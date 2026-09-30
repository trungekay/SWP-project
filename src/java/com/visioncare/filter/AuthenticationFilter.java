package com.visioncare.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Filter kiá»ƒm tra Ä‘Äƒng nháº­p cho cÃ¡c trang yÃªu cáº§u xÃ¡c thá»±c.
 * Hiá»‡n táº¡i Ã¡p dá»¥ng cho cÃ¡c URL pattern cáº§n login.
 */
@WebFilter(urlPatterns = {"/my-appointments", "/profile"})
public class AuthenticationFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // KhÃ´ng cáº§n khá»Ÿi táº¡o
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        HttpSession session = httpRequest.getSession(false);
        boolean loggedIn = (session != null && session.getAttribute("user") != null);

        if (loggedIn) {
            chain.doFilter(request, response);
        } else {
            // LÆ°u URL hiá»‡n táº¡i Ä‘á»ƒ redirect sau khi login
            String requestURI = httpRequest.getRequestURI();
            httpRequest.getSession().setAttribute("redirectAfterLogin", requestURI);
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/login");
        }
    }

    @Override
    public void destroy() {
        // KhÃ´ng cáº§n dá»n dáº¹p
    }
}
