package com.visioncare.controller;

import com.visioncare.dao.AppointmentDAO;
import com.visioncare.dao.CatalogDAO;
import com.visioncare.dao.DoctorDAO;
import com.visioncare.dao.MedicalRecordDAO;
import com.visioncare.dao.RoomDAO;
import com.visioncare.model.Appointment;
import com.visioncare.model.CatalogService;
import com.visioncare.model.Doctor;
import com.visioncare.model.Room;
import com.visioncare.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import com.visioncare.dao.DBContext;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

@WebServlet(name = "StaffWaitingListServlet", urlPatterns = {"/staff/waiting-list", "/staff/update-status"})
public class StaffWaitingListServlet extends HttpServlet {

    private final AppointmentDAO appointmentDAO = new AppointmentDAO();
    private final DoctorDAO doctorDAO = new DoctorDAO();
    private final RoomDAO roomDAO = new RoomDAO();
    private final CatalogDAO catalogDAO = new CatalogDAO();
    private final MedicalRecordDAO medicalRecordDAO = new MedicalRecordDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String ajax = request.getParameter("ajax");
        if ("postExamDetail".equalsIgnoreCase(ajax)) {
            handlePostExamDetailAjax(request, response);
            return;
        }

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
            long totalQueue = totalWaiting + totalExamining + totalCompleted;

            // Danh sách các bác sĩ hiện đang có bệnh nhân trong phòng khám (In_Progress)
            Set<Integer> busyDoctorIds = allDayQueue.stream()
                    .filter(a -> "In_Progress".equalsIgnoreCase(a.getStatus()) && a.getDoctorId() > 0)
                    .map(Appointment::getDoctorId)
                    .collect(Collectors.toSet());

            // Quy tắc y tế: Bắt buộc theo từng slot đối với lịch 1 bác sĩ
            // Với mỗi bác sĩ: chỉ ca Confirmed có ca/slot sớm nhất mới ĐƯỢC PHÉP GỌI khi bác sĩ đó rảnh
            Set<Integer> callableApptIds = new HashSet<>();
            Map<Integer, Appointment> nextCallableByDoctor = new HashMap<>();
            for (Appointment a : allDayQueue) {
                if ("Confirmed".equalsIgnoreCase(a.getStatus()) && a.getDoctorId() > 0) {
                    int docId = a.getDoctorId();
                    if (!busyDoctorIds.contains(docId)) {
                        Appointment cur = nextCallableByDoctor.get(docId);
                        if (cur == null) {
                            nextCallableByDoctor.put(docId, a);
                        } else {
                            String t1 = a.getTimeSlot() != null ? a.getTimeSlot() : "";
                            String t2 = cur.getTimeSlot() != null ? cur.getTimeSlot() : "";
                            if (t1.compareTo(t2) < 0) {
                                nextCallableByDoctor.put(docId, a);
                            }
                        }
                    }
                }
            }
            for (Appointment a : nextCallableByDoctor.values()) {
                callableApptIds.add(a.getId());
            }

            // Lấy danh sách hiển thị theo status và keyword
            List<Appointment> waitingList = appointmentDAO.getWaitingList(queryDate, filterStatus, doctorId, roomId, keyword);
            List<Doctor> doctors = doctorDAO.getAll();
            List<Room> rooms = roomDAO.getAll();

            // Tải danh mục dịch vụ khám & tư vấn từ Service_Catalog
            List<CatalogService> allServices = null;
            try {
                allServices = catalogDAO.listServices();
            } catch (Exception e) {
                e.printStackTrace();
            }
            List<CatalogService> bookingServices = new ArrayList<>();
            if (allServices != null) {
                for (CatalogService cs : allServices) {
                    if ("Khám và tư vấn".equalsIgnoreCase(cs.getCategory())
                            || "Kiểm tra và chẩn đoán".equalsIgnoreCase(cs.getCategory())
                            || (cs.getPrice() != null && cs.getPrice().longValue() <= 1000000)) {
                        bookingServices.add(cs);
                    }
                }
            }

