package com.visioncare.controller;

import com.visioncare.dao.InvoiceDAO;
import com.visioncare.dao.ProcedurePaymentDAO;
import com.visioncare.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.temporal.TemporalAdjusters;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@WebServlet(name = "AdminBillingServlet", urlPatterns = {"/admin/billing", "/admin/dashboard", "/staff/payments"})
public class AdminBillingServlet extends HttpServlet {

    private final InvoiceDAO invoiceDAO = new InvoiceDAO();
    private final ProcedurePaymentDAO procedurePaymentDAO = new ProcedurePaymentDAO();

    private boolean isStaffPage(HttpServletRequest request) {
        return request.getServletPath().startsWith("/staff/");
    }

    private String billingPath(HttpServletRequest request) {
        return isStaffPage(request) ? "/staff/payments" : "/admin/billing";
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");

        // Optional check: if not logged in or role not admin/staff/manager
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        if (currentUser.getRoleId() != 1 && currentUser.getRoleId() != 2 && currentUser.getRoleId() != 5) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String action = request.getParameter("action");
        String format = request.getParameter("format");

        // AJAX API to get detail as JSON
        if ("detail".equalsIgnoreCase(action) && "json".equalsIgnoreCase(format)) {
            response.setContentType("application/json;charset=UTF-8");
            String idParam = request.getParameter("id");
            if (idParam != null) {
                try {
                    int invId = Integer.parseInt(idParam);
                    Map<String, Object> detail = invoiceDAO.getInvoiceDetail(invId);
                    if (detail != null) {
                        PrintWriter out = response.getWriter();
                        out.print(toJson(detail));
                        out.flush();
                        return;
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            response.getWriter().print("{\"error\":\"Invoice not found\"}");
            return;
        }

        // Handle flash messages
        if (session.getAttribute("successMessage") != null) {
            request.setAttribute("successMessage", session.getAttribute("successMessage"));
            session.removeAttribute("successMessage");
        }
        if (session.getAttribute("errorMessage") != null) {
            request.setAttribute("errorMessage", session.getAttribute("errorMessage"));
            session.removeAttribute("errorMessage");
        }

        String search = request.getParameter("search");
        String status = request.getParameter("status");
        String timeRange = request.getParameter("timeRange");
        String selectedMonthStr = request.getParameter("selectedMonth");
        String selectedQuarterStr = request.getParameter("selectedQuarter");
        String selectedYearStr = request.getParameter("selectedYear");
        String customDateFrom = request.getParameter("dateFrom");
        String customDateTo = request.getParameter("dateTo");

        LocalDate today = LocalDate.now();
        int currentYear = today.getYear();
        int currentMonth = today.getMonthValue();
        int currentQuarter = (currentMonth - 1) / 3 + 1;

        if (timeRange == null || timeRange.trim().isEmpty()) {
            if ((customDateFrom != null && !customDateFrom.trim().isEmpty()) ||
                (customDateTo != null && !customDateTo.trim().isEmpty())) {
                timeRange = "custom";
            } else {
                timeRange = "today";
            }
        }

        int selectedYear = currentYear;
        if (selectedYearStr != null && !selectedYearStr.trim().isEmpty()) {
            try { selectedYear = Integer.parseInt(selectedYearStr.trim()); } catch (NumberFormatException ignored) {}
        }

        int selectedMonth = currentMonth;
        if (selectedMonthStr != null && !selectedMonthStr.trim().isEmpty()) {
            try { selectedMonth = Integer.parseInt(selectedMonthStr.trim()); } catch (NumberFormatException ignored) {}
        }

        int selectedQuarter = currentQuarter;
        if (selectedQuarterStr != null && !selectedQuarterStr.trim().isEmpty()) {
            try { selectedQuarter = Integer.parseInt(selectedQuarterStr.trim()); } catch (NumberFormatException ignored) {}
        }

        String computedDateFrom = null;
        String computedDateTo = null;
        String periodLabel = "Hôm nay";
        DateTimeFormatter vnDateFmt = DateTimeFormatter.ofPattern("dd/MM/yyyy");

        switch (timeRange) {
            case "today":
                computedDateFrom = today.toString();
                computedDateTo = today.toString();
                periodLabel = "Hôm nay (" + today.format(vnDateFmt) + ")";
                break;
            case "this_month":
            case "by_month":
                timeRange = "by_month";
                LocalDate firstDayMonth = LocalDate.of(selectedYear, selectedMonth, 1);
                LocalDate lastDayMonth = firstDayMonth.with(TemporalAdjusters.lastDayOfMonth());
                computedDateFrom = firstDayMonth.toString();
                computedDateTo = lastDayMonth.toString();
                periodLabel = "Tháng " + selectedMonth + "/" + selectedYear;
                break;
            case "by_quarter":
                int qStartMonth = (selectedQuarter - 1) * 3 + 1;
                int qEndMonth = qStartMonth + 2;
                LocalDate firstDayQ = LocalDate.of(selectedYear, qStartMonth, 1);
                LocalDate lastDayQ = LocalDate.of(selectedYear, qEndMonth, 1).with(TemporalAdjusters.lastDayOfMonth());
                computedDateFrom = firstDayQ.toString();
                computedDateTo = lastDayQ.toString();
                periodLabel = "Quý " + selectedQuarter + "/" + selectedYear + " (Tháng " + qStartMonth + " - " + qEndMonth + ")";
                break;
            case "custom":
                computedDateFrom = (customDateFrom != null && !customDateFrom.trim().isEmpty()) ? customDateFrom.trim() : null;
                computedDateTo = (customDateTo != null && !customDateTo.trim().isEmpty()) ? customDateTo.trim() : null;
                if (computedDateFrom != null && computedDateTo != null) {
                    if (computedDateTo.compareTo(computedDateFrom) < 0) {
                        request.setAttribute("errorMessage", "Ngày kết thúc phải lớn hơn hoặc bằng ngày bắt đầu!");
                        String temp = computedDateFrom;
                        computedDateFrom = computedDateTo;
                        computedDateTo = temp;
                    }
                    try {
                        LocalDate dFrom = LocalDate.parse(computedDateFrom);
                        LocalDate dTo = LocalDate.parse(computedDateTo);
                        periodLabel = dFrom.format(vnDateFmt) + " - " + dTo.format(vnDateFmt);
                    } catch (Exception ex) {
                        periodLabel = "Từ " + computedDateFrom + " đến " + computedDateTo;
                    }
                } else if (computedDateFrom != null) {
                    periodLabel = "Từ " + computedDateFrom;
                } else if (computedDateTo != null) {
                    periodLabel = "Đến " + computedDateTo;
                } else {
                    periodLabel = "Tự do";
                }
                break;
            case "all":
            default:
                timeRange = "all";
                computedDateFrom = null;
                computedDateTo = null;
                periodLabel = "Toàn thời gian";
                break;
        }

        try {
            Map<String, Object> stats = invoiceDAO.getBillingStats(computedDateFrom, computedDateTo);
            List<Map<String, Object>> invoices = invoiceDAO.getAllInvoices(search, status, computedDateFrom, computedDateTo);
            List<Map<String, Object>> procedureRequests = procedurePaymentDAO.listRequests();
            String csrf = (String) session.getAttribute("procedurePaymentCsrf");
            if (csrf == null) {
                csrf = UUID.randomUUID().toString();
                session.setAttribute("procedurePaymentCsrf", csrf);
            }

            request.setAttribute("stats", stats);
            request.setAttribute("invoices", invoices);
            request.setAttribute("procedureRequests", procedureRequests);
            request.setAttribute("procedurePaymentCsrf", csrf);
            request.setAttribute("staffBilling", isStaffPage(request));
            request.setAttribute("billingPath", billingPath(request));
            request.setAttribute("search", search);
            request.setAttribute("status", status != null ? status : "all");
            request.setAttribute("timeRange", timeRange);
            request.setAttribute("selectedMonth", selectedMonth);
            request.setAttribute("selectedQuarter", selectedQuarter);
            request.setAttribute("selectedYear", selectedYear);
            request.setAttribute("currentYear", currentYear);
            request.setAttribute("currentMonth", currentMonth);
            request.setAttribute("currentQuarter", currentQuarter);
            request.setAttribute("dateFrom", customDateFrom != null ? customDateFrom : computedDateFrom);
            request.setAttribute("dateTo", customDateTo != null ? customDateTo : computedDateTo);
            request.setAttribute("periodLabel", periodLabel);

            // If a specific ID is selected, pre-load it for modal view
            String selectedIdParam = request.getParameter("id");
            if (selectedIdParam != null && !selectedIdParam.isEmpty()) {
                try {
                    int selId = Integer.parseInt(selectedIdParam);
                    Map<String, Object> selectedInvoice = invoiceDAO.getInvoiceDetail(selId);
                    request.setAttribute("selectedInvoice", selectedInvoice);
                } catch (NumberFormatException ignored) {}
            }

            request.getRequestDispatcher("/views/admin/billing.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi khi tải dữ liệu hóa đơn: " + e.getMessage());
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        User currentUser = session == null ? null : (User) session.getAttribute("user");
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        if (currentUser.getRoleId() != 1 && currentUser.getRoleId() != 2 && currentUser.getRoleId() != 5) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String action = request.getParameter("action");
        String idParam = request.getParameter("invoiceId");

        if ("confirm-procedure".equals(action)) {
            String expected = (String) session.getAttribute("procedurePaymentCsrf");
            if (expected == null || !expected.equals(request.getParameter("csrfToken"))) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
            try {
                int orderId = Integer.parseInt(request.getParameter("orderId"));
                boolean paid = procedurePaymentDAO.confirm(orderId, currentUser.getActorId(), request.getParameter("paymentMethod"));
                session.setAttribute(paid ? "successMessage" : "errorMessage", paid
                        ? "Đã xác nhận thanh toán ca #CD-" + orderId + ". Specialist có thể tiếp nhận."
                        : "Không thể xác nhận ca #CD-" + orderId + ". Vui lòng kiểm tra trạng thái yêu cầu.");
            } catch (Exception error) {
                log("Cannot confirm surgery payment", error);
                session.setAttribute("errorMessage", "Chưa thể ghi nhận thanh toán phẫu thuật. Vui lòng thử lại.");
            }
            response.sendRedirect(request.getContextPath() + billingPath(request));
            return;
        }

        if ("update-status".equalsIgnoreCase(action) && idParam != null) {
            try {
                int invoiceId = Integer.parseInt(idParam);
                String newStatus = request.getParameter("newStatus");
                String paymentMethod = request.getParameter("paymentMethod");
                String amountStr = request.getParameter("amount");

                long amount = 0;
                if (amountStr != null && !amountStr.trim().isEmpty()) {
                    amount = Long.parseLong(amountStr.replaceAll("[^0-9]", ""));
                }

                boolean updated = invoiceDAO.updateInvoiceStatus(invoiceId, newStatus, paymentMethod, amount);
                if (updated) {
                    session.setAttribute("successMessage", "Cập nhật trạng thái hóa đơn #" + invoiceId + " thành công!");
                } else {
                    session.setAttribute("errorMessage", "Không thể cập nhật hóa đơn #" + invoiceId);
                }
            } catch (Exception e) {
                e.printStackTrace();
                session.setAttribute("errorMessage", "Lỗi: " + e.getMessage());
            }
        }

        response.sendRedirect(request.getContextPath() + billingPath(request));
    }

    /**
     * Minimal JSON serializer for invoice detail map without external library dependency
     */
    private String toJson(Map<String, Object> map) {
        StringBuilder sb = new StringBuilder("{");
        boolean first = true;
        for (Map.Entry<String, Object> entry : map.entrySet()) {
            if (!first) sb.append(",");
            sb.append("\"").append(escapeJson(entry.getKey())).append("\":");
            Object val = entry.getValue();
            if (val == null) {
                sb.append("null");
            } else if (val instanceof Number || val instanceof Boolean) {
                sb.append(val);
            } else if (val instanceof List) {
                sb.append("[");
                List<?> list = (List<?>) val;
                for (int i = 0; i < list.size(); i++) {
                    if (i > 0) sb.append(",");
                    Object item = list.get(i);
                    if (item instanceof Map) {
                        @SuppressWarnings("unchecked")
                        Map<String, Object> m = (Map<String, Object>) item;
                        sb.append(toJson(m));
                    } else {
                        sb.append("\"").append(escapeJson(String.valueOf(item))).append("\"");
                    }
                }
                sb.append("]");
            } else {
                sb.append("\"").append(escapeJson(String.valueOf(val))).append("\"");
            }
            first = false;
        }
        sb.append("}");
        return sb.toString();
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\b", "\\b")
                .replace("\f", "\\f")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}
