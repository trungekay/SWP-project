package com.visioncare.dao;

import java.sql.*;
import java.time.LocalDateTime;
import java.time.ZoneId;

/** Saves the specialist report and optional visit closure as one transaction. */
public class SpecialistCompletionDAO {
    @FunctionalInterface public interface Connections { Connection open() throws Exception; }
    private final Connections connections;
    public SpecialistCompletionDAO() { this(DBContext::getConnection); }
    public SpecialistCompletionDAO(Connections connections) { this.connections = connections; }

    public boolean accept(int orderId,int specialistId) throws Exception {
        if(orderId<=0||specialistId<=0)return false;
        try(Connection c=connections.open();PreparedStatement p=c.prepareStatement(
                "UPDATE po SET Specialist_Employee_ID=? FROM Procedure_Order po "
                + "JOIN Medical_Record mr ON mr.Record_ID=po.Record_ID JOIN Appointment a ON a.Appointment_ID=mr.Appointment_ID "
                + "WHERE po.Order_ID=? AND po.Status='Pending' AND po.Specialist_Employee_ID IS NULL "
                + "AND a.Status='In_Progress' AND a.checkin_time IS NOT NULL "
                + "AND EXISTS(SELECT 1 FROM Employee_Profile e JOIN Account ac ON ac.Account_ID=e.Account_ID "
                + "WHERE e.Employee_ID=? AND ac.Role_ID=4 AND ac.Account_Status='Active')")) {
            p.setInt(1,specialistId);p.setInt(2,orderId);p.setInt(3,specialistId);return p.executeUpdate()==1;
        }
    }

    public boolean cancel(int orderId, int specialistId, String reason) throws Exception {
        if(reason==null||reason.isBlank()||reason.length()>2000)
            throw new IllegalArgumentException("Vui lòng nhập lý do không thực hiện (tối đa 2.000 ký tự).");
        try (Connection conn = connections.open(); PreparedStatement ps = conn.prepareStatement(
                "UPDATE po SET Status='Cancelled', Specialist_Employee_ID=?, Result_Conclusion=? FROM Procedure_Order po "
                + "JOIN Medical_Record mr ON mr.Record_ID=po.Record_ID "
                + "JOIN Appointment a ON a.Appointment_ID=mr.Appointment_ID "
                + "WHERE po.Order_ID=? AND a.Status='In_Progress' AND po.Status IN ('Pending','In_Progress') "
                + "AND po.Specialist_Employee_ID=?")) {
            ps.setInt(1, specialistId); ps.setNString(2,reason.trim());ps.setInt(3, orderId); ps.setInt(4, specialistId);
            return ps.executeUpdate() == 1;
        }
    }

    public boolean save(int orderId, int specialistId, String report, String conclusion,
                     String status, boolean closeVisit) throws Exception {
        if (orderId <= 0 || specialistId <= 0 || !("Pending".equals(status) || "Completed".equals(status)))
            throw new IllegalArgumentException("Ca hoặc trạng thái không hợp lệ.");
        if (closeVisit && (!"Completed".equals(status) || conclusion == null || conclusion.isBlank()))
            throw new IllegalArgumentException("Cần hoàn tất biên bản và nhập kết luận trước khi kết thúc ca khám.");
        try (Connection conn = connections.open()) {
            conn.setAutoCommit(false);
            conn.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE);
            try {
                int appointmentId, recordId;
                // Serialize visit closure with doctor completion and other specialist reports.
                try (PreparedStatement ps = conn.prepareStatement(
                        "SELECT a.Appointment_ID, a.Status, mr.Record_ID, a.checkin_time "
                        + "FROM Procedure_Order po JOIN Medical_Record mr ON mr.Record_ID=po.Record_ID "
                        + "JOIN Appointment a WITH (UPDLOCK,HOLDLOCK) ON a.Appointment_ID=mr.Appointment_ID "
                        + "WHERE po.Order_ID=?")) {
                    ps.setInt(1, orderId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next() || !"In_Progress".equals(rs.getString("Status"))
                                || rs.getTimestamp("checkin_time") == null)
                            throw new IllegalStateException("Ca đã kết thúc, bị hủy hoặc chưa được tiếp nhận.");
                        appointmentId = rs.getInt("Appointment_ID"); recordId = rs.getInt("Record_ID");
                    }
                }
                if (closeVisit) {
                    try (PreparedStatement ps = conn.prepareStatement(
                            "SELECT 1 FROM Procedure_Order WITH (UPDLOCK,HOLDLOCK) "
                            + "WHERE Record_ID=? AND Order_ID<>? AND Status NOT IN ('Completed','Cancelled')")) {
                        ps.setInt(1, recordId); ps.setInt(2, orderId);
                        try (ResultSet rs = ps.executeQuery()) {
                            if (rs.next()) closeVisit=false;
                        }
                    }
                    // Only the last completed procedure closes a visit with several orders.
                    if(closeVisit) report += "\n<VISIT_CLOSURE>\nBSPT #" + specialistId + " kết thúc ca khám lúc "
                            + LocalDateTime.now(ZoneId.of("Asia/Ho_Chi_Minh")) + "\n</VISIT_CLOSURE>";
                }
                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE Procedure_Order SET Result_Text=?, Result_Conclusion=?, Status=?, Specialist_Employee_ID=?, "
                        + "Completed_At=CASE WHEN ?='Completed' THEN COALESCE(Completed_At,SYSDATETIME()) ELSE Completed_At END "
                        + "WHERE Order_ID=? AND Status<>'Cancelled' AND (Status<>'Completed' OR ?='Completed') "
                        + "AND Specialist_Employee_ID=?")) {
                    ps.setNString(1, report); ps.setNString(2, conclusion); ps.setString(3, status);
                    ps.setInt(4, specialistId); ps.setString(5, status); ps.setInt(6, orderId);
                    ps.setString(7, status); ps.setInt(8, specialistId);
                    if (ps.executeUpdate() != 1) throw new IllegalStateException("Ca đã bị hủy, hoàn tất hoặc được bác sĩ khác tiếp nhận.");
                }
                if (closeVisit) {
                    try (PreparedStatement ps = conn.prepareStatement(
                            "UPDATE Appointment SET Status='Completed', doctor_completed_at=SYSDATETIME() "
                            + "WHERE Appointment_ID=? AND Status='In_Progress'")) {
                        ps.setInt(1, appointmentId);
                        if (ps.executeUpdate() != 1) throw new IllegalStateException("Ca khám đã thay đổi. Hãy tải lại trang.");
                    }
                }
                conn.commit();
                return closeVisit;
            } catch (Exception error) {
                conn.rollback(); throw error;
            }
        }
    }
}
