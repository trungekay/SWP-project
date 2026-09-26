package com.visioncare.controller;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Servlet xử lý màn hình Cấu hình phòng khám (Admin)
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
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi tải cấu hình: " + e.getMessage());
        }

        request.getRequestDispatcher("/views/admin/clinic-config.jsp").forward(request, response);
    }
}
