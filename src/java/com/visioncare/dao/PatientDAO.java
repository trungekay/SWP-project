package com.visioncare.dao;

import com.visioncare.model.Patient;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class PatientDAO {

    private final SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");
    private final SimpleDateFormat dateTimeFormat = new SimpleDateFormat("HH:mm • dd/MM/yyyy");

    /**
     * Get paginated patient list with filters and sorting
     */
    public List<Patient> getPatients(String keyword, String accountType, String sortBy, int page, int pageSize) {
        List<Patient> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT p.Patient_ID, p.Account_ID, p.Full_Name, p.Phone, p.DOB, p.Address, " +
            "       acc.Email, " +
            "       (SELECT COUNT(1) FROM Appointment a WHERE a.Patient_ID = p.Patient_ID) AS Total_Appointments, " +
            "       (SELECT MAX(ws.Work_Date) FROM Appointment a JOIN Work_Schedule ws ON a.Schedule_ID = ws.Schedule_ID WHERE a.Patient_ID = p.Patient_ID) AS Latest_Date " +
            "FROM Patient p " +
            "LEFT JOIN Account acc ON p.Account_ID = acc.Account_ID " +
            "WHERE 1=1 "
        );

        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            String kw = keyword.trim();
            String cleanNumeric = kw.replaceAll("[^0-9]", "");
            int idVal = -1;
            if (!cleanNumeric.isEmpty()) {
                try {
                    idVal = Integer.parseInt(cleanNumeric);
                } catch (NumberFormatException ignored) {}
            }

            if (idVal > 0) {
                sql.append("AND (p.Full_Name LIKE ? OR p.Phone LIKE ? OR p.Patient_ID = ?) ");
                params.add("%" + kw + "%");
                params.add("%" + kw + "%");
                params.add(idVal);
            } else {
                sql.append("AND (p.Full_Name LIKE ? OR p.Phone LIKE ?) ");
                params.add("%" + kw + "%");
                params.add("%" + kw + "%");
            }
        }

        if (accountType != null && !accountType.trim().isEmpty()) {
            if ("with_account".equalsIgnoreCase(accountType.trim())) {
                sql.append("AND p.Account_ID IS NOT NULL AND p.Account_ID > 0 ");
            } else if ("no_account".equalsIgnoreCase(accountType.trim())) {
                sql.append("AND (p.Account_ID IS NULL OR p.Account_ID <= 0) ");
            }
        }

        // Sorting
        if ("name_asc".equalsIgnoreCase(sortBy)) {
            sql.append("ORDER BY p.Full_Name ASC ");
        } else if ("name_desc".equalsIgnoreCase(sortBy)) {
            sql.append("ORDER BY p.Full_Name DESC ");
        } else if ("appointments_desc".equalsIgnoreCase(sortBy)) {
            sql.append("ORDER BY Total_Appointments DESC, p.Patient_ID DESC ");
        } else {
            sql.append("ORDER BY p.Patient_ID DESC ");
        }

        // Pagination
        if (page < 1) page = 1;
        if (pageSize < 1) pageSize = 10;
        int offset = (page - 1) * pageSize;

        sql.append("OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        params.add(offset);
        params.add(pageSize);

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Patient p = new Patient();
                    p.setPatientId(rs.getInt("Patient_ID"));
                    int accId = rs.getInt("Account_ID");
                    p.setAccountId(rs.wasNull() ? null : accId);
                    p.setFullName(rs.getString("Full_Name"));
                    p.setPhone(rs.getString("Phone"));
                    p.setDob(rs.getDate("DOB"));
                    p.setAddress(rs.getString("Address"));
                    p.setEmail(rs.getString("Email"));
                    p.setTotalAppointments(rs.getInt("Total_Appointments"));

                    Date latestDate = rs.getDate("Latest_Date");
                    p.setLatestAppointmentDate(latestDate != null ? dateFormat.format(latestDate) : "Chưa khám");

                    list.add(p);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Count matching patients for pagination
     */
    public int countPatients(String keyword, String accountType) {
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(1) FROM Patient p WHERE 1=1 "
        );
        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            String kw = keyword.trim();
            String cleanNumeric = kw.replaceAll("[^0-9]", "");
            int idVal = -1;
            if (!cleanNumeric.isEmpty()) {
                try {
                    idVal = Integer.parseInt(cleanNumeric);
                } catch (NumberFormatException ignored) {}
            }

            if (idVal > 0) {
                sql.append("AND (p.Full_Name LIKE ? OR p.Phone LIKE ? OR p.Patient_ID = ?) ");
                params.add("%" + kw + "%");
                params.add("%" + kw + "%");
                params.add(idVal);
            } else {
                sql.append("AND (p.Full_Name LIKE ? OR p.Phone LIKE ?) ");
                params.add("%" + kw + "%");
                params.add("%" + kw + "%");
            }
        }

        if (accountType != null && !accountType.trim().isEmpty()) {
            if ("with_account".equalsIgnoreCase(accountType.trim())) {
                sql.append("AND p.Account_ID IS NOT NULL AND p.Account_ID > 0 ");
            } else if ("no_account".equalsIgnoreCase(accountType.trim())) {
                sql.append("AND (p.Account_ID IS NULL OR p.Account_ID <= 0) ");
            }
        }

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Get aggregate statistics for patient dashboard cards
     */
    public Map<String, Integer> getPatientStats() {
        Map<String, Integer> stats = new HashMap<>();
        stats.put("total", 0);
        stats.put("withAccount", 0);
        stats.put("noAccount", 0);
        stats.put("todayAppointments", 0);

        String sql =
            "SELECT " +
            "  (SELECT COUNT(1) FROM Patient) AS Total_Patients, " +
            "  (SELECT COUNT(1) FROM Patient WHERE Account_ID IS NOT NULL AND Account_ID > 0) AS With_Account, " +
            "  (SELECT COUNT(1) FROM Patient WHERE Account_ID IS NULL OR Account_ID <= 0) AS No_Account, " +
            "  (SELECT COUNT(DISTINCT a.Patient_ID) FROM Appointment a " +
            "   JOIN Work_Schedule ws ON a.Schedule_ID = ws.Schedule_ID " +
            "   WHERE ws.Work_Date = CAST(GETDATE() AS DATE) " +
            "     AND a.Status IN ('Confirmed', 'In_Progress', 'Completed')) AS Today_Appointments";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                stats.put("total", rs.getInt("Total_Patients"));
                stats.put("withAccount", rs.getInt("With_Account"));
                stats.put("noAccount", rs.getInt("No_Account"));
                stats.put("todayAppointments", rs.getInt("Today_Appointments"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return stats;
    }

    /**
     * Get patient by ID
     */
    public Patient getPatientById(int patientId) {
        String sql =
            "SELECT p.Patient_ID, p.Account_ID, p.Full_Name, p.Phone, p.DOB, p.Address, " +
            "       acc.Email, " +
            "       (SELECT COUNT(1) FROM Appointment a WHERE a.Patient_ID = p.Patient_ID) AS Total_Appointments, " +
            "       (SELECT MAX(ws.Work_Date) FROM Appointment a JOIN Work_Schedule ws ON a.Schedule_ID = ws.Schedule_ID WHERE a.Patient_ID = p.Patient_ID) AS Latest_Date " +
            "FROM Patient p " +
            "LEFT JOIN Account acc ON p.Account_ID = acc.Account_ID " +
            "WHERE p.Patient_ID = ?";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, patientId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Patient p = new Patient();
                    p.setPatientId(rs.getInt("Patient_ID"));
                    int accId = rs.getInt("Account_ID");
                    p.setAccountId(rs.wasNull() ? null : accId);
                    p.setFullName(rs.getString("Full_Name"));
                    p.setPhone(rs.getString("Phone"));
                    p.setDob(rs.getDate("DOB"));
                    p.setAddress(rs.getString("Address"));
                    p.setEmail(rs.getString("Email"));
                    p.setTotalAppointments(rs.getInt("Total_Appointments"));

                    Date latestDate = rs.getDate("Latest_Date");
                    p.setLatestAppointmentDate(latestDate != null ? dateFormat.format(latestDate) : "Chưa khám");
                    return p;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Check if phone exists (excluding current patient id when updating)
     */
    public boolean isPhoneExists(String phone, int excludePatientId) {
        if (phone == null || phone.trim().isEmpty()) return false;
        String sql = "SELECT 1 FROM Patient WHERE Phone = ? AND Patient_ID <> ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, phone.trim());
            ps.setInt(2, excludePatientId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Add new patient at counter
     */
    public int addPatient(Patient p) {
        String sql = "INSERT INTO Patient (Full_Name, Phone, DOB, Address) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, p.getFullName().trim());
            ps.setString(2, p.getPhone().trim());
            if (p.getDob() != null) {
                ps.setDate(3, p.getDob());
            } else {
                ps.setNull(3, java.sql.Types.DATE);
            }
            ps.setString(4, p.getAddress() != null ? p.getAddress().trim() : null);

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    /**
     * Update patient info
     */
    public boolean updatePatient(Patient p) {
        String sql = "UPDATE Patient SET Full_Name = ?, Phone = ?, DOB = ?, Address = ? WHERE Patient_ID = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, p.getFullName().trim());
            ps.setString(2, p.getPhone().trim());
            if (p.getDob() != null) {
                ps.setDate(3, p.getDob());
            } else {
                ps.setNull(3, java.sql.Types.DATE);
            }
            ps.setString(4, p.getAddress() != null ? p.getAddress().trim() : null);
            ps.setInt(5, p.getPatientId());

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Get all appointments of a patient for history drawer/modal
     */
    public List<Map<String, Object>> getPatientAppointmentHistory(int patientId) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql =
            "SELECT a.Appointment_ID, a.Status AS Appt_Status, a.created_at, " +
            "       ws.Work_Date, ws.Slot, " +
            "       CONVERT(VARCHAR(5), ws.Start_Time, 108) AS Start_Time_Str, " +
            "       doc.Full_Name AS Doctor_Name, doc.Specialty, " +
            "       cs.Name AS Service_Name, " +
            "       mi.Invoice_ID, mi.Total_Amount, mi.Status AS Invoice_Status, " +
            "       mr.Clinical_Diagnosis " +
            "FROM Appointment a " +
            "JOIN Work_Schedule ws ON a.Schedule_ID = ws.Schedule_ID " +
            "LEFT JOIN Employee_Profile doc ON ws.Doctor_Employee_ID = doc.Employee_ID " +
            "LEFT JOIN Catalog_Service cs ON a.Service_ID = cs.Service_ID " +
            "LEFT JOIN Master_Invoice mi ON a.Appointment_ID = mi.Appointment_ID " +
            "LEFT JOIN Medical_Record mr ON a.Appointment_ID = mr.Appointment_ID " +
            "WHERE a.Patient_ID = ? " +
            "ORDER BY ws.Work_Date DESC, ws.Start_Time DESC, a.Appointment_ID DESC";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, patientId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    int apptId = rs.getInt("Appointment_ID");
                    map.put("appointmentId", apptId);
                    map.put("formattedId", "#APT-" + apptId);
                    map.put("status", rs.getString("Appt_Status"));

                    Date workDate = rs.getDate("Work_Date");
                    map.put("workDate", workDate != null ? dateFormat.format(workDate) : "");
                    map.put("slot", rs.getString("Slot"));
                    map.put("time", rs.getString("Start_Time_Str"));

                    map.put("doctorName", rs.getString("Doctor_Name") != null ? rs.getString("Doctor_Name") : "Chưa chỉ định");
                    map.put("specialty", rs.getString("Specialty") != null ? rs.getString("Specialty") : "");
                    map.put("serviceName", rs.getString("Service_Name") != null ? rs.getString("Service_Name") : "Khám mắt tổng quát");

                    map.put("invoiceId", rs.getInt("Invoice_ID"));
                    long totalAmt = rs.getLong("Total_Amount");
                    map.put("totalAmount", totalAmt);
                    map.put("formattedTotal", String.format("%,d đ", totalAmt));
                    map.put("invoiceStatus", rs.getString("Invoice_Status"));

                    map.put("diagnosis", rs.getString("Clinical_Diagnosis") != null ? rs.getString("Clinical_Diagnosis") : "");

                    Timestamp createdAt = rs.getTimestamp("created_at");
                    map.put("createdAt", createdAt != null ? dateTimeFormat.format(createdAt) : "");

                    list.add(map);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}
