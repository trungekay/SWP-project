package com.visioncare.dao;

import com.visioncare.model.TimeSlotConfig;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class TimeSlotDAO {

    public TimeSlotDAO() {
        ensureSettingTable();
    }

    private void ensureSettingTable() {
        try (Connection conn = DBContext.getConnection();
             Statement st = conn.createStatement()) {
            String createTableSql = "IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Clinic_Setting' AND xtype='U') "
                    + "BEGIN "
                    + "CREATE TABLE Clinic_Setting ( "
                    + "    Setting_Key VARCHAR(50) PRIMARY KEY, "
                    + "    Setting_Value NVARCHAR(255) NOT NULL, "
                    + "    Description NVARCHAR(255) NULL "
                    + "); "
                    + "INSERT INTO Clinic_Setting (Setting_Key, Setting_Value, Description) "
                    + "VALUES ('MIN_WORK_HOURS_PER_WEEK', '30.0', N'Số giờ làm việc tối thiểu mỗi tuần'); "
                    + "END";
            st.execute(createTableSql);
        } catch (Exception e) {
            System.err.println("Error ensuring Clinic_Setting table: " + e.getMessage());
        }
    }

    public double getMaxWeeklyAvailableHours() {
        try {
            List<TimeSlotConfig> slots = getConfiguredSlots();
            int activeCount = 0;
            for (TimeSlotConfig s : slots) {
                if ("Available".equalsIgnoreCase(s.getStatus())) {
                    activeCount++;
                }
            }
            return activeCount * 7 * 0.5;
        } catch (Exception e) {
            System.err.println("Error getMaxWeeklyAvailableHours: " + e.getMessage());
            return 49.0;
        }
    }

    public double getMinWeeklyWorkingHours() {
        ensureSettingTable();
        double hours = 30.0;
        String sql = "SELECT Setting_Value FROM Clinic_Setting WHERE Setting_Key = 'MIN_WORK_HOURS_PER_WEEK'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                hours = Double.parseDouble(rs.getString("Setting_Value"));
            }
        } catch (Exception e) {
            System.err.println("Error getMinWeeklyWorkingHours: " + e.getMessage());
        }
        double maxHours = getMaxWeeklyAvailableHours();
        if (hours > maxHours) {
            hours = maxHours;
        }
        return hours;
    }

    public boolean updateMinWeeklyWorkingHours(double hours) {
        ensureSettingTable();
        double maxHours = getMaxWeeklyAvailableHours();
        if (hours > maxHours) {
            return false;
        }
        String sql = "UPDATE Clinic_Setting SET Setting_Value = ? WHERE Setting_Key = 'MIN_WORK_HOURS_PER_WEEK'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, String.valueOf(hours));
            int rows = ps.executeUpdate();
            if (rows == 0) {
                String insertSql = "INSERT INTO Clinic_Setting (Setting_Key, Setting_Value, Description) "
                        + "VALUES ('MIN_WORK_HOURS_PER_WEEK', ?, N'Số giờ làm việc tối thiểu mỗi tuần')";
                try (PreparedStatement psIns = conn.prepareStatement(insertSql)) {
                    psIns.setString(1, String.valueOf(hours));
                    return psIns.executeUpdate() > 0;
                }
            }
            return rows > 0;
        } catch (Exception e) {
            System.err.println("Error updateMinWeeklyWorkingHours: " + e.getMessage());
            return false;
        }
    }
    public List<TimeSlotConfig> getConfiguredSlots() throws Exception {
        List<TimeSlotConfig> list = new ArrayList<>();
        String sql = "SELECT Slot_ID, Slot_Name AS Slot, Start_Time, End_Time, " +
                "CASE " +
                "  WHEN CAST(Start_Time AS TIME) < '12:00:00' THEN 'Morning' " +
                "  WHEN CAST(Start_Time AS TIME) < '17:00:00' THEN 'Afternoon' " +
                "  ELSE 'Evening' " +
                "END AS Session, Status " +
                "FROM Time_Slot_Config " +
                "ORDER BY Start_Time";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                TimeSlotConfig config = new TimeSlotConfig(
                        rs.getString("Slot"),
                        rs.getString("Start_Time"),
                        rs.getString("End_Time"),
                        rs.getString("Session"),
                        rs.getString("Status"));
                config.setSlotId(rs.getInt("Slot_ID"));
                list.add(config);
            }
        }
        return list;
    }


    public boolean addTimeSlot(String name, String start, String end) throws Exception {
        return save(0, name, start, end, "Available");
    }

    public boolean updateTimeSlotConfig(int id, String name, String start, String end, String status) throws Exception {
        if (id <= 0) throw new IllegalArgumentException("Mã ca không hợp lệ.");
        return save(id, name, start, end, status);
    }

    private boolean save(int id, String name, String start, String end, String status) throws Exception {
        if(name==null || name.trim().isEmpty() || name.trim().length()>100 || name.contains("|"))
            throw new IllegalArgumentException("Tên ca không hợp lệ.");
        java.time.LocalTime from=java.time.LocalTime.parse(start), to=java.time.LocalTime.parse(end);
        if(java.time.Duration.between(from,to).getSeconds()!=1800)
            throw new IllegalArgumentException("Khung giờ phải dài đúng 30 phút.");
        if(!"Available".equals(status) && !"Canceled".equals(status))
            throw new IllegalArgumentException("Trạng thái không hợp lệ.");
        try(Connection conn=DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try {
                try(PreparedStatement ps=conn.prepareStatement(
                        "SELECT 1 FROM Time_Slot_Config WITH (UPDLOCK,HOLDLOCK) WHERE Slot_ID<>? "
                        +"AND (Slot_Name=? OR (Start_Time<CAST(? AS TIME) AND End_Time>CAST(? AS TIME)))")) {
                    ps.setInt(1,id); ps.setString(2,name.trim()); ps.setString(3,end); ps.setString(4,start);
                    try(ResultSet rs=ps.executeQuery()) {
                        if(rs.next()) throw new IllegalArgumentException("Tên ca trùng hoặc thời gian chồng lấn.");
                    }
                }
                if(id>0) {
                    String oldName,oldStart,oldEnd;
                    try(PreparedStatement ps=conn.prepareStatement(
                            "SELECT Slot_Name,Start_Time,End_Time FROM Time_Slot_Config WITH (UPDLOCK,HOLDLOCK) WHERE Slot_ID=?")) {
                        ps.setInt(1,id);
                        try(ResultSet rs=ps.executeQuery()) {
                            if(!rs.next()) throw new IllegalArgumentException("Ca không tồn tại.");
                            oldName=rs.getString(1); oldStart=rs.getString(2); oldEnd=rs.getString(3);
                        }
                    }
                    try(PreparedStatement ps=conn.prepareStatement(
                            "SELECT 1 FROM Work_Schedule WHERE Slot=? AND Start_Time=CAST(? AS TIME) AND End_Time=CAST(? AS TIME)")) {
                        ps.setString(1,oldName); ps.setString(2,oldStart); ps.setString(3,oldEnd);
                        try(ResultSet rs=ps.executeQuery()) {
                            if(rs.next() && (!from.equals(java.time.LocalTime.parse(oldStart)) || !to.equals(java.time.LocalTime.parse(oldEnd))))
                                throw new IllegalArgumentException("Ca đã có lịch làm việc. Hãy tạo ca mới để đổi giờ.");
                        }
                    }
                    // Synchronize labels only. Never overwrite booking, leave status, dates or times.
                    try(PreparedStatement ps=conn.prepareStatement(
                            "UPDATE Work_Schedule SET Slot=? WHERE Slot=? AND Start_Time=CAST(? AS TIME) AND End_Time=CAST(? AS TIME)")) {
                        ps.setString(1,name.trim()); ps.setString(2,oldName); ps.setString(3,oldStart); ps.setString(4,oldEnd);
                        ps.executeUpdate();
                    }
                }
                try(PreparedStatement ps=conn.prepareStatement(id==0
                        ? "INSERT Time_Slot_Config(Slot_Name,Start_Time,End_Time,Status) VALUES (?,?,?,?)"
                        : "UPDATE Time_Slot_Config SET Slot_Name=?,Start_Time=?,End_Time=?,Status=? WHERE Slot_ID=?")) {
                    ps.setString(1,name.trim()); ps.setString(2,start); ps.setString(3,end); ps.setString(4,status);
                    if(id>0) ps.setInt(5,id);
                    ps.executeUpdate();
                }
                conn.commit(); return true;
            } catch(Exception e) { conn.rollback(); throw e; }
        }
    }

    public boolean deleteTimeSlot(int id) throws Exception {
        try(Connection conn=DBContext.getConnection(); PreparedStatement ps=conn.prepareStatement(
                "UPDATE Time_Slot_Config SET Status='Canceled' WHERE Slot_ID=?")) {
            ps.setInt(1,id); return ps.executeUpdate()>0;
        }
    }
}
