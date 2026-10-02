package com.visioncare.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Servlet xá»­ lÃ½ mÃ n hÃ¬nh Cáº¥u hÃ¬nh phÃ²ng khÃ¡m (Admin)
 */
@WebServlet(name = "AdminClinicConfigServlet", urlPatterns = {"/admin/clinic-config"})
public class AdminClinicConfigServlet extends HttpServlet {

    private final com.visioncare.dao.RoomDAO roomDAO = new com.visioncare.dao.RoomDAO();
    private final com.visioncare.dao.TimeSlotDAO timeSlotDAO = new com.visioncare.dao.TimeSlotDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            request.setAttribute("rooms", roomDAO.getAll());
            request.setAttribute("timeSlots", timeSlotDAO.getConfiguredSlots());
            com.visioncare.dao.DoctorDAO doctorDAO = new com.visioncare.dao.DoctorDAO();
            request.setAttribute("doctors", doctorDAO.getAll());
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lá»—i táº£i cáº¥u hÃ¬nh: " + e.getMessage());
        }

        request.getRequestDispatcher("/views/admin/clinic-config.jsp").forward(request, response);
    }
}
