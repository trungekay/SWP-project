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

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        try {
            if ("add".equals(action)) {
                String roomName = request.getParameter("roomName");
                if (roomName != null && !roomName.trim().isEmpty()) {
                    roomDAO.addRoom(roomName.trim());
                }
            } else if ("delete".equals(action)) {
                int roomId = Integer.parseInt(request.getParameter("roomId"));
                roomDAO.deleteRoom(roomId);
            }
        } catch (Exception e) {
            e.printStackTrace();

            request.getSession().setAttribute("errorMsg", "Không thể thực hiện thao tác. Có thể phòng đang được sử dụng.");
        }
        
        response.sendRedirect(request.getContextPath() + "/admin/room-config");
    }
}
