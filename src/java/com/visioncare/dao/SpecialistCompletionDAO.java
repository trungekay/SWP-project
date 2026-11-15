package com.visioncare.dao;

import java.sql.*;
import java.util.List;

/** Saves the specialist report and any post-procedure medication together. */
public class SpecialistCompletionDAO {
    public record Medication(int supplyId, int quantity, String instructions) {}
    @FunctionalInterface public interface Connections { Connection open() throws Exception; }
    private final Connections connections;
    public SpecialistCompletionDAO() { this(DBContext::getConnection); }
    public SpecialistCompletionDAO(Connections connections) { this.connections = connections; }

    public boolean accept(int orderId,int specialistId) throws Exception {
        if(orderId<=0||specialistId<=0)return false;
        try(Connection c=connections.open();PreparedStatement p=c.prepareStatement(
                "UPDATE po SET Specialist_Employee_ID=?, Accepted_At=SYSUTCDATETIME() FROM Procedure_Order po "
                + "JOIN Medical_Record mr ON mr.Record_ID=po.Record_ID JOIN Appointment a ON a.Appointment_ID=mr.Appointment_ID "
                + "WHERE po.Order_ID=? AND po.Status IN ('Pending','In_Progress') AND po.Accepted_At IS NULL "
                + "AND (po.Specialist_Employee_ID IS NULL OR po.Specialist_Employee_ID=?) "
                + "AND " + ProcedureOrderDAO.READY_FOR_SPECIALIST + " "
                + "AND a.Status IN ('In_Progress','Completed') AND a.checkin_time IS NOT NULL "
                + "AND EXISTS(SELECT 1 FROM Employee_Profile e JOIN Account ac ON ac.Account_ID=e.Account_ID "
                + "WHERE e.Employee_ID=? AND ac.Role_ID=4 AND ac.Account_Status='Active')")) {
            p.setInt(1,specialistId);p.setInt(2,orderId);p.setInt(3,specialistId);p.setInt(4,specialistId);
            return p.executeUpdate()==1;
        }
    }

    public boolean cancel(int orderId, int specialistId, String reason) throws Exception {
        if(reason==null||reason.isBlank()||reason.length()>2000)
            throw new IllegalArgumentException("Vui lòng nhập lý do không thực hiện (tối đa 2.000 ký tự).");
        try (Connection conn = connections.open(); PreparedStatement ps = conn.prepareStatement(
                "UPDATE po SET Status='Cancelled', Specialist_Employee_ID=?, Result_Conclusion=? FROM Procedure_Order po "
                + "JOIN Medical_Record mr ON mr.Record_ID=po.Record_ID "
                + "JOIN Appointment a ON a.Appointment_ID=mr.Appointment_ID "
                + "WHERE po.Order_ID=? AND a.Status IN ('In_Progress','Completed') AND a.checkin_time IS NOT NULL "
                + "AND po.Status IN ('Pending','In_Progress') "
                + "AND " + ProcedureOrderDAO.READY_FOR_SPECIALIST + " "
                + "AND po.Specialist_Employee_ID=? AND po.Accepted_At IS NOT NULL")) {
            ps.setInt(1, specialistId); ps.setNString(2,reason.trim());ps.setInt(3, orderId); ps.setInt(4, specialistId);
            return ps.executeUpdate() == 1;
        }
    }

