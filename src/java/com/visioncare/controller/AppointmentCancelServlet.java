package com.visioncare.controller;

import com.visioncare.dao.AppointmentDAO;
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

        if (idParam != null && !idParam.trim().isEmpty()) {
            try {
                int appointmentId = Integer.parseInt(idParam.trim().replace("#APT-", "").replace("APT-", "").replace("#", ""));
                com.visioncare.model.Appointment appt = appointmentDAO.getAppointmentDetailById(appointmentId);

                if (appt != null && "Pending".equalsIgnoreCase(appt.getStatus()) && !"Paid".equalsIgnoreCase(appt.getInvoiceStatus()) && !"Partial_Paid".equalsIgnoreCase(appt.getInvoiceStatus())) {
                    // Lịch chưa thanh toán cọc -> Bệnh nhân có thể hủy trực tiếp và giải phóng slot ngay
                    boolean cancelled = appointmentDAO.cancelAppointment(appointmentId, currentUser.getId(), reason);
                    if (cancelled) {
                        session.setAttribute("successMessage", "Đã hủy lịch hẹn #" + appointmentId + " thành công.");
                    } else {
                        session.setAttribute("errorMessage", "Không thể hủy lịch hẹn #" + appointmentId + ".");
                    }
                } else {
                    // Lịch đã xác nhận (đã thanh toán cọc) -> Gửi yêu cầu duyệt hủy, chưa tạo yêu cầu hoàn tiền
                    boolean requested = appointmentDAO.requestCancelAppointment(appointmentId, currentUser.getId(), reason);
                    if (requested) {
                        session.setAttribute("successMessage", "Đã gửi yêu cầu hủy lịch #APT-" + appointmentId + ". Sau khi staff duyệt hủy, bạn mới có thể tạo yêu cầu hoàn tiền.");
                    } else {
                        session.setAttribute("errorMessage", "Không thể gửi yêu cầu hủy lịch hẹn #" + appointmentId + " (Lịch không ở trạng thái 'Đã xác nhận' hoặc không thuộc tài khoản của bạn).");
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
                session.setAttribute("errorMessage", "Có lỗi xảy ra: " + e.getMessage());
            }
        }

        response.sendRedirect(request.getContextPath() + "/views/profile/appointment-history.jsp");
    }
}
