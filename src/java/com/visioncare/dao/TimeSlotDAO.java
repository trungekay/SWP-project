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
        ensureTimeSlotConfigTable();
    }

    private void ensureTimeSlotConfigTable() {
        try (Connection conn = DBContext.getConnection();
             Statement st = conn.createStatement()) {
            String checkSql = "IF OBJECT_ID('dbo.Time_Slot_Config', 'U') IS NULL "
                    + "BEGIN "
                    + "CREATE TABLE dbo.Time_Slot_Config ( "
                    + " Slot_ID INT IDENTITY PRIMARY KEY, "
                    + " Slot_Name NVARCHAR(100) NOT NULL UNIQUE, "
                    + " Start_Time TIME(0) NOT NULL UNIQUE, "
                    + " End_Time TIME(0) NOT NULL, "
                    + " Status VARCHAR(20) NOT NULL DEFAULT 'Available', "
                    + " CHECK (DATEDIFF(SECOND,Start_Time,End_Time)=1800), "
                    + " CHECK (Status IN ('Available','Canceled')) "
                    + "); "
                    + "IF EXISTS (SELECT 1 FROM dbo.Work_Schedule) "
                    + "BEGIN "
                    + "    ;WITH labels AS ( "
                    + "     SELECT Slot,Start_Time,End_Time,COUNT(*) Uses, "
                    + "     ROW_NUMBER() OVER(PARTITION BY Start_Time,End_Time ORDER BY COUNT(*) DESC,Slot) Label_Rank "
                    + "     FROM dbo.Work_Schedule GROUP BY Slot,Start_Time,End_Time "
                    + "    ), ranges AS ( "
                    + "     SELECT l.Slot,l.Start_Time,l.End_Time, "
                    + "     CASE WHEN EXISTS(SELECT 1 FROM dbo.Work_Schedule w "
                    + "     WHERE w.Start_Time=l.Start_Time AND w.End_Time=l.End_Time AND w.Status<>'Canceled') "
                    + "     THEN 'Available' ELSE 'Canceled' END Status "
                    + "     FROM labels l WHERE Label_Rank=1 "
                    + "    ), names AS ( "
                    + "     SELECT *,COUNT(*) OVER(PARTITION BY Slot) Name_Count FROM ranges "
                    + "    ) "
                    + "    INSERT dbo.Time_Slot_Config(Slot_Name,Start_Time,End_Time,Status) "
                    + "    SELECT CASE WHEN Name_Count>1 THEN CONCAT(Slot,' (',CONVERT(VARCHAR(5),Start_Time,108),')') ELSE Slot END, "
                    + "     Start_Time,End_Time,Status FROM names; "
                    + "    UPDATE ws SET Slot=cfg.Slot_Name FROM dbo.Work_Schedule ws "
                    + "    JOIN dbo.Time_Slot_Config cfg ON cfg.Start_Time=ws.Start_Time AND cfg.End_Time=ws.End_Time; "
                    + "END "
                    + "ELSE "
                    + "BEGIN "
                    + "    INSERT dbo.Time_Slot_Config(Slot_Name,Start_Time,End_Time,Status) VALUES "
                    + "    (N'Ca 1 (08:00 - 08:30)', '08:00:00', '08:30:00', 'Available'), "
                    + "    (N'Ca 2 (08:30 - 09:00)', '08:30:00', '09:00:00', 'Available'), "
                    + "    (N'Ca 3 (09:00 - 09:30)', '09:00:00', '09:30:00', 'Available'), "
                    + "    (N'Ca 4 (09:30 - 10:00)', '09:30:00', '10:00:00', 'Available'), "
                    + "    (N'Ca 5 (10:00 - 10:30)', '10:00:00', '10:30:00', 'Available'), "
                    + "    (N'Ca 6 (10:30 - 11:00)', '10:30:00', '11:00:00', 'Available'), "
                    + "    (N'Ca 7 (11:00 - 11:30)', '11:00:00', '11:30:00', 'Available'), "
                    + "    (N'Ca 8 (13:30 - 14:00)', '13:30:00', '14:00:00', 'Available'), "
                    + "    (N'Ca 9 (14:00 - 14:30)', '14:00:00', '14:30:00', 'Available'), "
                    + "    (N'Ca 10 (14:30 - 15:00)', '14:30:00', '15:00:00', 'Available'), "
                    + "    (N'Ca 11 (15:00 - 15:30)', '15:00:00', '15:30:00', 'Available'), "
                    + "    (N'Ca 12 (15:30 - 16:00)', '15:30:00', '16:00:00', 'Available'), "
                    + "    (N'Ca 13 (16:00 - 16:30)', '16:00:00', '16:30:00', 'Available'), "
                    + "    (N'Ca 14 (16:30 - 17:00)', '16:30:00', '17:00:00', 'Available'); "
                    + "END "
                    + "END";
            st.execute(checkSql);

            // Permanently delete unwanted slots (13:00 or >= 17:00) if present
            String autoCleanSql = "IF OBJECT_ID('dbo.Time_Slot_Config', 'U') IS NOT NULL "
                    + "BEGIN "
                    + "    DELETE FROM dbo.Time_Slot_Config WHERE Start_Time = '13:00:00' OR Start_Time >= '17:00:00'; "
                    + "END";
            st.execute(autoCleanSql);
        } catch (Exception e) {
            System.err.println("Error ensuring Time_Slot_Config table: " + e.getMessage());
        }
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
                    + "INSERT INTO Clinic_Setting (Setting_Key, Setting_Value, Description) "
                    + "VALUES ('BOOKING_PENDING_HOLD_MINUTES', '15', N'Thời gian giữ chỗ tối đa cho lịch hẹn Pending chờ thanh toán (phút)'); "
                    + "END "
                    + "ELSE IF NOT EXISTS (SELECT 1 FROM Clinic_Setting WHERE Setting_Key = 'BOOKING_PENDING_HOLD_MINUTES') "
                    + "BEGIN "
                    + "INSERT INTO Clinic_Setting (Setting_Key, Setting_Value, Description) "
                    + "VALUES ('BOOKING_PENDING_HOLD_MINUTES', '15', N'Thời gian giữ chỗ tối đa cho lịch hẹn Pending chờ thanh toán (phút)'); "
                    + "END";
            st.execute(createTableSql);
        } catch (Exception e) {
            System.err.println("Error ensuring Clinic_Setting table: " + e.getMessage());
        }
    }

    public static int getPendingHoldMinutes() {
        int minutes = 15;
        String sql = "SELECT Setting_Value FROM Clinic_Setting WHERE Setting_Key = 'BOOKING_PENDING_HOLD_MINUTES'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                String val = rs.getString("Setting_Value");
                if (val != null && !val.trim().isEmpty()) {
                    minutes = Integer.parseInt(val.trim());
                }
            }
        } catch (Exception e) {
            // Default 15 if table or row not yet ready
            minutes = 15;
        }
        return minutes > 0 ? minutes : 15;
    }

    public boolean updatePendingHoldMinutes(int minutes) {
        if (minutes <= 0) return false;
        ensureSettingTable();
        String sql = "UPDATE Clinic_Setting SET Setting_Value = ? WHERE Setting_Key = 'BOOKING_PENDING_HOLD_MINUTES'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, String.valueOf(minutes));
            int rows = ps.executeUpdate();
            if (rows == 0) {
                String insertSql = "INSERT INTO Clinic_Setting (Setting_Key, Setting_Value, Description) "
                        + "VALUES ('BOOKING_PENDING_HOLD_MINUTES', ?, N'Thời gian giữ chỗ tối đa cho lịch hẹn Pending chờ thanh toán (phút)')";
                try (PreparedStatement psIns = conn.prepareStatement(insertSql)) {
                    psIns.setString(1, String.valueOf(minutes));
                    return psIns.executeUpdate() > 0;
                }
            }
            return rows > 0;
        } catch (Exception e) {
            System.err.println("Error updatePendingHoldMinutes: " + e.getMessage());
            return false;
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
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement("DELETE FROM Time_Slot_Config WHERE Slot_ID=?")) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Resets/re-aligns to 14 standard slots:
     * - Ca Sáng: 7 slots (08:00 - 11:30)
     * - Lunch break: 11:30 - 13:30 (2 hours)
     * - Ca Chiều: 7 slots (13:30 - 17:00)
     */
    public boolean resetToStandardSlots() {
        String[][] standardSlots = {
            {"Ca 1 (08:00 - 08:30)", "08:00:00", "08:30:00"},
            {"Ca 2 (08:30 - 09:00)", "08:30:00", "09:00:00"},
            {"Ca 3 (09:00 - 09:30)", "09:00:00", "09:30:00"},
            {"Ca 4 (09:30 - 10:00)", "09:30:00", "10:00:00"},
            {"Ca 5 (10:00 - 10:30)", "10:00:00", "10:30:00"},
            {"Ca 6 (10:30 - 11:00)", "10:30:00", "11:00:00"},
            {"Ca 7 (11:00 - 11:30)", "11:00:00", "11:30:00"},
            {"Ca 8 (13:30 - 14:00)", "13:30:00", "14:00:00"},
            {"Ca 9 (14:00 - 14:30)", "14:00:00", "14:30:00"},
            {"Ca 10 (14:30 - 15:00)", "14:30:00", "15:00:00"},
            {"Ca 11 (15:00 - 15:30)", "15:00:00", "15:30:00"},
            {"Ca 12 (15:30 - 16:00)", "15:30:00", "16:00:00"},
            {"Ca 13 (16:00 - 16:30)", "16:00:00", "16:30:00"},
            {"Ca 14 (16:30 - 17:00)", "16:30:00", "17:00:00"}
        };

        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try (Statement st = conn.createStatement()) {
                // 1. Rename existing slots temporarily to avoid UNIQUE constraint collision on Slot_Name
                st.executeUpdate("UPDATE Time_Slot_Config SET Slot_Name = CONCAT('__TEMP__', Slot_ID, '__', Slot_Name)");

                // 2. Permanently delete unwanted slots (13:00 or >= 17:00)
                st.executeUpdate("DELETE FROM Time_Slot_Config WHERE Start_Time = '13:00:00' OR Start_Time >= '17:00:00'");

                // 3. Upsert the 14 standard slots
                String updateSql = "UPDATE Time_Slot_Config SET Slot_Name = ?, End_Time = ?, Status = 'Available' WHERE Start_Time = ?";
                String insertSql = "INSERT INTO Time_Slot_Config (Slot_Name, Start_Time, End_Time, Status) VALUES (?, ?, ?, 'Available')";

                try (PreparedStatement psUpdate = conn.prepareStatement(updateSql);
                     PreparedStatement psInsert = conn.prepareStatement(insertSql)) {
                    for (String[] slot : standardSlots) {
                        psUpdate.setString(1, slot[0]);
                        psUpdate.setString(2, slot[2]);
                        psUpdate.setString(3, slot[1]);
                        int affected = psUpdate.executeUpdate();
                        if (affected == 0) {
                            psInsert.setString(1, slot[0]);
                            psInsert.setString(2, slot[1]);
                            psInsert.setString(3, slot[2]);
                            psInsert.executeUpdate();
                        }
                    }
                }

                // 4. Restore names of any extra slots
                st.executeUpdate("UPDATE Time_Slot_Config SET Slot_Name = REPLACE(Slot_Name, CONCAT('__TEMP__', Slot_ID, '__'), '') WHERE Slot_Name LIKE '__TEMP__%'");

                // 5. Update Work_Schedule labels to match
                st.executeUpdate("UPDATE ws SET Slot = cfg.Slot_Name FROM Work_Schedule ws "
                        + "JOIN Time_Slot_Config cfg ON cfg.Start_Time = ws.Start_Time AND cfg.End_Time = ws.End_Time "
                        + "WHERE cfg.Status = 'Available'");

                conn.commit();
                return true;
            } catch (Exception e) {
                conn.rollback();
                throw e;
            }
        } catch (Exception e) {
            System.err.println("Error resetToStandardSlots: " + e.getMessage());
            return false;
        }
    }
}
