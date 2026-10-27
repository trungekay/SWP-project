package com.visioncare.controller;

import com.visioncare.dao.ProcedureOrderDAO;
import com.visioncare.model.MedicalRecord;
import com.visioncare.model.Patient;
import com.visioncare.model.ProcedureOrder;
import com.visioncare.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

/**
 * Screen 35: Specialist Patient Detail Screen (View patient's profile)
 * Cho phép Kỹ thuật viên (Specialist) xem hồ sơ hành chính, tiền sử khám mắt 
 * và các ca thủ thuật/cận lâm sàng trước đây của bệnh nhân.
 */
@WebServlet(name = "SpecialistPatientDetailServlet", urlPatterns = {"/specialist/patient-detail"})
public class SpecialistPatientDetailServlet extends HttpServlet {

    private final ProcedureOrderDAO procedureOrderDAO = new ProcedureOrderDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            HttpSession session = request.getSession();
            User currentUser = (User) session.getAttribute("user");

            if (currentUser == null) {
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }

            // Lấy tham số patientId và orderId (nếu có)
            String patientIdStr = request.getParameter("patientId");
            String orderIdStr = request.getParameter("orderId");

            int patientId = 0;
            if (patientIdStr != null && !patientIdStr.trim().isEmpty()) {
                try {
                    patientId = Integer.parseInt(patientIdStr.trim());
                } catch (NumberFormatException ignored) {}
            }

            Integer orderId = null;
            ProcedureOrder currentOrder = null;
            if (orderIdStr != null && !orderIdStr.trim().isEmpty()) {
                try {
                    orderId = Integer.parseInt(orderIdStr.trim());
                    currentOrder = procedureOrderDAO.getOrderById(orderId);
                    if (patientId <= 0 && currentOrder != null) {
                        patientId = currentOrder.getPatientId();
                    }
                } catch (NumberFormatException ignored) {}
            }

            if (patientId <= 0) {
                response.sendRedirect(request.getContextPath() + "/specialist/waiting-list");
                return;
            }

            // Lấy thông tin cơ bản của bệnh nhân
            Patient patient = procedureOrderDAO.getPatientById(patientId);
            if (patient == null) {
                request.setAttribute("errorMessage", "Không tìm thấy hồ sơ bệnh nhân ID #" + patientId);
                response.sendRedirect(request.getContextPath() + "/specialist/waiting-list");
                return;
            }

            // Lấy toàn bộ lịch sử các lần khám bệnh của bệnh nhân
            List<MedicalRecord> medicalHistory = procedureOrderDAO.getPatientMedicalHistory(patientId);

            // Lấy toàn bộ lịch sử các ca cận lâm sàng / thủ thuật của bệnh nhân
            List<ProcedureOrder> pastOrders = procedureOrderDAO.getOrdersByPatientId(patientId);

            // Đưa dữ liệu sang JSP
            request.setAttribute("patient", patient);
            request.setAttribute("currentOrder", currentOrder);
            request.setAttribute("orderId", orderId);
            request.setAttribute("medicalHistory", medicalHistory);
            request.setAttribute("pastOrders", pastOrders);

            request.getRequestDispatcher("/views/specialist/specialist-patient-detail.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMessage", "Đã xảy ra lỗi khi tải hồ sơ bệnh nhân: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/specialist/waiting-list");
        }
    }
}
