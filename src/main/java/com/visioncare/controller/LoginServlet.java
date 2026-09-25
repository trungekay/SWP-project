package com.visioncare.controller;

import com.visioncare.dao.UserDAO;
import com.visioncare.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Servlet xử lý Đăng nhập / Đăng xuất.
 * GET  /login  → hiển thị form đăng nhập
 * POST /login  → xử lý đăng nhập
 * GET  /logout → đăng xuất
 */
@WebServlet(name = "LoginServlet", urlPatterns = {"/login", "/logout"})
public class LoginServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        if ("/logout".equals(path)) {
            // Đăng xuất: hủy session và redirect về trang chủ
            HttpSession session = request.getSession(false);
            if (session != null) {
                session.invalidate();
            }
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        // Hiển thị form đăng nhập
        request.getRequestDispatcher("/views/auth/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        try {
            // Mock đăng nhập không cần DB
            /*
            User user = userDAO.login(email, password);
            */
            User user = new User();
            user.setId(1);
            user.setFullName("Admin Mock");
            user.setEmail(email);
            user.setRole("admin");

            if (user != null) {
                // Đăng nhập thành công
                HttpSession session = request.getSession();
                session.setAttribute("user", user);
                session.setMaxInactiveInterval(30 * 60); // 30 phút

                // Redirect tới trang trước đó (nếu có) hoặc trang chủ
                String redirect = (String) session.getAttribute("redirectAfterLogin");
                if (redirect != null) {
                    session.removeAttribute("redirectAfterLogin");
                    response.sendRedirect(redirect);
                } else {
                    response.sendRedirect(request.getContextPath() + "/home");
                }
            } else {
                // Đăng nhập thất bại
                request.setAttribute("error", "Email hoặc mật khẩu không đúng.");
                request.setAttribute("email", email);
                request.getRequestDispatcher("/views/auth/login.jsp").forward(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            request.getRequestDispatcher("/views/auth/login.jsp").forward(request, response);
        }
    }
}
