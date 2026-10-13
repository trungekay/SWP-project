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
import java.util.Map;

@WebServlet(name = "InvoiceDetailServlet", urlPatterns = {"/profile/invoice-detail"})
public class InvoiceDetailServlet extends HttpServlet {

    private final InvoiceDAO invoiceDAO = new InvoiceDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/views/profile/medical-history.jsp");
            return;
        }

        try {
            int invoiceId = Integer.parseInt(idParam.trim());
            Map<String, Object> invoice;

            String role = currentUser.getRole() != null ? currentUser.getRole().trim() : "";
            if ("admin".equalsIgnoreCase(role) || "staff".equalsIgnoreCase(role) || "manager".equalsIgnoreCase(role) || "doctor".equalsIgnoreCase(role)) {
                invoice = invoiceDAO.getInvoiceDetail(invoiceId);
            } else {
                invoice = invoiceDAO.getInvoiceDetailForPatient(invoiceId, currentUser.getId());
            }

            if (invoice == null) {
                session.setAttribute("error", "Không tìm thấy hóa đơn hoặc bạn không có quyền xem hóa đơn này.");
                response.sendRedirect(request.getContextPath() + "/views/profile/medical-history.jsp");
                return;
            }

            request.setAttribute("invoice", invoice);
            request.getRequestDispatcher("/views/profile/invoice-detail.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/views/profile/medical-history.jsp");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/views/profile/medical-history.jsp");
        }
    }
}
