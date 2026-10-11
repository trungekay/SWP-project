package com.visioncare.filter;

import com.visioncare.model.User;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebFilter(urlPatterns = {"/*"})
public class ForcePasswordChangeFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        HttpSession session = httpRequest.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        String path = httpRequest.getRequestURI();
        String contextPath = httpRequest.getContextPath();
        
        // Let css, js, images pass through
        if (path.contains("/assets/") || path.contains("/css/") || path.contains("/js/") || path.contains("/images/")) {
            chain.doFilter(request, response);
            return;
        }

        if (user != null && user.isFirstLogin()) {
            boolean isChangePasswordUrl = path.endsWith("/views/profile/change-password.jsp") 
                                       || path.endsWith("/profile/change-password")
                                       || path.endsWith("/logout");
            
            if (!isChangePasswordUrl) {
                // Redirect to change password page if they try to access anything else
                httpResponse.sendRedirect(contextPath + "/views/profile/change-password.jsp?force=true");
                return;
            }
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {}
}