    public void save(int orderId, int specialistId, String report, String conclusion,
                     String status, List<Medication> medication) throws Exception {
        if (orderId <= 0 || specialistId <= 0 || !("Pending".equals(status) || "Completed".equals(status)))
            throw new IllegalArgumentException("Ca hoặc trạng thái không hợp lệ.");
        if ("Completed".equals(status) && (conclusion == null || conclusion.isBlank()))
            throw new IllegalArgumentException("Cần nhập kết luận để hoàn tất thủ thuật.");
        if ("Pending".equals(status) && !medication.isEmpty())
            throw new IllegalArgumentException("Thuốc hậu phẫu được lưu khi hoàn tất thủ thuật.");
        try (Connection conn = connections.open()) {
            conn.setAutoCommit(false);
            conn.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE);
            try {
                int recordId;
                // Invoice checkout also locks the appointment before taking its item snapshot.
                try (PreparedStatement ps = conn.prepareStatement(
                        "SELECT mr.Record_ID, a.Status AS Appointment_Status "
                        + "FROM Procedure_Order po JOIN Medical_Record mr ON mr.Record_ID=po.Record_ID "
                        + "JOIN Appointment a WITH (UPDLOCK,HOLDLOCK) ON a.Appointment_ID=mr.Appointment_ID "
                        + "WHERE po.Order_ID=? AND po.Specialist_Employee_ID=? AND po.Accepted_At IS NOT NULL AND a.checkin_time IS NOT NULL "
                        + "AND a.Status IN ('In_Progress','Completed') AND " + ProcedureOrderDAO.READY_FOR_SPECIALIST
                        + " AND NOT EXISTS (SELECT 1 FROM Master_Invoice i JOIN Invoice_Checkout co ON co.Invoice_ID=i.Invoice_ID "
                        + "WHERE i.Appointment_ID=a.Appointment_ID AND co.Finalized_At IS NOT NULL)")) {
                    ps.setInt(1, orderId);
                    ps.setInt(2, specialistId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next())
                            throw new IllegalStateException("Thủ thuật chưa đủ điều kiện thực hiện hoặc hóa đơn đã chốt.");
                        if (!medication.isEmpty() && !"Completed".equals(rs.getString("Appointment_Status")))
                            throw new IllegalArgumentException("Chờ kết thúc khám lâm sàng để lưu thuốc hậu phẫu.");
                        recordId = rs.getInt("Record_ID");
                    }
                }
                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE Procedure_Order SET Result_Text=?, Result_Conclusion=?, Status=?, "
                        + "Completed_At=CASE WHEN ?='Completed' THEN COALESCE(Completed_At,SYSDATETIME()) ELSE Completed_At END "
                        + "WHERE Order_ID=? AND Status IN ('Pending','In_Progress') AND Specialist_Employee_ID=?")) {
                    ps.setNString(1, report); ps.setNString(2, conclusion); ps.setString(3, status);
                    ps.setString(4, status); ps.setInt(5, orderId); ps.setInt(6, specialistId);
                    if (ps.executeUpdate() != 1) throw new IllegalStateException("Ca đã bị hủy, hoàn tất hoặc được bác sĩ khác tiếp nhận.");
                }
                if (!medication.isEmpty()) appendMedication(conn, recordId, medication);
                conn.commit();
            } catch (Exception error) {
                conn.rollback(); throw error;
            }
        }
    }

    private void appendMedication(Connection conn, int recordId, List<Medication> medication) throws SQLException {
        int prescriptionId = 0;
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT TOP 1 Prescription_ID FROM Prescription WITH (UPDLOCK,HOLDLOCK) "
                + "WHERE Record_ID=? ORDER BY Prescription_ID DESC")) {
            ps.setInt(1, recordId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) prescriptionId = rs.getInt(1);
            }
        }
        if (prescriptionId == 0) {
            try (PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO Prescription (Record_ID) OUTPUT INSERTED.Prescription_ID VALUES (?)")) {
                ps.setInt(1, recordId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) throw new IllegalStateException("Không tạo được đơn thuốc.");
                    prescriptionId = rs.getInt(1);
                }
            }
        }
        try (PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO Prescription_Detail (Prescription_ID,Medicine_Name,Quantity,Dosage_Instruction) "
                + "SELECT ?,Supply_Name,?,? FROM Medical_Supply WHERE Supply_ID=? AND Category=N'Thuốc & dung dịch'")) {
            for (Medication item : medication) {
                if (item.quantity() < 1 || item.quantity() > 999 || item.instructions() == null
                        || item.instructions().isBlank() || item.instructions().length() > 1000) {
                    throw new IllegalArgumentException("Kiểm tra số lượng và cách dùng thuốc hậu phẫu.");
                }
                ps.setInt(1, prescriptionId);
                ps.setInt(2, item.quantity());
                ps.setNString(3, item.instructions());
                ps.setInt(4, item.supplyId());
                if (ps.executeUpdate() != 1) throw new IllegalArgumentException("Thuốc hậu phẫu không còn trong danh mục.");
            }
        }
    }
}
