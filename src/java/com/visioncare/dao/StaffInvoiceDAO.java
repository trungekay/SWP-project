package com.visioncare.dao;

import com.visioncare.model.StaffInvoice;
import com.visioncare.model.StaffInvoice.Item;
import com.visioncare.model.InvoiceProgress;
import java.sql.*;
import java.util.*;
import java.security.SecureRandom;

public class StaffInvoiceDAO {
 @FunctionalInterface public interface Connections {Connection open() throws Exception;}
 private final Connections connections;
 public StaffInvoiceDAO(){this(DBContext::getConnection);}
 public StaffInvoiceDAO(Connections connections){this.connections=connections;}
 public List<Map<String,Object>> list(String search,String status,String date) throws Exception {
  String sql="SELECT a.Appointment_ID,p.Full_Name,p.Phone,ws.Work_Date,a.Status AS Appointment_Status,i.Invoice_ID,i.Status,i.Total_Amount,i.Balance_Due,co.Finalized_At,CASE WHEN EXISTS(SELECT 1 FROM Refund_Request rr WHERE rr.Invoice_ID=i.Invoice_ID AND rr.Status IN ('Pending','Approved')) THEN 1 ELSE 0 END AS Has_Refund,CASE WHEN EXISTS(SELECT 1 FROM Payment_Transaction pt WHERE pt.Invoice_ID=i.Invoice_ID AND pt.Gateway_Status='Success' AND pt.Amount>0) OR co.Opening_Paid>0 THEN 1 ELSE 0 END AS Has_Payment "
   +"FROM Appointment a JOIN Patient p ON p.Patient_ID=a.Patient_ID JOIN Work_Schedule ws ON ws.Schedule_ID=a.Schedule_ID "
   +"LEFT JOIN Master_Invoice i ON i.Appointment_ID=a.Appointment_ID LEFT JOIN Invoice_Checkout co ON co.Invoice_ID=i.Invoice_ID WHERE 1=1 ";
  List<Object> params=new ArrayList<>();
  if(search!=null&&!search.isBlank()){sql+="AND (p.Full_Name LIKE ? OR p.Phone LIKE ? OR CAST(a.Appointment_ID AS varchar) = ? OR CAST(i.Invoice_ID AS varchar) = ?) ";String clean=search.trim().replaceFirst("(?i)^#?(?:APT-|INV-)","");params.add("%"+search.trim()+"%");params.add("%"+search.trim()+"%");params.add(clean.replaceFirst("^0+(?!$)",""));params.add(clean.replaceFirst("^0+(?!$)",""));}
  // Filter the same derived progress displayed in the list, rather than the legacy financial status.
  if(date!=null&&!date.isBlank()){sql+="AND ws.Work_Date=? ";params.add(java.sql.Date.valueOf(date));}
  sql+="ORDER BY ws.Work_Date DESC,a.Appointment_ID DESC";
  List<Map<String,Object>> rows=new ArrayList<>();
  try(Connection c=connections.open();PreparedStatement ps=c.prepareStatement(sql)){for(int n=0;n<params.size();n++)ps.setObject(n+1,params.get(n));try(ResultSet r=ps.executeQuery()){while(r.next()){Map<String,Object> m=new HashMap<>();m.put("appointmentId",r.getInt("Appointment_ID"));m.put("patient",r.getString("Full_Name"));m.put("phone",r.getString("Phone"));m.put("date",r.getDate("Work_Date"));m.put("appointmentStatus",r.getString("Appointment_Status"));m.put("invoiceId",r.getInt("Invoice_ID"));m.put("status",r.getString("Status"));m.put("total",r.getLong("Total_Amount"));m.put("due",r.getLong("Balance_Due"));m.put("finalized",r.getTimestamp("Finalized_At")!=null);
   String financial=r.getString("Status");
   boolean collected="Paid".equals(financial)||"Partial_Paid".equals(financial)||r.getBoolean("Has_Payment");
   InvoiceProgress progress=InvoiceProgress.resolve(r.getInt("Invoice_ID")>0,r.getString("Appointment_Status"),financial,r.getTimestamp("Finalized_At")!=null,collected);
   m.put("progress",progress.name());m.put("progressLabel",progress.getLabel());m.put("progressColor",progress.getColor());
   m.put("canOpenCheckout",progress==InvoiceProgress.Examined && !r.getBoolean("Has_Refund"));
   if(status==null||status.isBlank()||"all".equals(status)||progress.name().equals(status))rows.add(m);
  }}}return rows;
 }
 public int invoiceForAppointment(int appointmentId)throws Exception {
  try(Connection c=connections.open();PreparedStatement ps=c.prepareStatement("SELECT Invoice_ID FROM Master_Invoice WHERE Appointment_ID=?")){ps.setInt(1,appointmentId);try(ResultSet r=ps.executeQuery()){if(r.next())return r.getInt(1);}}throw new IllegalArgumentException("Lịch hẹn chưa có hóa đơn. Cần kiểm tra khoản thu trước khi thanh toán.");
 }
 public StaffInvoice get(int id) throws Exception {try(Connection c=connections.open()){return load(c,id,false);}}
 private StaffInvoice load(Connection c,int id,boolean lock) throws Exception {
  String sql="SELECT i.*,a.Status AS Appointment_Status,p.Full_Name,p.Phone,ws.Work_Date,co.Base_Amount,co.Opening_Paid,co.Finalized_At,(SELECT ce.Full_Name FROM Employee_Profile ce WHERE ce.Employee_ID=co.Finalized_By) AS Cashier_Name, "
   +"CASE WHEN EXISTS(SELECT 1 FROM Refund_Request rr WHERE rr.Invoice_ID=i.Invoice_ID AND rr.Status IN ('Pending','Approved')) THEN 1 ELSE 0 END AS Has_Refund "
   +"FROM Master_Invoice i "+(lock?"WITH(UPDLOCK,HOLDLOCK) ":"")+"JOIN Appointment a "+(lock?"WITH(UPDLOCK,HOLDLOCK) ":"")+"ON a.Appointment_ID=i.Appointment_ID JOIN Patient p ON p.Patient_ID=a.Patient_ID JOIN Work_Schedule ws ON ws.Schedule_ID=a.Schedule_ID "
   +"LEFT JOIN Invoice_Checkout co ON co.Invoice_ID=i.Invoice_ID WHERE i.Invoice_ID=?";
  StaffInvoice inv=new StaffInvoice();boolean hasSnapshot=false;long recognizedPaid=0;
  try(PreparedStatement ps=c.prepareStatement(sql)){ps.setInt(1,id);try(ResultSet r=ps.executeQuery()){if(!r.next())throw new IllegalArgumentException("Không tìm thấy hóa đơn.");inv.id=id;inv.appointmentId=r.getInt("Appointment_ID");inv.appointmentStatus=r.getString("Appointment_Status");inv.invoiceStatus=r.getString("Status");inv.recordedTotal=r.getLong("Total_Amount");inv.patientName=r.getString("Full_Name");inv.phone=r.getString("Phone");inv.date=String.valueOf(r.getDate("Work_Date"));inv.hasActiveRefund=r.getBoolean("Has_Refund");inv.finalized=r.getTimestamp("Finalized_At")!=null;inv.cashierName=r.getString("Cashier_Name");inv.finalizedAt=inv.finalized?r.getTimestamp("Finalized_At").toLocalDateTime().plusHours(7).format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm")):null;hasSnapshot=r.getObject("Base_Amount")!=null;inv.priorPaid=r.getLong("Opening_Paid");recognizedPaid="Paid".equals(inv.invoiceStatus)?inv.recordedTotal:"Partial_Paid".equals(inv.invoiceStatus)?Math.max(0,inv.recordedTotal-r.getLong("Balance_Due")):0;inv.baseAmount=r.getObject("Base_Amount")!=null?r.getLong("Base_Amount"):(r.getLong("Deposit_Amount")>0?r.getLong("Deposit_Amount"):r.getLong("Total_Amount"));}}
  try(PreparedStatement ps=c.prepareStatement("SELECT Transaction_ID,Amount,Gateway_Status,Payment_Gateway,Trans_Date FROM Payment_Transaction WHERE Invoice_ID=? ORDER BY Transaction_ID")){ps.setInt(1,id);try(ResultSet r=ps.executeQuery()){while(r.next()){long amount=r.getLong("Amount");if("Success".equals(r.getString("Gateway_Status")))inv.paid=Math.addExact(inv.paid,amount);Map<String,Object> tx=new HashMap<>();tx.put("id",r.getInt("Transaction_ID"));tx.put("amount",amount);tx.put("status",r.getString("Gateway_Status"));tx.put("method",r.getString("Payment_Gateway"));tx.put("date",r.getTimestamp("Trans_Date"));inv.transactions.add(tx);}}}
  if(!hasSnapshot)inv.priorPaid=Math.max(0,recognizedPaid-inv.paid);
  inv.paid=Math.addExact(inv.paid,inv.priorPaid);
  Map<String,Item> saved=new LinkedHashMap<>();
  try(PreparedStatement ps=c.prepareStatement("SELECT * FROM Invoice_Checkout_Item WHERE Invoice_ID=? ORDER BY Item_Key")){ps.setInt(1,id);try(ResultSet r=ps.executeQuery()){while(r.next()){Item item=new Item(r.getString("Item_Key"),r.getString("Item_Name"),r.getString("Item_Type"),r.getInt("Quantity"),r.getLong("Unit_Price"),r.getBoolean("Removable"),r.getBoolean("Unpriced"),false);item.declined=r.getBoolean("Declined");saved.put(item.key,item);}}}
  if(inv.finalized)inv.items.addAll(saved.values());
  else if("Canceled".equals(inv.appointmentStatus)||"Canceled".equals(inv.invoiceStatus)||"Refunded".equals(inv.invoiceStatus))inv.items.add(new Item("RECORDED","Giá trị hóa đơn đã ghi nhận","Hóa đơn hủy / Hoàn tiền",1,inv.recordedTotal,false,false,false));
  else {
   inv.items.add(new Item("CONSULT","Phí khám / đăng ký khám","Khám bệnh",1,inv.baseAmount,false,false,false));
   sql="SELECT po.Order_ID,s.Service_Name,po.Actual_Price,po.Status,pr.Status AS Request_Status,COALESCE(pr.Credit_Amount,0) AS Credit_Amount FROM Procedure_Order po JOIN Medical_Record mr ON mr.Record_ID=po.Record_ID JOIN Service_Catalog s ON s.Service_ID=po.Service_ID LEFT JOIN Procedure_Payment_Request pr ON pr.Order_ID=po.Order_ID WHERE mr.Appointment_ID=? AND po.Status<>'Cancelled' AND s.Service_ID<>1 AND s.Service_Name<>N'Khám mắt tổng quát' ORDER BY po.Order_ID";
   try(PreparedStatement ps=c.prepareStatement(sql)){ps.setInt(1,inv.appointmentId);try(ResultSet r=ps.executeQuery()){while(r.next()){boolean pending="Pending".equals(r.getString("Status"));long price=r.getLong("Actual_Price")-r.getLong("Credit_Amount");if(price<0)throw new IllegalStateException("Phí thủ thuật thấp hơn khoản đã khấu trừ.");inv.items.add(new Item("PROCEDURE:"+r.getInt("Order_ID"),r.getString("Service_Name"),"Thủ thuật",1,price,pending&&!"Paid".equals(r.getString("Request_Status")),false,pending));}}}
   sql="SELECT pd.Detail_ID,pd.Medicine_Name,pd.Quantity,pd.Is_Custom_Medicine,ms.Price FROM Prescription_Detail pd JOIN Prescription pr ON pr.Prescription_ID=pd.Prescription_ID JOIN Medical_Record mr ON mr.Record_ID=pr.Record_ID OUTER APPLY(SELECT TOP 1 Price FROM Medical_Supply s WHERE s.Supply_Name=pd.Medicine_Name ORDER BY s.Supply_ID) ms WHERE mr.Appointment_ID=? ORDER BY pd.Detail_ID";
   try(PreparedStatement ps=c.prepareStatement(sql)){ps.setInt(1,inv.appointmentId);try(ResultSet r=ps.executeQuery()){while(r.next())inv.items.add(new Item("MEDICINE:"+r.getInt("Detail_ID"),r.getString("Medicine_Name"),"Thuốc / Vật tư",r.getInt("Quantity"),r.getLong("Price"),true,r.getObject("Price")==null,false));}}
   Set<String> live=new HashSet<>();for(Item i:inv.items){live.add(i.key);Item old=saved.get(i.key);if(old!=null&&old.declined)i.declined=true;}
   for(Item i:saved.values())if(i.declined&&!live.contains(i.key))inv.items.add(i);
  }
  inv.activePayment=active(c,id);
  return inv;
 }
 private Map<String,Object> active(Connection c,int id)throws Exception{
  try(PreparedStatement ps=c.prepareStatement("SELECT * FROM Invoice_Checkout_Payment WHERE Invoice_ID=? AND Status IN ('Creating','Pending') ORDER BY Created_At DESC")){ps.setInt(1,id);try(ResultSet r=ps.executeQuery()){return r.next()?paymentRow(r):null;}}
 }
 private Map<String,Object> paymentRow(ResultSet r)throws Exception {Map<String,Object> m=new HashMap<>();m.put("orderCode",r.getLong("Order_Code"));m.put("invoiceId",r.getInt("Invoice_ID"));m.put("amount",r.getLong("Amount"));m.put("fingerprint",r.getString("Fingerprint"));m.put("status",r.getString("Status"));m.put("url",r.getString("Checkout_Url"));m.put("qr",r.getString("QR_Code"));m.put("employeeId",r.getInt("Created_By"));return m;}
 public Map<String,Object> payment(long order)throws Exception{try(Connection c=connections.open();PreparedStatement ps=c.prepareStatement("SELECT * FROM Invoice_Checkout_Payment WHERE Order_Code=?")){ps.setLong(1,order);try(ResultSet r=ps.executeQuery()){return r.next()?paymentRow(r):null;}}}
 private void expect(StaffInvoice inv,String expected){if(expected==null||!inv.fingerprint().equals(expected))throw new IllegalStateException("Hóa đơn đã thay đổi. Hãy tải lại và kiểm tra số tiền trước khi tiếp tục.");}
 private void editable(StaffInvoice inv){if(!inv.isCanEdit())throw new IllegalStateException("Chỉ cập nhật hóa đơn khi đã kết thúc khám, không có yêu cầu hoàn tiền hoặc QR đang chờ xử lý.");}
 private void ready(StaffInvoice inv){editable(inv);if(!inv.isCanCheckout())throw new IllegalStateException("Hãy xử lý khoản chưa định giá, dịch vụ chưa thực hiện hoặc tiền thu thừa trước khi thanh toán.");}
 private void snapshot(Connection c,StaffInvoice inv,int employee)throws Exception {
  try(PreparedStatement ps=c.prepareStatement("IF NOT EXISTS(SELECT 1 FROM Invoice_Checkout WHERE Invoice_ID=?) INSERT INTO Invoice_Checkout(Invoice_ID,Base_Amount,Opening_Paid) VALUES(?,?,?)")){ps.setInt(1,inv.id);ps.setInt(2,inv.id);ps.setLong(3,inv.baseAmount);ps.setLong(4,inv.priorPaid);ps.executeUpdate();}
  try(PreparedStatement ps=c.prepareStatement("DELETE FROM Invoice_Checkout_Item WHERE Invoice_ID=?")){ps.setInt(1,inv.id);ps.executeUpdate();}
  try(PreparedStatement ps=c.prepareStatement("INSERT INTO Invoice_Checkout_Item(Invoice_ID,Item_Key,Item_Name,Item_Type,Quantity,Unit_Price,Removable,Declined,Unpriced,Changed_By) VALUES(?,?,?,?,?,?,?,?,?,?)")){for(Item item:inv.items){ps.setInt(1,inv.id);ps.setString(2,item.key);ps.setString(3,item.name);ps.setString(4,item.type);ps.setInt(5,item.quantity);ps.setLong(6,item.unitPrice);ps.setBoolean(7,item.removable);ps.setBoolean(8,item.declined);ps.setBoolean(9,item.unpriced);ps.setInt(10,employee);ps.addBatch();}ps.executeBatch();}
 }
 private void updateTotal(Connection c,StaffInvoice inv)throws Exception {
  try(PreparedStatement ps=c.prepareStatement("UPDATE Master_Invoice SET Total_Amount=?, Deposit_Amount=CASE WHEN COALESCE(Deposit_Amount,0)>? THEN ? ELSE Deposit_Amount END,Balance_Due=?,Status=?,Close_At=CASE WHEN ?=0 THEN Close_At ELSE NULL END WHERE Invoice_ID=?")){long total=inv.getTotal();ps.setLong(1,total);ps.setLong(2,total);ps.setLong(3,total);ps.setLong(4,inv.getDue());ps.setString(5,inv.getDue()==0?"Paid":inv.paid>0?"Partial_Paid":"Unpaid");ps.setLong(6,inv.getDue());ps.setInt(7,inv.id);ps.executeUpdate();}
 }
 public void decline(int id,String key,int employee,String expected)throws Exception {
  try(Connection c=connections.open()){c.setAutoCommit(false);c.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE);try{StaffInvoice inv=load(c,id,true);expect(inv,expected);editable(inv);Item chosen=inv.items.stream().filter(i->i.key.equals(key)).findFirst().orElseThrow(()->new IllegalArgumentException("Không tìm thấy khoản thu."));if(!chosen.removable||chosen.declined)throw new IllegalArgumentException("Không được bỏ khoản đã thực hiện hoặc đã thanh toán riêng.");chosen.declined=true;if(inv.getOverpaid()>0)throw new IllegalStateException("Khoản tiền đã thu vượt tổng mới. Cần xử lý hoàn tiền, không được xóa khoản thu.");
   if(key.startsWith("PROCEDURE:")){try(PreparedStatement ps=c.prepareStatement("UPDATE Procedure_Order SET Status='Cancelled' WHERE Order_ID=? AND Status='Pending' AND NOT EXISTS(SELECT 1 FROM Procedure_Payment_Request pr WHERE pr.Order_ID=Procedure_Order.Order_ID AND pr.Status='Paid')")){ps.setInt(1,Integer.parseInt(key.substring(10)));if(ps.executeUpdate()!=1)throw new IllegalStateException("Dịch vụ đã được xử lý. Hãy tải lại hóa đơn.");}}
   snapshot(c,inv,employee);updateTotal(c,inv);c.commit();}catch(Exception e){c.rollback();throw e;}}
 }
 private void finalizeInvoice(Connection c,StaffInvoice inv,int employee,String method,long amount,Long order)throws Exception {
  if(amount>0){int tx;try(PreparedStatement ps=c.prepareStatement("INSERT INTO Payment_Transaction(Invoice_ID,Amount,Gateway_Status,Payment_Gateway,Trans_Date) VALUES(?,?,'Success',?,SYSUTCDATETIME())",Statement.RETURN_GENERATED_KEYS)){ps.setInt(1,inv.id);ps.setLong(2,amount);ps.setString(3,method);ps.executeUpdate();try(ResultSet r=ps.getGeneratedKeys()){r.next();tx=r.getInt(1);}}
   if(order!=null)try(PreparedStatement ps=c.prepareStatement("UPDATE Invoice_Checkout_Payment SET Status='Paid',Transaction_ID=?,Updated_At=SYSUTCDATETIME() WHERE Order_Code=? AND Status='Pending'")){ps.setInt(1,tx);ps.setLong(2,order);if(ps.executeUpdate()!=1)throw new IllegalStateException("Yêu cầu QR đã được xử lý.");}
  }
  snapshot(c,inv,employee);
  try(PreparedStatement ps=c.prepareStatement("UPDATE Master_Invoice SET Total_Amount=?,Deposit_Amount=?,Balance_Due=0,Status='Paid',Close_At=SYSUTCDATETIME() WHERE Invoice_ID=?")){ps.setLong(1,inv.getTotal());ps.setLong(2,inv.getTotal());ps.setInt(3,inv.id);ps.executeUpdate();}
  try(PreparedStatement ps=c.prepareStatement("UPDATE Invoice_Checkout SET Finalized_At=SYSUTCDATETIME(),Finalized_By=?,Payment_Method=? WHERE Invoice_ID=? AND Finalized_At IS NULL")){ps.setInt(1,employee);ps.setString(2,method);ps.setInt(3,inv.id);if(ps.executeUpdate()!=1)throw new IllegalStateException("Hóa đơn đã được chốt.");}
 }
 private String lastPaidMethod(Connection c,int invoiceId)throws Exception {
  try(PreparedStatement ps=c.prepareStatement("SELECT TOP 1 Payment_Gateway FROM Payment_Transaction WHERE Invoice_ID=? AND Gateway_Status='Success' ORDER BY Transaction_ID DESC")){
   ps.setInt(1,invoiceId);try(ResultSet rs=ps.executeQuery()){return rs.next()?com.visioncare.util.PaymentMethod.canonical(rs.getString(1)):null;}
  }
 }
 public void cash(int id,int employee,String expected)throws Exception {
  try(Connection c=connections.open()){c.setAutoCommit(false);c.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE);try{StaffInvoice inv=load(c,id,true);expect(inv,expected);ready(inv);finalizeInvoice(c,inv,employee,inv.getDue()==0?lastPaidMethod(c,id):"Cash",inv.getDue(),null);c.commit();}catch(Exception e){c.rollback();throw e;}}
 }
 public Map<String,Object> reserveQr(int id,int employee,String expected)throws Exception {
  try(Connection c=connections.open()){c.setAutoCommit(false);c.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE);try{StaffInvoice inv=load(c,id,true);expect(inv,expected);ready(inv);if(inv.getDue()<=0||inv.getDue()>Integer.MAX_VALUE)throw new IllegalArgumentException("Số tiền không hợp lệ để tạo mã QR.");snapshot(c,inv,employee);updateTotal(c,inv);
   // Fingerprint after recalculating the persisted master invoice status.
   inv=load(c,id,true);long order=900000000000000L+new SecureRandom().nextLong(90000000000000L);
   try(PreparedStatement ps=c.prepareStatement("INSERT INTO Invoice_Checkout_Payment(Order_Code,Invoice_ID,Amount,Fingerprint,Status,Created_By) VALUES(?,?,?,?,'Creating',?)")){ps.setLong(1,order);ps.setInt(2,id);ps.setLong(3,inv.getDue());ps.setString(4,inv.fingerprint());ps.setInt(5,employee);ps.executeUpdate();}Map<String,Object> row=active(c,id);c.commit();return row;
  }catch(Exception e){c.rollback();throw e;}}
 }
 public void qrCreated(long order,String url,String qr)throws Exception {try(Connection c=connections.open();PreparedStatement ps=c.prepareStatement("UPDATE Invoice_Checkout_Payment SET Status=?,Checkout_Url=?,QR_Code=?,Updated_At=SYSUTCDATETIME() WHERE Order_Code=? AND Status='Creating'")){ps.setString(1,url==null?"Failed":"Pending");ps.setString(2,url);ps.setString(3,qr);ps.setLong(4,order);ps.executeUpdate();}}
 public void cancelledQr(long order)throws Exception{try(Connection c=connections.open();PreparedStatement ps=c.prepareStatement("UPDATE Invoice_Checkout_Payment SET Status='Cancelled',Updated_At=SYSUTCDATETIME() WHERE Order_Code=? AND Status IN ('Pending','Creating')")){ps.setLong(1,order);ps.executeUpdate();}}
 /** Only called after a server-to-server PayOS receipt verifies order, amount and PAID status. */
 public void confirmQr(long order,long verifiedAmount)throws Exception {
  Map<String,Object> pay=payment(order);if(pay==null)throw new IllegalArgumentException("Không tìm thấy yêu cầu thanh toán.");if("Paid".equals(pay.get("status")))return;
  try(Connection c=connections.open()){c.setAutoCommit(false);c.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE);try{StaffInvoice inv=load(c,(Integer)pay.get("invoiceId"),true);pay=paymentOn(c,order);if("Paid".equals(pay.get("status"))){c.commit();return;}
   if(!"Pending".equals(pay.get("status"))||verifiedAmount!=(Long)pay.get("amount")||inv.getDue()!=verifiedAmount||inv.isBlocked()||!inv.isClinicalComplete()||inv.finalized)throw new IllegalStateException("Giao dịch không khớp hóa đơn hiện tại.");
   expect(inv,(String)pay.get("fingerprint"));finalizeInvoice(c,inv,(Integer)pay.get("employeeId"),"QR_Banking",verifiedAmount,order);c.commit();
  }catch(Exception e){c.rollback();throw e;}}
 }
 private Map<String,Object> paymentOn(Connection c,long order)throws Exception{try(PreparedStatement ps=c.prepareStatement("SELECT * FROM Invoice_Checkout_Payment WITH(UPDLOCK,HOLDLOCK) WHERE Order_Code=?")){ps.setLong(1,order);try(ResultSet r=ps.executeQuery()){if(!r.next())throw new IllegalArgumentException("Không tìm thấy mã QR.");return paymentRow(r);}}}
}
