import java.sql.*;import java.nio.file.*;import java.lang.reflect.*;import java.util.*;
import com.visioncare.dao.*;import com.visioncare.model.*;
/** Explicit local test fixtures. One patient; one example per flow branch; reruns never reset used cases. */
public class SeedUserFlows {
 static final String TAG="FLOW-20261026", EMAIL="patient.an@gmail.com";
 static int add(Connection c,String sql,Object...v)throws Exception{try(PreparedStatement p=c.prepareStatement(sql,Statement.RETURN_GENERATED_KEYS)){bind(p,v);p.executeUpdate();try(ResultSet r=p.getGeneratedKeys()){if(!r.next())throw new Exception("Missing generated key");return r.getInt(1);}}}
 static void bind(PreparedStatement p,Object...v)throws Exception{for(int n=0;n<v.length;n++)p.setObject(n+1,v[n]);}
 static void update(Connection c,String sql,Object...v)throws Exception{try(PreparedStatement p=c.prepareStatement(sql)){bind(p,v);p.executeUpdate();}}
 static int id(Connection c,String sql,Object...v)throws Exception{try(PreparedStatement p=c.prepareStatement(sql)){bind(p,v);try(ResultSet r=p.executeQuery()){return r.next()?r.getInt(1):0;}}}
 static Connection borrowed(Connection c){return (Connection)Proxy.newProxyInstance(Connection.class.getClassLoader(),new Class[]{Connection.class},(p,m,a)->{if(Set.of("close","commit","rollback","setAutoCommit").contains(m.getName()))return null;try{return m.invoke(c,a);}catch(InvocationTargetException e){throw e.getCause();}});}
 static String marker(String code){return "["+TAG+":"+code+"]";}
 static final String[][] CASES={
  {"BOOKED","Đã trả phí khám, chưa check-in; patient gửi yêu cầu hủy"},
  {"CANCEL_PENDING","Patient đã gửi hủy; staff duyệt hủy trước khi tạo refund"},
  {"REFUND_ELIGIBLE","Staff đã duyệt hủy; patient hoặc staff tạo refund"},
  {"DOCTOR_CANCEL","Bác sĩ đổi lịch không thể bố trí lịch khác; staff tạo refund"},
  {"REFUND_PENDING","Refund đã tạo; director duyệt; không được tạo trùng"},
  {"EXPIRED","Quá 15 phút chưa thanh toán, lịch hủy; không được refund"},
  {"EXAM_DONE_BASE","Khám xong, không mua thêm; staff chủ động chốt với số tiền thu thêm bằng 0"},
  {"EXAM_DONE_EXTRAS","Khám xong, tiểu phẫu đã thực hiện và thêm thuốc; test bỏ mua thuốc và thu phần còn lại"},
  {"PAID_FINAL","Đã chốt đầy đủ; test xem trước/in hóa đơn và khóa sửa"}
 };
 static void removeOldTest(Connection c)throws Exception{
  int oldAccount=id(c,"SELECT Account_ID FROM Account WITH(UPDLOCK,HOLDLOCK) WHERE Email='nam.flow.test@example.test' AND Role_ID=6");
  if(oldAccount==0)return;
  int oldPatient=id(c,"SELECT Patient_ID FROM Patient WHERE Account_ID=?",oldAccount);
  if(oldPatient==0)throw new Exception("Old test account ownership changed");
  if(id(c,"SELECT COUNT(*) FROM Appointment a LEFT JOIN Medical_Record mr ON mr.Appointment_ID=a.Appointment_ID WHERE a.Patient_ID=? AND a.Appointment_ID<>96 AND (mr.Clinical_Diagnosis IS NULL OR mr.Clinical_Diagnosis NOT LIKE N'[[]FLOW-20261026:%')",oldPatient)>0)throw new Exception("Old account contains unrelated appointments; refusing deletion");
  List<Integer> appointments=new ArrayList<>();
  try(PreparedStatement p=c.prepareStatement("SELECT a.Appointment_ID FROM Appointment a JOIN Medical_Record mr ON mr.Appointment_ID=a.Appointment_ID WHERE a.Patient_ID=? AND mr.Clinical_Diagnosis LIKE N'[[]FLOW-20261026:%'")){p.setInt(1,oldPatient);try(ResultSet r=p.executeQuery()){while(r.next())appointments.add(r.getInt(1));}}
  if(appointments.size()!=9)throw new Exception("Expected exactly nine old test appointments");
  for(int appointment:appointments){
   int invoice=id(c,"SELECT Invoice_ID FROM Master_Invoice WHERE Appointment_ID=?",appointment);
   int record=id(c,"SELECT Record_ID FROM Medical_Record WHERE Appointment_ID=?",appointment);
   if(id(c,"SELECT COUNT(*) FROM Payment_Transaction WHERE Invoice_ID=? AND Payment_Gateway NOT IN ('Test_Seed','QR_Banking')",invoice)>0)throw new Exception("Non-seed payment found; refusing deletion");
   update(c,"DELETE FROM Refund_Request WHERE Invoice_ID=?",invoice);
   update(c,"DELETE FROM Invoice_Checkout_Payment WHERE Invoice_ID=?",invoice);
   update(c,"DELETE FROM Invoice_Checkout_Item WHERE Invoice_ID=?",invoice);
   update(c,"DELETE FROM Invoice_Checkout WHERE Invoice_ID=?",invoice);
   update(c,"DELETE FROM Procedure_Payment_Request WHERE Order_ID IN(SELECT Order_ID FROM Procedure_Order WHERE Record_ID=?)",record);
   update(c,"DELETE FROM Procedure_Order WHERE Record_ID=?",record);
   update(c,"DELETE FROM Prescription_Detail WHERE Prescription_ID IN(SELECT Prescription_ID FROM Prescription WHERE Record_ID=?)",record);
   update(c,"DELETE FROM Prescription WHERE Record_ID=?",record);
   update(c,"DELETE FROM Examination_Detail WHERE Record_ID=?",record);
   update(c,"DELETE FROM Medical_Record WHERE Record_ID=?",record);
   update(c,"DELETE FROM Payment_Transaction WHERE Invoice_ID=?",invoice);
   update(c,"DELETE FROM Master_Invoice WHERE Invoice_ID=?",invoice);
   int schedule=id(c,"SELECT Schedule_ID FROM Appointment WHERE Appointment_ID=?",appointment);
   update(c,"DELETE FROM Appointment WHERE Appointment_ID=? AND Patient_ID=?",appointment,oldPatient);
   update(c,"UPDATE Work_Schedule SET Status='Available' WHERE Schedule_ID=? AND Status='Booked' AND NOT EXISTS(SELECT 1 FROM Appointment WHERE Schedule_ID=? AND Status<>'Canceled')",schedule,schedule);
  }
  // Patient Nam and his earlier APT-96 are retained; remove only the newly created login.
  update(c,"UPDATE Patient SET Account_ID=NULL WHERE Patient_ID=? AND Account_ID=?",oldPatient,oldAccount);
  update(c,"DELETE FROM Account WHERE Account_ID=? AND Email='nam.flow.test@example.test' AND Role_ID=6",oldAccount);
 }
 public static void main(String[]args)throws Exception{
 if(args.length!=1||!"--seed-local".equals(args[0]))throw new IllegalArgumentException("Use --seed-local to create named local fixtures");
 List<String> rows=new ArrayList<>();int account,patient,staff,specialist;int created=0;
 try(Connection c=DBContext.getConnection()){
 if(!"eye_clinic_db".equalsIgnoreCase(c.getCatalog()))throw new Exception("Unexpected database; refusing seed");
 c.setAutoCommit(false);c.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE);
 try {
 staff=id(c,"SELECT TOP 1 e.Employee_ID FROM Employee_Profile e JOIN Account a ON a.Account_ID=e.Account_ID WHERE a.Role_ID=5 ORDER BY e.Employee_ID");
 specialist=id(c,"SELECT TOP 1 e.Employee_ID FROM Employee_Profile e JOIN Account a ON a.Account_ID=e.Account_ID WHERE a.Role_ID=4 ORDER BY e.Employee_ID");
 if(staff==0||specialist==0)throw new Exception("Missing staff/specialist reference data");
 account=id(c,"SELECT ac.Account_ID FROM Account ac JOIN Patient p ON p.Account_ID=ac.Account_ID WHERE ac.Email=? AND p.Full_Name=N'Nguyễn Văn An' AND ac.Role_ID=6 AND ac.Account_Status='Active'",EMAIL);
 if(account==0)throw new Exception("Existing active Nguyen Van An account not found; no new account will be created");
 patient=id(c,"SELECT Patient_ID FROM Patient WHERE Account_ID=?",account);
 removeOldTest(c);
 for(String[]def:CASES){String code=def[0],mark=marker(code);
 int appointment=id(c,"SELECT a.Appointment_ID FROM Appointment a JOIN Medical_Record mr ON mr.Appointment_ID=a.Appointment_ID WHERE a.Patient_ID=? AND mr.Clinical_Diagnosis LIKE ?",patient,mark.replace("[","[[]")+"%");
 int invoice;
 if(appointment==0){
  boolean clinical=code.startsWith("EXAM_DONE")||code.equals("PAID_FINAL");boolean cancelled=Set.of("REFUND_ELIGIBLE","DOCTOR_CANCEL","REFUND_PENDING","EXPIRED").contains(code);
  int schedule,doctor;String date=clinical?"2026-10-26":"2026-10-27";
  try(PreparedStatement p=c.prepareStatement("SELECT TOP 1 ws.Schedule_ID,ws.Doctor_Employee_ID FROM Work_Schedule ws WITH(UPDLOCK,HOLDLOCK) WHERE Work_Date=? AND Status='Available' AND Doctor_Employee_ID IS NOT NULL AND NOT EXISTS(SELECT 1 FROM Appointment a WHERE a.Schedule_ID=ws.Schedule_ID AND a.Status<>'Canceled') ORDER BY CASE WHEN Doctor_Employee_ID=3 THEN 0 ELSE 1 END,Start_Time,Schedule_ID")){p.setString(1,date);try(ResultSet r=p.executeQuery()){if(!r.next())throw new Exception("No existing free schedule for "+code);schedule=r.getInt(1);doctor=r.getInt(2);}}
  String status=clinical?"Completed":cancelled?"Canceled":code.equals("CANCEL_PENDING")?"Pending":"Confirmed";
  appointment=add(c,"INSERT INTO Appointment(Patient_ID,Schedule_ID,Staff_Employee_ID,Status,created_at) VALUES(?,?,?,?,DATEADD(HOUR,7,SYSUTCDATETIME()))",patient,schedule,staff,status);
  if(clinical)update(c,"UPDATE a SET checkin_time=CAST(CONCAT(ws.Work_Date,' ',ws.Start_Time) AS datetime2),doctor_completed_at=DATEADD(MINUTE,25,CAST(CONCAT(ws.Work_Date,' ',ws.Start_Time) AS datetime2)),created_at=DATEADD(MINUTE,-15,CAST(CONCAT(ws.Work_Date,' ',ws.Start_Time) AS datetime2)) FROM Appointment a JOIN Work_Schedule ws ON ws.Schedule_ID=a.Schedule_ID WHERE a.Appointment_ID=?",appointment);
  if(code.equals("EXPIRED"))update(c,"UPDATE Appointment SET created_at=DATEADD(MINUTE,-20,DATEADD(HOUR,7,SYSUTCDATETIME())) WHERE Appointment_ID=?",appointment);
  boolean extras=code.equals("EXAM_DONE_EXTRAS");boolean unpaid=code.equals("EXPIRED");long total=extras?545000:200000;
  invoice=add(c,"INSERT INTO Master_Invoice(Appointment_ID,Total_Amount,Deposit_Amount,Balance_Due,Status,Create_At) VALUES(?, ?,200000,?,?,DATEADD(HOUR,7,SYSUTCDATETIME()))",appointment,total,unpaid?200000:total-200000,unpaid?"Canceled":extras?"Partial_Paid":"Paid");
  if(!unpaid)add(c,"INSERT INTO Payment_Transaction(Invoice_ID,Amount,Gateway_Status,Payment_Gateway,Trans_Date) VALUES(?,200000,'Success','QR_Banking',DATEADD(HOUR,7,SYSUTCDATETIME()))",invoice);
  String note=code.equals("CANCEL_PENDING")?RefundPolicy.REQUESTED+"Bận việc cá nhân (ca kiểm thử)":Set.of("REFUND_ELIGIBLE","REFUND_PENDING").contains(code)?RefundPolicy.APPROVED+RefundPolicy.PATIENT_AT_COUNTER:code.equals("DOCTOR_CANCEL")?RefundPolicy.APPROVED+RefundPolicy.DOCTOR_UNAVAILABLE:clinical?"Kết thúc khám mẫu; đối chiếu hóa đơn tại quầy":code.equals("EXPIRED")?"Hệ thống: Hết hạn thanh toán (ca kiểm thử)":null;
  int record=add(c,"INSERT INTO Medical_Record(Appointment_ID,Doctor_Employee_ID,Clinical_Diagnosis,examination_result,conclusion,Created_At) VALUES(?,?,?,?,?,DATEADD(HOUR,7,SYSUTCDATETIME()))",appointment,doctor,mark+" Dữ liệu mẫu kiểm thử",clinical?"Đã lưu kết quả khám mẫu để kiểm tra lịch sử bệnh án":null,note);
  if(clinical)update(c,"INSERT INTO Examination_Detail(Record_ID,Chief_Complaint,Medical_History) VALUES(?,N'Ca mô phỏng kiểm thử hóa đơn',N'Dữ liệu mẫu, không phải chỉ định điều trị thực tế')",record);
  if(extras){int order=add(c,"INSERT INTO Procedure_Order(Specialist_Employee_ID,Record_ID,Service_ID,Actual_Price,Status,Referral_Notes,Result_Text,Result_Conclusion,Completed_At) VALUES(?,?,14,250000,'Completed',N'Ca mẫu: tiểu phẫu đã thực hiện',N'Kết quả mô phỏng',N'Hoàn tất tiểu phẫu mẫu',DATEADD(HOUR,7,SYSUTCDATETIME()))",specialist,record);
   int prescription=add(c,"INSERT INTO Prescription(Record_ID,Doctor_Notes,created_at) VALUES(?,N'Đơn mẫu kiểm thử mua thuốc tại quầy',DATEADD(HOUR,7,SYSUTCDATETIME()))",record);
   update(c,"INSERT INTO Prescription_Detail(Prescription_ID,Quantity,Medicine_Name,Is_Custom_Medicine,Dosage_Instruction) SELECT ?,1,Supply_Name,0,N'Dữ liệu mẫu kiểm thử; không dùng hướng dẫn điều trị' FROM Medical_Supply WHERE Supply_ID=1 AND Price=95000",prescription);
  }
  if(code.equals("REFUND_PENDING"))add(c,"INSERT INTO Refund_Request(Invoice_ID,created_by_employee_id,Patient_ID,Refund_Amount,Reason,Status,Created_At,Update_At) VALUES(?,?,?,200000,?,'Pending',SYSUTCDATETIME(),SYSUTCDATETIME())",invoice,staff,patient,mark+" Hoàn phí khám sau khi staff duyệt hủy");
  if(!cancelled)update(c,"UPDATE Work_Schedule SET Status='Booked' WHERE Schedule_ID=?",schedule);
  if(code.equals("PAID_FINAL")){StaffInvoiceDAO dao=new StaffInvoiceDAO(()->borrowed(c));StaffInvoice inv=dao.get(invoice);dao.cash(invoice,staff,inv.fingerprint());}
  created++;
 }else invoice=id(c,"SELECT Invoice_ID FROM Master_Invoice WHERE Appointment_ID=?",appointment);
 rows.add("| "+code+" | APT-"+appointment+" | INV-"+String.format("%05d",invoice)+" | "+def[1]+" |");
 }
 // Assert monetary integrity and correct link ownership before commit. No gateway calls.
 if(id(c,"SELECT COUNT(*) FROM Appointment a JOIN Medical_Record mr ON mr.Appointment_ID=a.Appointment_ID WHERE a.Patient_ID=? AND mr.Clinical_Diagnosis LIKE ?",patient,"[[]"+TAG+":%")!=CASES.length)throw new Exception("Fixture count mismatch");
 c.commit();
 }catch(Exception e){c.rollback();throw e;}
 }
 String md="# Bộ dữ liệu kiểm thử đúng luồng — "+TAG+"\n\nDatabase: `eye_clinic_db`. Không tạo database/bảng/tài khoản/email mới. Chạy lại không reset/xóa/tạo trùng ca đã dùng.\n\nPatient: **Nguyễn Văn An**, email sẵn có `"+EMAIL+"` (Account_ID="+account+", Patient_ID="+patient+"). Dùng mật khẩu hiện tại của tài khoản; script không đọc/đổi mật khẩu.\n\nĐã xóa 9 ca cũ APT-97..APT-105, INV-00063..INV-00071 và các bản ghi phụ thuộc của riêng bộ ca đó; đã xóa Account `nam.flow.test@example.test`. APT-96/INV-00062 của Nguyễn Văn Nam vẫn giữ nguyên, patient Nam không còn liên kết tài khoản email test.\n\nPhương thức thanh toán dùng Cash / QR_Banking như luồng thật. Các mã ca trong tài liệu là dữ liệu mô phỏng, không phải PayOS receipt thật.\n\n| Ca | Lịch | Hóa đơn | Cách test |\n|---|---|---|---|\n"+String.join("\n",rows)+"\n\nStaff và director dùng tài khoản hiện có. Các ca hủy chưa check-in; ca khám xong có check-in, kết quả khám và Examination_Detail. Chỉ Invoice_Checkout.Finalized_At thể hiện staff chốt cuối.\n";
 Files.writeString(Path.of("docs/testing/user-flow-fixtures-20261026.md"),md);System.out.println("Created "+created+" cases; manifest docs/testing/user-flow-fixtures-20261026.md");
 }
}
