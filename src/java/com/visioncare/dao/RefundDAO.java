package com.visioncare.dao;

import java.sql.*;
import java.text.SimpleDateFormat;
import java.util.*;

public class RefundDAO {



    /**
     * Get all refund requests for staff/admin management
     */
    public List<Map<String, Object>> getAllRefundRequests(String statusFilter) {return requests(statusFilter,null);}
    public Map<String,Object> getRefundRequest(int id) {List<Map<String,Object>> rows=requests("all",id);return rows.isEmpty()?null:rows.get(0);}
    private List<Map<String, Object>> requests(String statusFilter,Integer refundIdFilter) {
        List<Map<String, Object>> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT r.Refund_ID, r.Invoice_ID, r.Refund_Amount, r.Reason, r.Status, r.Created_At, r.Update_At, r.Decision_Note,r.Notification_Status,r.Request_Kind,r.Notification_Attempts,r.Notification_Sent_At,r.Decision_At,patientAccount.Email AS Patient_Email,a.Status AS Appointment_Status,a.checkin_time, " +
            "p.Patient_ID, p.Full_Name AS Patient_Name, p.Phone AS Patient_Phone, " +
            "i.Appointment_ID, i.Total_Amount, i.Status AS Invoice_Status, " +
            "e1.Full_Name AS Creator_Name, e2.Full_Name AS Approver_Name " +
            "FROM Refund_Request r " +
            "JOIN Patient p ON r.Patient_ID = p.Patient_ID " +
            "LEFT JOIN Master_Invoice i ON r.Invoice_ID = i.Invoice_ID LEFT JOIN Appointment a ON a.Appointment_ID=i.Appointment_ID LEFT JOIN Account patientAccount ON patientAccount.Account_ID=p.Account_ID " +
            "LEFT JOIN Employee_Profile e1 ON r.created_by_employee_id = e1.Employee_ID " +
            "LEFT JOIN Employee_Profile e2 ON r.approved_by_employee_id = e2.Employee_ID "
        );

