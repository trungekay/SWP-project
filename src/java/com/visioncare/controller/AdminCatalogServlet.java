package com.visioncare.controller;

import com.visioncare.dao.CatalogDAO;
import com.visioncare.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@WebServlet(name = "AdminCatalogServlet", urlPatterns = {
    "/admin/catalog", "/admin/catalog/service", "/admin/catalog/supply"
})
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
                List<Map<String, Object>> choices = service ? dao.listServices() : dao.listSupplies();
                int id = optionalId(request.getParameter("id"));
                if (id == 0 && !"1".equals(request.getParameter("new")) && !choices.isEmpty()) {
                    id = (Integer) choices.get(0).get("id");
                }
                Map<String, Object> item = id == 0 ? new HashMap<>() :
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
            request.setAttribute("error", "Không tải được danh mục. Hãy kiểm tra kết nối và chạy catalog_migration_v2.sql.");
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
        try {
            int id = optionalId(request.getParameter("id"));
            int savedId;
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
                String image = field(request, "image", 255, false);
                if (!image.isEmpty() && !image.matches("(departments-[1-5]\\.jpg|gallery/gallery-1\\.jpg)")) {
                    throw new IllegalArgumentException("Ảnh dịch vụ không hợp lệ.");
                }
                savedId = dao.saveService(id, user.getId(), code, name, price, specialty, tag, summary, description, image);
            } else {
                String name = field(request, "name", 255, true);
                String category = field(request, "category", 100, true);
                String batch = field(request, "batch", 50, false);
                String unit = field(request, "unit", 30, true);
                int quantity = Integer.parseInt(field(request, "quantity", 10, true));
                if (quantity < 0) throw new IllegalArgumentException("Số lượng không được âm.");
                savedId = dao.saveSupply(id, name, category, batch, unit, quantity, price(request));
            }
            response.sendRedirect(request.getContextPath() + "/admin/catalog?tab=" + (service ? "services" : "supplies") + "&saved=1&id=" + savedId);
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
}
