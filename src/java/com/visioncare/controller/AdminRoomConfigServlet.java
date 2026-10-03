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
        try {
            request.setAttribute("rooms", roomDAO.getAll());
            request.getRequestDispatcher("/views/admin/room-config.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
        }
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
                if (roomName != null && !roomName.trim().isEmpty()) {
                    int newRoomId = roomDAO.addRoom(roomName.trim());
                    if (newRoomId > 0 && doctorIdStr != null && !doctorIdStr.trim().isEmpty()) {
                        int doctorId = Integer.parseInt(doctorIdStr);
                        com.visioncare.dao.DoctorDAO doctorDAO = new com.visioncare.dao.DoctorDAO();
                        doctorDAO.assignDoctorToRoom(doctorId, newRoomId);
                    }
                }
            } else if ("edit".equals(action)) {
                int roomId = Integer.parseInt(request.getParameter("roomId"));
                String roomName = request.getParameter("roomName");
                String doctorIdStr = request.getParameter("doctorId");
                if (roomName != null && !roomName.trim().isEmpty()) {
                    roomDAO.updateRoom(roomId, roomName.trim());
                    com.visioncare.dao.DoctorDAO doctorDAO = new com.visioncare.dao.DoctorDAO();
                    // First unassign any doctor currently assigned to this room
                    doctorDAO.unassignDoctorFromRoom(roomId);
                    // Then assign the new one if selected
                    if (doctorIdStr != null && !doctorIdStr.trim().isEmpty()) {
                        int doctorId = Integer.parseInt(doctorIdStr);
                        doctorDAO.assignDoctorToRoom(doctorId, roomId);
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
        
        response.sendRedirect(request.getContextPath() + "/admin/room-config");
    }
}
