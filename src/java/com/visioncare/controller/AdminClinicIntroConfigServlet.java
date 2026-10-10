package com.visioncare.controller;

import com.visioncare.dao.ClinicGalleryDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import java.io.IOException;
import java.io.InputStream;

@WebServlet(name = "AdminClinicIntroConfigServlet", urlPatterns = {"/admin/clinic-intro-config"})
@MultipartConfig(maxFileSize = 10 * 1024 * 1024, maxRequestSize = 12 * 1024 * 1024)
public class AdminClinicIntroConfigServlet extends HttpServlet {
    private final ClinicGalleryDAO galleryDAO = new ClinicGalleryDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/admin/clinic-config?tab=intro");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        if (action == null) {
            action = "";
        }

        try {
            if ("add".equalsIgnoreCase(action)) {
                // Thêm hình ảnh mới
                String title = request.getParameter("title");
                String description = request.getParameter("description");
                int displayOrder = 1;
                try {
                    displayOrder = Integer.parseInt(request.getParameter("displayOrder"));
                } catch (Exception ignored) {}

                if (title == null || title.trim().isEmpty()) {
                    title = "Hình ảnh phòng khám";
                }

                Part imagePart = request.getPart("imageFile");
                if (imagePart == null || imagePart.getSize() <= 0) {
                    request.getSession().setAttribute("errorMsg", "Vui lòng chọn tệp hình ảnh để tải lên!");
                    response.sendRedirect(request.getContextPath() + "/admin/clinic-config?tab=intro");
                    return;
                }

                if (imagePart.getSize() > 10 * 1024 * 1024) {
                    request.getSession().setAttribute("errorMsg", "Kích thước ảnh tối đa là 10MB!");
                    response.sendRedirect(request.getContextPath() + "/admin/clinic-config?tab=intro");
                    return;
                }

                byte[] bytes;
                try (InputStream is = imagePart.getInputStream()) {
                    bytes = is.readAllBytes();
                }

                String mimeType = imagePart.getContentType();
                if (mimeType == null || !mimeType.startsWith("image/")) {
                    mimeType = detectMimeType(bytes);
                }

                boolean added = galleryDAO.insertItem(title.trim(), description != null ? description.trim() : "", displayOrder, bytes, mimeType);
                if (added) {
                    request.getSession().setAttribute("successMsg", "Đã thêm hình ảnh giới thiệu mới thành công!");
                } else {
                    request.getSession().setAttribute("errorMsg", "Không thể thêm hình ảnh vào hệ thống.");
                }

            } else if ("delete".equalsIgnoreCase(action)) {
                // Xóa hình ảnh
                int itemId = 0;
                try {
                    itemId = Integer.parseInt(request.getParameter("itemId"));
                } catch (Exception ignored) {}

                if (itemId <= 0) {
                    request.getSession().setAttribute("errorMsg", "Mã hình ảnh cần xóa không hợp lệ!");
                } else {
                    boolean deleted = galleryDAO.deleteItem(itemId);
                    if (deleted) {
                        request.getSession().setAttribute("successMsg", "Đã xóa hình ảnh #" + itemId + " thành công!");
                    } else {
                        request.getSession().setAttribute("errorMsg", "Không tìm thấy hoặc không thể xóa hình ảnh #" + itemId);
                    }
                }

            } else if ("reset".equalsIgnoreCase(action)) {
                // Khôi phục ảnh mặc định
                int itemId = 0;
                try {
                    itemId = Integer.parseInt(request.getParameter("itemId"));
                } catch (Exception ignored) {}

                if (itemId <= 0) {
                    request.getSession().setAttribute("errorMsg", "Mã hình ảnh không hợp lệ!");
                } else {
                    galleryDAO.resetToDefault(itemId);
                    request.getSession().setAttribute("successMsg", "Đã đặt lại hình ảnh #" + itemId + " về ảnh mặc định thành công!");
                }

            } else {
                // Cập nhật thông tin / sửa hình ảnh (update)
                int itemId = 0;
                try {
                    itemId = Integer.parseInt(request.getParameter("itemId"));
                } catch (Exception ignored) {}

                if (itemId <= 0) {
                    request.getSession().setAttribute("errorMsg", "Mã hình ảnh cần cập nhật không hợp lệ!");
                    response.sendRedirect(request.getContextPath() + "/admin/clinic-config?tab=intro");
                    return;
                }

                String title = request.getParameter("title");
                String description = request.getParameter("description");
                int displayOrder = 1;
                try {
                    displayOrder = Integer.parseInt(request.getParameter("displayOrder"));
                } catch (Exception ignored) {}

                if (title == null || title.trim().isEmpty()) {
                    title = "Hình ảnh phòng khám #" + itemId;
                }

                Part imagePart = request.getPart("imageFile");
                byte[] bytes = null;
                String mimeType = null;

                if (imagePart != null && imagePart.getSize() > 0) {
                    if (imagePart.getSize() > 10 * 1024 * 1024) {
                        request.getSession().setAttribute("errorMsg", "Kích thước ảnh tối đa là 10MB!");
                        response.sendRedirect(request.getContextPath() + "/admin/clinic-config?tab=intro");
                        return;
                    }

                    try (InputStream is = imagePart.getInputStream()) {
                        bytes = is.readAllBytes();
                    }

                    mimeType = imagePart.getContentType();
                    if (mimeType == null || !mimeType.startsWith("image/")) {
                        mimeType = detectMimeType(bytes);
                    }
                }

                boolean updated = galleryDAO.updateItem(itemId, title.trim(), description != null ? description.trim() : "", displayOrder, bytes, mimeType);
                if (updated) {
                    request.getSession().setAttribute("successMsg", "Cập nhật thông tin hình ảnh #" + itemId + " thành công!");
                } else {
                    request.getSession().setAttribute("errorMsg", "Không thể cập nhật hình ảnh #" + itemId);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMsg", "Lỗi xử lý hình ảnh: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/admin/clinic-config?tab=intro");
    }

    private String detectMimeType(byte[] bytes) {
        if (bytes == null || bytes.length < 4) return "image/jpeg";
        if ((bytes[0] & 255) == 0xff && (bytes[1] & 255) == 0xd8) return "image/jpeg";
        if ((bytes[0] & 255) == 0x89 && bytes[1] == 'P' && bytes[2] == 'N' && bytes[3] == 'G') return "image/png";
        if (bytes.length >= 12 && bytes[0] == 'R' && bytes[1] == 'I' && bytes[2] == 'F' && bytes[3] == 'F') return "image/webp";
        return "image/jpeg";
    }
}
