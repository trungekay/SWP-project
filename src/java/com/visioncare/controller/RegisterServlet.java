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

@WebServlet(name = "RegisterServlet", urlPatterns = {"/register", "/verify-otp"})
public class RegisterServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        if ("/verify-otp".equals(path)) {
            request.getRequestDispatcher("/views/auth/verify-otp.jsp").forward(request, response);
            return;
        }
        
        request.getRequestDispatcher("/views/auth/register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        HttpSession session = request.getSession();

        if ("/verify-otp".equals(path)) {
            // Validate OTP
            String otp1 = request.getParameter("otp1");
            String otp2 = request.getParameter("otp2");
            String otp3 = request.getParameter("otp3");
            String otp4 = request.getParameter("otp4");
            String otp5 = request.getParameter("otp5");
            String otp6 = request.getParameter("otp6");
            
            String enteredOtp = (otp1 != null ? otp1 : "") + (otp2 != null ? otp2 : "") 
                              + (otp3 != null ? otp3 : "") + (otp4 != null ? otp4 : "") 
                              + (otp5 != null ? otp5 : "") + (otp6 != null ? otp6 : "");
                              
            String sessionOtp = (String) session.getAttribute("registerOtp");
            User pendingUser = (User) session.getAttribute("pendingUser");
            
            if (sessionOtp != null && sessionOtp.equals(enteredOtp) && pendingUser != null) {
                // Register user
                try {
                    // Temporarily catching Exception, userDAO might throw SQLException
                    userDAO.register(pendingUser);
                    session.removeAttribute("registerOtp");
                    session.removeAttribute("pendingUser");
                    
                    // Auto login after verify
                    session.setAttribute("user", pendingUser);
                    response.sendRedirect(request.getContextPath() + "/home");
                    
                } catch (Exception e) {
                    e.printStackTrace();
                    request.setAttribute("error", "Không thể đăng ký: " + e.getMessage());
                    request.getRequestDispatcher("/views/auth/verify-otp.jsp").forward(request, response);
                }
            } else {
                request.setAttribute("error", "Mã OTP không đúng hoặc đã hết hạn.");
                request.getRequestDispatcher("/views/auth/verify-otp.jsp").forward(request, response);
            }
            return;
        }

        // Registration form submitted
        String fullName = request.getParameter("fullName");
        String phone = request.getParameter("phone");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        if (password == null || !password.equals(confirmPassword)) {
            request.setAttribute("error", "Mật khẩu xác nhận không khớp.");
            request.getRequestDispatcher("/views/auth/register.jsp").forward(request, response);
            return;
        }

        try {
            // Check if user exists (UserDAO might not have email checking in all schemas, but we try)
            User existing = userDAO.getByEmail(email);
            if (existing != null) {
                request.setAttribute("error", "Email đã tồn tại trong hệ thống.");
                request.getRequestDispatcher("/views/auth/register.jsp").forward(request, response);
                return;
            }

            // Generate 6-digit OTP
            String otp = String.format("%06d", new Random().nextInt(999999));
            
            // Create user object but don't save yet
            User user = new User();
            user.setFullName(fullName);
            user.setPhone(phone);
            user.setEmail(email);
            user.setPassword(password);
            user.setRole("patient");
            
            // Store in session
            session.setAttribute("pendingUser", user);
            session.setAttribute("registerOtp", otp);
            
            // Send email
            try {
                EmailUtil.sendOtpEmail(email, otp);
            } catch (Exception e) {
                System.out.println("Could not send email, check credentials: " + e.getMessage());
                // In development, we can still proceed and check console for OTP
            }
            
            // Redirect to OTP verification page
            response.sendRedirect(request.getContextPath() + "/verify-otp");
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            request.getRequestDispatcher("/views/auth/register.jsp").forward(request, response);
        }
    }
}
