package com.visioncare.controller;

import com.visioncare.dao.LeaveCancelRequestDAO;
import com.visioncare.dao.RefundDAO;
import com.visioncare.dao.WorkScheduleDAO;
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

@WebServlet(name = "DirectorDashboardServlet", urlPatterns = {"/director", "/director/dashboard"})
public class DirectorDashboardServlet extends HttpServlet {

    private final WorkScheduleDAO workScheduleDAO = new WorkScheduleDAO();
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
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập trang tổng quan Giám đốc.");
            return;
        }

        try {
            // Personnel counts
            List<User> doctors = workScheduleDAO.getEmployeesByRoleType("doctor");
            List<User> specialists = workScheduleDAO.getEmployeesByRoleType("specialist");
            List<User> staffs = workScheduleDAO.getEmployeesByRoleType("staff");

            int doctorCount = doctors != null ? doctors.size() : 0;
            int specialistCount = specialists != null ? specialists.size() : 0;
            int staffCount = staffs != null ? staffs.size() : 0;

            // Stats
            Map<String, Integer> leaveStats = leaveCancelRequestDAO.getStats();
            Map<String, Object> refundStats = refundDAO.getRefundStats();

            // Recent Pending Requests
            List<LeaveCancelRequest> pendingLeaveRequests = leaveCancelRequestDAO.getAllRequests("Pending", "all");
            List<Map<String, Object>> pendingRefundRequests = refundDAO.getAllRefundRequests("Pending");

            request.setAttribute("doctorCount", doctorCount);
            request.setAttribute("specialistCount", specialistCount);
            request.setAttribute("staffCount", staffCount);
            request.setAttribute("totalPersonnel", doctorCount + specialistCount + staffCount);

            request.setAttribute("leaveStats", leaveStats);
            request.setAttribute("refundStats", refundStats);

            request.setAttribute("pendingLeaveCount", leaveStats.get("pending"));
            request.setAttribute("pendingRefundCount", refundStats.get("pending"));

            request.setAttribute("recentLeaveRequests", pendingLeaveRequests);
            request.setAttribute("recentRefundRequests", pendingRefundRequests);

            request.getRequestDispatcher("/views/director/dashboard.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.setContentType("text/html;charset=UTF-8");
            response.getWriter().println("<h3>Lỗi khi tải bảng điều khiển Giám đốc: " + e.getMessage() + "</h3>");
        }
    }
}
