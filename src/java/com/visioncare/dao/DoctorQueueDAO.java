package com.visioncare.dao;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/** Status transition for a doctor's own checked-in appointment. */
public class DoctorQueueDAO {
    public boolean startExamination(int appointmentId, int doctorEmployeeId, Date clinicDate) throws Exception {
        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            conn.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE);
            try {
                Date workDate;
                String assignedSql = "SELECT ws.Work_Date FROM Appointment a WITH (UPDLOCK, HOLDLOCK) "
                        + "JOIN Work_Schedule ws WITH (UPDLOCK, HOLDLOCK) ON a.Schedule_ID = ws.Schedule_ID "
                        + "WHERE a.Appointment_ID = ? AND ws.Doctor_Employee_ID = ? AND ws.Work_Date = ? "
                        + "AND a.Status = 'Confirmed' AND a.checkin_time IS NOT NULL";
                try (PreparedStatement ps = conn.prepareStatement(assignedSql)) {
                    ps.setInt(1, appointmentId);
                    ps.setInt(2, doctorEmployeeId);
                    ps.setDate(3, clinicDate);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            conn.rollback();
                            return false;
                        }
                        workDate = rs.getDate("Work_Date");
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
