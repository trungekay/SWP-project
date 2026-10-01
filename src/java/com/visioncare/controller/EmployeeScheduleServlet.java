package com.visioncare.controller;

import com.visioncare.model.ScheduleDayDTO;
import com.visioncare.model.ScheduleSlotDTO;
import com.visioncare.model.User;
import com.visioncare.model.WeekOptionDTO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.temporal.TemporalAdjusters;
import java.time.temporal.WeekFields;
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

            LocalDate today = LocalDate.now();
            int currentYear = today.getYear();

            // 1. Xu ly Chon Nam (Toi da la Nam hien tai + 1)
            int maxYear = currentYear + 1;
            String yearParam = request.getParameter("year");
            int selectedYear = currentYear;
            if (yearParam != null && !yearParam.isEmpty()) {
                try {
                    selectedYear = Integer.parseInt(yearParam);
                } catch (NumberFormatException ignored) {
                }
            }

            if (selectedYear > maxYear) {
                selectedYear = maxYear;
            }

            // Danh sach cac nam de chon trong Dropdown (Nam hien tai - 2 den Nam hien tai + 1)
            List<Integer> availableYears = new ArrayList<>();
            for (int y = currentYear - 2; y <= maxYear; y++) {
                availableYears.add(y);
            }

            // 2. Tinh toan tat ca cac tuan trong nam duoc chon
            LocalDate firstMondayOfYear = LocalDate.of(selectedYear, 1, 4).with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
            DateTimeFormatter dmyFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
            DateTimeFormatter dayFormatter = DateTimeFormatter.ofPattern("dd/MM");
            DateTimeFormatter fullFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");

            List<WeekOptionDTO> weekOptions = new ArrayList<>();
            int currentWeekOfThisYear = 1;

            for (int w = 1; w <= 53; w++) {
                LocalDate wStart = firstMondayOfYear.plusWeeks(w - 1);
                LocalDate wEnd = wStart.plusDays(6);

                // Dung neu tuan 53 da qua sang nam tiep theo
                if (w == 53 && wStart.getYear() > selectedYear) {
                    break;
                }

                boolean isCurrentWeek = (selectedYear == currentYear)
                        && (today.isEqual(wStart) || (today.isAfter(wStart) && today.isBefore(wEnd.plusDays(1))));

                if (isCurrentWeek) {
                    currentWeekOfThisYear = w;
                }

                String label = String.format("Tuần %02d: %s - %s", w, wStart.format(dmyFormatter), wEnd.format(dmyFormatter));
                if (isCurrentWeek) {
                    label += " (Tuần hiện tại)";
                }

                weekOptions.add(new WeekOptionDTO(w, 0, label, wStart.format(dmyFormatter), wEnd.format(dmyFormatter), isCurrentWeek));
            }

            // 3. Xu ly Tuan duoc chon
            String weekParam = request.getParameter("week");
            int selectedWeek = (selectedYear == currentYear) ? currentWeekOfThisYear : 1;
            if (weekParam != null && !weekParam.isEmpty()) {
                try {
                    int w = Integer.parseInt(weekParam);
                    if (w >= 1 && w <= weekOptions.size()) {
                        selectedWeek = w;
                    }
                } catch (NumberFormatException ignored) {
                }
            }

            // Tinh 7 ngay cua Tuan duoc chon (Thu Hai -> Chu Nhat)
            LocalDate startOfSelectedWeek = firstMondayOfYear.plusWeeks(selectedWeek - 1);
            LocalDate endOfSelectedWeek = startOfSelectedWeek.plusDays(6);

            String[] dayNames = {"Thứ Hai", "Thứ Ba", "Thứ Tư", "Thứ Năm", "Thứ Sáu", "Thứ Bảy", "Chủ Nhật"};
            List<ScheduleDayDTO> weekDays = new ArrayList<>();
            for (int i = 0; i < 7; i++) {
                LocalDate date = startOfSelectedWeek.plusDays(i);
                boolean isToday = date.isEqual(today);
                weekDays.add(new ScheduleDayDTO(
                        dayNames[i],
                        date.format(dayFormatter),
                        date.format(fullFormatter),
                        isToday
                ));
            }

            // Tinh tuan truoc / tuan sau cho nut mui ten < va >
            int prevWeek = selectedWeek - 1;
            int prevYear = selectedYear;
            if (prevWeek < 1) {
                prevYear = selectedYear - 1;
                prevWeek = 52; // Tuan cuoi nam truoc
            }

            int nextWeek = selectedWeek + 1;
            int nextYear = selectedYear;
            if (nextWeek > weekOptions.size()) {
                if (selectedYear < maxYear) {
                    nextYear = selectedYear + 1;
                    nextWeek = 1; // Tuan 1 nam sau
                } else {
                    nextWeek = weekOptions.size(); // Giu o tuan cuoi nam toi da
                }
            }

            boolean isViewingCurrentWeek = (selectedYear == currentYear && selectedWeek == currentWeekOfThisYear);

            // 4. Danh sach cac Slot 30 phut theo nghiep vu
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
            request.setAttribute("selectedYear", selectedYear);
            request.setAttribute("availableYears", availableYears);
            request.setAttribute("selectedWeek", selectedWeek);
            request.setAttribute("weekOptions", weekOptions);
            request.setAttribute("prevWeek", prevWeek);
            request.setAttribute("prevYear", prevYear);
            request.setAttribute("nextWeek", nextWeek);
            request.setAttribute("nextYear", nextYear);
            request.setAttribute("isViewingCurrentWeek", isViewingCurrentWeek);
            request.setAttribute("currentYear", currentYear);
            request.setAttribute("currentWeekOfThisYear", currentWeekOfThisYear);

            request.setAttribute("weekDays", weekDays);
            request.setAttribute("slots", slots);
            request.setAttribute("sessionFilter", sessionFilter);
            request.setAttribute("currentUser", currentUser);
            request.setAttribute("todayStr", LocalDateTime.now().format(DateTimeFormatter.ofPattern("HH:mm • dd/MM/yyyy")));

            request.getRequestDispatcher("/views/employee/schedule.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.setContentType("text/html;charset=UTF-8");
            response.getWriter().println("<h3>Lỗi khi tải lịch làm việc: " + e.getMessage() + "</h3>");
        }
    }
}