            request.setAttribute("waitingList", waitingList);
            request.setAttribute("doctors", doctors);
            request.setAttribute("rooms", rooms);
            request.setAttribute("services", bookingServices);
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
            request.setAttribute("callableApptIds", callableApptIds);

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

        String apptIdParam = request.getParameter("appointmentId");
        if (apptIdParam != null && !apptIdParam.trim().isEmpty() && !"walkin".equalsIgnoreCase(action)) {
            try {
                int checkId = Integer.parseInt(apptIdParam.trim());
                Appointment checkAppt = appointmentDAO.getAppointmentById(checkId);
                if (checkAppt != null && checkAppt.isPast()) {
                    session.setAttribute("errorMessage", "Ca khám (#APT-" + checkId + ") đã qua ngày (" + checkAppt.getAppointmentDate() + "). Hệ thống chỉ cho phép xem thông tin hồ sơ ca khám!");
                    String returnUrl = request.getParameter("returnUrl");
                    if (returnUrl != null && !returnUrl.trim().isEmpty() && !returnUrl.contains(".jsp")) {
                        response.sendRedirect(returnUrl);
                    } else {
                        response.sendRedirect(request.getContextPath() + "/staff/waiting-list");
                    }
                    return;
                }
            } catch (Exception ignored) {
            }
        }

