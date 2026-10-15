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

@WebServlet(name = "ResendOtpServlet", urlPatterns = {"/resend-otp"})
public class ResendOtpServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processResend(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processResend(request, response);
    }

    private void processResend(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        String type = request.getParameter("type");

        User pendingUser = (User) session.getAttribute("pendingUser");
        String resetEmail = (String) session.getAttribute("resetEmail");

        // 1. Forgot Password Flow
        if ("reset".equalsIgnoreCase(type) || (pendingUser == null && resetEmail != null)) {
            if (resetEmail == null) {
                session.setAttribute("error", "Phiên làm việc đã hết hạn. Vui lòng nhập lại email.");
                response.sendRedirect(request.getContextPath() + "/forgot-password");
                return;
            }
            try {
                User u = userDAO.getByEmail(resetEmail);
                if (u == null) {
                    session.removeAttribute("resetEmail");
                    session.removeAttribute("resetOtp");
                    session.setAttribute("error", "Email không tồn tại trong hệ thống.");
                    response.sendRedirect(request.getContextPath() + "/forgot-password");
                    return;
                }

                String newOtp = String.format("%06d", new Random().nextInt(999999));
                session.setAttribute("resetOtp", newOtp);
                session.removeAttribute("resetOtpVerified");

                try {
                    EmailUtil.sendOtpEmail(resetEmail, newOtp);
                } catch (Exception e) {
                    System.out.println("Could not send email, check credentials: " + e.getMessage());
                }

                session.setAttribute("successMessage", "Mã OTP mới đã được gửi đến email của bạn.");
                response.sendRedirect(request.getContextPath() + "/forgot-password/verify");
            } catch (Exception e) {
                e.printStackTrace();
                session.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
                response.sendRedirect(request.getContextPath() + "/forgot-password/verify");
            }
            return;
        }

        // 2. Registration Flow
        if (pendingUser == null) {
            session.setAttribute("error", "Phiên đăng ký đã hết hạn. Vui lòng đăng ký lại.");
            response.sendRedirect(request.getContextPath() + "/register");
            return;
        }

        try {
            // Check if email or phone already registered
            User existingEmail = userDAO.getByEmail(pendingUser.getEmail());
            if (existingEmail != null) {
                session.removeAttribute("pendingUser");
                session.removeAttribute("registerOtp");
                session.setAttribute("error", "Email đã tồn tại trong hệ thống. Vui lòng đăng ký bằng email khác.");
                response.sendRedirect(request.getContextPath() + "/register");
                return;
            }

            User existingPhone = userDAO.getByPhone(pendingUser.getPhone());
            if (existingPhone != null) {
                session.removeAttribute("pendingUser");
                session.removeAttribute("registerOtp");
                session.setAttribute("error", "Số điện thoại đã tồn tại trong hệ thống. Vui lòng đăng ký lại.");
                response.sendRedirect(request.getContextPath() + "/register");
                return;
            }

            String newOtp = String.format("%06d", new Random().nextInt(999999));
            session.setAttribute("registerOtp", newOtp);

            try {
                EmailUtil.sendOtpEmail(pendingUser.getEmail(), newOtp);
            } catch (Exception e) {
                System.out.println("Could not send email, check credentials: " + e.getMessage());
            }

            session.setAttribute("successMessage", "Mã OTP mới đã được gửi đến email của bạn.");
            response.sendRedirect(request.getContextPath() + "/verify-otp");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/verify-otp");
        }
    }
}
