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
            int apptId = Integer.parseInt(idParam.trim());
            Appointment appointment = appointmentDAO.getAppointmentById(apptId);
            if (appointment == null) {
                HttpSession session = request.getSession();
                session.setAttribute("errorMessage", "Không tìm thấy lịch hẹn #" + apptId);
                response.sendRedirect(request.getContextPath() + "/staff/appointments");
                return;
            }

            request.setAttribute("appointment", appointment);
            request.setAttribute("todayStr", java.time.LocalDate.now().toString());
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

            Appointment targetAppt = appointmentDAO.getAppointmentById(apptId);
            if (targetAppt != null && targetAppt.isPast()) {
                session.setAttribute("errorMessage", "Lịch hẹn (#APPT-" + apptId + ") đã qua ngày khám (" + targetAppt.getAppointmentDate() + "). Hệ thống chỉ cho phép xem thông tin và ghi chú y tế, không thể thực hiện thao tác khác!");
                response.sendRedirect(request.getContextPath() + "/staff/appointment-detail?id=" + apptId);
                return;
            }

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
                session.setAttribute("errorMessage", "Không thể gọi vào khám từ màn hình Lễ tân! Thao tác này phải do Bác sĩ phụ trách gọi từ trong phòng khám.");
                response.sendRedirect(request.getContextPath() + "/staff/appointment-detail?id=" + apptId);
                return;
            } else if ("complete".equalsIgnoreCase(action)) {
                session.setAttribute("errorMessage", "Không thể hoàn tất ca khám từ màn hình Lễ tân! Thao tác này phải do Bác sĩ phụ trách thực hiện trong phòng khám sau khi kết thúc chẩn đoán và kê đơn.");
                response.sendRedirect(request.getContextPath() + "/staff/appointment-detail?id=" + apptId);
                return;
            } else if ("absent".equalsIgnoreCase(action)) {
                if (targetAppt != null && "In_Progress".equalsIgnoreCase(targetAppt.getStatus())) {
                    session.setAttribute("errorMessage", "Bệnh nhân đang ở trạng thái Đang khám trong phòng! Không thể báo vắng mặt hoặc hủy ca khám.");
                    response.sendRedirect(request.getContextPath() + "/staff/appointment-detail?id=" + apptId);
                    return;
                }

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
                try {
                    String resultMsg = appointmentDAO.skipQueue(apptId);
                    if (resultMsg != null && !resultMsg.isEmpty()) {
                        session.setAttribute("successMessage", resultMsg);
                    } else {
                        session.setAttribute("errorMessage", "Không thể chuyển lượt cho ca khám #" + apptId);
                    }
                } catch (Exception e) {
                    session.setAttribute("errorMessage", "Không thể bỏ qua lượt: " + e.getMessage());
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
