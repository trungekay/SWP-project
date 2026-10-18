package com.visioncare.controller;

import com.visioncare.dao.AppointmentDAO;
import com.visioncare.dao.CatalogDAO;
import com.visioncare.dao.DoctorDAO;
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
import java.sql.Date;
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
                    session.setAttribute("errorMessage", "Ca khám (#APPT-" + checkId + ") đã qua ngày (" + checkAppt.getAppointmentDate() + "). Hệ thống chỉ cho phép xem thông tin hồ sơ ca khám!");
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
            apptIdParam = request.getParameter("appointmentId");
            if (apptIdParam != null && !apptIdParam.trim().isEmpty()) {
                try {
                    int apptId = Integer.parseInt(apptIdParam.trim());
                    String resultMsg = appointmentDAO.skipQueue(apptId);
                    if (resultMsg != null && !resultMsg.isEmpty()) {
                        session.setAttribute("successMessage", resultMsg);
                    } else {
                        session.setAttribute("errorMessage", "Không thể chuyển lượt cho ca khám #APPT-" + apptId);
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

                                // Bắt buộc theo từng slot đối với lịch 1 bác sĩ:
                                // Không được gọi ca sau (ví dụ Ca 6) nếu bác sĩ đó vẫn còn ca trước (ví dụ Ca 2) đang ở trạng thái 'Confirmed'
                                if (targetAppt.getDoctorId() > 0) {
                                    Appointment earlierAppt = currentQueue.stream()
                                            .filter(a -> "Confirmed".equalsIgnoreCase(a.getStatus())
                                                    && a.getId() != apptId
                                                    && a.getDoctorId() == targetAppt.getDoctorId()
                                                    && (a.getTimeSlot() != null && targetAppt.getTimeSlot() != null && a.getTimeSlot().compareTo(targetAppt.getTimeSlot()) < 0))
                                            .findFirst().orElse(null);
                                    if (earlierAppt != null) {
                                        String earlierTime = earlierAppt.getTimeSlot() + (earlierAppt.getEndTime() != null ? " - " + earlierAppt.getEndTime() : "");
                                        session.setAttribute("errorMessage", "Không thể gọi ca này vào khám! Bác sĩ "
                                                + (targetAppt.getDoctorName() != null ? targetAppt.getDoctorName() : "")
                                                + " bắt buộc phải khám tuần tự theo từng ca. Hiện vẫn còn ca trước (#APPT-" + earlierAppt.getId()
                                                + " - " + earlierTime + ") đang chờ khám!");
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
                        session.setAttribute("successMessage", "Tiếp đón khách vãng lai: " + patientName.trim() + " (#APPT-" + newApptId + ") thành công! Bệnh nhân đã được đưa vào danh sách chờ khám.");
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
        }

        String returnUrl = request.getParameter("returnUrl");
        if (returnUrl != null && !returnUrl.trim().isEmpty() && !returnUrl.contains(".jsp")) {
            response.sendRedirect(returnUrl);
        } else {
            response.sendRedirect(request.getContextPath() + "/staff/waiting-list");
        }
    }
}
