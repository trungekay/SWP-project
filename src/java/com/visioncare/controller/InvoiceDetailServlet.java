package com.visioncare.controller;
import com.visioncare.dao.PatientInvoiceDAO;
import com.visioncare.model.*;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
@WebServlet("/profile/invoice-detail")
public class InvoiceDetailServlet extends HttpServlet {
 private final PatientInvoiceDAO dao=new PatientInvoiceDAO();
 @Override protected void doGet(HttpServletRequest req,HttpServletResponse res)throws IOException,ServletException {
  User u=(User)req.getSession().getAttribute("user");if(u==null){res.sendRedirect(req.getContextPath()+"/login");return;}if(u.getRoleId()!=6){res.sendError(403);return;}res.setHeader("Cache-Control","no-store");
  try{StaffInvoice invoice=dao.completed(Integer.parseInt(req.getParameter("id")),u.getId());if(invoice==null){req.getSession().setAttribute("errorMessage","Hóa đơn chỉ hiển thị sau khi khám xong và staff chốt thanh toán đầy đủ.");res.sendRedirect(req.getContextPath()+"/views/profile/medical-history.jsp");return;}
   req.setAttribute("invoice",invoice);req.getRequestDispatcher("/views/profile/invoice-detail.jsp").forward(req,res);
  }catch(NumberFormatException e){res.sendError(400);}catch(Exception e){log("Cannot load final patient invoice",e);res.sendError(500,"Không tải được hóa đơn.");}
 }
}
