package com.visioncare.controller;

import com.visioncare.dao.AppointmentDAO;
import com.visioncare.dao.DoctorDAO;
import com.visioncare.dao.WorkScheduleDAO;
import com.visioncare.model.Appointment;
import com.visioncare.model.Doctor;
import com.visioncare.model.TimeSlot;
import com.visioncare.model.User;
import com.visioncare.util.EmailUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.time.LocalDate;
import java.util.List;

@WebServlet(name = "PatientRescheduleServlet", urlPatterns = {"/staff/reschedule", "/staff/patient-reschedule", "/patient/reschedule", "/appointment/reschedule"})
public class PatientRescheduleServlet extends HttpServlet {

    private final AppointmentDAO appointmentDAO = new AppointmentDAO();
    private final DoctorDAO doctorDAO = new DoctorDAO();
    private final WorkScheduleDAO workScheduleDAO = new WorkScheduleDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");

        if (currentUser == null) {
            String fullUri = request.getRequestURI();
            String query = request.getQueryString();
            session.setAttribute("redirectAfterLogin", fullUri + (query != null ? "?" + query : ""));
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");

        // AJAX: Lấy danh sách slot khả dụng theo bác sĩ và ngày
        if ("getSlots".equalsIgnoreCase(action)) {
            response.setContentType("application/json;charset=UTF-8");
            try {
                String docIdStr = request.getParameter("doctorId");
                String dateStr = request.getParameter("date");
                if (docIdStr == null || docIdStr.isEmpty() || dateStr == null || dateStr.isEmpty()) {
                    response.getWriter().write("{\"shiftSummary\":\"OFF\",\"slots\":[]}");
                    return;
                }
                int doctorId = Integer.parseInt(docIdStr);
                appointmentDAO.autoCancelExpiredPendingAppointments();
                List<TimeSlot> slots = workScheduleDAO.getDoctorSlotsForDate(doctorId, dateStr);
                String shift = workScheduleDAO.getDoctorWorkShiftSummary(doctorId, dateStr);

                StringBuilder json = new StringBuilder();
                json.append("{\"shiftSummary\":\"").append(shift != null ? shift : "OFF").append("\",\"slots\":[");
                if (slots != null) {
                    for (int i = 0; i < slots.size(); i++) {
                        TimeSlot s = slots.get(i);
                        if (i > 0) json.append(",");
                        boolean isAvail = !s.isBooked() && !s.isPast();
                        json.append("{")
                            .append("\"scheduleId\":").append(s.getId()).append(",")
                            .append("\"slot\":\"").append(s.getSlotName() != null ? s.getSlotName() : "").append("\",")
                            .append("\"startTime\":\"").append(s.getStartTime() != null ? s.getStartTime() : "").append("\",")
                            .append("\"endTime\":\"").append(s.getEndTime() != null ? s.getEndTime() : "").append("\",")
                            .append("\"isAvailable\":").append(isAvail)
                            .append("}");
                    }
                }
                json.append("]}");
                response.getWriter().write(json.toString());
            } catch (Exception e) {
                response.getWriter().write("{\"shiftSummary\":\"ERROR\",\"slots\":[]}");
            }
            return;
        }

        String apptIdParam = request.getParameter("appointmentId");
        if (apptIdParam == null || apptIdParam.trim().isEmpty()) {
            apptIdParam = request.getParameter("id");
        }

        if (apptIdParam == null || apptIdParam.trim().isEmpty()) {
            session.setAttribute("errorMessage", "Không tìm thấy thông tin ca khám cần dời lịch.");
            redirectBack(request, response, currentUser);
            return;
        }

        try {
            int appointmentId = Integer.parseInt(apptIdParam.trim().replace("#APT-", "").replace("APT-", "").replace("#", ""));
            Appointment appt = appointmentDAO.getAppointmentDetailById(appointmentId);

            if (appt == null) {
                session.setAttribute("errorMessage", "Ca khám #" + appointmentId + " không tồn tại.");
                redirectBack(request, response, currentUser);
                return;
            }

            // Kiểm tra quyền: nếu không phải nhân viên/quản lý thì phải đúng tài khoản của mình
            boolean isStaffOrAdmin = currentUser.getRoleId() == 1 || currentUser.getRoleId() == 2 || currentUser.getRoleId() == 5;
            if (!isStaffOrAdmin) {
                if (appt.getUserId() <= 0 || appt.getUserId() != currentUser.getId()) {
                    session.setAttribute("errorMessage", "Bạn không có quyền dời lịch cho ca khám này.");
                    redirectBack(request, response, currentUser);
                    return;
                }
            }

            // Kiểm tra điều kiện: chỉ đổi lịch cho ca đang ở trạng thái Chờ tiếp đón (Confirmed và chưa check-in)
            if (!"Confirmed".equalsIgnoreCase(appt.getStatus()) || (appt.getCheckinTime() != null && !appt.getCheckinTime().trim().isEmpty())) {
                session.setAttribute("errorMessage", "Chỉ những ca khám đang ở trạng thái 'Chờ tiếp đón' mới được phép đổi lịch.");
                redirectBack(request, response, currentUser);
                return;
            }

            List<Doctor> doctors = doctorDAO.getAll();
            request.setAttribute("appointment", appt);
            request.setAttribute("doctors", doctors);
            request.setAttribute("isStaffOrAdmin", isStaffOrAdmin);
            request.setAttribute("minDate", LocalDate.now().toString());
            request.setAttribute("maxDate", LocalDate.now().plusDays(30).toString());

            request.getRequestDispatcher("/views/staff/patient-reschedule-form.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMessage", "Lỗi: " + e.getMessage());
            redirectBack(request, response, currentUser);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String apptIdParam = request.getParameter("appointmentId");
        String newScheduleIdParam = request.getParameter("newScheduleId");
        String reason = request.getParameter("reason");

        if (apptIdParam == null || newScheduleIdParam == null) {
            session.setAttribute("errorMessage", "Thiếu thông tin lịch hẹn hoặc khung giờ mới.");
            redirectBack(request, response, currentUser);
            return;
        }

        try {
            int appointmentId = Integer.parseInt(apptIdParam.trim().replace("#APT-", "").replace("APT-", "").replace("#", ""));
            int newScheduleId = Integer.parseInt(newScheduleIdParam.trim());

            Appointment appt = appointmentDAO.getAppointmentDetailById(appointmentId);
            if (appt == null) {
                session.setAttribute("errorMessage", "Ca khám không tồn tại.");
                redirectBack(request, response, currentUser);
                return;
            }

            boolean isStaffOrAdmin = currentUser.getRoleId() == 1 || currentUser.getRoleId() == 2 || currentUser.getRoleId() == 5;
            if (!isStaffOrAdmin) {
                if (appt.getUserId() <= 0 || appt.getUserId() != currentUser.getId()) {
                    session.setAttribute("errorMessage", "Bạn không có quyền dời ca khám này.");
                    redirectBack(request, response, currentUser);
                    return;
                }
            }

            if (!"Confirmed".equalsIgnoreCase(appt.getStatus()) || (appt.getCheckinTime() != null && !appt.getCheckinTime().trim().isEmpty())) {
                session.setAttribute("errorMessage", "Chỉ những ca khám đang ở trạng thái 'Chờ tiếp đón' mới được phép đổi lịch.");
                redirectBack(request, response, currentUser);
                return;
            }

            String fullReason = (reason != null && !reason.trim().isEmpty()) 
                    ? reason.trim() 
                    : (isStaffOrAdmin ? "Nhân viên hỗ trợ dời lịch theo yêu cầu bệnh nhân" : "Bệnh nhân yêu cầu đổi lịch khám");

            boolean success = appointmentDAO.rescheduleAppointment(appointmentId, newScheduleId, fullReason);
            if (success) {
                session.setAttribute("successMessage", "Đã dời lịch khám #APT-" + appointmentId + " thành công!");

                // Gửi email xác nhận dời lịch nếu bệnh nhân có email
                try {
                    Appointment updatedAppt = appointmentDAO.getAppointmentDetailById(appointmentId);
                    String email = updatedAppt.getEmail();
                    if ((email == null || email.trim().isEmpty()) && currentUser.getEmail() != null) {
                        email = currentUser.getEmail();
                    }
                    if (email != null && !email.trim().isEmpty()) {
                        EmailUtil.sendAppointmentConfirmationEmail(
                                email.trim(),
                                updatedAppt.getPatientName(),
                                updatedAppt.getId(),
                                updatedAppt.getDoctorName() != null ? updatedAppt.getDoctorName() : "Bác sĩ Chuyên khoa VisionCare",
                                updatedAppt.getDepartment() != null ? updatedAppt.getDepartment() : "Khám chuyên khoa mắt",
                                updatedAppt.getAppointmentDate() != null ? updatedAppt.getAppointmentDate().toString() : "",
                                updatedAppt.getTimeSlot() != null ? updatedAppt.getTimeSlot() : "",
                                updatedAppt.getFee() > 0 ? updatedAppt.getFee() : 200000
                        );
                    }
                } catch (Exception ex) {
                    System.err.println("Lỗi gửi email sau khi đổi lịch: " + ex.getMessage());
                }
            } else {
                session.setAttribute("errorMessage", "Không thể dời lịch khám: Khung giờ đã chọn không còn khả dụng hoặc ca khám không đủ điều kiện.");
                response.sendRedirect(request.getContextPath() + "/staff/reschedule?appointmentId=" + appointmentId);
                return;
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMessage", "Lỗi xử lý dời lịch: " + e.getMessage());
        }

        redirectBack(request, response, currentUser);
    }

    private void redirectBack(HttpServletRequest request, HttpServletResponse response, User user) throws IOException {
        if (user != null && (user.getRoleId() == 1 || user.getRoleId() == 2 || user.getRoleId() == 5)) {
            response.sendRedirect(request.getContextPath() + "/staff/appointments");
        } else {
            response.sendRedirect(request.getContextPath() + "/views/profile/appointment-history.jsp");
        }
    }
}
