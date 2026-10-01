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

/**
 * Servlet xá»­ lÃ½ ÄÄƒng nháº­p / ÄÄƒng xuáº¥t.
 * GET  /login  â†’ hiá»ƒn thá»‹ form Ä‘Äƒng nháº­p
 * POST /login  â†’ xá»­ lÃ½ Ä‘Äƒng nháº­p
 * GET  /logout â†’ Ä‘Äƒng xuáº¥t
 */
@WebServlet(name = "LoginServlet", urlPatterns = {"/login", "/logout"})
public class LoginServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        if ("/logout".equals(path)) {
            // ÄÄƒng xuáº¥t: há»§y session vÃ  redirect vá» trang chá»§
            HttpSession session = request.getSession(false);
            if (session != null) {
                session.invalidate();
            }
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        // Hiá»ƒn thá»‹ form Ä‘Äƒng nháº­p
        request.getRequestDispatcher("/views/auth/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        try {
            User user = userDAO.login(email, password);

            if (user != null) {
                // ÄÄƒng nháº­p thÃ nh cÃ´ng
                HttpSession session = request.getSession();
                session.setAttribute("user", user);
                session.setMaxInactiveInterval(30 * 60); // 30 phÃºt

                // Redirect tá»›i trang trÆ°á»›c Ä‘Ã³ (náº¿u cÃ³) hoáº·c trang chá»§
                String redirect = (String) session.getAttribute("redirectAfterLogin");
                if (redirect != null) {
                    session.removeAttribute("redirectAfterLogin");
                    response.sendRedirect(redirect);
                } else {
                    response.sendRedirect(request.getContextPath() + "/home");
                }
            } else {
                // ÄÄƒng nháº­p tháº¥t báº¡i
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
