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
                String slotName = request.getParameter("slotName");
                String startTime = request.getParameter("startTime");
                String endTime = request.getParameter("endTime");

                if (!timeSlotDAO.isStartTimeValid(startTime)) {
                    request.getSession().setAttribute("errorMsg", "Không thể thêm ca. Ca mới phải bắt đầu sau khi các ca hiện tại kết thúc!");
                    response.sendRedirect(request.getContextPath() + "/admin/clinic-config?tab=slots");
                    return;
                }

                timeSlotDAO.addTimeSlot(slotName, startTime, endTime);
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
            } else if ("update_min_hours".equals(action)) {
                String hoursStr = request.getParameter("minWorkHours");
                if (hoursStr != null && !hoursStr.trim().isEmpty()) {
                    try {
                        double hours = Double.parseDouble(hoursStr.trim());
                        double maxWeeklyHours = timeSlotDAO.getMaxWeeklyAvailableHours();
                        if (hours < 0 || (maxWeeklyHours > 0 && hours > maxWeeklyHours)) {
                            request.getSession().setAttribute("errorMsg", "Số giờ làm việc tối thiểu không hợp lệ! Con số này phải từ 0 đến tối đa tổng số giờ làm trong tuần hiện có (" + String.format("%.1f", maxWeeklyHours) + " giờ)!");
                        } else {
                            boolean success = timeSlotDAO.updateMinWeeklyWorkingHours(hours);
                            if (success) {
                                request.getSession().setAttribute("successMsg", "Đã cập nhật quy định số giờ làm việc tối thiểu thành công (" + hours + " giờ/tuần)!");
                            } else {
                                request.getSession().setAttribute("errorMsg", "Không thể cập nhật số giờ làm việc tối thiểu!");
                            }
                        }
                    } catch (NumberFormatException e) {
                        request.getSession().setAttribute("errorMsg", "Vui lòng nhập định dạng số hợp lệ cho số giờ làm việc!");
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMsg", "Lỗi cấu hình Slot: " + e.getMessage());
        }

        if ("update_min_hours".equals(action)) {
            response.sendRedirect(request.getContextPath() + "/admin/clinic-config?tab=rules");
            return;
        }
        response.sendRedirect(request.getContextPath() + "/admin/clinic-config?tab=slots");
    }
}
