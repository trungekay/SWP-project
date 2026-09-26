package com.visioncare.controller;

import com.visioncare.dao.AppointmentDAO;
import com.visioncare.dao.DoctorDAO;
import com.visioncare.dao.DepartmentDAO;
import com.visioncare.model.Appointment;
import com.visioncare.model.Doctor;
import com.visioncare.model.Department;
import com.visioncare.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Date;
import java.util.List;

/**
 * Servlet xử lý form đặt lịch khám mắt (wizard 3 bước).
 * GET  → hiển thị form
 * POST → xử lý đặt lịch
 * URL: /book-appointment
 */
@WebServlet(name = "BookAppointmentServlet", urlPatterns = {"/book-appointment"})
public class BookAppointmentServlet extends HttpServlet {

    private final DoctorDAO doctorDAO = new DoctorDAO();
    private final DepartmentDAO departmentDAO = new DepartmentDAO();
    private final AppointmentDAO appointmentDAO = new AppointmentDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Lấy danh sách bác sĩ và chuyên khoa cho form
            /*
            List<Doctor> doctors = doctorDAO.getAll();
            List<Department> departments = departmentDAO.getAll();
            request.setAttribute("doctors", doctors);
            request.setAttribute("departments", departments);
            */
            
            request.setAttribute("doctors", new java.util.ArrayList<Doctor>());
            request.setAttribute("departments", new java.util.ArrayList<Department>());

            // Nếu có tham số doc (từ trang doctor-schedules)
            String docParam = request.getParameter("doc");
            if (docParam != null) {
                request.setAttribute("selectedDoctor", docParam);
            }
            String timeParam = request.getParameter("time");
            if (timeParam != null) {
                request.setAttribute("selectedTime", timeParam);
            }

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
        try {
            // Thu thập dữ liệu từ form
            Appointment appointment = new Appointment();
            appointment.setPatientName(request.getParameter("patientName"));
            appointment.setPhone(request.getParameter("patientPhone"));
            appointment.setEmail(request.getParameter("patientEmail"));
            appointment.setDepartment(request.getParameter("department"));
            appointment.setPayment(request.getParameter("payment"));
            appointment.setReason(request.getParameter("visitReason"));
            appointment.setStatus("pending");

            // Parse doctor ID
            String doctorIdStr = request.getParameter("doctorId");
            if (doctorIdStr != null && !doctorIdStr.isEmpty()) {
                appointment.setDoctorId(Integer.parseInt(doctorIdStr));
            }

            // Parse dates
            String dateStr = request.getParameter("appointmentDate");
            if (dateStr != null && !dateStr.isEmpty()) {
                appointment.setAppointmentDate(Date.valueOf(dateStr));
            }

            String dobStr = request.getParameter("patientDob");
            if (dobStr != null && !dobStr.isEmpty()) {
                appointment.setDob(Date.valueOf(dobStr));
            }

            appointment.setTimeSlot(request.getParameter("timeSlot"));

            // Nếu user đã đăng nhập, gắn userId
            HttpSession session = request.getSession(false);
            if (session != null && session.getAttribute("user") != null) {
                User user = (User) session.getAttribute("user");
                appointment.setUserId(user.getId());
            }

            // Kiểm tra slot đã được đặt chưa
            boolean alreadyBooked = appointmentDAO.isSlotBooked(
                    appointment.getDoctorId(),
                    appointment.getAppointmentDate(),
                    appointment.getTimeSlot()
            );

            if (alreadyBooked) {
                request.setAttribute("error", "Khung giờ này đã được đặt. Vui lòng chọn khung giờ khác.");
                doGet(request, response);
                return;
            }

            // Lưu lịch hẹn
            int newId = appointmentDAO.create(appointment);

            if (newId > 0) {
                // Đặt lịch thành công
                request.setAttribute("success", true);
                request.setAttribute("appointmentId", newId);
                request.getRequestDispatcher("/views/appointment/book-appointment.jsp").forward(request, response);
            } else {
                request.setAttribute("error", "Không thể đặt lịch. Vui lòng thử lại.");
                doGet(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            doGet(request, response);
        }
    }
}
