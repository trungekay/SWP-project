package com.visioncare.dao;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.Types;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/** Database operations for the two doctor forms. One save is one transaction. */
public class DoctorFormDAO {
    private static final String[] EXAM_KEYS = {
        "chiefComplaint", "medicalHistory", "odUncorrected", "osUncorrected",
        "odCorrected", "osCorrected", "odIop", "osIop",
        "anteriorFindings", "posteriorFindings", "followUpDate"
    };
    private static final String[] EXAM_COLUMNS = {
        "Chief_Complaint", "Medical_History", "OD_Uncorrected", "OS_Uncorrected",
        "OD_Corrected", "OS_Corrected", "OD_IOP", "OS_IOP",
        "Anterior_Findings", "Posterior_Findings", "Follow_Up_Date"
    };
    private static final String[] GLASSES_KEYS = {
        "odSph", "odCyl", "odAxis", "odAdd",
        "osSph", "osCyl", "osAxis", "osAdd", "pd", "lensType", "glassesNotes"
    };
    private static final String[] GLASSES_COLUMNS = {
        "OD_SPH", "OD_CYL", "OD_AXIS", "OD_ADD",
        "OS_SPH", "OS_CYL", "OS_AXIS", "OS_ADD", "PD", "Lens_Type", "Glasses_Notes"
    };

