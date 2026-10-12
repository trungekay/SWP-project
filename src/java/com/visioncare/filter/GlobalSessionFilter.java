package com.visioncare.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebFilter(filterName = "GlobalSessionFilter", urlPatterns = {"/*"})
public class GlobalSessionFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        String uri = httpRequest.getRequestURI();
        
        // Skip static assets
        if (uri.contains("/assets/") || uri.endsWith(".css") || uri.endsWith(".js") || uri.endsWith(".png") || uri.endsWith(".jpg")) {
            chain.doFilter(request, response);
            return;
        }

        HttpSession session = httpRequest.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            com.visioncare.model.User sessionUser = (com.visioncare.model.User) session.getAttribute("user");
            try {
                com.visioncare.dao.UserDAO userDAO = new com.visioncare.dao.UserDAO();
                com.visioncare.model.User dbUser = userDAO.getUserById(sessionUser.getId());
                
                if (dbUser == null || "Inactive".equalsIgnoreCase(dbUser.getStatus()) || "Deleted".equalsIgnoreCase(dbUser.getStatus())) {
                    session.invalidate();
                    HttpServletResponse httpResponse = (HttpServletResponse) response;
                    httpResponse.sendRedirect(httpRequest.getContextPath() + "/login?error=locked");
                    return;
                } else {
                    session.setAttribute("user", dbUser);
                }
            } catch (Exception e) {
                // Ignore DB errors in global filter to prevent crashing the site
            }
        }
        
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {}
}
