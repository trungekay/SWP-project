package com.visioncare.util;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/** JSON contract for the automatic invoice QR monitor, including authentication failures. */
public final class InvoicePollingResponse {
    private InvoicePollingResponse() {}
    public static boolean isRequested(HttpServletRequest request) {
        String accept = request.getHeader("Accept");
        return (request.getContextPath() + "/staff/invoices/checkout").equals(request.getRequestURI())
                && accept != null && accept.contains("application/json");
    }
    public static void send(HttpServletResponse response, int code, String status, String message) throws IOException {
        response.setStatus(code);
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");
        response.setHeader("Cache-Control", "no-store");
        response.getWriter().write("{\"status\":\"" + escape(status) + "\",\"message\":\"" + escape(message) + "\"}");
    }
    private static String escape(String value) {
        return value == null ? "" : value.replace("\\", "\\\\").replace("\"", "\\\"")
                .replace("\r", "\\r").replace("\n", "\\n");
    }
}
