package com.visioncare.controller;

import com.visioncare.dao.AppointmentDAO;
import com.visioncare.dao.DoctorDAO;
import com.visioncare.dao.DepartmentDAO;
import com.visioncare.model.Appointment;
import com.visioncare.model.Doctor;
import com.visioncare.model.Department;
import com.visioncare.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Date;
import java.util.List;

import jakarta.servlet.annotation.WebServlet;

/**
 * Servlet xá»­ lÃ½ form Ä‘áº·t lá»‹ch khÃ¡m máº¯t (wizard 3 bÆ°á»›c).
 * GET  â†’ hiá»ƒn thá»‹ form
 * POST â†’ xá»­ lÃ½ Ä‘áº·t lá»‹ch
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
            // Láº¥y danh sÃ¡ch bÃ¡c sÄ© vÃ  chuyÃªn khoa cho form
            /*
            List<Doctor> doctors = doctorDAO.getAll();
            List<Department> departments = departmentDAO.getAll();
            request.setAttribute("doctors", doctors);
            request.setAttribute("departments", departments);
            */
            
            request.setAttribute("doctors", new java.util.ArrayList<Doctor>());
            request.setAttribute("departments", new java.util.ArrayList<Department>());

            // Náº¿u cÃ³ tham sá»‘ doc (tá»« trang doctor-schedules)
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
            request.setAttribute("error", "CÃ³ lá»—i xáº£y ra: " + e.getMessage());
            request.getRequestDispatcher("/views/error/500.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Thu tháº­p dá»¯ liá»‡u tá»« form
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

            // Náº¿u user Ä‘Ã£ Ä‘Äƒng nháº­p, gáº¯n userId
            HttpSession session = request.getSession(false);
            if (session != null && session.getAttribute("user") != null) {
                User user = (User) session.getAttribute("user");
                appointment.setUserId(user.getId());
            }

            // Kiá»ƒm tra slot Ä‘Ã£ Ä‘Æ°á»£c Ä‘áº·t chÆ°a
            boolean alreadyBooked = appointmentDAO.isSlotBooked(
                    appointment.getDoctorId(),
                    appointment.getAppointmentDate(),
                    appointment.getTimeSlot()
            );

            if (alreadyBooked) {
                request.setAttribute("error", "Khung giá» nÃ y Ä‘Ã£ Ä‘Æ°á»£c Ä‘áº·t. Vui lÃ²ng chá»n khung giá» khÃ¡c.");
                doGet(request, response);
                return;
            }

            // LÆ°u lá»‹ch háº¹n
            int newId = appointmentDAO.create(appointment);

            if (newId > 0) {
                // Äáº·t lá»‹ch thÃ nh cÃ´ng
                request.setAttribute("success", true);
                request.setAttribute("appointmentId", newId);
                request.getRequestDispatcher("/views/appointment/book-appointment.jsp").forward(request, response);
            } else {
                request.setAttribute("error", "KhÃ´ng thá»ƒ Ä‘áº·t lá»‹ch. Vui lÃ²ng thá»­ láº¡i.");
                doGet(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "CÃ³ lá»—i xáº£y ra: " + e.getMessage());
            doGet(request, response);
        }
    }
}
