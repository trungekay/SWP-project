package com.visioncare.controller;

import com.visioncare.dao.AppointmentDAO;
import com.visioncare.dao.CatalogDAO;
import com.visioncare.dao.DoctorFormDAO;
import com.visioncare.dao.MedicineDAO;
import com.visioncare.model.Appointment;
import com.visioncare.model.CatalogService;
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
import java.util.Set;
import java.util.TreeSet;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/** Handles validated, CSRF-protected writes for the two doctor forms. */
@WebServlet(name = "DoctorFormSaveServlet",
        urlPatterns = {"/doctor/examination/save", "/doctor/prescription/save"})
public class DoctorFormSaveServlet extends HttpServlet {
    private static final Pattern MEDICINE_NAME =
            Pattern.compile("^medicines\\[(\\d+)\\]\\.medicineName$");
    private static final String[] EXAM_FIELDS = {
        "chiefComplaint", "medicalHistory", "odUncorrected", "osUncorrected",
        "odCorrected", "osCorrected", "odIop", "osIop",
        "anteriorFindings", "posteriorFindings", "clinicalDiagnosis",
        "examinationResult", "conclusion", "followUpDate", "surgeryServiceId", "surgeryNotes"
    };
    private static final String[] PRESCRIPTION_FIELDS = {
        "odSph", "odCyl", "odAxis", "odAdd", "osSph", "osCyl", "osAxis", "osAdd",
        "pd", "lensType", "glassesNotes", "doctorNotes", "followUpDate"
    };
    private static final String[] MEDICINE_FIELDS = {
        "medicineName", "strength", "morning", "morningDose", "afternoon", "afternoonDose",
        "evening", "eveningDose", "duration", "quantity", "unit", "instructions"
    };
    private final AppointmentDAO appointmentDAO = new AppointmentDAO();
    private final DoctorFormDAO formDAO = new DoctorFormDAO();
    private final MedicineDAO medicineDAO = new MedicineDAO();
    private final CatalogDAO catalogDAO = new CatalogDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
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
        String csrf = (String) session.getAttribute("doctorFormCsrf");
        if (csrf == null || !csrf.equals(request.getParameter("csrfToken"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        int appointmentId;
        try {
            appointmentId = Integer.parseInt(request.getParameter("id"));
            if (appointmentId <= 0
                    || !String.valueOf(appointmentId).equals(request.getParameter("appointmentId"))) {
                throw new NumberFormatException();
            }
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
            boolean prescription = request.getServletPath().contains("/prescription/");
            boolean referSurgery = !prescription && "refer".equals(request.getParameter("submitAction"));
            Map<String, String> values = values(request,
                    prescription ? PRESCRIPTION_FIELDS : EXAM_FIELDS);
            List<Map<String, String>> medicines = prescription ? medicineRows(request) : new ArrayList<>();
            boolean includeMedication = prescription && "true".equals(request.getParameter("includeMedication"));
            boolean includeGlasses = prescription && "true".equals(request.getParameter("includeGlasses"));
            List<Medicine> medicineCatalog = prescription ? medicineDAO.listPrescribable() : List.of();
            List<CatalogService> surgeryServices = prescription ? List.of() : catalogDAO.listSurgeryServices();
            List<String> errors = prescription
                    ? DoctorFormValidator.prescription(values, medicines, includeMedication, includeGlasses)
                    : DoctorFormValidator.examination(values);
            Integer surgeryServiceId = null;
            if (referSurgery) {
                try {
                    surgeryServiceId = Integer.valueOf(values.get("surgeryServiceId"));
                } catch (RuntimeException invalidId) {
                    errors.add("Chọn loại phẫu thuật.");
                }
                final Integer selectedServiceId = surgeryServiceId;
                if (selectedServiceId != null && surgeryServices.stream().noneMatch(s -> s.getId() == selectedServiceId)) {
                    errors.add("Loại phẫu thuật không hợp lệ.");
                }
                String notes = values.get("surgeryNotes");
                if (notes == null || notes.isBlank()) errors.add("Nhập ghi chú chỉ định phẫu thuật.");
                else if (notes.length() > 2000) errors.add("Ghi chú chỉ định tối đa 2000 ký tự.");
            }
            if (!errors.isEmpty()) {
                if (!prescription) {
                    Map<String, String> savedContext = formDAO.loadExamination(appointmentId);
                    values.put("previousDiagnoses", savedContext.getOrDefault("previousDiagnoses", ""));
                    values.put("surgeryStatus", savedContext.getOrDefault("surgeryStatus", ""));
                }
                if (medicines.isEmpty()) medicines.add(new HashMap<>());
                response.setStatus(422);
                request.setAttribute("appointment", appointment);
                request.setAttribute("formValues", values);
                request.setAttribute("surgeryServices", surgeryServices);
                request.setAttribute("surgeryOpen", referSurgery);
                request.setAttribute("medicineRows", medicines);
                if (prescription) request.setAttribute("medicineCatalog", medicineCatalog);
                request.setAttribute("includeMedication", includeMedication);
                request.setAttribute("includeGlasses", includeGlasses);
                request.setAttribute("csrfToken", csrf);
                request.setAttribute("formErrors", errors);
                request.getRequestDispatcher(prescription
                        ? "/views/doctor/prescription-form.jsp"
                        : "/views/doctor/clinical-examination-form.jsp").forward(request, response);
                return;
            }
            if (prescription) {
                for (Map<String, String> medicine : medicines) {
                    String name = medicine.getOrDefault("medicineName", "");
                    boolean inCatalog = medicineCatalog.stream()
                            .anyMatch(item -> item.getName().equalsIgnoreCase(name));
                    medicine.put("customMedicine", String.valueOf(!inCatalog));
                }
                formDAO.savePrescription(appointmentId, doctor.getActorId(),
                        values, medicines, includeMedication, includeGlasses);
                session.setAttribute("doctorFormMessage", "Đã lưu đơn thuốc/kính.");
            } else {
                formDAO.saveExamination(appointmentId, doctor.getActorId(), values,
                        referSurgery ? surgeryServiceId : null, values.get("surgeryNotes"));
                session.setAttribute("doctorFormMessage", referSurgery
                        ? "Đã lưu phiếu khám và gửi chỉ định phẫu thuật vào hàng đợi bác sĩ thủ thuật."
                        : "Đã lưu kết quả khám.");
            }
            String formPath = prescription ? "/doctor/prescription" : "/doctor/examination";
            response.sendRedirect(request.getContextPath() + formPath + "?id=" + appointmentId);
        } catch (IllegalArgumentException invalid) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, invalid.getMessage());
        } catch (IllegalStateException changed) {
            response.sendError(HttpServletResponse.SC_CONFLICT, changed.getMessage());
        } catch (Exception error) {
            log("Cannot save doctor form", error);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    private Map<String, String> values(HttpServletRequest request, String[] keys) {
        Map<String, String> result = new HashMap<>();
        for (String key : keys) {
            String raw = request.getParameter(key);
            result.put(key, raw == null ? "" : raw.trim());
        }
        return result;
    }

    private List<Map<String, String>> medicineRows(HttpServletRequest request) {
        Set<Integer> indexes = new TreeSet<>();
        for (String name : request.getParameterMap().keySet()) {
            Matcher match = MEDICINE_NAME.matcher(name);
            if (match.matches()) {
                int index;
                try {
                    index = Integer.parseInt(match.group(1));
                } catch (NumberFormatException hugeIndex) {
                    throw new IllegalArgumentException("Danh sách thuốc không hợp lệ.");
                }
                if (index >= 20) throw new IllegalArgumentException("Tối đa 20 thuốc trong một đơn.");
                indexes.add(index);
            }
        }
        List<Map<String, String>> rows = new ArrayList<>();
        int expected = 0;
        for (int index : indexes) {
            if (index != expected++) throw new IllegalArgumentException("Danh sách thuốc không hợp lệ.");
            Map<String, String> row = new HashMap<>();
            for (String field : MEDICINE_FIELDS) {
                String raw = request.getParameter("medicines[" + index + "]." + field);
                row.put(field, raw == null ? "" : raw.trim());
            }
            rows.add(row);
        }
        return rows;
    }
}
