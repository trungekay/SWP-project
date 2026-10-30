package com.visioncare.controller;
import com.visioncare.dao.*;
import com.visioncare.model.User;
import com.visioncare.util.WorkflowTokens;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.util.*;
@WebServlet("/staff/refunds/items")
public class StaffItemRefundServlet extends HttpServlet {
 @Override protected void doPost(HttpServletRequest req,HttpServletResponse res)throws IOException,ServletException {
  req.setCharacterEncoding("UTF-8");User user=(User)req.getSession().getAttribute("user");if(user==null){res.sendRedirect(req.getContextPath()+"/login");return;}
  if(user.getRoleId()!=1&&user.getRoleId()!=5){res.sendError(403);return;}
  if(!WorkflowTokens.valid(req)){res.sendError(403);return;}
  int invoice=0;
  try{invoice=Integer.parseInt(req.getParameter("invoiceId"));int employee=0;
   try(var c=DBContext.getConnection();var p=c.prepareStatement("SELECT Employee_ID FROM Employee_Profile WHERE Account_ID=?")){p.setInt(1,user.getId());try(var r=p.executeQuery()){if(r.next())employee=r.getInt(1);}}
   Map<String,Integer> selected=new LinkedHashMap<>();String[] keys=req.getParameterValues("itemKey");if(keys!=null)for(String key:keys){if(selected.containsKey(key))throw new IllegalArgumentException("Khoản hoàn tiền bị chọn trùng.");selected.put(key,Integer.parseInt(req.getParameter("quantity:"+key)));}
   int id=new ItemRefundDAO().create(invoice,employee,selected,req.getParameter("reason"),"yes".equals(req.getParameter("unusedConfirmed")));
   req.getSession().setAttribute("invoiceSuccess","Đã tạo yêu cầu #REF-"+id+" cho các khoản phát sinh. Chờ director xét duyệt; chưa ghi nhận chi trả.");
  }catch(Exception e){log("Cannot create item refund",e);req.getSession().setAttribute("invoiceError",e instanceof IllegalArgumentException||e instanceof IllegalStateException?e.getMessage():"Không thể tạo yêu cầu. Vui lòng tải lại và kiểm tra khoản đã thanh toán.");}
  res.sendRedirect(req.getContextPath()+"/staff/invoices"+(invoice>0?"/detail?id="+invoice+"#refund-settlement":""));
 }
}
