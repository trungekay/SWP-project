package com.visioncare.controller;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Servlet xử lý form liên hệ.
 * POST /contact → ghi nhận và hiển thị thông báo thành công.
 */
@WebServlet(name = "ContactServlet", urlPatterns = {"/contact"})
public class ContactServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String subject = request.getParameter("subject");
        String message = request.getParameter("message");

        // TODO: Lưu vào DB hoặc gửi email
        // Hiện tại chỉ ghi log và redirect thành công
        System.out.println("=== Contact Form ===");
        System.out.println("Name: " + name);
        System.out.println("Email: " + email);
        System.out.println("Subject: " + subject);
        System.out.println("Message: " + message);

        // Redirect về trang chủ với thông báo thành công
        request.getSession().setAttribute("contactSuccess", "Tin nhắn của bạn đã được gửi. Cảm ơn!");
        response.sendRedirect(request.getContextPath() + "/home#contact");
    }
}
