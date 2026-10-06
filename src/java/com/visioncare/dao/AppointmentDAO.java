package com.visioncare.dao;
import com.visioncare.model.Appointment;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AppointmentDAO {

    public int create(Appointment a) throws Exception {
        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);
            int patientId = getOrCreatePatient(conn, a);
            int scheduleId = getOrCreateSchedule(conn, a);
            String sqlAppt = "INSERT INTO Appointment (Patient_ID, Schedule_ID, Status, created_at) VALUES (?, ?, ?, SYSUTCDATETIME())";
            int appointmentId = -1;
            try (PreparedStatement psAppt = conn.prepareStatement(sqlAppt, Statement.RETURN_GENERATED_KEYS)) {
                psAppt.setInt(1, patientId);
                psAppt.setInt(2, scheduleId);
                psAppt.setString(3, "Pending");
                psAppt.executeUpdate();
                try (ResultSet keys = psAppt.getGeneratedKeys()) {
                    if (keys.next()) {
                        appointmentId = keys.getInt(1);
                    }
                }
            }
            if (appointmentId > 0) {
                String sqlInvoice = "INSERT INTO Master_Invoice (Appointment_ID, Total_Amount, Balance_Due, Status) VALUES (?, 0, 0, 'Pending_Deposit')";
                try (PreparedStatement psInv = conn.prepareStatement(sqlInvoice)) {
                    psInv.setInt(1, appointmentId);
                    psInv.executeUpdate();
                }
                if (a.getReason() != null && !a.getReason().isEmpty()) {
                    String sqlRecord = "INSERT INTO Medical_Record (Appointment_ID, Doctor_Employee_ID, Clinical_Diagnosis) VALUES (?, ?, ?)";
                    try (PreparedStatement psRec = conn.prepareStatement(sqlRecord)) {
                        psRec.setInt(1, appointmentId);
                        psRec.setInt(2, a.getDoctorId()); 
                        psRec.setString(3, "Lý do khám: " + a.getReason());
                        psRec.executeUpdate();
                    }
                }
            }
            conn.commit();
            return appointmentId;
        } catch (Exception e) {
            if (conn != null) {
                conn.rollback();
            }
            e.printStackTrace();
            throw e;
        } finally {
            if (conn != null) {
                conn.setAutoCommit(true);
                conn.close();
            }
        }
    }
    private int getOrCreatePatient(Connection conn, Appointment a) throws SQLException {
        String sqlFind = "SELECT Patient_ID FROM Patient WHERE Phone = ?";
        try (PreparedStatement psFind = conn.prepareStatement(sqlFind)) {
            psFind.setString(1, a.getPhone());
            try (ResultSet rs = psFind.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("Patient_ID");
                }
            }
        }
        String sqlInsert = "INSERT INTO Patient (Account_ID, Full_Name, Phone, DOB) VALUES (?, ?, ?, ?)";
        try (PreparedStatement psIns = conn.prepareStatement(sqlInsert, Statement.RETURN_GENERATED_KEYS)) {
            if (a.getUserId() > 0) {
                psIns.setInt(1, a.getUserId());
            } else {
                psIns.setNull(1, Types.INTEGER);
            }
            psIns.setString(2, a.getPatientName());
            psIns.setString(3, a.getPhone());
            psIns.setDate(4, a.getDob());
            psIns.executeUpdate();
            try (ResultSet keys = psIns.getGeneratedKeys()) {
                if (keys.next()) {
                    return keys.getInt(1);
                }
            }
        }
        throw new SQLException("Cannot create patient");
    }
    private int getOrCreateSchedule(Connection conn, Appointment a) throws SQLException {
        String sqlFind = "SELECT Schedule_ID FROM Work_Schedule WHERE Doctor_Employee_ID = ? AND Work_Date = ? AND Start_Time = ?";
        try (PreparedStatement psFind = conn.prepareStatement(sqlFind)) {
            psFind.setInt(1, a.getDoctorId());
            psFind.setDate(2, a.getAppointmentDate());
            psFind.setString(3, a.getTimeSlot()); 
            try (ResultSet rs = psFind.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("Schedule_ID");
                }
            }
        }
        String sqlInsert = "INSERT INTO Work_Schedule (Doctor_Employee_ID, Work_Date, Start_Time, End_Time, Slot, Status) VALUES (?, ?, ?, ?, ?, 'Booked')";
        try (PreparedStatement psIns = conn.prepareStatement(sqlInsert, Statement.RETURN_GENERATED_KEYS)) {
            psIns.setInt(1, a.getDoctorId());
            psIns.setDate(2, a.getAppointmentDate());
            psIns.setString(3, a.getTimeSlot()); 
            String endTime = a.getTimeSlot().replace(":00", ":30");
            psIns.setString(4, endTime);
            psIns.setString(5, "Slot X");
            psIns.executeUpdate();
            try (ResultSet keys = psIns.getGeneratedKeys()) {
                if (keys.next()) {
                    return keys.getInt(1);
                }
            }
        }
        throw new SQLException("Cannot create schedule");
    }
    public List<Appointment> getByDoctorAndDate(int doctorId, Date date) throws Exception {
        List<Appointment> list = new ArrayList<>();
        String sql = "SELECT a.Appointment_ID, a.Status, p.Full_Name, p.Phone, p.DOB, ws.Start_Time, ws.Doctor_Employee_ID, p.Account_ID " +
                     "FROM Appointment a " +
                     "JOIN Patient p ON a.Patient_ID = p.Patient_ID " +
                     "JOIN Work_Schedule ws ON a.Schedule_ID = ws.Schedule_ID " +
                     "WHERE ws.Doctor_Employee_ID = ? AND ws.Work_Date = ? AND a.Status != 'Canceled' " +
                     "ORDER BY ws.Start_Time";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, doctorId);
            ps.setDate(2, date);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        }
        return list;
    }
    public List<Appointment> getByUserId(int userId) throws Exception {
        List<Appointment> list = new ArrayList<>();
        String sql = "SELECT a.Appointment_ID, a.Status, p.Full_Name, p.Phone, p.DOB, ws.Start_Time, ws.Doctor_Employee_ID, p.Account_ID, ws.Work_Date, e.Full_Name AS Doctor_Name " +
                     "FROM Appointment a " +
                     "JOIN Patient p ON a.Patient_ID = p.Patient_ID " +
                     "JOIN Work_Schedule ws ON a.Schedule_ID = ws.Schedule_ID " +
                     "LEFT JOIN Employee_Profile e ON ws.Doctor_Employee_ID = e.Employee_ID " +
                     "WHERE p.Account_ID = ? ORDER BY ws.Work_Date DESC, ws.Start_Time";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Appointment appt = mapRow(rs);
                    appt.setAppointmentDate(rs.getDate("Work_Date"));
                    list.add(appt);
                }
            }
        }
        return list;
    }
    public boolean isSlotBooked(int doctorId, Date date, String timeSlot) throws Exception {
        String sql = "SELECT COUNT(*) FROM Appointment a " +
                     "JOIN Work_Schedule ws ON a.Schedule_ID = ws.Schedule_ID " +
                     "WHERE ws.Doctor_Employee_ID = ? AND ws.Work_Date = ? AND ws.Start_Time = ? AND a.Status != 'Canceled'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, doctorId);
            ps.setDate(2, date);
            ps.setString(3, timeSlot);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        }
        return false;
    }
    private Appointment mapRow(ResultSet rs) throws SQLException {
        Appointment a = new Appointment();
        a.setId(rs.getInt("Appointment_ID"));
        a.setPatientName(rs.getString("Full_Name"));
        a.setPhone(rs.getString("Phone"));
        a.setDob(rs.getDate("DOB"));
        a.setDoctorId(rs.getInt("Doctor_Employee_ID"));
        a.setTimeSlot(rs.getString("Start_Time"));
        a.setStatus(rs.getString("Status"));
        try {
            a.setUserId(rs.getInt("Account_ID"));
        } catch (SQLException e) {
            a.setUserId(0);
        }
        try {
            a.setDoctorName(rs.getString("Doctor_Name"));
        } catch (SQLException e) {
            // Field not present in this query
        }
        return a;
    }
}
