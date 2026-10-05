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
                    "Undefined",
                    rs.getString("Status")
                ));
            }
        }
        return list;
    }
    public boolean addTimeSlot(String date, String slotName, String startTime, String endTime, String session) throws Exception {
        // Insert this slot for all active doctors
        String sql = "INSERT INTO Work_Schedule (Doctor_Employee_ID, Work_Date, Slot, Start_Time, End_Time, Status) " +
                     "SELECT e.Employee_ID, ?, ?, ?, ?, 'Available' " +
                     "FROM Employee_Profile e JOIN Account a ON e.Account_ID = a.Account_ID " +
                     "WHERE a.Role_ID = 3 AND a.Account_Status = 'Active'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, date);
            ps.setString(2, slotName);
            ps.setString(3, startTime);
            ps.setString(4, endTime);
            ps.setString(5, session);
            
            return ps.executeUpdate() > 0;
        }
    }

    public boolean deleteTimeSlot(int scheduleId) throws Exception {
        String sql = "DELETE FROM Work_Schedule WHERE Schedule_ID = ? AND Status = 'Available'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, scheduleId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean updateTimeSlotConfig(String oldSlotName, String newSlotName, String startTime, String endTime, String status) throws Exception {
        String sql = "UPDATE Work_Schedule SET Slot = ?, Start_Time = ?, End_Time = ?, Status = ? WHERE Slot = ? AND Status = 'Available'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newSlotName);
            ps.setString(2, startTime);
            ps.setString(3, endTime);
            ps.setString(4, status);
            ps.setString(5, oldSlotName);
            return ps.executeUpdate() > 0;
        }
    }
}
