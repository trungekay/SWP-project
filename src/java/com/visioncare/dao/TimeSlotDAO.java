package com.visioncare.dao;

import com.visioncare.model.TimeSlotConfig;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class TimeSlotDAO {
    public List<TimeSlotConfig> getConfiguredSlots() throws Exception {
        List<TimeSlotConfig> list = new ArrayList<>();
        // Query unique time slots from Work_Schedule since there is no master table for them yet
        String sql = "SELECT DISTINCT Slot, Start_Time, End_Time, Session " +
                     "FROM Work_Schedule " +
                     "ORDER BY Start_Time";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new TimeSlotConfig(
                    rs.getString("Slot"),
                    rs.getString("Start_Time"),
                    rs.getString("End_Time"),
                    rs.getString("Session")
                ));
            }
        }
        return list;
    }
    // Thêm một Slot cấu hình vào lịch làm việc chung
    public boolean addTimeSlot(String date, String slotName, String startTime, String endTime, String session) throws Exception {
        String sql = "INSERT INTO Work_Schedule (Work_Date, Slot, Start_Time, End_Time, Session, Status) " +
                     "VALUES (?, ?, ?, ?, ?, 'Available')";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, date);       // Định dạng: yyyy-MM-dd
            ps.setString(2, slotName);   // Ví dụ: "Slot 1"
            ps.setString(3, startTime);  // Ví dụ: "08:00:00"
            ps.setString(4, endTime);    // Ví dụ: "08:30:00"
            ps.setString(5, session);    // "Morning" / "Afternoon"
            
            return ps.executeUpdate() > 0;
        }
    }

    // Xóa một cấu hình Slot chưa có ai đặt (Trạng thái = Available)
    public boolean deleteTimeSlot(int scheduleId) throws Exception {
        // Chỉ cho phép xóa khi Status là 'Available' (Business Logic)
        String sql = "DELETE FROM Work_Schedule WHERE Schedule_ID = ? AND Status = 'Available'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, scheduleId);
            return ps.executeUpdate() > 0;
        }
    }
}
