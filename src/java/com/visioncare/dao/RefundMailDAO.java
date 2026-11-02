package com.visioncare.dao;
import java.sql.*;
import java.util.*;
public class RefundMailDAO {
 private final StaffInvoiceDAO.Connections connections;
 public RefundMailDAO(){this(DBContext::getConnection);}public RefundMailDAO(StaffInvoiceDAO.Connections c){connections=c;}
 public Map<String,Object> claim()throws Exception {
  try(Connection c=connections.open()){c.setAutoCommit(false);c.setTransactionIsolation(Connection.TRANSACTION_READ_COMMITTED);try{
   int id=0;String sql=";WITH nextMail AS(SELECT TOP 1 * FROM Refund_Request WITH(UPDLOCK,READPAST,ROWLOCK) WHERE Status IN ('Approved','Rejected','Completed') AND Notification_Attempts<10 AND (Notification_Status='Pending' AND (Notification_Claimed_At IS NULL OR Notification_Claimed_At<DATEADD(SECOND,-60,SYSUTCDATETIME())) OR Notification_Status='Sending' AND Notification_Claimed_At<DATEADD(MINUTE,-5,SYSUTCDATETIME())) ORDER BY Refund_ID) UPDATE nextMail SET Notification_Status='Sending',Notification_Attempts=Notification_Attempts+1,Notification_Claimed_At=SYSUTCDATETIME() OUTPUT inserted.Refund_ID";
   try(Statement s=c.createStatement();ResultSet r=s.executeQuery(sql)){if(r.next())id=r.getInt(1);}if(id==0){c.commit();return null;}
   Map<String,Object> m=new HashMap<>();try(PreparedStatement p=c.prepareStatement("SELECT ac.Email,p.Full_Name,r.Status,r.Refund_Amount,r.Decision_Note FROM Refund_Request r JOIN Patient p ON p.Patient_ID=r.Patient_ID JOIN Account ac ON ac.Account_ID=p.Account_ID WHERE r.Refund_ID=?")){p.setInt(1,id);try(ResultSet r=p.executeQuery()){m.put("id",id);if(r.next()){m.put("email",r.getString(1));m.put("name",r.getString(2));m.put("approved",!"Rejected".equals(r.getString(3)));m.put("amount",r.getLong(4));m.put("note",r.getString(5));}}}c.commit();return m;
  }catch(Exception e){c.rollback();throw e;}}
 }
 public void finish(int id,boolean success,String error)throws Exception {
  try(Connection c=connections.open();PreparedStatement p=c.prepareStatement("UPDATE Refund_Request SET Notification_Status=CASE WHEN ?=1 THEN 'Sent' WHEN Notification_Attempts>=10 THEN 'Failed' ELSE 'Pending' END,Notification_Sent_At=CASE WHEN ?=1 THEN SYSUTCDATETIME() ELSE NULL END,Notification_Last_Error=? WHERE Refund_ID=? AND Notification_Status='Sending'")){p.setBoolean(1,success);p.setBoolean(2,success);p.setString(3,error==null?null:error.substring(0,Math.min(500,error.length())));p.setInt(4,id);p.executeUpdate();}
 }
 public void retry(int id)throws Exception {
  try(Connection c=connections.open();PreparedStatement p=c.prepareStatement("UPDATE Refund_Request SET Notification_Status='Pending',Notification_Attempts=0,Notification_Claimed_At=NULL WHERE Refund_ID=? AND Notification_Status='Failed'")){p.setInt(1,id);p.executeUpdate();}
 }
}
