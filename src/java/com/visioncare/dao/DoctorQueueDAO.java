package com.visioncare.dao;

import com.visioncare.util.ExaminationWindow;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDateTime;

/** Status transition for a doctor's own checked-in appointment. */
public class DoctorQueueDAO {
    /** Cancel only this doctor's checked-in examination after its start window has passed. */
    public boolean cancelOverdueExamination(int appointmentId, int doctorEmployeeId,
            LocalDateTime clinicNow) throws Exception {
        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            conn.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE);
            try {
                int scheduleId;
                String assignedSql = "SELECT a.Status, a.checkin_time, ws.Schedule_ID, ws.Work_Date, ws.Start_Time "
                        + "FROM Appointment a WITH (UPDLOCK, HOLDLOCK) "
                        + "JOIN Work_Schedule ws WITH (UPDLOCK, HOLDLOCK) ON a.Schedule_ID = ws.Schedule_ID "
                        + "WHERE a.Appointment_ID = ? AND ws.Doctor_Employee_ID = ?";
                try (PreparedStatement ps = conn.prepareStatement(assignedSql)) {
                    ps.setInt(1, appointmentId);
                    ps.setInt(2, doctorEmployeeId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next() || rs.getTimestamp("checkin_time") == null
                                || !("Confirmed".equals(rs.getString("Status"))
                                || "In_Progress".equals(rs.getString("Status")))
                                || rs.getDate("Work_Date") == null || rs.getTime("Start_Time") == null
                                || !"late".equals(ExaminationWindow.state(
                                        rs.getDate("Work_Date").toLocalDate(),
                                        rs.getTime("Start_Time").toLocalTime(), clinicNow))) {
                            conn.rollback();
                            return false;
                        }
                        scheduleId = rs.getInt("Schedule_ID");
                    }
                }

                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE Appointment SET Status = 'Canceled' "
                        + "WHERE Appointment_ID = ? AND Status IN ('Confirmed', 'In_Progress')")) {
                    ps.setInt(1, appointmentId);
                    if (ps.executeUpdate() != 1) {
                        conn.rollback();
                        return false;
                    }
                }

                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE Work_Schedule SET Status = 'Available' WHERE Schedule_ID = ? "
                        + "AND Status = 'Booked' AND NOT EXISTS (SELECT 1 FROM Appointment "
                        + "WHERE Schedule_ID = ? AND Appointment_ID <> ? AND Status <> 'Canceled')")) {
                    ps.setInt(1, scheduleId);
                    ps.setInt(2, scheduleId);
                    ps.setInt(3, appointmentId);
                    ps.executeUpdate();
                }

                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE Master_Invoice SET Status = 'Canceled' "
                        + "WHERE Appointment_ID = ? AND Status IN ('Pending_Deposit', 'Unpaid')")) {
                    ps.setInt(1, appointmentId);
                    ps.executeUpdate();
                }

                String reason = "Bác sĩ hủy lịch: Quá 1 giờ sau giờ hẹn, ca khám chưa hoàn tất.";
                int recordCount;
                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE Medical_Record SET conclusion = CASE "
                        + "WHEN conclusion IS NULL OR LTRIM(RTRIM(conclusion)) = '' THEN ? "
                        + "ELSE CONCAT(conclusion, CHAR(10), ?) END WHERE Appointment_ID = ?")) {
                    ps.setString(1, reason);
                    ps.setString(2, reason);
                    ps.setInt(3, appointmentId);
                    recordCount = ps.executeUpdate();
                }
                if (recordCount == 0) {
                    try (PreparedStatement ps = conn.prepareStatement(
                            "INSERT INTO Medical_Record (Appointment_ID, Doctor_Employee_ID, conclusion, Created_At) "
                            + "VALUES (?, ?, ?, SYSUTCDATETIME())")) {
                        ps.setInt(1, appointmentId);
                        ps.setInt(2, doctorEmployeeId);
                        ps.setString(3, reason);
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
                + "AND a.Status = 'In_Progress' AND a.checkin_time IS NOT NULL";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, appointmentId);
            ps.setInt(2, doctorEmployeeId);
            ps.setDate(3, clinicDate);
            return ps.executeUpdate() == 1;
        }
    }

    public boolean startExamination(int appointmentId, int doctorEmployeeId, LocalDateTime clinicNow) throws Exception {
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
                        if (workDate == null || rs.getTime("Start_Time") == null
                                || !"open".equals(ExaminationWindow.state(workDate.toLocalDate(),
                                        rs.getTime("Start_Time").toLocalTime(), clinicNow))) {
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
