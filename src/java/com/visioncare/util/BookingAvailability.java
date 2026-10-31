package com.visioncare.util;
import java.sql.*;
import com.visioncare.dao.TimeSlotDAO;
/** Same public consultation windows, future clock and pending hold used by WorkScheduleDAO. */
public final class BookingAvailability {
 private BookingAvailability(){}
 public static final String WINDOW="((CAST(ws.Start_Time AS TIME)>='08:00:00' AND CAST(ws.Start_Time AS TIME)<'11:00:00') OR (CAST(ws.Start_Time AS TIME)>='13:30:00' AND CAST(ws.Start_Time AS TIME)<'17:00:00'))";
 public static final String FUTURE="(ws.Work_Date>CAST(DATEADD(HOUR,7,SYSUTCDATETIME()) AS DATE) OR (ws.Work_Date=CAST(DATEADD(HOUR,7,SYSUTCDATETIME()) AS DATE) AND ws.Start_Time>CAST(DATEADD(HOUR,7,SYSUTCDATETIME()) AS TIME)))";
 public static boolean available(Connection c,int schedule)throws SQLException {
  String sql="SELECT 1 FROM Work_Schedule ws WITH(UPDLOCK,HOLDLOCK) JOIN Employee_Profile e ON e.Employee_ID=ws.Doctor_Employee_ID JOIN Account ac ON ac.Account_ID=e.Account_ID WHERE ws.Schedule_ID=? AND ws.Status='Available' AND ac.Role_ID=3 AND ac.Account_Status='Active' AND "+WINDOW+" AND "+FUTURE+" AND NOT EXISTS(SELECT 1 FROM Appointment ap WITH(UPDLOCK,HOLDLOCK) WHERE ap.Schedule_ID=ws.Schedule_ID AND (ap.Status IN ('Confirmed','In_Progress','Completed') OR ap.Status='Pending' AND DATEDIFF(MINUTE,ap.created_at,DATEADD(HOUR,7,SYSUTCDATETIME()))<?))";
  try(PreparedStatement p=c.prepareStatement(sql)){p.setInt(1,schedule);p.setInt(2,TimeSlotDAO.getPendingHoldMinutes());try(ResultSet r=p.executeQuery()){return r.next();}}
 }
}
