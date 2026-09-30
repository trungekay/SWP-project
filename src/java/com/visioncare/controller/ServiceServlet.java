package com.visioncare.controller;

import com.visioncare.dao.ServiceDAO;
import com.visioncare.model.Service;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "ServiceServlet", urlPatterns = {"/services"})
public class ServiceServlet extends HttpServlet {
    private final ServiceDAO serviceDAO = new ServiceDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Controller gọi DAO để lấy Data
            List<Service> listServices = serviceDAO.getAllServices();
            request.setAttribute("services", listServices);
            
            // Forward Data sang View (JSP)
            request.getRequestDispatcher("/views/service/list.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace(); // Log lỗi cho server
            response.sendRedirect(request.getContextPath() + "/error-500.jsp");
        }
    }
}
