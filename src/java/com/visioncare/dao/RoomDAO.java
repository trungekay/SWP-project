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
    public int addRoom(String roomName) throws Exception {
        String sql = "INSERT INTO Room (Room_Name) VALUES (?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, java.sql.Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, roomName); 
            int affectedRows = ps.executeUpdate();
            if (affectedRows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            }
            return -1;
        }
    }
    public boolean deleteRoom(int roomId) throws Exception {
        String sql = "DELETE FROM Room WHERE Room_ID = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, roomId);
            return ps.executeUpdate() > 0;
        }
    }
    public boolean updateRoom(int roomId, String roomName) throws Exception {
        String sql = "UPDATE Room SET Room_Name = ? WHERE Room_ID = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, roomName);
            ps.setInt(2, roomId);
            return ps.executeUpdate() > 0;
        }
    }
}
