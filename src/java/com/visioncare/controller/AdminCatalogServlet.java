package com.visioncare.controller;

import com.visioncare.dao.CatalogDAO;
import com.visioncare.model.CatalogService;
import com.visioncare.model.MedicalSupply;
import com.visioncare.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.annotation.MultipartConfig;
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

@WebServlet(name = "AdminCatalogServlet", urlPatterns = {
    "/admin/catalog", "/admin/catalog/service", "/admin/catalog/supply"
})
@MultipartConfig(maxFileSize = 5 * 1024 * 1024, maxRequestSize = 6 * 1024 * 1024)
public class AdminCatalogServlet extends HttpServlet {
    private final CatalogDAO dao = new CatalogDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (admin(request, response) == null) return;
        request.getSession().setAttribute("catalogCsrf", csrf(request));
        String path = request.getServletPath();
        try {
            if ("/admin/catalog".equals(path)) {
                request.setAttribute("catalogServices", dao.listServices());
                request.setAttribute("catalogSupplies", dao.listSupplies());
                request.getRequestDispatcher("/views/admin/catalog.jsp").forward(request, response);
            } else {
                boolean service = path.endsWith("/service");
                List<?> choices = service ? dao.listServices() : dao.listSupplies();
                int id = optionalId(request.getParameter("id"));
                if (id == 0 && !"1".equals(request.getParameter("new")) && !choices.isEmpty()) {
                    id = service ? ((CatalogService) choices.get(0)).getId()
                            : ((MedicalSupply) choices.get(0)).getId();
                }
                Object item = id == 0 ? new HashMap<String, Object>() :
                        (service ? dao.getService(id) : dao.getSupply(id));
                if (item == null) { response.sendError(HttpServletResponse.SC_NOT_FOUND); return; }
                request.setAttribute("choices", choices);
                request.setAttribute("item", item);
                request.setAttribute("kind", service ? "service" : "supply");
                request.getRequestDispatcher("/views/admin/catalog-edit.jsp").forward(request, response);
            }
        } catch (IllegalArgumentException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
        } catch (Exception e) {
            log("Could not load admin catalog", e);
            request.setAttribute("error", "Không tải được danh mục. Hãy kiểm tra kết nối và cấu trúc bảng Service_Catalog, Medical_Supply trong eye_clinic_db_v2.");
            request.getRequestDispatcher("/views/admin/catalog-error.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = admin(request, response);
        if (user == null) return;
        String path = request.getServletPath();
        if ("/admin/catalog".equals(path)) { response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED); return; }
        String token = (String) request.getSession().getAttribute("catalogCsrf");
        if (token == null || !token.equals(request.getParameter("csrf"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN); return;
        }
        boolean service = path.endsWith("/service");
        String action = request.getParameter("action");
        if ("delete".equals(action)) {
            delete(request, response, service);
            return;
        }
        if (action != null && !"save".equals(action)) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        try {
            int id = optionalId(request.getParameter("id"));
            int savedId;
            CatalogDAO.ImageData upload = imageUpload(request);
            if (service) {
                String code = field(request, "code", 20, false);
                String name = field(request, "name", 255, true);
                BigDecimal price = price(request);
                String specialty = field(request, "specialty", 30, false);
                if (!specialty.isEmpty() && !List.of("general", "refraction", "lasik", "children", "retina", "cataract").contains(specialty)) {
                    throw new IllegalArgumentException("Chuyên khoa không hợp lệ.");
                }
                String tag = field(request, "tag", 100, false);
                String summary = field(request, "summary", 500, false);
                String description = field(request, "description", 4000, false);
                savedId = dao.saveService(id, user.getId(), code, name, price, specialty, tag, summary,
                        description, upload == null ? null : upload.getBytes(),
                        upload == null ? null : upload.getMimeType());
            } else {
                String name = field(request, "name", 255, true);
                String category = field(request, "category", 100, true);
                String batch = field(request, "batch", 50, false);
                String unit = field(request, "unit", 30, true);
                int quantity = Integer.parseInt(field(request, "quantity", 10, true));
                if (quantity < 0) throw new IllegalArgumentException("Số lượng không được âm.");
                savedId = dao.saveSupply(id, name, category, batch, unit, quantity, price(request),
                        upload == null ? null : upload.getBytes(),
                        upload == null ? null : upload.getMimeType());
            }
            response.sendRedirect(request.getContextPath() + "/admin/catalog?tab=" + (service ? "services" : "supplies")
                    + (id == 0 ? "&created=1" : "&updated=1") + "&id=" + savedId);
        } catch (IllegalArgumentException e) {
            request.setAttribute("error", e.getMessage() == null ? "Thông tin nhập không hợp lệ." : e.getMessage());
            showFormWithSubmittedValues(request, response, service);
        } catch (Exception e) {
            log("Could not save admin catalog", e);
            request.setAttribute("error", "Không lưu được dữ liệu. Kiểm tra mã trùng hoặc kết nối database.");
            showFormWithSubmittedValues(request, response, service);
        }
    }

    private void showFormWithSubmittedValues(HttpServletRequest request, HttpServletResponse response, boolean service)
            throws ServletException, IOException {
        Map<String, Object> item = new HashMap<>();
        for (String key : new String[]{"id", "code", "name", "price", "specialty", "tag", "summary", "description", "image", "category", "batch", "unit", "quantity"}) {
            item.put(key, request.getParameter(key));
        }
        try {
            request.setAttribute("choices", service ? dao.listServices() : dao.listSupplies());
        } catch (Exception e) {
            log("Could not reload catalog choices", e);
        }
        request.setAttribute("item", item);
        request.setAttribute("kind", service ? "service" : "supply");
        request.getRequestDispatcher("/views/admin/catalog-edit.jsp").forward(request, response);
    }

    private User admin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        Object current = session == null ? null : session.getAttribute("user");
        if (current == null) { response.sendRedirect(request.getContextPath() + "/login"); return null; }
        if (!(current instanceof User) || !"admin".equals(((User) current).getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN); return null;
        }
        return (User) current;
    }

    private String csrf(HttpServletRequest request) {
        HttpSession session = request.getSession();
        String token = (String) session.getAttribute("catalogCsrf");
        if (token == null) token = UUID.randomUUID().toString();
        return token;
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
        BigDecimal value = new BigDecimal(field(request, "price", 18, true));
        if (value.signum() < 0 || value.scale() > 0 || value.precision() > 18) {
            throw new IllegalArgumentException("Đơn giá phải là số nguyên không âm, tối đa 18 chữ số.");
        }
        return value;
    }

    private void delete(HttpServletRequest request, HttpServletResponse response, boolean service)
            throws IOException {
        final int id;
        try {
            id = optionalId(request.getParameter("id"));
            if (id == 0) throw new IllegalArgumentException("Mã không hợp lệ.");
        } catch (IllegalArgumentException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        try {
            boolean deleted = service ? dao.deleteService(id) : dao.deleteSupply(id);
            if (!deleted) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            response.sendRedirect(request.getContextPath() + "/admin/catalog?tab="
                    + (service ? "services" : "supplies") + "&deleted=1");
        } catch (Exception e) {
            log("Could not delete catalog item", e);
            response.sendRedirect(request.getContextPath() + "/admin/catalog?tab="
                    + (service ? "services" : "supplies") + "&deleteError=1");
        }
    }

    private CatalogDAO.ImageData imageUpload(HttpServletRequest request) throws Exception {
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
        return new CatalogDAO.ImageData(bytes, mime);
    }
}
