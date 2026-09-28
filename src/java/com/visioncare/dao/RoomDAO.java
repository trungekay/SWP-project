package com.visioncare.dao;

import com.visioncare.model.Room;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class RoomDAO {
    public List<Room> getAll() throws Exception {
        List<Room> list = new ArrayList<>();
        String sql = "SELECT * FROM Room ORDER BY Room_ID";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new Room(rs.getInt("Room_ID"), rs.getString("Room_Name")));
            }
        }
        return list;
    }
    // Thêm phòng mới (Create)
    public boolean addRoom(String roomName) throws Exception {
        String sql = "INSERT INTO Room (Room_Name) VALUES (?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, roomName); // Ngăn chặn SQL Injection
            return ps.executeUpdate() > 0;
        }
    }

    // Xóa phòng (Delete)
    public boolean deleteRoom(int roomId) throws Exception {
        String sql = "DELETE FROM Room WHERE Room_ID = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, roomId);
            return ps.executeUpdate() > 0;
        }
    }
}
