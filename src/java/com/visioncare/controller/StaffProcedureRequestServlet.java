package com.visioncare.controller;

import com.visioncare.dao.ProcedureOrderDAO;
import com.visioncare.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.UUID;

@WebServlet("/staff/procedure-requests")
public class StaffProcedureRequestServlet extends HttpServlet {
    private final ProcedureOrderDAO dao=new ProcedureOrderDAO();

    private User authorize(HttpServletRequest req,HttpServletResponse res) throws IOException {
        HttpSession s=req.getSession(false);
        User u=s==null?null:(User)s.getAttribute("user");
        if(u==null){res.sendRedirect(req.getContextPath()+"/login");return null;}
        if(u.getRoleId()!=5||u.getActorId()<=0){res.sendError(403);return null;}
        return u;
    }

    @Override protected void doGet(HttpServletRequest req,HttpServletResponse res) throws ServletException,IOException {
        if(authorize(req,res)==null)return;
        res.setHeader("Cache-Control","no-store");
        HttpSession session=req.getSession();
        if(session.getAttribute("procedureRequestCsrf")==null)
            session.setAttribute("procedureRequestCsrf",UUID.randomUUID().toString());
        try {
            req.setAttribute("schemaReady",dao.isStaffRequestSchemaReady());
            java.util.List<java.util.Map<String,Object>> patients=dao.getProcedureRequestPatients();
            req.setAttribute("patients",patients);
            req.setAttribute("services",dao.getProcedureRequestServices());
            String selected=req.getParameter("appointmentId");
            if(selected!=null&&!selected.isBlank()){
                int id=Integer.parseInt(selected);
                req.setAttribute("selectedAppointment",id);
                req.setAttribute("selectedEligible",patients.stream().anyMatch(p->((Number)p.get("appointmentId")).intValue()==id));
                java.util.Map<String,Object> context=dao.getProcedureRequestContext(id);
                req.setAttribute("patientContext",context);
                if(context.get("recordId")!=null)
                    req.setAttribute("existingOrders",dao.getTodoListByRecordId(((Number)context.get("recordId")).intValue()));
            }
            req.getRequestDispatcher("/views/staff/procedure-request.jsp").forward(req,res);
        }catch(NumberFormatException e){res.sendError(400);}
        catch(Exception e){log("Cannot load Staff procedure requests",e);throw new ServletException("Không thể tải màn chuyển ca thủ thuật.",e);}
    }

    @Override protected void doPost(HttpServletRequest req,HttpServletResponse res) throws ServletException,IOException {
        req.setCharacterEncoding("UTF-8");
        User u=authorize(req,res);if(u==null)return;
        Object token=req.getSession().getAttribute("procedureRequestCsrf");
        if(token==null||!token.equals(req.getParameter("csrfToken"))){res.sendError(403);return;}
        try {
            if(!dao.isStaffRequestSchemaReady()){
                req.setAttribute("formError","Chưa thể gửi ca: cơ sở dữ liệu chưa được cập nhật cho chức năng này.");
            }else{
                int id=dao.createStaffRequest(Integer.parseInt(req.getParameter("appointmentId")),
                        Integer.parseInt(req.getParameter("serviceId")),u.getActorId(),req.getParameter("notes"));
                req.getSession().setAttribute("procedureRequestSuccess","Đã gửi yêu cầu thủ thuật #CD-"+id
                        +" cho lượt khám #APT-"+Integer.parseInt(req.getParameter("appointmentId"))+" vào hàng đợi BSPT.");
                res.sendRedirect(req.getContextPath()+"/staff/procedure-requests?appointmentId="+Integer.parseInt(req.getParameter("appointmentId")));
                return;
            }
        }catch(NumberFormatException e){req.setAttribute("formError","Vui lòng chọn lượt khám và dịch vụ thủ thuật.");}
        catch(IllegalArgumentException|IllegalStateException e){req.setAttribute("formError",e.getMessage());}
        catch(Exception e){log("Cannot send Staff procedure request",e);req.setAttribute("formError","Không gửi được ca. Vui lòng tải lại và kiểm tra ca đã có trước khi thử lại.");}
        req.setAttribute("draftNotes",req.getParameter("notes"));
        doGet(req,res);
    }
}
