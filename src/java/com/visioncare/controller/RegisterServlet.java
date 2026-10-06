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
                try {
                    userDAO.register(pendingUser);
                    session.removeAttribute("registerOtp");
                    session.removeAttribute("pendingUser");
                    
                    User fullUser = userDAO.getByEmail(pendingUser.getEmail());
                    fullUser.setRole("patient");
                    session.setAttribute("user", fullUser);
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
        String fullName = request.getParameter("fullName");
        String phone = request.getParameter("phone");
        if (phone != null) {
            phone = phone.trim().replaceAll("\\s+", "");
            if (!phone.matches("\\d{10}")) {
                request.setAttribute("error", "Số điện thoại không hợp lệ. Phải bao gồm đúng 10 chữ số.");
                request.getRequestDispatcher("/views/auth/register.jsp").forward(request, response);
                return;
            }
        }
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        if (password == null || !password.equals(confirmPassword)) {
            request.setAttribute("error", "Mật khẩu xác nhận không khớp.");
            request.getRequestDispatcher("/views/auth/register.jsp").forward(request, response);
            return;
        }
        
        if (password.length() < 8 || !password.matches(".*[A-Z].*") || !password.matches(".*[a-z].*")) {
            request.setAttribute("error", "Mật khẩu phải dài tối thiểu 8 ký tự, bao gồm ít nhất 1 chữ hoa và 1 chữ thường.");
            request.getRequestDispatcher("/views/auth/register.jsp").forward(request, response);
            return;
        }
        
        try {
            User existingEmail = userDAO.getByEmail(email);
            if (existingEmail != null) {
                request.setAttribute("error", "Email đã tồn tại trong hệ thống.");
                request.getRequestDispatcher("/views/auth/register.jsp").forward(request, response);
                return;
            }
            
            User existingPhone = userDAO.getByPhone(phone);
            if (existingPhone != null) {
                request.setAttribute("error", "Số điện thoại đã tồn tại trong hệ thống.");
                request.getRequestDispatcher("/views/auth/register.jsp").forward(request, response);
                return;
            }

            String otp = String.format("%06d", new Random().nextInt(999999));
            
            User user = new User();
            user.setFullName(fullName);
            user.setPhone(phone);

            user.setEmail(email);
            user.setPassword(password);
            user.setRole("patient");
            
            session.setAttribute("pendingUser", user);
            session.setAttribute("registerOtp", otp);
            
            try {
                EmailUtil.sendOtpEmail(email, otp);
            } catch (Exception e) {
                System.out.println("Could not send email, check credentials: " + e.getMessage());
            }
            
            response.sendRedirect(request.getContextPath() + "/verify-otp");
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            request.getRequestDispatcher("/views/auth/register.jsp").forward(request, response);
        }
    }
}
