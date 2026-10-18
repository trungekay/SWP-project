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
                if (!rs.next()) return values;
                put(values, "clinicalDiagnosis", rs.getString("Clinical_Diagnosis"));
                put(values, "examinationResult", rs.getString("examination_result"));
                put(values, "conclusion", rs.getString("conclusion"));
                for (int i = 0; i < EXAM_KEYS.length; i++) {
                    put(values, EXAM_KEYS[i], rs.getString(EXAM_COLUMNS[i]));
                }
            }
        }
        return values;
    }

    public void saveExamination(int appointmentId, int doctorId, Map<String, String> values) throws Exception {
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
                conn.commit();
            } catch (Exception error) {
                conn.rollback();
                throw error;
            }
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
                    "Additional_Instruction, Dosage_Instruction FROM Prescription_Detail " +
                    "WHERE Prescription_ID = ? ORDER BY Detail_ID")) {
                ps.setInt(1, prescriptionId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, String> row = new HashMap<>();
                        put(row, "medicineName", rs.getString("Medicine_Name"));
                        put(row, "strength", rs.getString("Strength"));
                        String dosage = rs.getString("Dosage");
                        put(row, "dosage", dosage == null ? rs.getString("Dosage_Instruction") : dosage);
                        put(row, "frequency", rs.getString("Frequency"));
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
                            "Dosage, Frequency, Duration, Unit, Additional_Instruction) " +
                            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                    try (PreparedStatement ps = conn.prepareStatement(sql)) {
                        for (Map<String, String> row : medicines) {
                            List<String> parts = new ArrayList<>();
                            for (String key : new String[]{"dosage", "frequency", "duration", "instructions"}) {
                                String part = row.get(key);
                                if (part != null && !part.isBlank()) parts.add(part);
                            }
                            String instruction = String.join("; ", parts);
                            ps.setInt(1, prescriptionId);
                            ps.setNString(2, row.get("medicineName"));
                            ps.setInt(3, Integer.parseInt(row.get("quantity")));
                            ps.setNString(4, instruction);
                            ps.setNString(5, blankToNull(row.get("strength")));
                            ps.setNString(6, row.get("dosage"));
                            ps.setNString(7, row.get("frequency"));
                            ps.setNString(8, blankToNull(row.get("duration")));
                            ps.setNString(9, row.get("unit"));
                            ps.setNString(10, blankToNull(row.get("instructions")));
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
