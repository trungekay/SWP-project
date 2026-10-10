package com.visioncare.controller;
import com.visioncare.dao.RoomDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
@WebServlet(name = "AdminRoomConfigServlet", urlPatterns = {"/admin/room-config"})
public class AdminRoomConfigServlet extends HttpServlet {
    private final RoomDAO roomDAO = new RoomDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/admin/clinic-config");
    }

    // Xử lý Form Submit (Thêm/Xóa)
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action"); // "add" hoặc "delete"

        try {
            if ("add".equals(action)) {
                String roomName = request.getParameter("roomName");
                String doctorIdStr = request.getParameter("doctorId");
                String specialistIdStr = request.getParameter("specialistId");
                if (roomName != null && !roomName.trim().isEmpty()) {
                    int newRoomId = roomDAO.addRoom(roomName.trim());
                    if (newRoomId > 0) {
                        com.visioncare.dao.DoctorDAO doctorDAO = new com.visioncare.dao.DoctorDAO();
                        if (doctorIdStr != null && !doctorIdStr.trim().isEmpty()) {
                            int doctorId = Integer.parseInt(doctorIdStr);
                            doctorDAO.assignDoctorToRoom(doctorId, newRoomId);
                        }
                        if (specialistIdStr != null && !specialistIdStr.trim().isEmpty()) {
                            int specialistId = Integer.parseInt(specialistIdStr);
                            doctorDAO.assignDoctorToRoom(specialistId, newRoomId);
                        }
                    }
                }
            } else if ("edit".equals(action)) {
                int roomId = Integer.parseInt(request.getParameter("roomId"));
                String roomName = request.getParameter("roomName");
                String doctorIdStr = request.getParameter("doctorId");
                String specialistIdStr = request.getParameter("specialistId");
                if (roomName != null && !roomName.trim().isEmpty()) {
                    roomDAO.updateRoom(roomId, roomName.trim());
                    com.visioncare.dao.DoctorDAO doctorDAO = new com.visioncare.dao.DoctorDAO();
                    // First unassign any doctor/specialist currently assigned to this room
                    doctorDAO.unassignDoctorFromRoom(roomId);
                    // Then assign the new ones if selected
                    if (doctorIdStr != null && !doctorIdStr.trim().isEmpty()) {
                        int doctorId = Integer.parseInt(doctorIdStr);
                        doctorDAO.assignDoctorToRoom(doctorId, roomId);
                    }
                    if (specialistIdStr != null && !specialistIdStr.trim().isEmpty()) {
                        int specialistId = Integer.parseInt(specialistIdStr);
                        doctorDAO.assignDoctorToRoom(specialistId, roomId);
                    }
                }
            } else if ("delete".equals(action)) {
                int roomId = Integer.parseInt(request.getParameter("roomId"));
                roomDAO.deleteRoom(roomId);
            } else if ("assign_doctor".equals(action)) {
                int doctorId = Integer.parseInt(request.getParameter("doctorId"));
                int roomId = Integer.parseInt(request.getParameter("roomId"));
                com.visioncare.dao.DoctorDAO doctorDAO = new com.visioncare.dao.DoctorDAO();
                doctorDAO.assignDoctorToRoom(doctorId, roomId);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMsg", "Không thể thực hiện thao tác. Có thể phòng đang được sử dụng.");
        }
        
        String redirectTab = request.getParameter("tab");
        if (redirectTab == null || redirectTab.trim().isEmpty()) {
            redirectTab = "rooms";
        }
        response.sendRedirect(request.getContextPath() + "/admin/clinic-config?tab=" + redirectTab);
    }
}
