package com.visioncare.dao;
import java.sql.*;
import java.util.*;
import com.visioncare.util.BookingAvailability;
public class PatientRescheduleDAO {
 private final StaffInvoiceDAO.Connections connections;
 public PatientRescheduleDAO(){this(DBContext::getConnection);}public PatientRescheduleDAO(StaffInvoiceDAO.Connections c){connections=c;}
 public Map<String,Object> current(int id,int account)throws Exception {try(Connection c=connections.open()){return current(c,id,account);}}
 private Map<String,Object> current(Connection c,int id,int account)throws SQLException {
  String sql="SELECT a.Patient_ID,a.Schedule_ID,ws.Doctor_Employee_ID,ws.Work_Date,ws.Start_Time,e.Full_Name,ws.End_Time,ac.Email,p.Full_Name AS Patient_Name FROM Appointment a JOIN Patient p ON p.Patient_ID=a.Patient_ID JOIN Account ac ON ac.Account_ID=p.Account_ID JOIN Work_Schedule ws ON ws.Schedule_ID=a.Schedule_ID JOIN Employee_Profile e ON e.Employee_ID=ws.Doctor_Employee_ID WHERE a.Appointment_ID=? AND p.Account_ID=? AND a.Status='Confirmed' AND a.checkin_time IS NULL AND "+BookingAvailability.FUTURE+" AND EXISTS(SELECT 1 FROM Master_Invoice i WHERE i.Appointment_ID=a.Appointment_ID AND i.Status IN ('Paid','Partial_Paid') AND NOT EXISTS(SELECT 1 FROM Refund_Request r WHERE r.Invoice_ID=i.Invoice_ID AND r.Status IN ('Pending','Approved','Completed')) AND NOT EXISTS(SELECT 1 FROM Invoice_Checkout co WHERE co.Invoice_ID=i.Invoice_ID AND co.Finalized_At IS NOT NULL)) AND NOT EXISTS(SELECT 1 FROM Medical_Record m WHERE m.Appointment_ID=a.Appointment_ID AND m.examination_result IS NOT NULL)";
  try(PreparedStatement p=c.prepareStatement(sql)){p.setInt(1,id);p.setInt(2,account);try(ResultSet r=p.executeQuery()){if(!r.next())return null;Map<String,Object> m=new HashMap<>();m.put("id",id);m.put("patient",r.getInt(1));m.put("schedule",r.getInt(2));m.put("doctor",r.getInt(3));m.put("date",r.getDate(4));m.put("time",r.getTime(5));m.put("doctorName",r.getString(6));m.put("endTime",r.getTime(7));m.put("email",r.getString(8));m.put("patientName",r.getString(9));return m;}}
 }
 public record Change(Map<String,Object> previous,Map<String,Object> updated) {}
 public boolean move(int id,int account,int target)throws Exception {return moveWithDetails(id,account,target)!=null;}
 public Change moveWithDetails(int id,int account,int target)throws Exception {
  try(Connection c=connections.open()){c.setAutoCommit(false);c.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE);try{
   try(PreparedStatement p=c.prepareStatement("SELECT Patient_ID FROM Patient WITH(UPDLOCK,HOLDLOCK) WHERE Account_ID=?")){p.setInt(1,account);try(ResultSet r=p.executeQuery()){if(!r.next()){c.rollback();return null;}}}
   try(PreparedStatement p=c.prepareStatement("SELECT Appointment_ID FROM Appointment WITH(UPDLOCK,HOLDLOCK) WHERE Appointment_ID=?")){p.setInt(1,id);try(ResultSet r=p.executeQuery()){if(!r.next()){c.rollback();return null;}}}
   Map<String,Object> from=current(c,id,account);if(from==null||(Integer)from.get("schedule")==target){c.rollback();return null;}int old=(Integer)from.get("schedule");
   try(PreparedStatement p=c.prepareStatement("SELECT Schedule_ID FROM Work_Schedule WITH(UPDLOCK,HOLDLOCK) WHERE Schedule_ID IN (?,?) ORDER BY Schedule_ID")){p.setInt(1,old);p.setInt(2,target);try(ResultSet r=p.executeQuery()){while(r.next()){} }}
   if(!BookingAvailability.available(c,target)){c.rollback();return null;}
   int doctor;try(PreparedStatement p=c.prepareStatement("SELECT ws.Doctor_Employee_ID FROM Work_Schedule ws WHERE ws.Schedule_ID=? AND NOT EXISTS(SELECT 1 FROM Appointment other JOIN Work_Schedule os ON os.Schedule_ID=other.Schedule_ID WHERE other.Patient_ID=? AND other.Appointment_ID<>? AND (other.Status IN ('Confirmed','In_Progress') OR other.Status='Pending' AND DATEDIFF(MINUTE,other.created_at,DATEADD(HOUR,7,SYSUTCDATETIME()))<?) AND os.Work_Date=ws.Work_Date AND os.Start_Time<ws.End_Time AND os.End_Time>ws.Start_Time)")){p.setInt(1,target);p.setInt(2,(Integer)from.get("patient"));p.setInt(3,id);p.setInt(4,TimeSlotDAO.getPendingHoldMinutes());try(ResultSet r=p.executeQuery()){if(!r.next()){c.rollback();return null;}doctor=r.getInt(1);}}
   try(PreparedStatement p=c.prepareStatement("UPDATE Work_Schedule SET Status='Booked' WHERE Schedule_ID=? AND Status='Available'")){p.setInt(1,target);if(p.executeUpdate()!=1){c.rollback();return null;}}
   try(PreparedStatement p=c.prepareStatement("UPDATE Appointment SET Schedule_ID=? WHERE Appointment_ID=? AND Status='Confirmed' AND checkin_time IS NULL")){p.setInt(1,target);p.setInt(2,id);if(p.executeUpdate()!=1){c.rollback();return null;}}
   try(PreparedStatement p=c.prepareStatement("UPDATE Medical_Record SET Doctor_Employee_ID=? WHERE Appointment_ID=? AND examination_result IS NULL")){p.setInt(1,doctor);p.setInt(2,id);p.executeUpdate();}
   try(PreparedStatement p=c.prepareStatement("UPDATE Work_Schedule SET Status='Available' WHERE Schedule_ID=? AND Status='Booked' AND NOT EXISTS(SELECT 1 FROM Appointment WHERE Schedule_ID=? AND Status<>'Canceled')")){p.setInt(1,old);p.setInt(2,old);p.executeUpdate();}
   Map<String,Object> updated=current(c,id,account);
   if(updated==null)throw new IllegalStateException("Không thể xác nhận lịch mới.");
   c.commit();return new Change(from,updated);
  }catch(Exception e){c.rollback();throw e;}}
 }
}
