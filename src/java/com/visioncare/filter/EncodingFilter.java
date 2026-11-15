package com.visioncare.filter;
import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.annotation.WebFilter;
import java.io.IOException;
@WebFilter("/*")
public class EncodingFilter implements Filter {
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        request.setCharacterEncoding("UTF-8");
        // Let Tomcat stream static assets as their original bytes. Setting a
        // response encoding here makes its default servlet recode UTF-8 files.
        if (!(request instanceof HttpServletRequest httpRequest)
                || !httpRequest.getServletPath().startsWith("/assets/")) {
            response.setCharacterEncoding("UTF-8");
        }
        chain.doFilter(request, response);
    }
    @Override
    public void destroy() {
    }
}
