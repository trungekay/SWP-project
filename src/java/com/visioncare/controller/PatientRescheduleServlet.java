package com.visioncare.controller;
import com.visioncare.dao.*;
import com.visioncare.model.*;
import com.visioncare.util.WorkflowTokens;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.util.*;
@WebServlet("/profile/reschedule")
public class PatientRescheduleServlet extends HttpServlet {
 private final PatientRescheduleDAO dao=new PatientRescheduleDAO();
 private User authorize(HttpServletRequest req,HttpServletResponse res)throws IOException {
  User u=(User)req.getSession().getAttribute("user");if(u==null){res.sendRedirect(req.getContextPath()+"/login");return null;}if(u.getRoleId()!=6){res.sendError(403);return null;}return u;
 }
 @Override protected void doGet(HttpServletRequest req,HttpServletResponse res)throws IOException,ServletException {
  User u=authorize(req,res);if(u==null)return;res.setHeader("Cache-Control","no-store");WorkflowTokens.ensure(req.getSession());
  try{int id=Integer.parseInt(req.getParameter("id"));Map<String,Object> visit=dao.current(id,u.getId());if(visit==null){res.sendError(409,"Lịch hẹn không còn đủ điều kiện đổi lịch.");return;}
   if("slots".equals(req.getParameter("action"))){
    int doctor=Integer.parseInt(req.getParameter("doctorId"));String date=java.time.LocalDate.parse(req.getParameter("date")).toString();new AppointmentDAO().autoCancelExpiredPendingAppointments();
    List<TimeSlot> slots=new WorkScheduleDAO().getDoctorSlotsForDate(doctor,date);StringBuilder json=new StringBuilder("[");
    for(TimeSlot slot:slots)if(!slot.isBooked()&&!slot.isPast()){if(json.length()>1)json.append(',');json.append("{\"id\":").append(slot.getId()).append(",\"label\":\"").append(slot.getStartTime()).append(" - ").append(slot.getEndTime()).append("\"}");}
    res.setContentType("application/json;charset=UTF-8");res.getWriter().write(json.append(']').toString());return;
   }
   req.setAttribute("appointment",visit);req.setAttribute("doctors",new DoctorDAO().getAll());req.getRequestDispatcher("/views/profile/reschedule.jsp").forward(req,res);
  }catch(IllegalArgumentException e){res.sendError(400);}catch(Exception e){log("Cannot load reschedule",e);res.sendError(500,"Không tải được lịch trống.");}
 }
 @Override protected void doPost(HttpServletRequest req,HttpServletResponse res)throws IOException,ServletException {
  User u=authorize(req,res);if(u==null)return;if(!WorkflowTokens.valid(req)){res.sendError(403);return;}
  try{
   var result=com.visioncare.util.PatientRescheduleWorkflow.move(dao,Integer.parseInt(req.getParameter("appointmentId")),u.getId(),Integer.parseInt(req.getParameter("scheduleId")),com.visioncare.util.EmailUtil::sendRescheduleConfirmationEmail);
   if(!result.moved())throw new IllegalArgumentException("Ca khám đã được đặt hoặc lịch hẹn không còn được phép đổi. Vui lòng chọn lại.");
   if(result.emailError()==null)req.getSession().setAttribute("successMessage","Đã đổi bác sĩ / ca khám, giữ nguyên phí khám đã thanh toán. Email xác nhận lịch mới đã được gửi đến email tài khoản của bạn.");
   else {
    log("Reschedule committed but confirmation email failed",result.emailError());
    req.getSession().setAttribute("successMessage","Đã đổi bác sĩ / ca khám thành công và giữ nguyên phí khám đã thanh toán.");
    req.getSession().setAttribute("errorMessage","Chưa gửi được email xác nhận. Lịch mới đã được lưu; vui lòng kiểm tra thông tin trong lịch sử đặt lịch.");
   }
  }
  catch(Exception e){log("Reschedule rejected",e);req.getSession().setAttribute("errorMessage",e instanceof IllegalArgumentException?e.getMessage():"Không thể đổi lịch. Vui lòng tải lại và chọn ca trống.");}
  res.sendRedirect(req.getContextPath()+"/views/profile/appointment-history.jsp");
 }
}
