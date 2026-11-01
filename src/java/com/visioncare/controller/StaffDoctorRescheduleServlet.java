package com.visioncare.controller;

import com.visioncare.dao.AppointmentDAO;
import com.visioncare.dao.DoctorDAO;
import com.visioncare.dao.WorkScheduleDAO;
import com.visioncare.model.Appointment;
import com.visioncare.model.Doctor;
import com.visioncare.model.TimeSlot;
import com.visioncare.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Date;
import java.time.LocalDate;
import java.util.Collections;
import java.util.List;

/** Staff view of a doctor's schedule with handoff to the existing appointment reschedule flow. */
@WebServlet(name = "StaffDoctorRescheduleServlet", urlPatterns = {"/staff/doctor-reschedule"})
public class StaffDoctorRescheduleServlet extends HttpServlet {
    private final DoctorDAO doctorDAO = new DoctorDAO();
    private final WorkScheduleDAO workScheduleDAO = new WorkScheduleDAO();
    private final AppointmentDAO appointmentDAO = new AppointmentDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        if (user.getRoleId() != 1 && user.getRoleId() != 2 && user.getRoleId() != 5) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        try {
            List<Doctor> doctors = doctorDAO.getAll();
            LocalDate today = LocalDate.now();
            LocalDate date = today;
            String dateParam = request.getParameter("date");
            if (dateParam != null && !dateParam.isBlank()) {
                try {
                    date = LocalDate.parse(dateParam);
                } catch (Exception ignored) {
                    request.setAttribute("filterError", "Ngày không hợp lệ. Đã hiển thị lịch hôm nay.");
                }
            }

            Doctor selectedDoctor = null;
            String doctorParam = request.getParameter("doctorId");
            if (doctorParam != null && !doctorParam.isBlank()) {
                try {
                    int id = Integer.parseInt(doctorParam);
                    for (Doctor doctor : doctors) {
                        if (doctor.getId() == id) {
                            selectedDoctor = doctor;
                            break;
                        }
                    }
                    if (selectedDoctor == null) request.setAttribute("filterError", "Không tìm thấy bác sĩ đã chọn.");
                } catch (NumberFormatException e) {
                    request.setAttribute("filterError", "Mã bác sĩ không hợp lệ.");
                }
            }
            if (selectedDoctor == null && !doctors.isEmpty() && (doctorParam == null || doctorParam.isBlank())) {
                selectedDoctor = doctors.get(0);
            }

            List<TimeSlot> slots = Collections.emptyList();
            List<Appointment> appointments = Collections.emptyList();
            String shiftSummary = "OFF";
            int availableCount = 0;
            if (selectedDoctor != null) {
                slots = workScheduleDAO.getDoctorSlotsForDate(selectedDoctor.getId(), date.toString());
                shiftSummary = workScheduleDAO.getDoctorWorkShiftSummary(selectedDoctor.getId(), date.toString());
                appointments = appointmentDAO.getStaffAppointments(Date.valueOf(date), "all", selectedDoctor.getId(), null);
                for (TimeSlot slot : slots) {
                    if (!slot.isBooked() && !slot.isPast()) availableCount++;
                }
            }

            request.setAttribute("doctors", doctors);
            request.setAttribute("selectedDoctor", selectedDoctor);
            request.setAttribute("selectedDate", date.toString());
            request.setAttribute("today", today.toString());
            request.setAttribute("slots", slots);
            request.setAttribute("appointments", appointments);
            request.setAttribute("shiftSummary", shiftSummary);
            request.setAttribute("availableCount", availableCount);
            request.getRequestDispatcher("/views/staff/doctor-reschedule-form.jsp").forward(request, response);
        } catch (Exception e) {
            throw new ServletException("Không thể tải lịch bác sĩ", e);
        }
    }
}
