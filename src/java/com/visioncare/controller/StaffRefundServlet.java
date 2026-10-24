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

@WebServlet(name = "StaffRefundServlet", urlPatterns = {"/staff/refunds", "/admin/refunds", "/admin/reschedule-requests"})
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

        if ("/staff/refunds".equals(request.getServletPath())) {
            response.sendRedirect(request.getContextPath() + "/staff/appointments");
            return;
        }
        if (currentUser.getRoleId() != 1 && currentUser.getRoleId() != 2) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        if ("/admin/reschedule-requests".equals(request.getServletPath())) {
            request.getRequestDispatcher("/views/employee/reschedule-requests.jsp").forward(request, response);
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

        String action = request.getParameter("action");
        boolean creating = "create".equalsIgnoreCase(action);
        boolean management = currentUser.getRoleId() == 1 || currentUser.getRoleId() == 2;
        if ((creating && currentUser.getRoleId() != 5 && !management) || (!creating && !management)
                || (creating && !"/staff/refunds".equals(request.getServletPath()))
                || (!creating && !"/admin/refunds".equals(request.getServletPath()))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        int employeeId = getEmployeeId(currentUser.getId());

        try {
            if ("approve".equalsIgnoreCase(action)) {
                int refundId = Integer.parseInt(request.getParameter("refundId"));
                boolean ok = refundDAO.approveRefund(refundId, employeeId);
                if (ok) {
                    session.setAttribute("successMessage", "Đã duyệt và xác nhận hoàn tiền cho yêu cầu #REF-" + refundId + " thành công!");
                } else {
                    session.setAttribute("errorMessage", "Không thể duyệt hoàn tiền cho yêu cầu #REF-" + refundId + ". Lịch phải được duyệt hủy trước check-in và hóa đơn chưa hoàn tiền.");
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
                String initialStatus = "Pending";

                boolean ok = refundDAO.createRefundByStaff(invoiceId, employeeId, patientId, amount, reason, initialStatus);
                if (ok) {
                    session.setAttribute("successMessage", "Tạo yêu cầu hoàn tiền cho hóa đơn #" + invoiceId + " thành công!");
                } else {
                    session.setAttribute("errorMessage", "Không thể tạo yêu cầu hoàn tiền: lịch phải được duyệt hủy trước check-in, đã thanh toán, số tiền hợp lệ và chưa có yêu cầu đang xử lý.");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMessage", "Lỗi: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + (creating ? "/staff/appointments" : "/admin/refunds"));
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
