package com.visioncare.controller;

import com.visioncare.dao.MedicalRecordDAO;
import com.visioncare.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Map;

@WebServlet(name = "MedicalRecordServlet", urlPatterns = {"/profile/medical-record"})
public class MedicalRecordServlet extends HttpServlet {

    private final MedicalRecordDAO medicalRecordDAO = new MedicalRecordDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/views/profile/medical-history.jsp");
            return;
        }

        try {
            int recordId = Integer.parseInt(idParam.trim());
            Map<String, Object> record;

            String role = currentUser.getRole() != null ? currentUser.getRole().trim() : "";
            if ("admin".equalsIgnoreCase(role) || "staff".equalsIgnoreCase(role) || 
                "manager".equalsIgnoreCase(role) || "doctor".equalsIgnoreCase(role) ||
                "medical_specialist".equalsIgnoreCase(role)) {
                record = medicalRecordDAO.getMedicalRecordDetail(recordId);
            } else {
                record = medicalRecordDAO.getMedicalRecordDetailForPatient(recordId, currentUser.getId());
            }

            if (record == null) {
                session.setAttribute("errorMessage", "Không tìm thấy hồ sơ khám bệnh hoặc bạn không có quyền xem hồ sơ này.");
                response.sendRedirect(request.getContextPath() + "/views/profile/medical-history.jsp");
                return;
            }

            Object invoiceId=record.get("invoiceId");
            if(currentUser.getRoleId()==6 && invoiceId instanceof Number){record.put("invoiceVisible",new com.visioncare.dao.PatientInvoiceDAO().completed(((Number)invoiceId).intValue(),currentUser.getId())!=null);}
            request.setAttribute("record", record);
            request.getRequestDispatcher("/views/profile/medical-record.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/views/profile/medical-history.jsp");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/views/profile/medical-history.jsp");
        }
    }
}
