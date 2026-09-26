package com.visioncare.filter;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Filter kiểm tra đăng nhập cho các trang yêu cầu xác thực.
 * Hiện tại áp dụng cho các URL pattern cần login.
 */
@WebFilter(urlPatterns = {"/my-appointments", "/profile"})
public class AuthenticationFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Không cần khởi tạo
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
            // Lưu URL hiện tại để redirect sau khi login
            String requestURI = httpRequest.getRequestURI();
            httpRequest.getSession().setAttribute("redirectAfterLogin", requestURI);
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/login");
        }
    }

    @Override
    public void destroy() {
        // Không cần dọn dẹp
    }
}
