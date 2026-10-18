package com.visioncare.controller;

import com.visioncare.dao.AppointmentDAO;
import com.visioncare.dao.CatalogDAO;
import com.visioncare.dao.DoctorDAO;
import com.visioncare.model.Appointment;
import com.visioncare.model.CatalogService;
import com.visioncare.model.Doctor;
import com.visioncare.model.Patient;
import com.visioncare.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.Date;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "StaffAppointmentListServlet", urlPatterns = {"/staff/appointments", "/staff/check-in"})
public class StaffAppointmentListServlet extends HttpServlet {

    private final AppointmentDAO appointmentDAO = new AppointmentDAO();
    private final DoctorDAO doctorDAO = new DoctorDAO();
    private final CatalogDAO catalogDAO = new CatalogDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String ajaxAction = request.getParameter("ajax");
        if ("checkPayment".equalsIgnoreCase(ajaxAction)) {
            response.setContentType("application/json;charset=UTF-8");
            String apptIdStr = request.getParameter("appointmentId");
            boolean isPaid = false;
            if (apptIdStr != null && !apptIdStr.trim().isEmpty()) {
                try {
                    int apptId = Integer.parseInt(apptIdStr.trim());
                    Appointment appt = appointmentDAO.getAppointmentDetailById(apptId);
                    isPaid = (appt != null && ("Confirmed".equalsIgnoreCase(appt.getStatus()) || "Paid".equalsIgnoreCase(appt.getInvoiceStatus())));
                    if (!isPaid) {
                        String payosStatus = com.visioncare.util.PayOSUtil.getPaymentStatus(apptId);
                        if ("PAID".equalsIgnoreCase(payosStatus)) {
                            HttpSession session = request.getSession();
                            User currentUser = (User) session.getAttribute("user");
                            int staffEmployeeId = (currentUser != null && currentUser.getActorId() > 0) ? currentUser.getActorId() : 0;
                            appointmentDAO.confirmAndCheckinWalkin(apptId, staffEmployeeId);
                            isPaid = true;
                        }
                    } else if (appt != null && (appt.getCheckinTime() == null || appt.getCheckinTime().isEmpty())) {
                        HttpSession session = request.getSession();
                        User currentUser = (User) session.getAttribute("user");
                        int staffEmployeeId = (currentUser != null && currentUser.getActorId() > 0) ? currentUser.getActorId() : 0;
                        appointmentDAO.checkInPatient(apptId, staffEmployeeId);
                    }
                } catch (Exception ignored) {}
            }
            response.getWriter().write("{\"isPaid\":" + isPaid + "}");
            return;
        }
        if ("checkPhone".equalsIgnoreCase(ajaxAction)) {
            response.setContentType("application/json;charset=UTF-8");
            String rawPhone = request.getParameter("phone");
            String phone = (rawPhone != null) ? rawPhone.replaceAll("[^0-9]", "") : "";
            StringBuilder json = new StringBuilder("{");
            if (phone.length() == 10) {
                Patient p = appointmentDAO.findPatientByPhone(phone);
                if (p != null) {
                    json.append("\"found\":true,");
                    json.append("\"name\":\"").append(escapeJson(p.getFullName())).append("\",");
                    json.append("\"dob\":\"").append(p.getDob() != null ? p.getDob().toString() : "").append("\",");
                    Appointment activeAppt = appointmentDAO.getPatientActiveAppointmentToday(phone, Date.valueOf(LocalDate.now()));
                    if (activeAppt != null) {
                        json.append("\"hasApptToday\":true,");
                        json.append("\"apptId\":").append(activeAppt.getId()).append(",");
                        json.append("\"apptStatus\":\"").append(escapeJson(activeAppt.getStatus())).append("\",");
                        json.append("\"apptTime\":\"").append(escapeJson(activeAppt.getTimeSlot())).append("\",");
                        json.append("\"doctorName\":\"").append(escapeJson(activeAppt.getDoctorName() != null ? activeAppt.getDoctorName() : "")).append("\"");
                    } else {
                        json.append("\"hasApptToday\":false");
                    }
                } else {
                    json.append("\"found\":false");
                }
            } else {
                json.append("\"found\":false");
            }
            json.append("}");
            response.getWriter().write(json.toString());
            return;
        } else if ("checkDoctorSlots".equalsIgnoreCase(ajaxAction)) {
            response.setContentType("application/json;charset=UTF-8");
            String docIdStr = request.getParameter("doctorId");
            StringBuilder json = new StringBuilder("{\"bookedSlots\":[");
            if (docIdStr != null && !docIdStr.trim().isEmpty()) {
                try {
                    int docId = Integer.parseInt(docIdStr.trim());
                    List<String> bookedSlots = appointmentDAO.getBookedSlotsForDoctorToday(docId, Date.valueOf(LocalDate.now()));
                    for (int i = 0; i < bookedSlots.size(); i++) {
                        if (i > 0) json.append(",");
                        json.append("\"").append(bookedSlots.get(i)).append("\"");
                    }
                } catch (NumberFormatException ignored) {}
            }
            json.append("]}");
            response.getWriter().write(json.toString());
            return;
        }
        try {
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

            request.setAttribute("appointments", appointments);
            request.setAttribute("doctors", doctors);
            request.setAttribute("services", bookingServices);
            request.setAttribute("selectedDate", dateParam);
            request.setAttribute("selectedDoctorId", doctorId);
            request.setAttribute("selectedStatus", filterStatus);
            request.setAttribute("keyword", keyword);
            request.setAttribute("todayStr", todayStr);

            request.setAttribute("totalCount", totalCount);
            request.setAttribute("pendingCount", pendingCount);
            request.setAttribute("checkedInCount", checkedInCount);
            request.setAttribute("completedCount", completedCount);
            request.setAttribute("canceledCount", canceledCount);

            String servletPath = request.getServletPath();
            String currentNav = "/staff/check-in".equals(servletPath) ? "checkin" : "appointments";
            request.setAttribute("navActive", currentNav);

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
                    Appointment ticket = appointmentDAO.getAppointmentById(apptId);
                    if (ticket != null && ticket.isPast()) {
                        session.setAttribute("errorMessage", "Lịch hẹn (#APPT-" + apptId + ") đã qua ngày khám (" + ticket.getAppointmentDate() + "). Chỉ có thể xem thông tin và ghi chú y tế, không thể thực hiện tiếp đón!");
                        String returnUrl = request.getParameter("returnUrl");
                        response.sendRedirect(returnUrl != null && !returnUrl.isEmpty() ? returnUrl : (request.getContextPath() + "/staff/appointments"));
                        return;
                    }

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

                        ticket = appointmentDAO.getAppointmentById(apptId);
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
                    Appointment targetAppt = appointmentDAO.getAppointmentById(apptId);
                    if (targetAppt != null && targetAppt.isPast()) {
                        session.setAttribute("errorMessage", "Lịch hẹn (#APPT-" + apptId + ") đã qua ngày khám (" + targetAppt.getAppointmentDate() + "), không thể thực hiện hủy lịch!");
                        String returnUrl = request.getParameter("returnUrl");
                        response.sendRedirect(returnUrl != null && !returnUrl.isEmpty() ? returnUrl : (request.getContextPath() + "/staff/appointments"));
                        return;
                    }

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
        } else if ("confirmWalkinPayment".equalsIgnoreCase(action)) {
            response.setContentType("application/json;charset=UTF-8");
            String apptIdStr = request.getParameter("appointmentId");
            boolean success = false;
            if (apptIdStr != null && !apptIdStr.trim().isEmpty()) {
                try {
                    int apptId = Integer.parseInt(apptIdStr.trim());
                    User currentUser = (User) session.getAttribute("user");
                    int staffEmployeeId = (currentUser != null && currentUser.getActorId() > 0) ? currentUser.getActorId() : 0;
                    success = appointmentDAO.confirmAndCheckinWalkin(apptId, staffEmployeeId);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
            response.getWriter().write("{\"success\":" + success + "}");
            return;
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
                if ("1".equals(request.getParameter("ajax"))) {
                    response.setContentType("application/json;charset=UTF-8");
                    response.getWriter().write("{\"success\":false,\"message\":\"Vui lòng nhập họ tên, số điện thoại và chọn bác sĩ tiếp đón!\"}");
                    return;
                }
                session.setAttribute("errorMessage", "Vui lòng nhập họ tên, số điện thoại và chọn bác sĩ tiếp đón!");
            } else {
                try {
                    int doctorId = Integer.parseInt(doctorIdParam.trim());
                    Date today = Date.valueOf(LocalDate.now());

                    Date dob = null;
                    if (dobStr != null && !dobStr.trim().isEmpty()) {
                        try {
                            dob = Date.valueOf(dobStr.trim());
                        } catch (IllegalArgumentException ignored) {}
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

                    boolean isPendingPayment = "VietQR_Banking".equalsIgnoreCase(paymentMethod);
                    int newApptId = appointmentDAO.createWalkinAppointment(appt, staffEmployeeId, isPendingPayment);

                    if (newApptId > 0) {
                        if (isPendingPayment) {
                            String phoneSafe = appt.getPhone() != null ? appt.getPhone() : "";
                            String paymentDesc = "VC" + newApptId + " " + phoneSafe;
                            String encodedDesc = URLEncoder.encode(paymentDesc, StandardCharsets.UTF_8);
                            String qrUrl = "https://img.vietqr.io/image/MB-0335889999-compact2.png?amount=" + fee + "&addInfo=" + encodedDesc + "&accountName=PHONG%20KHAM%20MAT%20VISIONCARE";

                            String ajaxParam = request.getParameter("ajax");
                            String ajaxHeader = request.getHeader("X-Requested-With");
                            if ("1".equals(ajaxParam) || "XMLHttpRequest".equalsIgnoreCase(ajaxHeader)) {
                                response.setContentType("application/json;charset=UTF-8");
                                String json = "{"
                                        + "\"success\":true,"
                                        + "\"appointmentId\":" + newApptId + ","
                                        + "\"patientName\":\"" + escapeJson(patientName.trim()) + "\","
                                        + "\"phone\":\"" + escapeJson(phone.trim()) + "\","
                                        + "\"fee\":" + fee + ","
                                        + "\"formattedFee\":\"" + String.format("%,d ₫", fee).replace(',', '.') + "\","
                                        + "\"paymentDesc\":\"" + escapeJson(paymentDesc) + "\","
                                        + "\"qrUrl\":\"" + escapeJson(qrUrl) + "\","
                                        + "\"bankName\":\"Ngân hàng Quân Đội (MB Bank)\","
                                        + "\"accountNumber\":\"0335889999\","
                                        + "\"accountHolder\":\"PHONG KHAM MAT VISIONCARE\""
                                        + "}";
                                response.getWriter().write(json);
                                return;
                            }
                        }

                        session.setAttribute("successMessage", "Tiếp đón khách vãng lai: " + patientName.trim() + " (#APPT-" + newApptId + ") thành công! Bệnh nhân đã được đưa vào danh sách chờ khám.");
                        response.sendRedirect(request.getContextPath() + "/staff/waiting-list");
                        return;
                    } else {
                        if ("1".equals(request.getParameter("ajax"))) {
                            response.setContentType("application/json;charset=UTF-8");
                            response.getWriter().write("{\"success\":false,\"message\":\"Không thể tiếp đón khách vãng lai lúc này.\"}");
                            return;
                        }
                        session.setAttribute("errorMessage", "Không thể tiếp đón khách vãng lai lúc này.");
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                    if ("1".equals(request.getParameter("ajax"))) {
                        response.setContentType("application/json;charset=UTF-8");
                        response.getWriter().write("{\"success\":false,\"message\":\"" + escapeJson(e.getMessage()) + "\"}");
                        return;
                    }
                    session.setAttribute("errorMessage", "Lỗi tiếp đón khách vãng lai: " + e.getMessage());
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

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "");
    }
}
