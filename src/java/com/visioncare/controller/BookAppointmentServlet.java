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

@WebServlet(name = "BookAppointmentServlet", urlPatterns = {"/book-appointment"})
public class BookAppointmentServlet extends HttpServlet {

    private final DoctorDAO doctorDAO = new DoctorDAO();
    private final CatalogDAO catalogDAO = new CatalogDAO();
    private final WorkScheduleDAO workScheduleDAO = new WorkScheduleDAO();
    private final AppointmentDAO appointmentDAO = new AppointmentDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        // AJAX: Lấy khung giờ động theo Bác sĩ & Ngày (bỏ hoàn toàn ca tối)
        if ("getSlots".equalsIgnoreCase(action)) {
            response.setContentType("application/json;charset=UTF-8");
            try {
                String docIdStr = request.getParameter("doctorId");
                String dateStr = request.getParameter("date");
                if (docIdStr == null || docIdStr.isEmpty() || dateStr == null || dateStr.isEmpty()) {
                    response.getWriter().write("{\"shiftSummary\":\"OFF\",\"slots\":[]}");
                    return;
                }
                int doctorId = Integer.parseInt(docIdStr);
                List<TimeSlot> slots = workScheduleDAO.getDoctorSlotsForDate(doctorId, dateStr);
                String shift = workScheduleDAO.getDoctorWorkShiftSummary(doctorId, dateStr);

                StringBuilder json = new StringBuilder();
                json.append("{");
                json.append("\"shiftSummary\":\"").append(shift).append("\",");
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
                    json.append("\"isBooked\":").append(s.isBooked());
                    json.append("}");
                }
                json.append("]}");
                response.getWriter().write(json.toString());
                return;
            } catch (Exception e) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"error\":\"" + escapeJson(e.getMessage()) + "\"}");
                return;
            }
        }

        // Tải trang đặt lịch thông thường
        try {
            prepareFormData(request);

            // Xử lý params truyền vào từ trang khác (vd: trang bác sĩ, dịch vụ)
            String docParam = request.getParameter("doc");
            if (docParam != null && !docParam.isEmpty()) {
                request.setAttribute("selectedDoctorId", docParam);
            }
            String serviceParam = request.getParameter("serviceId");
            if (serviceParam != null && !serviceParam.isEmpty()) {
                request.setAttribute("selectedServiceId", serviceParam);
            }
            String dateParam = request.getParameter("date");
            if (dateParam != null && !dateParam.isEmpty()) {
                request.setAttribute("selectedDate", dateParam);
            } else {
                // Mặc định ngày mai hoặc hôm nay
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

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        // BƯỚC 2: Bệnh nhân quét mã QR và nhấn "Xác nhận tôi đã thanh toán (Verify Payment)"
        if ("confirmPayment".equalsIgnoreCase(action)) {
            try {
                String apptIdStr = request.getParameter("appointmentId");
                if (apptIdStr == null || apptIdStr.isEmpty()) {
                    request.setAttribute("error", "Không tìm thấy mã lịch hẹn cần xác nhận thanh toán.");
                    doGet(request, response);
                    return;
                }
                int appointmentId = Integer.parseInt(apptIdStr);

                // Cập nhật hóa đơn -> Paid, tạo Payment_Transaction, Confirmed lịch hẹn & Booked ca trực
                appointmentDAO.confirmPayment(appointmentId);

                // Lấy thông tin lịch hẹn đầy đủ sau khi đã thanh toán
                Appointment fullAppt = appointmentDAO.getAppointmentDetailById(appointmentId);
                String email = request.getParameter("email");
                if (email == null || email.trim().isEmpty()) {
                    if (fullAppt != null) email = fullAppt.getEmail();
                }

                // Gửi email xác nhận & hướng dẫn chuẩn bị đi khám tới bệnh nhân
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

                request.setAttribute("step", "success");
                request.setAttribute("appointment", fullAppt);
                request.getRequestDispatcher("/views/appointment/book-appointment.jsp").forward(request, response);
                return;
            } catch (Exception e) {
                e.printStackTrace();
                request.setAttribute("error", "Lỗi trong quá trình xác nhận thanh toán: " + e.getMessage());
                doGet(request, response);
                return;
            }
        }

        // BƯỚC 1: Bệnh nhân nhấn "Xác nhận lịch hẹn (Verify Appointment)"
        try {
            Appointment appointment = new Appointment();
            appointment.setPatientName(trimOrNull(request.getParameter("patientName")));
            appointment.setPhone(trimOrNull(request.getParameter("patientPhone")));
            appointment.setEmail(trimOrNull(request.getParameter("patientEmail")));
            appointment.setReason(trimOrNull(request.getParameter("visitReason")));

            // Parse Bệnh lý / Dịch vụ khám từ DB
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

            // Parse Bác sĩ từ DB
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

            // Gán Account ID nếu bệnh nhân đã đăng nhập
            HttpSession session = request.getSession(false);
            if (session != null && session.getAttribute("user") != null) {
                User user = (User) session.getAttribute("user");
                appointment.setUserId(user.getId());
                if (appointment.getEmail() == null || appointment.getEmail().isEmpty()) {
                    appointment.setEmail(user.getEmail());
                }
            }

            // VALIDATE THÔNG TIN (Verify Appointment Info)
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

            // KIỂM TRA TÍNH KHẢ DỤNG CỦA KHUNG GIỜ (Check slot availability)
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

            // TẠO LỊCH HẸN PENDING VÀ HÓA ĐƠN PENDING DEPOSIT
            long fee = 200000; // Phí khám ban đầu theo tiêu chuẩn phòng khám
            appointment.setFee(fee);
            int newId = appointmentDAO.createPendingAppointment(appointment, serviceId, fee);

            if (newId <= 0) {
                request.setAttribute("error", "Khung giờ này không còn trống hoặc hệ thống đang bận. Vui lòng thử lại.");
                repopulateAndForward(request, response, appointment);
                return;
            }

            // TẠO MÃ QR THANH TOÁN ĐỘNG (Dynamic VietQR Code)
            String phoneSafe = appointment.getPhone() != null ? appointment.getPhone() : "";
            String paymentDesc = "VC" + newId + " " + phoneSafe;
            String encodedDesc = URLEncoder.encode(paymentDesc, StandardCharsets.UTF_8);
            String qrUrl = "https://img.vietqr.io/image/MB-0335889999-compact2.png?amount=" + fee + "&addInfo=" + encodedDesc + "&accountName=PHONG%20KHAM%20MAT%20VISIONCARE";

            Appointment fullAppt = appointmentDAO.getAppointmentDetailById(newId);
            if (fullAppt != null) {
                fullAppt.setEmail(appointment.getEmail());
            }

            request.setAttribute("step", "payment");
            request.setAttribute("appointment", fullAppt != null ? fullAppt : appointment);
            request.setAttribute("appointmentId", newId);
            request.setAttribute("qrUrl", qrUrl);
            request.setAttribute("fee", fee);
            request.setAttribute("paymentDesc", paymentDesc);
            request.setAttribute("bankName", "Ngân hàng Quân Đội (MB Bank)");
            request.setAttribute("accountNumber", "0335889999");
            request.setAttribute("accountHolder", "PHONG KHAM MAT VISIONCARE");

            request.getRequestDispatcher("/views/appointment/book-appointment.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra trong quá trình đặt lịch: " + e.getMessage());
            doGet(request, response);
        }
    }

    private void prepareFormData(HttpServletRequest request) throws Exception {
        // Tải danh mục bệnh lý / dịch vụ hoàn toàn từ Database (Service_Catalog)
        List<CatalogService> services = catalogDAO.listServices();
        request.setAttribute("services", services);

        // Tải danh sách bác sĩ hoàn toàn từ Database (Employee_Profile)
        List<Doctor> doctors = doctorDAO.getAll();
        request.setAttribute("doctors", doctors);

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
