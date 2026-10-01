package com.visioncare.controller;

import com.visioncare.dao.UserDAO;
import com.visioncare.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "ProfileServlet", urlPatterns = {"/profile/update", "/profile/change-password"})
public class ProfileServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String path = request.getServletPath();
        
        if ("/profile/change-password".equals(path)) {
            String oldPassword = request.getParameter("oldPassword");
            String newPassword = request.getParameter("newPassword");
            String confirmPassword = request.getParameter("confirmPassword");
            
            if (!currentUser.getPassword().equals(oldPassword)) {
                request.getSession().setAttribute("error", "Mật khẩu hiện tại không đúng!");
                response.sendRedirect(request.getContextPath() + "/views/profile/change-password.jsp");
                return;
            }
            if (!newPassword.equals(confirmPassword)) {
                request.getSession().setAttribute("error", "Mật khẩu xác nhận không khớp!");
                response.sendRedirect(request.getContextPath() + "/views/profile/change-password.jsp");
                return;
            }
            
            try {
                // Update password in DB
                userDAO.updatePassword(currentUser.getId(), newPassword);
                currentUser.setPassword(newPassword);
                session.setAttribute("user", currentUser);
                
                request.getSession().setAttribute("success", "Đổi mật khẩu thành công!");
                response.sendRedirect(request.getContextPath() + "/views/profile/change-password.jsp");
            } catch (Exception e) {
                e.printStackTrace();
                request.getSession().setAttribute("error", "Lỗi: " + e.getMessage());
                response.sendRedirect(request.getContextPath() + "/views/profile/change-password.jsp");
            }
            return;
        }

        // Profile update flow
        String fullName = request.getParameter("fullName");
        String phone = request.getParameter("phone");
        String dob = request.getParameter("dob");
        String address = request.getParameter("address");

        try {
            // Update object
            currentUser.setFullName(fullName);
            currentUser.setPhone(phone);
            currentUser.setDob(dob);
            currentUser.setAddress(address);
            
            // Update database
            userDAO.updateProfile(currentUser);
            
            // Update session
            session.setAttribute("user", currentUser);
            
            // Redirect back with success message
            request.getSession().setAttribute("success", "Cập nhật hồ sơ thành công!");
            response.sendRedirect(request.getContextPath() + "/views/profile/manage.jsp");
            
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("error", "Lỗi cập nhật: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/views/profile/manage.jsp");
        }
    }
}
