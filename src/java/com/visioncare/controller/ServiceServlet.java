package com.visioncare.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import com.visioncare.model.Service;
import com.visioncare.dao.ServiceDAO;

@WebServlet(name = "ServiceServlet", urlPatterns = {"/services"})
public class ServiceServlet extends HttpServlet {
    private ServiceDAO serviceDAO = new ServiceDAO();
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            List<Service> listServices = serviceDAO.getAllServices();
            request.setAttribute("services", listServices);
            
            request.getRequestDispatcher("/views/service/list.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/error-500.jsp");
        }
    }
}
