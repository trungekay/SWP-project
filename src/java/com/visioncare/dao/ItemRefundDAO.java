package com.visioncare.dao;

import java.sql.*;
import java.util.*;

/** Paid, unused invoice lines; totals and quantities are calculated server-side. */
public class ItemRefundDAO {
 private final StaffInvoiceDAO.Connections connections;
 public ItemRefundDAO(){this(DBContext::getConnection);}
 public ItemRefundDAO(StaffInvoiceDAO.Connections c){connections=c;}
 public static boolean employeeRole(Connection c,int employee,int... roles)throws SQLException {
  try(PreparedStatement p=c.prepareStatement("SELECT ac.Role_ID FROM Employee_Profile e JOIN Account ac ON ac.Account_ID=e.Account_ID WHERE e.Employee_ID=? AND ac.Account_Status='Active'")){p.setInt(1,employee);try(ResultSet r=p.executeQuery()){if(!r.next())return false;for(int role:roles)if(r.getInt(1)==role)return true;return false;}}
 }
 public static long received(Connection c,int invoice)throws SQLException {
  String sql="SELECT CASE WHEN co.Invoice_ID IS NOT NULL THEN COALESCE(tx.Paid,0)+co.Opening_Paid WHEN COALESCE(tx.Paid,0)>v.Recognized THEN COALESCE(tx.Paid,0) ELSE v.Recognized END FROM Master_Invoice i LEFT JOIN Invoice_Checkout co ON co.Invoice_ID=i.Invoice_ID OUTER APPLY(SELECT SUM(Amount) AS Paid FROM Payment_Transaction WHERE Invoice_ID=i.Invoice_ID AND Gateway_Status='Success') tx CROSS APPLY(SELECT CASE WHEN i.Status IN ('Paid','Refunded') THEN i.Total_Amount WHEN i.Status='Partial_Paid' THEN i.Total_Amount-i.Balance_Due ELSE 0 END AS Recognized) v WHERE i.Invoice_ID=?";
  try(PreparedStatement p=c.prepareStatement(sql)){p.setInt(1,invoice);try(ResultSet r=p.executeQuery()){return r.next()?r.getLong(1):0;}}
 }
 public static long refunded(Connection c,int invoice)throws SQLException {
  try(PreparedStatement p=c.prepareStatement("SELECT COALESCE(SUM(Refund_Amount),0) FROM Refund_Request WHERE Invoice_ID=? AND Status='Completed'")){p.setInt(1,invoice);try(ResultSet r=p.executeQuery()){r.next();return r.getLong(1);}}
 }
 private static Connection borrowed(Connection c){return (Connection)java.lang.reflect.Proxy.newProxyInstance(Connection.class.getClassLoader(),new Class[]{Connection.class},(o,m,a)->{if(m.getName().equals("close"))return null;try{return m.invoke(c,a);}catch(java.lang.reflect.InvocationTargetException e){throw e.getCause();}});}
 private static String procedureUnused="po.Status IN ('Pending','Cancelled') AND po.Completed_At IS NULL AND NULLIF(LTRIM(RTRIM(po.Result_Text)),N'') IS NULL AND NULLIF(LTRIM(RTRIM(po.Result_Conclusion)),N'') IS NULL";
 public List<Map<String,Object>> candidates(int invoice)throws Exception {try(Connection c=connections.open()){return candidates(c,invoice,0);}}
 private Map<String,Object> candidate(String key,String name,String type,int quantity,long price){Map<String,Object> m=new HashMap<>();m.put("key",key);m.put("name",name);m.put("type",type);m.put("quantity",quantity);m.put("unitPrice",price);return m;}
 List<Map<String,Object>> candidates(Connection c,int invoice,int excludeRefund)throws SQLException {
  try(PreparedStatement p=c.prepareStatement("SELECT 1 FROM Master_Invoice i WHERE i.Invoice_ID=? AND i.Status IN ('Paid','Partial_Paid') AND NOT EXISTS(SELECT 1 FROM Invoice_Checkout_Payment cp WHERE cp.Invoice_ID=i.Invoice_ID AND cp.Status IN ('Creating','Pending'))")){p.setInt(1,invoice);try(ResultSet r=p.executeQuery()){if(!r.next())return List.of();}}
  Map<String,Map<String,Object>> available=new LinkedHashMap<>();
  // Final cashier snapshots prove that the selected medicine line was paid, at its historical price.
  String sql="SELECT ci.Item_Key,ci.Item_Name,ci.Quantity,ci.Unit_Price FROM Invoice_Checkout_Item ci JOIN Invoice_Checkout co ON co.Invoice_ID=ci.Invoice_ID JOIN Master_Invoice i ON i.Invoice_ID=ci.Invoice_ID WHERE ci.Invoice_ID=? AND co.Finalized_At IS NOT NULL AND i.Status='Paid' AND co.Opening_Paid+COALESCE((SELECT SUM(tx.Amount) FROM Payment_Transaction tx WHERE tx.Invoice_ID=i.Invoice_ID AND tx.Gateway_Status='Success'),0)>=(SELECT COALESCE(SUM(s.Quantity*s.Unit_Price),0) FROM Invoice_Checkout_Item s WHERE s.Invoice_ID=i.Invoice_ID AND s.Declined=0) AND ci.Declined=0 AND ci.Unpriced=0 AND ci.Unit_Price>0 AND (ci.Item_Key LIKE 'MEDICINE:%' OR ci.Item_Key LIKE 'PROCEDURE:%')";
  try(PreparedStatement p=c.prepareStatement(sql)){p.setInt(1,invoice);try(ResultSet r=p.executeQuery()){while(r.next()){String key=r.getString(1);boolean medicine=key.startsWith("MEDICINE:");if(!medicine&&!unused(c,Integer.parseInt(key.substring(10))))continue;available.put(key,candidate(key,r.getString(2),medicine?"Medicine":"Procedure",r.getInt(3),r.getLong(4)));}}}
  // A separately paid surgery may be refunded before the visit itself is finished.
  sql="SELECT po.Order_ID,s.Service_Name,pr.Amount FROM Procedure_Order po JOIN Medical_Record mr ON mr.Record_ID=po.Record_ID JOIN Master_Invoice i ON i.Appointment_ID=mr.Appointment_ID JOIN Procedure_Payment_Request pr ON pr.Order_ID=po.Order_ID JOIN Payment_Transaction tx ON tx.Transaction_ID=pr.Transaction_ID AND tx.Invoice_ID=i.Invoice_ID JOIN Service_Catalog s ON s.Service_ID=po.Service_ID WHERE i.Invoice_ID=? AND pr.Status='Paid' AND pr.Amount>0 AND tx.Gateway_Status='Success' AND tx.Amount>=pr.Amount AND "+procedureUnused;
  try(PreparedStatement p=c.prepareStatement(sql)){p.setInt(1,invoice);try(ResultSet r=p.executeQuery()){while(r.next()){String key="PROCEDURE:"+r.getInt(1);available.putIfAbsent(key,candidate(key,r.getString(2),"Procedure",1,r.getLong(3)));}}}
  try(PreparedStatement p=c.prepareStatement("SELECT ri.Item_Key,SUM(ri.Quantity) FROM Refund_Request_Item ri JOIN Refund_Request rr ON rr.Refund_ID=ri.Refund_ID WHERE rr.Invoice_ID=? AND rr.Refund_ID<>? AND rr.Status IN ('Pending','Approved','Completed') GROUP BY ri.Item_Key")){p.setInt(1,invoice);p.setInt(2,excludeRefund);try(ResultSet r=p.executeQuery()){while(r.next()){Map<String,Object> m=available.get(r.getString(1));if(m!=null)m.put("quantity",(Integer)m.get("quantity")-r.getInt(2));}}}
  available.values().removeIf(m->(Integer)m.get("quantity")<=0);
  return new ArrayList<>(available.values());
 }
 private boolean unused(Connection c,int order)throws SQLException {
  try(PreparedStatement p=c.prepareStatement("SELECT 1 FROM Procedure_Order po WHERE po.Order_ID=? AND "+procedureUnused)){p.setInt(1,order);try(ResultSet r=p.executeQuery()){return r.next();}}
 }
 private void lockInvoice(Connection c,int invoice)throws SQLException {
  try(PreparedStatement p=c.prepareStatement("SELECT a.Appointment_ID FROM Appointment a WITH(UPDLOCK,HOLDLOCK) JOIN Master_Invoice i WITH(UPDLOCK,HOLDLOCK) ON i.Appointment_ID=a.Appointment_ID WHERE i.Invoice_ID=?")){p.setInt(1,invoice);try(ResultSet r=p.executeQuery()){if(!r.next())throw new IllegalArgumentException("Không tìm thấy hóa đơn.");}}
 }
 public int create(int invoice,int employee,Map<String,Integer> requested,String reason,boolean unusedConfirmed)throws Exception {
  if(!unusedConfirmed||requested==null||requested.isEmpty()||requested.size()>100||reason==null||reason.isBlank()||reason.length()>1000)throw new IllegalArgumentException("Chọn khoản cần hoàn, nhập lý do và xác nhận đã đối chiếu thuốc chưa giao / thủ thuật chưa thực hiện.");
  try(Connection c=connections.open()){c.setAutoCommit(false);c.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE);try{
   if(!employeeRole(c,employee,1,5))throw new IllegalArgumentException("Chỉ staff được tạo yêu cầu hoàn khoản phát sinh.");lockInvoice(c,invoice);
   try(PreparedStatement p=c.prepareStatement("SELECT 1 FROM Refund_Request WHERE Invoice_ID=? AND Status IN ('Pending','Approved')")){p.setInt(1,invoice);try(ResultSet r=p.executeQuery()){if(r.next())throw new IllegalArgumentException("Hóa đơn đang có yêu cầu chờ duyệt / chờ chi trả. Cần giải quyết yêu cầu đó trước.");}}
   Map<String,Map<String,Object>> choices=new HashMap<>();for(Map<String,Object> m:candidates(c,invoice,0))choices.put((String)m.get("key"),m);
   long amount=0;for(var entry:requested.entrySet()){var line=choices.get(entry.getKey());if(line==null||entry.getValue()==null||entry.getValue()<=0||entry.getValue()>(Integer)line.get("quantity"))throw new IllegalArgumentException("Khoản chưa thanh toán, đã sử dụng / đã hoàn hoặc số lượng không hợp lệ.");amount=Math.addExact(amount,Math.multiplyExact((Long)line.get("unitPrice"),entry.getValue()));}
   if(amount<=0||amount>received(c,invoice)-refunded(c,invoice))throw new IllegalArgumentException("Số tiền hoàn vượt số tiền thực thu còn lại.");
   int patient;try(PreparedStatement p=c.prepareStatement("SELECT a.Patient_ID FROM Appointment a JOIN Master_Invoice i ON i.Appointment_ID=a.Appointment_ID WHERE i.Invoice_ID=?")){p.setInt(1,invoice);try(ResultSet r=p.executeQuery()){r.next();patient=r.getInt(1);}}
   int id;try(PreparedStatement p=c.prepareStatement("INSERT INTO Refund_Request(Invoice_ID,created_by_employee_id,Patient_ID,Refund_Amount,Reason,Status,Created_At,Update_At,Request_Kind,Unused_Checked_By,Unused_Checked_At) VALUES(?,?,?,?,?,'Pending',SYSUTCDATETIME(),SYSUTCDATETIME(),'Items',?,SYSUTCDATETIME())",Statement.RETURN_GENERATED_KEYS)){p.setInt(1,invoice);p.setInt(2,employee);p.setInt(3,patient);p.setLong(4,amount);p.setString(5,reason);p.setInt(6,employee);p.executeUpdate();try(ResultSet r=p.getGeneratedKeys()){r.next();id=r.getInt(1);}}
   StaffInvoiceDAO.Connections source=()->borrowed(c);com.visioncare.model.StaffInvoice bill=new StaffInvoiceDAO(source).get(invoice);
   try(PreparedStatement p=c.prepareStatement("IF NOT EXISTS(SELECT 1 FROM Invoice_Checkout WHERE Invoice_ID=?) INSERT INTO Invoice_Checkout(Invoice_ID,Base_Amount,Opening_Paid) VALUES(?,?,?)")){p.setInt(1,invoice);p.setInt(2,invoice);p.setLong(3,bill.baseAmount);p.setLong(4,bill.priorPaid);p.executeUpdate();}
   for(var entry:requested.entrySet()){
    var line=choices.get(entry.getKey());
    try(PreparedStatement p=c.prepareStatement("INSERT INTO Refund_Request_Item(Refund_ID,Item_Key,Item_Name,Item_Type,Quantity,Unit_Price) VALUES(?,?,?,?,?,?)")){p.setInt(1,id);p.setString(2,entry.getKey());p.setString(3,(String)line.get("name"));p.setString(4,(String)line.get("type"));p.setInt(5,entry.getValue());p.setLong(6,(Long)line.get("unitPrice"));p.executeUpdate();}
    // Retain the original paid charge when its unused procedure is removed from the clinical queue.
    try(PreparedStatement p=c.prepareStatement("IF NOT EXISTS(SELECT 1 FROM Invoice_Checkout_Item WHERE Invoice_ID=? AND Item_Key=?) INSERT INTO Invoice_Checkout_Item(Invoice_ID,Item_Key,Item_Name,Item_Type,Quantity,Unit_Price,Removable,Changed_By) VALUES(?,?,?,?,?,?,0,?)")){p.setInt(1,invoice);p.setString(2,entry.getKey());p.setInt(3,invoice);p.setString(4,entry.getKey());p.setString(5,(String)line.get("name"));p.setString(6,(String)line.get("type"));p.setInt(7,((String)line.get("type")).equals("Procedure")?1:(Integer)line.get("quantity"));p.setLong(8,(Long)line.get("unitPrice"));p.setInt(9,employee);p.executeUpdate();}
    if(entry.getKey().startsWith("PROCEDURE:"))try(PreparedStatement p=c.prepareStatement("UPDATE Procedure_Order SET Status='Cancelled' WHERE Order_ID=? AND Status IN ('Pending','Cancelled') AND Completed_At IS NULL")){p.setInt(1,Integer.parseInt(entry.getKey().substring(10)));if(p.executeUpdate()!=1)throw new IllegalStateException("Thủ thuật đã được thực hiện. Hãy tải lại.");}
   }
   c.commit();return id;
  }catch(Exception e){c.rollback();throw e;}}
 }
 public boolean valid(Connection c,int id)throws Exception {
  int invoice;long amount;
  try(PreparedStatement p=c.prepareStatement("SELECT Invoice_ID,Refund_Amount FROM Refund_Request WHERE Refund_ID=? AND Request_Kind='Items' AND Unused_Checked_By IS NOT NULL AND Unused_Checked_At IS NOT NULL")){p.setInt(1,id);try(ResultSet r=p.executeQuery()){if(!r.next())return false;invoice=r.getInt(1);amount=r.getLong(2);}}
  lockInvoice(c,invoice);Map<String,Map<String,Object>> choices=new HashMap<>();for(var m:candidates(c,invoice,id))choices.put((String)m.get("key"),m);
  long total=0;int count=0;for(var m:lines(c,id)){var choice=choices.get((String)m.get("key"));if(choice==null||(Integer)m.get("quantity")>(Integer)choice.get("quantity")||!m.get("unitPrice").equals(choice.get("unitPrice")))return false;total=Math.addExact(total,(Long)m.get("amount"));count++;}
  return count>0&&total==amount&&amount<=received(c,invoice)-refunded(c,invoice);
 }
 public static List<Map<String,Object>> lines(Connection c,int id)throws SQLException {
  List<Map<String,Object>> result=new ArrayList<>();try(PreparedStatement p=c.prepareStatement("SELECT Item_Key,Item_Name,Quantity,Unit_Price FROM Refund_Request_Item WHERE Refund_ID=? ORDER BY Item_Key")){p.setInt(1,id);try(ResultSet r=p.executeQuery()){while(r.next()){Map<String,Object> m=new HashMap<>();m.put("key",r.getString(1));m.put("name",r.getString(2));m.put("quantity",r.getInt(3));m.put("unitPrice",r.getLong(4));m.put("amount",Math.multiplyExact(r.getLong(4),r.getInt(3)));result.add(m);}}}return result;
 }
}
