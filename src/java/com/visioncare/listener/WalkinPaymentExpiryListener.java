package com.visioncare.listener;

import com.visioncare.dao.AppointmentDAO;
import com.visioncare.dao.DBContext;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebListener;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.*;

/** Releases unpaid walk-in holds even when the payment tab has been closed. */
@WebListener
public class WalkinPaymentExpiryListener implements ServletContextListener {
    private ScheduledExecutorService worker;
    @Override public void contextInitialized(ServletContextEvent event) {
        worker = Executors.newSingleThreadScheduledExecutor(r -> {
            Thread t = new Thread(r, "walkin-payment-expiry"); t.setDaemon(true); return t;
        });
        worker.scheduleWithFixedDelay(() -> {
            try {
                List<Integer> ids = new ArrayList<>();
                try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(
                        "SELECT a.Appointment_ID FROM Appointment a JOIN Master_Invoice mi ON mi.Appointment_ID=a.Appointment_ID "
                        + "WHERE a.Status='Pending' AND a.Staff_Employee_ID IS NOT NULL "
                        + "AND mi.Status IN ('Pending_Deposit','Unpaid') "
                        + "AND a.created_at <= DATEADD(MINUTE,-?,DATEADD(HOUR,7,SYSUTCDATETIME()))")) {
                    ps.setInt(1, com.visioncare.dao.TimeSlotDAO.getPendingHoldMinutes());
                    try (ResultSet rs = ps.executeQuery()) { while (rs.next()) ids.add(rs.getInt(1)); }
                }
                for (int id : ids) {
                    try {
                        long orderCode = com.visioncare.util.WalkinPaymentDisplay.orderCodeFor(id);
                        String state = orderCode > 0 ? com.visioncare.util.PayOSUtil.getPaymentStatus(orderCode) : "UNKNOWN";
                        if ("PAID".equalsIgnoreCase(state)) new AppointmentDAO().confirmPayment(id);
                        else if (orderCode == 0 || "PENDING".equalsIgnoreCase(state) || "CANCELLED".equalsIgnoreCase(state) || "EXPIRED".equalsIgnoreCase(state))
                            new AppointmentDAO().abortWalkinAppointment(id);
                    }
                    catch (Exception e) { event.getServletContext().log("Cannot release walk-in hold " + id, e); }
                }
            } catch (Exception e) { event.getServletContext().log("Walk-in expiry will retry", e); }
        }, 15, 15, TimeUnit.SECONDS);
    }
    @Override public void contextDestroyed(ServletContextEvent event) {
        if (worker != null) worker.shutdownNow();
    }
}