        if ("absent".equalsIgnoreCase(action) || "cancel".equalsIgnoreCase(action)) {
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
                    Appointment targetAppt = appointmentDAO.getAppointmentById(apptId);
                    if (targetAppt != null && "In_Progress".equalsIgnoreCase(targetAppt.getStatus())) {
                        session.setAttribute("errorMessage", "Bệnh nhân đang ở trạng thái Đang khám trong phòng! Không thể báo vắng mặt hoặc hủy ca khám.");
                        String returnUrl = request.getParameter("returnUrl");
                        if (returnUrl != null && !returnUrl.trim().isEmpty() && !returnUrl.contains(".jsp")) {
                            response.sendRedirect(returnUrl);
                        } else {
                            response.sendRedirect(request.getContextPath() + "/staff/waiting-list");
                        }
                        return;
                    }

                    boolean success = appointmentDAO.cancelAppointment(apptId, "Báo vắng mặt: " + reason);
                    if (success) {
                        session.setAttribute("successMessage", "Đã ghi nhận bệnh nhân (#APT-" + apptId + ") vắng mặt và gỡ khỏi hàng đợi.");
                    } else {
                        session.setAttribute("errorMessage", "Không thể ghi nhận vắng mặt cho ca khám #APT-" + apptId + ". Ca có thể đã được bác sĩ gọi vào khám; vui lòng tải lại hàng đợi.");
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                    session.setAttribute("errorMessage", "Lỗi xử lý vắng mặt: " + e.getMessage());
                }
            }
        } else if ("skip".equalsIgnoreCase(action)) {
            apptIdParam = request.getParameter("appointmentId");
            if (apptIdParam != null && !apptIdParam.trim().isEmpty()) {
                try {
                    int apptId = Integer.parseInt(apptIdParam.trim());
                    String resultMsg = appointmentDAO.skipQueue(apptId);
                    if (resultMsg != null && !resultMsg.isEmpty()) {
                        session.setAttribute("successMessage", resultMsg);
                    } else {
                        session.setAttribute("errorMessage", "Không thể chuyển lượt cho ca khám #APT-" + apptId);
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                    session.setAttribute("errorMessage", "Không thể bỏ qua lượt: " + e.getMessage());
                }
            }
        } else if ("updateStatus".equalsIgnoreCase(action)) {
            apptIdParam = request.getParameter("appointmentId");
            String newStatus = request.getParameter("status");

            if (apptIdParam != null && newStatus != null) {
                try {
                    int apptId = Integer.parseInt(apptIdParam.trim());

                    if ("Completed".equalsIgnoreCase(newStatus.trim())) {
                        session.setAttribute("errorMessage", "Không thể hoàn tất ca khám từ màn hình Lễ tân! Thao tác này phải do Bác sĩ phụ trách thực hiện trong phòng khám sau khi kết thúc chẩn đoán và kê đơn.");
                        String returnUrl = request.getParameter("returnUrl");
                        if (returnUrl != null && !returnUrl.trim().isEmpty() && !returnUrl.contains(".jsp")) {
                            response.sendRedirect(returnUrl);
                        } else {
                            response.sendRedirect(request.getContextPath() + "/staff/waiting-list");
                        }
                        return;
                    }

                    if ("In_Progress".equalsIgnoreCase(newStatus.trim())) {
                        session.setAttribute("errorMessage", "Không thể gọi vào khám từ màn hình Hàng đợi phòng khám của Lễ tân! Thao tác này phải do Bác sĩ phụ trách gọi từ trong phòng khám.");
                        String returnUrl = request.getParameter("returnUrl");
                        if (returnUrl != null && !returnUrl.trim().isEmpty() && !returnUrl.contains(".jsp")) {
                            response.sendRedirect(returnUrl);
                        } else {
                            response.sendRedirect(request.getContextPath() + "/staff/waiting-list");
                        }
                        return;
                    }

                    if ("Canceled".equalsIgnoreCase(newStatus.trim())) {
                        boolean success = appointmentDAO.cancelAppointment(apptId, "Lễ tân hủy ca / Vắng mặt");
                        if (success) {
                            session.setAttribute("successMessage", "Đã hủy ca khám (#APT-" + apptId + ") và gỡ khỏi hàng đợi.");
                        } else {
                            session.setAttribute("errorMessage", "Không thể hủy ca khám #APT-" + apptId + ". Ca có thể đã được bác sĩ gọi vào khám hoặc đã hoàn tất; vui lòng tải lại hàng đợi.");
                        }
                    } else {
                        session.setAttribute("errorMessage", "Không thể đổi trạng thái khám từ màn hình Lễ tân. Vui lòng dùng thao tác tiếp đón hoặc để bác sĩ xử lý ca khám.");
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                    session.setAttribute("errorMessage", "Lỗi cập nhật trạng thái: " + e.getMessage());
                }
            }
        } else if ("walkin".equalsIgnoreCase(action)) {
            String patientName = request.getParameter("patientName");
            String phone = request.getParameter("phone");
            String dobStr = request.getParameter("dob");
            String serviceIdParam = request.getParameter("serviceId");
            String paymentMethod = request.getParameter("paymentMethod");
            String doctorIdParam = request.getParameter("doctorId");
            String timeSlot = request.getParameter("timeSlot");
            String reason = request.getParameter("reason");

            if (patientName == null || patientName.trim().isEmpty() ||
                phone == null || phone.trim().isEmpty() ||
                doctorIdParam == null || doctorIdParam.trim().isEmpty()) {
                session.setAttribute("errorMessage", "Vui lòng nhập họ tên, số điện thoại và chọn bác sĩ tiếp đón!");
            } else {
                try {
                    int doctorId = Integer.parseInt(doctorIdParam.trim());
                    Date today = Date.valueOf(LocalDate.now());

                    Date dob = null;
                    if (dobStr != null && !dobStr.trim().isEmpty()) {
                        String s = dobStr.trim();
                        try {
                            if (s.contains("/")) {
                                String[] parts = s.split("/");
                                if (parts.length == 3) {
                                    int d = Integer.parseInt(parts[0].trim());
                                    int m = Integer.parseInt(parts[1].trim());
                                    int y = Integer.parseInt(parts[2].trim());
                                    if (y < 100) {
                                        y += (y > 26 ? 1900 : 2000);
                                    }
                                    dob = Date.valueOf(String.format("%04d-%02d-%02d", y, m, d));
                                }
                            } else if (s.contains("-")) {
                                dob = Date.valueOf(s);
                            }
                        } catch (Exception ignored) {}
                    }

                    int serviceId = 0;
                    if (serviceIdParam != null && !serviceIdParam.trim().isEmpty()) {
                        try {
                            serviceId = Integer.parseInt(serviceIdParam.trim());
                        } catch (NumberFormatException ignored) {}
                    }
                    CatalogService selectedSvc = null;
                    if (serviceId > 0) {
                        try {
                            selectedSvc = catalogDAO.getService(serviceId);
                        } catch (Exception ignored) {}
                    }
                    long fee = (selectedSvc != null && selectedSvc.getPrice() != null) ? selectedSvc.getPrice().longValue() : 200000;
                    String serviceName = (selectedSvc != null) ? selectedSvc.getName() : "Khám mắt tổng quát & Soi đáy mắt";

                    if (timeSlot == null || timeSlot.trim().isEmpty()) {
                        java.time.LocalTime now = java.time.LocalTime.now();
                        int minute = now.getMinute() >= 30 ? 30 : 0;
                        timeSlot = String.format("%02d:%02d", now.getHour(), minute);
                    }

                    Appointment appt = new Appointment();
                    appt.setPatientName(patientName.trim());
                    appt.setPhone(phone.trim());
                    appt.setDob(dob);
                    appt.setDoctorId(doctorId);
                    appt.setAppointmentDate(today);
                    appt.setTimeSlot(timeSlot.trim());
                    appt.setServiceId(serviceId);
                    appt.setServiceName(serviceName);
                    appt.setReason(reason != null && !reason.trim().isEmpty() ? reason.trim() : "Khách vãng lai");
                    appt.setTotalAmount(fee);
                    appt.setFee(fee);
                    appt.setPayment(paymentMethod != null && !paymentMethod.trim().isEmpty() ? paymentMethod.trim() : "Cash_At_Counter");

                    User currentUser = (User) session.getAttribute("user");
                    int staffEmployeeId = (currentUser != null && currentUser.getActorId() > 0) ? currentUser.getActorId() : 0;

                    int newApptId = appointmentDAO.createWalkinAppointment(appt, staffEmployeeId);
                    if (newApptId > 0) {
                        session.setAttribute("successMessage", "Tiếp đón khách vãng lai: " + patientName.trim() + " (#APT-" + newApptId + ") thành công! Bệnh nhân đã được đưa vào danh sách chờ khám.");
                        response.sendRedirect(request.getContextPath() + "/staff/waiting-list");
                        return;
                    } else {
                        session.setAttribute("errorMessage", "Không thể tiếp đón khách vãng lai lúc này.");
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                    session.setAttribute("errorMessage", "Lỗi tiếp đón khách vãng lai: " + e.getMessage());
                }
            }
        } else if ("confirmHandover".equalsIgnoreCase(action) || "completeAppointment".equalsIgnoreCase(action)) {
            apptIdParam = request.getParameter("appointmentId");
            String paymentGateway = request.getParameter("paymentGateway");
            if (paymentGateway == null || paymentGateway.trim().isEmpty()) {
                paymentGateway = "Cash";
            }

            if (apptIdParam != null && !apptIdParam.trim().isEmpty()) {
                try {
                    int apptId = Integer.parseInt(apptIdParam.trim());
                    Appointment checkAppt = appointmentDAO.getAppointmentById(apptId);
                    if (checkAppt == null) {
                        if ("1".equals(request.getParameter("ajax"))) {
                            response.setContentType("application/json;charset=UTF-8");
                            response.getWriter().write("{\"success\":false,\"message\":\"Không tìm thấy lịch hẹn!\"}");
                            return;
                        }
                        session.setAttribute("errorMessage", "Không tìm thấy lịch hẹn #APT-" + apptId);
                        String returnUrl = request.getParameter("returnUrl");
                        if (returnUrl != null && !returnUrl.trim().isEmpty() && !returnUrl.contains(".jsp")) {
                            response.sendRedirect(returnUrl);
                        } else {
                            response.sendRedirect(request.getContextPath() + "/staff/waiting-list");
                        }
                        return;
                    }

                    if (!"Completed".equalsIgnoreCase(checkAppt.getStatus())) {
                        String notCompletedMsg = "Không thể hoàn tất lịch hẹn (#APT-" + apptId + ") do Bác sĩ đang khám trong phòng và chưa hoàn tất ca khám!";
                        if ("1".equals(request.getParameter("ajax"))) {
                            response.setContentType("application/json;charset=UTF-8");
                            response.getWriter().write("{\"success\":false,\"message\":\"" + escapeJson(notCompletedMsg) + "\"}");
                            return;
                        }
                        session.setAttribute("errorMessage", notCompletedMsg);
                        String returnUrl = request.getParameter("returnUrl");
                        if (returnUrl != null && !returnUrl.trim().isEmpty() && !returnUrl.contains(".jsp")) {
                            response.sendRedirect(returnUrl);
                        } else {
                            response.sendRedirect(request.getContextPath() + "/staff/waiting-list");
                        }
                        return;
                    }

                    User currentUser = (User) session.getAttribute("user");
                    int staffEmployeeId = (currentUser != null && currentUser.getActorId() > 0) ? currentUser.getActorId() : 0;

                    boolean success = appointmentDAO.completeAppointmentByStaff(apptId, staffEmployeeId, paymentGateway);
                    if (success) {
                        if ("1".equals(request.getParameter("ajax"))) {
                            response.setContentType("application/json;charset=UTF-8");
                            response.getWriter().write("{\"success\":true,\"message\":\"Đã thanh toán phần còn lại và hoàn tất lịch hẹn (#APT-" + apptId + ") thành công!\"}");
                            return;
                        }
                        session.setAttribute("successMessage", "Đã thanh toán và hoàn tất lịch hẹn cho bệnh nhân (#APT-" + apptId + ").");
                    } else {
                        if ("1".equals(request.getParameter("ajax"))) {
                            response.setContentType("application/json;charset=UTF-8");
                            response.getWriter().write("{\"success\":false,\"message\":\"Không thể hoàn tất lịch hẹn #APT-" + apptId + "\"}");
                            return;
                        }
                        session.setAttribute("errorMessage", "Không thể hoàn tất lịch hẹn: #APT-" + apptId);
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                    if ("1".equals(request.getParameter("ajax"))) {
                        response.setContentType("application/json;charset=UTF-8");
                        response.getWriter().write("{\"success\":false,\"message\":\"Lỗi hoàn tất: " + escapeJson(e.getMessage()) + "\"}");
                        return;
                    }
                    session.setAttribute("errorMessage", "Không thể hoàn tất lịch hẹn: " + e.getMessage());
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

    private void handlePostExamDetailAjax(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        String idParam = request.getParameter("appointmentId");
        if (idParam == null || idParam.trim().isEmpty()) {
            response.getWriter().write("{\"success\":false,\"message\":\"Thiếu mã lịch hẹn\"}");
            return;
        }

        try {
            int apptId = Integer.parseInt(idParam.trim());
            Appointment appt = appointmentDAO.getAppointmentById(apptId);
            if (appt == null) {
                response.getWriter().write("{\"success\":false,\"message\":\"Không tìm thấy lịch hẹn\"}");
                return;
            }

            Map<String, Object> mr = null;
            try {
                mr = medicalRecordDAO.getMedicalRecordDetail(apptId);
            } catch (Exception mrEx) {
                log("Cannot fetch medical record detail for #" + apptId, mrEx);
            }

            StringBuilder sb = new StringBuilder("{");
            sb.append("\"success\":true,");
            sb.append("\"appointmentId\":").append(appt.getId()).append(",");
            sb.append("\"patientName\":\"").append(escapeJson(appt.getPatientName())).append("\",");
            sb.append("\"phone\":\"").append(escapeJson(appt.getPhone())).append("\",");
            sb.append("\"dob\":\"").append(escapeJson(appt.getDob() != null ? appt.getDob().toString() : "")).append("\",");
            sb.append("\"doctorName\":\"").append(escapeJson(appt.getDoctorName() != null ? appt.getDoctorName() : "Bác sĩ")).append("\",");
            sb.append("\"roomName\":\"").append(escapeJson(appt.getRoomName() != null ? appt.getRoomName() : "Phòng khám")).append("\",");
            sb.append("\"timeSlot\":\"").append(escapeJson(appt.getTimeSlot() != null ? appt.getTimeSlot() : "")).append("\",");
            sb.append("\"appointmentDate\":\"").append(appt.getAppointmentDate() != null ? appt.getAppointmentDate().toString() : "").append("\",");
            sb.append("\"status\":\"").append(escapeJson(appt.getStatus())).append("\",");
            sb.append("\"medicalNotes\":\"").append(escapeJson(appt.getMedicalNotes() != null ? appt.getMedicalNotes() : "")).append("\",");

            // Query Master_Invoice directly
            long totalAmount = 200000;
            long depositAmount = 200000;
            long balanceDue = 0;
            String invStatus = "Paid";
            int invId = 0;
            try (Connection conn = DBContext.getConnection();
                 PreparedStatement psInv = conn.prepareStatement("SELECT Invoice_ID, Total_Amount, Deposit_Amount, Balance_Due, Status FROM Master_Invoice WHERE Appointment_ID = ?")) {
                psInv.setInt(1, apptId);
                try (ResultSet rsInv = psInv.executeQuery()) {
                    if (rsInv.next()) {
                        invId = rsInv.getInt("Invoice_ID");
                        totalAmount = rsInv.getLong("Total_Amount");
                        depositAmount = rsInv.getLong("Deposit_Amount");
                        balanceDue = rsInv.getLong("Balance_Due");
                        invStatus = rsInv.getString("Status");
                    }
                }
            } catch (Exception ex) {
                log("Error fetching invoice for appt #" + apptId, ex);
            }

            sb.append("\"invoiceId\":").append(invId).append(",");
            sb.append("\"totalAmount\":").append(totalAmount).append(",");
            sb.append("\"totalAmountFmt\":\"").append(String.format("%,d ₫", totalAmount)).append("\",");
            sb.append("\"depositAmount\":").append(depositAmount).append(",");
            sb.append("\"depositAmountFmt\":\"").append(String.format("%,d ₫", depositAmount)).append("\",");
            sb.append("\"balanceDue\":").append(balanceDue).append(",");
            sb.append("\"balanceDueFmt\":\"").append(String.format("%,d ₫", balanceDue)).append("\",");
            sb.append("\"invoiceStatus\":\"").append(escapeJson(invStatus)).append("\",");
            sb.append("\"invoiceAmountFmt\":\"").append(String.format("%,d ₫", totalAmount)).append("\",");
            sb.append("\"isFullyPaid\":").append(balanceDue <= 0 && "Paid".equalsIgnoreCase(invStatus)).append(",");

            if (mr != null) {
                Object formId = mr.get("formattedId");
                sb.append("\"recordId\":\"").append(escapeJson(formId != null ? String.valueOf(formId) : "#MR-" + apptId)).append("\",");
                Object diag = mr.get("clinicalDiagnosis");
                sb.append("\"clinicalDiagnosis\":\"").append(escapeJson(diag != null ? String.valueOf(diag) : "Khám mắt tổng quát")).append("\",");
                Object examRes = mr.get("examinationResult");
                sb.append("\"examinationResult\":\"").append(escapeJson(examRes != null ? String.valueOf(examRes) : "")).append("\",");
                Object conc = mr.get("conclusion");
                sb.append("\"conclusion\":\"").append(escapeJson(conc != null ? String.valueOf(conc) : "")).append("\",");
                Object followUp = mr.get("followUpDate");
                sb.append("\"followUpDate\":\"").append(escapeJson(followUp != null ? String.valueOf(followUp) : "")).append("\",");
                Object docNotes = mr.get("doctorNotes");
                sb.append("\"doctorNotes\":\"").append(escapeJson(docNotes != null ? String.valueOf(docNotes) : "Uống/nhỏ thuốc theo đúng hướng dẫn của bác sĩ.")).append("\",");

                // Medicines
                sb.append("\"medicines\":[");
                Object rawMeds = mr.get("medicines");
                if (rawMeds instanceof List) {
                    List<?> meds = (List<?>) rawMeds;
                    for (int i = 0; i < meds.size(); i++) {
                        Object item = meds.get(i);
                        if (item instanceof Map) {
                            @SuppressWarnings("unchecked")
                            Map<String, Object> m = (Map<String, Object>) item;
                            if (i > 0) sb.append(",");
                            Object sttVal = m.get("stt");
                            Object nameVal = m.get("medicineName");
                            Object qtyVal = m.get("quantity");
                            Object doseVal = m.get("dosageInstruction");

                            sb.append("{");
                            sb.append("\"stt\":").append(sttVal != null ? sttVal : (i + 1)).append(",");
                            sb.append("\"name\":\"").append(escapeJson(nameVal != null ? String.valueOf(nameVal) : "")).append("\",");
                            sb.append("\"quantity\":").append(qtyVal != null ? qtyVal : 1).append(",");
                            sb.append("\"dosageInstruction\":\"").append(escapeJson(doseVal != null ? String.valueOf(doseVal) : "")).append("\"");
                            sb.append("}");
                        }
                    }
                }
                sb.append("],");

                // Procedures
                sb.append("\"procedures\":[");
                Object rawProcs = mr.get("procedures");
                if (rawProcs instanceof List) {
                    List<?> procs = (List<?>) rawProcs;
                    for (int i = 0; i < procs.size(); i++) {
                        Object item = procs.get(i);
                        if (item instanceof Map) {
                            @SuppressWarnings("unchecked")
                            Map<String, Object> p = (Map<String, Object>) item;
                            if (i > 0) sb.append(",");
                            Object sName = p.get("serviceName");
                            Object pFmt = p.get("priceFmt");
                            Object pStat = p.get("status");

                            sb.append("{");
                            sb.append("\"serviceName\":\"").append(escapeJson(sName != null ? String.valueOf(sName) : "")).append("\",");
                            sb.append("\"priceFmt\":\"").append(escapeJson(pFmt != null ? String.valueOf(pFmt) : "0 ₫")).append("\",");
                            sb.append("\"status\":\"").append(escapeJson(pStat != null ? String.valueOf(pStat) : "")).append("\"");
                            sb.append("}");
                        }
                    }
                }
                sb.append("]");
            } else {
                sb.append("\"clinicalDiagnosis\":\"Khám mắt tổng quát\",");
                sb.append("\"examinationResult\":\"\",");
                sb.append("\"conclusion\":\"Bình thường\",");
                sb.append("\"doctorNotes\":\"Uống thuốc và tái khám theo chỉ định.\",");
                sb.append("\"medicines\":[],");
                sb.append("\"procedures\":[]");
            }

            sb.append("}");
            response.getWriter().write(sb.toString());
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"success\":false,\"message\":\"Lỗi tải thông tin sau khám: " + escapeJson(e.getMessage()) + "\"}");
        }
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "");
    }
}
