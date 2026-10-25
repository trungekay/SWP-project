import com.visioncare.controller.StaffInvoiceServlet;
import com.visioncare.filter.AuthenticationFilter;
public class StaffInvoiceAccessTest {
 public static void main(String[]args)throws Exception{
  int checks=0;
  for(String action:new String[]{null,"detail","checkout"}){
   RefundAccessTest.Exchange legacy=new RefundAccessTest.Exchange(RefundAccessTest.user(5),"/staff/payments",action);
   jakarta.servlet.http.HttpServletRequest request=(jakarta.servlet.http.HttpServletRequest)java.lang.reflect.Proxy.newProxyInstance(jakarta.servlet.http.HttpServletRequest.class.getClassLoader(),new Class[]{jakarta.servlet.http.HttpServletRequest.class},(p,m,a)->{
    if(m.getName().equals("getParameter")&&"id".equals(a[0]))return action==null?null:"13";
    try{return m.invoke(legacy.request,a);}catch(java.lang.reflect.InvocationTargetException error){throw error.getCause();}
   });
   java.lang.reflect.Method method=com.visioncare.controller.AdminBillingServlet.class.getDeclaredMethod("doGet",jakarta.servlet.http.HttpServletRequest.class,jakarta.servlet.http.HttpServletResponse.class);method.setAccessible(true);method.invoke(new com.visioncare.controller.AdminBillingServlet(),request,legacy.response);
   String target=action==null?"/SWP-project/staff/invoices":"/SWP-project/staff/invoices/"+("checkout".equals(action)?"checkout":"detail")+"?id=13";
   RefundAccessTest.require(target.equals(legacy.redirect),"Legacy payment link preserves invoice destination");checks++;
  }
  for(String path:new String[]{"/staff/invoices","/staff/invoices/detail","/staff/invoices/checkout","/staff/invoices/export"}){
   for(int role:new int[]{3,4,6}){RefundAccessTest.Exchange e=new RefundAccessTest.Exchange(RefundAccessTest.user(role),path,null);RefundAccessTest.invoke(new StaffInvoiceServlet(),"doGet",e);RefundAccessTest.require(e.status==403,"Non-cashier cannot read invoices");checks++;}
   RefundAccessTest.Exchange anonymous=new RefundAccessTest.Exchange(null,path,null);RefundAccessTest.invoke(new StaffInvoiceServlet(),"doGet",anonymous);RefundAccessTest.require(anonymous.redirect.endsWith("/login"),"Anonymous login redirect");checks++;
  }
  for(String action:new String[]{"cash","createQr","decline","checkQr"}){RefundAccessTest.Exchange e=new RefundAccessTest.Exchange(RefundAccessTest.user(5),"/staff/invoices/checkout",action);RefundAccessTest.invoke(new StaffInvoiceServlet(),"doPost",e);RefundAccessTest.require(e.status==403,"CSRF required for "+action);checks++;}
  for(String page:new String[]{"invoice-list.jsp","invoice-detail.jsp","invoice-export.jsp"}){RefundAccessTest.Exchange e=new RefundAccessTest.Exchange(RefundAccessTest.user(5),"/views/staff/"+page,null);new AuthenticationFilter().doFilter(e.request,e.response,(req,res)->{throw new AssertionError("Direct JSP bypass");});RefundAccessTest.require(e.redirect.endsWith("/staff/invoices"),"Direct JSP uses controller authorization");checks++;}
  RefundAccessTest.Exchange expired=new RefundAccessTest.Exchange(null,"/staff/invoices/detail",null);
  jakarta.servlet.http.HttpServletRequest withQuery=(jakarta.servlet.http.HttpServletRequest)java.lang.reflect.Proxy.newProxyInstance(jakarta.servlet.http.HttpServletRequest.class.getClassLoader(),new Class[]{jakarta.servlet.http.HttpServletRequest.class},(proxy,method,values)->{
   if(method.getName().equals("getQueryString"))return "id=18";
   try{return method.invoke(expired.request,values);}catch(java.lang.reflect.InvocationTargetException error){throw error.getCause();}
  });
  new AuthenticationFilter().doFilter(withQuery,expired.response,(req,res)->{throw new AssertionError("Anonymous request passed filter");});
  RefundAccessTest.require("/SWP-project/staff/invoices/detail?id=18".equals(expired.attributes.get("redirectAfterLogin")),"Keep invoice id when login expires");checks++;
  System.out.println("PASS: "+checks+" staff invoice authorization and CSRF checks.");
 }
}
