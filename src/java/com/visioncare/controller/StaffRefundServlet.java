package com.visioncare.controller;

import com.visioncare.dao.DBContext;
import com.visioncare.dao.RefundDAO;
import com.visioncare.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.List;
import java.util.Map;

@WebServlet(name = "StaffRefundServlet", urlPatterns = {"/staff/refunds", "/admin/refunds"})
public class StaffRefundServlet extends HttpServlet {

    private final RefundDAO refundDAO = new RefundDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String role = currentUser.getRole() != null ? currentUser.getRole().toLowerCase() : "";
        if (!"staff".equals(role) && !"admin".equals(role) && !"manager".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/views/profile/refund-request.jsp");
            return;
        }

        String statusFilter = request.getParameter("status");
        if (statusFilter == null || statusFilter.isEmpty()) {
            statusFilter = "all";
        }

        List<Map<String, Object>> refunds = refundDAO.getAllRefundRequests(statusFilter);
        Map<String, Object> stats = refundDAO.getRefundStats();
        List<Map<String, Object>> availableInvoices = refundDAO.getInvoicesForStaffRefundSelection();

        request.setAttribute("refunds", refunds);
        request.setAttribute("stats", stats);
        request.setAttribute("availableInvoices", availableInvoices);
        request.setAttribute("currentStatus", statusFilter);

        // Flash messages
        if (session.getAttribute("successMessage") != null) {
            request.setAttribute("successMessage", session.getAttribute("successMessage"));
            session.removeAttribute("successMessage");
        }
        if (session.getAttribute("errorMessage") != null) {
            request.setAttribute("errorMessage", session.getAttribute("errorMessage"));
            session.removeAttribute("errorMessage");
        }

        request.getRequestDispatcher("/views/admin/refund-management.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        int employeeId = getEmployeeId(currentUser.getId());
        String action = request.getParameter("action");

        try {
            if ("approve".equalsIgnoreCase(action)) {
                int refundId = Integer.parseInt(request.getParameter("refundId"));
                boolean ok = refundDAO.approveRefund(refundId, employeeId);
                if (ok) {
                    session.setAttribute("successMessage", "Đã duyệt và xác nhận hoàn tiền cho yêu cầu #REF-" + refundId + " thành công!");
                } else {
                    session.setAttribute("errorMessage", "Không thể duyệt hoàn tiền cho yêu cầu #REF-" + refundId + ". Nếu ca đang khám, hãy đợi bác sĩ kết thúc hoặc dừng ca trước.");
                }
            } else if ("reject".equalsIgnoreCase(action)) {
                int refundId = Integer.parseInt(request.getParameter("refundId"));
                String note = request.getParameter("rejectNote");
                boolean ok = refundDAO.rejectRefund(refundId, employeeId, note);
                if (ok) {
                    session.setAttribute("successMessage", "Đã từ chối yêu cầu hoàn tiền #REF-" + refundId);
                } else {
                    session.setAttribute("errorMessage", "Không thể từ chối yêu cầu #REF-" + refundId);
                }
            } else if ("create".equalsIgnoreCase(action)) {
                int invoiceId = Integer.parseInt(request.getParameter("invoiceId"));
                int patientId = Integer.parseInt(request.getParameter("patientId"));
                long amount = Long.parseLong(request.getParameter("amount").replaceAll("[^0-9]", ""));
                String reason = request.getParameter("reason");
                String initialStatus = request.getParameter("initialStatus");

                boolean ok = refundDAO.createRefundByStaff(invoiceId, employeeId, patientId, amount, reason, initialStatus);
                if (ok) {
                    session.setAttribute("successMessage", "Tạo yêu cầu hoàn tiền cho hóa đơn #" + invoiceId + " thành công!");
                } else {
                    session.setAttribute("errorMessage", "Không thể tạo yêu cầu hoàn tiền.");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMessage", "Lỗi: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/staff/refunds");
    }

    private int getEmployeeId(int accountId) {
        String sql = "SELECT Employee_ID FROM Employee_Profile WHERE Account_ID = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception ignored) {}
        return 1;
    }
}
