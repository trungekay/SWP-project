package com.visioncare.controller;

import com.visioncare.dao.AdminDashboardDAO;
import com.visioncare.dao.InvoiceDAO;
import com.visioncare.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.time.LocalDate;
import java.time.ZoneId;

@WebServlet(name = "AdminDashboardServlet", urlPatterns = {"/admin/dashboard"})
public class AdminDashboardServlet extends HttpServlet {

    private final InvoiceDAO invoiceDAO = new InvoiceDAO();
    private final AdminDashboardDAO dashboardDAO = new AdminDashboardDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User currentUser = session == null ? null : (User) session.getAttribute("user");
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        if (currentUser.getRoleId() != 1 && currentUser.getRoleId() != 2) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        try {
            AdminDashboardDAO.AttendanceSummary attendance =
                    dashboardDAO.getAttendanceSummary(LocalDate.now(ZoneId.of("Asia/Ho_Chi_Minh")));
            request.setAttribute("stats", invoiceDAO.getBillingStats());
            request.setAttribute("attendance", attendance);
            request.setAttribute("attendanceRate", attendance.getRatePercent());
            request.getRequestDispatcher("/views/admin/dashboard.jsp").forward(request, response);
        } catch (Exception e) {
            throw new ServletException("Không tải được thống kê dashboard.", e);
        }
    }
}
