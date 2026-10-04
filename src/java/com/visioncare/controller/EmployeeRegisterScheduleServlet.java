package com.visioncare.controller;
import com.visioncare.dao.TimeSlotDAO;
import com.visioncare.dao.WorkScheduleDAO;
import com.visioncare.model.ScheduleDayDTO;
import com.visioncare.model.ScheduleRegistrationDTO;
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
@WebServlet(name = "EmployeeRegisterScheduleServlet", urlPatterns = {"/employee/register-schedule"})
public class EmployeeRegisterScheduleServlet extends HttpServlet {
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
            int actorId = currentUser.getActorId() > 0 ? currentUser.getActorId() : 1;
            String role = currentUser.getRole() != null ? currentUser.getRole() : "doctor";
            LocalDate today = LocalDate.now();
            int currentYear = today.getYear();
            int maxYear = currentYear + 1;
            LocalDate firstMondayOfCurrentYear = LocalDate.of(currentYear, 1, 4).with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
            DateTimeFormatter dmyFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
            DateTimeFormatter dayFormatter = DateTimeFormatter.ofPattern("dd/MM");
            DateTimeFormatter fullFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
            int currentWeekOfThisYear = 1;
            int totalWeeksInCurrentYear = 52;
            for (int w = 1; w <= 53; w++) {
                LocalDate wStart = firstMondayOfCurrentYear.plusWeeks(w - 1);
                LocalDate wEnd = wStart.plusDays(6);
                if (w == 53 && wStart.getYear() > currentYear) {
                    break;
                }
                totalWeeksInCurrentYear = w;
                if (today.isEqual(wStart) || (today.isAfter(wStart) && today.isBefore(wEnd.plusDays(1)))) {
                    currentWeekOfThisYear = w;
                }
            }
            int earliestYear = currentYear;
            int earliestWeek = currentWeekOfThisYear + 1;
            if (earliestWeek > totalWeeksInCurrentYear) {
                earliestYear = currentYear + 1;
                earliestWeek = 1;
            }
            List<Integer> availableYears = new ArrayList<>();
            for (int y = earliestYear; y <= maxYear; y++) {
                availableYears.add(y);
            }
            String yearParam = request.getParameter("year");
            int selectedYear = earliestYear;
            if (yearParam != null && !yearParam.isEmpty()) {
                try {
                    int y = Integer.parseInt(yearParam);
                    if (y >= earliestYear && y <= maxYear) {
                        selectedYear = y;
                    }
                } catch (NumberFormatException ignored) {
                }
            }
            LocalDate firstMondayOfSelectedYear = LocalDate.of(selectedYear, 1, 4).with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
            int minWeekInSelectedYear = (selectedYear == currentYear) ? (currentWeekOfThisYear + 1) : 1;
            List<WeekOptionDTO> weekOptions = new ArrayList<>();
            int totalWeeksInSelectedYear = 52;
            for (int w = 1; w <= 53; w++) {
                LocalDate wStart = firstMondayOfSelectedYear.plusWeeks(w - 1);
                LocalDate wEnd = wStart.plusDays(6);
                if (w == 53 && wStart.getYear() > selectedYear) {
                    break;
                }
                totalWeeksInSelectedYear = w;
                if (w >= minWeekInSelectedYear) {
                    boolean isFirstAvailable = (selectedYear == earliestYear && w == earliestWeek);
                    String label = String.format("Tuần %02d: %s - %s", w, wStart.format(dmyFormatter), wEnd.format(dmyFormatter));
                    if (isFirstAvailable) {
                        label += " (Tuần tiếp theo)";
                    }
                    weekOptions.add(new WeekOptionDTO(w, 0, label, wStart.format(dmyFormatter), wEnd.format(dmyFormatter), isFirstAvailable));
                }
            }
            String weekParam = request.getParameter("week");
            int selectedWeek = (selectedYear == earliestYear) ? earliestWeek : 1;
            if (weekParam != null && !weekParam.isEmpty()) {
                try {
                    int w = Integer.parseInt(weekParam);
                    if (w >= minWeekInSelectedYear && w <= totalWeeksInSelectedYear) {
                        selectedWeek = w;
                    }
                } catch (NumberFormatException ignored) {
                }
            }
            LocalDate startOfSelectedWeek = firstMondayOfSelectedYear.plusWeeks(selectedWeek - 1);
            LocalDate endOfSelectedWeek = startOfSelectedWeek.plusDays(6);
            String[] dayNames = {"Thứ Hai", "Thứ Ba", "Thứ Tư", "Thứ Năm", "Thứ Sáu", "Thứ Bảy", "Chủ Nhật"};
            List<ScheduleDayDTO> weekDays = new ArrayList<>();
            for (int i = 0; i < 7; i++) {
                LocalDate date = startOfSelectedWeek.plusDays(i);
                boolean isToday = date.isEqual(today);
                boolean isPast = date.isBefore(today);
                ScheduleDayDTO dayDto = new ScheduleDayDTO(
                        dayNames[i],
                        date.format(dayFormatter),
                        date.format(fullFormatter),
                        isToday,
                        isPast
                );
                weekDays.add(dayDto);
            }
            List<ScheduleSlotDTO> slots = new ArrayList<>();
            slots.add(new ScheduleSlotDTO("Slot 1", "08:00 - 08:30", "Morning", "08:00", "08:30"));
            slots.add(new ScheduleSlotDTO("Slot 2", "08:30 - 09:00", "Morning", "08:30", "09:00"));
            slots.add(new ScheduleSlotDTO("Slot 3", "09:00 - 09:30", "Morning", "09:00", "09:30"));
            slots.add(new ScheduleSlotDTO("Slot 4", "09:30 - 10:00", "Morning", "09:30", "10:00"));
            slots.add(new ScheduleSlotDTO("Slot 5", "10:00 - 10:30", "Morning", "10:00", "10:30"));
            slots.add(new ScheduleSlotDTO("Slot 6", "10:30 - 11:00", "Morning", "10:30", "11:00"));
            slots.add(new ScheduleSlotDTO("Slot 7", "11:00 - 11:30", "Morning", "11:00", "11:30"));
            slots.add(new ScheduleSlotDTO("Slot 8", "13:30 - 14:00", "Afternoon", "13:30", "14:00"));
            slots.add(new ScheduleSlotDTO("Slot 9", "14:00 - 14:30", "Afternoon", "14:00", "14:30"));
            slots.add(new ScheduleSlotDTO("Slot 10", "14:30 - 15:00", "Afternoon", "14:30", "15:00"));
            slots.add(new ScheduleSlotDTO("Slot 11", "15:00 - 15:30", "Afternoon", "15:00", "15:30"));
            slots.add(new ScheduleSlotDTO("Slot 12", "15:30 - 16:00", "Afternoon", "15:30", "16:00"));
            slots.add(new ScheduleSlotDTO("Slot 13", "16:00 - 16:30", "Afternoon", "16:00", "16:30"));
            slots.add(new ScheduleSlotDTO("Slot 14", "16:30 - 17:00", "Afternoon", "16:30", "17:00"));
            String startDateStr = startOfSelectedWeek.format(fullFormatter);
            String endDateStr = endOfSelectedWeek.format(fullFormatter);
            Set<String> registeredKeys = workScheduleDAO.getRegisteredSlotKeys(actorId, role, startDateStr, endDateStr);
            Map<String, Boolean> registeredMap = new HashMap<>();
            for (String k : registeredKeys) {
                registeredMap.put(k, Boolean.TRUE);
            }
            Set<String> closedKeys = workScheduleDAO.getClosedSlotKeys(actorId, role, startDateStr, endDateStr);
            Map<String, Boolean> closedMap = new HashMap<>();
            for (String k : closedKeys) {
                closedMap.put(k, Boolean.TRUE);
            }
            boolean hasPrevWeek = true;
            int prevWeek = selectedWeek - 1;
            int prevYear = selectedYear;
            if (selectedYear == earliestYear && selectedWeek <= earliestWeek) {
                hasPrevWeek = false;
            } else if (prevWeek < minWeekInSelectedYear) {
                if (selectedYear > earliestYear) {
                    prevYear = selectedYear - 1;
                    prevWeek = totalWeeksInCurrentYear;
                } else {
                    hasPrevWeek = false;
                }
            }
            boolean hasNextWeek = true;
            int nextWeek = selectedWeek + 1;
            int nextYear = selectedYear;
            if (nextWeek > totalWeeksInSelectedYear) {
                if (selectedYear < maxYear) {
                    nextYear = selectedYear + 1;
                    nextWeek = 1;
                } else {
                    hasNextWeek = false;
                }
            }
            User actorProfile = workScheduleDAO.getActorProfile(actorId, role);
            if (actorProfile == null) {
                actorProfile = currentUser;
            }
            request.setAttribute("actorProfile", actorProfile);
            request.setAttribute("selectedYear", selectedYear);
            request.setAttribute("availableYears", availableYears);
            request.setAttribute("selectedWeek", selectedWeek);
            request.setAttribute("weekOptions", weekOptions);
            request.setAttribute("hasPrevWeek", hasPrevWeek);
            request.setAttribute("prevWeek", prevWeek);
            request.setAttribute("prevYear", prevYear);
            request.setAttribute("hasNextWeek", hasNextWeek);
            request.setAttribute("nextWeek", nextWeek);
            request.setAttribute("nextYear", nextYear);
            request.setAttribute("today", today.format(fullFormatter));
            request.setAttribute("weekDays", weekDays);
            request.setAttribute("slots", slots);
            Map<String, String> slotStatusMap = new HashMap<>();
            try {
                List<TimeSlotConfig> cfgSlots = timeSlotDAO.getConfiguredSlots();
                for (TimeSlotConfig cfg : cfgSlots) {
                    slotStatusMap.put(cfg.getSlotName(), cfg.getStatus());
                }
            } catch (Exception ignored) {}
            request.setAttribute("registeredKeys", registeredKeys);
            request.setAttribute("registeredMap", registeredMap);
            request.setAttribute("closedMap", closedMap);
            request.setAttribute("slotStatusMap", slotStatusMap);
            request.setAttribute("registeredCount", registeredKeys.size());
            request.setAttribute("registeredHours", registeredKeys.size() * 0.5);
            request.getRequestDispatcher("/views/employee/register-schedule.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.setContentType("text/html;charset=UTF-8");
            response.getWriter().println("<h3>Lỗi khi tải trang đăng ký lịch: " + e.getMessage() + "</h3>");
        }
    }
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            HttpSession session = request.getSession();
            User currentUser = (User) session.getAttribute("user");
            if (currentUser == null) {
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }
            int actorId = currentUser.getActorId() > 0 ? currentUser.getActorId() : 1;
            String role = currentUser.getRole() != null ? currentUser.getRole() : "doctor";
            String yearParam = request.getParameter("year");
            String weekParam = request.getParameter("week");
            String[] selectedSlots = request.getParameterValues("selectedSlots");
            if (selectedSlots == null || selectedSlots.length == 0) {
                session.setAttribute("errorMessage", "Vui lòng chọn ít nhất một ca làm việc để đăng ký!");
                response.sendRedirect(request.getContextPath() + "/employee/register-schedule?year=" + yearParam + "&week=" + weekParam);
                return;
            }
            List<ScheduleRegistrationDTO> registrationList = new ArrayList<>();
            LocalDate today = LocalDate.now();
            for (String raw : selectedSlots) {
                String[] parts = raw.split("\\|");
                if (parts.length >= 5) {
                    String workDate = parts[0];
                    String slot = parts[1];
                    String startTime = parts[2];
                    String endTime = parts[3];
                    String sessionType = parts[4];
                    LocalDate date = LocalDate.parse(workDate);
                    if (!date.isBefore(today)) {
                        registrationList.add(new ScheduleRegistrationDTO(workDate, slot, startTime, endTime, sessionType));
                    }
                }
            }
            if (registrationList.isEmpty()) {
                session.setAttribute("errorMessage", "Không có ca làm việc hợp lệ trong tương lai để đăng ký!");
                response.sendRedirect(request.getContextPath() + "/employee/register-schedule?year=" + yearParam + "&week=" + weekParam);
                return;
            }

            int year = Integer.parseInt(yearParam);
            int week = Integer.parseInt(weekParam);
            LocalDate firstDayOfYear = LocalDate.of(year, 1, 1);
            LocalDate firstMonday = firstDayOfYear.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
            if (firstMonday.getYear() < year && firstDayOfYear.get(java.time.temporal.IsoFields.WEEK_OF_WEEK_BASED_YEAR) > 50) {
                firstMonday = firstMonday.plusWeeks(1);
            }
            LocalDate startOfWeek = firstMonday.plusWeeks(week - 1);
            LocalDate endOfWeek = startOfWeek.plusDays(6);
            DateTimeFormatter dbFmt = DateTimeFormatter.ofPattern("yyyy-MM-dd");
            Set<String> existingKeys = workScheduleDAO.getRegisteredSlotKeys(actorId, role, startOfWeek.format(dbFmt), endOfWeek.format(dbFmt));

            Set<String> allKeysThisWeek = new HashSet<>(existingKeys);
            for (ScheduleRegistrationDTO item : registrationList) {
                allKeysThisWeek.add(item.getWorkDate() + "_" + item.getSlot());
            }
            double totalWeeklyHours = allKeysThisWeek.size() * 0.5;

            if (totalWeeklyHours < 30.0) {
                session.setAttribute("errorMessage", "Quy định: Bạn cần đăng ký tối thiểu 30.0 giờ / tuần (hiện tại mới có: " + String.format("%.1f", totalWeeklyHours) + "h). Vui lòng chọn thêm!");
                response.sendRedirect(request.getContextPath() + "/employee/register-schedule?year=" + yearParam + "&week=" + weekParam);
                return;
            }

            boolean success = workScheduleDAO.registerScheduleBatch(actorId, role, registrationList);
            if (success) {
                session.setAttribute("successMessage", "Đăng ký thành công " + registrationList.size() + " ca làm việc mới!");
                response.sendRedirect(request.getContextPath() + "/employee/schedule?year=" + yearParam + "&week=" + weekParam);
            } else {
                session.setAttribute("errorMessage", "Có lỗi xảy ra trong quá trình lưu lịch làm việc. Vui lòng thử lại!");
                response.sendRedirect(request.getContextPath() + "/employee/register-schedule?year=" + yearParam + "&week=" + weekParam);
            }
        } catch (Exception e) {
            e.printStackTrace();
            HttpSession session = request.getSession();
            session.setAttribute("errorMessage", "Lỗi hệ thống: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/employee/register-schedule");
        }
    }
}
