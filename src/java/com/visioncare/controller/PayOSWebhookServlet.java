package com.visioncare.controller;

import com.visioncare.dao.AppointmentDAO;
import com.visioncare.model.Appointment;
import com.visioncare.util.EmailUtil;
import com.visioncare.util.PayOSUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.IOException;

@WebServlet("/api/payos-webhook")
public class PayOSWebhookServlet extends HttpServlet {

    private final AppointmentDAO appointmentDAO = new AppointmentDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");

        StringBuilder sb = new StringBuilder();
        try (BufferedReader reader = request.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
        }
        String jsonBody = sb.toString();
        System.out.println("[PayOS Webhook] Received payload: " + jsonBody);

        try {
            String code = PayOSUtil.extractJsonField(jsonBody, "code");
            String orderCodeStr = PayOSUtil.extractJsonField(jsonBody, "orderCode");

            if (orderCodeStr != null && !orderCodeStr.isEmpty()) {
                long orderCode = Long.parseLong(orderCodeStr);
                if (orderCode >= 900000000000000L) {
                    String state = com.visioncare.util.StaffCheckoutPayments.refresh(orderCode, 0);
                    response.setStatus(HttpServletResponse.SC_OK);
                    response.getWriter().write("{\"success\":true,\"checkout\":true}");
                    return;
                }

                int appointmentId = (int) (orderCode > 1000000L ? (orderCode / 1000000L) : orderCode);

                // Cập nhật trạng thái thành Confirmed & Paid
                if (!appointmentDAO.confirmPayment(appointmentId)) {
                    System.err.println("[PayOS Webhook] Payment requires staff review; appointment cannot be confirmed: " + appointmentId);
                    response.setStatus(HttpServletResponse.SC_CONFLICT);
                    response.getWriter().write("{\"success\":false,\"message\":\"Appointment unavailable; payment requires staff review\"}");
                    return;
                }
                System.out.println("[PayOS Webhook] Successfully confirmed payment for Appointment #" + appointmentId + " (OrderCode: " + orderCode + ")");

                // Gửi email vé khám
                try {
                    Appointment fullAppt = appointmentDAO.getAppointmentDetailById(appointmentId);
                    if (fullAppt != null && fullAppt.getEmail() != null && !fullAppt.getEmail().isEmpty()) {
                        EmailUtil.sendAppointmentConfirmationEmail(
                                fullAppt.getEmail().trim(),
                                fullAppt.getPatientName(),
                                fullAppt.getId(),
                                fullAppt.getDoctorName() != null ? fullAppt.getDoctorName() : "Bác sĩ Chuyên khoa VisionCare",
                                fullAppt.getDepartment() != null ? fullAppt.getDepartment() : "Khám chuyên khoa mắt",
                                fullAppt.getAppointmentDate() != null ? fullAppt.getAppointmentDate().toString() : "",
                                fullAppt.getTimeSlot() != null ? fullAppt.getTimeSlot() : "",
                                fullAppt.getFee() > 0 ? fullAppt.getFee() : 200000
                        );
                    }
                } catch (Exception e) {
                    System.err.println("[PayOS Webhook] Lỗi gửi email: " + e.getMessage());
                }

                response.setStatus(HttpServletResponse.SC_OK);
                response.getWriter().write("{\"success\":true,\"message\":\"Payment confirmed\"}");
                return;
            }
        } catch (Exception e) {
            e.printStackTrace();
            System.err.println("[PayOS Webhook] Error processing webhook: " + e.getMessage());
        }

        response.setStatus(HttpServletResponse.SC_OK);
        response.getWriter().write("{\"success\":true}");
    }
}
