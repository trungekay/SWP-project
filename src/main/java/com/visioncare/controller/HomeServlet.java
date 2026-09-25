package com.visioncare.controller;

import com.visioncare.dao.DoctorDAO;
import com.visioncare.dao.DepartmentDAO;
import com.visioncare.model.Doctor;
import com.visioncare.model.Department;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

/**
 * Servlet xử lý trang chủ VisionCare.
 * URL: /home hoặc /
 */
@WebServlet(name = "HomeServlet", urlPatterns = {"/home", ""})
public class HomeServlet extends HttpServlet {

    private final DoctorDAO doctorDAO = new DoctorDAO();
    private final DepartmentDAO departmentDAO = new DepartmentDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Bỏ qua kết nối DB tạm thời theo yêu cầu (chỉ làm frontend trước)
            /* 
            List<Doctor> doctors = doctorDAO.getAll();
            List<Department> departments = departmentDAO.getAll();
            request.setAttribute("doctors", doctors);
            request.setAttribute("departments", departments);
            */

            request.getRequestDispatcher("/views/home/index.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            request.getRequestDispatcher("/views/error/500.jsp").forward(request, response);
        }
    }
}
