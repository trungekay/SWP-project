import com.visioncare.dao.*;
import com.visioncare.model.StaffInvoice;
import com.visioncare.util.*;
import java.sql.*;
import java.lang.reflect.*;
import java.util.*;

/** Integration fixtures live inside one outer transaction and are always rolled back. No real gateway is called. */
public class StaffCheckoutTest {
 interface Operation {void run()throws Exception;}
 static int checks=0;
 static void check(boolean ok,String message){if(!ok)throw new AssertionError(message);checks++;}
 static void reject(Operation op,String message)throws Exception{try{op.run();throw new AssertionError(message);}catch(IllegalArgumentException|IllegalStateException expected){checks++;}}
 static int insert(Connection c,String sql,Object... values)throws Exception{try(PreparedStatement ps=c.prepareStatement(sql,Statement.RETURN_GENERATED_KEYS)){for(int n=0;n<values.length;n++)ps.setObject(n+1,values[n]);ps.executeUpdate();try(ResultSet r=ps.getGeneratedKeys()){r.next();return r.getInt(1);}}}
 static int scalar(Connection c,String sql,Object...values)throws Exception{try(PreparedStatement ps=c.prepareStatement(sql)){for(int n=0;n<values.length;n++)ps.setObject(n+1,values[n]);try(ResultSet r=ps.executeQuery()){r.next();return r.getInt(1);}}}
 static Connection borrowed(Connection real){return (Connection)Proxy.newProxyInstance(Connection.class.getClassLoader(),new Class[]{Connection.class},(p,m,a)->{if(Set.of("close","commit","rollback","setAutoCommit").contains(m.getName()))return null;try{return m.invoke(real,a);}catch(InvocationTargetException e){throw e.getCause();}});}
 static class Fixture {int invoice,appointment,medicine,pending,completed;long medicinePrice;}
 static Fixture fixture(Connection c)throws Exception {
  int patient,schedule,doctor,employee,service,specialist;String medicine;long price;
  try(Statement st=c.createStatement();ResultSet r=st.executeQuery("SELECT TOP 1 a.Patient_ID,a.Schedule_ID,ws.Doctor_Employee_ID FROM Appointment a JOIN Work_Schedule ws ON ws.Schedule_ID=a.Schedule_ID ORDER BY a.Appointment_ID")){r.next();patient=r.getInt(1);schedule=r.getInt(2);doctor=r.getInt(3);}
  employee=scalar(c,"SELECT TOP 1 Employee_ID FROM Employee_Profile ORDER BY Employee_ID");
  try(Statement st=c.createStatement();ResultSet r=st.executeQuery("SELECT TOP 1 po.Service_ID,po.Specialist_Employee_ID FROM Procedure_Order po JOIN Service_Catalog s ON s.Service_ID=po.Service_ID WHERE s.Service_ID<>1 AND s.Service_Name<>N'Khám mắt tổng quát' ORDER BY po.Order_ID")){r.next();service=r.getInt(1);specialist=r.getInt(2);}
  try(Statement st=c.createStatement();ResultSet r=st.executeQuery("SELECT TOP 1 Supply_Name,Price FROM Medical_Supply WHERE Price>0 ORDER BY Supply_ID")){r.next();medicine=r.getString(1);price=r.getLong(2);}
  Fixture f=new Fixture();f.medicinePrice=price;
  f.appointment=insert(c,"INSERT INTO Appointment(Patient_ID,Schedule_ID,Staff_Employee_ID,Status,created_at,checkin_time,doctor_completed_at) VALUES(?,?,?,'Completed',SYSUTCDATETIME(),SYSUTCDATETIME(),SYSUTCDATETIME())",patient,schedule,employee);
  f.invoice=insert(c,"INSERT INTO Master_Invoice(Appointment_ID,Total_Amount,Deposit_Amount,Balance_Due,Status,Create_At) VALUES(?,200000,200000,0,'Paid',SYSUTCDATETIME())",f.appointment);
  insert(c,"INSERT INTO Payment_Transaction(Invoice_ID,Amount,Gateway_Status,Payment_Gateway,Trans_Date) VALUES(?,200000,'Success','Test_Deposit',SYSUTCDATETIME())",f.invoice);
  int record=insert(c,"INSERT INTO Medical_Record(Appointment_ID,Doctor_Employee_ID,Clinical_Diagnosis,Created_At) VALUES(?,?,N'Checkout rollback test',SYSUTCDATETIME())",f.appointment,doctor);
  int prescription=insert(c,"INSERT INTO Prescription(Record_ID,created_at) VALUES(?,SYSUTCDATETIME())",record);
  f.medicine=insert(c,"INSERT INTO Prescription_Detail(Prescription_ID,Quantity,Medicine_Name,Is_Custom_Medicine) VALUES(?,2,?,0)",prescription,medicine);
  f.completed=insert(c,"INSERT INTO Procedure_Order(Specialist_Employee_ID,Record_ID,Service_ID,Actual_Price,Status) VALUES(?,?,?,100000,'Completed')",specialist,record,service);
  f.pending=insert(c,"INSERT INTO Procedure_Order(Specialist_Employee_ID,Record_ID,Service_ID,Actual_Price,Status) VALUES(?,?,?,30000,'Pending')",specialist,record,service);
  return f;
 }
 static int employee(Connection c)throws Exception{return scalar(c,"SELECT TOP 1 Employee_ID FROM Employee_Profile ORDER BY Employee_ID");}
 public static void main(String[]args)throws Exception {
  DriverManager.setLoginTimeout(5);
  try(Connection real=DBContext.getConnection()) {
   real.setAutoCommit(false);
   try {
    StaffInvoiceDAO dao=new StaffInvoiceDAO(()->borrowed(real));int employee=employee(real);
    int baseAppointment=insert(real,"INSERT INTO Appointment(Patient_ID,Schedule_ID,Status,created_at) SELECT TOP 1 Patient_ID,Schedule_ID,'Confirmed',SYSUTCDATETIME() FROM Appointment");
    int baseInvoice=insert(real,"INSERT INTO Master_Invoice(Appointment_ID,Total_Amount,Deposit_Amount,Balance_Due,Status,Create_At) VALUES(?,200000,200000,0,'Paid',SYSUTCDATETIME())",baseAppointment);
    check("Thanh toán một phần".equals(dao.get(baseInvoice).getPaymentLabel()),"Fee-only paid booking remains partial until examination");
    check(dao.list("APT-"+baseAppointment,"Partial_Paid",null).stream().anyMatch(r->Integer.valueOf(baseInvoice).equals(r.get("invoiceId"))),"Partial filter matches displayed progress even with legacy Paid financial status");
    try(PreparedStatement ps=real.prepareStatement("UPDATE Appointment SET Status='Completed' WHERE Appointment_ID=?")){ps.setInt(1,baseAppointment);ps.executeUpdate();}
    StaffInvoice base=dao.get(baseInvoice);
    check(base.getDue()==0&&!base.finalized&&"Khám xong".equals(base.getPaymentLabel()),"No extra purchases never auto-finalize a completed examination");
    check(dao.list("APT-"+baseAppointment,"Examined",null).stream().anyMatch(r->Integer.valueOf(baseInvoice).equals(r.get("invoiceId"))),"Examined filter follows doctor completion");
    dao.cash(baseInvoice,employee,base.fingerprint());
    check("Hoàn thành".equals(dao.get(baseInvoice).getPaymentLabel()),"Staff explicitly closes fee-only invoice");
    check(scalar(real,"SELECT COUNT(*) FROM Payment_Transaction WHERE Invoice_ID=?",baseInvoice)==0,"Zero balance close never creates a fictitious cash receipt");
    check(dao.list("APT-"+baseAppointment,"Completed",null).stream().anyMatch(r->Integer.valueOf(baseInvoice).equals(r.get("invoiceId"))),"Completed filter requires staff checkout finalization");
    Fixture cash=fixture(real);StaffInvoice inv=dao.get(cash.invoice);
    check(inv.getTotal()==330000+2*cash.medicinePrice,"Exact total from source items");
    check(inv.paid==200000&&inv.getDue()==130000+2*cash.medicinePrice,"Deposit is deducted exactly once");
    check(!inv.isCanCheckout()&&inv.isUnperformed(),"Cannot collect pending procedure as completed");
    String initial=inv.fingerprint();reject(()->dao.decline(cash.invoice,"PROCEDURE:"+cash.completed,employee,initial),"Cannot remove performed service");
    reject(()->dao.cash(cash.invoice,employee,"tampered"),"Cannot trust client amount/fingerprint");
    dao.decline(cash.invoice,"PROCEDURE:"+cash.pending,employee,initial);inv=dao.get(cash.invoice);
    check(inv.isCanCheckout()&&inv.getTotal()==300000+2*cash.medicinePrice,"Recalculate after declining unperformed procedure");
    check(scalar(real,"SELECT COUNT(*) FROM Procedure_Order WHERE Order_ID=? AND Status='Cancelled'",cash.pending)==1,"Declined clinical order is cancelled, not deleted");
    String beforeCash=inv.fingerprint();dao.cash(cash.invoice,employee,beforeCash);StaffInvoice paid=dao.get(cash.invoice);
    check(paid.finalized&&paid.getDue()==0&&paid.paid==paid.getTotal(),"Cash settles and freezes full invoice");
    check(scalar(real,"SELECT COUNT(*) FROM Payment_Transaction WHERE Invoice_ID=?",cash.invoice)==2,"Only deposit and outstanding cash are recorded");
    reject(()->dao.cash(cash.invoice,employee,beforeCash),"Double-submit cash must not duplicate receipt");
    check(scalar(real,"SELECT COUNT(*) FROM Payment_Transaction WHERE Invoice_ID=?",cash.invoice)==2,"No duplicate cash transaction");
    try(PreparedStatement ps=real.prepareStatement("UPDATE Prescription_Detail SET Quantity=5 WHERE Detail_ID=?")){ps.setInt(1,cash.medicine);ps.executeUpdate();}
    check(dao.get(cash.invoice).getTotal()==paid.getTotal(),"Printed bill is unaffected by later prescription edits");
    reject(()->dao.decline(cash.invoice,"MEDICINE:"+cash.medicine,employee,paid.fingerprint()),"Cannot edit finalized invoice");
    Fixture qr=fixture(real);StaffInvoice q=dao.get(qr.invoice);dao.decline(qr.invoice,"PROCEDURE:"+qr.pending,employee,q.fingerprint());q=dao.get(qr.invoice);
    Map<String,Object> order=dao.reserveQr(qr.invoice,employee,q.fingerprint());long code=(Long)order.get("orderCode"),amount=(Long)order.get("amount");
    check(code>=900000000000000L,"QR checkout code cannot collide with appointment deposit codes");
    String whileQr=dao.get(qr.invoice).fingerprint();reject(()->dao.cash(qr.invoice,employee,whileQr),"Cannot collect cash while QR is active");
    dao.qrCreated(code,"https://pay.payos.vn/web/test", "test-qr");
    PayOSUtil.VerifiedReceipt wrong=new PayOSUtil.VerifiedReceipt();wrong.orderCode=code;wrong.status="PAID";wrong.amount=amount-1;wrong.amountPaid=amount;
    reject(()->StaffCheckoutPayments.refresh(dao,c->wrong,code,qr.invoice),"Cannot accept gateway amount mismatch");
    check(!dao.get(qr.invoice).finalized,"Mismatched receipt did not alter payment status");
    reject(()->StaffCheckoutPayments.refresh(dao,c->wrong,code,cash.invoice),"QR belongs to one invoice only");
    PayOSUtil.VerifiedReceipt verified=new PayOSUtil.VerifiedReceipt();verified.orderCode=code;verified.status="PAID";verified.amount=amount;verified.amountPaid=amount;
    check("Paid".equals(StaffCheckoutPayments.refresh(dao,c->verified,code,qr.invoice)),"Verified gateway receipt settles invoice");
    StaffCheckoutPayments.refresh(dao,c->verified,code,qr.invoice);
    check(scalar(real,"SELECT COUNT(*) FROM Payment_Transaction WHERE Invoice_ID=?",qr.invoice)==2,"Polling and webhook are idempotent");
    check(dao.get(qr.invoice).finalized&&dao.get(qr.invoice).getDue()==0,"QR checkout final invoice is settled");
    Fixture legacy=fixture(real);
    try(PreparedStatement ps=real.prepareStatement("DELETE FROM Payment_Transaction WHERE Invoice_ID=?")){ps.setInt(1,legacy.invoice);ps.executeUpdate();}
    StaffInvoice old=dao.get(legacy.invoice);
    check(old.paid==200000&&old.priorPaid==200000,"Preserve paid legacy invoice without transaction details");
    dao.decline(legacy.invoice,"PROCEDURE:"+legacy.pending,employee,old.fingerprint());old=dao.get(legacy.invoice);
    dao.cash(legacy.invoice,employee,old.fingerprint());old=dao.get(legacy.invoice);
    check(old.finalized&&old.paid==old.getTotal()&&old.priorPaid==200000,"Legacy paid amount persists after checkout");
    check(scalar(real,"SELECT COUNT(*) FROM Payment_Transaction WHERE Invoice_ID=?",legacy.invoice)==1,"Only new outstanding balance is collected on a legacy paid invoice");
    Fixture blocked=fixture(real);
    try(PreparedStatement ps=real.prepareStatement("UPDATE Appointment SET Status='Canceled' WHERE Appointment_ID=?")){ps.setInt(1,blocked.appointment);ps.executeUpdate();}
    check(dao.get(blocked.invoice).isBlocked(),"Canceled appointment cannot collect new payment");
    reject(()->dao.cash(blocked.invoice,employee,dao.get(blocked.invoice).fingerprint()),"Cannot charge canceled appointment");
    System.out.println("PASS: "+checks+" transactional checkout integration checks. All fixtures rolled back; no real payment or gateway call.");
   } finally {real.rollback();}
  }
 }
}
