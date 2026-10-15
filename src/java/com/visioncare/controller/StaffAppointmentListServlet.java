package com.visioncare.controller;

import com.visioncare.dao.AppointmentDAO;
import com.visioncare.dao.DoctorDAO;
import com.visioncare.model.Appointment;
import com.visioncare.model.Doctor;
import com.visioncare.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Date;
import java.time.LocalDate;
import java.util.List;

@WebServlet(name = "StaffAppointmentListServlet", urlPatterns = {"/staff/appointments", "/staff/check-in"})
public class StaffAppointmentListServlet extends HttpServlet {

    private final AppointmentDAO appointmentDAO = new AppointmentDAO();
    private final DoctorDAO doctorDAO = new DoctorDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Tự động quét và hủy các ca hẹn quá hạn/quá giờ mà không đến check-in
            appointmentDAO.autoCancelExpiredAppointments();

            String dateParam = request.getParameter("date");
            String statusParam = request.getParameter("status");
            String doctorIdParam = request.getParameter("doctorId");
            String keywordParam = request.getParameter("keyword");
            String keyword = (keywordParam != null) ? keywordParam.trim() : "";

            Date queryDate = null;
            String todayStr = LocalDate.now().toString();

            if (dateParam != null && !dateParam.trim().isEmpty() && !"all".equalsIgnoreCase(dateParam.trim())) {
                try {
                    queryDate = Date.valueOf(dateParam.trim());
                } catch (IllegalArgumentException e) {
                    queryDate = Date.valueOf(todayStr);
                    dateParam = todayStr;
                }
            } else if (dateParam != null && "all".equalsIgnoreCase(dateParam.trim())) {
                queryDate = null;
            } else {
                // Nếu không chỉ định ngày:
                // - Có keyword tìm kiếm: tìm kiếm trên toàn bộ các ngày để tìm nhanh lịch của bệnh nhân
                // - Không có keyword: mặc định hiển thị hôm nay
                if (!keyword.isEmpty()) {
                    queryDate = null;
                    dateParam = "all";
                } else {
                    queryDate = Date.valueOf(todayStr);
                    dateParam = todayStr;
                }
            }

            Integer doctorId = null;
            if (doctorIdParam != null && !doctorIdParam.trim().isEmpty() && !"all".equalsIgnoreCase(doctorIdParam.trim())) {
                try {
                    doctorId = Integer.parseInt(doctorIdParam.trim());
                } catch (NumberFormatException ignored) {}
            }

            String filterStatus;
            if (statusParam != null && !statusParam.trim().isEmpty()) {
                filterStatus = statusParam.trim();
            } else if (!keyword.isEmpty()) {
                filterStatus = "all";
            } else {
                filterStatus = "Pending";
            }

            // Lấy toàn bộ lịch hẹn trong ngày để tính chỉ số KPI tiếp đón
            List<Appointment> allDayAppointments = appointmentDAO.getStaffAppointments(queryDate, "all", doctorId, null);
            int totalCount = allDayAppointments.size();
            long pendingCount = allDayAppointments.stream().filter(a -> a.getCheckinTime() == null && !"Canceled".equalsIgnoreCase(a.getStatus())).count();
            long checkedInCount = allDayAppointments.stream().filter(a -> a.getCheckinTime() != null && !"Canceled".equalsIgnoreCase(a.getStatus())).count();
            long completedCount = allDayAppointments.stream().filter(a -> "Completed".equalsIgnoreCase(a.getStatus())).count();
            long canceledCount = allDayAppointments.stream().filter(a -> "Canceled".equalsIgnoreCase(a.getStatus())).count();

            // Lấy danh sách lịch hẹn theo trạng thái đang chọn (Mặc định: Pending - Chờ tiếp đón)
            List<Appointment> appointments = appointmentDAO.getStaffAppointments(queryDate, filterStatus, doctorId, keyword);
            List<Doctor> doctors = doctorDAO.getAll();

