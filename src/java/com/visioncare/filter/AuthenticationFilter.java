package com.visioncare.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebFilter(urlPatterns = {"/my-appointments", "/profile/*", "/views/profile/*", "/book-appointment", "/admin/*", "/employee/*"})
public class AuthenticationFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        HttpSession session = httpRequest.getSession(false);
        boolean loggedIn = (session != null && session.getAttribute("user") != null);

        if (loggedIn) {
                // Ghost User check is now handled by GlobalSessionFilter globally
                
                // 2. Fix Authorization Bypass for Admin
                String uri = httpRequest.getRequestURI();
                if (uri.startsWith(httpRequest.getContextPath() + "/admin/")) {
                    com.visioncare.model.User sessionUser = (com.visioncare.model.User) session.getAttribute("user");
                    if (sessionUser.getRoleId() != 1 && sessionUser.getRoleId() != 2) {
                        httpResponse.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập trang này.");
                        return;
                    }
                }
                
                chain.doFilter(request, response);
        } else {
            String requestURI = httpRequest.getRequestURI();
            httpRequest.getSession().setAttribute("redirectAfterLogin", requestURI);
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/login");
        }
    }

    @Override
    public void destroy() {
       
    }
}
