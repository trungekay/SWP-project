import java.sql.*;import java.nio.file.*;import java.util.*;import com.visioncare.dao.*;import com.visioncare.model.*;
public class VerifyUserFlows {
 static int checks=0; static void ok(boolean v,String m){if(!v)throw new AssertionError(m);checks++;}
 static int scalar(Connection c,String q,Object...vs)throws Exception{try(PreparedStatement p=c.prepareStatement(q)){for(int i=0;i<vs.length;i++)p.setObject(i+1,vs[i]);try(ResultSet r=p.executeQuery()){r.next();return r.getInt(1);}}}
 static String bracket(String s){return "["+s.replace("]","]]")+"]";}
 public static void main(String[]args)throws Exception{
 User user=new User();
 StaffInvoiceDAO dao=new StaffInvoiceDAO();StringBuilder md=new StringBuilder("# Xác minh bộ test FLOW-20261026\n\n");
 try(Connection c=DBContext.getConnection()){
  user.setId(scalar(c,"SELECT Account_ID FROM Account WHERE Email=? AND Role_ID=6",SeedUserFlows.EMAIL));
  ok(user.getId()>0,"Existing patient account; no new login credentials");
  ok(scalar(c,"SELECT COUNT(*) FROM Account WHERE Email='nam.flow.test@example.test'")==0,"Old test email removed");
  ok(scalar(c,"SELECT COUNT(*) FROM Appointment WHERE Appointment_ID BETWEEN 97 AND 105")==0,"Nine old appointments removed");
  int patient=scalar(c,"SELECT Patient_ID FROM Patient WHERE Account_ID=?",user.getId());
  for(String[]def:SeedUserFlows.CASES){String code=def[0];int inv=scalar(c,"SELECT i.Invoice_ID FROM Master_Invoice i JOIN Appointment a ON a.Appointment_ID=i.Appointment_ID JOIN Medical_Record mr ON mr.Appointment_ID=a.Appointment_ID WHERE a.Patient_ID=? AND mr.Clinical_Diagnosis LIKE ?",patient,SeedUserFlows.marker(code).replace("[","[[]")+"%");StaffInvoice bill=dao.get(inv);
   ok(bill.getTotal()==(code.equals("EXAM_DONE_EXTRAS")?545000:200000),code+" total");
   ok(bill.paid==(code.equals("EXPIRED")?0:200000),code+" recorded paid");
   String expected=code.equals("EXPIRED")?"Unpaid":code.equals("PAID_FINAL")?"Completed":code.startsWith("EXAM_DONE")?"Examined":Set.of("REFUND_ELIGIBLE","DOCTOR_CANCEL","REFUND_PENDING").contains(code)?"Canceled":"Partial_Paid";
   ok(expected.equals(bill.getProgress().name()),code+" UI progress");
   int eligible=scalar(c,"SELECT COUNT(*) FROM Master_Invoice i JOIN Appointment a ON a.Appointment_ID=i.Appointment_ID WHERE i.Invoice_ID=? AND "+RefundPolicy.ELIGIBLE+" AND "+RefundPolicy.NO_ACTIVE_REQUEST,inv);
   ok(eligible==(Set.of("REFUND_ELIGIBLE","DOCTOR_CANCEL").contains(code)?1:0),code+" refund eligibility");
   int request=scalar(c,"SELECT COUNT(*) FROM Appointment a WHERE a.Appointment_ID=? AND "+RefundPolicy.CANCELLATION_REQUESTED,bill.appointmentId);
   ok(request==(code.equals("CANCEL_PENDING")?1:0),code+" cancellation approval filter");
   Map<String,Object> patientInvoice=new InvoiceDAO().getInvoiceDetailForPatient(inv,user.getId());
   ok(patientInvoice!=null,code+" patient invoice access");
   ok(((Number)patientInvoice.get("totalAmount")).longValue()==bill.getTotal(),code+" same patient/staff total");
   ok(((Number)patientInvoice.get("balanceDue")).longValue()==bill.getDue(),code+" same patient/staff balance");
   ok(((Number)patientInvoice.get("depositAmount")).longValue()==bill.baseAmount,code+" base fee never counted twice");
   if(code.startsWith("EXAM_DONE"))ok(bill.isCanCheckout(),code+" staff can close");
   if(code.equals("EXAM_DONE_EXTRAS")){
    int recordId=scalar(c,"SELECT Record_ID FROM Medical_Record WHERE Appointment_ID=?",bill.appointmentId);
    Map<String,Object> record=new MedicalRecordDAO().getMedicalRecordDetailForPatient(recordId,user.getId());
    ok(record!=null&&record.get("medicines") instanceof List&&((List<?>)record.get("medicines")).size()==1,"Patient medical record preserves medicines when optional eyeglass table is absent");
   }
   if(code.equals("PAID_FINAL"))ok(bill.finalized&&!bill.isCanEdit()&&bill.getDue()==0,"Export finalization");
   md.append("- ").append(code).append(": APT-").append(bill.appointmentId).append(" / INV-").append(inv).append("; ").append(bill.getPaymentLabel()).append("; tổng=").append(bill.getTotal()).append("; đã thu=").append(bill.paid).append("; còn thu=").append(bill.getDue()).append("\n");
  }
  ok(new HistoryDAO().getMedicalRecords(user.getId()).size()>=3,"Three completed records visible in patient history");
  md.append("\n## Kiểm tra khóa ngoại toàn database\n\n| Khóa ngoại | Bảng con → bảng cha | Bản ghi mồ côi | Disabled / Not trusted |\n|---|---|---:|---|\n");
  Map<Integer,List<String[]>> all=new LinkedHashMap<>();
  String sql="SELECT fk.object_id,fk.name,SCHEMA_NAME(child.schema_id),child.name,SCHEMA_NAME(parent.schema_id),parent.name,cc.name,pc.name,fk.is_disabled,fk.is_not_trusted FROM sys.foreign_keys fk JOIN sys.foreign_key_columns fkc ON fkc.constraint_object_id=fk.object_id JOIN sys.tables child ON child.object_id=fk.parent_object_id JOIN sys.tables parent ON parent.object_id=fk.referenced_object_id JOIN sys.columns cc ON cc.object_id=child.object_id AND cc.column_id=fkc.parent_column_id JOIN sys.columns pc ON pc.object_id=parent.object_id AND pc.column_id=fkc.referenced_column_id ORDER BY fk.object_id,fkc.constraint_column_id";
  try(Statement s=c.createStatement();ResultSet r=s.executeQuery(sql)){while(r.next()){String[]cols=new String[9];for(int j=0;j<9;j++)cols[j]=r.getString(j+2);all.computeIfAbsent(r.getInt(1),k->new ArrayList<>()).add(cols);}}
  long orphans=0;for(List<String[]>cols:all.values()){String[]f=cols.get(0);List<String>nonnull=new ArrayList<>(),join=new ArrayList<>();for(String[]v:cols){nonnull.add("c."+bracket(v[5])+" IS NOT NULL");join.add("p."+bracket(v[6])+"=c."+bracket(v[5]));}String q="SELECT COUNT(*) FROM "+bracket(f[1])+"."+bracket(f[2])+" c WHERE "+String.join(" AND ",nonnull)+" AND NOT EXISTS(SELECT 1 FROM "+bracket(f[3])+"."+bracket(f[4])+" p WHERE "+String.join(" AND ",join)+")";int n=scalar(c,q);orphans+=n;md.append("| ").append(f[0]).append(" | ").append(f[2]).append(" → ").append(f[4]).append(" | ").append(n).append(" | ").append(f[7]).append(" / ").append(f[8]).append(" |\n");}
  md.append("\nSố khóa ngoại kiểm tra: ").append(all.size()).append("; tổng bản ghi mồ côi: ").append(orphans).append(".\n");
 }
 md.append("\nPASS: ").append(checks).append(" kiểm tra bộ ca. Chỉ đọc; không gọi PayOS, không gửi email, không thay đổi trạng thái test.\n");Files.writeString(Path.of("docs/testing/user-flow-verification-20261026.md"),md);System.out.println("PASS: "+checks+" checks; FK audit saved.");
 }
}
