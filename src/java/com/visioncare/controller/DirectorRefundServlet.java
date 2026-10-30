package com.visioncare.controller;

import com.visioncare.dao.LeaveCancelRequestDAO;
import com.visioncare.dao.RefundDAO;
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

@WebServlet(name = "DirectorRefundServlet", urlPatterns = {"/director/refunds", "/director/refunds/detail", "/director/reschedule-requests"})
public class DirectorRefundServlet extends HttpServlet {

    private final RefundDAO refundDAO = new RefundDAO();
    private final LeaveCancelRequestDAO leaveCancelRequestDAO = new LeaveCancelRequestDAO();

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

        // Patient rescheduling is immediate after availability validation; no director approval queue.
        if ("/director/reschedule-requests".equals(request.getServletPath())) {
            response.sendRedirect(request.getContextPath() + "/director/dashboard");
            return;
        }
        com.visioncare.util.WorkflowTokens.ensure(session);
        String statusFilter = request.getParameter("status");
        if (statusFilter == null || statusFilter.isEmpty()) {
            statusFilter = "all";
        }

        List<Map<String, Object>> refunds = "/director/refunds/detail".equals(request.getServletPath()) ? List.of() : refundDAO.getAllRefundRequests(statusFilter);
        Map<String, Object> stats = refundDAO.getRefundStats();

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
        Map<String, Integer> leaveStats = leaveCancelRequestDAO.getStats();
        request.setAttribute("pendingLeaveCount", leaveStats.get("pending"));
        request.setAttribute("pendingRefundCount", stats.get("pending"));

        request.setAttribute("refunds", refunds);
        request.setAttribute("stats", stats);
        request.setAttribute("currentStatus", statusFilter);

        if("/director/refunds/detail".equals(request.getServletPath())){
            int id;try{id=Integer.parseInt(request.getParameter("id"));}catch(Exception e){response.sendError(400);return;}
            Map<String,Object> refund=refundDAO.getRefundRequest(id);if(refund==null){response.sendError(404);return;}
            request.setAttribute("refund",refund);
            request.getRequestDispatcher("/views/director/refund-detail.jsp").forward(request,response);return;
        }

        request.getRequestDispatcher("/views/director/refund-requests.jsp").forward(request, response);
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

        if (!"/director/refunds".equals(request.getServletPath())) {
            response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
            return;
        }
        int directorEmployeeId = getEmployeeId(currentUser.getId());
        if (directorEmployeeId <= 0) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Tài khoản chưa có hồ sơ nhân viên để duyệt yêu cầu.");
            return;
        }
        if(!com.visioncare.util.WorkflowTokens.valid(request)){response.sendError(403);return;}
        String action = request.getParameter("action");

        try {
            if("retry-email".equals(action)){new com.visioncare.dao.RefundMailDAO().retry(Integer.parseInt(request.getParameter("refundId")));}
            else if ("approve".equalsIgnoreCase(action)) {
                int refundId = Integer.parseInt(request.getParameter("refundId"));
                boolean ok = new com.visioncare.dao.RefundLifecycleDAO().decide(refundId, directorEmployeeId,true,request.getParameter("approvalNote"));
                if (ok) {
                    session.setAttribute("successMessage", "Giám đốc đã phê duyệt yêu cầu hoàn tiền #REF-" + refundId + " thành công!");
                } else {
                    session.setAttribute("errorMessage", "Không thể duyệt hoàn tiền cho yêu cầu #REF-" + refundId + ". Vui lòng kiểm tra lại trạng thái ca khám hoặc hóa đơn.");
                }
            } else if ("reject".equalsIgnoreCase(action)) {
                int refundId = Integer.parseInt(request.getParameter("refundId"));
                String note = request.getParameter("rejectNote");
                boolean ok = new com.visioncare.dao.RefundLifecycleDAO().decide(refundId, directorEmployeeId,false,note);
                if (ok) {
                    session.setAttribute("successMessage", "Đã từ chối yêu cầu hoàn tiền #REF-" + refundId + ".");
                } else {
                    session.setAttribute("errorMessage", "Không thể từ chối yêu cầu #" + refundId + ".");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMessage", "Đã xảy ra lỗi: " + e.getMessage());
        }

        String returnPath="/director/refunds";
        if("yes".equals(request.getParameter("returnToDetail"))){try{returnPath+="/detail?id="+Integer.parseInt(request.getParameter("refundId"));}catch(NumberFormatException ignored){}}
        response.sendRedirect(request.getContextPath() + returnPath);
    }
    private int getEmployeeId(int accountId) {
        try (java.sql.Connection conn = com.visioncare.dao.DBContext.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement("SELECT Employee_ID FROM Employee_Profile WHERE Account_ID = ?")) {
            ps.setInt(1, accountId);
            try (java.sql.ResultSet rs = ps.executeQuery()) { return rs.next() ? rs.getInt(1) : 0; }
        } catch (Exception e) { log("Cannot resolve refund approver", e); return 0; }
    }
}
