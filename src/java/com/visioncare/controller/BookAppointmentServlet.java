package com.visioncare.controller;

import com.visioncare.dao.AppointmentDAO;
import com.visioncare.dao.CatalogDAO;
import com.visioncare.dao.DoctorDAO;
import com.visioncare.dao.WorkScheduleDAO;
import com.visioncare.model.Appointment;
import com.visioncare.model.CatalogService;
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
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.Date;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Controller xử lý toàn bộ quy trình Đặt Lịch Khám Online (End-to-End Booking Pipeline).
 * Luồng chạy được sắp xếp theo đúng thứ tự 5 màn hình tuần tự:
 *   [MÀN HÌNH 1]: Form Đặt lịch & Chọn Dịch vụ, Bác sĩ (handleDefaultBookingForm)
 *   [MÀN HÌNH 2]: Chọn Ngày & Khung giờ khám động AJAX (handleGetSlots)
 *   [MÀN HÌNH 3]: Thông tin người khám & Submit tạo lịch (handleCreatePendingAppointmentPost)
 *   [MÀN HÌNH 4]: Thanh toán VietQR & Giữ chỗ 15 phút (handlePaymentView, checkPayment, confirmPayment)
 *   [MÀN HÌNH 5]: Vé khám điện tử & Gửi Email thành công (handleSuccessView)
 */
@WebServlet(name = "BookAppointmentServlet", urlPatterns = {"/book-appointment"})
public class BookAppointmentServlet extends HttpServlet {

    private final DoctorDAO doctorDAO = new DoctorDAO();
    private final CatalogDAO catalogDAO = new CatalogDAO();
    private final WorkScheduleDAO workScheduleDAO = new WorkScheduleDAO();
    private final AppointmentDAO appointmentDAO = new AppointmentDAO();

