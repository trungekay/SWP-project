package com.visioncare.controller;

import com.visioncare.dao.AppointmentDAO;
import com.visioncare.dao.DoctorDAO;
import com.visioncare.dao.RoomDAO;
import com.visioncare.model.Appointment;
import com.visioncare.model.Doctor;
import com.visioncare.model.Room;
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
import java.util.Set;
import java.util.stream.Collectors;

@WebServlet(name = "StaffWaitingListServlet", urlPatterns = {"/staff/waiting-list", "/staff/update-status"})
public class StaffWaitingListServlet extends HttpServlet {

    private final AppointmentDAO appointmentDAO = new AppointmentDAO();
    private final DoctorDAO doctorDAO = new DoctorDAO();
    private final RoomDAO roomDAO = new RoomDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String dateParam = request.getParameter("date");
            String statusParam = request.getParameter("status");
            String doctorIdParam = request.getParameter("doctorId");
            String roomIdParam = request.getParameter("roomId");
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

            Integer roomId = null;
            if (roomIdParam != null && !roomIdParam.trim().isEmpty() && !"all".equalsIgnoreCase(roomIdParam.trim())) {
                try {
                    roomId = Integer.parseInt(roomIdParam.trim());
                } catch (NumberFormatException ignored) {}
            }

            String filterStatus;
            if (statusParam != null && !statusParam.trim().isEmpty()) {
                filterStatus = statusParam.trim();
            } else {
                filterStatus = "all";
            }

            // Lấy tất cả ca đã check-in trong ngày để tính chỉ số KPI hàng đợi ổn định
            List<Appointment> allDayQueue = appointmentDAO.getWaitingList(queryDate, "all_day", doctorId, roomId, null);
            long totalWaiting = allDayQueue.stream().filter(a -> "Confirmed".equalsIgnoreCase(a.getStatus())).count();
            long totalExamining = allDayQueue.stream().filter(a -> "In_Progress".equalsIgnoreCase(a.getStatus())).count();
            long totalCompleted = allDayQueue.stream().filter(a -> "Completed".equalsIgnoreCase(a.getStatus())).count();
            long totalQueue = totalWaiting + totalExamining;

            // Danh sách các bác sĩ hiện đang có bệnh nhân trong phòng khám (In_Progress)
            Set<Integer> busyDoctorIds = allDayQueue.stream()
                    .filter(a -> "In_Progress".equalsIgnoreCase(a.getStatus()) && a.getDoctorId() > 0)
                    .map(Appointment::getDoctorId)
                    .collect(Collectors.toSet());

            // Lấy danh sách hiển thị theo status và keyword
            List<Appointment> waitingList = appointmentDAO.getWaitingList(queryDate, filterStatus, doctorId, roomId, keyword);
            List<Doctor> doctors = doctorDAO.getAll();
            List<Room> rooms = roomDAO.getAll();

            request.setAttribute("waitingList", waitingList);
            request.setAttribute("doctors", doctors);
            request.setAttribute("rooms", rooms);
            request.setAttribute("selectedDate", dateParam);
            request.setAttribute("selectedDoctorId", doctorId);
            request.setAttribute("selectedRoomId", roomId);
            request.setAttribute("selectedStatus", filterStatus);
            request.setAttribute("keyword", keyword);
            request.setAttribute("totalWaiting", totalWaiting);
            request.setAttribute("totalExamining", totalExamining);
            request.setAttribute("totalCompleted", totalCompleted);
            request.setAttribute("totalQueue", totalQueue);
            request.setAttribute("busyDoctorIds", busyDoctorIds);

