package com.visioncare.controller;

import com.visioncare.dao.AppointmentDAO;
import com.visioncare.model.Appointment;
import com.visioncare.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Renders the doctor form screens. POST persistence belongs to the
 * examination and prescription workflows and is not implemented here.
 */
@WebServlet(name = "DoctorFormsServlet", urlPatterns = {"/doctor/examination", "/doctor/prescription"})
public class DoctorFormsServlet extends HttpServlet {
    private final AppointmentDAO appointmentDAO = new AppointmentDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User doctor = session == null ? null : (User) session.getAttribute("user");
        if (doctor == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        if (doctor.getRoleId() != 3 || doctor.getActorId() <= 0) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        int appointmentId;
        try {
            appointmentId = Integer.parseInt(request.getParameter("id"));
            if (appointmentId <= 0) throw new NumberFormatException();
        } catch (NumberFormatException invalidId) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        try {
            Appointment appointment = appointmentDAO.getAppointmentById(appointmentId);
            if (appointment == null || appointment.getDoctorId() != doctor.getActorId()
                    || appointment.getCheckinTime() == null || appointment.getCheckinTime().isBlank()
                    || !"In_Progress".equals(appointment.getStatus())) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }

            request.setAttribute("appointment", appointment);
            String view = request.getServletPath().endsWith("/prescription")
                    ? "/views/doctor/prescription-form.jsp"
                    : "/views/doctor/clinical-examination-form.jsp";
            request.getRequestDispatcher(view).forward(request, response);
        } catch (Exception error) {
            log("Cannot load doctor form", error);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}
