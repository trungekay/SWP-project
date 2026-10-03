package com.visioncare.controller;
import com.visioncare.dao.TimeSlotDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
@WebServlet(name = "AdminTimeSlotConfigServlet", urlPatterns = {"/admin/timeslot-config"})
public class AdminTimeSlotConfigServlet extends HttpServlet {
    private final TimeSlotDAO timeSlotDAO = new TimeSlotDAO();
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        try {
            if ("add".equals(action)) {
                String workDate = request.getParameter("workDate");
                String slotName = request.getParameter("slotName");
                String startTime = request.getParameter("startTime");
                String endTime = request.getParameter("endTime");
                String session = request.getParameter("session");
                timeSlotDAO.addTimeSlot(workDate, slotName, startTime, endTime, session);
            } else if ("edit".equals(action)) {
                String oldSlotName = request.getParameter("oldSlotName");
                String newSlotName = request.getParameter("slotName");
                String startTime = request.getParameter("startTime");
                String endTime = request.getParameter("endTime");
                String status = request.getParameter("status");
                timeSlotDAO.updateTimeSlotConfig(oldSlotName, newSlotName, startTime, endTime, status);
            } else if ("delete".equals(action)) {
                int scheduleId = Integer.parseInt(request.getParameter("scheduleId"));
                boolean success = timeSlotDAO.deleteTimeSlot(scheduleId);
                if (!success) {
                    request.getSession().setAttribute("errorMsg", "Không thể xóa Slot này vì đã có bệnh nhân đặt hoặc dữ liệu không tồn tại!");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMsg", "Lỗi cấu hình Slot: " + e.getMessage());
        }
        response.sendRedirect(request.getContextPath() + "/admin/clinic-config");
    }
}
