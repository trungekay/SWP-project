package com.visioncare.dao;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/** Staff collection requests for doctor-referred surgery. */
public class ProcedurePaymentDAO {
    public List<Map<String, Object>> listRequests() throws Exception {
        String sql = "SELECT po.Order_ID, mr.Appointment_ID, p.Full_Name AS Patient_Name, "
                + "s.Service_Name, po.Actual_Price, pr.Amount, pr.Credit_Amount, "
                + "pr.Status, pr.Created_At, pr.Confirmed_At, "
                + "pr.Payment_Method, e.Full_Name AS Confirmed_By "
                + "FROM Procedure_Payment_Request pr "
                + "JOIN Procedure_Order po ON po.Order_ID = pr.Order_ID "
                + "JOIN Service_Catalog s ON s.Service_ID = po.Service_ID "
                + "JOIN Medical_Record mr ON mr.Record_ID = po.Record_ID "
                + "JOIN Appointment a ON a.Appointment_ID = mr.Appointment_ID "
                + "JOIN Patient p ON p.Patient_ID = a.Patient_ID "
                + "LEFT JOIN Employee_Profile e ON e.Employee_ID = pr.Confirmed_By_Employee_ID "
                + "WHERE s.Service_Code LIKE 'PT-%' AND po.Status <> 'Cancelled' "
                + "ORDER BY CASE WHEN pr.Status = 'Pending' THEN 0 ELSE 1 END, pr.Created_At DESC";
        List<Map<String, Object>> rows = new ArrayList<>();
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("orderId", rs.getInt("Order_ID"));
                row.put("appointmentId", rs.getInt("Appointment_ID"));
                row.put("patientName", rs.getString("Patient_Name"));
                row.put("serviceName", rs.getString("Service_Name"));
                row.put("price", rs.getBigDecimal("Actual_Price"));
                row.put("amount", rs.getBigDecimal("Amount"));
                row.put("creditAmount", rs.getBigDecimal("Credit_Amount"));
                row.put("status", rs.getString("Status"));
                row.put("createdAt", rs.getTimestamp("Created_At"));
                row.put("confirmedAt", rs.getTimestamp("Confirmed_At"));
                row.put("paymentMethod", rs.getString("Payment_Method"));
                row.put("confirmedBy", rs.getString("Confirmed_By"));
                rows.add(row);
            }
        }
        return rows;
    }

    /** Record the receipt once and release the matching surgery order atomically. */
    public boolean confirm(int orderId, int staffEmployeeId, String method) throws Exception {
        try { method = com.visioncare.util.PaymentMethod.canonical(method); } catch (IllegalArgumentException error) { return false; }
        if (orderId <= 0 || staffEmployeeId <= 0
                || !("Cash".equals(method) || "QR_Banking".equals(method))) {
            return false;
        }
        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            conn.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE);
            try {
                // The doctor save path locks the order before its payment request.
                try (PreparedStatement ps = conn.prepareStatement(
                        "SELECT Order_ID FROM Procedure_Order WITH (UPDLOCK, HOLDLOCK) WHERE Order_ID = ?")) {
                    ps.setInt(1, orderId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            conn.rollback();
                            return false;
                        }
                    }
                }
                String lookup = "SELECT pr.Status, pr.Amount, pr.Credit_Amount, po.Actual_Price, i.Invoice_ID "
                        + "FROM Procedure_Payment_Request pr WITH (UPDLOCK, HOLDLOCK) "
                        + "JOIN Procedure_Order po ON po.Order_ID = pr.Order_ID "
                        + "JOIN Service_Catalog s ON s.Service_ID = po.Service_ID "
                        + "JOIN Medical_Record mr ON mr.Record_ID = po.Record_ID "
                        + "JOIN Appointment a ON a.Appointment_ID = mr.Appointment_ID AND a.Status <> 'Canceled' "
                        + "JOIN Master_Invoice i WITH (UPDLOCK, HOLDLOCK) ON i.Appointment_ID = mr.Appointment_ID "
                        + "WHERE pr.Order_ID = ? AND pr.Status = 'Pending' AND po.Status = 'Pending' "
                        + "AND s.Service_Code LIKE 'PT-%' AND po.Referral_Notes IS NOT NULL "
                        + "AND i.Status NOT IN ('Canceled', 'Refunded') "
                        + "AND NOT EXISTS (SELECT 1 FROM Invoice_Checkout co WHERE co.Invoice_ID=i.Invoice_ID AND co.Finalized_At IS NOT NULL)";
                int invoiceId;
                BigDecimal amount;
                try (PreparedStatement ps = conn.prepareStatement(lookup)) {
                    ps.setInt(1, orderId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            conn.rollback();
                            return false;
                        }
                        amount = rs.getBigDecimal("Amount");
                        BigDecimal credit = rs.getBigDecimal("Credit_Amount");
                        if (amount == null || amount.signum() < 0 || credit == null || credit.signum() < 0
                                || amount.add(credit).compareTo(rs.getBigDecimal("Actual_Price")) != 0) {
                            conn.rollback();
                            return false;
                        }
                        invoiceId = rs.getInt("Invoice_ID");
                    }
                }

                Integer transactionId = null;
                if (amount.signum() > 0) {
                    try (PreparedStatement ps = conn.prepareStatement(
                            "UPDATE Master_Invoice SET Total_Amount = Total_Amount + ?, "
                            + "Status = CASE WHEN Balance_Due = 0 THEN 'Paid' ELSE 'Partial_Paid' END, "
                            + "Close_At = CASE WHEN Balance_Due = 0 THEN SYSUTCDATETIME() ELSE NULL END "
                            + "WHERE Invoice_ID = ?")) {
                        ps.setBigDecimal(1, amount);
                        ps.setInt(2, invoiceId);
                        if (ps.executeUpdate() != 1) throw new IllegalStateException("Không cập nhật được hóa đơn.");
                    }

                    try (PreparedStatement ps = conn.prepareStatement(
                            "INSERT INTO Payment_Transaction (Invoice_ID, Amount, Gateway_Status, Payment_Gateway, Trans_Date) "
                            + "VALUES (?, ?, 'Success', ?, SYSUTCDATETIME())", Statement.RETURN_GENERATED_KEYS)) {
                        ps.setInt(1, invoiceId);
                        ps.setBigDecimal(2, amount);
                        ps.setString(3, method);
                        ps.executeUpdate();
                        try (ResultSet keys = ps.getGeneratedKeys()) {
                            if (!keys.next()) throw new IllegalStateException("Không ghi được giao dịch thanh toán.");
                            transactionId = keys.getInt(1);
                        }
                    }
                }

                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE Procedure_Payment_Request SET Status = 'Paid', "
                        + "Confirmed_At = SYSUTCDATETIME(), Confirmed_By_Employee_ID = ?, "
                        + "Payment_Method = ?, Transaction_ID = ? "
                        + "WHERE Order_ID = ? AND Status = 'Pending'")) {
                    ps.setInt(1, staffEmployeeId);
                    ps.setString(2, method);
                    if (transactionId == null) ps.setNull(3, java.sql.Types.INTEGER);
                    else ps.setInt(3, transactionId);
                    ps.setInt(4, orderId);
                    if (ps.executeUpdate() != 1) throw new IllegalStateException("Yêu cầu đã được xử lý.");
                }
                conn.commit();
                return true;
            } catch (Exception error) {
                conn.rollback();
                throw error;
            }
        }
    }
}
