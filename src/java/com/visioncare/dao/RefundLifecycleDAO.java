package com.visioncare.dao;
import java.sql.*;
import java.util.*;
import com.visioncare.util.RefundImage;
/** Director decision and actual cashier payout are separate transactions. */
public class RefundLifecycleDAO {
 private final StaffInvoiceDAO.Connections connections;
 public RefundLifecycleDAO(){this(DBContext::getConnection);}
 public RefundLifecycleDAO(StaffInvoiceDAO.Connections source){connections=source;}
 private boolean role(Connection c,int employee,int... allowed)throws SQLException {
  try(PreparedStatement p=c.prepareStatement("SELECT ac.Role_ID FROM Employee_Profile e JOIN Account ac ON ac.Account_ID=e.Account_ID WHERE e.Employee_ID=? AND ac.Account_Status='Active'")){
   p.setInt(1,employee);try(ResultSet r=p.executeQuery()){if(!r.next())return false;for(int v:allowed)if(r.getInt(1)==v)return true;return false;}
  }
 }
 private boolean eligible(Connection c,int refund)throws Exception {
  try(PreparedStatement p=c.prepareStatement("SELECT Request_Kind FROM Refund_Request WHERE Refund_ID=?")){p.setInt(1,refund);try(ResultSet r=p.executeQuery()){if(r.next()&&"Items".equals(r.getString(1)))return new ItemRefundDAO(connections).valid(c,refund);}}

  String sql="SELECT 1 FROM Refund_Request r JOIN Master_Invoice i WITH(UPDLOCK,HOLDLOCK) ON i.Invoice_ID=r.Invoice_ID JOIN Appointment a ON a.Appointment_ID=i.Appointment_ID WHERE r.Refund_ID=? AND r.Patient_ID=a.Patient_ID AND "+RefundPolicy.ELIGIBLE+" AND r.Refund_Amount>0 AND r.Refund_Amount<=CASE WHEN i.Status='Partial_Paid' THEN i.Total_Amount-i.Balance_Due ELSE i.Total_Amount END";
  try(PreparedStatement p=c.prepareStatement(sql)){p.setInt(1,refund);try(ResultSet r=p.executeQuery()){return r.next();}}
 }
 public boolean decide(int id,int employee,boolean approve,String note)throws Exception {
  if(note!=null&&note.length()>1000||!approve&&(note==null||note.isBlank()))throw new IllegalArgumentException("Vui lòng nhập lý do từ chối (tối đa 1000 ký tự).");
  try(Connection c=connections.open()){c.setAutoCommit(false);try{
   if(!role(c,employee,1,2)){c.rollback();return false;}
   if(approve&&!eligible(c,id)){c.rollback();return false;}
   try(PreparedStatement p=c.prepareStatement("UPDATE Refund_Request SET Status=?,approved_by_employee_id=?,Decision_Note=?,Decision_At=SYSUTCDATETIME(),Update_At=SYSUTCDATETIME(),Notification_Status='Pending',Notification_Attempts=0,Notification_Last_Error=NULL WHERE Refund_ID=? AND Status='Pending'")){
    p.setString(1,approve?"Approved":"Rejected");p.setInt(2,employee);p.setString(3,note);p.setInt(4,id);if(p.executeUpdate()!=1){c.rollback();return false;}
   }c.commit();return true;
  }catch(Exception e){c.rollback();throw e;}}
 }
 public boolean complete(int id,int employee,String note,byte[] image)throws Exception {
  if(note!=null&&note.length()>1000)throw new IllegalArgumentException("Ghi chú tối đa 1000 ký tự.");String type=image==null?null:RefundImage.type(image);
  try(Connection c=connections.open()){c.setAutoCommit(false);c.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE);try{
   if(!role(c,employee,1,5)){c.rollback();return false;}
   String kind;int invoice;try(PreparedStatement p=c.prepareStatement("SELECT Invoice_ID,Request_Kind FROM Refund_Request WITH(UPDLOCK,HOLDLOCK) WHERE Refund_ID=? AND Status='Approved'")){p.setInt(1,id);try(ResultSet r=p.executeQuery()){if(!r.next()){c.rollback();return false;}invoice=r.getInt(1);kind=r.getString(2);}}
   if(!eligible(c,id)){c.rollback();return false;}
   // Preserve recognized legacy receipts before marking Partial_Paid as Refunded.
   try(PreparedStatement p=c.prepareStatement("IF NOT EXISTS(SELECT 1 FROM Invoice_Checkout WHERE Invoice_ID=?) INSERT INTO Invoice_Checkout(Invoice_ID,Base_Amount,Opening_Paid) SELECT i.Invoice_ID,COALESCE(NULLIF(i.Deposit_Amount,0),i.Total_Amount),CASE WHEN v.Paid>COALESCE(t.Paid,0) THEN v.Paid-COALESCE(t.Paid,0) ELSE 0 END FROM Master_Invoice i OUTER APPLY(SELECT SUM(Amount) AS Paid FROM Payment_Transaction WHERE Invoice_ID=i.Invoice_ID AND Gateway_Status='Success') t CROSS APPLY(SELECT CASE WHEN i.Status='Partial_Paid' THEN i.Total_Amount-i.Balance_Due ELSE i.Total_Amount END AS Paid) v WHERE i.Invoice_ID=?")){p.setInt(1,invoice);p.setInt(2,invoice);p.executeUpdate();}
   try(PreparedStatement p=c.prepareStatement("UPDATE Refund_Request SET Status='Completed',Completed_By=?,Completed_At=SYSUTCDATETIME(),Completion_Note=?,Evidence_Image=?,Evidence_Type=?,Update_At=SYSUTCDATETIME() WHERE Refund_ID=? AND Status='Approved'")){p.setInt(1,employee);p.setString(2,note);p.setBytes(3,image);p.setString(4,type);p.setInt(5,id);if(p.executeUpdate()!=1){c.rollback();return false;}}
   if("Items".equals(kind)){
    if(ItemRefundDAO.refunded(c,invoice)>=ItemRefundDAO.received(c,invoice))try(PreparedStatement p=c.prepareStatement("UPDATE Master_Invoice SET Status='Refunded' WHERE Invoice_ID=?")){p.setInt(1,invoice);p.executeUpdate();}
   }else try(PreparedStatement p=c.prepareStatement("UPDATE Master_Invoice SET Status='Refunded' WHERE Invoice_ID=? AND Status IN ('Paid','Partial_Paid')")){p.setInt(1,invoice);if(p.executeUpdate()!=1){c.rollback();return false;}}
   c.commit();return true;
  }catch(Exception e){c.rollback();throw e;}}
 }
 public Map<String,Object> latest(int invoice)throws Exception {
  try(Connection c=connections.open();PreparedStatement p=c.prepareStatement("SELECT TOP 1 r.*,e.Full_Name AS Completed_Name,director.Full_Name AS Approver_Name,a.Status AS Appointment_Status,a.checkin_time,i.Appointment_ID,CASE WHEN Evidence_Image IS NULL THEN 0 ELSE 1 END AS Has_Evidence FROM Refund_Request r LEFT JOIN Employee_Profile e ON e.Employee_ID=r.Completed_By LEFT JOIN Employee_Profile director ON director.Employee_ID=r.approved_by_employee_id JOIN Master_Invoice i ON i.Invoice_ID=r.Invoice_ID JOIN Appointment a ON a.Appointment_ID=i.Appointment_ID WHERE r.Invoice_ID=? ORDER BY r.Refund_ID DESC")){
   p.setInt(1,invoice);try(ResultSet r=p.executeQuery()){if(!r.next())return null;Map<String,Object> m=new HashMap<>();m.put("id",r.getInt("Refund_ID"));m.put("invoiceId",invoice);m.put("status",r.getString("Status"));m.put("canComplete","Approved".equals(r.getString("Status")) && eligible(c,r.getInt("Refund_ID")));m.put("amount",r.getLong("Refund_Amount"));m.put("reason",r.getString("Reason"));m.put("decision",r.getString("Decision_Note"));m.put("completedAt",r.getTimestamp("Completed_At"));m.put("completedBy",r.getString("Completed_Name"));m.put("note",r.getString("Completion_Note"));m.put("hasEvidence",r.getBoolean("Has_Evidence"));
   m.put("approvedBy",r.getString("Approver_Name"));m.put("kind",r.getString("Request_Kind"));m.put("lines",ItemRefundDAO.lines(c,r.getInt("Refund_ID")));
   m.put("decisionAt",r.getTimestamp("Decision_At"));
   if("Approved".equals(r.getString("Status"))&&!Boolean.TRUE.equals(m.get("canComplete"))) {
    String appointmentStatus=r.getString("Appointment_Status");
    String reason="Cần đối chiếu khoản thu và phạm vi yêu cầu hoàn tiền.";
    if("Items".equals(r.getString("Request_Kind"))){m.put("payoutBlockedReason","Khoản thuốc / thủ thuật không còn đủ điều kiện: đã sử dụng, số lượng hoặc tiền thực thu đã thay đổi. Cần đối chiếu lại.");return m;}
    if("Completed".equals(appointmentStatus))reason="Lịch #APT-"+r.getInt("Appointment_ID")+" đã khám xong. Yêu cầu cũ này chưa có chi tiết khoản phát sinh đủ điều kiện; không thể dùng yêu cầu hoàn phí khám để tự hoàn thuốc / thủ thuật.";
    else if(r.getTimestamp("checkin_time")!=null)reason="Lịch #APT-"+r.getInt("Appointment_ID")+" đã check-in, không thuộc luồng hoàn phí khám do hủy trước check-in.";
    else if(!"Canceled".equals(appointmentStatus))reason="Lịch #APT-"+r.getInt("Appointment_ID")+" chưa được xác nhận hủy trước check-in.";
    m.put("payoutBlockedReason",reason);
   }
   return m;}
  }
 }
 public Map<String,Object> evidence(int id)throws Exception {
  try(Connection c=connections.open();PreparedStatement p=c.prepareStatement("SELECT Evidence_Image,Evidence_Type FROM Refund_Request WHERE Refund_ID=? AND Evidence_Image IS NOT NULL")){p.setInt(1,id);try(ResultSet r=p.executeQuery()){if(!r.next())return null;Map<String,Object> m=new HashMap<>();m.put("bytes",r.getBytes(1));m.put("type",r.getString(2));return m;}}
 }
}
