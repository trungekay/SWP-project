package com.visioncare.controller;

import com.visioncare.dao.InvoiceDAO;
import com.visioncare.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "RefundRequestServlet", urlPatterns = {"/refund/request"})
public class RefundRequestServlet extends HttpServlet {

    private final InvoiceDAO invoiceDAO = new InvoiceDAO();

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

        String invoiceIdParam = request.getParameter("invoiceId");
        String appointmentIdParam = request.getParameter("appointmentId");
        String amountParam = request.getParameter("amount");
        String reason = request.getParameter("reason");
        String redirect = request.getParameter("redirect");

        if (amountParam != null && !amountParam.trim().isEmpty()) {
            try {
                long amount = Long.parseLong(amountParam.trim());
                boolean ok = false;
                if (appointmentIdParam != null && !appointmentIdParam.trim().isEmpty()) {
                    int apptId = Integer.parseInt(appointmentIdParam.replaceAll("[^0-9]", ""));
                    ok = invoiceDAO.createRefundRequestForAppointment(apptId, currentUser.getId(), amount, reason);
                    session.setAttribute(ok ? "successMessage" : "errorMessage", ok
                        ? "Đã gửi yêu cầu hoàn tiền #APT-" + apptId
                        : "Chỉ được hoàn tiền cho lịch đã được staff duyệt hủy trước check-in, đã thanh toán và chưa có yêu cầu hoàn tiền đang xử lý.");
                } else if (invoiceIdParam != null && !invoiceIdParam.trim().isEmpty()) {
                    int invoiceId = Integer.parseInt(invoiceIdParam.replaceAll("[^0-9]", ""));
                    if (invoiceDAO.hasActiveRefundRequest(invoiceId)) {
                        session.setAttribute("errorMessage", "Hóa đơn #INV-" + String.format("%05d", invoiceId) + " đã có yêu cầu hoàn tiền đang được xử lý hoặc đã duyệt thành công. Vui lòng không gửi yêu cầu trùng lặp!");
                    } else {
                        ok = invoiceDAO.createRefundRequest(invoiceId, currentUser.getId(), amount, reason);
                        if (ok) {

                            session.setAttribute("successMessage", "Yêu cầu hoàn tiền cho hóa đơn #INV-" + String.format("%05d", invoiceId) + " đã được gửi thành công tới nhân viên. ");
                        } else {
                            session.setAttribute("errorMessage", "Không thể gửi yêu cầu hoàn tiền. Quy định: Lịch phải được staff duyệt hủy trước check-in và đã thanh toán.");
                        }
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
                session.setAttribute("errorMessage", "Có lỗi xảy ra: " + e.getMessage());
            }
        }

        if ("appointment-history".equals(redirect)) {
            response.sendRedirect(request.getContextPath() + "/views/profile/appointment-history.jsp");
        } else {
            response.sendRedirect(request.getContextPath() + "/views/profile/refund-request.jsp");
        }
    }
}
