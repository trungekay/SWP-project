package com.visioncare.controller;
import com.visioncare.dao.DoctorDAO;
import com.visioncare.dao.CatalogDAO;
import com.visioncare.model.Doctor;
import com.visioncare.model.CatalogService;

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
    private final CatalogDAO catalogDAO = new CatalogDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        com.visioncare.model.User user = (com.visioncare.model.User) request.getSession().getAttribute("user");
        if (user != null) {
            String role = user.getRole();
            int roleId = user.getRoleId();
            if (roleId == 1 || "admin".equalsIgnoreCase(role)) {
                response.sendRedirect(request.getContextPath() + "/admin/users");
                return;
            } else if (roleId == 2 || "director".equalsIgnoreCase(role)) {
                response.sendRedirect(request.getContextPath() + "/director/revenue");
                return;
            } else if (roleId == 3 || "doctor".equalsIgnoreCase(role)
                    || roleId == 4 || "medical_specialist".equalsIgnoreCase(role) || "specialist".equalsIgnoreCase(role)
                    || roleId == 5 || "staff".equalsIgnoreCase(role)) {
                response.sendRedirect(request.getContextPath() + "/employee/schedule");
                return;
            }
        }
        try {
            List<Doctor> doctors = doctorDAO.getAll();
            request.setAttribute("doctors", doctors);
            List<CatalogService> catalogServices = catalogDAO.listServices();
            request.setAttribute("catalogServices", catalogServices);
            // Truyền ID của dịch vụ Khám tổng quát (NK-01) động từ DB —
            // dùng cho nút CTA "Đặt lịch Khám tổng quát trước" tại trang chủ
            // cho các dịch vụ Case 3 (chỉ nhận qua chỉ định bác sĩ).
            if (catalogServices != null) {
                for (CatalogService s : catalogServices) {
                    if ("NK-01".equalsIgnoreCase(s.getCode())) {
                        request.setAttribute("generalExamServiceId", s.getId());
                        break;
                    }
                }
            }
            com.visioncare.dao.ClinicGalleryDAO galleryDAO = new com.visioncare.dao.ClinicGalleryDAO();

            request.setAttribute("galleryItems", galleryDAO.getAll());

            request.getRequestDispatcher("/views/home/index.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            request.getRequestDispatcher("/views/error/500.jsp").forward(request, response);
        }
    }
}
