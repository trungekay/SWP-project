package com.visioncare.dao;

import com.visioncare.util.BookingAvailability;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;

/** Atomically closes a doctor's work slot and transfers its appointment, if any. */
public class StaffDoctorRescheduleDAO {
    public record Result(Integer appointmentId, Integer replacementDoctorId) {}

    public Result change(int doctorId, int sourceScheduleId, Integer targetScheduleId,
                         LocalDate targetDate, int staffAccountId, String reason) throws Exception {
        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            conn.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE);
            try {
                String sourceStatus;
                String sourceSql = "SELECT ws.Status FROM Work_Schedule ws WITH (UPDLOCK, HOLDLOCK) "
                        + "WHERE ws.Schedule_ID=? AND ws.Doctor_Employee_ID=? "
                        + "AND ws.Status IN ('Available','Booked') AND " + BookingAvailability.FUTURE;
                try (PreparedStatement ps = conn.prepareStatement(sourceSql)) {
                    ps.setInt(1, sourceScheduleId);
                    ps.setInt(2, doctorId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) throw new IllegalStateException("Ca làm việc đã qua hoặc không còn khả dụng.");
                        sourceStatus = rs.getString(1);
                    }
                }

                Integer appointmentId = null;
                Integer patientId = null;
                String appointmentStatus = null;
                boolean checkedIn = false;
                try (PreparedStatement ps = conn.prepareStatement(
                        "SELECT Appointment_ID, Patient_ID, Status, checkin_time FROM Appointment WITH (UPDLOCK, HOLDLOCK) "
                        + "WHERE Schedule_ID=? AND Status<>'Canceled'")) {
                    ps.setInt(1, sourceScheduleId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            appointmentId = rs.getInt(1);
                            patientId = rs.getInt(2);
                            appointmentStatus = rs.getString(3);
                            checkedIn = rs.getTimestamp(4) != null;
                            if (rs.next()) throw new IllegalStateException("Ca này có nhiều lịch hẹn; cần xử lý thủ công.");
                        }
                    }
                }

                Integer replacementDoctorId = null;
                if (appointmentId != null) {
                    if (!"Booked".equals(sourceStatus) || !"Confirmed".equals(appointmentStatus) || checkedIn) {
                        throw new IllegalStateException("Chỉ chuyển lịch hẹn đã xác nhận và chưa check-in.");
                    }
                    ensureAppointmentCanMove(conn, appointmentId);
                    if (targetScheduleId == null || targetDate == null || targetScheduleId == sourceScheduleId) {
                        throw new IllegalArgumentException("Hãy chọn bác sĩ và khung giờ thay thế.");
                    }
                    LocalDate today = LocalDate.now();
                    if (targetDate.isBefore(today) || targetDate.isAfter(today.plusDays(30))) {
                        throw new IllegalArgumentException("Ngày thay thế phải nằm trong 30 ngày tới.");
                    }
                    replacementDoctorId = getReplacementDoctor(conn, doctorId, targetScheduleId, targetDate);
                    if (!BookingAvailability.available(conn, targetScheduleId)
                            || hasAnyActiveAppointment(conn, targetScheduleId)
                            || hasPatientConflict(conn, patientId, appointmentId, targetScheduleId)) {
                        throw new IllegalStateException("Khung giờ thay thế đã kín hoặc bệnh nhân bị trùng lịch.");
                    }
                    try (PreparedStatement ps = conn.prepareStatement(
                            "UPDATE Work_Schedule SET Status='Booked' WHERE Schedule_ID=? AND Status='Available'")) {
                        ps.setInt(1, targetScheduleId);
                        if (ps.executeUpdate() != 1) throw new IllegalStateException("Khung giờ thay thế vừa được đặt.");
                    }
                    try (PreparedStatement ps = conn.prepareStatement(
                            "UPDATE Appointment SET Schedule_ID=? WHERE Appointment_ID=? AND Schedule_ID=? "
                            + "AND Status='Confirmed' AND checkin_time IS NULL")) {
                        ps.setInt(1, targetScheduleId);
                        ps.setInt(2, appointmentId);
                        ps.setInt(3, sourceScheduleId);
                        if (ps.executeUpdate() != 1) throw new IllegalStateException("Lịch hẹn đã thay đổi; hãy tải lại trang.");
                    }
                    try (PreparedStatement ps = conn.prepareStatement(
                            "UPDATE Medical_Record SET Doctor_Employee_ID=? WHERE Appointment_ID=? AND examination_result IS NULL")) {
                        ps.setInt(1, replacementDoctorId);
                        ps.setInt(2, appointmentId);
                        ps.executeUpdate();
                    }
                } else if (!"Available".equals(sourceStatus)) {
                    throw new IllegalStateException("Ca đã được đặt nhưng không tìm thấy lịch hẹn hợp lệ.");
                }

                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE Work_Schedule SET Status='Canceled' WHERE Schedule_ID=? AND Status=? "
                        + "AND NOT EXISTS (SELECT 1 FROM Appointment WHERE Schedule_ID=? AND Status<>'Canceled')")) {
                    ps.setInt(1, sourceScheduleId);
                    ps.setString(2, sourceStatus);
                    ps.setInt(3, sourceScheduleId);
                    if (ps.executeUpdate() != 1) throw new IllegalStateException("Không thể đóng ca cũ; hãy tải lại trang.");
                }

                try (PreparedStatement ps = conn.prepareStatement(
                        "INSERT INTO Doctor_Schedule_Change "
                        + "(Source_Schedule_ID, Target_Schedule_ID, Appointment_ID, Changed_By_Account_ID, Reason) "
                        + "VALUES (?,?,?,?,?)")) {
                    ps.setInt(1, sourceScheduleId);
                    if (targetScheduleId != null && appointmentId != null) ps.setInt(2, targetScheduleId);
                    else ps.setNull(2, java.sql.Types.INTEGER);
                    if (appointmentId != null) ps.setInt(3, appointmentId);
                    else ps.setNull(3, java.sql.Types.INTEGER);
                    ps.setInt(4, staffAccountId);
                    ps.setString(5, reason);
                    ps.executeUpdate();
                }
                conn.commit();
                return new Result(appointmentId, replacementDoctorId);
            } catch (Exception e) {
                conn.rollback();
                throw e;
            }
        }
    }

    private void ensureAppointmentCanMove(Connection conn, int appointmentId) throws SQLException {
        String sql = "SELECT 1 FROM Master_Invoice i WHERE i.Appointment_ID=? AND i.Status IN ('Paid','Partial_Paid') "
                + "AND NOT EXISTS (SELECT 1 FROM Refund_Request r WHERE r.Invoice_ID=i.Invoice_ID "
                + "AND r.Status IN ('Pending','Approved','Completed')) "
                + "AND NOT EXISTS (SELECT 1 FROM Invoice_Checkout co WHERE co.Invoice_ID=i.Invoice_ID "
                + "AND co.Finalized_At IS NOT NULL) "
                + "AND NOT EXISTS (SELECT 1 FROM Medical_Record mr WHERE mr.Appointment_ID=i.Appointment_ID "
                + "AND mr.examination_result IS NOT NULL)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, appointmentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) throw new IllegalStateException("Lịch hẹn đã xử lý thanh toán, hoàn tiền hoặc khám; không thể chuyển tự động.");
            }
        }
    }

    private int getReplacementDoctor(Connection conn, int sourceDoctorId, int targetScheduleId,
                                     LocalDate targetDate) throws SQLException {
        String sql = "SELECT ws.Doctor_Employee_ID FROM Work_Schedule ws WITH (UPDLOCK, HOLDLOCK) "
                + "JOIN Employee_Profile e ON e.Employee_ID=ws.Doctor_Employee_ID "
                + "JOIN Account ac ON ac.Account_ID=e.Account_ID "
                + "WHERE ws.Schedule_ID=? AND ws.Work_Date=? AND ws.Doctor_Employee_ID<>? "
                + "AND ws.Status='Available' AND ac.Role_ID=3 AND ac.Account_Status='Active'";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, targetScheduleId);
            ps.setDate(2, java.sql.Date.valueOf(targetDate));
            ps.setInt(3, sourceDoctorId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) throw new IllegalStateException("Khung giờ thay thế phải thuộc bác sĩ khác và còn trống.");
                return rs.getInt(1);
            }
        }
    }

    private boolean hasAnyActiveAppointment(Connection conn, int scheduleId) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT 1 FROM Appointment WITH (UPDLOCK,HOLDLOCK) WHERE Schedule_ID=? AND Status<>'Canceled'")) {
            ps.setInt(1, scheduleId);
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        }
    }

    private boolean hasPatientConflict(Connection conn, int patientId, int appointmentId,
                                       int targetScheduleId) throws SQLException {
        String sql = "SELECT 1 FROM Work_Schedule ws WHERE ws.Schedule_ID=? AND EXISTS ("
                + "SELECT 1 FROM Appointment a JOIN Work_Schedule other ON other.Schedule_ID=a.Schedule_ID "
                + "WHERE a.Patient_ID=? AND a.Appointment_ID<>? "
                + "AND (a.Status IN ('Confirmed','In_Progress') OR "
                + "(a.Status='Pending' AND DATEDIFF(MINUTE,a.created_at,DATEADD(HOUR,7,SYSUTCDATETIME()))<?)) "
                + "AND other.Work_Date=ws.Work_Date AND other.Start_Time<ws.End_Time "
                + "AND other.End_Time>ws.Start_Time)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, targetScheduleId);
            ps.setInt(2, patientId);
            ps.setInt(3, appointmentId);
            ps.setInt(4, TimeSlotDAO.getPendingHoldMinutes());
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        }
    }
}