            request.getRequestDispatcher("/views/staff/waiting-list.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi tải hàng đợi khám: " + e.getMessage());
            request.getRequestDispatcher("/views/staff/waiting-list.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        HttpSession session = request.getSession();

        if ("absent".equalsIgnoreCase(action) || "cancel".equalsIgnoreCase(action)) {
            String apptIdParam = request.getParameter("appointmentId");
            String reasonSelect = request.getParameter("cancelReasonSelect");
            String reasonCustom = request.getParameter("cancelReasonCustom");

            String reason = "Gọi tên nhiều lần không có mặt / Không vào phòng khám";
            if ("other".equalsIgnoreCase(reasonSelect)) {
                if (reasonCustom != null && !reasonCustom.trim().isEmpty()) {
                    reason = reasonCustom.trim();
                } else {
                    reason = "Bệnh nhân vắng mặt không rõ lý do";
                }
            } else if (reasonSelect != null && !reasonSelect.trim().isEmpty()) {
                reason = reasonSelect.trim();
            }

            if (apptIdParam != null && !apptIdParam.trim().isEmpty()) {
                try {
                    int apptId = Integer.parseInt(apptIdParam.trim());
                    boolean success = appointmentDAO.cancelAppointment(apptId, "Báo vắng mặt: " + reason);
                    if (success) {
                        session.setAttribute("successMessage", "Đã ghi nhận bệnh nhân (#APPT-" + apptId + ") vắng mặt và gỡ khỏi hàng đợi.");
                    } else {
                        session.setAttribute("errorMessage", "Không thể ghi nhận vắng mặt cho ca khám #APPT-" + apptId);
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                    session.setAttribute("errorMessage", "Lỗi xử lý vắng mặt: " + e.getMessage());
                }
            }
        } else if ("skip".equalsIgnoreCase(action)) {
            String apptIdParam = request.getParameter("appointmentId");
            if (apptIdParam != null && !apptIdParam.trim().isEmpty()) {
                try {
                    int apptId = Integer.parseInt(apptIdParam.trim());
                    boolean success = appointmentDAO.skipQueue(apptId);
                    if (success) {
                        session.setAttribute("successMessage", "Đã bỏ qua lượt cho bệnh nhân (#APPT-" + apptId + ") và chuyển xuống cuối hàng đợi.");
                    } else {
                        session.setAttribute("errorMessage", "Không thể chuyển lượt cho ca khám #APPT-" + apptId);
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                    session.setAttribute("errorMessage", "Lỗi chuyển lượt: " + e.getMessage());
                }
            }
        } else if ("updateStatus".equalsIgnoreCase(action)) {
            String apptIdParam = request.getParameter("appointmentId");
            String newStatus = request.getParameter("status");

            if (apptIdParam != null && newStatus != null) {
                try {
                    int apptId = Integer.parseInt(apptIdParam.trim());

                    if ("Canceled".equalsIgnoreCase(newStatus.trim())) {
                        boolean success = appointmentDAO.cancelAppointment(apptId, "Lễ tân hủy ca / Vắng mặt");
                        if (success) {
                            session.setAttribute("successMessage", "Đã hủy ca khám (#APPT-" + apptId + ") và gỡ khỏi hàng đợi.");
                        } else {
                            session.setAttribute("errorMessage", "Không thể hủy ca khám #APPT-" + apptId);
                        }
                    } else {
                        // Kiểm tra quy tắc: Mỗi ca khám / mỗi bác sĩ chỉ có 1 bệnh nhân tại 1 thời điểm
                        if ("In_Progress".equalsIgnoreCase(newStatus.trim())) {
                            Date todayDate = Date.valueOf(LocalDate.now());
                            List<Appointment> currentQueue = appointmentDAO.getWaitingList(todayDate, null, null, null);
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
                                    String returnUrl = request.getParameter("returnUrl");
                                    if (returnUrl != null && !returnUrl.trim().isEmpty() && !returnUrl.contains(".jsp")) {
                                        response.sendRedirect(returnUrl);
                                    } else {
                                        response.sendRedirect(request.getContextPath() + "/staff/waiting-list");
                                    }
                                    return;
                                }
                            }
                        }

                        boolean success = appointmentDAO.updateAppointmentStatus(apptId, newStatus.trim());

                        if (success) {
                            if ("In_Progress".equalsIgnoreCase(newStatus.trim())) {
                                session.setAttribute("successMessage", "Bệnh nhân (#APPT-" + apptId + ") đã được gọi vào phòng khám.");
                            } else if ("Completed".equalsIgnoreCase(newStatus.trim())) {
                                session.setAttribute("successMessage", "Ca khám (#APPT-" + apptId + ") đã được xác nhận hoàn tất thành công.");
                            } else {
                                session.setAttribute("successMessage", "Đã cập nhật ca khám (#APPT-" + apptId + ") thành công.");
                            }
                        } else {
                            session.setAttribute("errorMessage", "Không thể cập nhật trạng thái cho ca khám #APPT-" + apptId);
                        }
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                    session.setAttribute("errorMessage", "Lỗi cập nhật trạng thái: " + e.getMessage());
                }
            }
        }

        String returnUrl = request.getParameter("returnUrl");
        if (returnUrl != null && !returnUrl.trim().isEmpty() && !returnUrl.contains(".jsp")) {
            response.sendRedirect(returnUrl);
        } else {
            response.sendRedirect(request.getContextPath() + "/staff/waiting-list");
        }
    }
}
