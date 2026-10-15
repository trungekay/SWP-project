package com.visioncare.controller;

import com.visioncare.dao.AppointmentDAO;
import com.visioncare.model.Appointment;
import com.visioncare.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet(name = "StaffAppointmentDetailServlet", urlPatterns = {"/staff/appointment-detail"})
public class StaffAppointmentDetailServlet extends HttpServlet {

    private final AppointmentDAO appointmentDAO = new AppointmentDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/staff/appointments");
            return;
        }

        try {
            // Tự động quét và hủy các ca hẹn quá hạn/quá giờ mà không đến check-in
            appointmentDAO.autoCancelExpiredAppointments();

            int apptId = Integer.parseInt(idParam.trim());
            Appointment appointment = appointmentDAO.getAppointmentById(apptId);
            if (appointment == null) {
                HttpSession session = request.getSession();
                session.setAttribute("errorMessage", "Không tìm thấy lịch hẹn #" + apptId);
                response.sendRedirect(request.getContextPath() + "/staff/appointments");
                return;
            }

            request.setAttribute("appointment", appointment);
            request.getRequestDispatcher("/views/staff/appointment-detail.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            HttpSession session = request.getSession();
            session.setAttribute("errorMessage", "Lỗi tải chi tiết lịch hẹn: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/staff/appointments");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        String idParam = request.getParameter("appointmentId");
        HttpSession session = request.getSession();

        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/staff/appointments");
            return;
        }

        try {
            int apptId = Integer.parseInt(idParam.trim());

            if ("saveNotes".equalsIgnoreCase(action)) {
                String notes = request.getParameter("medicalNotes");
                int doctorId = 0;
                String docIdParam = request.getParameter("doctorId");
                if (docIdParam != null && !docIdParam.trim().isEmpty()) {
                    doctorId = Integer.parseInt(docIdParam.trim());
                }

                boolean success = appointmentDAO.saveMedicalNotes(apptId, doctorId, notes);
                if (success) {
                    session.setAttribute("successMessage", "Ghi chú y tế ban đầu đã được lưu thành công vào hồ sơ khám.");
                } else {
                    session.setAttribute("errorMessage", "Không thể lưu ghi chú y tế.");
                }
            } else if ("checkin".equalsIgnoreCase(action)) {
                User currentUser = (User) session.getAttribute("user");
                int staffEmployeeId = (currentUser != null && currentUser.getActorId() > 0) ? currentUser.getActorId() : 0;

                boolean success = appointmentDAO.checkInPatient(apptId, staffEmployeeId);
                if (success) {
                    Appointment appt = appointmentDAO.getAppointmentById(apptId);
                    String patientName = (appt != null && appt.getPatientName() != null) ? appt.getPatientName() : "bệnh nhân";
                    session.setAttribute("successMessage", "Đã tiếp đón " + patientName + " (#APPT-" + apptId + ") thành công! Đã chuyển vào hàng đợi phòng khám.");
                    response.sendRedirect(request.getContextPath() + "/staff/waiting-list");
                    return;
                } else {
                    session.setAttribute("errorMessage", "Check-in không thành công.");
                }
            } else if ("startExam".equalsIgnoreCase(action) || "inProgress".equalsIgnoreCase(action)) {
                java.sql.Date todayDate = java.sql.Date.valueOf(java.time.LocalDate.now());
                java.util.List<Appointment> currentQueue = appointmentDAO.getWaitingList(todayDate, null, null, null);
                Appointment targetAppt = currentQueue.stream().filter(a -> a.getId() == apptId).findFirst().orElse(null);
                if (targetAppt != null) {
                    Appointment busyAppt = currentQueue.stream()
                            .filter(a -> "In_Progress".equalsIgnoreCase(a.getStatus())
                                    && a.getId() != apptId
                                    && ((targetAppt.getDoctorId() > 0 && a.getDoctorId() == targetAppt.getDoctorId())
                                        || (targetAppt.getRoomName() != null && !targetAppt.getRoomName().isEmpty() && targetAppt.getRoomName().equalsIgnoreCase(a.getRoomName()))))
                            .findFirst().orElse(null);
                    if (busyAppt != null) {
                        session.setAttribute("errorMessage", "Không thể gọi vào phòng: "
                                + (targetAppt.getDoctorName() != null ? targetAppt.getDoctorName() : "Bác sĩ")
                                + " hiện đang khám cho bệnh nhân " + busyAppt.getPatientName() + " (#APPT-" + busyAppt.getId() + ")! Mỗi ca 30 phút chỉ có 1 bệnh nhân trong phòng, vui lòng hoàn tất ca hiện tại trước.");
                        response.sendRedirect(request.getContextPath() + "/staff/appointment-detail?id=" + apptId);
                        return;
                    }
                }

                boolean success = appointmentDAO.updateAppointmentStatus(apptId, "In_Progress");
                if (success) {
                    session.setAttribute("successMessage", "Bệnh nhân (#APPT-" + apptId + ") đã được gọi vào phòng khám.");
                } else {
                    session.setAttribute("errorMessage", "Không thể cập nhật trạng thái vào khám.");
                }
            } else if ("complete".equalsIgnoreCase(action)) {
                boolean success = appointmentDAO.updateAppointmentStatus(apptId, "Completed");
                if (success) {
                    session.setAttribute("successMessage", "Ca khám (#APPT-" + apptId + ") đã được xác nhận hoàn tất thành công.");
                } else {
                    session.setAttribute("errorMessage", "Không thể cập nhật hoàn tất ca khám.");
                }
            } else if ("absent".equalsIgnoreCase(action)) {
                String reasonSelect = request.getParameter("cancelReasonSelect");
                String reasonCustom = request.getParameter("cancelReasonCustom");
                String reason = "other".equalsIgnoreCase(reasonSelect) ? reasonCustom : reasonSelect;
                if (reason == null || reason.trim().isEmpty()) {
                    reason = "Gọi tên nhiều lần không có mặt / Không vào phòng khám";
                }

                boolean success = appointmentDAO.cancelAppointment(apptId, "Báo vắng mặt: " + reason.trim());
                if (success) {
                    session.setAttribute("successMessage", "Đã ghi nhận bệnh nhân (#APPT-" + apptId + ") vắng mặt và gỡ khỏi hàng đợi khám.");
                } else {
                    session.setAttribute("errorMessage", "Không thể ghi nhận vắng mặt cho ca khám #" + apptId);
                }
            } else if ("skip".equalsIgnoreCase(action)) {
                boolean success = appointmentDAO.skipQueue(apptId);
                if (success) {
                    session.setAttribute("successMessage", "Đã bỏ qua lượt cho bệnh nhân (#APPT-" + apptId + ") và chuyển xuống cuối hàng đợi.");
                } else {
                    session.setAttribute("errorMessage", "Không thể chuyển lượt cho ca khám #" + apptId);
                }
            } else if ("cancel".equalsIgnoreCase(action)) {
                String reasonSelect = request.getParameter("cancelReasonSelect");
                String reasonCustom = request.getParameter("cancelReasonCustom");
                String reason = "other".equalsIgnoreCase(reasonSelect) ? reasonCustom : reasonSelect;
                if (reason == null || reason.trim().isEmpty()) {
                    reason = request.getParameter("cancelReason");
                }
                if (reason == null || reason.trim().isEmpty()) {
                    reason = "Bệnh nhân báo bận, yêu cầu đổi lịch sang ngày khác";
                }

                boolean success = appointmentDAO.cancelAppointment(apptId, reason.trim());
                if (success) {
                    session.setAttribute("successMessage", "Lịch hẹn (#APPT-" + apptId + ") đã được hủy thành công. Ca khám của bác sĩ đã được giải phóng.");
                } else {
                    session.setAttribute("errorMessage", "Không thể hủy lịch hẹn #" + apptId);
                }
            }

            response.sendRedirect(request.getContextPath() + "/staff/appointment-detail?id=" + apptId);
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMessage", "Có lỗi xảy ra: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/staff/appointment-detail?id=" + idParam);
        }
    }
}
