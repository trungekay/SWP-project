package com.visioncare.controller;
import com.visioncare.dao.*;
import com.visioncare.model.User;
import com.visioncare.util.WorkflowTokens;
import jakarta.servlet.*;
import jakarta.servlet.annotation.*;
import jakarta.servlet.http.*;
import java.io.*;
import java.util.*;
@WebServlet(urlPatterns={"/staff/refunds/complete","/staff/refunds/evidence"})
@MultipartConfig(maxFileSize=5242880,maxRequestSize=6291456)
public class StaffRefundSettlementServlet extends HttpServlet {
 private final RefundLifecycleDAO dao=new RefundLifecycleDAO();
 private User authorize(HttpServletRequest req,HttpServletResponse res,boolean evidence)throws IOException {
  User u=(User)req.getSession().getAttribute("user");
  if(u==null){res.sendRedirect(req.getContextPath()+"/login");return null;}
  if(u.getRoleId()!=1&&u.getRoleId()!=5&&!(evidence&&u.getRoleId()==2)){res.sendError(403);return null;}return u;
 }
 @Override protected void doGet(HttpServletRequest req,HttpServletResponse res)throws IOException,ServletException {
  if(authorize(req,res,true)==null)return;if(!req.getServletPath().endsWith("/evidence")){res.sendError(405);return;}
  try{Map<String,Object> image=dao.evidence(Integer.parseInt(req.getParameter("id")));if(image==null){res.sendError(404);return;}
   res.setContentType((String)image.get("type"));res.setHeader("X-Content-Type-Options","nosniff");res.setHeader("Cache-Control","no-store");res.getOutputStream().write((byte[])image.get("bytes"));
  }catch(NumberFormatException e){res.sendError(400);}catch(Exception e){throw new ServletException(e);}
 }
 @Override protected void doPost(HttpServletRequest req,HttpServletResponse res)throws IOException,ServletException {
  req.setCharacterEncoding("UTF-8");User user=authorize(req,res,false);if(user==null)return;
  int invoice=0;
  try{
   if(!WorkflowTokens.valid(req)){res.sendError(403);return;}
   if(!req.getServletPath().endsWith("/complete")){res.sendError(405);return;}
   int id=Integer.parseInt(req.getParameter("refundId"));invoice=Integer.parseInt(req.getParameter("invoiceId"));
   Map<String,Object> refund=dao.latest(invoice);if(refund==null||(Integer)refund.get("id")!=id)throw new IllegalArgumentException("Yêu cầu hoàn tiền không khớp hóa đơn.");
   if(!"yes".equals(req.getParameter("refundSent")))throw new IllegalArgumentException("Cần xác nhận đã thực sự hoàn tiền bên ngoài.");
   int employee=0;try(var c=DBContext.getConnection();var p=c.prepareStatement("SELECT Employee_ID FROM Employee_Profile WHERE Account_ID=?")){p.setInt(1,user.getId());try(var r=p.executeQuery()){if(r.next())employee=r.getInt(1);}}
   Part file=req.getPart("evidence");byte[] bytes=null;if(file!=null&&file.getSize()>0){if(file.getSize()>5242880)throw new IllegalArgumentException("Ảnh tối đa 5 MB.");try(InputStream stream=file.getInputStream()){bytes=stream.readNBytes(5242881);}}
   if(!dao.complete(id,employee,req.getParameter("completionNote"),bytes))throw new IllegalArgumentException("Yêu cầu chưa được duyệt, đã chi trả hoặc khoản hoàn không còn đủ điều kiện.");
   req.getSession().setAttribute("invoiceSuccess","Đã ghi nhận hoàn tiền và điều chỉnh doanh thu.");
  }catch(Exception e){log("Refund completion rejected",e);req.getSession().setAttribute("invoiceError",e instanceof IllegalArgumentException?e.getMessage():"Không thể xác nhận hoàn tiền. Kiểm tra ảnh PNG/JPEG tối đa 5 MB và tải lại trang.");}
  res.sendRedirect(req.getContextPath()+"/staff/invoices"+(invoice>0?"/detail?id="+invoice:""));
 }
}
