package com.visioncare.controller;

import com.visioncare.dao.AppointmentDAO;
import com.visioncare.dao.DoctorQueueDAO;
import com.visioncare.model.Appointment;
import com.visioncare.model.User;
import com.visioncare.util.ExaminationWindow;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Date;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;
import java.util.HashMap;
import java.util.UUID;
import java.util.stream.Collectors;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

@WebServlet(name = "DoctorWaitingListServlet", urlPatterns = {"/doctor/waiting-list"})
public class DoctorWaitingListServlet extends HttpServlet {
    private static final ZoneId CLINIC_ZONE = ZoneId.of("Asia/Ho_Chi_Minh");
    private static final DateTimeFormatter DISPLAY_DATE = DateTimeFormatter.ofPattern("dd/MM/yyyy");
    private final AppointmentDAO appointmentDAO = new AppointmentDAO();
    private final DoctorQueueDAO doctorQueueDAO = new DoctorQueueDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User doctor = currentDoctor(request, response);
        if (doctor == null) return;

        LocalDate today = LocalDate.now(CLINIC_ZONE);
        LocalDate day;
        try {
            String rawDate = request.getParameter("date");
            day = rawDate == null || rawDate.isBlank() ? today : LocalDate.parse(rawDate);
        } catch (RuntimeException invalidDate) {
            day = today;
        }

        String status = request.getParameter("status");
        if (!"Confirmed".equals(status) && !"In_Progress".equals(status)
                && !"Completed".equals(status) && !"Canceled".equals(status)) {
            status = "all_day";
        }
        final String selectedStatus = status;
        String keyword = request.getParameter("keyword");
        keyword = keyword == null ? "" : keyword.trim();
        if (keyword.length() > 100) keyword = keyword.substring(0, 100);

