package com.visioncare.controller;

import com.visioncare.dao.LeaveCancelRequestDAO;
import com.visioncare.dao.RefundDAO;
import com.visioncare.dao.TimeSlotDAO;
import com.visioncare.dao.WorkScheduleDAO;
import com.visioncare.model.*;
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

@WebServlet(name = "DirectorScheduleServlet", urlPatterns = {
    "/director/schedules",
    "/director/doctors",
    "/director/specialists",
    "/director/staffs"
})
public class DirectorScheduleServlet extends HttpServlet {

    private final WorkScheduleDAO workScheduleDAO = new WorkScheduleDAO();
    private final TimeSlotDAO timeSlotDAO = new TimeSlotDAO();
    private final LeaveCancelRequestDAO leaveCancelRequestDAO = new LeaveCancelRequestDAO();
    private final RefundDAO refundDAO = new RefundDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Only Director (roleId 2) or Admin (roleId 1)
        if (currentUser.getRoleId() != 2 && currentUser.getRoleId() != 1 && !"director".equalsIgnoreCase(currentUser.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập trang điều hành này.");
            return;
        }

        try {
            String uri = request.getRequestURI();
            String typeParam = request.getParameter("type");
            String employeeType = "doctor"; // default

            if (uri.endsWith("/doctors") || "doctor".equalsIgnoreCase(typeParam)) {
                employeeType = "doctor";
            } else if (uri.endsWith("/specialists") || "specialist".equalsIgnoreCase(typeParam) || "medical_specialist".equalsIgnoreCase(typeParam)) {
                employeeType = "specialist";
            } else if (uri.endsWith("/staffs") || "staff".equalsIgnoreCase(typeParam)) {
                employeeType = "staff";
            }

            // Get list of employees for selected type
            List<User> employeeList = workScheduleDAO.getEmployeesByRoleType(employeeType);

            // Determine which employee's schedule to view
            String empIdParam = request.getParameter("empId");
            int selectedEmpId = -1;
            if (empIdParam != null && !empIdParam.trim().isEmpty()) {
                try {
                    selectedEmpId = Integer.parseInt(empIdParam.trim());
                } catch (NumberFormatException ignored) {}
            }

            // Fallback to first employee if not specified or not found
            if (selectedEmpId <= 0 && employeeList != null && !employeeList.isEmpty()) {
                selectedEmpId = employeeList.get(0).getActorId();
            }

            User selectedEmployee = null;
            if (selectedEmpId > 0) {
                selectedEmployee = workScheduleDAO.getActorProfile(selectedEmpId, employeeType);
            }

            // Date & Week calculation
            LocalDate today = LocalDate.now();
            int currentYear = today.getYear();
            int maxYear = currentYear + 1;
            String yearParam = request.getParameter("year");
            int selectedYear = currentYear;
            if (yearParam != null && !yearParam.isEmpty()) {
                try {
                    selectedYear = Integer.parseInt(yearParam);
                } catch (NumberFormatException ignored) {}
            }
            if (selectedYear > maxYear) selectedYear = maxYear;

            List<Integer> availableYears = new ArrayList<>();
            for (int y = currentYear - 2; y <= maxYear; y++) {
                availableYears.add(y);
            }

            LocalDate firstMondayOfYear = LocalDate.of(selectedYear, 1, 4).with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
            DateTimeFormatter dmyFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
            DateTimeFormatter dayFormatter = DateTimeFormatter.ofPattern("dd/MM");
            DateTimeFormatter fullFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");

            List<WeekOptionDTO> weekOptions = new ArrayList<>();
            int currentWeekOfThisYear = 1;
            for (int w = 1; w <= 53; w++) {
                LocalDate wStart = firstMondayOfYear.plusWeeks(w - 1);
                LocalDate wEnd = wStart.plusDays(6);
                if (w == 53 && wStart.getYear() > selectedYear) break;

                boolean isCurrentWeek = (selectedYear == currentYear)
                        && (today.isEqual(wStart) || (today.isAfter(wStart) && today.isBefore(wEnd.plusDays(1))));
                if (isCurrentWeek) {
                    currentWeekOfThisYear = w;
                }
                String label = String.format("Tuần %02d: %s - %s", w, wStart.format(dmyFormatter), wEnd.format(dmyFormatter));
                if (isCurrentWeek) {
                    label += " (Hiện tại)";
                }
                weekOptions.add(new WeekOptionDTO(w, 0, label, wStart.format(dmyFormatter), wEnd.format(dmyFormatter), isCurrentWeek));
            }

            String weekParam = request.getParameter("week");
            int selectedWeek = (selectedYear == currentYear) ? currentWeekOfThisYear : 1;
            if (weekParam != null && !weekParam.isEmpty()) {
                try {
                    int w = Integer.parseInt(weekParam);
                    if (w >= 1 && w <= weekOptions.size()) {
                        selectedWeek = w;
                    }
                } catch (NumberFormatException ignored) {}
            }

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

            // Slots configuration
            List<ScheduleSlotDTO> slots = new ArrayList<>();
            for (TimeSlotConfig cfg : timeSlotDAO.getConfiguredSlots()) {
                String startStr = cfg.getStartTime();
                if (startStr != null && startStr.length() >= 5) startStr = startStr.substring(0, 5);
                String endStr = cfg.getEndTime();
                if (endStr != null && endStr.length() >= 5) endStr = endStr.substring(0, 5);
                slots.add(new ScheduleSlotDTO(cfg.getSlotName(), startStr + " - " + endStr, cfg.getSession()));
            }

            String startDateStr = startOfSelectedWeek.format(fullFormatter);
            String endDateStr = endOfSelectedWeek.format(fullFormatter);
            Map<String, ScheduleCellDTO> scheduleMatrix = new HashMap<>();
            if (selectedEmpId > 0) {
                scheduleMatrix = workScheduleDAO.getScheduleMatrix(selectedEmpId, employeeType, startDateStr, endDateStr);
            }

            int totalWeeklySlots = 0;
            for (ScheduleDayDTO day : weekDays) {
                int daySlotsCount = 0;
                for (ScheduleSlotDTO slot : slots) {
                    String key = day.getFullDate() + "_" + slot.getId();
                    ScheduleCellDTO cell = scheduleMatrix.get(key);
                    if (cell != null && !cell.isOff() && !cell.isOnLeave() && !cell.isClosed()) {
                        daySlotsCount++;
                        totalWeeklySlots++;
                    }
                }
                day.setTotalSlotsCount(daySlotsCount);
            }
            double totalWeeklyHours = totalWeeklySlots * 0.5;

            int prevWeek = selectedWeek - 1;
            int prevYear = selectedYear;
            if (prevWeek < 1) {
                prevYear = selectedYear - 1;
                prevWeek = 52;
            }
            int nextWeek = selectedWeek + 1;
            int nextYear = selectedYear;
            if (nextWeek > weekOptions.size()) {
                if (selectedYear < maxYear) {
                    nextYear = selectedYear + 1;
                    nextWeek = 1;
                } else {
                    nextWeek = weekOptions.size();
                }
            }

            // Pending badges
            Map<String, Integer> leaveStats = leaveCancelRequestDAO.getStats();
            Map<String, Object> refundStats = refundDAO.getRefundStats();
            request.setAttribute("pendingLeaveCount", leaveStats.get("pending"));
            request.setAttribute("pendingRefundCount", refundStats.get("pending"));

            request.setAttribute("employeeType", employeeType);
            request.setAttribute("employeeList", employeeList);
            request.setAttribute("selectedEmployee", selectedEmployee);
            request.setAttribute("selectedEmpId", selectedEmpId);

            request.setAttribute("selectedYear", selectedYear);
            request.setAttribute("availableYears", availableYears);
            request.setAttribute("selectedWeek", selectedWeek);
            request.setAttribute("weekOptions", weekOptions);
            request.setAttribute("prevWeek", prevWeek);
            request.setAttribute("prevYear", prevYear);
            request.setAttribute("nextWeek", nextWeek);
            request.setAttribute("nextYear", nextYear);
            request.setAttribute("isViewingCurrentWeek", (selectedYear == currentYear && selectedWeek == currentWeekOfThisYear));
            request.setAttribute("weekDays", weekDays);
            request.setAttribute("slots", slots);
            request.setAttribute("scheduleMatrix", scheduleMatrix);
            request.setAttribute("totalWeeklySlots", totalWeeklySlots);
            request.setAttribute("totalWeeklyHours", totalWeeklyHours);

            String sessionFilter = request.getParameter("session");
            if (sessionFilter == null || sessionFilter.isEmpty()) sessionFilter = "all";
            request.setAttribute("sessionFilter", sessionFilter);

            request.getRequestDispatcher("/views/director/schedule-view.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.setContentType("text/html;charset=UTF-8");
            response.getWriter().println("<h3>Lỗi khi tải lịch làm việc của nhân sự: " + e.getMessage() + "</h3>");
        }
    }
}
