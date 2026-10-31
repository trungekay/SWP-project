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
            // orderCode được truyền từ JS (lưu từ lúc tạo QR)
            String orderCodeStr = request.getParameter("orderCode");
            boolean isPaid = false;
            if (apptIdStr != null && !apptIdStr.trim().isEmpty()) {
                try {
                    int apptId = Integer.parseInt(apptIdStr.trim());
                    Appointment appt = appointmentDAO.getAppointmentDetailById(apptId);
                    isPaid = appt != null && appt.isDepositPaid();
                    if (!isPaid) {
                        // Dùng orderCode thực từ khi tạo PayOS link, KHÔNG dùng apptId
                        long orderCode = 0;
                        if (orderCodeStr != null && !orderCodeStr.trim().isEmpty()) {
                            try { orderCode = Long.parseLong(orderCodeStr.trim()); } catch (NumberFormatException ignored2) {}
                        }
                        if (orderCode > 0) {
                            String payosStatus = com.visioncare.util.PayOSUtil.getPaymentStatus(orderCode);
                            if ("PAID".equalsIgnoreCase(payosStatus)) {
                                HttpSession session = request.getSession();
                                User currentUser = (User) session.getAttribute("user");
                                int staffEmployeeId = (currentUser != null && currentUser.getActorId() > 0) ? currentUser.getActorId() : 0;
                                // Thanh toán QR: xác nhận Paid/Confirmed, KHÔNG tự check-in
                                appointmentDAO.confirmAndCheckinWalkin(apptId, staffEmployeeId, false);
                                isPaid = true;
                            }
                        }
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
        java.util.List<java.util.Map<String, Object>> refundInvoices = new com.visioncare.dao.RefundDAO().getInvoicesForStaffRefundSelection();
        request.setAttribute("availableInvoices", refundInvoices);
        java.util.Map<Integer, Boolean> refundEligible = new java.util.HashMap<>();
        for (java.util.Map<String, Object> invoice : refundInvoices) refundEligible.put((Integer) invoice.get("appointmentId"), true);
        request.setAttribute("refundEligible", refundEligible);
        request.setAttribute("activeAppointmentRefunds", new com.visioncare.dao.RefundDAO().getActiveRefundsForStaffAppointments());
        try {
            // Tự động quét và hủy các ca hẹn quá hạn từ hôm qua trở về trước mà bệnh nhân không check-in
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
            } else {
                filterStatus = "all";
            }

            // Lấy toàn bộ lịch hẹn trong ngày để tính chỉ số KPI tiếp đón
            List<Appointment> allDayAppointments = appointmentDAO.getStaffAppointments(queryDate, "all", doctorId, null);
            int totalCount = allDayAppointments.size();
            long pendingCount = allDayAppointments.stream().filter(a -> a.isReadyForCheckIn() || a.isCancellationRequested()).count();
            long checkedInCount = allDayAppointments.stream().filter(a -> a.getCheckinTime() != null && !"Canceled".equalsIgnoreCase(a.getStatus())).count();
            long completedCount = allDayAppointments.stream().filter(a -> "Completed".equalsIgnoreCase(a.getEffectiveStatus())).count();
            long canceledCount = allDayAppointments.stream().filter(a -> "Canceled".equalsIgnoreCase(a.getStatus())).count();
            request.setAttribute("cancellationRequestedCount", appointmentDAO.getStaffAppointments(null, "CancellationRequested", null, null).size());
            request.setAttribute("refundEligibleCount", refundInvoices.size());

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
                    if ("Khám và chẩn đoán".equalsIgnoreCase(cs.getCategory())
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
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        HttpSession session = request.getSession();

        if ("approveCancellation".equals(action)) {
            try {
                int id = Integer.parseInt(request.getParameter("appointmentId"));
                Appointment appt = appointmentDAO.getAppointmentById(id);
                boolean ok = appt != null && appt.isCancellationRequested()
                    && appointmentDAO.cancelAppointment(id, "Đã duyệt yêu cầu hủy lịch của bệnh nhân: " + (appt.getReason() != null && appt.getReason().startsWith(com.visioncare.dao.RefundPolicy.REQUESTED)
                        ? appt.getReason().substring(com.visioncare.dao.RefundPolicy.REQUESTED.length()) : "Yêu cầu hủy lịch từ luồng trước"));
                session.setAttribute(ok ? "successMessage" : "errorMessage", ok
                    ? "Đã duyệt hủy lịch #APT-" + id + ". Có thể tạo yêu cầu hoàn tiền."
                    : "Yêu cầu hủy không hợp lệ hoặc bệnh nhân đã check-in.");
            } catch (Exception e) { session.setAttribute("errorMessage", "Không thể duyệt yêu cầu hủy lịch."); }
            String idFilter = request.getParameter("appointmentId");
            String keyword = idFilter != null && idFilter.matches("[0-9]+") ? idFilter : "";
            response.sendRedirect(request.getContextPath() + "/staff/appointments?date=all&status=all&keyword=" + keyword);
            return;
        }

        if ("confirmHandover".equalsIgnoreCase(action) || "completeAppointment".equalsIgnoreCase(action)) {
            String apptIdParam = request.getParameter("appointmentId");
            String paymentGateway = request.getParameter("paymentGateway");
            if (paymentGateway == null || paymentGateway.trim().isEmpty()) {
                paymentGateway = "Cash";
            }

            if (apptIdParam != null && !apptIdParam.trim().isEmpty()) {
                try {
                    int apptId = Integer.parseInt(apptIdParam.trim());
                    Appointment checkAppt = appointmentDAO.getAppointmentById(apptId);
                    if (checkAppt == null) {
                        session.setAttribute("errorMessage", "Không tìm thấy lịch hẹn #APT-" + apptId);
                        String returnUrl = request.getParameter("returnUrl");
                        response.sendRedirect(returnUrl != null && !returnUrl.trim().isEmpty() && !returnUrl.contains(".jsp") ? returnUrl : (request.getContextPath() + "/staff/appointments"));
                        return;
                    }

                    User currentUser = (User) session.getAttribute("user");
                    int staffEmployeeId = (currentUser != null && currentUser.getActorId() > 0) ? currentUser.getActorId() : 0;

                    boolean success = appointmentDAO.completeAppointmentByStaff(apptId, staffEmployeeId, paymentGateway);
                    if (success) {
                        session.setAttribute("successMessage", "Đã xác nhận thanh toán thành công và cập nhật hoàn thành cho bệnh nhân (#APT-" + apptId + ").");
                    } else {
                        session.setAttribute("errorMessage", "Không thể xác nhận hoàn tất cho ca khám #APT-" + apptId);
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                    session.setAttribute("errorMessage", "Lỗi xác nhận hoàn tất: " + e.getMessage());
                }
            }
            String returnUrl = request.getParameter("returnUrl");
            if (returnUrl != null && !returnUrl.trim().isEmpty() && !returnUrl.contains(".jsp")) {
                response.sendRedirect(returnUrl);
            } else {
                response.sendRedirect(request.getContextPath() + "/staff/appointments");
            }
            return;
        }

        if ("checkin".equalsIgnoreCase(action)) {
            String apptIdParam = request.getParameter("appointmentId");
            if (apptIdParam != null && !apptIdParam.trim().isEmpty()) {
                try {
                    int apptId = Integer.parseInt(apptIdParam.trim());
                    Appointment ticket = appointmentDAO.getAppointmentById(apptId);
                    if (ticket != null && ticket.isPast()) {
                        session.setAttribute("errorMessage", "Lịch hẹn (#APT-" + apptId + ") đã qua ngày khám (" + ticket.getAppointmentDate() + "). Chỉ có thể xem thông tin và ghi chú y tế, không thể thực hiện tiếp đón!");
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
                        if (notes != null && !notes.trim().isEmpty()) {
                            appointmentDAO.saveMedicalNotes(apptId, ticket.getDoctorId(), notes);
                        }

                        ticket = appointmentDAO.getAppointmentById(apptId);
                        String patientName = (ticket != null && ticket.getPatientName() != null) ? ticket.getPatientName() : "bệnh nhân";
                        session.setAttribute("successMessage", "Tiếp đón " + patientName + " (#APT-" + apptId + ") thành công! Đã chuyển vào danh sách chờ khám.");
                        response.sendRedirect(request.getContextPath() + "/staff/waiting-list");
                        return;
                    } else {
                        session.setAttribute("errorMessage", "Không thể check-in lịch hẹn #" + apptId + ". Lịch phải được xác nhận thanh toán và chưa check-in.");
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
                        session.setAttribute("errorMessage", "Lịch hẹn (#APT-" + apptId + ") đã qua ngày khám (" + targetAppt.getAppointmentDate() + "), không thể thực hiện hủy lịch!");
                        String returnUrl = request.getParameter("returnUrl");
                        response.sendRedirect(returnUrl != null && !returnUrl.isEmpty() ? returnUrl : (request.getContextPath() + "/staff/appointments"));
                        return;
                    }

                    boolean success = appointmentDAO.cancelAppointment(apptId, reason.trim());
                    if (success) {
                        session.setAttribute("successMessage", "Đã hủy lịch hẹn (#APT-" + apptId + ") thành công! Ca khám của bác sĩ đã được giải phóng.");
                        response.sendRedirect(request.getContextPath() + "/staff/appointments?date=all&status=Canceled&keyword=" + apptId);
                        return;
                    } else {
                        session.setAttribute("errorMessage", "Không thể hủy lịch hẹn #" + apptId + ". Ca có thể đã được bác sĩ gọi vào khám hoặc đã hoàn tất; vui lòng tải lại danh sách.");
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                    session.setAttribute("errorMessage", "Lỗi khi hủy lịch hẹn: " + e.getMessage());
                }
            }
        } else if ("confirmWalkinPayment".equalsIgnoreCase(action)) {
            response.setContentType("application/json;charset=UTF-8");
            String apptIdStr = request.getParameter("appointmentId");
            String orderCodeStr2 = request.getParameter("orderCode");
            boolean success = false;
            String errorMsg = null;
            if (apptIdStr != null && !apptIdStr.trim().isEmpty()) {
                try {
                    int apptId = Integer.parseInt(apptIdStr.trim());

                    // Kiểm tra trạng thái thanh toán trên PayOS trước khi xác nhận thủ công
                    long orderCode2 = 0;
                    if (orderCodeStr2 != null && !orderCodeStr2.trim().isEmpty()) {
                        try { orderCode2 = Long.parseLong(orderCodeStr2.trim()); } catch (NumberFormatException ignored2) {}
                    }

                    // Thanh toán QR: xác nhận Paid/Confirmed, KHÔNG tự check-in
                    boolean shouldCheckin = false;

                    if (orderCode2 > 0) {
                        String payosStatus = com.visioncare.util.PayOSUtil.getPaymentStatus(orderCode2);
                        if ("PAID".equalsIgnoreCase(payosStatus)) {
                            // PayOS đã nhận được tiền -> xác nhận hợp lệ
                            User currentUser = (User) session.getAttribute("user");
                            int staffEmployeeId = (currentUser != null && currentUser.getActorId() > 0) ? currentUser.getActorId() : 0;
                            success = appointmentDAO.confirmAndCheckinWalkin(apptId, staffEmployeeId, shouldCheckin);
                        } else {
                            // Chưa nhận được tiền từ ngân hàng
                            errorMsg = "Chưa nhận được tiền từ ngân hàng (PayOS: " + payosStatus + "). Vui lòng đợi bệnh nhân quét mã và hoàn tất chuyển khoản!";
                        }
                    } else {
                        // Không có orderCode -> kiểm tra từ DB (trường hợp dự phòng)
                        Appointment apptCheck = appointmentDAO.getAppointmentDetailById(apptId);
                        if (apptCheck != null && "Paid".equalsIgnoreCase(apptCheck.getInvoiceStatus())) {
                            User currentUser = (User) session.getAttribute("user");
                            int staffEmployeeId = (currentUser != null && currentUser.getActorId() > 0) ? currentUser.getActorId() : 0;
                            success = appointmentDAO.confirmAndCheckinWalkin(apptId, staffEmployeeId, shouldCheckin);
                        } else {
                            errorMsg = "Không thể xác minh trạng thái thanh toán. Vui lòng đợi hệ thống tự động xác nhận sau khi bệnh nhân chuyển khoản!";
                        }
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                    errorMsg = "Lỗi khi xác nhận: " + e.getMessage();
                }
            }
            if (success) {
                response.getWriter().write("{\"success\":true}");
            } else {
                String safeMsg = errorMsg != null ? errorMsg.replace("\"", "'") : "Không thể xác nhận thanh toán.";
                response.getWriter().write("{\"success\":false,\"message\":\"" + safeMsg + "\"}");
            }
            return;
        } else if ("abortWalkinQR".equalsIgnoreCase(action) || "cancelWalkinQR".equalsIgnoreCase(action)) {
            response.setContentType("application/json;charset=UTF-8");
            String apptIdStr = request.getParameter("appointmentId");
            boolean success = false;
            String errorMsg = null;
            if (apptIdStr != null && !apptIdStr.trim().isEmpty()) {
                try {
                    int apptId = Integer.parseInt(apptIdStr.trim());
                    success = appointmentDAO.abortWalkinAppointment(apptId);
                } catch (Exception e) {
                    e.printStackTrace();
                    errorMsg = e.getMessage();
                }
            }
            if (success) {
                response.getWriter().write("{\"success\":true}");
            } else {
                String safeMsg = errorMsg != null ? errorMsg.replace("\"", "'") : "Không thể hủy lịch hẹn chưa thanh toán.";
                response.getWriter().write("{\"success\":false,\"message\":\"" + safeMsg + "\"}");
            }
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

            String cleanName = patientName != null ? patientName.trim() : "";
            if (cleanName.isEmpty() || cleanName.matches(".*\\d.*")) {
                if ("1".equals(request.getParameter("ajax"))) {
                    response.setContentType("application/json;charset=UTF-8");
                    response.getWriter().write("{\"success\":false,\"message\":\"Họ và tên bệnh nhân chỉ được nhập chữ, không được chứa chữ số!\"}");
                    return;
                }
                session.setAttribute("errorMessage", "Họ và tên bệnh nhân chỉ được nhập chữ, không được chứa chữ số!");
                response.sendRedirect(request.getContextPath() + "/staff/appointments");
                return;
            }

            if (!cleanName.matches("^[\\p{L}\\s'-]+$")) {
                if ("1".equals(request.getParameter("ajax"))) {
                    response.setContentType("application/json;charset=UTF-8");
                    response.getWriter().write("{\"success\":false,\"message\":\"Họ và tên bệnh nhân chỉ được chứa chữ cái, không được chứa ký tự đặc biệt!\"}");
                    return;
                }
                session.setAttribute("errorMessage", "Họ và tên bệnh nhân chỉ được chứa chữ cái, không được chứa ký tự đặc biệt!");
                response.sendRedirect(request.getContextPath() + "/staff/appointments");
                return;
            }

            if (phone == null || phone.trim().isEmpty() || doctorIdParam == null || doctorIdParam.trim().isEmpty()) {
                if ("1".equals(request.getParameter("ajax"))) {
                    response.setContentType("application/json;charset=UTF-8");
                    response.getWriter().write("{\"success\":false,\"message\":\"Vui lòng nhập đầy đủ số điện thoại và chọn bác sĩ tiếp đón!\"}");
                    return;
                }
                session.setAttribute("errorMessage", "Vui lòng nhập đầy đủ số điện thoại và chọn bác sĩ tiếp đón!");
            } else {
                try {
                    int doctorId = Integer.parseInt(doctorIdParam.trim());
                    Date today = Date.valueOf(LocalDate.now());

                    Date dob = null;
                    if (dobStr != null && !dobStr.trim().isEmpty()) {
                        String s = dobStr.trim();
                        int d = 0, m = 0, y = 0;
                        try {
                            if (s.contains("/")) {
                                String[] parts = s.split("/");
                                if (parts.length != 3) {
                                    throw new IllegalArgumentException("Định dạng ngày sinh phải là dd/mm/yyyy!");
                                }
                                d = Integer.parseInt(parts[0].trim());
                                m = Integer.parseInt(parts[1].trim());
                                y = Integer.parseInt(parts[2].trim());
                            } else if (s.contains("-")) {
                                String[] parts = s.split("-");
                                if (parts.length != 3) {
                                    throw new IllegalArgumentException("Định dạng ngày sinh phải là dd/mm/yyyy!");
                                }
                                y = Integer.parseInt(parts[0].trim());
                                m = Integer.parseInt(parts[1].trim());
                                d = Integer.parseInt(parts[2].trim());
                            } else {
                                throw new IllegalArgumentException("Định dạng ngày sinh không hợp lệ!");
                            }

                            int currentYear = LocalDate.now().getYear();
                            if (y < 1900) {
                                throw new IllegalArgumentException("Năm sinh không hợp lệ (phải từ năm 1900 trở lên)!");
                            }
                            if (y > currentYear) {
                                throw new IllegalArgumentException("Năm sinh không được vượt quá năm hiện tại (" + currentYear + ")!");
                            }
                            if (m < 1 || m > 12) {
                                throw new IllegalArgumentException("Tháng sinh không hợp lệ (1 năm chỉ có 12 tháng: 01 - 12)!");
                            }

                            int maxDaysInMonth;
                            switch (m) {
                                case 4: case 6: case 9: case 11:
                                    maxDaysInMonth = 30;
                                    break;
                                case 2:
                                    boolean isLeap = (y % 4 == 0 && y % 100 != 0) || (y % 400 == 0);
                                    maxDaysInMonth = isLeap ? 29 : 28;
                                    break;
                                default:
                                    maxDaysInMonth = 31;
                                    break;
                            }

                            if (d < 1 || d > maxDaysInMonth) {
                                throw new IllegalArgumentException("Tháng " + m + " năm " + y + " chỉ có tối đa " + maxDaysInMonth + " ngày!");
                            }

                            LocalDate parsedDate = LocalDate.of(y, m, d);
                            if (parsedDate.isAfter(LocalDate.now())) {
                                throw new IllegalArgumentException("Ngày sinh không được ở tương lai!");
                            }
                            dob = Date.valueOf(parsedDate);
                        } catch (IllegalArgumentException e) {
                            if ("1".equals(request.getParameter("ajax"))) {
                                response.setContentType("application/json;charset=UTF-8");
                                response.getWriter().write("{\"success\":false,\"message\":\"" + e.getMessage() + "\"}");
                                return;
                            }
                            session.setAttribute("errorMessage", e.getMessage());
                            response.sendRedirect(request.getContextPath() + "/staff/appointments");
                            return;
                        } catch (Exception e) {
                            if ("1".equals(request.getParameter("ajax"))) {
                                response.setContentType("application/json;charset=UTF-8");
                                response.getWriter().write("{\"success\":false,\"message\":\"Ngày sinh không hợp lệ! Vui lòng kiểm tra lại ngày, tháng, năm sinh.\"}");
                                return;
                            }
                            session.setAttribute("errorMessage", "Ngày sinh không hợp lệ!");
                            response.sendRedirect(request.getContextPath() + "/staff/appointments");
                            return;
                        }
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
                    paymentMethod = paymentMethod != null && !paymentMethod.isBlank() ? com.visioncare.util.PaymentMethod.canonical(paymentMethod) : "Cash";
                    appt.setPayment(paymentMethod);

                    User currentUser = (User) session.getAttribute("user");
                    int staffEmployeeId = (currentUser != null && currentUser.getActorId() > 0) ? currentUser.getActorId() : 0;

                    boolean isPendingPayment = "QR_Banking".equalsIgnoreCase(paymentMethod);
                    int newApptId = appointmentDAO.createWalkinAppointment(appt, staffEmployeeId, isPendingPayment);

                    if (newApptId > 0) {
                        if (isPendingPayment) {
                            String phoneSafe = appt.getPhone() != null ? appt.getPhone() : "";
                            String paymentDesc = "VC" + newApptId + " " + phoneSafe;
                            String encodedDesc = URLEncoder.encode(paymentDesc, StandardCharsets.UTF_8);

                            String bankName = "Ngân hàng Quân Đội (MB Bank)";
                            String accountNumber = "0877757889";
                            String accountHolder = "NGUYEN DINH TRUNG";
                            String qrUrl = null;

                            long orderCodeFinal = 0;
                            try {
                                orderCodeFinal = ((long) newApptId * 1000000L) + (System.currentTimeMillis() / 1000L % 1000000L);
                                String baseUrl = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath();
                                String cancelUrl = baseUrl + "/staff/appointments";
                                String returnUrl = baseUrl + "/staff/appointments";
                                com.visioncare.util.PayOSUtil.PaymentLinkResult payosRes = com.visioncare.util.PayOSUtil.createPaymentLink(orderCodeFinal, (int) fee, "VC" + newApptId, cancelUrl, returnUrl);
                                if (payosRes != null && payosRes.success && payosRes.qrCode != null && !payosRes.qrCode.isEmpty()) {
                                    qrUrl = "https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=" + URLEncoder.encode(payosRes.qrCode, StandardCharsets.UTF_8);
                                }
                            } catch (Exception payosEx) {
                                payosEx.printStackTrace();
                            }

                            if (qrUrl == null || qrUrl.isEmpty()) {
                                qrUrl = "https://img.vietqr.io/image/MB-" + accountNumber + "-compact2.png?amount=" + fee + "&addInfo=" + encodedDesc + "&accountName=" + URLEncoder.encode(accountHolder, StandardCharsets.UTF_8);
                            }

                            String ajaxParam = request.getParameter("ajax");
                            String ajaxHeader = request.getHeader("X-Requested-With");
                            if ("1".equals(ajaxParam) || "XMLHttpRequest".equalsIgnoreCase(ajaxHeader)) {
                                response.setContentType("application/json;charset=UTF-8");
                                String json = "{"
                                        + "\"success\":true,"
                                        + "\"appointmentId\":" + newApptId + ","
                                        + "\"orderCode\":" + orderCodeFinal + ","
                                        + "\"patientName\":\"" + escapeJson(patientName.trim()) + "\","
                                        + "\"phone\":\"" + escapeJson(phone.trim()) + "\","
                                        + "\"fee\":" + fee + ","
                                        + "\"formattedFee\":\"" + String.format("%,d ₫", fee).replace(',', '.') + "\","
                                        + "\"paymentDesc\":\"" + escapeJson(paymentDesc) + "\","
                                        + "\"qrUrl\":\"" + escapeJson(qrUrl) + "\","
                                        + "\"bankName\":\"" + escapeJson(bankName) + "\","
                                        + "\"accountNumber\":\"" + escapeJson(accountNumber) + "\","
                                        + "\"accountHolder\":\"" + escapeJson(accountHolder) + "\""
                                        + "}";
                                response.getWriter().write(json);
                                return;
                            }
                        } else {
                            String ajaxParam = request.getParameter("ajax");
                            String ajaxHeader = request.getHeader("X-Requested-With");
                            if ("1".equals(ajaxParam) || "XMLHttpRequest".equalsIgnoreCase(ajaxHeader)) {
                                response.setContentType("application/json;charset=UTF-8");
                                String json = "{"
                                        + "\"success\":true,"
                                        + "\"appointmentId\":" + newApptId + ","
                                        + "\"paymentMethod\":\"Cash\","
                                        + "\"patientName\":\"" + escapeJson(patientName.trim()) + "\","
                                        + "\"phone\":\"" + escapeJson(phone.trim()) + "\","
                                        + "\"fee\":" + fee + ","
                                        + "\"formattedFee\":\"" + String.format("%,d ₫", fee).replace(',', '.') + "\","
                                        + "\"message\":\"Thu tiền mặt và tiếp đón thành công!\""
                                        + "}";
                                response.getWriter().write(json);
                                return;
                            }
                        }

                        if (isPendingPayment) {
                            session.setAttribute("successMessage", "Tạo lịch tiếp đón cho bệnh nhân: " + patientName.trim() + " (#APT-" + newApptId + ") thành công! Sau khi bệnh nhân thanh toán VietQR, lịch hẹn sẽ lưu ở Danh sách Lịch hẹn (vui lòng bấm Check-in khi bệnh nhân có mặt).");
                            response.sendRedirect(request.getContextPath() + "/staff/appointments?date=all&keyword=" + newApptId);
                        } else {
                            session.setAttribute("successMessage", "Tiếp đón khách vãng lai: " + patientName.trim() + " (#APT-" + newApptId + ") thành công! Bệnh nhân đã được đưa vào danh sách chờ khám.");
                            response.sendRedirect(request.getContextPath() + "/staff/waiting-list");
                        }
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
