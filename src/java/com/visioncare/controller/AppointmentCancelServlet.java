package com.visioncare.controller;

import com.visioncare.dao.AppointmentDAO;
import com.visioncare.dao.InvoiceDAO;
import com.visioncare.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "AppointmentCancelServlet", urlPatterns = {"/appointment/cancel"})
public class AppointmentCancelServlet extends HttpServlet {

    private final AppointmentDAO appointmentDAO = new AppointmentDAO();
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

        String idParam = request.getParameter("appointmentId");
        String reason = request.getParameter("reason");
        String requestRefund = request.getParameter("requestRefund");

        if (idParam != null && !idParam.trim().isEmpty()) {
            try {
                int appointmentId = Integer.parseInt(idParam.trim().replace("#APT-", ""));
                boolean requested = appointmentDAO.requestCancelAppointment(appointmentId, currentUser.getId(), reason);
                if (requested) {
                    invoiceDAO.createRefundRequestForAppointment(
                        appointmentId, 
                        currentUser.getId(), 
                        250000, 
                        "Hủy lịch hẹn #" + appointmentId + ": " + (reason != null && !reason.trim().isEmpty() ? reason : "Bận việc đột xuất")
                    );
                    session.setAttribute("successMessage", "Yêu cầu hủy lịch hẹn #" + appointmentId + " và hoàn tiền cọc đã được gửi tới nhân viên tiếp nhận. Trạng thái lịch chuyển sang 'Chờ duyệt', sau khi nhân viên duyệt thì lịch hẹn mới được hủy!");
                } else {
                    session.setAttribute("errorMessage", "Không thể gửi yêu cầu hủy lịch hẹn #" + appointmentId + " (Lịch không ở trạng thái 'Đã xác nhận' hoặc không thuộc tài khoản của bạn).");
                }
            } catch (Exception e) {
                e.printStackTrace();
                session.setAttribute("errorMessage", "Có lỗi xảy ra: " + e.getMessage());
            }
        }

        response.sendRedirect(request.getContextPath() + "/views/profile/appointment-history.jsp");
    }
}
