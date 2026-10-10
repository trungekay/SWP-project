package com.visioncare.controller;
import com.visioncare.dao.DoctorDAO;
import com.visioncare.dao.DepartmentDAO;
import com.visioncare.dao.AppointmentDAO;
import com.visioncare.model.Doctor;
import com.visioncare.model.Department;
import com.visioncare.model.TimeSlot;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Date;
import java.util.*;
@WebServlet(name = "DoctorScheduleServlet", urlPatterns = {"/doctor-schedules"})
public class DoctorScheduleServlet extends HttpServlet {
    private final DoctorDAO doctorDAO = new DoctorDAO();
    private final DepartmentDAO departmentDAO = new DepartmentDAO();
    private final AppointmentDAO appointmentDAO = new AppointmentDAO();
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String specialty = request.getParameter("specialty");
            String dateStr = request.getParameter("date");
            Date selectedDate;
            if (dateStr != null && !dateStr.isEmpty()) {
                selectedDate = Date.valueOf(dateStr);
            } else {
                selectedDate = new Date(System.currentTimeMillis());
            }
            List<Doctor> doctors;
            if (specialty != null && !specialty.isEmpty() && !specialty.equals("all")) {
                doctors = doctorDAO.getByDepartment(specialty);
            } else {
                doctors = doctorDAO.getAll();
            }

            List<Department> departments = departmentDAO.getAll();
            com.visioncare.dao.WorkScheduleDAO workScheduleDAO = new com.visioncare.dao.WorkScheduleDAO();

            Map<Integer, List<TimeSlot>> doctorSlots = new LinkedHashMap<>();
            Map<Integer, String> doctorShiftSummary = new LinkedHashMap<>();
            for (Doctor doc : doctors) {
                List<TimeSlot> slots = workScheduleDAO.getDoctorSlotsForDate(doc.getId(), selectedDate.toString());
                doctorSlots.put(doc.getId(), slots);
                doctorShiftSummary.put(doc.getId(), workScheduleDAO.getDoctorWorkShiftSummary(doc.getId(), selectedDate.toString()));
            }

            request.setAttribute("doctors", doctors);
            request.setAttribute("departments", departments);
            request.setAttribute("doctorSlots", doctorSlots);
            request.setAttribute("doctorShiftSummary", doctorShiftSummary);
            request.setAttribute("selectedDate", selectedDate.toString());
            request.setAttribute("selectedSpecialty", specialty != null ? specialty : "all");
            request.getRequestDispatcher("/views/doctor/doctor-schedules.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            request.getRequestDispatcher("/views/error/500.jsp").forward(request, response);
        }
    }
}
