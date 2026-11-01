package com.visioncare.util;
import java.sql.*;
import com.visioncare.dao.TimeSlotDAO;

/** Same public consultation windows, future clock and pending hold used by WorkScheduleDAO. */
public final class BookingAvailability {
    private BookingAvailability(){}

    // Window khi mở full toàn bộ ca khám của bác sĩ (08:00 - 11:30 và 13:30 - 17:00)
    public static final String WINDOW_FULL = "((CAST(ws.Start_Time AS TIME)>='08:00:00' AND CAST(ws.Start_Time AS TIME)<'11:30:00') OR (CAST(ws.Start_Time AS TIME)>='13:30:00' AND CAST(ws.Start_Time AS TIME)<'17:00:00'))";

    // Window khi bật chế độ Buffer Slot (Dành riêng 30p cuối mỗi ca: 11h-11h30 và 16h30-17h để xử lý khám bù giờ phát sinh)
    public static final String WINDOW_BUFFER = "((CAST(ws.Start_Time AS TIME)>='08:00:00' AND CAST(ws.Start_Time AS TIME)<'11:00:00') OR (CAST(ws.Start_Time AS TIME)>='13:30:00' AND CAST(ws.Start_Time AS TIME)<'16:30:00'))";

    public static final String WINDOW = WINDOW_FULL;

    public static String getWindowCondition() {
        return TimeSlotDAO.isSessionEndBufferEnabled() ? WINDOW_BUFFER : WINDOW_FULL;
    }

    public static final String FUTURE = "(ws.Work_Date>CAST(DATEADD(HOUR,7,SYSUTCDATETIME()) AS DATE) OR (ws.Work_Date=CAST(DATEADD(HOUR,7,SYSUTCDATETIME()) AS DATE) AND ws.Start_Time>CAST(DATEADD(HOUR,7,SYSUTCDATETIME()) AS TIME)))";

    public static boolean available(Connection c, int schedule) throws SQLException {
        String window = getWindowCondition();
        String sql = "SELECT 1 FROM Work_Schedule ws WITH(UPDLOCK,HOLDLOCK) " +
                     "JOIN Employee_Profile e ON e.Employee_ID=ws.Doctor_Employee_ID " +
                     "JOIN Account ac ON ac.Account_ID=e.Account_ID " +
                     "WHERE ws.Schedule_ID=? AND ws.Status='Available' AND ac.Role_ID=3 AND ac.Account_Status='Active' " +
                     "AND " + window + " AND " + FUTURE + " " +
                     "AND NOT EXISTS(SELECT 1 FROM Appointment ap WITH(UPDLOCK,HOLDLOCK) " +
                     "               WHERE ap.Schedule_ID=ws.Schedule_ID " +
                     "                 AND (ap.Status IN ('Confirmed','In_Progress','Completed') " +
                     "                      OR (ap.Status='Pending' AND DATEDIFF(MINUTE,ap.created_at,DATEADD(HOUR,7,SYSUTCDATETIME()))<?)))";
        try (PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, schedule);
            p.setInt(2, TimeSlotDAO.getPendingHoldMinutes());
            try (ResultSet r = p.executeQuery()) {
                return r.next();
            }
        }
    }
}
