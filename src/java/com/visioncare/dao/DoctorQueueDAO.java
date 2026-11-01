package com.visioncare.dao;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashSet;
import java.util.Set;

/** Status transition for a doctor's own checked-in appointment. */
public class DoctorQueueDAO {
    private static final String EXAMINATION_READY = "EXISTS (SELECT 1 FROM Medical_Record mr "
            + "JOIN Examination_Detail ed ON ed.Record_ID = mr.Record_ID "
            + "WHERE mr.Appointment_ID = a.Appointment_ID "
            + "AND NULLIF(LTRIM(RTRIM(mr.Clinical_Diagnosis)), '') IS NOT NULL "
            + "AND NULLIF(LTRIM(RTRIM(mr.examination_result)), '') IS NOT NULL "
            + "AND NULLIF(LTRIM(RTRIM(mr.conclusion)), '') IS NOT NULL) "
            + "AND NOT EXISTS (SELECT 1 FROM Procedure_Order po JOIN Medical_Record pm ON pm.Record_ID=po.Record_ID "
            + "WHERE pm.Appointment_ID=a.Appointment_ID AND po.Status NOT IN ('Completed','Cancelled'))";

    /** Appointments whose saved examination form has the required result and conclusion. */
    public Set<Integer> readyForCompletion(int doctorEmployeeId, Date clinicDate) throws Exception {
        Set<Integer> ready = new HashSet<>();
        String sql = "SELECT a.Appointment_ID FROM Appointment a "
                + "JOIN Work_Schedule ws ON a.Schedule_ID = ws.Schedule_ID "
                + "WHERE ws.Doctor_Employee_ID = ? AND ws.Work_Date = ? "
                + "AND a.Status = 'In_Progress' AND a.checkin_time IS NOT NULL AND " + EXAMINATION_READY;
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, doctorEmployeeId);
            ps.setDate(2, clinicDate);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) ready.add(rs.getInt(1));
            }
        }
        return ready;
    }

    /** The assigned doctor may cancel a waiting case or stop an active examination. */
    public boolean cancelExamination(int appointmentId, int doctorEmployeeId, String reason) throws Exception {
        if (reason == null || reason.trim().isEmpty() || reason.trim().length() > 500) return false;
        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            conn.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE);
            try {
                int scheduleId;
                String originalStatus;
                String assignedSql = "SELECT a.Status, a.checkin_time, ws.Schedule_ID "
                        + "FROM Appointment a WITH (UPDLOCK, HOLDLOCK) "
                        + "JOIN Work_Schedule ws WITH (UPDLOCK, HOLDLOCK) ON a.Schedule_ID = ws.Schedule_ID "
                        + "WHERE a.Appointment_ID = ? AND ws.Doctor_Employee_ID = ?";
                try (PreparedStatement ps = conn.prepareStatement(assignedSql)) {
                    ps.setInt(1, appointmentId);
                    ps.setInt(2, doctorEmployeeId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next() || rs.getTimestamp("checkin_time") == null) {
                            conn.rollback();
                            return false;
                        }
                        originalStatus = rs.getString("Status");
                        if (!"In_Progress".equals(originalStatus)
                                && !"Confirmed".equals(originalStatus)) {
                            conn.rollback();
                            return false;
                        }
                        scheduleId = rs.getInt("Schedule_ID");
                    }
                }

                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE Appointment SET Status = 'Canceled' "
                        + "WHERE Appointment_ID = ? AND Status = ? AND checkin_time IS NOT NULL")) {
                    ps.setInt(1, appointmentId);
                    ps.setString(2, originalStatus);
                    if (ps.executeUpdate() != 1) {
                        conn.rollback();
                        return false;
                    }
                }

                // A started examination has consumed its slot even when the doctor stops it.
                if ("Confirmed".equals(originalStatus)) {
                    try (PreparedStatement ps = conn.prepareStatement(
                            "UPDATE Work_Schedule SET Status = 'Available' WHERE Schedule_ID = ? "
                            + "AND Status = 'Booked' AND NOT EXISTS (SELECT 1 FROM Appointment "
                            + "WHERE Schedule_ID = ? AND Appointment_ID <> ? AND Status <> 'Canceled')")) {
                        ps.setInt(1, scheduleId);
                        ps.setInt(2, scheduleId);
                        ps.setInt(3, appointmentId);
                        ps.executeUpdate();
                    }
                }

                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE Master_Invoice SET Status = 'Canceled' "
                        + "WHERE Appointment_ID = ? AND Status IN ('Pending_Deposit', 'Unpaid')")) {
                    ps.setInt(1, appointmentId);
                    ps.executeUpdate();
                }

                String cancellationNote = "In_Progress".equals(originalStatus)
                        ? "Bác sĩ dừng ca đang khám: " + reason.trim()
                        : "Bác sĩ hủy ca chờ khám: " + reason.trim();
                int recordCount;
                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE Medical_Record SET conclusion = CASE "
                        + "WHEN conclusion IS NULL OR LTRIM(RTRIM(conclusion)) = '' THEN ? "
                        + "ELSE CONCAT(conclusion, CHAR(10), ?) END WHERE Appointment_ID = ?")) {
                    ps.setString(1, cancellationNote);
                    ps.setString(2, cancellationNote);
                    ps.setInt(3, appointmentId);
                    recordCount = ps.executeUpdate();
                }
                if (recordCount == 0) {
                    try (PreparedStatement ps = conn.prepareStatement(
                            "INSERT INTO Medical_Record (Appointment_ID, Doctor_Employee_ID, conclusion, Created_At) "
                            + "VALUES (?, ?, ?, SYSUTCDATETIME())")) {
                        ps.setInt(1, appointmentId);
                        ps.setInt(2, doctorEmployeeId);
                        ps.setString(3, cancellationNote);
                        ps.executeUpdate();
                    }
                }

                conn.commit();
                return true;
            } catch (Exception error) {
                conn.rollback();
                throw error;
            }
        }
    }

    /** Complete only the signed-in doctor's checked-in appointment for today. */
    public boolean completeExamination(int appointmentId, int doctorEmployeeId, Date clinicDate) throws Exception {
        String sql = "UPDATE a SET a.Status = 'Completed' "
                + "FROM Appointment a "
                + "JOIN Work_Schedule ws ON a.Schedule_ID = ws.Schedule_ID "
                + "WHERE a.Appointment_ID = ? AND ws.Doctor_Employee_ID = ? AND ws.Work_Date = ? "
                + "AND a.Status = 'In_Progress' AND a.checkin_time IS NOT NULL AND " + EXAMINATION_READY;
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, appointmentId);
            ps.setInt(2, doctorEmployeeId);
            ps.setDate(3, clinicDate);
            return ps.executeUpdate() == 1;
        }
    }

    public boolean startExamination(int appointmentId, int doctorEmployeeId) throws Exception {
        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            conn.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE);
            try {
                Date workDate;
                String assignedSql = "SELECT ws.Work_Date, ws.Start_Time FROM Appointment a WITH (UPDLOCK, HOLDLOCK) "
                        + "JOIN Work_Schedule ws WITH (UPDLOCK, HOLDLOCK) ON a.Schedule_ID = ws.Schedule_ID "
                        + "WHERE a.Appointment_ID = ? AND ws.Doctor_Employee_ID = ? "
                        + "AND a.Status = 'Confirmed' AND a.checkin_time IS NOT NULL";
                try (PreparedStatement ps = conn.prepareStatement(assignedSql)) {
                    ps.setInt(1, appointmentId);
                    ps.setInt(2, doctorEmployeeId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            conn.rollback();
                            return false;
                        }
                        workDate = rs.getDate("Work_Date");
                        if (workDate == null || rs.getTime("Start_Time") == null) {
                            conn.rollback();
                            return false;
                        }
                    }
                }

                String busySql = "SELECT TOP 1 a.Appointment_ID FROM Appointment a WITH (UPDLOCK, HOLDLOCK) "
                        + "JOIN Work_Schedule ws ON a.Schedule_ID = ws.Schedule_ID "
                        + "WHERE ws.Doctor_Employee_ID = ? AND ws.Work_Date = ? AND a.Status = 'In_Progress'";
                try (PreparedStatement ps = conn.prepareStatement(busySql)) {
                    ps.setInt(1, doctorEmployeeId);
                    ps.setDate(2, workDate);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            conn.rollback();
                            return false;
                        }
                    }
                }

                int updated;
                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE Appointment SET Status = 'In_Progress' WHERE Appointment_ID = ? AND Status = 'Confirmed'")) {
                    ps.setInt(1, appointmentId);
                    updated = ps.executeUpdate();
                }
                if (updated == 1) {
                    conn.commit();
                    return true;
                }
                conn.rollback();
                return false;
            } catch (SQLException error) {
                conn.rollback();
                throw error;
            }
        }
    }
}
