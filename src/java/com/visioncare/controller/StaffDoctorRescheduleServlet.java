package com.visioncare.controller;

import com.visioncare.dao.AppointmentDAO;
import com.visioncare.dao.DoctorDAO;
import com.visioncare.dao.StaffDoctorRescheduleDAO;
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
import java.io.IOException;
import java.sql.Date;
import java.time.LocalDate;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.HashMap;
import java.util.UUID;

/** Staff view of a doctor's schedule with handoff to the existing appointment reschedule flow. */
@WebServlet(name = "StaffDoctorRescheduleServlet", urlPatterns = {"/staff/doctor-reschedule"})
public class StaffDoctorRescheduleServlet extends HttpServlet {
    private final DoctorDAO doctorDAO = new DoctorDAO();
    private final WorkScheduleDAO workScheduleDAO = new WorkScheduleDAO();
    private final AppointmentDAO appointmentDAO = new AppointmentDAO();
    private final StaffDoctorRescheduleDAO rescheduleDAO = new StaffDoctorRescheduleDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        if (user.getRoleId() != 1 && user.getRoleId() != 2 && user.getRoleId() != 5) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        if ("slots".equals(request.getParameter("action"))) {
            try {
                int doctorId = Integer.parseInt(request.getParameter("doctorId"));
                LocalDate date = LocalDate.parse(request.getParameter("date"));
                LocalDate today = LocalDate.now();
                if (date.isBefore(today) || date.isAfter(today.plusDays(30)) || doctorDAO.getById(doctorId) == null) {
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST);
                    return;
                }
                List<TimeSlot> targetSlots = workScheduleDAO.getDoctorSlotsForDate(doctorId, date.toString());
                StringBuilder json = new StringBuilder("{\"slots\":[");
                for (TimeSlot slot : targetSlots) {
                    if (json.charAt(json.length() - 1) != '[') json.append(',');
                    json.append("{\"scheduleId\":").append(slot.getId())
                            .append(",\"startTime\":\"").append(slot.getStartTime())
                            .append("\",\"endTime\":\"").append(slot.getEndTime())
                            .append("\",\"isAvailable\":").append(!slot.isBooked() && !slot.isPast())
                            .append('}');
                }
                response.setContentType("application/json;charset=UTF-8");
                response.setHeader("Cache-Control", "no-store");
                response.getWriter().write(json.append("]}").toString());
            } catch (Exception e) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            }
            return;
        }

        try {
            List<Doctor> doctors = doctorDAO.getAll();
            LocalDate today = LocalDate.now();
            LocalDate date = today;
            String dateParam = request.getParameter("date");
            if (dateParam != null && !dateParam.isBlank()) {
                try {
                    date = LocalDate.parse(dateParam);
                } catch (Exception ignored) {
                    request.setAttribute("filterError", "Ngày không hợp lệ. Đã hiển thị lịch hôm nay.");
                }
            }

            Doctor selectedDoctor = null;
            String doctorParam = request.getParameter("doctorId");
            if (doctorParam != null && !doctorParam.isBlank()) {
                try {
                    int id = Integer.parseInt(doctorParam);
                    for (Doctor doctor : doctors) {
                        if (doctor.getId() == id) {
                            selectedDoctor = doctor;
                            break;
                        }
                    }
                    if (selectedDoctor == null) request.setAttribute("filterError", "Không tìm thấy bác sĩ đã chọn.");
                } catch (NumberFormatException e) {
                    request.setAttribute("filterError", "Mã bác sĩ không hợp lệ.");
                }
            }
            if (selectedDoctor == null && !doctors.isEmpty() && (doctorParam == null || doctorParam.isBlank())) {
                selectedDoctor = doctors.get(0);
            }

            List<TimeSlot> slots = Collections.emptyList();
            List<Appointment> appointments = Collections.emptyList();
            String shiftSummary = "OFF";
            int availableCount = 0;
            Map<Integer, Boolean> lockedSlots = new HashMap<>();
            if (selectedDoctor != null) {
                slots = workScheduleDAO.getDoctorShiftSlotsForDate(selectedDoctor.getId(), date.toString());
                shiftSummary = workScheduleDAO.getDoctorWorkShiftSummary(selectedDoctor.getId(), date.toString());
                appointments = appointmentDAO.getStaffAppointments(Date.valueOf(date), "all", selectedDoctor.getId(), null);
                for (Appointment appointment : appointments) {
                    if ("In_Progress".equals(appointment.getStatus()) || "Completed".equals(appointment.getStatus())) {
                        lockedSlots.put(appointment.getScheduleId(), true);
                    }
                }
                for (TimeSlot slot : slots) {
                    if (!slot.isBooked() && !slot.isPast()) availableCount++;
                }
            }

            request.setAttribute("doctors", doctors);
            request.setAttribute("selectedDoctor", selectedDoctor);
            request.setAttribute("selectedDate", date.toString());
            request.setAttribute("today", today.toString());
            request.setAttribute("slots", slots);
            request.setAttribute("lockedSlots", lockedSlots);
            request.setAttribute("appointments", appointments);
            request.setAttribute("shiftSummary", shiftSummary);
            request.setAttribute("availableCount", availableCount);
            String csrfToken = (String) request.getSession().getAttribute("doctorScheduleCsrf");
            if (csrfToken == null) {
                csrfToken = UUID.randomUUID().toString();
                request.getSession().setAttribute("doctorScheduleCsrf", csrfToken);
            }
            request.setAttribute("csrfToken", csrfToken);
            request.getRequestDispatcher("/views/staff/doctor-reschedule-form.jsp").forward(request, response);
        } catch (Exception e) {
            throw new ServletException("Không thể tải lịch bác sĩ", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        User user = (User) request.getSession().getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        if (user.getRoleId() != 1 && user.getRoleId() != 2 && user.getRoleId() != 5) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        String csrfToken = (String) request.getSession().getAttribute("doctorScheduleCsrf");
        if (csrfToken == null || !csrfToken.equals(request.getParameter("csrfToken"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        request.getSession().removeAttribute("doctorScheduleCsrf");

        int doctorId = 0;
        String viewDate = request.getParameter("viewDate");
        try {
            doctorId = Integer.parseInt(request.getParameter("doctorId"));
            String sourceSession = request.getParameter("sourceSession");
            LocalDate sourceDate = LocalDate.parse(viewDate);
            String reason = request.getParameter("reason");
            reason = reason == null ? "" : reason.trim();
            if (reason.length() < 10 || reason.length() > 500) {
                throw new IllegalArgumentException("Lý do điều chỉnh cần từ 10 đến 500 ký tự.");
            }

            Map<Integer, StaffDoctorRescheduleDAO.Replacement> replacements = new HashMap<>();
            for (TimeSlot slot : workScheduleDAO.getDoctorShiftSlotsForDate(doctorId, sourceDate.toString())) {
                String doctorParam = request.getParameter("replacementDoctor_" + slot.getId());
                String dateParam = request.getParameter("targetDate_" + slot.getId());
                if (doctorParam != null && !doctorParam.isBlank() && dateParam != null && !dateParam.isBlank()) {
                    replacements.put(slot.getId(), new StaffDoctorRescheduleDAO.Replacement(
                            Integer.parseInt(doctorParam), LocalDate.parse(dateParam)));
                }
            }
            List<StaffDoctorRescheduleDAO.Result> results = rescheduleDAO.changeShift(
                    doctorId, sourceDate, sourceSession, replacements, user.getId(), reason);
            long moved = results.stream().filter(result -> result.appointmentId() != null).count();
            int emailsSent = 0;
            int emailsFailed = 0;
            int noEmail = 0;
            for (StaffDoctorRescheduleDAO.Result result : results) {
                if (result.appointmentId() == null) continue;
                try {
                    Appointment updated = appointmentDAO.getAppointmentDetailById(result.appointmentId());
                    if (updated != null && updated.getEmail() != null && !updated.getEmail().isBlank()) {
                        EmailUtil.sendDoctorReplacementEmail(updated.getEmail().trim(),
                                updated.getPatientName(), updated.getId(), updated.getDoctorName(),
                                updated.getAppointmentDate().toString(), updated.getTimeSlot());
                        emailsSent++;
                    } else {
                        noEmail++;
                    }
                } catch (Exception e) {
                    emailsFailed++;
                    getServletContext().log("Cannot email patient after doctor schedule change", e);
                }
            }
            request.getSession().setAttribute("successMessage", "Đã điều chỉnh " + results.size()
                    + " khung giờ ca " + ("Morning".equals(sourceSession) ? "Sáng" : "Chiều")
                    + " và chuyển " + moved + " lịch hẹn. Email gửi thành công: " + emailsSent
                    + (noEmail > 0 ? "; bệnh nhân chưa có email: " + noEmail : "")
                    + (emailsFailed > 0 ? "; gửi lỗi: " + emailsFailed : "") + ".");
        } catch (IllegalArgumentException | IllegalStateException e) {
            request.getSession().setAttribute("errorMessage", e.getMessage());
        } catch (Exception e) {
            getServletContext().log("Cannot change doctor schedule", e);
            request.getSession().setAttribute("errorMessage", "Không thể điều chỉnh lịch bác sĩ. Vui lòng tải lại trang và thử lại.");
        }

        String redirect = request.getContextPath() + "/staff/doctor-reschedule";
        try {
            LocalDate selected = LocalDate.parse(viewDate);
            if (doctorId > 0) redirect += "?doctorId=" + doctorId + "&date=" + selected;
        } catch (Exception ignored) {}
        response.sendRedirect(redirect);
    }
}