        try {
            Date sqlDate = Date.valueOf(day);
            int doctorId = doctor.getActorId();
            // One result set keeps tab counts and visible rows in sync with the search.
            List<Appointment> matchingDay = appointmentDAO.getWaitingList(sqlDate, "doctor_day", doctorId, null, keyword);
            List<Appointment> appointments = "all_day".equals(selectedStatus) ? matchingDay
                    : matchingDay.stream().filter(a -> selectedStatus.equals(a.getStatus())).collect(Collectors.toList());

            LocalDateTime clinicNow = LocalDateTime.now(CLINIC_ZONE);
            Map<Integer, String> startWindowStates = new HashMap<>();
            long overdueCount = 0;
            for (Appointment appointment : matchingDay) {
                String windowState = ExaminationWindow.state(appointment, clinicNow);
                startWindowStates.put(appointment.getId(), windowState);
                if ("late".equals(windowState) && ("Confirmed".equals(appointment.getStatus())
                        || "In_Progress".equals(appointment.getStatus()))) {
                    overdueCount++;
                }
            }

            long waitingCount = matchingDay.stream().filter(a -> "Confirmed".equals(a.getStatus())).count();
            long examiningCount = matchingDay.stream().filter(a -> "In_Progress".equals(a.getStatus())).count();
            long completedCount = matchingDay.stream().filter(a -> "Completed".equals(a.getStatus())).count();
            long canceledCount = matchingDay.stream().filter(a -> "Canceled".equals(a.getStatus())).count();
            boolean doctorBusy = examiningCount > 0;
            if (!doctorBusy && !keyword.isEmpty()) {
                doctorBusy = !appointmentDAO.getWaitingList(sqlDate, "In_Progress", doctorId, null, null).isEmpty();
            }
            HttpSession session = request.getSession();
            String csrfToken = (String) session.getAttribute("doctorQueueCsrf");
            if (csrfToken == null) {
                csrfToken = UUID.randomUUID().toString();
                session.setAttribute("doctorQueueCsrf", csrfToken);
            }

            request.setAttribute("appointments", appointments);
            request.setAttribute("startWindowStates", startWindowStates);
            request.setAttribute("overdueCount", overdueCount);
            request.setAttribute("waitingCount", waitingCount);
            request.setAttribute("examiningCount", examiningCount);
            request.setAttribute("completedCount", completedCount);
            request.setAttribute("canceledCount", canceledCount);
            request.setAttribute("totalCount", matchingDay.size());
            request.setAttribute("doctorBusy", doctorBusy);
            request.setAttribute("selectedDate", day.toString());
            request.setAttribute("displayDate", day.format(DISPLAY_DATE));
            request.setAttribute("previousDate", day.minusDays(1).toString());
            request.setAttribute("nextDate", day.plusDays(1).toString());
            request.setAttribute("todayDate", today.toString());
            request.setAttribute("isToday", today.equals(day));
            request.setAttribute("selectedStatus", status);
            request.setAttribute("keyword", keyword);
            request.setAttribute("csrfToken", csrfToken);
            request.getRequestDispatcher("/views/doctor/doctor-waiting-list.jsp").forward(request, response);
        } catch (Exception error) {
            log("Cannot load doctor waiting list", error);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User doctor = currentDoctor(request, response);
        if (doctor == null) return;
        HttpSession session = request.getSession(false);
        String expected = session == null ? null : (String) session.getAttribute("doctorQueueCsrf");
        if (expected == null || !expected.equals(request.getParameter("csrfToken"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        String action = request.getParameter("action");
        if (!"start".equals(action) && !"complete".equals(action) && !"cancel".equals(action)) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        int appointmentId;
        try {
            appointmentId = Integer.parseInt(request.getParameter("appointmentId"));
            if (appointmentId <= 0) throw new NumberFormatException();
        } catch (NumberFormatException invalidId) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        try {
            Date clinicDate = Date.valueOf(LocalDate.now(CLINIC_ZONE));
            boolean updated;
            if ("start".equals(action)) {
                updated = doctorQueueDAO.startExamination(appointmentId, doctor.getActorId(), LocalDateTime.now(CLINIC_ZONE));
            } else if ("cancel".equals(action)) {
                updated = doctorQueueDAO.cancelOverdueExamination(appointmentId, doctor.getActorId(), LocalDateTime.now(CLINIC_ZONE));
            } else {
                updated = doctorQueueDAO.completeExamination(appointmentId, doctor.getActorId(), clinicDate);
            }
            if (updated && "start".equals(action)) {
                response.sendRedirect(request.getContextPath() + "/doctor/patient-detail?id=" + appointmentId);
            } else if (updated && "cancel".equals(action)) {
                session.setAttribute("doctorQueueMessage", "Đã hủy ca khám quá giờ #APPT-" + appointmentId + ".");
                response.sendRedirect(returnToQueue(request));
            } else if (updated) {
                session.setAttribute("doctorQueueMessage", "Đã hoàn tất ca khám #APPT-" + appointmentId + ".");
                response.sendRedirect(request.getContextPath() + "/doctor/waiting-list?date="
                        + clinicDate + "&status=Completed");
            } else {
                String message = "Không thể cập nhật ca khám này. Hãy làm mới danh sách và kiểm tra trạng thái hiện tại.";
                if ("start".equals(action)) {
                    Appointment appointment = appointmentDAO.getAppointmentById(appointmentId);
                    if (appointment != null && appointment.getDoctorId() == doctor.getActorId()) {
                        String state = ExaminationWindow.state(appointment, LocalDateTime.now(CLINIC_ZONE));
                        if ("early".equals(state)) message = "Chưa đến giờ khám. Chỉ có thể bắt đầu trong vòng 1 giờ trước giờ hẹn.";
                        if ("late".equals(state)) message = "Đã quá giờ khám. Chỉ có thể bắt đầu trong vòng 1 giờ sau giờ hẹn.";
                    }
                } else if ("cancel".equals(action)) {
                    message = "Chỉ có thể hủy ca đã check-in, quá 1 giờ sau giờ hẹn, chưa hoàn tất và thuộc lịch của bạn.";
                }
                session.setAttribute("doctorQueueMessage", message);
                response.sendRedirect(returnToQueue(request));
            }
        } catch (Exception error) {
            log("Cannot update doctor examination", error);
            session.setAttribute("doctorQueueMessage", "Chưa thể cập nhật ca khám. Vui lòng thử lại.");
            response.sendRedirect(returnToQueue(request));
        }
    }

    private String returnToQueue(HttpServletRequest request) {
        String date = request.getParameter("date");
        try {
            date = LocalDate.parse(date).toString();
        } catch (RuntimeException invalidDate) {
            date = LocalDate.now(CLINIC_ZONE).toString();
        }
        String status = request.getParameter("status");
        if (!"Confirmed".equals(status) && !"In_Progress".equals(status)
                && !"Completed".equals(status) && !"Canceled".equals(status)) status = "all_day";
        String keyword = request.getParameter("keyword");
        if (keyword == null) keyword = "";
        if (keyword.length() > 100) keyword = keyword.substring(0, 100);
        return request.getContextPath() + "/doctor/waiting-list?date=" + date
                + "&status=" + status + "&keyword=" + URLEncoder.encode(keyword, StandardCharsets.UTF_8);
    }

    private User currentDoctor(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return null;
        }
        if (user.getRoleId() != 3 || user.getActorId() <= 0) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return null;
        }
        return user;
    }
}
