package com.visioncare.controller;

import com.visioncare.dao.*;
import com.visioncare.model.*;
import com.visioncare.util.*;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.net.URI;
import java.security.MessageDigest;
import java.nio.charset.StandardCharsets;
import java.util.*;

@WebServlet(name="StaffInvoiceServlet",urlPatterns={"/staff/invoices","/staff/invoices/detail","/staff/invoices/checkout","/staff/invoices/export"})
public class StaffInvoiceServlet extends HttpServlet {
 private final StaffInvoiceDAO dao=new StaffInvoiceDAO();
 private User authorize(HttpServletRequest req,HttpServletResponse res)throws IOException {
  User u=(User)req.getSession().getAttribute("user");
  if(u==null){if(InvoicePollingResponse.isRequested(req))InvoicePollingResponse.send(res,401,"Unauthenticated","Phiên đăng nhập đã hết hạn.");else res.sendRedirect(req.getContextPath()+"/login");return null;}
  if(u.getRoleId()!=5&&u.getRoleId()!=1&&u.getRoleId()!=2){if(InvoicePollingResponse.isRequested(req))InvoicePollingResponse.send(res,403,"Forbidden","Bạn không có quyền xem hóa đơn.");else res.sendError(403);return null;}return u;
 }
 @Override protected void doGet(HttpServletRequest req,HttpServletResponse res)throws ServletException,IOException {
  if(authorize(req,res)==null)return;
  res.setHeader("Cache-Control","no-store");
  HttpSession session=req.getSession();if(session.getAttribute("invoiceCsrf")==null)session.setAttribute("invoiceCsrf",UUID.randomUUID().toString());
  try {
   String path=req.getServletPath();
   if("/staff/invoices".equals(path)) {
    String search=req.getParameter("search"),status=req.getParameter("status"),date=req.getParameter("date");
    req.setAttribute("rows",dao.list(search,status,date));req.getRequestDispatcher("/views/staff/invoice-list.jsp").forward(req,res);return;
   }
   if(req.getParameter("id")==null && req.getParameter("appointmentId")==null){res.sendRedirect(req.getContextPath()+"/staff/invoices");return;}
   int id=req.getParameter("id")!=null?Integer.parseInt(req.getParameter("id")):dao.invoiceForAppointment(Integer.parseInt(req.getParameter("appointmentId")));StaffInvoice invoice=dao.get(id);req.setAttribute("invoice",invoice);req.setAttribute("fingerprint",invoice.fingerprint());
   if("/staff/invoices/export".equals(path)) {
    if(!invoice.finalized||!"Paid".equals(invoice.invoiceStatus)||invoice.getDue()!=0||invoice.isBlocked()){res.sendError(409,"Chỉ xuất hóa đơn đã chốt và thanh toán đủ.");return;}
    req.getRequestDispatcher("/views/staff/invoice-export.jsp").forward(req,res);return;
   }
   req.setAttribute("checkout",path.endsWith("/checkout"));req.getRequestDispatcher("/views/staff/invoice-detail.jsp").forward(req,res);
  }catch(IllegalArgumentException e){res.sendError(400,e.getMessage());}catch(Exception e){log("Cannot read staff invoice",e);res.sendError(500,"Không tải được hóa đơn. Vui lòng thử lại.");}
 }
 private int employee(User u)throws Exception{
  try(java.sql.Connection c=DBContext.getConnection();java.sql.PreparedStatement ps=c.prepareStatement("SELECT Employee_ID FROM Employee_Profile WHERE Account_ID=?")){ps.setInt(1,u.getId());try(java.sql.ResultSet r=ps.executeQuery()){if(r.next())return r.getInt(1);}}throw new IllegalArgumentException("Tài khoản chưa có hồ sơ nhân viên.");
 }
 @Override protected void doPost(HttpServletRequest req,HttpServletResponse res)throws ServletException,IOException {
  req.setCharacterEncoding("UTF-8");User user=authorize(req,res);if(user==null)return;
  String action=req.getParameter("action");
  boolean polling=InvoicePollingResponse.isRequested(req)||"checkQr".equals(action);
  String token=(String)req.getSession().getAttribute("invoiceCsrf"),provided=req.getParameter("csrfToken");
  if(token==null||provided==null||!MessageDigest.isEqual(token.getBytes(StandardCharsets.UTF_8),provided.getBytes(StandardCharsets.UTF_8))){if(polling)InvoicePollingResponse.send(res,403,"SessionExpired","Phiên xác nhận đã hết hạn. Đang làm mới trang.");else res.sendError(403,"Phiên thao tác đã hết hạn. Hãy tải lại trang.");return;}
  int id;try{id=Integer.parseInt(req.getParameter("invoiceId"));}catch(Exception e){if(polling)InvoicePollingResponse.send(res,400,"InvalidRequest","Mã hóa đơn không hợp lệ.");else res.sendError(400);return;}
  try {
   if(!"/staff/invoices/checkout".equals(req.getServletPath())){if(polling)InvoicePollingResponse.send(res,405,"InvalidRequest","Đường dẫn theo dõi không hợp lệ.");else res.sendError(405);return;}
   int employee=polling?0:employee(user);
   String expected=req.getParameter("fingerprint");
   if("decline".equals(action)){dao.decline(id,req.getParameter("itemKey"),employee,expected);req.getSession().setAttribute("invoiceSuccess","Đã bỏ khoản khách từ chối và tính lại hóa đơn.");}
   else if("cash".equals(action)){if(!"yes".equals(req.getParameter("cashReceived")))throw new IllegalArgumentException("Cần xác nhận đã nhận và đối chiếu tiền mặt.");dao.cash(id,employee,expected);req.getSession().setAttribute("invoiceSuccess","Đã xác nhận tiền mặt và chốt hóa đơn.");}
   else if("createQr".equals(action)) {
    if(PayOSUtil.getClientId().isEmpty()||PayOSUtil.getApiKey().isEmpty()||PayOSUtil.getChecksumKey().isEmpty())throw new IllegalStateException("Chưa cấu hình PayOS. Vui lòng chọn tiền mặt hoặc cấu hình cổng thanh toán.");
    StaffInvoice invoice=dao.get(id);Map<String,Object> pay=invoice.activePayment;
    if(pay==null)pay=dao.reserveQr(id,employee,expected);
    else if(!"Creating".equals(pay.get("status")))throw new IllegalStateException("Hóa đơn đã có QR đang chờ thanh toán.");
    long order=(Long)pay.get("orderCode");
    // Build return URLs from the current local application; return query strings never confirm payment.
    String base=req.getRequestURL().toString().replace(req.getServletPath(),"");
    PayOSUtil.PaymentLinkResult result=PayOSUtil.createPaymentLink(order,Math.toIntExact((Long)pay.get("amount")),"VCINV"+id,base+"/staff/invoices/checkout?id="+id,base+"/staff/invoices/checkout?id="+id);
    if(!result.success||result.checkoutUrl==null)throw new IllegalStateException("Chưa xác định được trạng thái tạo QR. Hãy kiểm tra hoặc thử lại cùng yêu cầu; không thu thêm tiền mặt khi QR chưa được hủy.");
    URI url=URI.create(result.checkoutUrl);if(!"https".equalsIgnoreCase(url.getScheme())||!"pay.payos.vn".equalsIgnoreCase(url.getHost()))throw new IllegalStateException("Địa chỉ thanh toán không hợp lệ.");
    dao.qrCreated(order,result.checkoutUrl,result.qrCode);
   }
   else if(polling){long order=Long.parseLong(req.getParameter("orderCode"));String status=StaffCheckoutPayments.refresh(order,id);InvoicePollingResponse.send(res,200,status,"Paid".equals(status)?"Thanh toán hoàn thành.":"Đang chờ xác nhận thanh toán.");return;}
   else throw new IllegalArgumentException("Thao tác không hợp lệ.");
  }catch(Exception e){if(polling){InvoicePollingResponse.send(res,409,"Retry","Chưa xác minh được giao dịch. Hệ thống sẽ tự thử lại.");return;}req.getSession().setAttribute("invoiceError",e instanceof IllegalArgumentException||e instanceof IllegalStateException?e.getMessage():"Không thể cập nhật hóa đơn. Vui lòng tải lại.");log("Staff invoice operation did not finish",e);}
  res.sendRedirect(req.getContextPath()+"/staff/invoices/checkout?id="+id);
 }
}
