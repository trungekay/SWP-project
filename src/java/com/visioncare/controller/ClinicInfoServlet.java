package com.visioncare.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Servlet xử lý hiển thị thông tin phòng khám
 */
@WebServlet(name = "ClinicInfoServlet", urlPatterns = {"/clinic-info"})
public class ClinicInfoServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Mock dữ liệu thông tin phòng khám (Có thể mở rộng đọc từ DB nếu cần)
        request.setAttribute("clinicName", "VisionCare Eye Clinic");
        request.setAttribute("address", "123 Lê Lợi, Quận 1, TP.HCM");
        request.setAttribute("phone", "0901234567");
        request.setAttribute("email", "contact@visioncare.com");
        request.setAttribute("workingHours", "Thứ 2 - Thứ 7: 08:00 - 17:00");
        
        // Chuyển hướng tới giao diện JSP
        request.getRequestDispatcher("/views/clinic/info.jsp").forward(request, response);
    }
}
