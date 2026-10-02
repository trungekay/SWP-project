package com.visioncare.controller;

import com.visioncare.dao.UserDAO;
import com.visioncare.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "AdminUserAddServlet", urlPatterns = {"/admin/users/add"})
public class AdminUserAddServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/views/admin/user-add.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String phone = request.getParameter("phone");
        if (phone != null) {
            phone = phone.trim();
            if (phone.startsWith("+84")) {
                phone = "0" + phone.substring(3);
            }
            phone = phone.replaceAll("\\s+", ""); // Xóa khoảng trắng
        }
        int roleId = Integer.parseInt(request.getParameter("roleId"));
        
        User user = new User();
        user.setFullName(fullName);
        user.setEmail(email);
        user.setPassword(password);
        user.setPhone(phone);
        user.setRoleId(roleId);
        
        try {
            boolean success = userDAO.addSystemUser(user);
            if (success) {
                request.getSession().setAttribute("success", "Thêm người dùng thành công!");
                response.sendRedirect(request.getContextPath() + "/admin/users");
            } else {
                request.setAttribute("error", "Lỗi khi thêm người dùng.");
                request.getRequestDispatcher("/views/admin/user-add.jsp").forward(request, response);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            request.setAttribute("error", "Lỗi hệ thống: " + ex.getMessage());
            request.getRequestDispatcher("/views/admin/user-add.jsp").forward(request, response);
        }
    }
}
