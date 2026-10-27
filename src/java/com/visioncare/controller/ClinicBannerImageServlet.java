package com.visioncare.controller;

import com.visioncare.dao.ClinicBannerDAO;
import com.visioncare.dao.ClinicBannerDAO.ImageData;
import com.visioncare.model.ClinicBanner;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "ClinicBannerImageServlet", urlPatterns = {"/clinic-banner-image"})
public class ClinicBannerImageServlet extends HttpServlet {
    private final ClinicBannerDAO dao = new ClinicBannerDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String key = request.getParameter("key");
        if (key == null || key.trim().isEmpty()) {
            key = "HERO_BANNER";
        }
        key = key.trim();

        try {
            ImageData img = dao.getImageData(key);
            if (img != null && img.getBytes() != null && img.getBytes().length > 0) {
                response.setHeader("X-Content-Type-Options", "nosniff");
                response.setHeader("Cache-Control", "no-cache, must-revalidate");
                response.setContentType(img.getMimeType() != null ? img.getMimeType() : "image/jpeg");
                response.setContentLength(img.getBytes().length);
                response.getOutputStream().write(img.getBytes());
                return;
            }

            ClinicBanner banner = dao.getByKey(key);
            if (banner != null && banner.getDefaultFilename() != null && !banner.getDefaultFilename().trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/assets/img/" + banner.getDefaultFilename());
                return;
            }

            if ("ABOUT_IMAGE".equalsIgnoreCase(key)) {
                response.sendRedirect(request.getContextPath() + "/assets/img/about.jpg");
            } else {
                response.sendRedirect(request.getContextPath() + "/assets/img/hero-bg.jpg");
            }
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/assets/img/hero-bg.jpg");
        }
    }
}