        if(refundIdFilter!=null)sql.append("WHERE r.Refund_ID=? ");
        else if (statusFilter != null && !statusFilter.isEmpty() && !"all".equalsIgnoreCase(statusFilter)) {
            sql.append("WHERE r.Status = ? ");
        }
        sql.append("ORDER BY r.Refund_ID DESC");

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            if(refundIdFilter!=null)ps.setInt(1,refundIdFilter);
            else if (statusFilter != null && !statusFilter.isEmpty() && !"all".equalsIgnoreCase(statusFilter)) {
                ps.setString(1, statusFilter);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> item = new HashMap<>();
                    int refundId = rs.getInt("Refund_ID");
                    int invoiceId = rs.getInt("Invoice_ID");
                    int appointmentId = rs.getInt("Appointment_ID");
                    long amount = rs.getLong("Refund_Amount");
                    String st = rs.getString("Status");
                    Timestamp createdAt = rs.getTimestamp("Created_At");
                    Timestamp updatedAt = rs.getTimestamp("Update_At");

                    item.put("id", refundId);
                    item.put("formattedId", String.format("#REF-%03d", refundId));
                    item.put("invoiceId", invoiceId);
                    item.put("formattedInvoiceId", String.format("#INV-%05d", invoiceId));
                    item.put("appointmentId", appointmentId);
                    item.put("formattedApptId", appointmentId > 0 ? ("#APT-" + appointmentId) : "N/A");
                    item.put("patientId", rs.getInt("Patient_ID"));
                    item.put("patientName", rs.getString("Patient_Name"));
                    item.put("patientPhone", rs.getString("Patient_Phone"));
                    item.put("patientEmail",rs.getString("Patient_Email"));
                    item.put("appointmentStatus",rs.getString("Appointment_Status"));
                    item.put("checkin",rs.getTimestamp("checkin_time"));
                    item.put("invoiceStatus",rs.getString("Invoice_Status"));
                    item.put("notificationAttempts",rs.getInt("Notification_Attempts"));
                    item.put("notificationSentAt",rs.getTimestamp("Notification_Sent_At"));
                    item.put("decisionAt",rs.getTimestamp("Decision_At"));
                    String mailStatus=rs.getString("Notification_Status");
                    item.put("notificationLabel",switch(mailStatus==null?"":mailStatus){case "Sent"->"Máy chủ email đã chấp nhận";case "Failed"->"Gửi thất bại";case "Pending"->"Chờ gửi tự động";case "Sending"->"Đang gửi";default->"Chưa có thông báo quyết định mới";});
                    item.put("amount", amount);
                    item.put("amountFmt", String.format("%,d đ", amount));
                    item.put("reason", rs.getString("Reason") != null ? rs.getString("Reason") : "Không có lý do");
                    item.put("kind",rs.getString("Request_Kind"));
                    item.put("lines",ItemRefundDAO.lines(conn,refundId));
                    item.put("decisionNote",rs.getString("Decision_Note"));
                    item.put("notificationStatus",rs.getString("Notification_Status"));
                    item.put("status", st);
                    item.put("statusVn", getStatusVn(st));
                    item.put("badgeClass", getBadgeClass(st));
                    item.put("createdAt", createdAt != null ? createdAt.toLocalDateTime().format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm")) : "");
                    item.put("updatedAt", updatedAt != null ? updatedAt.toLocalDateTime().format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm")) : "");
                    item.put("creatorName", rs.getString("Creator_Name") != null ? rs.getString("Creator_Name") : "Hệ thống");
                    item.put("approverName", rs.getString("Approver_Name") != null ? rs.getString("Approver_Name") : "Chưa duyệt");

                    list.add(item);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Summary stats for staff dashboard/refund management
     */
    public Map<String, Object> getRefundStats() {
        Map<String, Object> stats = new HashMap<>();
        int total = 0, pending = 0, approved = 0, rejected = 0, completed = 0;
        long totalApprovedAmount = 0;

        String sql = "SELECT Status, COUNT(*) AS Cnt, SUM(Refund_Amount) AS SumAmt FROM Refund_Request GROUP BY Status";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String st = rs.getString("Status");
                int cnt = rs.getInt("Cnt");
                long sum = rs.getLong("SumAmt");
                total += cnt;
                if ("Pending".equalsIgnoreCase(st)) {
                    pending = cnt;
                } else if ("Approved".equalsIgnoreCase(st)) {
                    approved = cnt;
                    totalApprovedAmount += sum;
                } else if ("Completed".equalsIgnoreCase(st)) {
                    completed=cnt;
                } else if ("Rejected".equalsIgnoreCase(st)) {
                    rejected = cnt;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        stats.put("completed",completed);
        stats.put("total", total);
        stats.put("pending", pending);
        stats.put("approved", approved);
        stats.put("rejected", rejected);
        stats.put("totalApprovedAmount", totalApprovedAmount);
        stats.put("totalApprovedAmountFmt", String.format("%,d đ", totalApprovedAmount));
        return stats;
    }

    /**
     * Director approves a refund request; staff payout is separate.
     * - Refund_Request -> Approved
     * - Master_Invoice changes only after actual staff payout.
     * - Only staff-approved pre-check-in cancellations are eligible; appointment stays canceled
     */
    public boolean approveRefund(int id,int employee) {
        try{return new RefundLifecycleDAO().decide(id,employee,true,null);}catch(Exception e){e.printStackTrace();return false;}
    }
    public boolean rejectRefund(int id,int employee,String note) {
        try{return new RefundLifecycleDAO().decide(id,employee,false,note);}catch(Exception e){e.printStackTrace();return false;}
    }

    public boolean createRefundByStaff(int invoiceId, int employeeId, int patientId, long amount, String reason, String initialStatus) {
        String status = "Pending";
        String sql = "INSERT INTO Refund_Request (Invoice_ID, created_by_employee_id, approved_by_employee_id, Patient_ID, Refund_Amount, Reason, Status, Created_At, Update_At) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, SYSUTCDATETIME(), SYSUTCDATETIME())";
        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try {
                String eligibleSql = "SELECT a.Appointment_ID, a.Patient_ID, "
                    + "CASE WHEN i.Status = 'Partial_Paid' THEN i.Deposit_Amount ELSE i.Total_Amount END AS Paid_Amount "
                    + "FROM Master_Invoice i WITH (UPDLOCK, HOLDLOCK) "
                    + "JOIN Appointment a WITH (UPDLOCK, HOLDLOCK) ON a.Appointment_ID = i.Appointment_ID "
                    + "WHERE i.Invoice_ID = ? AND " + RefundPolicy.ELIGIBLE + " AND " + RefundPolicy.NO_ACTIVE_REQUEST;
                try (PreparedStatement check = conn.prepareStatement(eligibleSql)) {
                    check.setInt(1, invoiceId);
                    try (ResultSet rs = check.executeQuery()) {
                        if (!rs.next() || rs.getInt("Patient_ID") != patientId || amount <= 0
                                || amount > rs.getLong("Paid_Amount") || reason == null || reason.trim().isEmpty()) {
                            conn.rollback();
                            return false;
                        }
                    }
                }
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, invoiceId);
                    ps.setInt(2, employeeId);
                    ps.setNull(3, Types.INTEGER);
                    ps.setInt(4, patientId);
                    ps.setLong(5, amount);
                    ps.setString(6, reason);
                    ps.setString(7, status);
                    ps.executeUpdate();
                }

                conn.commit();
                return true;
            } catch (Exception e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    private boolean isEligibleForApproval(Connection conn, int invoiceId, int refundId) throws SQLException {
        String sql = "SELECT 1 FROM Master_Invoice i WITH (UPDLOCK, HOLDLOCK) "
            + "JOIN Appointment a ON a.Appointment_ID = i.Appointment_ID WHERE i.Invoice_ID = ? AND "
            + RefundPolicy.ELIGIBLE + " AND EXISTS (SELECT 1 FROM Refund_Request r WHERE r.Refund_ID = ? "
            + "AND r.Invoice_ID = i.Invoice_ID AND r.Patient_ID = a.Patient_ID AND r.Refund_Amount > 0 "
            + "AND r.Refund_Amount <= CASE WHEN i.Status = 'Partial_Paid' THEN i.Deposit_Amount ELSE i.Total_Amount END)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, invoiceId);
            ps.setInt(2, refundId);
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        }
    }

    public boolean createRefundByPatient(int invoiceId, int accountId, long amount, String reason) {
        String sql = "SELECT a.Patient_ID, (SELECT TOP 1 Employee_ID FROM Employee_Profile ORDER BY Employee_ID) AS Employee_ID "
            + "FROM Master_Invoice i JOIN Appointment a ON a.Appointment_ID = i.Appointment_ID "
            + "JOIN Patient p ON p.Patient_ID = a.Patient_ID WHERE i.Invoice_ID = ? AND p.Account_ID = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, invoiceId);
            ps.setInt(2, accountId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return false;
                return createRefundByStaff(invoiceId, rs.getInt("Employee_ID"), rs.getInt("Patient_ID"), amount, reason, "Pending");
            }
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    /**
     * Get list of invoices eligible for staff to pick when creating a refund request
     */
    public List<Map<String, Object>> getInvoicesForStaffRefundSelection() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT i.Invoice_ID, i.Appointment_ID, i.Total_Amount, i.Deposit_Amount, i.Status, " +
                     "p.Patient_ID, p.Full_Name AS Patient_Name, p.Phone AS Patient_Phone " +
                     "FROM Master_Invoice i " +
                     "JOIN Appointment a ON i.Appointment_ID = a.Appointment_ID " +
                     "JOIN Patient p ON a.Patient_ID = p.Patient_ID " +
                     "WHERE " + RefundPolicy.ELIGIBLE + " AND " + RefundPolicy.NO_ACTIVE_REQUEST + " ORDER BY i.Invoice_ID DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                int invId = rs.getInt("Invoice_ID");
                int aptId = rs.getInt("Appointment_ID");
                long total = rs.getLong("Total_Amount");
                long dep = rs.getLong("Deposit_Amount");
                long refundable = "Partial_Paid".equalsIgnoreCase(rs.getString("Status")) ? dep : total;

                map.put("invoiceId", invId);
                map.put("formattedInvoiceId", String.format("#INV-%05d", invId));
                map.put("appointmentId", aptId);
                map.put("patientId", rs.getInt("Patient_ID"));
                map.put("patientName", rs.getString("Patient_Name"));
                map.put("patientPhone", rs.getString("Patient_Phone"));
                map.put("refundableAmount", refundable);
                map.put("label", String.format("#INV-%05d (Hẹn #APT-%d) - %s (%s) - %s đ", 
                    invId, aptId, rs.getString("Patient_Name"), rs.getString("Patient_Phone"), String.format("%,d", refundable)));
                list.add(map);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /** Existing requests are visible to reception without permitting a duplicate refund. */
    public Map<Integer, Map<String, Object>> getActiveRefundsForStaffAppointments() {
        Map<Integer, Map<String, Object>> results = new HashMap<>();
        String sql = "SELECT i.Appointment_ID, i.Invoice_ID, r.Refund_ID, r.Status, r.Refund_Amount, r.Reason "
                + "FROM Refund_Request r JOIN Master_Invoice i ON i.Invoice_ID = r.Invoice_ID "
                + "JOIN Appointment a ON a.Appointment_ID = i.Appointment_ID "
                + "WHERE r.Status IN ('Pending', 'Approved', 'Rejected', 'Completed') ORDER BY r.Refund_ID DESC";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                int appointmentId = rs.getInt("Appointment_ID");
                if (results.containsKey(appointmentId)) continue;
                Map<String, Object> refund = new HashMap<>();
                refund.put("id", rs.getInt("Refund_ID"));
                refund.put("code", String.format("#REF-%03d", rs.getInt("Refund_ID")));
                refund.put("invoiceId",rs.getInt("Invoice_ID"));
                refund.put("invoiceCode", String.format("#INV-%05d", rs.getInt("Invoice_ID")));
                refund.put("status", rs.getString("Status"));
                refund.put("statusLabel", getStatusVn(rs.getString("Status")));
                refund.put("amount", rs.getLong("Refund_Amount"));
                refund.put("amountLabel", String.format("%,d đ", rs.getLong("Refund_Amount")));
                refund.put("reason", rs.getString("Reason"));
                results.put(appointmentId, refund);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return results;
    }

    private String getStatusVn(String st) {
        if ("Pending".equalsIgnoreCase(st)) return "Chờ duyệt";
        if ("Approved".equalsIgnoreCase(st)) return "Đã duyệt · Chờ staff hoàn tiền";
        if ("Completed".equalsIgnoreCase(st)) return "Đã hoàn tiền";
        if ("Rejected".equalsIgnoreCase(st)) return "Từ chối";
        return st != null ? st : "";
    }

    private String getBadgeClass(String st) {
        if ("Pending".equalsIgnoreCase(st)) return "bg-warning text-dark";
        if ("Approved".equalsIgnoreCase(st)) return "bg-success text-white";
        if ("Rejected".equalsIgnoreCase(st)) return "bg-danger text-white";
        return "bg-secondary text-white";
    }
}
