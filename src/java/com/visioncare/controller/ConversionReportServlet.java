package com.visioncare.controller;

import com.visioncare.dao.ConversionReportDAO;
import com.visioncare.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.*;
import java.time.temporal.ChronoUnit;

@WebServlet(name="ConversionReportServlet",urlPatterns={"/admin/conversion-report"})
public class ConversionReportServlet extends HttpServlet {
    private final ConversionReportDAO dao=new ConversionReportDAO();
    @Override protected void doGet(HttpServletRequest request,HttpServletResponse response) throws ServletException,IOException {
        HttpSession session=request.getSession(false);
        Object current=session==null?null:session.getAttribute("user");
        if(current==null){response.sendRedirect(request.getContextPath()+"/login");return;}
        if(!(current instanceof User) || (((User)current).getRoleId()!=1 && ((User)current).getRoleId()!=2)){
            response.sendError(HttpServletResponse.SC_FORBIDDEN);return;
        }
        response.setHeader("Cache-Control","no-store");
        LocalDateTime now=LocalDateTime.now(ZoneId.of("Asia/Ho_Chi_Minh"));
        LocalDate to=now.toLocalDate(),from=to.withDayOfMonth(1);
        String period=request.getParameter("period");
        if(!"today".equals(period) && !"year".equals(period) && !"custom".equals(period))period="month";
        if("today".equals(period))from=to;
        if("year".equals(period))from=to.withDayOfYear(1);
        if("custom".equals(period)){
            try {
                from=LocalDate.parse(request.getParameter("from"), java.time.format.DateTimeFormatter.ofPattern("dd/MM/uuuu").withResolverStyle(java.time.format.ResolverStyle.STRICT));to=LocalDate.parse(request.getParameter("to"), java.time.format.DateTimeFormatter.ofPattern("dd/MM/uuuu").withResolverStyle(java.time.format.ResolverStyle.STRICT));
                if(from.isAfter(to)||ChronoUnit.DAYS.between(from,to)>730)throw new IllegalArgumentException();
            }catch(Exception e){response.sendError(400,"Khoảng ngày không hợp lệ (tối đa 731 ngày).");return;}
        }
        request.setAttribute("reportPeriod",period);
        request.setAttribute("reportFromDisplay",from.format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/uuuu")));
        request.setAttribute("reportToDisplay",to.format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/uuuu")));
        request.setAttribute("reportFrom",from);request.setAttribute("reportTo",to);
        try {request.setAttribute("reportDays",dao.list(from,to,now));}
        catch(Exception e){log("Could not load conversion report",e);response.setStatus(503);
            request.setAttribute("reportError","Không tải được báo cáo. Vui lòng thử lại sau.");}
        request.getRequestDispatcher("/views/admin/conversion-report.jsp").forward(request,response);
    }
}
