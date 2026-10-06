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


        String fullName = request.getParameter("fullName");
        String phone = request.getParameter("phone");
        
        if (phone != null) {
            phone = phone.trim().replaceAll("\\s+", "");
            if (!phone.matches("\\d{10}")) {
                request.getSession().setAttribute("error", "Số điện thoại không hợp lệ. Phải bao gồm đúng 10 chữ số.");
                response.sendRedirect(request.getContextPath() + "/views/profile/manage.jsp");
                return;
            }
        }
        
        String dob = request.getParameter("dob");
        if (dob != null && !dob.trim().isEmpty()) {
            dob = dob.trim();
            if (dob.matches("\\d{2}/\\d{2}/\\d{4}")) {
                String[] parts = dob.split("/");
                dob = parts[2] + "-" + parts[1] + "-" + parts[0];
            } else if (dob.matches("\\d{2}-\\d{2}-\\d{4}")) {
                String[] parts = dob.split("-");
                dob = parts[2] + "-" + parts[1] + "-" + parts[0];
            }
        }
        
        String address = request.getParameter("address");
        try {
            currentUser.setFullName(fullName);
            currentUser.setPhone(phone);
            currentUser.setDob(dob);
            currentUser.setAddress(address);
            
            userDAO.updateProfile(currentUser);
            
            session.setAttribute("user", currentUser);
            
            request.getSession().setAttribute("success", "Cập nhật hồ sơ thành công!");
            response.sendRedirect(request.getContextPath() + "/views/profile/manage.jsp");
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("error", "Lỗi cập nhật: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/views/profile/manage.jsp");
        }
    }
}
