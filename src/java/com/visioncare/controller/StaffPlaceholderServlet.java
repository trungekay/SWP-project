package com.visioncare.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Placeholder servlet for staff screens that are not yet implemented.
 * Automatically responds with HTTP 404 as requested.
 */
@WebServlet(name = "StaffPlaceholderServlet", urlPatterns = {
    "/staff/patients"
})
public class StaffPlaceholderServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendError(HttpServletResponse.SC_NOT_FOUND, "Chức năng đang được phát triển.");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendError(HttpServletResponse.SC_NOT_FOUND, "Chức năng đang được phát triển.");
    }
}
