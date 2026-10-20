package com.visioncare.controller;

import com.visioncare.dao.ProcedurePaymentDAO;
import com.visioncare.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@WebServlet(name = "StaffProcedurePaymentServlet", urlPatterns = {"/staff/procedure-payments"})
public class StaffProcedurePaymentServlet extends HttpServlet {
    private final ProcedurePaymentDAO dao = new ProcedurePaymentDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User staff = currentStaff(request, response);
        if (staff == null) return;
        try {
            List<Map<String, Object>> requests = dao.listRequests();
            long pendingCount = requests.stream().filter(row -> "Pending".equals(row.get("status"))).count();
            HttpSession session = request.getSession();
            String csrf = (String) session.getAttribute("procedurePaymentCsrf");
            if (csrf == null) {
                csrf = UUID.randomUUID().toString();
                session.setAttribute("procedurePaymentCsrf", csrf);
            }
            request.setAttribute("requests", requests);
            request.setAttribute("pendingCount", pendingCount);
            request.setAttribute("csrfToken", csrf);
            request.getRequestDispatcher("/views/staff/procedure-payments.jsp").forward(request, response);
        } catch (Exception error) {
            log("Cannot load surgery payment requests", error);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User staff = currentStaff(request, response);
        if (staff == null) return;
        HttpSession session = request.getSession(false);
        String expected = session == null ? null : (String) session.getAttribute("procedurePaymentCsrf");
        if (expected == null || !expected.equals(request.getParameter("csrfToken"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        int orderId;
        try {
            orderId = Integer.parseInt(request.getParameter("orderId"));
        } catch (NumberFormatException error) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        try {
            boolean paid = dao.confirm(orderId, staff.getActorId(), request.getParameter("paymentMethod"));
            session.setAttribute("procedurePaymentMessage", paid
                    ? "Đã xác nhận thanh toán ca #CD-" + orderId + ". Specialist có thể tiếp nhận."
                    : "Không thể xác nhận ca #CD-" + orderId + ". Hãy kiểm tra trạng thái và tải lại danh sách.");
        } catch (Exception error) {
            log("Cannot confirm surgery payment", error);
            session.setAttribute("procedurePaymentMessage", "Chưa thể ghi nhận thanh toán. Vui lòng thử lại.");
        }
        response.sendRedirect(request.getContextPath() + "/staff/procedure-payments");
    }

    private User currentStaff(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return null;
        }
        int roleId = user.getRoleId();
        if (user.getActorId() <= 0 || !(roleId == 5 || roleId == 1 || roleId == 2)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return null;
        }
        return user;
    }
}
