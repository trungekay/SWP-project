package com.visioncare.controller;

import com.visioncare.dao.ProcedureOrderDAO;
import com.visioncare.model.ProcedureOrder;
import com.visioncare.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Date;
import java.util.List;
import java.util.Map;

@WebServlet(name = "SpecialistWaitingListServlet", urlPatterns = {"/specialist/waiting-list"})
public class SpecialistWaitingListServlet extends HttpServlet {

    private final ProcedureOrderDAO procedureOrderDAO = new ProcedureOrderDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            HttpSession session = request.getSession();
            User currentUser = (User) session.getAttribute("user");

            Integer specialistId = null;
            if (currentUser != null && ("medical_specialist".equalsIgnoreCase(currentUser.getRole()) 
                    || "specialist".equalsIgnoreCase(currentUser.getRole())
                    || currentUser.getRoleId() == 4)) {
                specialistId = currentUser.getActorId() > 0 ? currentUser.getActorId() : null;
            }

            // Filter scope: "my" (only my orders / unassigned) or "all" (all clinic orders)
            String scope = request.getParameter("scope");
            if (scope == null || scope.isEmpty()) {
                scope = (specialistId != null) ? "my" : "all";
            }
            Integer filterSpecialistId = "my".equalsIgnoreCase(scope) ? specialistId : null;

            // Status filter: "all", "Pending", "Completed", "Cancelled" (default to "Pending" for waiting list)
            String status = request.getParameter("status");
            if (status == null || status.trim().isEmpty()) {
                status = "all";
            }

            // Search keyword
            String keyword = request.getParameter("keyword");
            if (keyword != null) {
                keyword = keyword.trim();
            }

            // Date filter (yyyy-MM-dd)
            String dateParam = request.getParameter("date");
            Date sqlDate = null;
            if (dateParam != null && !dateParam.trim().isEmpty()) {
                try {
                    sqlDate = Date.valueOf(dateParam.trim());
                } catch (IllegalArgumentException ignored) {
                }
            }

            // Retrieve data
            List<ProcedureOrder> orderList = procedureOrderDAO.getWaitingList(filterSpecialistId, status, keyword, sqlDate);
            Map<String, Integer> counts = procedureOrderDAO.getOrderStatusCounts(filterSpecialistId);

            request.setAttribute("orderList", orderList);
            request.setAttribute("statusCounts", counts);
            request.setAttribute("selectedStatus", status);
            request.setAttribute("keyword", keyword);
            request.setAttribute("selectedDate", dateParam);
            request.setAttribute("selectedScope", scope);
            request.setAttribute("currentSpecialistId", specialistId);

            request.getRequestDispatcher("/views/specialist/specialist-waiting-list.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Không thể tải danh sách hàng đợi cận lâm sàng: " + e.getMessage());
            request.getRequestDispatcher("/views/error/500.jsp").forward(request, response);
        }
    }
}
