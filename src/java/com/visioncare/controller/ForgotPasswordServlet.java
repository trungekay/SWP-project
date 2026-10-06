package com.visioncare.controller;

import com.visioncare.dao.UserDAO;
import com.visioncare.model.User;
import com.visioncare.util.EmailUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Random;

@WebServlet(name = "ForgotPasswordServlet", urlPatterns = {"/forgot-password", "/forgot-password/verify", "/forgot-password/reset"})
public class ForgotPasswordServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        if ("/forgot-password/verify".equals(path)) {
            request.getRequestDispatcher("/views/auth/verify-reset-otp.jsp").forward(request, response);
            return;
        } else if ("/forgot-password/reset".equals(path)) {
            HttpSession session = request.getSession();
            if (session.getAttribute("resetEmail") == null || session.getAttribute("resetOtpVerified") == null) {
                response.sendRedirect(request.getContextPath() + "/forgot-password");
                return;
            }
            request.getRequestDispatcher("/views/auth/reset-password.jsp").forward(request, response);
            return;
        }

        // Default to /forgot-password
        request.getRequestDispatcher("/views/auth/forgot-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        HttpSession session = request.getSession();

        if ("/forgot-password/verify".equals(path)) {
            String otp1 = request.getParameter("otp1");
            String otp2 = request.getParameter("otp2");
            String otp3 = request.getParameter("otp3");
            String otp4 = request.getParameter("otp4");
            String otp5 = request.getParameter("otp5");
            String otp6 = request.getParameter("otp6");
            
            String enteredOtp = otp1 + otp2 + otp3 + otp4 + otp5 + otp6;
            String sessionOtp = (String) session.getAttribute("resetOtp");
            
            if (sessionOtp != null && sessionOtp.equals(enteredOtp)) {
                session.setAttribute("resetOtpVerified", true);
                response.sendRedirect(request.getContextPath() + "/forgot-password/reset");
            } else {
                request.setAttribute("error", "Mã xác thực không chính xác.");
                request.getRequestDispatcher("/views/auth/verify-reset-otp.jsp").forward(request, response);
            }
            return;
        } else if ("/forgot-password/reset".equals(path)) {
            String newPassword = request.getParameter("newPassword");
            String confirmPassword = request.getParameter("confirmPassword");
            String email = (String) session.getAttribute("resetEmail");
            
            if (email == null || session.getAttribute("resetOtpVerified") == null) {
                response.sendRedirect(request.getContextPath() + "/forgot-password");
                return;
            }
            
            if (!newPassword.equals(confirmPassword)) {
                request.setAttribute("error", "Mật khẩu xác nhận không khớp.");
                request.getRequestDispatcher("/views/auth/reset-password.jsp").forward(request, response);
                return;
            }
            
            if (newPassword.length() < 8 || !newPassword.matches(".*[A-Z].*") || !newPassword.matches(".*[a-z].*")) {
                request.setAttribute("error", "Mật khẩu phải dài tối thiểu 8 ký tự, bao gồm ít nhất 1 chữ hoa và 1 chữ thường.");
                request.getRequestDispatcher("/views/auth/reset-password.jsp").forward(request, response);
                return;
            }
            
            try {
                User u = userDAO.getByEmail(email);
                if (u != null) {
                    userDAO.updatePassword(u.getId(), newPassword);
                    session.removeAttribute("resetEmail");
                    session.removeAttribute("resetOtp");
                    session.removeAttribute("resetOtpVerified");
                    
                    request.getSession().setAttribute("successMsg", "Đặt lại mật khẩu thành công. Vui lòng đăng nhập.");
                    response.sendRedirect(request.getContextPath() + "/login");
                }
            } catch (Exception e) {
                e.printStackTrace();
                request.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
                request.getRequestDispatcher("/views/auth/reset-password.jsp").forward(request, response);
            }
            return;
        }

        // Default /forgot-password POST (send email)
        String email = request.getParameter("email");
        try {
            User existing = userDAO.getByEmail(email);
            if (existing == null) {
                request.setAttribute("error", "Email không tồn tại trong hệ thống.");
                request.getRequestDispatcher("/views/auth/forgot-password.jsp").forward(request, response);
                return;
            }

            String otp = String.format("%06d", new Random().nextInt(999999));
            session.setAttribute("resetEmail", email);
            session.setAttribute("resetOtp", otp);
            session.removeAttribute("resetOtpVerified"); // Reset verification status
            
            try {
                EmailUtil.sendOtpEmail(email, otp);
            } catch (Exception e) {
                e.printStackTrace();
            }
            
            response.sendRedirect(request.getContextPath() + "/forgot-password/verify");
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            request.getRequestDispatcher("/views/auth/forgot-password.jsp").forward(request, response);
        }
    }
}