            request.setAttribute("appointments", appointments);
            request.setAttribute("doctors", doctors);
            request.setAttribute("selectedDate", dateParam);
            request.setAttribute("selectedDoctorId", doctorId);
            request.setAttribute("selectedStatus", filterStatus);
            request.setAttribute("keyword", keyword);

            request.setAttribute("totalCount", totalCount);
            request.setAttribute("pendingCount", pendingCount);
            request.setAttribute("checkedInCount", checkedInCount);
            request.setAttribute("completedCount", completedCount);
            request.setAttribute("canceledCount", canceledCount);

            request.getRequestDispatcher("/views/staff/appointment-list.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi tải danh sách lịch hẹn: " + e.getMessage());
            request.getRequestDispatcher("/views/staff/appointment-list.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        HttpSession session = request.getSession();

        if ("checkin".equalsIgnoreCase(action)) {
            String apptIdParam = request.getParameter("appointmentId");
            if (apptIdParam != null && !apptIdParam.trim().isEmpty()) {
                try {
                    int apptId = Integer.parseInt(apptIdParam.trim());
                    User currentUser = (User) session.getAttribute("user");
                    int staffEmployeeId = (currentUser != null && currentUser.getActorId() > 0) ? currentUser.getActorId() : 0;

                    boolean success = appointmentDAO.checkInPatient(apptId, staffEmployeeId);
                    if (success) {
                        // Lưu medical notes nếu lễ tân nhập luôn trong lúc check-in
                        String notes = request.getParameter("medicalNotes");
                        String docIdParam = request.getParameter("doctorId");
                        int doctorId = 0;
                        if (docIdParam != null && !docIdParam.trim().isEmpty()) {
                            try { doctorId = Integer.parseInt(docIdParam.trim()); } catch (NumberFormatException ignored) {}
                        }
                        if (notes != null && !notes.trim().isEmpty()) {
                            appointmentDAO.saveMedicalNotes(apptId, doctorId, notes.trim());
                        }

                        Appointment ticket = appointmentDAO.getAppointmentById(apptId);
                        String patientName = (ticket != null && ticket.getPatientName() != null) ? ticket.getPatientName() : "bệnh nhân";
                        session.setAttribute("successMessage", "Tiếp đón " + patientName + " (#APPT-" + apptId + ") thành công! Đã chuyển vào danh sách chờ khám.");
                        response.sendRedirect(request.getContextPath() + "/staff/waiting-list");
                        return;
                    } else {
                        session.setAttribute("errorMessage", "Không thể check-in lịch hẹn #" + apptId);
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                    session.setAttribute("errorMessage", "Lỗi thực hiện check-in: " + e.getMessage());
                }
            }
        } else if ("cancel".equalsIgnoreCase(action)) {
            String apptIdParam = request.getParameter("appointmentId");
            String reasonSelect = request.getParameter("cancelReasonSelect");
            String reasonCustom = request.getParameter("cancelReasonCustom");
            String reason = "other".equalsIgnoreCase(reasonSelect) ? reasonCustom : reasonSelect;
            if (reason == null || reason.trim().isEmpty()) {
                reason = "Bệnh nhân báo bận, yêu cầu đổi lịch sang ngày khác";
            }

            if (apptIdParam != null && !apptIdParam.trim().isEmpty()) {
                try {
                    int apptId = Integer.parseInt(apptIdParam.trim());
                    boolean success = appointmentDAO.cancelAppointment(apptId, reason.trim());
                    if (success) {
                        session.setAttribute("successMessage", "Đã hủy lịch hẹn (#APPT-" + apptId + ") thành công! Ca khám của bác sĩ đã được giải phóng.");
                    } else {
                        session.setAttribute("errorMessage", "Không thể hủy lịch hẹn #" + apptId);
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                    session.setAttribute("errorMessage", "Lỗi khi hủy lịch hẹn: " + e.getMessage());
                }
            }
        }

        String returnUrl = request.getParameter("returnUrl");
        if (returnUrl != null && !returnUrl.trim().isEmpty() && !returnUrl.contains(".jsp")) {
            response.sendRedirect(returnUrl);
        } else {
            response.sendRedirect(request.getContextPath() + "/staff/appointments");
        }
    }
}
