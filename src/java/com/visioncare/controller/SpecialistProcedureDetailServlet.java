package com.visioncare.controller;

import com.visioncare.dao.ProcedureOrderDAO;
import com.visioncare.model.MedicalRecord;
import com.visioncare.model.ProcedureOrder;
import com.visioncare.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

/**
 * Controller cho Màn hình Thực hiện Thủ thuật & Nhập kết quả (Screen 36 - Procedure Execution Detail Screen)
 * Phục vụ cho Kỹ thuật viên (Specialist) thực hiện:
 * 1. View examination report (Xem chẩn đoán & phiếu khám của Bác sĩ)
 * 2. View To-do list (Xem danh sách các chỉ định/thủ thuật của ca khám)
 * 3. Update procedure status (Cập nhật trạng thái Pending -> Completed/Cancelled và lưu kết quả cận lâm sàng)
 */
@WebServlet(name = "SpecialistProcedureDetailServlet", urlPatterns = {"/specialist/procedure-detail"})
public class SpecialistProcedureDetailServlet extends HttpServlet {

    private final ProcedureOrderDAO procedureOrderDAO = new ProcedureOrderDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");

        // 1. Kiểm tra đăng nhập
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // 2. Kiểm tra phân quyền
        String role = currentUser.getRole() != null ? currentUser.getRole().trim().toLowerCase() : "";
        if (!role.equals("medical_specialist") && !role.equals("doctor") && !role.equals("admin") && !role.equals("staff")) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        // 3. Đọc orderId
        String orderIdStr = request.getParameter("orderId");
        if (orderIdStr == null || orderIdStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/specialist/waiting-list");
            return;
        }

        try {
            int orderId = Integer.parseInt(orderIdStr.trim());
            ProcedureOrder order = procedureOrderDAO.getOrderById(orderId);
            if (order == null) {
                session.setAttribute("errorMessage", "Không tìm thấy thông tin ca thủ thuật #" + orderId);
                response.sendRedirect(request.getContextPath() + "/specialist/waiting-list");
                return;
            }

            // Feature 1: View examination report (Lấy phiếu khám & chẩn đoán ban đầu của BS)
            MedicalRecord record = procedureOrderDAO.getMedicalRecordById(order.getRecordId());

            // Feature 2: View To-do list (Lấy toàn bộ các thủ thuật cần làm trong cùng ca khám này)
            List<ProcedureOrder> todoList = procedureOrderDAO.getTodoListByRecordId(order.getRecordId());

            request.setAttribute("order", order);
            request.setAttribute("record", record);
            request.setAttribute("todoList", todoList);

            request.getRequestDispatcher("/views/specialist/specialist-procedure-detail.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/specialist/waiting-list");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMessage", "Có lỗi hệ thống khi tải thông tin ca thủ thuật: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/specialist/waiting-list");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String orderIdStr = request.getParameter("orderId");
        String action = request.getParameter("action");

        if (orderIdStr == null || orderIdStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/specialist/waiting-list");
            return;
        }

        try {
            int orderId = Integer.parseInt(orderIdStr.trim());
            ProcedureOrder order = procedureOrderDAO.getOrderById(orderId);
            if (order == null) {
                session.setAttribute("errorMessage", "Không tìm thấy thông tin ca chỉ định.");
                response.sendRedirect(request.getContextPath() + "/specialist/waiting-list");
                return;
            }

            String examinationResult = request.getParameter("examinationResult");
            String conclusion = request.getParameter("conclusion");

            // Feature 3: Update procedure status
            if ("complete".equalsIgnoreCase(action)) {
                // Hoàn thành thủ thuật: Đổi Status -> Completed, gán KTV đăng nhập
                procedureOrderDAO.updateOrderStatus(orderId, currentUser.getId(), "Completed");

                // Lưu kết quả đo và kết luận cận lâm sàng
                if (examinationResult != null || conclusion != null) {
                    procedureOrderDAO.updateMedicalRecordResults(
                            order.getRecordId(),
                            examinationResult != null ? examinationResult.trim() : "",
                            conclusion != null ? conclusion.trim() : ""
                    );
                }

                session.setAttribute("successMessage", "Đã hoàn thành thủ thuật và cập nhật kết quả thành công cho ca #CD-" + orderId + "!");
                response.sendRedirect(request.getContextPath() + "/specialist/procedure-detail?orderId=" + orderId);

            } else if ("cancel".equalsIgnoreCase(action)) {
                // Hủy ca thủ thuật
                procedureOrderDAO.updateOrderStatus(orderId, currentUser.getId(), "Cancelled");
                session.setAttribute("infoMessage", "Đã hủy ca chỉ định #CD-" + orderId + ".");
                response.sendRedirect(request.getContextPath() + "/specialist/waiting-list");

            } else if ("updateResults".equalsIgnoreCase(action)) {
                // Cập nhật bổ sung kết quả
                if (examinationResult != null || conclusion != null) {
                    procedureOrderDAO.updateMedicalRecordResults(
                            order.getRecordId(),
                            examinationResult != null ? examinationResult.trim() : "",
                            conclusion != null ? conclusion.trim() : ""
                    );
                }
                session.setAttribute("successMessage", "Đã lưu cập nhật kết quả cận lâm sàng thành công!");
                response.sendRedirect(request.getContextPath() + "/specialist/procedure-detail?orderId=" + orderId);

            } else {
                response.sendRedirect(request.getContextPath() + "/specialist/procedure-detail?orderId=" + orderId);
            }

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMessage", "Có lỗi khi cập nhật trạng thái thủ thuật: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/specialist/waiting-list");
        }
    }
}
