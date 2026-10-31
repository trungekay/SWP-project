package com.visioncare.controller;

import com.visioncare.dao.LeaveCancelRequestDAO;
import com.visioncare.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.UUID;
import java.util.List;
import java.util.Map;

@WebServlet(urlPatterns="/employee/leave-requests")
public class EmployeeLeaveRequestServlet extends HttpServlet {
    private final LeaveCancelRequestDAO dao=new LeaveCancelRequestDAO();

    private User authorize(HttpServletRequest req,HttpServletResponse res) throws IOException {
        HttpSession session=req.getSession(false);
        User user=session==null?null:(User)session.getAttribute("user");
        if(user==null){res.sendRedirect(req.getContextPath()+"/login");return null;}
        if((user.getRoleId()!=3&&user.getRoleId()!=4)||user.getActorId()<=0){res.sendError(403);return null;}
        return user;
    }

    @Override protected void doGet(HttpServletRequest req,HttpServletResponse res) throws ServletException,IOException {
        User user=authorize(req,res);if(user==null)return;
        res.setHeader("Cache-Control","no-store");
        HttpSession session=req.getSession();
        if(session.getAttribute("scheduleCsrf")==null)session.setAttribute("scheduleCsrf",UUID.randomUUID().toString());
        try {
            req.setAttribute("ownLeave",true);
            req.setAttribute("readOnly",false);
            req.setAttribute("actorLabel",user.getRoleId()==3?"Bác sĩ khám":"Bác sĩ phẫu thuật");
            List<Map<String,Object>> shifts=dao.getAvailableShifts(user.getActorId());
            req.setAttribute("shifts",shifts);
            req.setAttribute("previewOnly","1".equals(req.getParameter("preview")));
            if(req.getParameter("scheduleId")!=null&&!req.getParameter("scheduleId").isBlank()) {
                int id=Integer.parseInt(req.getParameter("scheduleId"));
                boolean valid=shifts.stream().anyMatch(s->((Number)s.get("scheduleId")).intValue()==id);
                if(valid) {
                    req.setAttribute("selectedShift",id);
                    req.setAttribute("affectedAppointments",dao.getAffectedAppointments(id,user.getActorId()));
                } else {
                    if("1".equals(req.getParameter("preview"))){res.sendError(409,"Buổi làm việc không còn khả dụng.");return;}
                    req.setAttribute("formError","Buổi đã chọn không còn đủ điều kiện xin nghỉ. Vui lòng chọn lại.");
                }
            }
            if(!"1".equals(req.getParameter("preview")))
                req.setAttribute("requests",dao.getAllRequests("all","all").stream()
                    .filter(r->r.getRequesterEmployeeId()==user.getActorId()).collect(java.util.stream.Collectors.toList()));
            req.getRequestDispatcher("/views/employee/leave-requests.jsp").forward(req,res);
        } catch(NumberFormatException e){res.sendError(400,"Mã lịch không hợp lệ.");}
        catch(Exception e){log("Cannot load leave requests",e);throw new ServletException("Không thể tải yêu cầu nghỉ.",e);}
    }

    @Override protected void doPost(HttpServletRequest req,HttpServletResponse res) throws ServletException,IOException {
        req.setCharacterEncoding("UTF-8");
        User user=authorize(req,res);if(user==null)return;
        HttpSession session=req.getSession();
        Object token=session.getAttribute("scheduleCsrf");
        if(token==null||!token.equals(req.getParameter("csrfToken"))){res.sendError(403);return;}
        try {
            String reason=req.getParameter("reason");
            int reviewed=user.getRoleId()==3?Integer.parseInt(req.getParameter("reviewedCount")):0;
            boolean ok=dao.createRequest(Integer.parseInt(req.getParameter("scheduleId")),user.getActorId(),null,reason,reviewed,"yes".equals(req.getParameter("impactConfirmed")));
            if(!ok) {
                req.setAttribute("draftReason",reason);
                req.setAttribute("formError","Chưa gửi yêu cầu. Vui lòng kiểm tra lại danh sách lịch hẹn, xác nhận ảnh hưởng và điều kiện của buổi làm việc. Nội dung đã nhập được giữ lại.");
                doGet(req,res);return;
            }
            session.setAttribute("successMessage","Đã gửi yêu cầu nghỉ cả buổi, chờ giám đốc duyệt. Lịch làm việc và lịch hẹn bệnh nhân chưa thay đổi.");
        } catch(NumberFormatException e){res.sendError(400,"Mã lịch không hợp lệ.");return;}
        catch(Exception e){log("Cannot create leave request",e);session.setAttribute("errorMessage","Không thể gửi yêu cầu. Vui lòng thử lại.");}
        res.sendRedirect(req.getContextPath()+"/employee/leave-requests");
    }
}
