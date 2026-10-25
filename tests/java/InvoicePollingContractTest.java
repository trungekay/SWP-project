import com.visioncare.controller.StaffInvoiceServlet;
import com.visioncare.filter.AuthenticationFilter;
import com.visioncare.filter.ForcePasswordChangeFilter;
import com.visioncare.model.User;
import jakarta.servlet.http.*;
import java.lang.reflect.*;

public class InvoicePollingContractTest {
 static int checks=0;
 static HttpServletRequest request(RefundAccessTest.Exchange e,String csrf,String invoiceId) {
  return (HttpServletRequest)Proxy.newProxyInstance(HttpServletRequest.class.getClassLoader(),new Class[]{HttpServletRequest.class},(p,m,a)->{
   if(m.getName().equals("getHeader")&&"Accept".equalsIgnoreCase((String)a[0]))return "application/json";
   if(m.getName().equals("getParameter")){if("csrfToken".equals(a[0]))return csrf;if("invoiceId".equals(a[0]))return invoiceId;}
   try{return m.invoke(e.request,a);}catch(InvocationTargetException error){throw error.getCause();}
  });
 }
 static void invoke(RefundAccessTest.Exchange e,HttpServletRequest request)throws Exception {
  Method method=StaffInvoiceServlet.class.getDeclaredMethod("doPost",HttpServletRequest.class,HttpServletResponse.class);method.setAccessible(true);method.invoke(new StaffInvoiceServlet(),request,e.response);
 }
 static void expect(RefundAccessTest.Exchange e,int status,String state) {
  RefundAccessTest.require(e.status==status,"HTTP status for "+state);
  RefundAccessTest.require(e.contentType!=null&&e.contentType.startsWith("application/json"),"JSON content type for "+state);
  RefundAccessTest.require(e.body.toString().startsWith("{")&&e.body.toString().contains("\"status\":\""+state+"\""),"No HTML error page for "+state);
  RefundAccessTest.require(e.redirect==null,"No login HTML redirect for polling");checks++;
 }
 public static void main(String[]args)throws Exception {
  RefundAccessTest.Exchange e=new RefundAccessTest.Exchange(null,"/staff/invoices/checkout","checkQr");
  new AuthenticationFilter().doFilter(request(e,null,"13"),e.response,(req,res)->{throw new AssertionError("Anonymous polling passed");});expect(e,401,"Unauthenticated");
  e=new RefundAccessTest.Exchange(RefundAccessTest.user(6),"/staff/invoices/checkout","checkQr");
  new AuthenticationFilter().doFilter(request(e,null,"13"),e.response,(req,res)->{throw new AssertionError("Patient polling passed");});expect(e,403,"Forbidden");
  e=new RefundAccessTest.Exchange(RefundAccessTest.user(5),"/staff/invoices/checkout","checkQr");
  invoke(e,request(e,null,"13"));expect(e,403,"SessionExpired");
  e=new RefundAccessTest.Exchange(RefundAccessTest.user(5),"/staff/invoices/checkout","checkQr");e.attributes.put("invoiceCsrf","valid");
  invoke(e,request(e,"wrong","13"));expect(e,403,"SessionExpired");
  e=new RefundAccessTest.Exchange(RefundAccessTest.user(5),"/staff/invoices/checkout","checkQr");e.attributes.put("invoiceCsrf","valid");
  invoke(e,request(e,"valid","not-an-id"));expect(e,400,"InvalidRequest");
  User first=RefundAccessTest.user(5);first.setFirstLogin(true);e=new RefundAccessTest.Exchange(first,"/staff/invoices/checkout","checkQr");
  new ForcePasswordChangeFilter().doFilter(request(e,null,"13"),e.response,(req,res)->{throw new AssertionError("First login polling passed");});expect(e,403,"Forbidden");
  System.out.println("PASS: "+checks+" QR polling authentication/error JSON contract checks.");
 }
}