    /* =========================================================================
     * CHỐT CHẶN BẢO MẬT: KIỂM TRA QUYỀN SỞ HỮU LỊCH HẸN (CHỐNG IDOR / BOLA)
     * ========================================================================= */
    private boolean ownsAppointment(HttpServletRequest request, HttpServletResponse response, String raw) throws IOException {
        User user = (User) request.getSession().getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return false;
        }
        try {
            Appointment appointment = appointmentDAO.getAppointmentDetailById(Integer.parseInt(raw));
            if (appointment == null || appointment.getUserId() != user.getId()) {
                response.sendError(403);
                return false;
            }
            return true;
        } catch (NumberFormatException e) {
            response.sendError(400);
            return false;
        } catch (Exception e) {
            response.sendError(500, "Không kiểm tra được lịch hẹn.");
            return false;
        }
    }

    /* =========================================================================
     * HTTP GET: ĐIỀU HƯỚNG CÁC GIAI ĐOẠN ĐẶT LỊCH (THEO THỨ TỰ TRẢI NGHIỆM NGƯỜI DÙNG)
     * ========================================================================= */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        String requestedStep = request.getParameter("step");

        // Bảo vệ các hành động gắn với lịch hẹn cụ thể
        if ("checkPayment".equalsIgnoreCase(action) || "cancelPending".equalsIgnoreCase(action)
                || "payment".equalsIgnoreCase(requestedStep) || "success".equalsIgnoreCase(requestedStep)) {
            String target = "checkPayment".equalsIgnoreCase(action) ? request.getParameter("appointmentId") : request.getParameter("id");
            if (!ownsAppointment(request, response, target)) return;
        }

        // ---------------------------------------------------------------------
        // BƯỚC 1: AJAX LẤY KHUNG GIỜ THEO BÁC SĨ & NGÀY (action = "getSlots")
        // ---------------------------------------------------------------------
        if ("getSlots".equalsIgnoreCase(action)) {
            handleGetSlots(request, response);
            return;
        }

        // ---------------------------------------------------------------------
        // BƯỚC 2: MÀN HÌNH THANH TOÁN VIETQR & GIỮ CHỖ 15 PHÚT (step = "payment")
        // ---------------------------------------------------------------------
        if ("payment".equalsIgnoreCase(requestedStep)) {
            handlePaymentView(request, response);
            return;
        }

        // ---------------------------------------------------------------------
        // BƯỚC 3: AJAX POLLING KIỂM TRA TRẠNG THÁI THANH TOÁN (action = "checkPayment")
        // ---------------------------------------------------------------------
        if ("checkPayment".equalsIgnoreCase(action)) {
            handleCheckPayment(request, response);
            return;
        }

        // ---------------------------------------------------------------------
        // BƯỚC 4: HỦY GIỮ CHỖ KHI ĐANG THANH TOÁN (action = "cancelPending")
        // ---------------------------------------------------------------------
        if ("cancelPending".equalsIgnoreCase(action)) {
            handleCancelPending(request, response);
            return;
        }

        // ---------------------------------------------------------------------
        // BƯỚC 5: MÀN HÌNH THÀNH CÔNG & XUẤT VÉ KHÁM (step = "success")
        // ---------------------------------------------------------------------
        if ("success".equalsIgnoreCase(requestedStep)) {
            handleSuccessView(request, response);
            return;
        }

        // ---------------------------------------------------------------------
        // BƯỚC 0 (MẶC ĐỊNH): MÀN HÌNH FORM ĐẶT LỊCH (step = "form")
        // ---------------------------------------------------------------------
        handleDefaultBookingForm(request, response);
    }

    /* =========================================================================
     * HTTP POST: XỬ LÝ SUBMIT ĐẶT LỊCH & XÁC NHẬN THANH TOÁN
     * ========================================================================= */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        // Bắt buộc bệnh nhân phải đăng nhập để thực hiện đặt lịch
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null) {
            if (session == null) {
                session = request.getSession(true);
            }
            session.setAttribute("redirectAfterLogin", request.getContextPath() + "/book-appointment");
            session.setAttribute("infoMsg", "Vui lòng đăng nhập để thực hiện đặt lịch khám mắt.");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");

        // ---------------------------------------------------------------------
        // NHÁNH A: BỆNH NHÂN BẤM "XÁC NHẬN TÔI ĐÃ THANH TOÁN" (action = "confirmPayment")
        // ---------------------------------------------------------------------
        if ("confirmPayment".equalsIgnoreCase(action)) {
            handleConfirmPaymentPost(request, response);
            return;
        }

        // ---------------------------------------------------------------------
        // NHÁNH B (MẶC ĐỊNH): BỆNH NHÂN BẤM "XÁC NHẬN LỊCH HẸN" (SUBMIT FORM ĐẶT LỊCH)
        // ---------------------------------------------------------------------
        handleCreatePendingAppointmentPost(request, response, user);
    }

    /* =========================================================================
     * [MÀN HÌNH 1]: FORM ĐẶT LỊCH — CHỌN DỊCH VỤ & BÁC SĨ (step = "form")
     * ========================================================================= */
    private void handleDefaultBookingForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Bắt buộc bệnh nhân phải đăng nhập để đặt lịch khám
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null) {
            String query = request.getQueryString();
            String redirectUrl = request.getContextPath() + "/book-appointment" + (query != null && !query.isEmpty() ? "?" + query : "");
            if (session == null) {
                session = request.getSession(true);
            }
            session.setAttribute("redirectAfterLogin", redirectUrl);
            session.setAttribute("infoMsg", "Vui lòng đăng nhập để thực hiện đặt lịch khám mắt.");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Tải trang đặt lịch thông thường
        try {
            prepareFormData(request);

            // Xử lý params truyền vào từ trang khác (vd: trang bác sĩ, dịch vụ)
            String docParam = request.getParameter("doc");
            String serviceParam = request.getParameter("serviceId");
            @SuppressWarnings("unchecked")
            List<CatalogService> services = (List<CatalogService>) request.getAttribute("services");
            @SuppressWarnings("unchecked")
            List<Doctor> doctors = (List<Doctor>) request.getAttribute("doctors");

            if (docParam != null && !docParam.isEmpty()) {
                request.setAttribute("selectedDoctorId", docParam);
                // Nếu chưa có serviceId, tự động tìm dịch vụ tương ứng với chuyên khoa của bác sĩ này
                if (serviceParam == null || serviceParam.isEmpty()) {
                    try {
                        int dId = Integer.parseInt(docParam);
                        Doctor targetDoc = null;
                        if (doctors != null) {
                            for (Doctor d : doctors) {
                                if (d.getId() == dId) { targetDoc = d; break; }
                            }
                        }
                        if (targetDoc != null && services != null) {
                            for (CatalogService cs : services) {
                                if (cs.getSpecialty() != null && (cs.getSpecialty().equalsIgnoreCase(targetDoc.getDepartmentKey()) ||
                                    (targetDoc.getSpecialty() != null && targetDoc.getSpecialty().toLowerCase().contains(cs.getSpecialty().toLowerCase())))) {
                                    request.setAttribute("selectedServiceId", String.valueOf(cs.getId()));
                                    break;
                                }
                            }
                        }
                    } catch (Exception ignored) {}
                }
            }

            if (serviceParam != null && !serviceParam.isEmpty()) {
                String effectiveServiceParam = serviceParam;
                try {
                    int sId = Integer.parseInt(serviceParam);
                    CatalogService requestedSvc = catalogDAO.getService(sId);
                    if (requestedSvc != null && !requestedSvc.isAllowDirectBooking()) {
                        if (requestedSvc.isRequiresPreOp() && requestedSvc.getPrerequisiteServiceId() != null && requestedSvc.getPrerequisiteServiceId() > 0) {
                            effectiveServiceParam = String.valueOf(requestedSvc.getPrerequisiteServiceId());
                            request.setAttribute("serviceNotice", "Gói '" + requestedSvc.getName() + "' bắt buộc phải khám tiền phẫu trước. Hệ thống đã tự động chuyển sang gói tiền phẫu: " + requestedSvc.getPrerequisiteServiceName() + ".");
                        } else {
                            effectiveServiceParam = null;
                            request.setAttribute("serviceNotice", "Dịch vụ '" + requestedSvc.getName() + "' chỉ tiếp nhận theo chỉ định trực tiếp từ Bác sĩ, không cho phép đặt lịch trực tiếp. Quý khách vui lòng chọn một gói khám lâm sàng bên dưới.");
                        }
                    }
                } catch (Exception ignored) {}

                if (effectiveServiceParam != null) {
                    request.setAttribute("selectedServiceId", effectiveServiceParam);
                }
                // Nếu chưa có doctorId, tự động tìm bác sĩ đầu tiên thuộc đúng chuyên khoa của dịch vụ này
                if (docParam == null || docParam.isEmpty()) {
                    try {
                        String sIdStr = (String) request.getAttribute("selectedServiceId");
                        int sId = (sIdStr != null && !sIdStr.isEmpty()) ? Integer.parseInt(sIdStr) : Integer.parseInt(serviceParam);
                        CatalogService targetSvc = null;
                        if (services != null) {
                            for (CatalogService cs : services) {
                                if (cs.getId() == sId) { targetSvc = cs; break; }
                            }
                        }
                        if (targetSvc != null && targetSvc.getSpecialty() != null && doctors != null) {
                            for (Doctor d : doctors) {
                                if (targetSvc.getSpecialty().equalsIgnoreCase(d.getDepartmentKey()) ||
                                    (d.getSpecialty() != null && d.getSpecialty().toLowerCase().contains(targetSvc.getSpecialty().toLowerCase()))) {
                                    request.setAttribute("selectedDoctorId", String.valueOf(d.getId()));
                                    break;
                                }
                            }
                        }
                    } catch (Exception ignored) {}
                }
            }

            String dateParam = request.getParameter("date");
            if (dateParam != null && !dateParam.isEmpty()) {
                request.setAttribute("selectedDate", dateParam);
            } else {
                // Mặc định ngày hôm nay
                request.setAttribute("selectedDate", LocalDate.now().toString());
            }
            String timeParam = request.getParameter("time");
            if (timeParam != null && !timeParam.isEmpty()) {
                request.setAttribute("selectedTime", timeParam);
            }

            request.setAttribute("step", "form");
            request.getRequestDispatcher("/views/appointment/book-appointment.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            request.getRequestDispatcher("/views/error/500.jsp").forward(request, response);
        }
    }

    /* =========================================================================
     * [MÀN HÌNH 2]: CHỌN NGÀY & KHUNG GIỜ KHÁM ĐỘNG AJAX (action = "getSlots")
     * ========================================================================= */
    private void handleGetSlots(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
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
            boolean bufferEnabled = com.visioncare.dao.TimeSlotDAO.isSessionEndBufferEnabled();

            StringBuilder json = new StringBuilder();
            json.append("{");
            json.append("\"shiftSummary\":\"").append(shift).append("\",");
            json.append("\"sessionEndBufferEnabled\":").append(bufferEnabled).append(",");
            json.append("\"slots\":[");
            for (int i = 0; i < slots.size(); i++) {
                TimeSlot s = slots.get(i);
                if (i > 0) json.append(",");
                json.append("{");
                json.append("\"id\":").append(s.getId()).append(",");
                json.append("\"slotName\":\"").append(escapeJson(s.getSlotName())).append("\",");
                json.append("\"startTime\":\"").append(escapeJson(s.getStartTime())).append("\",");
                json.append("\"endTime\":\"").append(escapeJson(s.getEndTime())).append("\",");
                json.append("\"session\":\"").append(escapeJson(s.getSession())).append("\",");
                json.append("\"isBooked\":").append(s.isBooked()).append(",");
                json.append("\"isPast\":").append(s.isPast());
                json.append("}");
            }
            json.append("]}");
            response.getWriter().write(json.toString());
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\":\"" + escapeJson(e.getMessage()) + "\"}");
        }
    }

    /* =========================================================================
     * [MÀN HÌNH 3]: THÔNG TIN NGƯỜI KHÁM & SUBMIT TẠO LỊCH (handleCreatePendingAppointmentPost)
     * ========================================================================= */
    private void handleCreatePendingAppointmentPost(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {
        try {
            Appointment appointment = new Appointment();
            appointment.setPatientName(trimOrNull(request.getParameter("patientName")));
            appointment.setPhone(trimOrNull(request.getParameter("patientPhone")));
            appointment.setEmail(trimOrNull(request.getParameter("patientEmail")));
            appointment.setReason(trimOrNull(request.getParameter("visitReason")));

            // Parse Dịch vụ khám
            String serviceIdStr = request.getParameter("serviceId");
            int serviceId = 0;
            if (serviceIdStr != null && !serviceIdStr.isEmpty()) {
                serviceId = Integer.parseInt(serviceIdStr);
                appointment.setServiceId(serviceId);
                try {
                    CatalogService cs = catalogDAO.getService(serviceId);
                    if (cs != null) {
                        appointment.setServiceName(cs.getName());
                    }
                } catch (Exception ignored) {}
            }

            // Parse Bác sĩ
            String doctorIdStr = request.getParameter("doctorId");
            int doctorId = 0;
            if (doctorIdStr != null && !doctorIdStr.isEmpty()) {
                doctorId = Integer.parseInt(doctorIdStr);
                appointment.setDoctorId(doctorId);
                try {
                    Doctor doc = doctorDAO.getById(doctorId);
                    if (doc != null) {
                        appointment.setDoctorName(doc.getFullName());
                        appointment.setDepartment(doc.getSpecialty());
                    }
                } catch (Exception ignored) {}
            }

            // Parse Ngày hẹn khám
            String dateStr = request.getParameter("appointmentDate");
            if (dateStr != null && !dateStr.isEmpty()) {
                appointment.setAppointmentDate(Date.valueOf(dateStr));
            }

            // Parse Ngày sinh
            String dobStr = request.getParameter("patientDob");
            if (dobStr != null && !dobStr.trim().isEmpty()) {
                dobStr = dobStr.trim();
                if (dobStr.matches("\\d{2}/\\d{2}/\\d{4}")) {
                    String[] parts = dobStr.split("/");
                    dobStr = parts[2] + "-" + parts[1] + "-" + parts[0];
                } else if (dobStr.matches("\\d{2}-\\d{2}-\\d{4}")) {
                    String[] parts = dobStr.split("-");
                    dobStr = parts[2] + "-" + parts[1] + "-" + parts[0];
                }
                appointment.setDob(Date.valueOf(dobStr));
            }

            // Parse Khung giờ & Schedule ID
            String timeSlot = request.getParameter("timeSlot");
            appointment.setTimeSlot(timeSlot);
            String scheduleIdStr = request.getParameter("scheduleId");
            if (scheduleIdStr != null && !scheduleIdStr.isEmpty()) {
                appointment.setScheduleId(Integer.parseInt(scheduleIdStr));
            }

            // Gán Account ID
            if (user != null) {
                appointment.setUserId(user.getId());
                if (appointment.getEmail() == null || appointment.getEmail().isEmpty()) {
                    appointment.setEmail(user.getEmail());
                }
            }

            // Validate dữ liệu form
            if (appointment.getPatientName() == null || appointment.getPatientName().isEmpty()) {
                request.setAttribute("error", "Vui lòng nhập họ và tên người khám.");
                repopulateAndForward(request, response, appointment);
                return;
            }
            if (appointment.getPhone() == null || !appointment.getPhone().matches("^0[3|5|7|8|9][0-9]{8}$")) {
                request.setAttribute("error", "Số điện thoại không hợp lệ (yêu cầu số điện thoại Việt Nam 10 chữ số).");
                repopulateAndForward(request, response, appointment);
                return;
            }
            if (appointment.getEmail() == null || !appointment.getEmail().matches("^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}$")) {
                request.setAttribute("error", "Vui lòng nhập địa chỉ email hợp lệ để nhận vé khám và lời nhắc.");
                repopulateAndForward(request, response, appointment);
                return;
            }
            if (appointment.getDoctorId() <= 0) {
                request.setAttribute("error", "Vui lòng chọn bác sĩ khám.");
                repopulateAndForward(request, response, appointment);
                return;
            }
            if (appointment.getAppointmentDate() == null) {
                request.setAttribute("error", "Vui lòng chọn ngày khám.");
                repopulateAndForward(request, response, appointment);
                return;
            }
            if (appointment.getTimeSlot() == null || appointment.getTimeSlot().isEmpty()) {
                request.setAttribute("error", "Vui lòng chọn khung giờ khám phù hợp.");
                repopulateAndForward(request, response, appointment);
                return;
            }

            // Kiểm tra thời gian thực: không cho đặt ngày giờ trong quá khứ
            LocalDate today = LocalDate.now();
            if (appointment.getAppointmentDate() != null) {
                LocalDate apptDate = appointment.getAppointmentDate().toLocalDate();
                if (apptDate.isBefore(today)) {
                    request.setAttribute("error", "Ngày khám này đã qua. Vui lòng chọn ngày khám trong tương lai.");
                    repopulateAndForward(request, response, appointment);
                    return;
                } else if (apptDate.isEqual(today) && appointment.getTimeSlot() != null) {
                    java.time.LocalTime now = java.time.LocalTime.now();
                    try {
                        String slotStr = appointment.getTimeSlot().trim();
                        if (slotStr.length() > 5) slotStr = slotStr.substring(0, 5);
                        java.time.LocalTime slotTime = java.time.LocalTime.parse(slotStr);
                        if (slotTime.isBefore(now)) {
                            request.setAttribute("error", "Khung giờ " + appointment.getTimeSlot() + " hôm nay đã trôi qua. Vui lòng chọn khung giờ khác.");
                            repopulateAndForward(request, response, appointment);
                            return;
                        }
                    } catch (Exception ignored) {}
                }
            }

            // Kiểm tra tính khả dụng của khung giờ
            boolean alreadyBooked = appointmentDAO.isSlotBooked(
                    appointment.getDoctorId(),
                    appointment.getAppointmentDate(),
                    appointment.getTimeSlot()
            );
            if (alreadyBooked) {
                request.setAttribute("error", "Khung giờ này vừa có người đặt hoặc không khả dụng. Vui lòng chọn khung giờ khác.");
                repopulateAndForward(request, response, appointment);
                return;
            }

            // Tạo lịch hẹn Pending và hóa đơn cọc
            CatalogService cs = null;
            if (serviceId > 0) {
                try {
                    cs = catalogDAO.getService(serviceId);
                    if (cs != null) {
                        if (!cs.isAllowDirectBooking()) {
                            request.setAttribute("error", "Dịch vụ '" + cs.getName() + "' chỉ tiếp nhận theo chỉ định trực tiếp từ Bác sĩ sau khi thăm khám, không cho phép đặt lịch trực tiếp trên Website.");
                            repopulateAndForward(request, response, appointment);
                            return;
                        }
                        appointment.setServiceName(cs.getName());
                    }
                } catch (Exception ignored) {}
            }
            long totalServicePrice = (cs != null && cs.getPrice() != null) ? cs.getPrice().longValue() : 200000;
            appointment.setTotalAmount(totalServicePrice);

            long fee = cs != null ? cs.getOnlineDepositFee() : 200000;
            long balanceDue = cs != null ? cs.getOnlineBalanceDue() : 0;
            appointment.setFee(fee);
            appointment.setBalanceDue(balanceDue);

            int newId = appointmentDAO.createPendingAppointment(appointment, serviceId, fee);

            if (newId <= 0) {
                request.setAttribute("error", "Khung giờ này không còn trống hoặc hệ thống đang bận. Vui lòng thử lại.");
                repopulateAndForward(request, response, appointment);
                return;
            }

            // Khởi tạo mã đơn và link PayOS VietQR
            String payosDesc = "VC" + newId;
            long orderCode = ((long) newId * 1000000L) + (System.currentTimeMillis() / 1000L % 1000000L);
            request.getSession().setAttribute("payos_order_" + newId, orderCode);

            String baseUrl = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath();
            String cancelUrl = baseUrl + "/book-appointment?action=cancelPending&id=" + newId;
            String returnUrl = baseUrl + "/book-appointment?step=success&id=" + newId;
            com.visioncare.util.PayOSUtil.PaymentLinkResult payosRes = com.visioncare.util.BookingPaymentSession.link(request.getSession(), newId, Math.toIntExact(fee), cancelUrl, returnUrl);

            String qrUrl = null;
            String payosCheckoutUrl = null;
            if (payosRes != null && payosRes.success) {
                payosCheckoutUrl = payosRes.checkoutUrl;
                request.setAttribute("payosCheckoutUrl", payosRes.checkoutUrl);
                request.setAttribute("isPayOSEnabled", true);
                if (payosRes.qrCode != null && !payosRes.qrCode.isEmpty()) {
                    qrUrl = "https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=" + URLEncoder.encode(payosRes.qrCode, StandardCharsets.UTF_8);
                }
            } else {
                request.setAttribute("isPayOSEnabled", false);
            }

            if (qrUrl == null || qrUrl.isEmpty()) {
                request.getSession().setAttribute("errorMessage", "Chưa tạo được QR từ cổng thanh toán. Vui lòng thử lại từ lịch sử hẹn khám; không chuyển tiền bằng QR cũ hoặc QR tĩnh.");
                response.sendRedirect(request.getContextPath() + "/views/profile/appointment-history.jsp");
                return;
            }

            Appointment fullAppt = appointmentDAO.getAppointmentDetailById(newId);
            if (fullAppt != null) {
                fullAppt.setEmail(appointment.getEmail());
            }

            // Chuyển sang Màn hình 3 (Payment)
            int pendingHoldMinutes = com.visioncare.dao.TimeSlotDAO.getPendingHoldMinutes();
            request.setAttribute("pendingHoldMinutes", pendingHoldMinutes);
            request.setAttribute("pendingHoldSeconds", pendingHoldMinutes * 60);
            request.setAttribute("step", "payment");
            request.setAttribute("appointment", fullAppt != null ? fullAppt : appointment);
            request.setAttribute("appointmentId", newId);
            request.setAttribute("orderCode", orderCode);
            request.setAttribute("qrUrl", qrUrl);
            request.setAttribute("payosCheckoutUrl", payosCheckoutUrl);
            request.setAttribute("fee", fee);
            request.setAttribute("paymentDesc", payosDesc);
            request.setAttribute("bankName", "Ngân hàng Quân Đội (MB Bank)");
            request.setAttribute("accountNumber", "0877757889");
            request.setAttribute("accountHolder", "NGUYEN DINH TRUNG");

            request.getRequestDispatcher("/views/appointment/book-appointment.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra trong quá trình đặt lịch: " + e.getMessage());
            doGet(request, response);
        }
    }

    /* =========================================================================
     * [MÀN HÌNH 4]: THANH TOÁN VIETQR & GIỮ CHỖ 15 PHÚT (step = "payment", checkPayment, confirmPayment)
     * ========================================================================= */
    private void handlePaymentView(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String apptIdParam = request.getParameter("id");
        if (apptIdParam == null || apptIdParam.isEmpty()) return;

        try {
            int apptId = Integer.parseInt(apptIdParam);
            Appointment pendingAppt = appointmentDAO.getAppointmentDetailById(apptId);
            if (pendingAppt != null) {
                if (pendingAppt.isDepositPaid()) {
                    response.sendRedirect(request.getContextPath() + "/book-appointment?step=success&id=" + apptId);
                    return;
                }
                if (!pendingAppt.isAwaitingPayment()) {
                    response.sendRedirect(request.getContextPath() + "/views/profile/appointment-history.jsp");
                    return;
                }
                String paymentError = (String) request.getSession().getAttribute("paymentError");
                if (paymentError != null) {
                    request.setAttribute("error", paymentError);
                    request.getSession().removeAttribute("paymentError");
                }

                long fee = pendingAppt.getFee() > 0 ? pendingAppt.getFee() : 200000;
                String payosDesc = "VC" + apptId;

                Long sessionOrder = (Long) request.getSession().getAttribute("payos_order_" + apptId);
                long orderCode = (sessionOrder != null) ? sessionOrder : (((long) apptId * 1000000L) + (System.currentTimeMillis() / 1000L % 1000000L));
                request.getSession().setAttribute("payos_order_" + apptId, orderCode);

                String baseUrl = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath();
                String cancelUrl = baseUrl + "/book-appointment?action=cancelPending&id=" + apptId;
                String returnUrl = baseUrl + "/book-appointment?step=success&id=" + apptId;
                com.visioncare.util.PayOSUtil.PaymentLinkResult payosRes = com.visioncare.util.BookingPaymentSession.link(request.getSession(), apptId, Math.toIntExact(fee), cancelUrl, returnUrl);

                String qrUrl = null;
                String payosCheckoutUrl = null;
                if (payosRes != null && payosRes.success) {
                    payosCheckoutUrl = payosRes.checkoutUrl;
                    request.setAttribute("payosCheckoutUrl", payosRes.checkoutUrl);
                    request.setAttribute("isPayOSEnabled", true);
                    if (payosRes.qrCode != null && !payosRes.qrCode.isEmpty()) {
                        qrUrl = "https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=" + URLEncoder.encode(payosRes.qrCode, StandardCharsets.UTF_8);
                    }
                } else {
                    request.setAttribute("isPayOSEnabled", false);
                }

                if (qrUrl == null || qrUrl.isEmpty()) {
                    request.getSession().setAttribute("errorMessage", "Chưa tạo được QR từ cổng thanh toán. Vui lòng thử lại từ lịch sử hẹn khám; không chuyển tiền bằng QR cũ hoặc QR tĩnh.");
                    response.sendRedirect(request.getContextPath() + "/views/profile/appointment-history.jsp");
                    return;
                }

                int pendingHoldMinutes = com.visioncare.dao.TimeSlotDAO.getPendingHoldMinutes();
                request.setAttribute("pendingHoldMinutes", pendingHoldMinutes);
                request.setAttribute("pendingHoldSeconds", pendingHoldMinutes * 60);
                request.setAttribute("step", "payment");
                request.setAttribute("appointment", pendingAppt);
                request.setAttribute("appointmentId", apptId);
                request.setAttribute("orderCode", orderCode);
                request.setAttribute("qrUrl", qrUrl);
                request.setAttribute("payosCheckoutUrl", payosCheckoutUrl);
                request.setAttribute("fee", fee);
                request.setAttribute("paymentDesc", payosDesc);
                request.setAttribute("bankName", "Ngân hàng Quân Đội (MB Bank)");
                request.setAttribute("accountNumber", "0877757889");
                request.setAttribute("accountHolder", "NGUYEN DINH TRUNG");
                request.getRequestDispatcher("/views/appointment/book-appointment.jsp").forward(request, response);
            }
        } catch (Exception ignored) {}
    }

    /* =========================================================================
     * [AJAX POLLING]: TỰ ĐỘNG KIỂM TRA TRẠNG THÁI THANH TOÁN TỪ PAYOS
     * ========================================================================= */
    private void handleCheckPayment(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        String apptIdStr = request.getParameter("appointmentId");
        String orderCodeStr = request.getParameter("orderCode");
        if (apptIdStr != null && !apptIdStr.isEmpty()) {
            try {
                int apptId = Integer.parseInt(apptIdStr);
                Appointment appt = appointmentDAO.getAppointmentDetailById(apptId);
                boolean isPaid = appt != null && appt.isDepositPaid();

                // Nếu DB chưa ghi nhận Paid, kiểm tra trực tiếp sang cổng PayOS
                if (!isPaid) {
                    long orderCode = 0;
                    if (orderCodeStr != null && !orderCodeStr.isEmpty()) {
                        try { orderCode = Long.parseLong(orderCodeStr); } catch (Exception ignored) {}
                    }
                    if (orderCode <= 0) {
                        Long sessionOrder = (Long) request.getSession().getAttribute("payos_order_" + apptId);
                        orderCode = (sessionOrder != null) ? sessionOrder : apptId;
                    }

                    com.visioncare.util.PayOSUtil.VerifiedReceipt receipt = com.visioncare.util.PayOSUtil.getVerifiedReceipt(orderCode);
                    if (com.visioncare.util.BookingPaymentSession.matches(apptId, orderCode, appt.getFee(), receipt)) {
                        if (!appointmentDAO.confirmPayment(apptId)) {
                            throw new IllegalStateException("Bác sĩ không còn làm việc trong khung giờ đã chọn hoặc lịch hẹn không còn hợp lệ. Nếu đã thanh toán, vui lòng liên hệ phòng khám để xử lý.");
                        }
                        isPaid = true;

                        // Tự động gửi email xác nhận đặt lịch & hướng dẫn đi khám
                        try {
                            String emailSentKey = "email_sent_appt_" + apptId;
                            if (request.getSession().getAttribute(emailSentKey) == null) {
                                request.getSession().setAttribute(emailSentKey, true);
                                Appointment fullAppt = appointmentDAO.getAppointmentDetailById(apptId);
                                String email = fullAppt != null ? fullAppt.getEmail() : null;
                                if (email == null || email.trim().isEmpty()) {
                                    User sessionUser = (User) request.getSession().getAttribute("user");
                                    if (sessionUser != null) email = sessionUser.getEmail();
                                }
                                if (email != null && !email.trim().isEmpty() && fullAppt != null) {
                                    EmailUtil.sendAppointmentConfirmationEmail(
                                            email.trim(),
                                            fullAppt.getPatientName(),
                                            fullAppt.getId(),
                                            fullAppt.getDoctorName() != null ? fullAppt.getDoctorName() : "Bác sĩ Chuyên khoa VisionCare",
                                            fullAppt.getDepartment() != null ? fullAppt.getDepartment() : "Khám chuyên khoa mắt",
                                            fullAppt.getAppointmentDate() != null ? fullAppt.getAppointmentDate().toString() : "",
                                            fullAppt.getTimeSlot() != null ? fullAppt.getTimeSlot() : "",
                                            fullAppt.getFee() > 0 ? fullAppt.getFee() : 200000
                                    );
                                }
                            }
                        } catch (Exception ex) {
                            System.err.println("[checkPayment] Lỗi gửi email xác nhận: " + ex.getMessage());
                        }
                    }
                }
                response.getWriter().write("{\"isPaid\":" + isPaid + "}");
                return;
            } catch (Exception e) {
                response.getWriter().write("{\"isPaid\":false,\"error\":\"" + escapeJson(e.getMessage()) + "\"}");
                return;
            }
        }
        response.getWriter().write("{\"isPaid\":false}");
    }

    /* =========================================================================
     * [XÁC NHẬN THANH TOÁN POST]: BỆNH NHÂN BẤM "XÁC NHẬN TÔI ĐÃ THANH TOÁN"
     * ========================================================================= */
    private void handleConfirmPaymentPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!ownsAppointment(request, response, request.getParameter("appointmentId"))) return;
        try {
            String apptIdStr = request.getParameter("appointmentId");
            if (apptIdStr == null || apptIdStr.isEmpty()) {
                request.setAttribute("error", "Không tìm thấy mã lịch hẹn cần xác nhận thanh toán.");
                doGet(request, response);
                return;
            }
            int appointmentId = Integer.parseInt(apptIdStr);

            long orderCode = 0;
            String orderCodeStr = request.getParameter("orderCode");
            if (orderCodeStr != null && !orderCodeStr.isEmpty()) {
                try { orderCode = Long.parseLong(orderCodeStr); } catch (Exception ignored) {}
            }
            if (orderCode <= 0) {
                Long sessionOrder = (Long) request.getSession().getAttribute("payos_order_" + appointmentId);
                orderCode = (sessionOrder != null) ? sessionOrder : appointmentId;
            }

            // Kiểm tra trạng thái thanh toán từ cổng PayOS
            Appointment paymentAppointment = appointmentDAO.getAppointmentDetailById(appointmentId);
            com.visioncare.util.PayOSUtil.VerifiedReceipt receipt = com.visioncare.util.PayOSUtil.getVerifiedReceipt(orderCode);

            // Nếu chưa thanh toán thành công trên cổng ngân hàng/PayOS, không cho xác nhận
            if (paymentAppointment == null || !com.visioncare.util.BookingPaymentSession.matches(appointmentId, orderCode, paymentAppointment.getFee(), receipt)) {
                request.getSession().setAttribute("paymentError", "Hệ thống chưa ghi nhận được thanh toán từ ngân hàng (Trạng thái đơn: Chưa thanh toán). Quý khách vui lòng quét mã QR chuyển khoản và chờ hệ thống xử lý trong ít giây!");
                response.sendRedirect(request.getContextPath() + "/book-appointment?step=payment&id=" + appointmentId);
                return;
            }

            // Xác nhận thanh toán thành công vào DB (UPDLOCK, HOLDLOCK)
            if (!appointmentDAO.confirmPayment(appointmentId)) {
                throw new IllegalStateException("Bác sĩ không còn làm việc trong khung giờ đã chọn hoặc lịch hẹn không còn hợp lệ. Nếu đã thanh toán, vui lòng liên hệ phòng khám để xử lý.");
            }

            // Gửi email xác nhận & hướng dẫn chuẩn bị đi khám tới bệnh nhân
            Appointment fullAppt = appointmentDAO.getAppointmentDetailById(appointmentId);
            String email = request.getParameter("email");
            if (email == null || email.trim().isEmpty()) {
                if (fullAppt != null) email = fullAppt.getEmail();
            }

            if (email != null && !email.trim().isEmpty() && fullAppt != null) {
                EmailUtil.sendAppointmentConfirmationEmail(
                        email.trim(),
                        fullAppt.getPatientName(),
                        fullAppt.getId(),
                        fullAppt.getDoctorName() != null ? fullAppt.getDoctorName() : "Bác sĩ Chuyên khoa VisionCare",
                        fullAppt.getDepartment() != null ? fullAppt.getDepartment() : "Khám chuyên khoa mắt",
                        fullAppt.getAppointmentDate() != null ? fullAppt.getAppointmentDate().toString() : "",
                        fullAppt.getTimeSlot() != null ? fullAppt.getTimeSlot() : "",
                        fullAppt.getFee() > 0 ? fullAppt.getFee() : 200000
                );
            }

            // Forward sang Màn hình 4 (Success)
            request.setAttribute("step", "success");
            request.setAttribute("appointment", fullAppt);
            request.getRequestDispatcher("/views/appointment/book-appointment.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi trong quá trình xác nhận thanh toán: " + e.getMessage());
            doGet(request, response);
        }
    }

    /* =========================================================================
     * [HỦY GIỮ CHỖ]: BỆNH NHÂN HỦY LỊCH PENDING ĐỂ CHỌN LẠI LỊCH KHÁC
     * ========================================================================= */
    private void handleCancelPending(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String apptIdStr = request.getParameter("id");
        if (apptIdStr != null && !apptIdStr.isEmpty()) {
            try {
                int apptId = Integer.parseInt(apptIdStr);
                appointmentDAO.cancelAppointment(apptId, "Bệnh nhân hủy trước khi thanh toán để chọn lịch khác");
            } catch (Exception ignored) {}
        }
        if ("XMLHttpRequest".equals(request.getHeader("X-Requested-With")) || "json".equalsIgnoreCase(request.getParameter("format"))) {
            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().write("{\"success\":true}");
            return;
        }
        response.sendRedirect(request.getContextPath() + "/book-appointment");
    }

    /* =========================================================================
     * [MÀN HÌNH 5]: THÀNH CÔNG, VÉ KHÁM ĐIỆN TỬ & GỬI EMAIL (step = "success")
     * ========================================================================= */
    private void handleSuccessView(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String apptIdParam = request.getParameter("id");
        if (apptIdParam == null || apptIdParam.isEmpty()) return;

        try {
            int apptId = Integer.parseInt(apptIdParam);
            Appointment fullAppt = appointmentDAO.getAppointmentDetailById(apptId);
            if (fullAppt != null) {
                if (!fullAppt.isDepositPaid()) {
                    response.sendRedirect(request.getContextPath() + "/book-appointment?step=payment&id=" + apptId);
                    return;
                }
                // Gửi email dự phòng nếu luồng trước chưa kịp gửi
                try {
                    String emailSentKey = "email_sent_appt_" + apptId;
                    if (request.getSession().getAttribute(emailSentKey) == null) {
                        request.getSession().setAttribute(emailSentKey, true);
                        String email = fullAppt.getEmail();
                        if (email == null || email.trim().isEmpty()) {
                            User sessionUser = (User) request.getSession().getAttribute("user");
                            if (sessionUser != null) email = sessionUser.getEmail();
                        }
                        if (email != null && !email.trim().isEmpty()) {
                            EmailUtil.sendAppointmentConfirmationEmail(
                                    email.trim(),
                                    fullAppt.getPatientName(),
                                    fullAppt.getId(),
                                    fullAppt.getDoctorName() != null ? fullAppt.getDoctorName() : "Bác sĩ Chuyên khoa VisionCare",
                                    fullAppt.getDepartment() != null ? fullAppt.getDepartment() : "Khám chuyên khoa mắt",
                                    fullAppt.getAppointmentDate() != null ? fullAppt.getAppointmentDate().toString() : "",
                                    fullAppt.getTimeSlot() != null ? fullAppt.getTimeSlot() : "",
                                    fullAppt.getFee() > 0 ? fullAppt.getFee() : 200000
                            );
                        }
                    }
                } catch (Exception ex) {
                    System.err.println("[step=success] Lỗi gửi email xác nhận: " + ex.getMessage());
                }

                request.setAttribute("step", "success");
                request.setAttribute("appointment", fullAppt);
                request.getRequestDispatcher("/views/appointment/book-appointment.jsp").forward(request, response);
            }
        } catch (Exception ignored) {}
    }

    /* =========================================================================
     * CÁC HÀM TIỆN ÍCH HỖ TRỢ (HELPER METHODS)
     * ========================================================================= */
    private void prepareFormData(HttpServletRequest request) throws Exception {
        // Chỉ tải các dịch vụ cho phép bệnh nhân đặt lịch trực tiếp trên Website (Allow_Direct_Booking = 1)
        List<CatalogService> allServices = catalogDAO.listBookableServices();
        request.setAttribute("services", allServices);

        // Tải danh sách bác sĩ từ Database
        List<Doctor> doctors = doctorDAO.getAll();
        request.setAttribute("doctors", doctors);

        // Pre-load lịch làm việc 7 ngày tới để client-side filter bác sĩ theo ngày 
        String today = LocalDate.now().toString();
        String weekEnd = LocalDate.now().plusDays(6).toString();
        Map<String, Set<Integer>> scheduleMap = workScheduleDAO.getDoctorWorkingDays(today, weekEnd);
        StringBuilder scheduleJson = new StringBuilder("{");
        boolean firstDate = true;
        for (Map.Entry<String, Set<Integer>> entry : scheduleMap.entrySet()) {
            if (!firstDate) scheduleJson.append(",");
            firstDate = false;
            scheduleJson.append("\"").append(entry.getKey()).append("\":[");
            boolean firstId = true;
            for (Integer docId : entry.getValue()) {
                if (!firstId) scheduleJson.append(",");
                firstId = false;
                scheduleJson.append(docId);
            }
            scheduleJson.append("]");
        }
        scheduleJson.append("}");
        request.setAttribute("doctorScheduleMapJson", scheduleJson.toString());
        request.setAttribute("sessionEndBufferEnabled", com.visioncare.dao.TimeSlotDAO.isSessionEndBufferEnabled());

        // Tự động điền thông tin nếu bệnh nhân đã đăng nhập
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            User loggedUser = (User) session.getAttribute("user");
            request.setAttribute("loggedUser", loggedUser);
        }
    }

    private void repopulateAndForward(HttpServletRequest request, HttpServletResponse response, Appointment a) throws Exception {
        prepareFormData(request);
        request.setAttribute("appointment", a);
        request.setAttribute("selectedServiceId", a.getServiceId());
        request.setAttribute("selectedDoctorId", a.getDoctorId());
        request.setAttribute("selectedDate", a.getAppointmentDate() != null ? a.getAppointmentDate().toString() : "");
        request.setAttribute("selectedTime", a.getTimeSlot());
        request.setAttribute("step", "form");
        request.getRequestDispatcher("/views/appointment/book-appointment.jsp").forward(request, response);
    }

    private String trimOrNull(String s) {
        if (s == null) return null;
        String t = s.trim();
        return t.isEmpty() ? null : t;
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "");
    }
}
