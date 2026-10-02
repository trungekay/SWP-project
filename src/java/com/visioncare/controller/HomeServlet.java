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
@WebServlet(name = "HomeServlet", urlPatterns = {"/home", ""})
public class HomeServlet extends HttpServlet {
    private final DoctorDAO doctorDAO = new DoctorDAO();
    private final DepartmentDAO departmentDAO = new DepartmentDAO();
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        com.visioncare.model.User user = (com.visioncare.model.User) request.getSession().getAttribute("user");
        if (user != null) {
            String role = user.getRole();
            if ("admin".equals(role)) {
                response.sendRedirect(request.getContextPath() + "/admin/users");
                return;
            } else if ("director".equals(role) || "staff".equals(role) || "doctor".equals(role) || "specialist".equals(role) || "medical_specialist".equals(role)) {
                response.sendRedirect(request.getContextPath() + "/employee/schedule");
                return;
            }
        }
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
