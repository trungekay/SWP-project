import com.visioncare.model.InvoiceProgress;
import com.visioncare.model.StaffInvoice;

public class InvoiceProgressTest {
 public static void main(String[] args) {
  expect("Canceled","Canceled",false,false,InvoiceProgress.Unpaid);
  expect("Pending","Pending_Deposit",false,false,InvoiceProgress.Unpaid);
  expect("Confirmed","Paid",false,true,InvoiceProgress.Partial_Paid);
  expect("Checked_In","Paid",false,true,InvoiceProgress.Partial_Paid);
  expect("In_Progress","Partial_Paid",false,true,InvoiceProgress.Partial_Paid);
  expect("Completed","Paid",false,true,InvoiceProgress.Examined);
  expect("Completed","Unpaid",false,false,InvoiceProgress.Examined);
  expect("Completed","Paid",true,true,InvoiceProgress.Completed);
  expect("Canceled","Paid",false,true,InvoiceProgress.Canceled);
  expect("Canceled","Refunded",false,true,InvoiceProgress.Refunded);
  StaffInvoice noExtras=new StaffInvoice();noExtras.id=1;noExtras.appointmentStatus="Completed";
  noExtras.invoiceStatus="Paid";noExtras.paid=200000;
  noExtras.items.add(new StaffInvoice.Item("CONSULT","Fee","Consult",1,200000,false,false,false));
  if(noExtras.getDue()!=0||!"Khám xong".equals(noExtras.getPaymentLabel()))throw new AssertionError("No extras must await staff closing");
  noExtras.finalized=true;
  if(!"Hoàn thành".equals(noExtras.getPaymentLabel()))throw new AssertionError("Only staff closing completes invoice");
  if(java.util.Arrays.stream(InvoiceProgress.values()).map(InvoiceProgress::getColor).distinct().count()!=InvoiceProgress.values().length)throw new AssertionError("Distinct state colors");
  System.out.println("PASS: 13 invoice progress and no-extra-purchase checks.");
 }
 static void expect(String clinical,String financial,boolean closed,boolean paid,InvoiceProgress expected){
  if(InvoiceProgress.resolve(true,clinical,financial,closed,paid)!=expected)throw new AssertionError(clinical+" / "+financial);
 }
}
