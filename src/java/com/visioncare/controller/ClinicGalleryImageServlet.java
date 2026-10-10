package com.visioncare.controller;

import com.visioncare.dao.ClinicGalleryDAO;
import com.visioncare.dao.ClinicGalleryDAO.ImageData;
import com.visioncare.model.ClinicGalleryItem;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "ClinicGalleryImageServlet", urlPatterns = {"/clinic-gallery-image"})
public class ClinicGalleryImageServlet extends HttpServlet {
    private final ClinicGalleryDAO dao = new ClinicGalleryDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int id;
        try {
            id = Integer.parseInt(request.getParameter("id"));
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        try {
            ImageData img = dao.getImageData(id);
            if (img != null && img.getBytes() != null && img.getBytes().length > 0) {
                response.setHeader("X-Content-Type-Options", "nosniff");
                response.setHeader("Cache-Control", "no-cache, must-revalidate");
                response.setContentType(img.getMimeType() != null ? img.getMimeType() : "image/jpeg");
                response.setContentLength(img.getBytes().length);
                response.getOutputStream().write(img.getBytes());
                return;
            }

            ClinicGalleryItem item = dao.getById(id);
            if (item != null && item.getDefaultFilename() != null && !item.getDefaultFilename().trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/assets/img/gallery/" + item.getDefaultFilename());
                return;
            }

            if (id >= 1 && id <= 8) {
                response.sendRedirect(request.getContextPath() + "/assets/img/gallery/gallery-" + id + ".jpg");
                return;
            }

            response.sendRedirect(request.getContextPath() + "/assets/img/gallery/gallery-1.jpg");
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/assets/img/gallery/gallery-1.jpg");
        }
    }
}
