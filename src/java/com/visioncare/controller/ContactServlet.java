package com.visioncare.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Servlet xá»­ lÃ½ form liÃªn há»‡.
 * POST /contact â†’ ghi nháº­n vÃ  hiá»ƒn thá»‹ thÃ´ng bÃ¡o thÃ nh cÃ´ng.
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

        // TODO: LÆ°u vÃ o DB hoáº·c gá»­i email
        // Hiá»‡n táº¡i chá»‰ ghi log vÃ  redirect thÃ nh cÃ´ng
        System.out.println("=== Contact Form ===");
        System.out.println("Name: " + name);
        System.out.println("Email: " + email);
        System.out.println("Subject: " + subject);
        System.out.println("Message: " + message);

        // Redirect vá» trang chá»§ vá»›i thÃ´ng bÃ¡o thÃ nh cÃ´ng
        request.getSession().setAttribute("contactSuccess", "Tin nháº¯n cá»§a báº¡n Ä‘Ã£ Ä‘Æ°á»£c gá»­i. Cáº£m Æ¡n!");
        response.sendRedirect(request.getContextPath() + "/home#contact");
    }
}
