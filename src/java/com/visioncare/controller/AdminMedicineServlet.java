package com.visioncare.controller;

import com.visioncare.dao.MedicineDAO;
import com.visioncare.dao.MedicineDAO.ImageData;
import com.visioncare.model.Medicine;
import com.visioncare.model.SupplyCategory;
import com.visioncare.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@WebServlet(name = "AdminMedicineServlet", urlPatterns = {"/admin/medicine", "/admin/medicine/item", "/medicine-image"})
@MultipartConfig(maxFileSize = 5 * 1024 * 1024, maxRequestSize = 6 * 1024 * 1024)
public class AdminMedicineServlet extends HttpServlet {
    private final MedicineDAO dao = new MedicineDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if ("/medicine-image".equals(request.getServletPath())) {
            showImage(request, response);
            return;
        }
        if (!isAdmin(request, response)) return;
        request.getSession().setAttribute("medicineCsrf", csrf(request));
        try {
            if ("/admin/medicine".equals(request.getServletPath())) {
                request.setAttribute("medicines", dao.list());
                request.setAttribute("medicineCategories", categories());
                request.getRequestDispatcher("/views/admin/medicine.jsp").forward(request, response);
                return;
            }
            if (!"/admin/medicine/item".equals(request.getServletPath())) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            List<Medicine> choices = dao.list();
            int id = optionalId(request.getParameter("id"));
            if (id == 0 && !"1".equals(request.getParameter("new")) && !choices.isEmpty()) {
                id = choices.get(0).getId();
            }
            Medicine item = id == 0 ? null : dao.get(id);
            if (id != 0 && item == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            request.setAttribute("item", item);
            request.setAttribute("choices", choices);
            request.setAttribute("medicineCategories", categories());
            request.getRequestDispatcher("/views/admin/medicine-edit.jsp").forward(request, response);
        } catch (IllegalArgumentException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
        } catch (Exception e) {
            log("Could not load medicine", e);
            showError(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAdmin(request, response)) return;
        if (!"/admin/medicine/item".equals(request.getServletPath())) {
            response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
            return;
        }
        String token = (String) request.getSession().getAttribute("medicineCsrf");
        if (token == null || !token.equals(request.getParameter("csrf"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        String action = request.getParameter("action");
        if ("delete".equals(action)) {
            delete(request, response);
            return;
        }
        if (action != null && !"save".equals(action)) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        try {
            int id = optionalId(request.getParameter("id"));
            String name = field(request, "name", 255, true);
            String category = field(request, "category", 100, true);
            SupplyCategory parsed = SupplyCategory.fromVietnameseName(category);
            if (parsed == null || !parsed.isRetail()) {
                throw new IllegalArgumentException("Phân loại vật tư bán lẻ không hợp lệ.");
            }
            ImageUpload upload = imageUpload(request);
            int savedId = dao.save(id, name, category, price(request),
                    upload == null ? null : upload.bytes,
                    upload == null ? null : upload.mimeType);
            response.sendRedirect(request.getContextPath() + "/admin/medicine?" +
                    (id == 0 ? "created=1" : "updated=1") + "&id=" + savedId);
        } catch (IllegalArgumentException e) {
            request.setAttribute("error", e.getMessage() == null ?
                    "Thông tin nhập không hợp lệ." : e.getMessage());
            showSubmittedForm(request, response);
        } catch (Exception e) {
            log("Could not save medicine", e);
            request.setAttribute("error", "Không lưu được vật tư bán lẻ. Kiểm tra kết nối database.");
            showSubmittedForm(request, response);
        }
    }

    private void delete(HttpServletRequest request, HttpServletResponse response) throws IOException {
        final int id;
        try {
            id = optionalId(request.getParameter("id"));
            if (id == 0) throw new IllegalArgumentException("Mã không hợp lệ.");
        } catch (IllegalArgumentException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        try {
            if (!dao.delete(id)) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            response.sendRedirect(request.getContextPath() + "/admin/medicine?deleted=1");
        } catch (Exception e) {
            log("Could not delete medicine", e);
            response.sendRedirect(request.getContextPath() + "/admin/medicine?deleteError=1");
        }
    }

    private void showImage(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id;
        try {
            id = Integer.parseInt(request.getParameter("id"));
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        if (id <= 0) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        try {
            ImageData image = dao.getImage(id);
            if (image == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            response.setHeader("X-Content-Type-Options", "nosniff");
            response.setHeader("Cache-Control", "no-store");
            response.setContentType(image.getMimeType());
            response.setContentLength(image.getBytes().length);
            response.getOutputStream().write(image.getBytes());
        } catch (Exception e) {
            throw new ServletException("Không đọc được ảnh vật tư bán lẻ", e);
        }
    }

    private void showSubmittedForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Map<String, Object> item = new HashMap<>();
        for (String key : new String[]{"id", "name", "category", "price"}) {
            item.put(key, request.getParameter(key));
        }
        try {
            request.setAttribute("choices", dao.list());
        } catch (Exception e) {
            log("Could not reload medicine choices", e);
        }
        request.setAttribute("item", item);
        request.setAttribute("medicineCategories", categories());
        request.getRequestDispatcher("/views/admin/medicine-edit.jsp").forward(request, response);
    }

    private SupplyCategory[] categories() {
        return SupplyCategory.retailValues();
    }

    private boolean isAdmin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        Object current = session == null ? null : session.getAttribute("user");
        if (current == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return false;
        }
        if (!(current instanceof User) || !"admin".equals(((User) current).getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return false;
        }
        return true;
    }

    private String csrf(HttpServletRequest request) {
        HttpSession session = request.getSession();
        String token = (String) session.getAttribute("medicineCsrf");
        return token == null ? UUID.randomUUID().toString() : token;
    }

    private int optionalId(String raw) {
        if (raw == null || raw.isBlank()) return 0;
        int id = Integer.parseInt(raw);
        if (id < 0) throw new IllegalArgumentException("Mã không hợp lệ.");
        return id;
    }

    private String field(HttpServletRequest request, String name, int max, boolean required) {
        String value = request.getParameter(name);
        value = value == null ? "" : value.trim();
        if (required && value.isEmpty()) throw new IllegalArgumentException("Vui lòng nhập đầy đủ thông tin bắt buộc.");
        if (value.length() > max) throw new IllegalArgumentException("Trường " + name + " vượt quá " + max + " ký tự.");
        return value;
    }

    private BigDecimal price(HttpServletRequest request) {
        BigDecimal value = new BigDecimal(field(request, "price", 12, true));
        if (value.signum() < 0 || value.scale() > 0 || value.precision() > 12) {
            throw new IllegalArgumentException("Đơn giá phải là số nguyên không âm, tối đa 12 chữ số.");
        }
        return value;
    }

    private ImageUpload imageUpload(HttpServletRequest request) throws Exception {
        Part part = request.getPart("imageFile");
        if (part == null || part.getSize() == 0) return null;
        if (part.getSize() > 5 * 1024 * 1024) {
            throw new IllegalArgumentException("Ảnh phải nhỏ hơn 5 MB.");
        }
        byte[] bytes;
        try (java.io.InputStream input = part.getInputStream()) {
            bytes = input.readAllBytes();
        }
        String mime;
        if (bytes.length >= 3 && (bytes[0] & 255) == 0xff && (bytes[1] & 255) == 0xd8 && (bytes[2] & 255) == 0xff) {
            mime = "image/jpeg";
        } else if (bytes.length >= 8 && (bytes[0] & 255) == 0x89 && bytes[1] == 'P' && bytes[2] == 'N' && bytes[3] == 'G'
                && bytes[4] == 13 && bytes[5] == 10 && bytes[6] == 26 && bytes[7] == 10) {
            mime = "image/png";
        } else if (bytes.length >= 12 && bytes[0] == 'R' && bytes[1] == 'I' && bytes[2] == 'F' && bytes[3] == 'F'
                && bytes[8] == 'W' && bytes[9] == 'E' && bytes[10] == 'B' && bytes[11] == 'P') {
            mime = "image/webp";
        } else {
            throw new IllegalArgumentException("Chỉ nhận ảnh JPG, PNG hoặc WebP.");
        }
        return new ImageUpload(bytes, mime);
    }

    private void showError(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("error", "Không tải được vật tư bán lẻ. Kiểm tra kết nối và bảng Medical_Supply trong eye_clinic_db.");
        request.getRequestDispatcher("/views/admin/medicine-error.jsp").forward(request, response);
    }

    private static final class ImageUpload {
        private final byte[] bytes;
        private final String mimeType;

        private ImageUpload(byte[] bytes, String mimeType) {
            this.bytes = bytes;
            this.mimeType = mimeType;
        }
    }
}
