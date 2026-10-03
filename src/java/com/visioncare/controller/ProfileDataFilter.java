package com.visioncare.controller;

import com.visioncare.dao.AppointmentDAO;
import com.visioncare.dao.HistoryDAO;
import com.visioncare.model.Appointment;
import com.visioncare.model.User;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebFilter(filterName = "ProfileDataFilter", urlPatterns = {"/views/profile/*"})
public class ProfileDataFilter implements Filter {

    private AppointmentDAO appointmentDAO = new AppointmentDAO();
    private HistoryDAO historyDAO = new HistoryDAO();

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest req = (HttpServletRequest) request;
        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user != null) {
            String path = req.getRequestURI();
            try {
                if (path.endsWith("appointment-history.jsp")) {
                    List<Appointment> appointments = appointmentDAO.getByUserId(user.getId());
                    req.setAttribute("appointments", appointments);
                } else if (path.endsWith("medical-history.jsp")) {
                    req.setAttribute("records", historyDAO.getMedicalRecords(user.getId()));
                    req.setAttribute("invoices", historyDAO.getInvoices(user.getId()));
                } else if (path.endsWith("refund-request.jsp")) {
                    req.setAttribute("refunds", historyDAO.getRefunds(user.getId()));
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        
        chain.doFilter(request, response);
    }
}
