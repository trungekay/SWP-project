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
            "a.Status AS Appointment_Status, a.checkin_time, " +
            "ws.Work_Date, ws.Start_Time, ws.End_Time, ws.Slot, " +
            "p.Patient_ID, p.Full_Name AS Patient_Name, p.Phone AS Patient_Phone, p.DOB AS Patient_DOB, " +
            "p.Address AS Patient_Address, p.Account_ID, " +
            "acc.Email AS Patient_Email, " +
            "doc.Full_Name AS Doctor_Name, doc.Specialty AS Doctor_Specialty, doc.Phone AS Doctor_Phone, " +
            "r.Room_Name, " +
            "inv.Invoice_ID, inv.Total_Amount, inv.Status AS Invoice_Status " +
            "FROM Medical_Record m " +
            "JOIN Appointment a ON m.Appointment_ID = a.Appointment_ID " +
            "LEFT JOIN Work_Schedule ws ON a.Schedule_ID = ws.Schedule_ID " +
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
        sql.append("ORDER BY CASE WHEN m.Record_ID = ? THEN 0 ELSE 1 END");

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            ps.setInt(1, id);
            ps.setInt(2, id);
            if (accountId != null) {
                ps.setInt(3, accountId);
            }
            ps.setInt(accountId == null ? 3 : 4, id);

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

                    // Time and Schedule details
                    java.sql.Date workDate = rs.getDate("Work_Date");
                    record.put("appointmentDateFmt", workDate != null ? dateOnlyFormat.format(workDate) : (createdAt != null ? dateOnlyFormat.format(createdAt) : "N/A"));

                    java.sql.Time st = rs.getTime("Start_Time");
                    java.sql.Time et = rs.getTime("End_Time");
                    String timeSlot = "";
                    if (st != null && et != null) {
                        timeSlot = st.toString().substring(0, 5) + " - " + et.toString().substring(0, 5);
                    } else if (st != null) {
                        timeSlot = st.toString().substring(0, 5);
                    } else {
                        String slot = rs.getString("Slot");
                        timeSlot = slot != null && !slot.trim().isEmpty() ? slot : "Chưa cập nhật";
                    }
                    record.put("timeSlot", timeSlot);

                    Timestamp checkinTs = rs.getTimestamp("checkin_time");
                    record.put("checkinTime", checkinTs != null ? dateTimeFormat.format(checkinTs) : null);

                    // Patient details
                    int patientId = rs.getInt("Patient_ID");
                    record.put("patientId", patientId);
                    record.put("formattedPatientId", String.format("#BN-%04d", patientId));
                    record.put("patientName", rs.getString("Patient_Name"));
                    record.put("patientPhone", rs.getString("Patient_Phone"));
                    java.sql.Date dob = rs.getDate("Patient_DOB");
                    record.put("patientDob", dob != null ? dateOnlyFormat.format(dob) : "Chưa cập nhật");
                    record.put("patientAddress", rs.getString("Patient_Address") != null ? rs.getString("Patient_Address") : "Chưa cập nhật");
                    record.put("patientEmail", rs.getString("Patient_Email") != null ? rs.getString("Patient_Email") : "Chưa cập nhật");

                    // Doctor details
                    String rawDoc = rs.getString("Doctor_Name");
                    String docName = rawDoc != null && !rawDoc.trim().isEmpty() ? rawDoc.trim() : "Chưa cập nhật";
                    if (!"Chưa cập nhật".equals(docName)) {
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
                    }
                    record.put("doctorName", docName);
                    record.put("doctorSpecialty", rs.getString("Doctor_Specialty") != null ? rs.getString("Doctor_Specialty") : "Bác sĩ nhãn khoa");
                    record.put("doctorPhone", rs.getString("Doctor_Phone") != null ? rs.getString("Doctor_Phone") : "Chưa cập nhật");
                    record.put("roomName", rs.getString("Room_Name") != null ? rs.getString("Room_Name") : "Phòng khám Mắt");

                    // Clinical details
                    String diag = rs.getString("Clinical_Diagnosis");
                    record.put("clinicalDiagnosis", diag != null && !diag.trim().isEmpty() ? diag : "Chưa cập nhật");

                    String examResult = rs.getString("examination_result");
                    record.put("examinationResult", examResult != null && !examResult.trim().isEmpty() 
                            ? examResult 
                            : "Chưa cập nhật");

                    String conclusion = rs.getString("conclusion");
                    record.put("conclusion", conclusion != null && !conclusion.trim().isEmpty() 
                            ? conclusion 
                            : "Chưa cập nhật");

                    loadExaminationDetail(conn, recordId, record);

                    // Load Procedures (Cận lâm sàng & Thủ thuật)
                    record.put("procedures", loadProcedures(conn, recordId));

                    // Load Prescription & Medicine details & Eyeglass
                    loadPrescription(conn, recordId, record);

                    // Load Previous visits history of this patient (matching doctor screen)
                    record.put("history", loadPatientHistory(conn, patientId, recordId));
                }
            }
        }

        return record;
    }

    private void loadExaminationDetail(Connection conn, int recordId, Map<String, Object> record) throws Exception {
        String sql = "SELECT Chief_Complaint, Medical_History, OD_Uncorrected, OS_Uncorrected, " +
                "OD_Corrected, OS_Corrected, OD_IOP, OS_IOP, Anterior_Findings, Posterior_Findings, Follow_Up_Date " +
                "FROM Examination_Detail WHERE Record_ID = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, recordId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return;
                record.put("chiefComplaint", rs.getString("Chief_Complaint"));
                record.put("medicalHistory", rs.getString("Medical_History"));
                record.put("odUncorrected", rs.getString("OD_Uncorrected"));
                record.put("osUncorrected", rs.getString("OS_Uncorrected"));
                record.put("odCorrected", rs.getString("OD_Corrected"));
                record.put("osCorrected", rs.getString("OS_Corrected"));
                record.put("odIop", rs.getString("OD_IOP"));
                record.put("osIop", rs.getString("OS_IOP"));
                record.put("anteriorFindings", rs.getString("Anterior_Findings"));
                record.put("posteriorFindings", rs.getString("Posterior_Findings"));
                java.sql.Date followUp = rs.getDate("Follow_Up_Date");
                record.put("followUpDate", followUp == null ? null : dateOnlyFormat.format(followUp));
            }
        }
    }

    private List<Map<String, Object>> loadProcedures(Connection conn, int recordId) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT po.Order_ID, po.Status, po.Referral_Notes, po.Result_Text, po.Result_Conclusion, po.Completed_At, " +
                     "s.Service_Name, po.Actual_Price, esp.Full_Name AS Specialist_Name " +
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
                    item.put("referralNotes", rs.getString("Referral_Notes"));
                    item.put("resultText", rs.getString("Result_Text"));
                    item.put("resultConclusion", rs.getString("Result_Conclusion"));
                    Timestamp compAt = rs.getTimestamp("Completed_At");
                    item.put("completedAtFmt", compAt != null ? dateTimeFormat.format(compAt) : null);
                    String specName = rs.getString("Specialist_Name");
                    item.put("specialistName", specName != null ? specName : "Chưa phân công");
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
        String doctorNotes = "Chưa có lời dặn của bác sĩ.";
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
            // Load Medicines
            String sqlDetail = "SELECT Detail_ID, Medicine_Name, Quantity, Dosage_Instruction " +
                               "FROM Prescription_Detail WHERE Prescription_ID = ? ORDER BY Detail_ID ASC";
            try (PreparedStatement psDetail = conn.prepareStatement(sqlDetail)) {
                psDetail.setInt(1, prescriptionId);
                try (ResultSet rsDetail = psDetail.executeQuery()) {
                    int stt = 1;
                    while (rsDetail.next()) {
                        Map<String, Object> med = new HashMap<>();
                        med.put("stt", stt++);
                        med.put("medicineName", rsDetail.getString("Medicine_Name"));
                        med.put("quantity", rsDetail.getInt("Quantity"));
                        String dosage = rsDetail.getString("Dosage_Instruction");
                        med.put("dosageInstruction", dosage != null ? dosage : "Chưa cập nhật");
                        medicines.add(med);
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }

            // Load Eyeglass Prescription if any
            boolean hasEyeglassTable;
            try (ResultSet tables = conn.getMetaData().getTables(conn.getCatalog(), null, "Eyeglass_Prescription", new String[]{"TABLE"})) {
                hasEyeglassTable = tables.next();
            } catch (Exception error) {
                throw new IllegalStateException("Không kiểm tra được cấu trúc đơn kính.", error);
            }
            if (!hasEyeglassTable) {
                record.put("medicines", medicines);
                return;
            }
            String sqlGlass = "SELECT OD_SPH, OD_CYL, OD_AXIS, OD_ADD, OS_SPH, OS_CYL, OS_AXIS, OS_ADD, PD, Lens_Type, Glasses_Notes " +
                              "FROM Eyeglass_Prescription WHERE Prescription_ID = ?";
            try (PreparedStatement psGlass = conn.prepareStatement(sqlGlass)) {
                psGlass.setInt(1, prescriptionId);
                try (ResultSet rsGlass = psGlass.executeQuery()) {
                    if (rsGlass.next()) {
                        Map<String, Object> eyeglass = new HashMap<>();
                        eyeglass.put("odSph", rsGlass.getString("OD_SPH"));
                        eyeglass.put("odCyl", rsGlass.getString("OD_CYL"));
                        eyeglass.put("odAxis", rsGlass.getString("OD_AXIS"));
                        eyeglass.put("odAdd", rsGlass.getString("OD_ADD"));
                        eyeglass.put("osSph", rsGlass.getString("OS_SPH"));
                        eyeglass.put("osCyl", rsGlass.getString("OS_CYL"));
                        eyeglass.put("osAxis", rsGlass.getString("OS_AXIS"));
                        eyeglass.put("osAdd", rsGlass.getString("OS_ADD"));
                        eyeglass.put("pd", rsGlass.getString("PD"));
                        String lensType = rsGlass.getString("Lens_Type");
                        eyeglass.put("lensType", lensType);
                        String lensTypeName = "Kính nhìn xa";
                        if ("near".equalsIgnoreCase(lensType)) lensTypeName = "Kính đọc gần";
                        else if ("progressive".equalsIgnoreCase(lensType)) lensTypeName = "Kính đa tròng";
                        else if ("other".equalsIgnoreCase(lensType)) lensTypeName = "Khác";
                        eyeglass.put("lensTypeName", lensTypeName);
                        eyeglass.put("glassesNotes", rsGlass.getString("Glasses_Notes"));
                        record.put("eyeglass", eyeglass);
                        record.put("hasGlasses", true);
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        record.put("medicines", medicines);
    }

    private List<Map<String, Object>> loadPatientHistory(Connection conn, int patientId, int currentRecordId) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT m.Record_ID, m.Appointment_ID, m.Clinical_Diagnosis, m.examination_result, m.conclusion, m.Created_At, " +
                     "ws.Work_Date, ws.Start_Time, " +
                     "doc.Full_Name AS Doctor_Name, doc.Specialty AS Doctor_Specialty " +
                     "FROM Medical_Record m " +
                     "JOIN Appointment a ON m.Appointment_ID = a.Appointment_ID " +
                     "LEFT JOIN Work_Schedule ws ON a.Schedule_ID = ws.Schedule_ID " +
                     "LEFT JOIN Employee_Profile doc ON COALESCE(m.Doctor_Employee_ID, ws.Doctor_Employee_ID) = doc.Employee_ID " +
                     "WHERE a.Patient_ID = ? AND m.Record_ID != ? AND a.Status = 'Completed' " +
                     "ORDER BY COALESCE(ws.Work_Date, CAST(m.Created_At AS DATE)) DESC, COALESCE(ws.Start_Time, CAST(m.Created_At AS TIME)) DESC, m.Created_At DESC";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, patientId);
            ps.setInt(2, currentRecordId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> item = new HashMap<>();
                    int recId = rs.getInt("Record_ID");
                    item.put("recordId", recId);
                    item.put("formattedId", String.format("#MR-%05d", recId));
                    item.put("appointmentId", rs.getInt("Appointment_ID"));
                    java.sql.Date workDate = rs.getDate("Work_Date");
                    java.sql.Time startTime = rs.getTime("Start_Time");
                    Timestamp cat = rs.getTimestamp("Created_At");

                    String dateFmt = "N/A";
                    if (workDate != null) {
                        dateFmt = dateOnlyFormat.format(workDate);
                    } else if (cat != null) {
                        dateFmt = dateOnlyFormat.format(cat);
                    }

                    String timeFmt = "--:--";
                    if (startTime != null) {
                        timeFmt = new SimpleDateFormat("HH:mm").format(startTime);
                    } else if (cat != null) {
                        timeFmt = new SimpleDateFormat("HH:mm").format(cat);
                    }

                    item.put("dateFmt", dateFmt);
                    item.put("timeFmt", timeFmt);
                    String rawDoc = rs.getString("Doctor_Name");
                    String docName = rawDoc != null && !rawDoc.trim().isEmpty() ? rawDoc.trim() : "Chưa cập nhật";
                    if (!"Chưa cập nhật".equals(docName) && !docName.startsWith("BS.") && !docName.startsWith("BS ")) {
                        docName = "BS. " + docName;
                    }
                    item.put("doctorName", docName);
                    item.put("doctorSpecialty", rs.getString("Doctor_Specialty"));
                    item.put("clinicalDiagnosis", rs.getString("Clinical_Diagnosis"));
                    item.put("examinationResult", rs.getString("examination_result"));
                    item.put("conclusion", rs.getString("conclusion"));
                    list.add(item);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }
}
