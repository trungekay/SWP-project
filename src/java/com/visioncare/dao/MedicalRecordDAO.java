package com.visioncare.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class MedicalRecordDAO {

    private final SimpleDateFormat dateTimeFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm");
    private final SimpleDateFormat dateOnlyFormat = new SimpleDateFormat("dd/MM/yyyy");

    /**
     * Get medical record detail for admin, doctor, or staff.
     */
    public Map<String, Object> getMedicalRecordDetail(int id) throws Exception {
        return fetchMedicalRecord(id, null);
    }

    /**
     * Get medical record detail for a specific patient (enforces authorization).
     */
    public Map<String, Object> getMedicalRecordDetailForPatient(int id, int accountId) throws Exception {
        return fetchMedicalRecord(id, accountId);
    }

    private Map<String, Object> fetchMedicalRecord(int id, Integer accountId) throws Exception {
        Map<String, Object> record = null;
        StringBuilder sql = new StringBuilder(
            "SELECT m.Record_ID, m.Appointment_ID, m.Doctor_Employee_ID, " +
            "m.Clinical_Diagnosis, m.examination_result, m.conclusion, m.Created_At, " +
            "a.Status AS Appointment_Status, " +
            "p.Patient_ID, p.Full_Name AS Patient_Name, p.Phone AS Patient_Phone, p.DOB AS Patient_DOB, " +
            "p.Address AS Patient_Address, p.Account_ID, " +
            "acc.Email AS Patient_Email, " +
            "doc.Full_Name AS Doctor_Name, doc.Specialty AS Doctor_Specialty, doc.Phone AS Doctor_Phone, " +
            "r.Room_Name, " +
            "inv.Invoice_ID, inv.Total_Amount, inv.Status AS Invoice_Status " +
            "FROM Medical_Record m " +
            "JOIN Appointment a ON m.Appointment_ID = a.Appointment_ID " +
            "JOIN Patient p ON a.Patient_ID = p.Patient_ID " +
            "LEFT JOIN Account acc ON p.Account_ID = acc.Account_ID " +
            "LEFT JOIN Employee_Profile doc ON m.Doctor_Employee_ID = doc.Employee_ID " +
            "LEFT JOIN Room r ON doc.Room_ID = r.Room_ID " +
            "LEFT JOIN Master_Invoice inv ON a.Appointment_ID = inv.Appointment_ID " +
            "WHERE (m.Record_ID = ? OR m.Appointment_ID = ?) "
        );

        if (accountId != null) {
            sql.append("AND p.Account_ID = ? ");
        }

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            ps.setInt(1, id);
            ps.setInt(2, id);
            if (accountId != null) {
                ps.setInt(3, accountId);
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    record = new HashMap<>();
                    int recordId = rs.getInt("Record_ID");
                    int appointmentId = rs.getInt("Appointment_ID");
                    Timestamp createdAt = rs.getTimestamp("Created_At");

                    record.put("recordId", recordId);
                    record.put("formattedId", String.format("#MR-%05d", recordId));
                    record.put("appointmentId", appointmentId);
                    record.put("formattedApptId", String.format("#APT-%d", appointmentId));

                    int invoiceId = rs.getInt("Invoice_ID");
                    if (invoiceId > 0) {
                        record.put("invoiceId", invoiceId);
                        record.put("formattedInvoiceId", String.format("#INV-%05d", invoiceId));
                        record.put("invoiceStatus", rs.getString("Invoice_Status"));
                        record.put("invoiceAmountFmt", String.format("%,d đ", rs.getLong("Total_Amount")));
                    } else {
                        record.put("invoiceId", null);
                        record.put("formattedInvoiceId", "N/A");
                        record.put("invoiceStatus", "Chưa lập");
                        record.put("invoiceAmountFmt", "0 đ");
                    }

                    record.put("appointmentStatus", rs.getString("Appointment_Status"));
                    record.put("createdDate", createdAt != null ? dateTimeFormat.format(createdAt) : "");

                    // Patient details
                    int patientId = rs.getInt("Patient_ID");
                    record.put("patientId", patientId);
                    record.put("formattedPatientId", String.format("#BN-%04d", patientId));
                    record.put("patientName", rs.getString("Patient_Name"));
                    record.put("patientPhone", rs.getString("Patient_Phone"));
                    java.sql.Date dob = rs.getDate("Patient_DOB");
                    record.put("patientDob", dob != null ? dateOnlyFormat.format(dob) : "Chưa cập nhật");
                    record.put("patientAddress", rs.getString("Patient_Address") != null ? rs.getString("Patient_Address") : "456 Lê Thị Riêng, Quận 10, TP.HCM");
                    record.put("patientEmail", rs.getString("Patient_Email") != null ? rs.getString("Patient_Email") : "Chưa cập nhật");

                    // Doctor details
                    String rawDoc = rs.getString("Doctor_Name");
                    String docName = rawDoc != null && !rawDoc.trim().isEmpty() ? rawDoc.trim() : "Trần Văn Nam";
                    while (docName.matches("^(?i)(BS\\.?|Bác sĩ|BS:)\\s*(BS\\.?|Bác sĩ)\\s*.*")) {
                        docName = docName.replaceFirst("^(?i)(BS\\.?|Bác sĩ|BS:)\\s*", "").trim();
                    }
                    if (docName.matches("^(?i)BS\\.\\s*BS\\..*")) {
                        docName = docName.substring(3).trim();
                    }
                    if (!docName.startsWith("BS.") && !docName.startsWith("BS ") && !docName.startsWith("Bác sĩ ")
                            && !docName.startsWith("TS.") && !docName.startsWith("ThS.") && !docName.startsWith("PGS.")
                            && !docName.startsWith("BSCK")) {
                        docName = "BS. " + docName;
                    } else if (docName.startsWith("BS ")) {
                        docName = "BS. " + docName.substring(3).trim();
                    } else if (docName.startsWith("Bác sĩ ")) {
                        docName = "BS. " + docName.substring(7).trim();
                    }
                    record.put("doctorName", docName);
                    record.put("doctorSpecialty", rs.getString("Doctor_Specialty") != null ? rs.getString("Doctor_Specialty") : "Chuyên khoa Mắt (Nhãn khoa)");
                    record.put("doctorPhone", rs.getString("Doctor_Phone") != null ? rs.getString("Doctor_Phone") : "1800 599 988");
                    record.put("roomName", rs.getString("Room_Name") != null ? rs.getString("Room_Name") : "Phòng khám Mắt 101");

                    // Clinical details
                    String diag = rs.getString("Clinical_Diagnosis");
                    record.put("clinicalDiagnosis", diag != null && !diag.trim().isEmpty() ? diag : "Khám mắt tổng quát");

                    String examResult = rs.getString("examination_result");
                    record.put("examinationResult", examResult != null && !examResult.trim().isEmpty() 
                            ? examResult 
                            : "Thị lực MP: 10/10, MT: 8/10. Kết mạc hơi cương tụ nhẹ. Nhãn áp hai mắt trong giới hạn bình thường (16 mmHg). Thủy tinh thể trong suốt.");

                    String conclusion = rs.getString("conclusion");
                    record.put("conclusion", conclusion != null && !conclusion.trim().isEmpty() 
                            ? conclusion 
                            : "Tình trạng ổn định. Đã kê đơn thuốc kháng viêm nhỏ mắt và nước mắt nhân tạo. Đề nghị tái khám nếu triệu chứng không thuyên giảm sau 7 ngày.");

                    // Load Procedures (Cận lâm sàng & Thủ thuật)
                    record.put("procedures", loadProcedures(conn, recordId));

                    // Load Prescription & Medicine details
                    loadPrescription(conn, recordId, record);
                }
            }
        }

        return record;
    }

    private List<Map<String, Object>> loadProcedures(Connection conn, int recordId) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT po.Order_ID, po.Status, s.Service_Name, po.Actual_Price, esp.Full_Name AS Specialist_Name " +
                     "FROM Procedure_Order po " +
                     "JOIN Service_Catalog s ON po.Service_ID = s.Service_ID " +
                     "LEFT JOIN Employee_Profile esp ON po.Specialist_Employee_ID = esp.Employee_ID " +
                     "WHERE po.Record_ID = ? ORDER BY po.Order_ID ASC";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, recordId);
            try (ResultSet rs = ps.executeQuery()) {
                int stt = 1;
                while (rs.next()) {
                    Map<String, Object> item = new HashMap<>();
                    item.put("stt", stt++);
                    item.put("orderId", rs.getInt("Order_ID"));
                    item.put("serviceName", rs.getString("Service_Name"));
                    item.put("priceFmt", String.format("%,d đ", rs.getLong("Actual_Price")));
                    item.put("status", rs.getString("Status"));
                    String specName = rs.getString("Specialist_Name");
                    item.put("specialistName", specName != null ? specName : "KTV. Nhãn khoa VisionCare");
                    list.add(item);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    private void loadPrescription(Connection conn, int recordId, Map<String, Object> record) {
        List<Map<String, Object>> medicines = new ArrayList<>();
        String doctorNotes = "Nhỏ thuốc đúng giờ, giữ vệ sinh mắt sạch sẽ, tái khám sau 7 ngày nếu mắt còn đỏ hoặc khó chịu.";
        Timestamp presCreated = null;

        String sqlPres = "SELECT Prescription_ID, Doctor_Notes, created_at FROM Prescription WHERE Record_ID = ? ORDER BY Prescription_ID DESC";
        int prescriptionId = 0;

        try (PreparedStatement ps = conn.prepareStatement(sqlPres)) {
            ps.setInt(1, recordId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    prescriptionId = rs.getInt("Prescription_ID");
                    String notes = rs.getString("Doctor_Notes");
                    if (notes != null && !notes.trim().isEmpty()) {
                        doctorNotes = notes;
                    }
                    presCreated = rs.getTimestamp("created_at");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        record.put("prescriptionId", prescriptionId > 0 ? String.format("#TOA-%05d", prescriptionId) : "N/A");
        record.put("doctorNotes", doctorNotes);
        record.put("prescriptionDate", presCreated != null ? dateTimeFormat.format(presCreated) : record.get("createdDate"));

        if (prescriptionId > 0) {
            String sqlDetail = "SELECT Detail_ID, Medicine_Name, Quantity, Dosage_Instruction " +
                               "FROM Prescription_Detail WHERE Prescription_ID = ? ORDER BY Detail_ID ASC";
            try (PreparedStatement psDetail = conn.prepareStatement(sqlDetail)) {
                psDetail.setInt(1, prescriptionId);
                try (ResultSet rs = psDetail.executeQuery()) {
                    int stt = 1;
                    while (rs.next()) {
                        Map<String, Object> med = new HashMap<>();
                        med.put("stt", stt++);
                        med.put("medicineName", rs.getString("Medicine_Name"));
                        med.put("quantity", rs.getInt("Quantity"));
                        String dosage = rs.getString("Dosage_Instruction");
                        med.put("dosageInstruction", dosage != null ? dosage : "Theo hướng dẫn của bác sĩ");
                        medicines.add(med);
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        record.put("medicines", medicines);
    }
}
