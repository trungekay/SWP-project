package com.visioncare.controller;

import com.visioncare.dao.CatalogDAO;
import com.visioncare.dao.CatalogDAO.ImageData;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "CatalogImageServlet", urlPatterns = {"/catalog-image"})
public class CatalogImageServlet extends HttpServlet {
    private final CatalogDAO dao = new CatalogDAO();

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
        if (id <= 0) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
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
}
