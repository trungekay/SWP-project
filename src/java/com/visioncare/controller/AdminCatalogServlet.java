package com.visioncare.controller;

import com.visioncare.dao.CatalogDAO;
import com.visioncare.dao.CatalogDAO.ImageData;
import com.visioncare.model.CatalogService;
import com.visioncare.model.MedicalSupply;
import com.visioncare.model.ServiceCategory;
import com.visioncare.model.SupplyCategory;
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
    "/admin/catalog", "/admin/catalog/service", "/admin/catalog/supply",
    "/admin/catalog/consumable", "/catalog-image"
})
@MultipartConfig(maxFileSize = 5 * 1024 * 1024, maxRequestSize = 6 * 1024 * 1024)
public class AdminCatalogServlet extends HttpServlet {
    private final CatalogDAO dao = new CatalogDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if ("/catalog-image".equals(request.getServletPath())) {
            showImage(request, response);
            return;
        }
        if (admin(request, response) == null) return;
        request.getSession().setAttribute("catalogCsrf", csrf(request));
        String path = request.getServletPath();
        try {
            if ("/admin/catalog".equals(path) && "retail".equals(request.getParameter("tab"))) {
                response.sendRedirect(request.getContextPath() + "/admin/medicine");
                return;
            }
            if ("/admin/catalog".equals(path)) {
                request.setAttribute("catalogServices", dao.listServices());
                request.setAttribute("catalogSupplies", dao.listSupplies("supply"));
                request.setAttribute("catalogConsumables", dao.listSupplies("consumable"));
                request.getRequestDispatcher("/views/admin/catalog.jsp").forward(request, response);
            } else {
                String kind = kind(path);
                if ("supply".equals(kind) && "consumables".equals(request.getParameter("returnTab"))) {
                    response.sendRedirect(request.getContextPath() + "/admin/catalog/consumable" +
                            (request.getQueryString() == null ? "?new=1" : "?" + request.getQueryString()));
                    return;
                }
                boolean service = "service".equals(kind);
                List<?> choices = service ? dao.listServices() : dao.listSupplies(kind);
                int id = optionalId(request.getParameter("id"));
                if (id == 0 && !"1".equals(request.getParameter("new")) && !choices.isEmpty()) {
                    id = service ? ((CatalogService) choices.get(0)).getId()
                            : ((MedicalSupply) choices.get(0)).getId();
                }
                Object item = id == 0 ? new HashMap<String, Object>() :
                        (service ? dao.getService(id) : dao.getSupply(kind, id));
                if (item == null) { response.sendError(HttpServletResponse.SC_NOT_FOUND); return; }
                request.setAttribute("choices", choices);
                if (!service) request.setAttribute("supplyCategories", SupplyCategory.values());
                if (service) {
                    request.setAttribute("serviceCategories", ServiceCategory.values());
                }
                request.setAttribute("item", item);
                request.setAttribute("kind", kind);
                request.setAttribute("catalogReturnTab", returnTab(kind));
                request.getRequestDispatcher("/views/admin/catalog-edit.jsp").forward(request, response);
            }
        } catch (IllegalArgumentException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
        } catch (Exception e) {
            log("Could not load admin catalog", e);
            request.setAttribute("error", "Không tải được danh mục. Hãy kiểm tra kết nối và cấu trúc bảng Service_Catalog, Medical_Supply, Consumables trong eye_clinic_db.");
            request.getRequestDispatcher("/views/admin/catalog-error.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if ("/catalog-image".equals(request.getServletPath())) {
            response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
            return;
        }
        User user = admin(request, response);
        if (user == null) return;
        String path = request.getServletPath();
        if ("/admin/catalog".equals(path)) { response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED); return; }
        String kind = kind(path);
        boolean service = "service".equals(kind);
        String token = (String) request.getSession().getAttribute("catalogCsrf");
        if (token == null || !token.equals(request.getParameter("csrf"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN); return;
        }
        String action = request.getParameter("action");
        if ("delete".equals(action)) {
            delete(request, response, kind);
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
                if (price.compareTo(BigDecimal.valueOf(10000)) < 0) {
                    throw new IllegalArgumentException("Đơn giá dịch vụ phải từ 10.000 VNĐ trở lên.");
                }
                String category = field(request, "category", 100, true);
                if (ServiceCategory.fromVietnameseName(category) == null) {
                    throw new IllegalArgumentException("Nhóm dịch vụ không hợp lệ.");
                }
                String summary = field(request, "summary", 500, false);
                String description = field(request, "description", 4000, false);
                savedId = dao.saveService(id, code, name, price, category, summary,
                        description, upload == null ? null : upload.getBytes(),
                        upload == null ? null : upload.getMimeType());
            } else {
                String name = field(request, "name", 255, true);
                String category = field(request, "category", 100, true);
                validateCategory(kind, category);
                savedId = dao.saveSupply(kind, id, name, category, price(request),
                        upload == null ? null : upload.getBytes(),
                        upload == null ? null : upload.getMimeType());
            }
            response.sendRedirect(request.getContextPath() + listUrl(kind)
                    + (listUrl(kind).contains("?") ? "&" : "?")
                    + (id == 0 ? "created=1" : "updated=1") + "&id=" + savedId);
        } catch (IllegalArgumentException e) {
            request.setAttribute("error", e.getMessage() == null ? "Thông tin nhập không hợp lệ." : e.getMessage());
            showFormWithSubmittedValues(request, response, kind);
        } catch (Exception e) {
            log("Could not save admin catalog", e);
            request.setAttribute("error", "Không lưu được dữ liệu. Kiểm tra mã trùng hoặc kết nối database.");
            showFormWithSubmittedValues(request, response, kind);
        }
    }

    private void showFormWithSubmittedValues(HttpServletRequest request, HttpServletResponse response, String kind)
            throws ServletException, IOException {
        boolean service = "service".equals(kind);
        Map<String, Object> item = new HashMap<>();
        for (String key : new String[]{"id", "code", "name", "price", "category", "summary", "description", "image"}) {
            item.put(key, request.getParameter(key));
        }
        try {
            request.setAttribute("choices", service ? dao.listServices() : dao.listSupplies(kind));
            if (!service) request.setAttribute("supplyCategories", SupplyCategory.values());
            if (service) {
                request.setAttribute("serviceCategories", ServiceCategory.values());
            }
        } catch (Exception e) {
            log("Could not reload catalog choices", e);
        }
        request.setAttribute("item", item);
        request.setAttribute("kind", kind);
        request.setAttribute("catalogReturnTab", returnTab(kind));
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
        BigDecimal value = new BigDecimal(field(request, "price", 12, true));
        if (value.signum() < 0 || value.scale() > 0 || value.precision() > 12) {
            throw new IllegalArgumentException("Đơn giá phải là số nguyên không âm, tối đa 12 chữ số.");
        }
        return value;
    }

    private void delete(HttpServletRequest request, HttpServletResponse response, String kind)
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
            boolean deleted = "service".equals(kind) ? dao.deleteService(id) : dao.deleteSupply(kind, id);
            if (!deleted) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            response.sendRedirect(request.getContextPath() + listUrl(kind)
                    + (listUrl(kind).contains("?") ? "&" : "?") + "deleted=1");
        } catch (Exception e) {
            log("Could not delete catalog item", e);
            response.sendRedirect(request.getContextPath() + listUrl(kind)
                    + (listUrl(kind).contains("?") ? "&" : "?") + "deleteError=1");
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
        if ("medicine".equals(request.getParameter("kind"))) {
            response.sendRedirect(request.getContextPath() + "/medicine-image?id=" + id);
            return;
        }
        try {
            ImageData image = dao.getImage(request.getParameter("kind"), id);
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
            throw new ServletException("Không đọc được ảnh danh mục", e);
        }
    }

    private String kind(String path) {
        switch (path) {
            case "/admin/catalog/service": return "service";
            case "/admin/catalog/supply": return "supply";
            case "/admin/catalog/consumable": return "consumable";
            default: throw new IllegalArgumentException("Đường dẫn không hợp lệ.");
        }
    }

    private String returnTab(String kind) {
        switch (kind) {
            case "service": return "services";
            case "supply": return "supplies";
            case "consumable": return "consumables";
            default: throw new IllegalArgumentException("Loại vật tư không hợp lệ.");
        }
    }

    private String listUrl(String kind) {
        return "/admin/catalog?tab=" + returnTab(kind);
    }

    private void validateCategory(String kind, String category) {
        SupplyCategory value = SupplyCategory.fromVietnameseName(category);
        boolean valid = value != null &&
                ("supply".equals(kind) && value == SupplyCategory.OTHER ||
                 "consumable".equals(kind) && value == SupplyCategory.MEDICAL_CONSUMABLES);
        if (!valid) throw new IllegalArgumentException("Phân loại vật tư không hợp lệ.");
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
