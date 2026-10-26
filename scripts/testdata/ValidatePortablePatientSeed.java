import java.sql.*;import java.nio.file.*;import java.util.*;import java.lang.reflect.*;
import com.visioncare.dao.*;import com.visioncare.model.*;
/** Validates only the embedded seed inside an outer transaction that always rolls back. */
public class ValidatePortablePatientSeed {
 static int scalar(Connection c,String sql)throws Exception{try(Statement s=c.createStatement();ResultSet r=s.executeQuery(sql)){r.next();return r.getInt(1);}}
 static Connection borrowed(Connection c){return (Connection)Proxy.newProxyInstance(Connection.class.getClassLoader(),new Class[]{Connection.class},(p,m,a)->{if(Set.of("close","commit","rollback","setAutoCommit").contains(m.getName()))return null;try{return m.invoke(c,a);}catch(InvocationTargetException e){throw e.getCause();}});}
 static List<Map<String,Object>> execute(Connection c,String sql)throws Exception{List<Map<String,Object>> rows=new ArrayList<>();try(Statement s=c.createStatement()){boolean result=s.execute(sql);while(true){if(result){try(ResultSet r=s.getResultSet()){while(r.next()){Map<String,Object> row=new HashMap<>();row.put("code",r.getString("Case_Code"));row.put("apt",r.getInt("Appointment_ID"));row.put("invoice",r.getInt("Invoice_ID"));row.put("new",r.getBoolean("Created_Now"));rows.add(row);}}}else if(s.getUpdateCount()==-1)break;result=s.getMoreResults();}}return rows;}
 public static void main(String[]args)throws Exception{
  String whole=Files.readString(Path.of("database/eye_clinic_db.sql"));String marker="-- BEGIN PORTABLE PATIENT INVOICE SCENARIOS",end="-- END PORTABLE PATIENT INVOICE SCENARIOS";
  String sql=whole.substring(whole.indexOf(marker),whole.indexOf(end)+end.length());
  int beforeA,beforeI,checks=0;
  try(Connection c=DBContext.getConnection()){
   c.setAutoCommit(false);beforeA=scalar(c,"SELECT COUNT(*) FROM Appointment");beforeI=scalar(c,"SELECT COUNT(*) FROM Master_Invoice");
   try{
    List<Map<String,Object>> first=execute(c,sql);if(first.size()!=9||first.stream().filter(r->Boolean.TRUE.equals(r.get("new"))).count()!=9)throw new AssertionError("Expected nine new portable samples");checks++;
    StaffInvoiceDAO dao=new StaffInvoiceDAO(()->borrowed(c));
    for(Map<String,Object> row:first){String code=(String)row.get("code");int invoice=(Integer)row.get("invoice");StaffInvoice bill=dao.get(invoice);
     long expected=code.equals("EXAM_DONE_EXTRAS")?545000:200000;if(bill.getTotal()!=expected||bill.paid!=(code.equals("EXPIRED")?0:200000))throw new AssertionError(code+" money");checks++;
     if(!bill.patientName.equals("Nguyễn Văn An"))throw new AssertionError("Wrong patient");checks++;
     String state=code.equals("EXPIRED")?"Unpaid":code.equals("PAID_FINAL")?"Completed":code.startsWith("EXAM_DONE")?"Examined":Set.of("REFUND_ELIGIBLE","DOCTOR_CANCEL","REFUND_PENDING").contains(code)?"Canceled":"Partial_Paid";
     if(!state.equals(bill.getProgress().name()))throw new AssertionError(code+" state");checks++;
     String eligibleSql="SELECT COUNT(*) FROM Master_Invoice i JOIN Appointment a ON a.Appointment_ID=i.Appointment_ID WHERE i.Invoice_ID="+invoice+" AND "+RefundPolicy.ELIGIBLE+" AND "+RefundPolicy.NO_ACTIVE_REQUEST;
     if(scalar(c,eligibleSql)!=(Set.of("REFUND_ELIGIBLE","DOCTOR_CANCEL").contains(code)?1:0))throw new AssertionError(code+" refund eligibility");checks++;
     if(code.equals("PAID_FINAL")&&(!bill.finalized||bill.items.size()!=1||bill.getOutstanding()!=0))throw new AssertionError("Final bill not frozen");
    }
    int booked=first.stream().filter(r->"BOOKED".equals(r.get("code"))).map(r->(Integer)r.get("apt")).findFirst().orElseThrow();
    try(Statement s=c.createStatement()){s.executeUpdate("UPDATE Appointment SET Status='Pending' WHERE Appointment_ID="+booked);}
    int afterFirst=scalar(c,"SELECT COUNT(*) FROM Appointment");List<Map<String,Object>> second=execute(c,sql);
    if(second.size()!=9||second.stream().anyMatch(r->Boolean.TRUE.equals(r.get("new")))||scalar(c,"SELECT COUNT(*) FROM Appointment")!=afterFirst)throw new AssertionError("Seed duplicated visits");checks++;
    if(scalar(c,"SELECT COUNT(*) FROM Appointment WHERE Appointment_ID="+booked+" AND Status='Pending'")!=1)throw new AssertionError("Rerun reset an edited case");checks++;
    if(scalar(c,"SELECT COUNT(*) FROM Appointment")!=beforeA+9||scalar(c,"SELECT COUNT(*) FROM Master_Invoice")!=beforeI+9)throw new AssertionError("Unexpected fixture row count");checks++;
    if(scalar(c,"SELECT @@TRANCOUNT")<1)throw new AssertionError("Validation transaction unexpectedly committed");
   }finally{c.rollback();}
  }
  try(Connection c=DBContext.getConnection()){if(scalar(c,"SELECT COUNT(*) FROM Appointment")!=beforeA||scalar(c,"SELECT COUNT(*) FROM Master_Invoice")!=beforeI)throw new AssertionError("Validation fixtures persisted");}
  System.out.println("PASS: "+checks+" portable SQL sample checks; rerun creates zero duplicates; all validation rows rolled back.");
 }
}
