package com.visioncare.controller;

import com.visioncare.dao.PatientDAO;
import com.visioncare.model.Patient;
import com.visioncare.model.User;
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
import java.util.List;
import java.util.Map;
import java.util.regex.Pattern;

@WebServlet(name = "StaffPatientServlet", urlPatterns = {"/staff/patients", "/staff/patients/history"})
public class StaffPatientServlet extends HttpServlet {

    private final PatientDAO patientDAO = new PatientDAO();
    private static final Pattern PHONE_PATTERN = Pattern.compile("^(0[3|5|7|8|9])[0-9]{8}$");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            HttpSession session = request.getSession(false);
            User currentUser = (session == null) ? null : (User) session.getAttribute("user");
            if (currentUser == null) {
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }

            if (currentUser.getRoleId() != 5 && currentUser.getRoleId() != 1 && currentUser.getRoleId() != 2) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập trang này.");
                return;
            }

            String ajax = request.getParameter("ajax");
            if ("detail".equalsIgnoreCase(ajax)) {
                handleAjaxDetail(request, response);
                return;
            } else if ("history".equalsIgnoreCase(ajax)) {
                handleAjaxHistory(request, response);
                return;
            } else if ("checkPhone".equalsIgnoreCase(ajax)) {
                handleAjaxCheckPhone(request, response);
                return;
            }

            // Standard listing
            String keyword = request.getParameter("keyword");
            if (keyword != null) keyword = keyword.trim();
            else keyword = "";

            String accountType = request.getParameter("accountType");
            if (accountType == null || accountType.trim().isEmpty()) {
                accountType = "all";
            }

            String sortBy = request.getParameter("sortBy");
            if (sortBy == null || sortBy.trim().isEmpty()) {
                sortBy = "newest";
            }

            int page = 1;
            String pageStr = request.getParameter("page");
            if (pageStr != null && !pageStr.trim().isEmpty()) {
                try {
                    page = Integer.parseInt(pageStr.trim());
                    if (page < 1) page = 1;
                } catch (NumberFormatException ignored) {}
            }

            int pageSize = 10;
            String pageSizeStr = request.getParameter("pageSize");
            if (pageSizeStr != null && !pageSizeStr.trim().isEmpty()) {
                try {
                    pageSize = Integer.parseInt(pageSizeStr.trim());
                    if (pageSize < 5) pageSize = 5;
                    if (pageSize > 50) pageSize = 50;
                } catch (NumberFormatException ignored) {}
            }

            Map<String, Integer> stats = patientDAO.getPatientStats();
            int totalRecords = patientDAO.countPatients(keyword, accountType);
            int totalPages = (int) Math.ceil((double) totalRecords / pageSize);
            if (totalPages < 1) totalPages = 1;
            if (page > totalPages) page = totalPages;

            List<Patient> patients = patientDAO.getPatients(keyword, accountType, sortBy, page, pageSize);

            request.setAttribute("patients", patients);
            request.setAttribute("stats", stats);
            request.setAttribute("keyword", keyword);
            request.setAttribute("accountType", accountType);
            request.setAttribute("sortBy", sortBy);
            request.setAttribute("currentPage", page);
            request.setAttribute("pageSize", pageSize);
            request.setAttribute("totalRecords", totalRecords);
            request.setAttribute("totalPages", totalPages);

            request.getRequestDispatcher("/views/staff/patient-list.jsp").forward(request, response);
        } catch (Throwable t) {
            t.printStackTrace();
            request.setAttribute("error", "Lỗi xử lý tại StaffPatientServlet: " + t.getMessage() + " (" + t.getClass().getName() + ")");
            request.getRequestDispatcher("/views/error/500.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        User currentUser = (session == null) ? null : (User) session.getAttribute("user");
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        if (currentUser.getRoleId() != 5 && currentUser.getRoleId() != 1 && currentUser.getRoleId() != 2) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền thực hiện thao tác này.");
            return;
        }

        String action = request.getParameter("action");
        if ("create".equalsIgnoreCase(action)) {
            handleCreatePatient(request, response, session);
        } else if ("update".equalsIgnoreCase(action)) {
            handleUpdatePatient(request, response, session);
        } else {
            response.sendRedirect(request.getContextPath() + "/staff/patients");
        }
    }

    private void handleCreatePatient(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws IOException {
        String fullName = request.getParameter("fullName");
        String phone = request.getParameter("phone");
        String dobStr = request.getParameter("dob");
        String address = request.getParameter("address");

        if (fullName == null || fullName.trim().isEmpty()) {
            session.setAttribute("errorMessage", "Họ và tên bệnh nhân không được để trống!");
            response.sendRedirect(request.getContextPath() + "/staff/patients");
            return;
        }

        if (phone == null || !PHONE_PATTERN.matcher(phone.trim()).matches()) {
            session.setAttribute("errorMessage", "Số điện thoại không hợp lệ! Vui lòng nhập đúng 10 số (bắt đầu bằng 03, 05, 07, 08, 09).");
            response.sendRedirect(request.getContextPath() + "/staff/patients");
            return;
        }

        phone = phone.trim();
        if (patientDAO.isPhoneExists(phone, 0)) {
            session.setAttribute("errorMessage", "Số điện thoại '" + phone + "' đã tồn tại trong hệ thống! Vui lòng tìm kiếm bệnh nhân theo số điện thoại này.");
            response.sendRedirect(request.getContextPath() + "/staff/patients?keyword=" + URLEncoder.encode(phone, StandardCharsets.UTF_8));
            return;
        }

        Date dob = null;
        if (dobStr != null && !dobStr.trim().isEmpty()) {
            try {
                dob = Date.valueOf(dobStr.trim());
                if (dob.after(new java.util.Date())) {
                    session.setAttribute("errorMessage", "Ngày sinh không được lớn hơn ngày hiện tại!");
                    response.sendRedirect(request.getContextPath() + "/staff/patients");
                    return;
                }
            } catch (IllegalArgumentException e) {
                session.setAttribute("errorMessage", "Định dạng ngày sinh không hợp lệ!");
                response.sendRedirect(request.getContextPath() + "/staff/patients");
                return;
            }
        }

        Patient patient = new Patient();
        patient.setFullName(fullName.trim());
        patient.setPhone(phone);
        patient.setDob(dob);
        patient.setAddress(address != null ? address.trim() : "");

        int newId = patientDAO.addPatient(patient);
        if (newId > 0) {
            session.setAttribute("successMessage", "Đã tạo mới hồ sơ bệnh nhân #" + String.format("%04d", newId) + " (" + fullName.trim() + ") thành công!");
        } else {
            session.setAttribute("errorMessage", "Không thể tạo hồ sơ bệnh nhân. Vui lòng thử lại!");
        }
        response.sendRedirect(request.getContextPath() + "/staff/patients");
    }

    private void handleUpdatePatient(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws IOException {
        String idStr = request.getParameter("patientId");
        String fullName = request.getParameter("fullName");
        String phone = request.getParameter("phone");
        String dobStr = request.getParameter("dob");
        String address = request.getParameter("address");

        int patientId = 0;
        try {
            patientId = Integer.parseInt(idStr);
            if (patientId <= 0) throw new NumberFormatException();
        } catch (Exception e) {
            session.setAttribute("errorMessage", "Mã bệnh nhân không hợp lệ!");
            response.sendRedirect(request.getContextPath() + "/staff/patients");
            return;
        }

        if (fullName == null || fullName.trim().isEmpty()) {
            session.setAttribute("errorMessage", "Họ và tên bệnh nhân không được để trống!");
            response.sendRedirect(request.getContextPath() + "/staff/patients");
            return;
        }

        if (phone == null || !PHONE_PATTERN.matcher(phone.trim()).matches()) {
            session.setAttribute("errorMessage", "Số điện thoại không hợp lệ! Vui lòng nhập đúng 10 số.");
            response.sendRedirect(request.getContextPath() + "/staff/patients");
            return;
        }

        phone = phone.trim();
        if (patientDAO.isPhoneExists(phone, patientId)) {
            session.setAttribute("errorMessage", "Số điện thoại '" + phone + "' đã được sử dụng bởi một bệnh nhân khác!");
            response.sendRedirect(request.getContextPath() + "/staff/patients");
            return;
        }

        Date dob = null;
        if (dobStr != null && !dobStr.trim().isEmpty()) {
            try {
                dob = Date.valueOf(dobStr.trim());
                if (dob.after(new java.util.Date())) {
                    session.setAttribute("errorMessage", "Ngày sinh không hợp lệ!");
                    response.sendRedirect(request.getContextPath() + "/staff/patients");
                    return;
                }
            } catch (Exception e) {
                session.setAttribute("errorMessage", "Định dạng ngày sinh không hợp lệ!");
                response.sendRedirect(request.getContextPath() + "/staff/patients");
                return;
            }
        }

        Patient patient = new Patient();
        patient.setPatientId(patientId);
        patient.setFullName(fullName.trim());
        patient.setPhone(phone);
        patient.setDob(dob);
        patient.setAddress(address != null ? address.trim() : "");

        boolean ok = patientDAO.updatePatient(patient);
        if (ok) {
            session.setAttribute("successMessage", "Cập nhật thông tin bệnh nhân #" + String.format("%04d", patientId) + " thành công!");
        } else {
            session.setAttribute("errorMessage", "Cập nhật thông tin thất bại!");
        }
        response.sendRedirect(request.getContextPath() + "/staff/patients");
    }

    private void handleAjaxDetail(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        String idStr = request.getParameter("id");
        try {
            int patientId = Integer.parseInt(idStr);
            Patient p = patientDAO.getPatientById(patientId);
            if (p != null) {
                StringBuilder json = new StringBuilder("{");
                json.append("\"found\":true,");
                json.append("\"id\":").append(p.getPatientId()).append(",");
                json.append("\"formattedId\":\"").append(escapeJson(p.getFormattedId())).append("\",");
                json.append("\"fullName\":\"").append(escapeJson(p.getFullName())).append("\",");
                json.append("\"phone\":\"").append(escapeJson(p.getPhone())).append("\",");
                json.append("\"dob\":\"").append(p.getDob() != null ? p.getDob().toString() : "").append("\",");
                json.append("\"age\":").append(p.getAge()).append(",");
                json.append("\"address\":\"").append(escapeJson(p.getAddress() != null ? p.getAddress() : "")).append("\",");
                json.append("\"email\":\"").append(escapeJson(p.getEmail() != null ? p.getEmail() : "")).append("\",");
                json.append("\"hasAccount\":").append(p.isHasAccount()).append(",");
                json.append("\"totalAppointments\":").append(p.getTotalAppointments()).append(",");
                json.append("\"latestDate\":\"").append(escapeJson(p.getLatestAppointmentDate())).append("\"");
                json.append("}");
                response.getWriter().write(json.toString());
                return;
            }
        } catch (Exception ignored) {}
        response.getWriter().write("{\"found\":false}");
    }

    private void handleAjaxHistory(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        String idStr = request.getParameter("id");
        try {
            int patientId = Integer.parseInt(idStr);
            List<Map<String, Object>> history = patientDAO.getPatientAppointmentHistory(patientId);
            StringBuilder json = new StringBuilder("[");
            for (int i = 0; i < history.size(); i++) {
                Map<String, Object> item = history.get(i);
                if (i > 0) json.append(",");
                json.append("{");
                json.append("\"appointmentId\":").append(item.get("appointmentId")).append(",");
                json.append("\"formattedId\":\"").append(escapeJson((String) item.get("formattedId"))).append("\",");
                json.append("\"status\":\"").append(escapeJson((String) item.get("status"))).append("\",");
                json.append("\"workDate\":\"").append(escapeJson((String) item.get("workDate"))).append("\",");
                json.append("\"slot\":\"").append(escapeJson(item.get("slot") != null ? (String) item.get("slot") : "")).append("\",");
                json.append("\"time\":\"").append(escapeJson((String) item.get("time"))).append("\",");
                json.append("\"doctorName\":\"").append(escapeJson((String) item.get("doctorName"))).append("\",");
                json.append("\"specialty\":\"").append(escapeJson((String) item.get("specialty"))).append("\",");
                json.append("\"serviceName\":\"").append(escapeJson((String) item.get("serviceName"))).append("\",");
                json.append("\"invoiceId\":").append(item.get("invoiceId") != null ? item.get("invoiceId") : 0).append(",");
                json.append("\"totalAmount\":").append(item.get("totalAmount")).append(",");
                json.append("\"formattedTotal\":\"").append(escapeJson((String) item.get("formattedTotal"))).append("\",");
                json.append("\"invoiceStatus\":\"").append(escapeJson(item.get("invoiceStatus") != null ? (String) item.get("invoiceStatus") : "")).append("\",");
                json.append("\"diagnosis\":\"").append(escapeJson((String) item.get("diagnosis"))).append("\",");
                json.append("\"createdAt\":\"").append(escapeJson((String) item.get("createdAt"))).append("\"");
                json.append("}");
            }
            json.append("]");
            response.getWriter().write(json.toString());
            return;
        } catch (Exception ignored) {}
        response.getWriter().write("[]");
    }

    private void handleAjaxCheckPhone(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        String phone = request.getParameter("phone");
        String excludeIdStr = request.getParameter("excludeId");
        int excludeId = 0;
        try {
            if (excludeIdStr != null) excludeId = Integer.parseInt(excludeIdStr);
        } catch (NumberFormatException ignored) {}

        boolean exists = patientDAO.isPhoneExists(phone, excludeId);
        response.getWriter().write("{\"exists\":" + exists + "}");
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\b", "\\b")
                .replace("\f", "\\f")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}
