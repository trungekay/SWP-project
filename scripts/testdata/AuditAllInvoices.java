import java.sql.*;import java.nio.file.*;import java.util.*;
import com.visioncare.dao.*;import com.visioncare.model.*;
/** Read-only, invoice-by-invoice reconciliation. Never infers that a missing receipt is money not paid. */
public class AuditAllInvoices {
 static String fmt(Object o){return o==null?"":o.toString().replace("|","/").replace("\n"," ");}
 static void section(Connection c,StringBuilder out,String title,String sql)throws Exception {
  out.append("\n## ").append(title).append("\n\n");
  try(Statement s=c.createStatement();ResultSet r=s.executeQuery(sql)){
   int columns=r.getMetaData().getColumnCount(),rows=0;
   out.append('|');for(int j=1;j<=columns;j++)out.append(r.getMetaData().getColumnLabel(j)).append('|');out.append("\n|");for(int j=1;j<=columns;j++)out.append("---|");out.append('\n');
   while(r.next()){rows++;out.append('|');for(int j=1;j<=columns;j++)out.append(fmt(r.getObject(j))).append('|');out.append('\n');}
   out.append("\nSố dòng: ").append(rows).append(".\n");System.out.println(title+": "+rows);
  }
 }
 public static void main(String[]args)throws Exception{
  StringBuilder out=new StringBuilder("# Đối chiếu toàn bộ hóa đơn cũ — 26/10/2026\n\nChỉ đọc database. Không xóa giao dịch, không tự xác nhận thu tiền/hoàn tiền. Số đã thu kế thừa từ dữ liệu cũ được tách khỏi tổng giao dịch chi tiết. Chênh giữa tổng gốc và tổng hiện tại có thể là khoản phát sinh chưa được staff chốt, không tự động kết luận sai chứng từ.\n\n");
  int audited=0,errors=0,viewFailures=0,legacy=0,overpaid=0,diff=0;List<Integer> ids=new ArrayList<>();
  try(Connection c=DBContext.getConnection();Statement s=c.createStatement();ResultSet r=s.executeQuery("SELECT Invoice_ID FROM Master_Invoice ORDER BY Invoice_ID")){while(r.next())ids.add(r.getInt(1));}
  out.append("| Invoice | APT | Clinical | Financial | Tổng gốc | Tổng theo khoản thu | Giao dịch Success | Khoản kế thừa thiếu giao dịch chi tiết | Đã ghi nhận thu | Chênh lệch còn lại | Khóa thu | Chốt | Ghi chú |\n|---|---|---|---|---:|---:|---:|---:|---:|---:|---|---|---|\n");
  StaffInvoiceDAO dao=new StaffInvoiceDAO();
  for(int id:ids)try{StaffInvoice bill=dao.get(id);long receipts=0;for(Map<String,Object> tx:bill.transactions)if("Success".equals(tx.get("status")))receipts+=((Number)tx.get("amount")).longValue();
   List<String> notes=new ArrayList<>();if(bill.priorPaid>0){legacy++;notes.add("Có khoản đã thu kế thừa, chưa đủ giao dịch chi tiết để đối soát");}
   if(bill.recordedTotal!=bill.getTotal()){diff++;notes.add("Tổng gốc khác các khoản hiện tại; đối chiếu phát sinh trước chốt");}
   if(bill.getOverpaid()>0){overpaid++;notes.add("Tiền đã ghi nhận vượt tổng hóa đơn");}
   Map<String,Object> view=new InvoiceDAO().getInvoiceDetail(id);
   if(view==null||((Number)view.get("totalAmount")).longValue()!=bill.getTotal()||((Number)view.get("paidAmount")).longValue()!=bill.paid||((Number)view.get("balanceDue")).longValue()!=bill.getOutstanding()||Boolean.TRUE.equals(view.get("settled"))!=(bill.finalized&&!bill.isBlocked()&&bill.getOutstanding()==0)){viewFailures++;notes.add("LỖI dữ liệu hiển thị patient/staff không khớp");}
   if(bill.finalized&&bill.getOutstanding()>0){notes.add("LỖI hóa đơn chốt còn dư nợ");}
   audited++;out.append('|').append(id).append('|').append(bill.appointmentId).append('|').append(fmt(bill.appointmentStatus)).append('|').append(fmt(bill.invoiceStatus)).append('|').append(bill.recordedTotal).append('|').append(bill.getTotal()).append('|').append(receipts).append('|').append(bill.priorPaid).append('|').append(bill.paid).append('|').append(bill.getOutstanding()).append('|').append(bill.isBlocked()).append('|').append(bill.finalized).append('|').append(String.join("; ",notes)).append("|\n");
  }catch(Exception e){errors++;out.append('|').append(id).append("||||||||||||LỖI: ").append(fmt(e.getMessage())).append("|\n");}
  try(Connection c=DBContext.getConnection()){
   section(c,out,"Lịch Confirmed thiếu hóa đơn", "SELECT a.Appointment_ID,a.Patient_ID,ws.Work_Date FROM Appointment a JOIN Work_Schedule ws ON ws.Schedule_ID=a.Schedule_ID WHERE a.Status='Confirmed' AND NOT EXISTS(SELECT 1 FROM Master_Invoice i WHERE i.Appointment_ID=a.Appointment_ID) ORDER BY a.Appointment_ID");
   section(c,out,"Lịch có nhiều master invoice", "SELECT Appointment_ID,COUNT(*) AS Invoice_Count FROM Master_Invoice GROUP BY Appointment_ID HAVING COUNT(*)>1");
   section(c,out,"Cặp giao dịch nghi trùng (chỉ cảnh báo, chưa đủ chứng cứ xóa)", "SELECT p.Invoice_ID,p.Transaction_ID AS First_Transaction,q.Transaction_ID AS Second_Transaction,p.Amount,p.Trans_Date AS First_Date,q.Trans_Date AS Second_Date FROM Payment_Transaction p JOIN Payment_Transaction q ON q.Invoice_ID=p.Invoice_ID AND q.Transaction_ID>p.Transaction_ID AND q.Amount=p.Amount AND q.Payment_Gateway=p.Payment_Gateway AND p.Gateway_Status='Success' AND q.Gateway_Status='Success' AND ABS(DATEDIFF(SECOND,p.Trans_Date,q.Trans_Date))<=2 ORDER BY p.Invoice_ID");
   section(c,out,"Refund Pending không đủ điều kiện duyệt hủy trước check-in", "SELECT rr.Refund_ID,i.Invoice_ID,a.Appointment_ID,a.Status,a.checkin_time,rr.Refund_Amount FROM Refund_Request rr JOIN Master_Invoice i ON i.Invoice_ID=rr.Invoice_ID JOIN Appointment a ON a.Appointment_ID=i.Appointment_ID WHERE rr.Status='Pending' AND NOT ("+RefundPolicy.ELIGIBLE+")");
   section(c,out,"Refund Approved nhưng hóa đơn chưa chuyển Refunded", "SELECT rr.Refund_ID,i.Invoice_ID,a.Appointment_ID,i.Status AS Invoice_Status,a.Status AS Appointment_Status,rr.Refund_Amount FROM Refund_Request rr JOIN Master_Invoice i ON i.Invoice_ID=rr.Invoice_ID JOIN Appointment a ON a.Appointment_ID=i.Appointment_ID WHERE rr.Status='Approved' AND i.Status<>'Refunded'");
   section(c,out,"Phương thức thanh toán", "SELECT Payment_Gateway,COUNT(*) AS Transaction_Count,SUM(Amount) AS Recorded_Amount FROM Payment_Transaction GROUP BY Payment_Gateway");
  }
  out.append("\n## Kết quả\n\n- Tổng hóa đơn: ").append(ids.size()).append("; đọc được: ").append(audited).append("; lỗi tải: ").append(errors).append(".\n- Lỗi số liệu hiển thị patient/staff: ").append(viewFailures).append(".\n- Hóa đơn có khoản kế thừa thiếu giao dịch chi tiết: ").append(legacy).append(".\n- Hóa đơn tổng gốc khác tổng các khoản hiện tại: ").append(diff).append(".\n- Hóa đơn tiền đã thu vượt tổng: ").append(overpaid).append(".\n\nNhững ca thiếu chứng từ/giao dịch nghi trùng cần đối chiếu nguồn; audit không tự thêm/xóa phiếu thu hoặc thay quyết định refund.\n");
  Files.writeString(Path.of("docs/testing/invoice-reconciliation-20261026.md"),out);System.out.println("Audited="+audited+" errors="+errors+" viewFailures="+viewFailures+" legacy="+legacy+" totalDiff="+diff+" overpaid="+overpaid);
 }
}
