package com.visioncare.controller;

import com.visioncare.dao.LeaveCancelRequestDAO;
import com.visioncare.dao.RefundDAO;
import com.visioncare.model.LeaveCancelRequest;
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

@WebServlet(name = "DirectorLeaveRequestServlet", urlPatterns = {"/director/leave-requests"})
public class DirectorLeaveRequestServlet extends HttpServlet {

    private final LeaveCancelRequestDAO leaveCancelRequestDAO = new LeaveCancelRequestDAO();
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

        if (currentUser.getRoleId() != 2 && currentUser.getRoleId() != 1 && !"director".equalsIgnoreCase(currentUser.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập trang này.");
            return;
        }

        String statusFilter = request.getParameter("status");
        if (statusFilter == null || statusFilter.isEmpty()) {
            statusFilter = "all";
        }

        String roleFilter = request.getParameter("role");
        if (roleFilter == null || roleFilter.isEmpty()) {
            roleFilter = "all";
        }

        List<LeaveCancelRequest> requests = leaveCancelRequestDAO.getAllRequests(statusFilter, roleFilter);
        Map<String, Integer> stats = leaveCancelRequestDAO.getStats();

        // Flash messages
        if (session.getAttribute("successMessage") != null) {
            request.setAttribute("successMessage", session.getAttribute("successMessage"));
            session.removeAttribute("successMessage");
        }
        if (session.getAttribute("errorMessage") != null) {
            request.setAttribute("errorMessage", session.getAttribute("errorMessage"));
            session.removeAttribute("errorMessage");
        }

        // Pending counts for sidebar
        request.setAttribute("pendingLeaveCount", stats.get("pending"));
        Map<String, Object> refundStats = refundDAO.getRefundStats();
        request.setAttribute("pendingRefundCount", refundStats.get("pending"));

        request.setAttribute("requests", requests);
        request.setAttribute("stats", stats);
        request.setAttribute("currentStatus", statusFilter);
        request.setAttribute("currentRole", roleFilter);

        request.getRequestDispatcher("/views/director/leave-requests.jsp").forward(request, response);
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

        if (currentUser.getRoleId() != 2 && currentUser.getRoleId() != 1 && !"director".equalsIgnoreCase(currentUser.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền thực hiện thao tác này.");
            return;
        }

        int directorEmployeeId = currentUser.getActorId() > 0 ? currentUser.getActorId() : 2;
        String action = request.getParameter("action");

        try {
            if ("approve".equalsIgnoreCase(action)) {
                int requestId = Integer.parseInt(request.getParameter("requestId"));
                boolean ok = leaveCancelRequestDAO.approveRequest(requestId, directorEmployeeId);
                if (ok) {
                    session.setAttribute("successMessage", "Đã chấp thuận yêu cầu hủy ca trực #" + requestId + " thành công! Ca trực đã chuyển trạng thái Nghỉ phép.");
                } else {
                    session.setAttribute("errorMessage", "Không thể phê duyệt yêu cầu #" + requestId + ". Vui lòng kiểm tra lại trạng thái ca trực.");
                }
            } else if ("reject".equalsIgnoreCase(action)) {
                int requestId = Integer.parseInt(request.getParameter("requestId"));
                String rejectReason = request.getParameter("rejectReason");
                boolean ok = leaveCancelRequestDAO.rejectRequest(requestId, directorEmployeeId, rejectReason);
                if (ok) {
                    session.setAttribute("successMessage", "Đã từ chối yêu cầu hủy ca trực #" + requestId + ".");
                } else {
                    session.setAttribute("errorMessage", "Không thể từ chối yêu cầu #" + requestId + ".");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMessage", "Đã xảy ra lỗi: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/director/leave-requests");
    }
}
