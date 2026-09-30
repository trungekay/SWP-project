package com.visioncare.controller;

import com.visioncare.model.ScheduleDayDTO;
import com.visioncare.model.ScheduleSlotDTO;
import com.visioncare.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.temporal.TemporalAdjusters;
import java.util.*;

/**
 * Servlet xu ly man hinh Xem lich lam viec cho Doctor, Specialist, Staff.
 * URL: /employee/schedule
 */
@WebServlet(name = "EmployeeScheduleServlet", urlPatterns = {"/employee/schedule"})
public class EmployeeScheduleServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            HttpSession session = request.getSession();
            User currentUser = (User) session.getAttribute("user");

            // Neu chua dang nhap trong luc dev test, gan user tam de xem giao dien
            if (currentUser == null) {
                currentUser = new User(3, "ThS.BS. Lê Hoàng Lan", "doctor.lan@visioncare.vn", "", "0901234567", "doctor", "1985-05-15", "Hà Nội");
                session.setAttribute("user", currentUser);
            }

            // Tinh toan tuan hien tai hoac tuan duoc chon
            String weekOffsetParam = request.getParameter("weekOffset");
            int weekOffset = 0;
            if (weekOffsetParam != null && !weekOffsetParam.isEmpty()) {
                try {
                    weekOffset = Integer.parseInt(weekOffsetParam);
                } catch (NumberFormatException ignored) {
                }
            }

            LocalDate today = LocalDate.now();
            LocalDate startOfWeek = today.plusWeeks(weekOffset).with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
            
            DateTimeFormatter dayFormatter = DateTimeFormatter.ofPattern("dd/MM");
            DateTimeFormatter fullFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");

            String[] dayNames = {"Thứ Hai", "Thứ Ba", "Thứ Tư", "Thứ Năm", "Thứ Sáu", "Thứ Bảy", "Chủ Nhật"};
            
            List<ScheduleDayDTO> weekDays = new ArrayList<>();
            for (int i = 0; i < 7; i++) {
                LocalDate date = startOfWeek.plusDays(i);
                boolean isToday = date.isEqual(today);
                weekDays.add(new ScheduleDayDTO(
                        dayNames[i],
                        date.format(dayFormatter),
                        date.format(fullFormatter),
                        isToday
                ));
            }

            // Danh sach cac Slot 30 phut theo nghiep vu
            List<ScheduleSlotDTO> slots = new ArrayList<>();
            slots.add(new ScheduleSlotDTO("Slot 1", "08:00 - 08:30", "Morning"));
            slots.add(new ScheduleSlotDTO("Slot 2", "08:30 - 09:00", "Morning"));
            slots.add(new ScheduleSlotDTO("Slot 3", "09:00 - 09:30", "Morning"));
            slots.add(new ScheduleSlotDTO("Slot 4", "09:30 - 10:00", "Morning"));
            slots.add(new ScheduleSlotDTO("Slot 5", "10:00 - 10:30", "Morning"));
            slots.add(new ScheduleSlotDTO("Slot 6", "10:30 - 11:00", "Morning"));
            slots.add(new ScheduleSlotDTO("Slot 7", "11:00 - 11:30", "Morning"));
            slots.add(new ScheduleSlotDTO("Slot 8", "13:30 - 14:00", "Afternoon"));
            slots.add(new ScheduleSlotDTO("Slot 9", "14:00 - 14:30", "Afternoon"));
            slots.add(new ScheduleSlotDTO("Slot 10", "14:30 - 15:00", "Afternoon"));
            slots.add(new ScheduleSlotDTO("Slot 11", "15:00 - 15:30", "Afternoon"));
            slots.add(new ScheduleSlotDTO("Slot 12", "15:30 - 16:00", "Afternoon"));
            slots.add(new ScheduleSlotDTO("Slot 13", "16:00 - 16:30", "Afternoon"));
            slots.add(new ScheduleSlotDTO("Slot 14", "16:30 - 17:00", "Afternoon"));

            // Lay ca loc (all, Morning, Afternoon)
            String sessionFilter = request.getParameter("session");
            if (sessionFilter == null || sessionFilter.isEmpty()) {
                sessionFilter = "all";
            }

            // Truyen attribute sang JSP
            request.setAttribute("weekDays", weekDays);
            request.setAttribute("slots", slots);
            request.setAttribute("weekOffset", weekOffset);
            request.setAttribute("sessionFilter", sessionFilter);
            request.setAttribute("currentUser", currentUser);
            request.setAttribute("todayStr", java.time.LocalDateTime.now().format(DateTimeFormatter.ofPattern("HH:mm • dd/MM/yyyy")));

            request.getRequestDispatcher("/views/employee/schedule.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.setContentType("text/html;charset=UTF-8");
            response.getWriter().println("<h3>Lỗi khi tải lịch làm việc: " + e.getMessage() + "</h3>");
        }
    }
}