    public Map<String, String> loadExamination(int appointmentId) throws Exception {
        Map<String, String> values = new HashMap<>();
        String sql = "SELECT m.Clinical_Diagnosis, m.examination_result, m.conclusion, e.* " +
                "FROM Medical_Record m LEFT JOIN Examination_Detail e ON e.Record_ID = m.Record_ID " +
                "WHERE m.Appointment_ID = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, appointmentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    put(values, "clinicalDiagnosis", rs.getString("Clinical_Diagnosis"));
                    put(values, "examinationResult", rs.getString("examination_result"));
                    put(values, "conclusion", rs.getString("conclusion"));
                    for (int i = 0; i < EXAM_KEYS.length; i++) {
                        put(values, EXAM_KEYS[i], rs.getString(EXAM_COLUMNS[i]));
                    }
                }
            }
        }
        if (values.getOrDefault("chiefComplaint", "").isBlank()) {
            String staffNote = values.get("clinicalDiagnosis");
            if (staffNote != null && !staffNote.isBlank()
                    && values.getOrDefault("examinationResult", "").isBlank()) {
                values.put("chiefComplaint", staffNote);
                values.put("chiefComplaintSource", "Lấy từ ghi chú tiếp nhận");
            }
        }
        if (values.getOrDefault("medicalHistory", "").isBlank()) {
            String history = latestPatientHistory(appointmentId);
            if (history != null) {
                values.put("medicalHistory", history);
                values.put("medicalHistorySource", "Lấy từ lần khám đã hoàn tất gần nhất");
            }
        }
        values.put("previousDiagnoses", previousDiagnoses(appointmentId));
        String referralSql = "SELECT TOP 1 po.Service_ID, po.Referral_Notes, po.Status, " +
                "po.Result_Text, po.Result_Conclusion, po.Completed_At, " +
                "sc.Service_Name, specialist.Full_Name AS Specialist_Name " +
                "FROM Medical_Record m JOIN Procedure_Order po ON po.Record_ID = m.Record_ID " +
                "JOIN Service_Catalog sc ON sc.Service_ID = po.Service_ID " +
                "LEFT JOIN Employee_Profile specialist ON specialist.Employee_ID = po.Specialist_Employee_ID " +
                "WHERE m.Appointment_ID = ? AND po.Referral_Notes IS NOT NULL ORDER BY po.Order_ID DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(referralSql)) {
            ps.setInt(1, appointmentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    values.put("surgeryServiceId", String.valueOf(rs.getInt("Service_ID")));
                    put(values, "surgeryNotes", rs.getString("Referral_Notes"));
                    put(values, "surgeryStatus", rs.getString("Status"));
                    put(values, "surgeryServiceName", rs.getString("Service_Name"));
                    if ("Completed".equalsIgnoreCase(rs.getString("Status"))) {
                        String result = rs.getString("Result_Text");
                        if (result != null) {
                            put(values, "surgeryResult", result.replaceFirst("(?s)^\\[OD_UCVA:.*?\\]\\s*\\[OS_UCVA:.*?\\]\\s*\\[PD:.*?\\]\\s*", "").trim());
                        }
                        put(values, "surgeryConclusion", rs.getString("Result_Conclusion"));
                        put(values, "surgerySpecialist", rs.getString("Specialist_Name"));
                        if (rs.getTimestamp("Completed_At") != null) {
                            put(values, "surgeryCompletedAt", rs.getTimestamp("Completed_At").toString().replace('T', ' '));
                        }
                    }
                }
            }
        }
        return values;
    }

    private String latestPatientHistory(int appointmentId) throws Exception {
        String sql = "SELECT TOP 1 e.Medical_History FROM Appointment currentAppt " +
                "JOIN Work_Schedule currentWs ON currentWs.Schedule_ID = currentAppt.Schedule_ID " +
                "JOIN Appointment previousAppt ON previousAppt.Patient_ID = currentAppt.Patient_ID " +
                "JOIN Work_Schedule previousWs ON previousWs.Schedule_ID = previousAppt.Schedule_ID " +
                "JOIN Medical_Record m ON m.Appointment_ID = previousAppt.Appointment_ID " +
                "JOIN Examination_Detail e ON e.Record_ID = m.Record_ID " +
                "WHERE currentAppt.Appointment_ID = ? AND previousAppt.Appointment_ID <> ? " +
                "AND (previousWs.Work_Date < currentWs.Work_Date OR " +
                "(previousWs.Work_Date = currentWs.Work_Date AND previousWs.Start_Time < currentWs.Start_Time)) " +
                "AND previousAppt.Status = 'Completed' " +
                "AND NULLIF(LTRIM(RTRIM(e.Medical_History)), '') IS NOT NULL " +
                "ORDER BY previousWs.Work_Date DESC, previousWs.Start_Time DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, appointmentId);
            ps.setInt(2, appointmentId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getString(1) : null;
            }
        }
    }

    private String previousDiagnoses(int appointmentId) throws Exception {
        String sql = "SELECT TOP 5 CONVERT(VARCHAR(10), previousWs.Work_Date, 103) AS VisitDate, " +
                "m.Clinical_Diagnosis FROM Appointment currentAppt " +
                "JOIN Work_Schedule currentWs ON currentWs.Schedule_ID = currentAppt.Schedule_ID " +
                "JOIN Appointment previousAppt ON previousAppt.Patient_ID = currentAppt.Patient_ID " +
                "JOIN Work_Schedule previousWs ON previousWs.Schedule_ID = previousAppt.Schedule_ID " +
                "JOIN Medical_Record m ON m.Appointment_ID = previousAppt.Appointment_ID " +
                "WHERE currentAppt.Appointment_ID = ? AND previousAppt.Appointment_ID <> ? " +
                "AND (previousWs.Work_Date < currentWs.Work_Date OR " +
                "(previousWs.Work_Date = currentWs.Work_Date AND previousWs.Start_Time < currentWs.Start_Time)) " +
                "AND previousAppt.Status = 'Completed' " +
                "AND NULLIF(LTRIM(RTRIM(m.Clinical_Diagnosis)), '') IS NOT NULL " +
                "ORDER BY previousWs.Work_Date DESC, previousWs.Start_Time DESC, m.Record_ID DESC";
        List<String> lines = new ArrayList<>();
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, appointmentId);
            ps.setInt(2, appointmentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) lines.add(rs.getString("VisitDate") + ": " + rs.getString("Clinical_Diagnosis"));
            }
        }
        return String.join("\n", lines);
    }

    public void saveExamination(int appointmentId, int doctorId, Map<String, String> values,
                                Integer surgeryServiceId, String surgeryNotes) throws Exception {
        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            conn.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE);
            try {
                int recordId = lockedRecordId(conn, appointmentId, doctorId);
                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE Medical_Record SET Clinical_Diagnosis = ?, examination_result = ?, " +
                        "conclusion = ? WHERE Record_ID = ?")) {
                    ps.setNString(1, values.get("clinicalDiagnosis"));
                    ps.setNString(2, values.get("examinationResult"));
                    ps.setNString(3, values.get("conclusion"));
                    ps.setInt(4, recordId);
                    if (ps.executeUpdate() != 1) throw new IllegalStateException("Không tìm thấy bệnh án.");
                }

                StringBuilder update = new StringBuilder("UPDATE Examination_Detail SET ");
                StringBuilder insert = new StringBuilder("INSERT INTO Examination_Detail (Record_ID");
                StringBuilder placeholders = new StringBuilder(" VALUES (?");
                for (int i = 0; i < EXAM_COLUMNS.length; i++) {
                    if (i > 0) update.append(", ");
                    update.append(EXAM_COLUMNS[i]).append(" = ?");
                    insert.append(", ").append(EXAM_COLUMNS[i]);
                    placeholders.append(", ?");
                }
                update.append(" WHERE Record_ID = ?");
                insert.append(")").append(placeholders).append(")");
                int updated;
                try (PreparedStatement ps = conn.prepareStatement(update.toString())) {
                    setExamFields(ps, values, 1);
                    ps.setInt(EXAM_KEYS.length + 1, recordId);
                    updated = ps.executeUpdate();
                }
                if (updated == 0) {
                    try (PreparedStatement ps = conn.prepareStatement(insert.toString())) {
                        ps.setInt(1, recordId);
                        setExamFields(ps, values, 2);
                        ps.executeUpdate();
                    }
                }
                if (surgeryServiceId != null) {
                    saveSurgeryReferral(conn, recordId, surgeryServiceId, surgeryNotes);
                }
                conn.commit();
            } catch (Exception error) {
                conn.rollback();
                throw error;
            }
        }
    }

    private void saveSurgeryReferral(Connection conn, int recordId, int serviceId, String notes) throws Exception {
        BigDecimal price;
        String serviceCode;
        String serviceSql = "SELECT Price, Service_Code FROM Service_Catalog WHERE Service_ID = ? " +
                "AND (Service_Code IN ('LS-03', 'TT-05') OR Service_Code LIKE 'PT-%')";
        try (PreparedStatement ps = conn.prepareStatement(serviceSql)) {
            ps.setInt(1, serviceId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) throw new IllegalArgumentException("Dịch vụ phẫu thuật không hợp lệ.");
                price = rs.getBigDecimal(1);
                serviceCode = rs.getString(2);
            }
        }
        String existingSql = "SELECT TOP 1 Order_ID, Status FROM Procedure_Order WITH (UPDLOCK, HOLDLOCK) " +
                "WHERE Record_ID = ? AND Referral_Notes IS NOT NULL ORDER BY Order_ID DESC";
        try (PreparedStatement ps = conn.prepareStatement(existingSql)) {
            ps.setInt(1, recordId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int orderId = rs.getInt("Order_ID");
                    if (!"Pending".equals(rs.getString("Status"))) {
                        throw new IllegalStateException("Chỉ định đã được bác sĩ thủ thuật tiếp nhận; không thể sửa từ phiếu khám.");
                    }
                    try (PreparedStatement paid = conn.prepareStatement(
                            "SELECT Status FROM Procedure_Payment_Request WITH (UPDLOCK, HOLDLOCK) WHERE Order_ID = ?")) {
                        paid.setInt(1, orderId);
                        try (ResultSet payment = paid.executeQuery()) {
                            if (payment.next() && "Paid".equals(payment.getString(1))) {
                                throw new IllegalStateException("Chỉ định đã thanh toán; không thể đổi dịch vụ hoặc giá.");
                            }
                        }
                    }
                    try (PreparedStatement update = conn.prepareStatement(
                            "UPDATE Procedure_Order SET Service_ID = ?, Actual_Price = ?, Referral_Notes = ? WHERE Order_ID = ?")) {
                        update.setInt(1, serviceId);
                        update.setBigDecimal(2, price);
                        update.setNString(3, notes);
                        update.setInt(4, orderId);
                        update.executeUpdate();
                    }
                    syncSurgeryPayment(conn, orderId, recordId, serviceCode, price);
                    return;
                }
            }
        }
        try (PreparedStatement insert = conn.prepareStatement(
                "INSERT INTO Procedure_Order (Record_ID, Service_ID, Specialist_Employee_ID, Status, Actual_Price, Referral_Notes) " +
                "VALUES (?, ?, NULL, 'Pending', ?, ?)", Statement.RETURN_GENERATED_KEYS)) {
            insert.setInt(1, recordId);
            insert.setInt(2, serviceId);
            insert.setBigDecimal(3, price);
            insert.setNString(4, notes);
            insert.executeUpdate();
            try (ResultSet keys = insert.getGeneratedKeys()) {
                if (!keys.next()) throw new IllegalStateException("Không lấy được mã chỉ định phẫu thuật.");
                syncSurgeryPayment(conn, keys.getInt(1), recordId, serviceCode, price);
            }
        }
    }

    private void syncSurgeryPayment(Connection conn, int orderId, int recordId,
                                    String serviceCode, BigDecimal price) throws Exception {
        if (serviceCode == null || !serviceCode.startsWith("PT-")) {
            try (PreparedStatement ps = conn.prepareStatement(
                    "DELETE FROM Procedure_Payment_Request WHERE Order_ID = ? AND Status = 'Pending'")) {
                ps.setInt(1, orderId);
                ps.executeUpdate();
            }
            return;
        }
        if (price == null || price.signum() <= 0) {
            throw new IllegalStateException("Giá phẫu thuật phải lớn hơn 0.");
        }
        BigDecimal credit = BigDecimal.ZERO;
        String creditSql = "SELECT i.Deposit_Amount, COALESCE(SUM(CASE WHEN t.Gateway_Status = 'Success' "
                + "THEN t.Amount ELSE 0 END), 0) AS Paid_Amount "
                + "FROM Medical_Record mr JOIN Master_Invoice i ON i.Appointment_ID = mr.Appointment_ID "
                + "LEFT JOIN Payment_Transaction t ON t.Invoice_ID = i.Invoice_ID "
                + "WHERE mr.Record_ID = ? GROUP BY i.Deposit_Amount";
        try (PreparedStatement ps = conn.prepareStatement(creditSql)) {
            ps.setInt(1, recordId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    BigDecimal deposit = rs.getBigDecimal("Deposit_Amount");
                    BigDecimal paid = rs.getBigDecimal("Paid_Amount");
                    if (deposit != null && paid != null && deposit.signum() > 0 && paid.signum() > 0) {
                        credit = deposit.min(paid).min(price);
                    }
                }
            }
        }
        BigDecimal amount = price.subtract(credit);
        try (PreparedStatement ps = conn.prepareStatement(
                "UPDATE Procedure_Payment_Request SET Amount = ?, Credit_Amount = ? "
                + "WHERE Order_ID = ? AND Status = 'Pending'")) {
            ps.setBigDecimal(1, amount);
            ps.setBigDecimal(2, credit);
            ps.setInt(3, orderId);
            if (ps.executeUpdate() == 1) return;
        }
        try (PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO Procedure_Payment_Request (Order_ID, Amount, Credit_Amount) VALUES (?, ?, ?)")) {
            ps.setInt(1, orderId);
            ps.setBigDecimal(2, amount);
            ps.setBigDecimal(3, credit);
            ps.executeUpdate();
        }
    }

    public PrescriptionSnapshot loadPrescription(int appointmentId) throws Exception {
        Map<String, String> values = new HashMap<>();
        List<Map<String, String>> medicines = new ArrayList<>();
        boolean hasPrescription = false;
        boolean hasGlasses = false;
        try (Connection conn = DBContext.getConnection()) {
            int recordId = findRecordId(conn, appointmentId);
            if (recordId == 0) return new PrescriptionSnapshot(values, medicines, false, false);
            int prescriptionId = 0;
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT TOP 1 Prescription_ID, Doctor_Notes, Follow_Up_Date " +
                    "FROM Prescription WHERE Record_ID = ? ORDER BY Prescription_ID DESC")) {
                ps.setInt(1, recordId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        hasPrescription = true;
                        prescriptionId = rs.getInt("Prescription_ID");
                        put(values, "doctorNotes", rs.getString("Doctor_Notes"));
                        put(values, "followUpDate", rs.getString("Follow_Up_Date"));
                    }
                }
            }
            if (prescriptionId == 0) return new PrescriptionSnapshot(values, medicines, false, false);
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT Medicine_Name, Strength, Dosage, Frequency, Duration, Quantity, Unit, " +
                    "Additional_Instruction, Dosage_Instruction, Morning_Dose, Afternoon_Dose, Evening_Dose " +
                    "FROM Prescription_Detail " +
                    "WHERE Prescription_ID = ? ORDER BY Detail_ID")) {
                ps.setInt(1, prescriptionId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, String> row = new HashMap<>();
                        put(row, "medicineName", rs.getString("Medicine_Name"));
                        put(row, "strength", rs.getString("Strength"));
                        for (String[] session : new String[][]{{"morning", "Morning_Dose"},
                                {"afternoon", "Afternoon_Dose"}, {"evening", "Evening_Dose"}}) {
                            String dose = rs.getString(session[1]);
                            put(row, session[0], dose == null ? "" : "true");
                            put(row, session[0] + "Dose", dose);
                        }
                        if (row.get("morning").isBlank() && row.get("afternoon").isBlank()
                                && row.get("evening").isBlank()) {
                            String legacy = rs.getString("Dosage_Instruction");
                            if (legacy == null || legacy.isBlank()) {
                                legacy = String.join("; ", java.util.stream.Stream.of(
                                        rs.getString("Dosage"), rs.getString("Frequency"))
                                        .filter(part -> part != null && !part.isBlank()).toList());
                            }
                            put(row, "legacySchedule", legacy);
                        }
                        put(row, "duration", rs.getString("Duration"));
                        put(row, "quantity", rs.getString("Quantity"));
                        put(row, "unit", rs.getString("Unit"));
                        put(row, "instructions", rs.getString("Additional_Instruction"));
                        medicines.add(row);
                    }
                }
            }
            StringBuilder glassSelect = new StringBuilder("SELECT ");
            for (int i = 0; i < GLASSES_COLUMNS.length; i++) {
                if (i > 0) glassSelect.append(", ");
                glassSelect.append(GLASSES_COLUMNS[i]);
            }
            glassSelect.append(" FROM Eyeglass_Prescription WHERE Prescription_ID = ?");
            try (PreparedStatement ps = conn.prepareStatement(glassSelect.toString())) {
                ps.setInt(1, prescriptionId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        hasGlasses = true;
                        for (int i = 0; i < GLASSES_KEYS.length; i++) {
                            put(values, GLASSES_KEYS[i], rs.getString(GLASSES_COLUMNS[i]));
                        }
                    }
                }
            }
        }
        return new PrescriptionSnapshot(values, medicines, hasPrescription && !medicines.isEmpty(), hasGlasses);
    }

    public void savePrescription(int appointmentId, int doctorId, Map<String, String> values,
                                 List<Map<String, String>> medicines, boolean includeMedication,
                                 boolean includeGlasses) throws Exception {
        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            conn.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE);
            try {
                int recordId = lockedRecordId(conn, appointmentId, doctorId);
                int prescriptionId = 0;
                try (PreparedStatement ps = conn.prepareStatement(
                        "SELECT TOP 1 Prescription_ID FROM Prescription WITH (UPDLOCK, HOLDLOCK) " +
                        "WHERE Record_ID = ? ORDER BY Prescription_ID DESC")) {
                    ps.setInt(1, recordId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) prescriptionId = rs.getInt(1);
                    }
                }
                if (prescriptionId == 0) {
                    try (PreparedStatement ps = conn.prepareStatement(
                            "INSERT INTO Prescription (Record_ID, Doctor_Notes, Follow_Up_Date) VALUES (?, ?, ?)",
                            Statement.RETURN_GENERATED_KEYS)) {
                        ps.setInt(1, recordId);
                        ps.setNString(2, blankToNull(values.get("doctorNotes")));
                        setDate(ps, 3, values.get("followUpDate"));
                        ps.executeUpdate();
                        try (ResultSet keys = ps.getGeneratedKeys()) {
                            if (!keys.next()) throw new IllegalStateException("Không tạo được đơn.");
                            prescriptionId = keys.getInt(1);
                        }
                    }
                } else {
                    try (PreparedStatement ps = conn.prepareStatement(
                            "UPDATE Prescription SET Doctor_Notes = ?, Follow_Up_Date = ? WHERE Prescription_ID = ?")) {
                        ps.setNString(1, blankToNull(values.get("doctorNotes")));
                        setDate(ps, 2, values.get("followUpDate"));
                        ps.setInt(3, prescriptionId);
                        ps.executeUpdate();
                    }
                }

                try (PreparedStatement ps = conn.prepareStatement(
                        "DELETE FROM Prescription_Detail WHERE Prescription_ID = ?")) {
                    ps.setInt(1, prescriptionId);
                    ps.executeUpdate();
                }
                if (includeMedication) {
                    String sql = "INSERT INTO Prescription_Detail " +
                            "(Prescription_ID, Medicine_Name, Quantity, Dosage_Instruction, Strength, " +
                            "Dosage, Frequency, Duration, Unit, Additional_Instruction, " +
                            "Morning_Dose, Afternoon_Dose, Evening_Dose, Is_Custom_Medicine) " +
                            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                    try (PreparedStatement ps = conn.prepareStatement(sql)) {
                        for (Map<String, String> row : medicines) {
                            List<String> sessions = new ArrayList<>();
                            List<String> parts = new ArrayList<>();
                            for (String[] slot : new String[][]{{"morning", "morningDose", "Sáng"},
                                    {"afternoon", "afternoonDose", "Chiều"}, {"evening", "eveningDose", "Tối"}}) {
                                if ("true".equals(row.get(slot[0]))) {
                                    sessions.add(slot[2]);
                                    parts.add(slot[2] + ": " + row.get(slot[1]));
                                }
                            }
                            String duration = blankToNull(row.get("duration"));
                            if (duration != null) parts.add("Thời gian: " + duration);
                            String extra = blankToNull(row.get("instructions"));
                            if (extra != null) parts.add(extra);
                            ps.setInt(1, prescriptionId);
                            ps.setNString(2, row.get("medicineName"));
                            ps.setInt(3, Integer.parseInt(row.get("quantity")));
                            ps.setNString(4, String.join("; ", parts));
                            ps.setNString(5, blankToNull(row.get("strength")));
                            ps.setNull(6, Types.NVARCHAR);
                            ps.setNString(7, String.join(", ", sessions));
                            ps.setNString(8, duration);
                            ps.setNString(9, row.get("unit"));
                            ps.setNString(10, extra);
                            ps.setNString(11, "true".equals(row.get("morning")) ? row.get("morningDose") : null);
                            ps.setNString(12, "true".equals(row.get("afternoon")) ? row.get("afternoonDose") : null);
                            ps.setNString(13, "true".equals(row.get("evening")) ? row.get("eveningDose") : null);
                            ps.setBoolean(14, "true".equals(row.get("customMedicine")));
                            ps.addBatch();
                        }
                        ps.executeBatch();
                    }
                }

                if (includeGlasses) {
                    StringBuilder update = new StringBuilder("UPDATE Eyeglass_Prescription SET ");
                    StringBuilder insert = new StringBuilder("INSERT INTO Eyeglass_Prescription (Prescription_ID");
                    StringBuilder placeholders = new StringBuilder(" VALUES (?");
                    for (int i = 0; i < GLASSES_COLUMNS.length; i++) {
                        if (i > 0) update.append(", ");
                        update.append(GLASSES_COLUMNS[i]).append(" = ?");
                        insert.append(", ").append(GLASSES_COLUMNS[i]);
                        placeholders.append(", ?");
                    }
                    update.append(" WHERE Prescription_ID = ?");
                    insert.append(")").append(placeholders).append(")");
                    int updated;
                    try (PreparedStatement ps = conn.prepareStatement(update.toString())) {
                        setGlassesFields(ps, values, 1);
                        ps.setInt(GLASSES_KEYS.length + 1, prescriptionId);
                        updated = ps.executeUpdate();
                    }
                    if (updated == 0) {
                        try (PreparedStatement ps = conn.prepareStatement(insert.toString())) {
                            ps.setInt(1, prescriptionId);
                            setGlassesFields(ps, values, 2);
                            ps.executeUpdate();
                        }
                    }
                } else {
                    try (PreparedStatement ps = conn.prepareStatement(
                            "DELETE FROM Eyeglass_Prescription WHERE Prescription_ID = ?")) {
                        ps.setInt(1, prescriptionId);
                        ps.executeUpdate();
                    }
                }
                conn.commit();
            } catch (Exception error) {
                conn.rollback();
                throw error;
            }
        }
    }

    private int lockedRecordId(Connection conn, int appointmentId, int doctorId) throws Exception {
        String authorized = "SELECT a.Appointment_ID FROM Appointment a WITH (UPDLOCK, HOLDLOCK) " +
                "JOIN Work_Schedule ws ON ws.Schedule_ID = a.Schedule_ID " +
                "WHERE a.Appointment_ID = ? AND ws.Doctor_Employee_ID = ? " +
                "AND a.Status = 'In_Progress' AND a.checkin_time IS NOT NULL";
        try (PreparedStatement ps = conn.prepareStatement(authorized)) {
            ps.setInt(1, appointmentId);
            ps.setInt(2, doctorId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) throw new IllegalStateException("Ca khám không còn được phép chỉnh sửa.");
            }
        }
        int recordId = findRecordId(conn, appointmentId);
        if (recordId != 0) return recordId;
        try (PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO Medical_Record (Appointment_ID, Doctor_Employee_ID, Created_At) " +
                "VALUES (?, ?, SYSUTCDATETIME())", Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, appointmentId);
            ps.setInt(2, doctorId);
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (!keys.next()) throw new IllegalStateException("Không tạo được bệnh án.");
                return keys.getInt(1);
            }
        }
    }

    private int findRecordId(Connection conn, int appointmentId) throws Exception {
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT Record_ID FROM Medical_Record WITH (UPDLOCK, HOLDLOCK) WHERE Appointment_ID = ?")) {
            ps.setInt(1, appointmentId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    private void setExamFields(PreparedStatement ps, Map<String, String> values, int first) throws Exception {
        for (int i = 0; i < EXAM_KEYS.length; i++) {
            String value = blankToNull(values.get(EXAM_KEYS[i]));
            int index = first + i;
            if (i == 6 || i == 7) setDecimal(ps, index, value);
            else if (i == 10) setDate(ps, index, value);
            else ps.setNString(index, value);
        }
    }

    private void setGlassesFields(PreparedStatement ps, Map<String, String> values, int first) throws Exception {
        for (int i = 0; i < GLASSES_KEYS.length; i++) {
            String value = blankToNull(values.get(GLASSES_KEYS[i]));
            int index = first + i;
            if (i == 2 || i == 6) {
                if (value == null) ps.setNull(index, Types.SMALLINT);
                else ps.setInt(index, Integer.parseInt(value));
            } else if (i == 9) {
                ps.setString(index, value);
            } else if (i == 10) {
                ps.setNString(index, value);
            } else {
                setDecimal(ps, index, value);
            }
        }
    }

    private void setDecimal(PreparedStatement ps, int index, String value) throws Exception {
        if (value == null) ps.setNull(index, Types.DECIMAL);
        else ps.setBigDecimal(index, new BigDecimal(value));
    }

    private void setDate(PreparedStatement ps, int index, String value) throws Exception {
        if (value == null || value.isBlank()) ps.setNull(index, Types.DATE);
        else ps.setDate(index, Date.valueOf(value));
    }

    private void put(Map<String, String> map, String key, String value) {
        map.put(key, value == null ? "" : value);
    }

    private String blankToNull(String value) {
        return value == null || value.isBlank() ? null : value;
    }

    public static final class PrescriptionSnapshot {
        private final Map<String, String> values;
        private final List<Map<String, String>> medicines;
        private final boolean includeMedication;
        private final boolean includeGlasses;

        public PrescriptionSnapshot(Map<String, String> values, List<Map<String, String>> medicines,
                                    boolean includeMedication, boolean includeGlasses) {
            this.values = values;
            this.medicines = medicines;
            this.includeMedication = includeMedication;
            this.includeGlasses = includeGlasses;
        }

        public Map<String, String> getValues() { return values; }
        public List<Map<String, String>> getMedicines() { return medicines; }
        public boolean isIncludeMedication() { return includeMedication; }
        public boolean isIncludeGlasses() { return includeGlasses; }
    }
}
