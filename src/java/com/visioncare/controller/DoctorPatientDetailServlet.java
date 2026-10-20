package com.visioncare.controller;

import com.visioncare.dao.AppointmentDAO;
import com.visioncare.dao.DoctorQueueDAO;
import com.visioncare.dao.ProcedureOrderDAO;
import com.visioncare.model.Appointment;
import com.visioncare.model.MedicalRecord;
import com.visioncare.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "DoctorPatientDetailServlet", urlPatterns = {"/doctor/patient-detail"})
public class DoctorPatientDetailServlet extends HttpServlet {
    private final AppointmentDAO appointmentDAO = new AppointmentDAO();
    private final DoctorQueueDAO doctorQueueDAO = new DoctorQueueDAO();
    private final ProcedureOrderDAO procedureOrderDAO = new ProcedureOrderDAO();

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
                    || appointment.getCheckinTime() == null
                    || appointment.getCheckinTime().isBlank()
                    || (!"Confirmed".equals(appointment.getStatus())
                        && !"In_Progress".equals(appointment.getStatus())
                        && !"Completed".equals(appointment.getStatus())
                        && !"Canceled".equals(appointment.getStatus()))) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }

            List<MedicalRecord> history = procedureOrderDAO.getPatientMedicalHistory(appointment.getPatientId());
            history.removeIf(record -> record.getAppointmentId() == appointmentId
                    || !"Completed".equals(record.getAppointmentStatus()));
            request.setAttribute("appointment", appointment);
            request.setAttribute("history", history);
            if ("In_Progress".equals(appointment.getStatus()) || "Completed".equals(appointment.getStatus())) {
                request.setAttribute("examinationUrl",
                        request.getContextPath() + "/doctor/examination?id=" + appointmentId);
            }
            if ("In_Progress".equals(appointment.getStatus())) {
                request.setAttribute("prescriptionUrl",
                        request.getContextPath() + "/doctor/prescription?id=" + appointmentId);
                request.setAttribute("completionReady", appointment.getAppointmentDate() != null
                        && doctorQueueDAO.readyForCompletion(doctor.getActorId(), appointment.getAppointmentDate())
                                .contains(appointmentId));
            }
            String csrf = (String) session.getAttribute("doctorQueueCsrf");
            if (csrf == null) {
                csrf = java.util.UUID.randomUUID().toString();
                session.setAttribute("doctorQueueCsrf", csrf);
            }
            request.setAttribute("csrfToken", csrf);
            request.getRequestDispatcher("/views/doctor/patient-detail.jsp").forward(request, response);
        } catch (Exception error) {
            log("Cannot load doctor patient detail", error);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}
