package com.visioncare.controller;

import com.visioncare.dao.AppointmentDAO;
import com.visioncare.dao.DoctorFormDAO;
import com.visioncare.dao.MedicineDAO;
import com.visioncare.model.Appointment;
import com.visioncare.model.Medicine;
import com.visioncare.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * Renders the doctor form screens with their saved values.
 */
@WebServlet(name = "DoctorFormsServlet", urlPatterns = {
        "/doctor/examination", "/doctor/examination/print", "/doctor/prescription"})
public class DoctorFormsServlet extends HttpServlet {
    private final AppointmentDAO appointmentDAO = new AppointmentDAO();
    private final DoctorFormDAO formDAO = new DoctorFormDAO();
    private final MedicineDAO medicineDAO = new MedicineDAO();

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
            boolean prescription = request.getServletPath().endsWith("/prescription");
            boolean printExamination = request.getServletPath().endsWith("/examination/print");
            if (appointment == null || appointment.getDoctorId() != doctor.getActorId()
                    || appointment.getCheckinTime() == null || appointment.getCheckinTime().isBlank()
                    || !("In_Progress".equals(appointment.getStatus())
                         || (!prescription && "Completed".equals(appointment.getStatus())))) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }

            request.setAttribute("readOnly", "Completed".equals(appointment.getStatus()));
            Map<String, String> formValues;
            List<Map<String, String>> medicineRows = new ArrayList<>();
            boolean includeMedication = true;
            boolean includeGlasses = false;
            if (prescription) {
                DoctorFormDAO.PrescriptionSnapshot saved = formDAO.loadPrescription(appointmentId);
                formValues = saved.getValues();
                medicineRows = saved.getMedicines();
                List<Medicine> medicineCatalog = medicineDAO.listPrescribable();
                request.setAttribute("medicineCatalog", medicineCatalog);
                if (!medicineRows.isEmpty() || saved.isIncludeGlasses()) {
                    includeMedication = saved.isIncludeMedication();
                    includeGlasses = saved.isIncludeGlasses();
                }
            } else {
                formValues = formDAO.loadExamination(appointmentId);
                boolean printReady = formDAO.hasSavedExamination(appointmentId);
                if (printExamination && !printReady) {
                    response.sendError(HttpServletResponse.SC_CONFLICT,
                            "Lưu đầy đủ phiếu khám trước khi in.");
                    return;
                }
                request.setAttribute("printReady", printReady);
                if (printExamination) {
                    response.setHeader("Cache-Control", "no-store");
                    request.setAttribute("appointment", appointment);
                    request.setAttribute("formValues", formValues);
                    request.getRequestDispatcher("/views/doctor/examination-print.jsp")
                            .forward(request, response);
                    return;
                }
            }
            if (medicineRows.isEmpty()) medicineRows.add(new HashMap<>());
            String csrf = (String) session.getAttribute("doctorFormCsrf");
            if (csrf == null) {
                csrf = UUID.randomUUID().toString();
                session.setAttribute("doctorFormCsrf", csrf);
            }
            request.setAttribute("appointment", appointment);
            request.setAttribute("formValues", formValues);
            request.setAttribute("medicineRows", medicineRows);
            request.setAttribute("includeMedication", includeMedication);
            request.setAttribute("includeGlasses", includeGlasses);
            request.setAttribute("csrfToken", csrf);
            String notice = (String) session.getAttribute("doctorFormMessage");
            if (notice != null) {
                request.setAttribute("formMessage", notice);
                session.removeAttribute("doctorFormMessage");
            }
            String view = prescription
                    ? "/views/doctor/prescription-form.jsp"
                    : "/views/doctor/clinical-examination-form.jsp";
            request.getRequestDispatcher(view).forward(request, response);
        } catch (Exception error) {
            log("Cannot load doctor form", error);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}
