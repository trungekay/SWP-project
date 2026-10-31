package com.visioncare.dao;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;

public class AdminDashboardDAO {

    /** Attendance for active appointments scheduled from the start of this month through today. */
    public AttendanceSummary getAttendanceSummary(LocalDate today) throws Exception {
        String sql = "SELECT COUNT(*) AS Total_Appointments, "
                + "COUNT(CASE WHEN a.checkin_time IS NOT NULL THEN 1 END) AS Checked_In "
                + "FROM Appointment a "
                + "JOIN Work_Schedule ws ON ws.Schedule_ID = a.Schedule_ID "
                + "WHERE ws.Work_Date >= ? AND ws.Work_Date <= ? "
                + "AND a.Status IN ('Confirmed', 'In_Progress', 'Completed')";

        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setDate(1, Date.valueOf(today.withDayOfMonth(1)));
            statement.setDate(2, Date.valueOf(today));
            try (ResultSet result = statement.executeQuery()) {
                if (result.next()) {
                    return new AttendanceSummary(result.getInt("Total_Appointments"),
                            result.getInt("Checked_In"));
                }
            }
        }
        throw new SQLException("Không đọc được thống kê lịch hẹn.");
    }

    public static class AttendanceSummary {
        private final int totalAppointments;
        private final int checkedIn;

        public AttendanceSummary(int totalAppointments, int checkedIn) {
            this.totalAppointments = totalAppointments;
            this.checkedIn = checkedIn;
        }

        public int getTotalAppointments() {
            return totalAppointments;
        }

        public int getCheckedIn() {
            return checkedIn;
        }

        public Integer getRatePercent() {
            if (totalAppointments == 0) {
                return null;
            }
            return (int) Math.round(checkedIn * 100.0 / totalAppointments);
        }
    }
}
