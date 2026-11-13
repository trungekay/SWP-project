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
 * CHỨC NĂNG: Trung tâm điều phối và quản lý toàn bộ lịch làm việc của Giám đốc (Director)
 * =========================================================================================
 * 
 * PHẦN 1: Khai báo 4 URL Patterns và khởi tạo các DAO phụ trách
 * PHẦN 2: Kiểm tra xác thực phiên đăng nhập và phân quyền bảo mật (Role Director / Admin)
 * PHẦN 3: Phân loại nhóm nhân sự (Bác sĩ / KTV / Nhân viên) và chế độ xem (List / Schedule)
 * PHẦN 4: Thuật toán tính toán tuần, ngày trong năm và chọn tuần làm việc
 * PHẦN 5: Lấy cấu hình khung giờ khám và dựng ma trận lịch trực 2 chiều (Schedule Matrix)
 * PHẦN 6: Xử lý logic chuyển tuần (Tuần trước / Tuần sau) và tải badge thống kê
 * PHẦN 7: Nạp toàn bộ dữ liệu vào Request và chuyển tiếp sang trang JSP (schedule-view.jsp)
 * =========================================================================================
 */
// =========================================================================================
// PHẦN 1: KHAI BÁO CÁC URL MAPPING & KHỞI TẠO DAO
// Gom 4 đường dẫn điều hành về 1 Servlet duy nhất:
// - /director/schedules  : Trang tổng quan lịch trực chung
// - /director/doctors    : Lịch làm việc của Bác sĩ
// - /director/specialists: Lịch làm việc của Chuyên viên y tế / Kỹ thuật viên
// - /director/staffs     : Lịch làm việc của Nhân viên tiếp đón / Hành chính
// =========================================================================================
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
        
        // =====================================================================================
        // PHẦN 2: XÁC THỰC PHIÊN ĐĂNG NHẬP & PHÂN QUYỀN TRUY CẬP (SECURITY CHECK)
        // =====================================================================================
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");

        // 1. Nếu chưa đăng nhập -> Chuyển hướng người dùng về trang đăng nhập
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // 2. Chặn quyền: Chỉ Giám đốc (Role_ID = 2)  mới được truy cập
        if (currentUser.getRoleId() != 2  && !"director".equalsIgnoreCase(currentUser.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập trang điều hành này.");
            return;
        }

        try {
            // =================================================================================
            // PHẦN 3: PHÂN LOẠI NHÓM NHÂN SỰ & CHẾ ĐỘ XEM (LIST VIEW vs SCHEDULE VIEW)
            // =================================================================================
            String uri = request.getRequestURI();
            String typeParam = request.getParameter("type");
            String employeeType = "doctor"; // Mặc định là nhóm Bác sĩ

            // 1. Phân loại đối tượng nhân sự dựa trên URL hoặc tham số "?type="
            if (uri.endsWith("/doctors") || "doctor".equalsIgnoreCase(typeParam)) {
                employeeType = "doctor";
            } else if (uri.endsWith("/specialists") || "specialist".equalsIgnoreCase(typeParam) || "medical_specialist".equalsIgnoreCase(typeParam)) {
                employeeType = "specialist";
            } else if (uri.endsWith("/staffs") || "staff".equalsIgnoreCase(typeParam)) {
                employeeType = "staff";
            }

            // 2. Đảm bảo dữ liệu lịch trình hợp lệ trong DB
            workScheduleDAO.ensureRealisticSchedules();

            // 3. Đếm số lượng nhân sự của từng nhóm để hiển thị badge số lượng trên các tab đầu trang
            List<User> allDoctors = workScheduleDAO.getEmployeesByRoleType("doctor");
            List<User> allSpecialists = workScheduleDAO.getEmployeesByRoleType("specialist");
            List<User> allStaffs = workScheduleDAO.getEmployeesByRoleType("staff");

            int doctorCount = (allDoctors != null) ? allDoctors.size() : 0;
            int specialistCount = (allSpecialists != null) ? allSpecialists.size() : 0;
            int staffCount = (allStaffs != null) ? allStaffs.size() : 0;

            // 4. Lấy danh sách nhân sự thuộc nhóm đang được chọn
            List<User> employeeList = "specialist".equalsIgnoreCase(employeeType) ? allSpecialists
                    : ("staff".equalsIgnoreCase(employeeType) ? allStaffs : allDoctors);

            // 5. Xác định chế độ xem: "list" (Danh sách nhân sự) vs "schedule" (Lịch chi tiết theo tuần)
            String viewMode = request.getParameter("view");
            String empIdParam = request.getParameter("empId");

            int selectedEmpId = -1;
            if (empIdParam != null && !empIdParam.trim().isEmpty()) {
                try {
                    selectedEmpId = Integer.parseInt(empIdParam.trim());
                } catch (NumberFormatException ignored) {}
            }

            // Nếu có truyền empId thì mặc định mở xem "schedule", ngược lại mở "list"
            if (viewMode == null || viewMode.isEmpty()) {
                if (empIdParam != null && !empIdParam.trim().isEmpty()) {
                    viewMode = "schedule";
                } else {
                    viewMode = "list";
                }
            }

            // 6. Đảm bảo nhân sự được chọn thuộc danh sách nhân sự hiện tại (tránh ID rác)
            boolean idFoundInList = false;
            if (selectedEmpId > 0 && employeeList != null) {
                for (User u : employeeList) {
                    if (u.getActorId() == selectedEmpId) {
                        idFoundInList = true;
                        break;
                    }
                }
            }
            if (!idFoundInList && employeeList != null && !employeeList.isEmpty()) {
                selectedEmpId = employeeList.get(0).getActorId();
            }

            // 7. Lấy thông tin hồ sơ chi tiết của nhân sự được chọn (tên, avatar, chức danh, chuyên khoa)
            User selectedEmployee = null;
            if (selectedEmpId > 0) {
                selectedEmployee = workScheduleDAO.getActorProfile(selectedEmpId, employeeType);
            }

            // =================================================================================
            // PHẦN 4: THUẬT TOÁN TÍNH TOÁN TUẦN VÀ 7 NGÀY TRONG TUẦN (DATE & WEEK ENGINE)
            // =================================================================================
            LocalDate today = LocalDate.now();
            int currentYear = today.getYear();
            int maxYear = currentYear + 1; // Cho phép xem trước tối đa 1 năm
            String yearParam = request.getParameter("year");
            int selectedYear = currentYear;
            if (yearParam != null && !yearParam.isEmpty()) {
                try {
                    selectedYear = Integer.parseInt(yearParam);
                } catch (NumberFormatException ignored) {}
            }
            if (selectedYear > maxYear) selectedYear = maxYear;

            // Danh sách các năm cho phép chọn trên bộ lọc (từ 2 năm trước đến 1 năm sau)
            List<Integer> availableYears = new ArrayList<>();
            for (int y = currentYear - 2; y <= maxYear; y++) {
                availableYears.add(y);
            }

            // Tìm ngày Thứ Hai đầu tiên của năm được chọn (chuẩn ISO lịch tuần)
            LocalDate firstMondayOfYear = LocalDate.of(selectedYear, 1, 4).with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
            DateTimeFormatter dmyFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
            DateTimeFormatter dayFormatter = DateTimeFormatter.ofPattern("dd/MM");
            DateTimeFormatter fullFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");

            // Tạo danh sách 52 - 53 tuần cho dropdown chọn tuần
            List<WeekOptionDTO> weekOptions = new ArrayList<>();
            int currentWeekOfThisYear = 1;
            for (int w = 1; w <= 53; w++) {
                LocalDate wStart = firstMondayOfYear.plusWeeks(w - 1);
                LocalDate wEnd = wStart.plusDays(6);
                if (w == 53 && wStart.getYear() > selectedYear) break;

                // Kiểm tra xem tuần này có phải tuần hiện tại của hôm nay không
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

            // Lấy tuần được chọn từ URL (mặc định lấy tuần hiện tại)
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

            // Tính ngày bắt đầu và kết thúc của tuần đang chọn
            LocalDate startOfSelectedWeek = firstMondayOfYear.plusWeeks(selectedWeek - 1);
            LocalDate endOfSelectedWeek = startOfSelectedWeek.plusDays(6);
            
            // Xây dựng danh sách 7 ngày trong tuần (Thứ Hai -> Chủ Nhật)
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

            // =================================================================================
            // PHẦN 5: LẤY CẤU HÌNH KHUNG GIỜ VÀ DỰNG MA TRẬN LỊCH TRỰC (SCHEDULE MATRIX)
            // =================================================================================
            // 1. Lấy danh sách các khung giờ khám đã cấu hình trong DB (Ca 1 đến Ca 14, 30 phút/ca)
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
            
            // 2. Lấy dữ liệu ma trận ca trực của nhân sự được chọn trong tuần từ Database
            Map<String, ScheduleCellDTO> scheduleMatrix = new HashMap<>();
            if (selectedEmpId > 0) {
                scheduleMatrix = workScheduleDAO.getScheduleMatrix(selectedEmpId, employeeType, startDateStr, endDateStr);
            }

            // 3. Tính toán các chỉ số thống kê KPI làm việc trong tuần của nhân sự
            int totalWeeklySlots = 0;   // Tổng số ca làm việc
            int totalBookedSlots = 0;   // Số ca đã có bệnh nhân đặt hẹn
            int totalLeaveSlots = 0;    // Số ca xin nghỉ phép
            for (ScheduleDayDTO day : weekDays) {
                int daySlotsCount = 0;
                for (ScheduleSlotDTO slot : slots) {
                    String key = day.getFullDate() + "_" + slot.getId();
                    ScheduleCellDTO cell = scheduleMatrix.get(key);
                    if (cell != null) {
                        if (!cell.isOff() && !cell.isOnLeave() && !cell.isClosed()) {
                            daySlotsCount++;
                            totalWeeklySlots++;
                            if (cell.isBooked()) {
                                totalBookedSlots++;
                            }
                        } else if (cell.isOnLeave()) {
                            totalLeaveSlots++;
                        }
                    }
                }
                day.setTotalSlotsCount(daySlotsCount);
            }
            int totalAvailableSlots = Math.max(0, totalWeeklySlots - totalBookedSlots);
            double totalWeeklyHours = totalWeeklySlots * 0.5;

            // =================================================================================
            // PHẦN 6: XỬ LÝ LOGIC CHUYỂN TUẦN (PREV / NEXT) VÀ TẢI THỐNG KÊ CHỜ DUYỆT
            // =================================================================================
            // 1. Tính toán tuần trước (Prev Week): Nếu đang ở tuần 1 thì lùi về tuần 52 năm trước
            int prevWeek = selectedWeek - 1;
            int prevYear = selectedYear;
            if (prevWeek < 1) {
                prevYear = selectedYear - 1;
                prevWeek = 52;
            }
            
            // 2. Tính toán tuần sau (Next Week): Nếu vượt quá tuần tối đa thì sang tuần 1 năm sau
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

            // 3. Tải thống kê số ca đã xếp/đã đặt của toàn bộ nhân sự để hiển thị trên bảng danh sách (view=list)
            Map<Integer, int[]> employeeSlotStats = workScheduleDAO.getWeeklyEmployeeSlotStats(employeeType, startDateStr, endDateStr);
            request.setAttribute("employeeSlotStats", employeeSlotStats);
            request.setAttribute("viewMode", viewMode);

            // 4. Lấy số lượng đơn xin nghỉ phép và yêu cầu hoàn tiền đang chờ Giám đốc duyệt (hiển thị badge đỏ trên menu)
            Map<String, Integer> leaveStats = leaveCancelRequestDAO.getStats();
            Map<String, Object> refundStats = refundDAO.getRefundStats();
            request.setAttribute("pendingLeaveCount", leaveStats.get("pending"));
            request.setAttribute("pendingRefundCount", refundStats.get("pending"));

            // =================================================================================
            // PHẦN 7: NẠP DỮ LIỆU VÀO REQUEST & CHUYỂN TIẾP HIỂN THỊ (FORWARD TO JSP)
            // =================================================================================
            // Số lượng nhân sự theo từng nhóm
            request.setAttribute("doctorCount", doctorCount);
            request.setAttribute("specialistCount", specialistCount);
            request.setAttribute("staffCount", staffCount);

            // Dữ liệu nhân sự đang chọn
            request.setAttribute("employeeType", employeeType);
            request.setAttribute("employeeList", employeeList);
            request.setAttribute("selectedEmployee", selectedEmployee);
            request.setAttribute("selectedEmpId", selectedEmpId);

            // Dữ liệu điều hướng tuần và năm
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
            
            // Dữ liệu ma trận lịch trực và KPI
            request.setAttribute("slots", slots);
            request.setAttribute("scheduleMatrix", scheduleMatrix);
            request.setAttribute("totalWeeklySlots", totalWeeklySlots);
            request.setAttribute("totalBookedSlots", totalBookedSlots);
            request.setAttribute("totalAvailableSlots", totalAvailableSlots);
            request.setAttribute("totalLeaveSlots", totalLeaveSlots);
            request.setAttribute("totalWeeklyHours", totalWeeklyHours);

            // Bộ lọc buổi (Sáng / Chiều / Tất cả)
            String sessionFilter = request.getParameter("session");
            if (sessionFilter == null || sessionFilter.isEmpty()) sessionFilter = "all";
            request.setAttribute("sessionFilter", sessionFilter);

            // Chuyển tiếp toàn bộ dữ liệu sang giao diện schedule-view.jsp để render HTML
            request.getRequestDispatcher("/views/director/schedule-view.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.setContentType("text/html;charset=UTF-8");
            response.getWriter().println("<h3>Lỗi khi tải lịch làm việc của nhân sự: " + e.getMessage() + "</h3>");
        }
    }
}
