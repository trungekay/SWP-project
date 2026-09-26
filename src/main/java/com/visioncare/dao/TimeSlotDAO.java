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
}
