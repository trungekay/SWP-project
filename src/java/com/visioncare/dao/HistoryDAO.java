package com.visioncare.dao;

import com.visioncare.model.Appointment;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class HistoryDAO {
    
    // For medical-history.jsp (Lịch sử khám)
    public List<Map<String, Object>> getMedicalRecords(int accountId) throws Exception {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT m.Record_ID, a.Appointment_ID, a.Status, m.Created_At AS Date, e.Full_Name AS DoctorName, " +
                     "i.Invoice_ID, i.Status AS Invoice_Status, i.Total_Amount, " +
                     "(SELECT TOP 1 s.Service_Name FROM Procedure_Order po JOIN Service s ON po.Service_ID = s.Service_ID WHERE po.Record_ID = m.Record_ID) AS Dynamic_Service " +
                     "FROM Medical_Record m " +
                     "JOIN Appointment a ON m.Appointment_ID = a.Appointment_ID " +
                     "JOIN Patient p ON a.Patient_ID = p.Patient_ID " +
                     "JOIN Employee_Profile e ON m.Doctor_Employee_ID = e.Employee_ID " +
                     "LEFT JOIN Master_Invoice i ON a.Appointment_ID = i.Appointment_ID " +
                     "WHERE p.Account_ID = ? ORDER BY m.Created_At DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("date", rs.getDate("Date"));
                    map.put("doctorName", rs.getString("DoctorName"));
                    map.put("status", rs.getString("Status"));
                    int recId = rs.getInt("Record_ID");
                    int apptId = rs.getInt("Appointment_ID");
                    map.put("recordId", recId);
                    map.put("appointmentId", apptId);
                    map.put("id", recId > 0 ? recId : apptId);
                    int invId = rs.getInt("Invoice_ID");
                    map.put("invoiceId", invId > 0 ? invId : 0);
                    map.put("invoiceStatus", rs.getString("Invoice_Status"));
                    String dynamicSvc = rs.getString("Dynamic_Service");
                    map.put("serviceName", dynamicSvc != null ? dynamicSvc : "Khám chuyên khoa");
                    list.add(map);
                }
            }
        }
        return list;
    }

    // For medical-history.jsp (Lịch sử thanh toán)
    public List<Map<String, Object>> getInvoices(int accountId) throws Exception {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT i.Invoice_ID, i.Close_At AS Date, i.Total_Amount, i.Status, " +
                     "(SELECT STRING_AGG(s.Service_Name, ', ') FROM Procedure_Order po JOIN Service s ON po.Service_ID = s.Service_ID WHERE po.Record_ID = m.Record_ID) AS Description, " +
                     "(SELECT TOP 1 Payment_Gateway FROM Payment_Transaction pt WHERE pt.Invoice_ID = i.Invoice_ID ORDER BY pt.Transaction_ID DESC) AS Method " +
                     "FROM Master_Invoice i " +
                     "JOIN Appointment a ON i.Appointment_ID = a.Appointment_ID " +
                     "JOIN Patient p ON a.Patient_ID = p.Patient_ID " +
                     "LEFT JOIN Medical_Record m ON a.Appointment_ID = m.Appointment_ID " +
                     "WHERE p.Account_ID = ? AND i.Status != 'Pending_Deposit' ORDER BY i.Close_At DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("id", rs.getInt("Invoice_ID"));
                    map.put("date", rs.getDate("Date"));
                    map.put("amount", String.format("%,d", rs.getLong("Total_Amount")));
                    String desc = rs.getString("Description");
                    map.put("description", desc != null ? desc : "Phí dịch vụ");
                    String method = rs.getString("Method");
                    map.put("method", method != null ? method : "Cash");
                    
                    String status = rs.getString("Status");
                    String statusVn = status;
                    if ("Paid".equals(status)) statusVn = "Đã thanh toán";
                    else if ("Refunded".equals(status)) statusVn = "Đã hoàn tiền";
                    map.put("status", statusVn);
                    
                    list.add(map);
                }
            }
        }
        return list;
    }

    // For refund-request.jsp
    public List<Map<String, Object>> getRefunds(int accountId) throws Exception {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT r.Refund_ID, r.Invoice_ID, r.Refund_Amount, r.Reason, r.Status, r.Created_At, " +
                     "p.Full_Name AS Patient_Name, p.Phone AS Patient_Phone, i.Appointment_ID " +
                     "FROM Refund_Request r " +
                     "JOIN Patient p ON r.Patient_ID = p.Patient_ID " +
                     "LEFT JOIN Master_Invoice i ON r.Invoice_ID = i.Invoice_ID " +
                     "WHERE p.Account_ID = ? ORDER BY r.Refund_ID DESC";
        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    int refundId = rs.getInt("Refund_ID");
                    int invoiceId = rs.getInt("Invoice_ID");
                    int apptId = rs.getInt("Appointment_ID");
                    String status = rs.getString("Status");
                    String statusVn = status;
                    if ("Pending".equals(status)) statusVn = "Chờ duyệt";
                    else if ("Approved".equals(status)) statusVn = "Đã xác nhận";
                    else if ("Rejected".equals(status)) statusVn = "Đã từ chối";

                    map.put("id", refundId);
                    map.put("formattedId", String.format("#REF-%03d", refundId));
                    map.put("invoiceId", invoiceId);
                    map.put("formattedInvoiceId", String.format("#INV-%05d", invoiceId));
                    map.put("appointmentId", apptId);
                    map.put("formattedApptId", apptId > 0 ? ("#APT-" + apptId) : "N/A");
                    map.put("amount", String.format("%,d", rs.getLong("Refund_Amount")));
                    map.put("amountFmt", String.format("%,d đ", rs.getLong("Refund_Amount")));
                    map.put("reason", rs.getString("Reason"));
                    map.put("status", status);
                    map.put("statusVn", statusVn);
                    map.put("patientName", rs.getString("Patient_Name"));
                    map.put("patientPhone", rs.getString("Patient_Phone"));
                    map.put("createdAt", rs.getTimestamp("Created_At") != null ? sdf.format(rs.getTimestamp("Created_At")) : "N/A");
                    
                    list.add(map);
                }
            }
        }
        return list;
    }
}
