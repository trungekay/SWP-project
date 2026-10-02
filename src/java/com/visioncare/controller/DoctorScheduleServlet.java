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
            Map<Integer, List<TimeSlot>> doctorSlots = new LinkedHashMap<>();
            String[] morningSlots = {"08:00", "08:30", "09:00", "09:30", "10:00", "10:30", "11:00"};
            String[] afternoonSlots = {"13:30", "14:00", "14:30", "15:00", "15:30", "16:00", "16:30"};
            for (Doctor doc : doctors) {
                List<TimeSlot> slots = new ArrayList<>();
                for (String time : morningSlots) {
                    TimeSlot ts = new TimeSlot();
                    ts.setDoctorId(doc.getId());
                    ts.setDate(selectedDate);
                    ts.setStartTime(time);
                    ts.setBooked(appointmentDAO.isSlotBooked(doc.getId(), selectedDate, time));
                    slots.add(ts);
                }
                for (String time : afternoonSlots) {
                    TimeSlot ts = new TimeSlot();
                    ts.setDoctorId(doc.getId());
                    ts.setDate(selectedDate);
                    ts.setStartTime(time);
                    ts.setBooked(appointmentDAO.isSlotBooked(doc.getId(), selectedDate, time));
                    slots.add(ts);
                }
                doctorSlots.put(doc.getId(), slots);
            }
            request.setAttribute("doctors", doctors);
            request.setAttribute("departments", departments);
            request.setAttribute("doctorSlots", doctorSlots);
            request.setAttribute("selectedDate", selectedDate.toString());
            request.setAttribute("selectedSpecialty", specialty != null ? specialty : "all");
            request.getRequestDispatcher("/views/doctor/doctor-schedules.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "CÃ³ lá»—i xáº£y ra: " + e.getMessage());
            request.getRequestDispatcher("/views/error/500.jsp").forward(request, response);
        }
    }
}
