package com.visioncare.controller;

import com.visioncare.dao.DoctorDAO;
import com.visioncare.dao.DepartmentDAO;
import com.visioncare.model.Doctor;
import com.visioncare.model.Department;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

/**
 * Servlet xá»­ lÃ½ trang chá»§ VisionCare.
 * URL: /home hoáº·c /
 */
@WebServlet(name = "HomeServlet", urlPatterns = {"/home", ""})
public class HomeServlet extends HttpServlet {

    private final DoctorDAO doctorDAO = new DoctorDAO();
    private final DepartmentDAO departmentDAO = new DepartmentDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            List<Doctor> doctors = doctorDAO.getAll();
            List<Department> departments = departmentDAO.getAll();
            request.setAttribute("doctors", doctors);
            request.setAttribute("departments", departments);

            request.getRequestDispatcher("/views/home/index.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "CÃ³ lá»—i xáº£y ra: " + e.getMessage());
            request.getRequestDispatcher("/views/error/500.jsp").forward(request, response);
        }
    }
}
