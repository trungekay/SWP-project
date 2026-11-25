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

/**
 * =========================================================================================
 * CONTROLLER: DirectorScheduleServlet
 * CHỨC NĂNG: Trung tâm điều phối và quản lý toàn bộ lịch làm việc của Giám đốc
 * (Director)
 * 
 * ĐÃ PHÂN TÁCH RÕ RÀNG 2 PHẦN THEO TỪNG NÚT BẤM TRÊN GIAO DIỆN:
 * 👉 PHẦN 1: handlePersonnelListView() - Xử lý MÀN HÌNH DANH SÁCH THẺ (viewMode
 * = "list")
 * Kích hoạt khi Giám đốc bấm menu /director/doctors, /specialists, /staffs
 * hoặc bấm nút "<- Danh sách".
 * 
 * 👉 PHẦN 2: handleScheduleMatrixView() - Xử lý MÀN HÌNH MA TRẬN LỊCH CHI TIẾT
 * (viewMode = "schedule")
 * Kích hoạt khi Giám đốc bấm nút "Xem lịch chi tiết ->" trên thẻ của 1 nhân sự.
 * =========================================================================================
 */
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

    private final DateTimeFormatter dmyFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
    private final DateTimeFormatter dayFormatter = DateTimeFormatter.ofPattern("dd/MM");
    private final DateTimeFormatter fullFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // =====================================================================================
        // BƯỚC 1: XÁC THỰC PHIÊN ĐĂNG NHẬP & PHÂN QUYỀN (SECURITY CHECK)
        // =====================================================================================
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Chỉ Giám đốc (Role_ID = 2) mới được truy cập
        if (currentUser.getRoleId() != 2 && !"director".equalsIgnoreCase(currentUser.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập trang điều hành này.");
            return;
        }

        try {
            // Đảm bảo cấu trúc bảng trong DB hợp lệ
            workScheduleDAO.ensureRealisticSchedules();

            // =================================================================================
            // BƯỚC 2: PHÂN LOẠI NHÓM NHÂN SỰ DỰA TRÊN URL (Bác sĩ / KTV / Nhân viên)
            // =================================================================================
            String uri = request.getRequestURI();
            String typeParam = request.getParameter("type");
            String employeeType = "doctor"; // Mặc định là doctor

            if (uri.endsWith("/doctors") || "doctor".equalsIgnoreCase(typeParam)) {
                employeeType = "doctor";
            } else if (uri.endsWith("/specialists") || "specialist".equalsIgnoreCase(typeParam)
                    || "medical_specialist".equalsIgnoreCase(typeParam)) {
                employeeType = "specialist";
            } else if (uri.endsWith("/staffs") || "staff".equalsIgnoreCase(typeParam)) {
                employeeType = "staff";
            }

          
            List<User> allDoctors = workScheduleDAO.getEmployeesByRoleType("doctor");
            List<User> allSpecialists = workScheduleDAO.getEmployeesByRoleType("specialist");
            List<User> allStaffs = workScheduleDAO.getEmployeesByRoleType("staff");

            List<User> employeeList = "specialist".equalsIgnoreCase(employeeType) ? allSpecialists
                    : ("staff".equalsIgnoreCase(employeeType) ? allStaffs : allDoctors);

           
            request.setAttribute("employeeType", employeeType);
            request.setAttribute("employeeList", employeeList);
            request.setAttribute("doctorCount", (allDoctors != null) ? allDoctors.size() : 0);
            request.setAttribute("specialistCount", (allSpecialists != null) ? allSpecialists.size() : 0);
            request.setAttribute("staffCount", (allStaffs != null) ? allStaffs.size() : 0);

            // Lấy số lượng đơn xin nghỉ phép và hoàn tiền đang chờ duyệt (hiển thị badge đỏ
            // trên menu)
            Map<String, Integer> leaveStats = leaveCancelRequestDAO.getStats();
            Map<String, Object> refundStats = refundDAO.getRefundStats();
            request.setAttribute("pendingLeaveCount", leaveStats.get("pending"));
            request.setAttribute("pendingRefundCount", refundStats.get("pending"));

            // =================================================================================
            // BƯỚC 3: ĐIỀU HƯỚNG 2 HÀM RIÊNG BIỆT DỰA VÀO NÚT BẤM (viewMode)
            // =================================================================================
            String viewParam = request.getParameter("view");
            String empIdParam = request.getParameter("empId");

            // Nếu URL có view=schedule HOẶC có empId cụ thể (và không yêu cầu view=list) ->
            boolean isScheduleView = "schedule".equalsIgnoreCase(viewParam)
                    || (empIdParam != null && !empIdParam.trim().isEmpty() && !"list".equalsIgnoreCase(viewParam));

            if (isScheduleView) {
                handleScheduleMatrixView(request, response, employeeType);
            } else {
                handlePersonnelListView(request, response, employeeType, employeeList);
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.setContentType("text/html;charset=UTF-8");
            response.getWriter().println("<h3>Lỗi khi tải lịch làm việc của nhân sự: " + e.getMessage() + "</h3>");
        }
    }

    // =========================================================================================
    //  HÀM 1: XỬ LÝ MÀN HÌNH DANH SÁCH THẺ NHÂN SỰ (viewMode = "list")
    // =========================================================================================
    private void handlePersonnelListView(HttpServletRequest request, HttpServletResponse response,
                                         String employeeType, List<User> employeeList)
            throws Exception {

        // Luôn luôn lấy mốc Thứ 2 đến Chủ Nhật của TUẦN HIỆN TẠI 
        LocalDate today = LocalDate.now();
        LocalDate startOfWeek = today.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
        LocalDate endOfWeek = startOfWeek.plusDays(6);

        String startDateStr = startOfWeek.format(fullFormatter); 
        String endDateStr = endOfWeek.format(fullFormatter);    

        Map<Integer, int[]> employeeSlotStats = workScheduleDAO.getWeeklyEmployeeSlotStats(employeeType, startDateStr, endDateStr);

        request.setAttribute("viewMode", "list");
        request.setAttribute("employeeSlotStats", employeeSlotStats);

        request.getRequestDispatcher("/views/director/schedule-view.jsp").forward(request, response);
    }

    // =========================================================================================
    //  HÀM 2: XỬ LÝ MÀN HÌNH MA TRẬN LỊCH CHI TIẾT (viewMode = "schedule")
    // =========================================================================================
    private void handleScheduleMatrixView(HttpServletRequest request, HttpServletResponse response,
            String employeeType)
            throws Exception {

        // 1. Lấy mã nhân sự (empId) được chọn
        String empIdParam = request.getParameter("empId");
        int selectedEmpId = -1;
        if (empIdParam != null && !empIdParam.trim().isEmpty()) {
            try {
                selectedEmpId = Integer.parseInt(empIdParam.trim());
            } catch (NumberFormatException ignored) {
            }
        }

        // Lấy hồ sơ chi tiết của nhân sự được chọn
        User selectedEmployee = null;
        if (selectedEmpId > 0) {
            selectedEmployee = workScheduleDAO.getActorProfile(selectedEmpId, employeeType);
        }

        // Nếu empId không hợp lệ hoặc không tìm thấy nhân sự, chuyển hướng về màn hình danh sách
        if (selectedEmployee == null) {
            response.sendRedirect(request.getContextPath() + "/director/"
                    + ("specialist".equalsIgnoreCase(employeeType) ? "specialists"
                            : ("staff".equalsIgnoreCase(employeeType) ? "staffs" : "doctors")));
            return;
        }

        // 2. Thuật toán xử lý năm và tuần
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
        if (selectedYear > maxYear)
            selectedYear = maxYear;

        List<Integer> availableYears = new ArrayList<>();
        for (int y = currentYear - 2; y <= maxYear; y++) {
            availableYears.add(y);
        }

        LocalDate firstMondayOfYear = LocalDate.of(selectedYear, 1, 4)
                .with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));

        // 3. Tạo danh sách 52 - 53 tuần cho dropdown chọn tuần
        List<WeekOptionDTO> weekOptions = new ArrayList<>();
        int currentWeekOfThisYear = 1;
        for (int w = 1; w <= 53; w++) {
            LocalDate wStart = firstMondayOfYear.plusWeeks(w - 1);
            LocalDate wEnd = wStart.plusDays(6);
            if (w == 53 && wStart.getYear() > selectedYear)
                break;

            boolean isCurrentWeek = (selectedYear == currentYear)
                    && (today.isEqual(wStart) || (today.isAfter(wStart) && today.isBefore(wEnd.plusDays(1))));
            if (isCurrentWeek) {
                currentWeekOfThisYear = w;
            }
            String label = String.format("Tuần %02d: %s - %s", w, wStart.format(dmyFormatter),
                    wEnd.format(dmyFormatter));
            if (isCurrentWeek) {
                label += " (Hiện tại)";
            }
            weekOptions.add(new WeekOptionDTO(w, 0, label, wStart.format(dmyFormatter), wEnd.format(dmyFormatter),
                    isCurrentWeek));
        }

        // Lấy tuần được chọn từ URL (mặc định tuần hiện tại)
        String weekParam = request.getParameter("week");
        int selectedWeek = (selectedYear == currentYear) ? currentWeekOfThisYear : 1;
        if (weekParam != null && !weekParam.isEmpty()) {
            try {
                int w = Integer.parseInt(weekParam);
                if (w >= 1 && w <= weekOptions.size())
                    selectedWeek = w;
            } catch (NumberFormatException ignored) {
            }
        }

        // Tính ngày Thứ Hai và Chủ Nhật của tuần đang chọn
        LocalDate startOfSelectedWeek = firstMondayOfYear.plusWeeks(selectedWeek - 1);
        LocalDate endOfSelectedWeek = startOfSelectedWeek.plusDays(6);

        // Xây dựng 7 ngày trong tuần (Thứ Hai -> Chủ Nhật)
        String[] dayNames = { "Thứ Hai", "Thứ Ba", "Thứ Tư", "Thứ Năm", "Thứ Sáu", "Thứ Bảy", "Chủ Nhật" };
        List<ScheduleDayDTO> weekDays = new ArrayList<>();
        for (int i = 0; i < 7; i++) {
            LocalDate date = startOfSelectedWeek.plusDays(i);
            weekDays.add(new ScheduleDayDTO(dayNames[i], date.format(dayFormatter), date.format(fullFormatter),
                    date.isEqual(today)));
        }

        // 4. Lấy danh sách ca khám cấu hình trong DB 
        List<ScheduleSlotDTO> slots = new ArrayList<>();
        for (TimeSlotConfig cfg : timeSlotDAO.getConfiguredSlots()) {
            String startStr = cfg.getStartTime();
            if (startStr != null && startStr.length() >= 5)
                startStr = startStr.substring(0, 5);
            String endStr = cfg.getEndTime();
            if (endStr != null && endStr.length() >= 5)
                endStr = endStr.substring(0, 5);
            slots.add(new ScheduleSlotDTO(cfg.getSlotName(), startStr + " - " + endStr, cfg.getSession()));
        }

        String startDateStr = startOfSelectedWeek.format(fullFormatter);
        String endDateStr = endOfSelectedWeek.format(fullFormatter);

        // 5. GỌI DAO: Lấy dữ liệu ma trận ca trực của nhân sự được chọn trong tuần
        Map<String, ScheduleCellDTO> scheduleMatrix = new HashMap<>();
        if (selectedEmpId > 0) {
            scheduleMatrix = workScheduleDAO.getScheduleMatrix(selectedEmpId, employeeType, startDateStr, endDateStr);
        }

        // 6. Lấy các chỉ số thống kê từ DAO 
        Map<Integer, int[]> slotStats = workScheduleDAO.getWeeklyEmployeeSlotStats(employeeType, startDateStr, endDateStr);
        int[] stats = (slotStats != null) ? slotStats.get(selectedEmpId) : null;
        int totalWeeklySlots = (stats != null) ? stats[0] : 0;
        int totalBookedSlots = (stats != null) ? stats[1] : 0;
        double totalWeeklyHours = totalWeeklySlots * 0.5;

        // 7. Tính tuần trước (prevWeek) và tuần sau (nextWeek)
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

        // 8. Nạp toàn bộ dữ liệu vào Request cho màn hình Ma trận lịch
        request.setAttribute("viewMode", "schedule");
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
        request.setAttribute("isViewingCurrentWeek",
                (selectedYear == currentYear && selectedWeek == currentWeekOfThisYear));
        request.setAttribute("currentYear", currentYear);
        request.setAttribute("weekDays", weekDays);
        request.setAttribute("slots", slots);
        request.setAttribute("scheduleMatrix", scheduleMatrix);
        request.setAttribute("totalWeeklySlots", totalWeeklySlots);
        request.setAttribute("totalBookedSlots", totalBookedSlots);
        request.setAttribute("totalWeeklyHours", totalWeeklyHours);


        request.getRequestDispatcher("/views/director/schedule-view.jsp").forward(request, response);
    }
}
