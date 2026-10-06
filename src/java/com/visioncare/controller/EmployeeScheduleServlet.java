package com.visioncare.controller;
import com.visioncare.dao.TimeSlotDAO;
import com.visioncare.dao.WorkScheduleDAO;
import com.visioncare.model.ScheduleCellDTO;
import com.visioncare.model.ScheduleDayDTO;
import com.visioncare.model.ScheduleSlotDTO;
import com.visioncare.model.TimeSlotConfig;
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
import java.util.*;
@WebServlet(name = "EmployeeScheduleServlet", urlPatterns = {"/employee/schedule"})
public class EmployeeScheduleServlet extends HttpServlet {
    private final WorkScheduleDAO workScheduleDAO = new WorkScheduleDAO();
    private final TimeSlotDAO timeSlotDAO = new TimeSlotDAO();
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            HttpSession session = request.getSession();
            User currentUser = (User) session.getAttribute("user");
            if (currentUser == null) {
                currentUser = workScheduleDAO.getActorProfile(1, "doctor");
                if (currentUser == null) {
                    currentUser = new User();
                    currentUser.setId(3);
                    currentUser.setActorId(1);
                    currentUser.setFullName("BS. Trần Văn Nam");
                    currentUser.setRole("doctor");
                    currentUser.setSpecialty("Khám mắt tổng quát");
                    currentUser.setRoomName("Phòng Khám Mắt 101");
                }
                session.setAttribute("user", currentUser);
            }
            String viewActorIdParam = request.getParameter("viewActorId");
            String viewRoleParam = request.getParameter("viewRole");
            int effectiveActorId = currentUser.getActorId() > 0 ? currentUser.getActorId() : 1;
            String effectiveRole = currentUser.getRole() != null ? currentUser.getRole() : "doctor";
            if (viewActorIdParam != null && !viewActorIdParam.isEmpty() && viewRoleParam != null && !viewRoleParam.isEmpty()) {
                try {
                    effectiveActorId = Integer.parseInt(viewActorIdParam);
                    effectiveRole = viewRoleParam;
                } catch (NumberFormatException ignored) {
                }
            }
            User viewedActor = workScheduleDAO.getActorProfile(effectiveActorId, effectiveRole);
            if (viewedActor == null) {
                viewedActor = currentUser;
            }
            LocalDate today = LocalDate.now();
            int currentYear = today.getYear();
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
            List<ScheduleSlotDTO> slots = new ArrayList<>();
            try {
                com.visioncare.dao.TimeSlotDAO timeSlotDAO = new com.visioncare.dao.TimeSlotDAO();
                for (com.visioncare.model.TimeSlotConfig cfg : timeSlotDAO.getConfiguredSlots()) {
                    String startStr = cfg.getStartTime();
                    if (startStr != null && startStr.length() >= 5) startStr = startStr.substring(0, 5);
                    String endStr = cfg.getEndTime();
                    if (endStr != null && endStr.length() >= 5) endStr = endStr.substring(0, 5);
                    String timeRange = startStr + " - " + endStr;
                    slots.add(new ScheduleSlotDTO(cfg.getSlotName(), timeRange, cfg.getSession()));
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            String startDateStr = startOfSelectedWeek.format(fullFormatter);
            String endDateStr = endOfSelectedWeek.format(fullFormatter);
            Map<String, ScheduleCellDTO> scheduleMatrix = workScheduleDAO.getScheduleMatrix(
                    effectiveActorId, effectiveRole, startDateStr, endDateStr
            );
            Map<String, String> slotStatusMap = new HashMap<>();
            try {
                List<TimeSlotConfig> cfgSlots = timeSlotDAO.getConfiguredSlots();
                for (TimeSlotConfig cfg : cfgSlots) {
                    slotStatusMap.put(cfg.getSlotName(), cfg.getStatus());
                }
            } catch (Exception ignored) {}
            int totalWeeklySlots = 0;
            for (ScheduleDayDTO day : weekDays) {
                int daySlotsCount = 0;
                for (ScheduleSlotDTO slot : slots) {
                    String key = day.getFullDate() + "_" + slot.getId();
                    ScheduleCellDTO cell = scheduleMatrix.get(key);
                    boolean isGloballyClosed = "Canceled".equalsIgnoreCase(slotStatusMap.get(slot.getId())) 
                            || "Inactive".equalsIgnoreCase(slotStatusMap.get(slot.getId())) 
                            || "Disabled".equalsIgnoreCase(slotStatusMap.get(slot.getId()));
                    if (!isGloballyClosed && cell != null && !cell.isOff() && !cell.isOnLeave() && !cell.isClosed()) {
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
            boolean isViewingCurrentWeek = (selectedYear == currentYear && selectedWeek == currentWeekOfThisYear);
            String sessionFilter = request.getParameter("session");
            if (sessionFilter == null || sessionFilter.isEmpty()) {
                sessionFilter = "all";
            }
            List<User> staffAndDoctorList = workScheduleDAO.getStaffAndDoctorList();
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
            request.setAttribute("scheduleMatrix", scheduleMatrix);
            request.setAttribute("totalWeeklySlots", totalWeeklySlots);
            request.setAttribute("totalWeeklyHours", totalWeeklyHours);
            request.setAttribute("sessionFilter", sessionFilter);
            request.setAttribute("currentUser", currentUser);
            request.setAttribute("viewedActor", viewedActor);
            request.setAttribute("effectiveActorId", effectiveActorId);
            request.setAttribute("effectiveRole", effectiveRole);
            request.setAttribute("slotStatusMap", slotStatusMap);
            request.setAttribute("todayStr", LocalDateTime.now().format(DateTimeFormatter.ofPattern("HH:mm • dd/MM/yyyy")));
            request.getRequestDispatcher("/views/employee/schedule.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.setContentType("text/html;charset=UTF-8");
            response.getWriter().println("<h3>Lỗi khi tải lịch làm việc: " + e.getMessage() + "</h3>");
        }
    }
}
