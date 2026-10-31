package com.visioncare.controller;

import com.visioncare.dao.AdminDashboardDAO;
import com.visioncare.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.format.DateTimeParseException;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.text.NumberFormat;
import java.util.*;

@WebServlet(name = "AdminDashboardServlet", urlPatterns = {"/admin/dashboard"})
public class AdminDashboardServlet extends HttpServlet {

    private final AdminDashboardDAO dashboardDAO = new AdminDashboardDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User currentUser = session == null ? null : (User) session.getAttribute("user");
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        if (currentUser.getRoleId() != 1 && currentUser.getRoleId() != 2) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        try {
            LocalDate today=LocalDate.now(ZoneId.of("Asia/Ho_Chi_Minh"));
            String period=request.getParameter("period");
            if(!"today".equals(period)&&!"year".equals(period)&&!"custom".equals(period))period="month";
            LocalDate from="today".equals(period)?today:"year".equals(period)?today.withDayOfYear(1):today.withDayOfMonth(1);
            LocalDate to=today;
            if("custom".equals(period)){
                try {
                    from=LocalDate.parse(request.getParameter("from"),DateTimeFormatter.ofPattern("dd/MM/uuuu"));
                    to=LocalDate.parse(request.getParameter("to"),DateTimeFormatter.ofPattern("dd/MM/uuuu"));
                    if(from.isAfter(to)||ChronoUnit.DAYS.between(from,to)>730)throw new DateTimeParseException("Invalid range","",0);
                } catch(Exception ex){period="month";from=today.withDayOfMonth(1);to=today;}
            }
            String search=Optional.ofNullable(request.getParameter("search")).orElse("").trim();
            if(search.length()>80)search=search.substring(0,80);
            String status=request.getParameter("status");
            if(!"Paid".equals(status)&&!"Refunded".equals(status))status="all";
            int page=1;
            try{page=Math.max(1,Math.min(1000,Integer.parseInt(request.getParameter("page"))));}catch(Exception ignored){}
            Map<String,Long> revenue=dashboardDAO.getRevenue(from,to);
            long days=ChronoUnit.DAYS.between(from,to)+1;
            String bucket;
            int count;
            if("today".equals(period)){bucket="slot";count=12;}
            else if("year".equals(period)){bucket="month";count=12;}
            else if("month".equals(period)){bucket="week";count=(int)((days+6)/7);}
            else if(days<=31){bucket="day";count=(int)days;}
            else if(days<=120){bucket="week";count=(int)((days+6)/7);}
            else{bucket="month";count=(to.getYear()-from.getYear())*12+to.getMonthValue()-from.getMonthValue()+1;}
            List<Map<String,Long>> series=dashboardDAO.getRevenueSeries(from,to,bucket,count);
            long max=series.stream().mapToLong(v->v.get("Exam")+v.get("Surgery")).max().orElse(0);
            List<Map<String,Object>> bars=new ArrayList<>();
            for(int i=0;i<count;i++){
                Map<String,Object> bar=new HashMap<>();
                long exam=series.get(i).get("Exam");
                long surgery=series.get(i).get("Surgery");
                long total=exam+surgery;
                if("slot".equals(bucket))bar.put("label",String.format("%02d–%02d",i*2,(i+1)*2));
                else if("day".equals(bucket))bar.put("label",from.plusDays(i).getDayOfMonth()+"/"+from.plusDays(i).getMonthValue());
                else if("month".equals(bucket))bar.put("label","Tháng "+from.plusMonths(i).getMonthValue());
                else bar.put("label","Tuần "+(i+1));
                bar.put("value",money(total));
                bar.put("examValue",money(exam));
                bar.put("surgeryValue",money(surgery));
                bar.put("height",max==0?0:Math.round(total*100.0/max));
                bar.put("surgeryShare",total==0?0:Math.round(surgery*100.0/total));
                bars.add(bar);
            }
            request.setAttribute("revenue",revenue);
            request.setAttribute("totalFmt",money(revenue.get("Total")));
            request.setAttribute("examFmt",money(revenue.get("Exam")));
            request.setAttribute("surgeryFmt",money(revenue.get("Surgery")));
            request.setAttribute("refundFmt",money(revenue.get("Refund")));
            request.setAttribute("chartBars",bars);
            request.setAttribute("chartCount",count);
            request.setAttribute("chartTitle","slot".equals(bucket)?"Diễn biến nguồn thu hôm nay":"day".equals(bucket)?"Diễn biến nguồn thu theo ngày":"month".equals(bucket)?"Diễn biến nguồn thu theo tháng":"Diễn biến nguồn thu theo tuần");
            request.setAttribute("chartDescription","slot".equals(bucket)?"Mỗi cột là một khung 2 giờ":"year".equals(period)?"Từ đầu năm đến hôm nay":"Trong kỳ đã chọn");
            List<Map<String,Object>> journal=dashboardDAO.getJournal(from,to,search,status,page,15);
            request.setAttribute("hasNextPage",journal.size()>15);
            request.setAttribute("journal",journal.size()>15?journal.subList(0,15):journal);
            request.setAttribute("period",period);
            request.setAttribute("from",from);
            request.setAttribute("to",to);
            request.setAttribute("fromDisplay",from.format(DateTimeFormatter.ofPattern("dd/MM/uuuu")));
            request.setAttribute("toDisplay",to.format(DateTimeFormatter.ofPattern("dd/MM/uuuu")));
            request.setAttribute("search",search);
            request.setAttribute("status",status);
            request.setAttribute("pageNumber",page);
            request.setAttribute("nextPage",page+1);
            request.setAttribute("previousPage",Math.max(1,page-1));
            request.getRequestDispatcher("/views/admin/dashboard.jsp").forward(request, response);
        } catch (Exception e) {
            throw new ServletException("Không tải được thống kê dashboard.", e);
        }
    }

    private String money(long amount){
        return NumberFormat.getInstance(new Locale("vi","VN")).format(amount)+" đ";
    }
}
