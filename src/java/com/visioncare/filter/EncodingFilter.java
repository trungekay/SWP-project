package com.visioncare.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import java.io.IOException;

/**
 * Filter Ä‘áº·t encoding UTF-8 cho má»i request/response.
 * Äáº£m báº£o tiáº¿ng Viá»‡t hiá»ƒn thá»‹ Ä‘Ãºng.
 */
@WebFilter("/*")
public class EncodingFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // KhÃ´ng cáº§n khá»Ÿi táº¡o gÃ¬
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        // KhÃ´ng cáº§n dá»n dáº¹p gÃ¬
    }
}
