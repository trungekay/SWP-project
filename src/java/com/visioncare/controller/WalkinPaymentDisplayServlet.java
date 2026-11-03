package com.visioncare.controller;

import com.visioncare.dao.AppointmentDAO;
import com.visioncare.model.Appointment;
import com.visioncare.util.WalkinPaymentDisplay;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/payment/walkin")
public class WalkinPaymentDisplayServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        response.setHeader("Cache-Control", "no-store");
        WalkinPaymentDisplay.Grant grant = WalkinPaymentDisplay.get(request.getParameter("token"));
        if (grant == null) { response.setStatus(410); response.getWriter().write("{\"state\":\"expired\"}"); return; }
        try {
            AppointmentDAO dao = new AppointmentDAO();
            Appointment appointment = dao.getAppointmentDetailById(grant.appointmentId);
            if (appointment != null && appointment.isDepositPaid()) {
                response.getWriter().write("{\"state\":\"paid\"}"); return;
            }
            String gateway = grant.orderCode > 0 ? com.visioncare.util.PayOSUtil.getPaymentStatus(grant.orderCode) : "UNKNOWN";
            if ("PAID".equalsIgnoreCase(gateway)) {
                boolean confirmed = dao.confirmPayment(grant.appointmentId);
                response.getWriter().write("{\"state\":\"" + (confirmed ? "paid" : "error") + "\"}"); return;
            }
            boolean cancelled = dao.abortWalkinAppointment(grant.appointmentId);
            response.getWriter().write("{\"state\":\"" + (cancelled ? "cancelled" : "error") + "\"}");
        } catch (Exception e) { log("Cannot cancel walk-in hold", e); response.setStatus(503); response.getWriter().write("{\"state\":\"error\"}"); }
    }
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setHeader("Cache-Control", "no-store");
        response.setHeader("Referrer-Policy", "no-referrer");
        response.setHeader("X-Frame-Options", "DENY");
        response.setHeader("X-Content-Type-Options", "nosniff");
        WalkinPaymentDisplay.Grant grant = WalkinPaymentDisplay.get(request.getParameter("token"));
        boolean polling = "status".equals(request.getParameter("action"));
        if (polling) response.setContentType("application/json;charset=UTF-8");
        if (grant == null) {
            response.setStatus(HttpServletResponse.SC_GONE);
            if (polling) response.getWriter().write("{\"state\":\"expired\"}");
            else {
                response.setContentType("text/html;charset=UTF-8");
                response.getWriter().write("<meta charset='UTF-8'><p>Liên kết đã hết hạn. Vui lòng liên hệ lễ tân.</p>");
            }
            return;
        }
        try {
            Appointment appointment = new AppointmentDAO().getAppointmentDetailById(grant.appointmentId);
            if (polling && appointment != null && !appointment.isDepositPaid()
                    && "Pending".equalsIgnoreCase(appointment.getStatus()) && grant.orderCode > 0
                    && "PAID".equalsIgnoreCase(com.visioncare.util.PayOSUtil.getPaymentStatus(grant.orderCode))) {
                new AppointmentDAO().confirmPayment(grant.appointmentId);
                appointment = new AppointmentDAO().getAppointmentDetailById(grant.appointmentId);
            }
            String state = appointment == null || "Canceled".equalsIgnoreCase(appointment.getStatus())
                    || "Cancelled".equalsIgnoreCase(appointment.getStatus()) ? "cancelled"
                    : appointment.isDepositPaid() ? "paid" : "pending";
            if (polling) {
                response.getWriter().write("{\"state\":\"" + state + "\",\"expiresAt\":" + grant.getExpiresAt()
                        + ",\"holdSeconds\":" + grant.getHoldSeconds() + "}");
                return;
            }
            request.setAttribute("display", grant);
            request.setAttribute("appointment", appointment);
            request.setAttribute("paymentState", state);
            request.getRequestDispatcher("/WEB-INF/views/walkin-payment.jsp").forward(request, response);
        } catch (Exception e) {
            log("Cannot read walk-in payment display", e);
            response.setStatus(HttpServletResponse.SC_SERVICE_UNAVAILABLE);
            if (polling) response.getWriter().write("{\"state\":\"error\"}");
            else response.getWriter().write("Payment information temporarily unavailable.");
        }
    }
}
