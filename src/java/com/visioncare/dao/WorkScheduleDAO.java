package com.visioncare.dao;
import com.visioncare.model.ScheduleCellDTO;
import com.visioncare.model.ScheduleRegistrationDTO;
import com.visioncare.model.User;
import java.sql.*;
import java.util.*;
public class WorkScheduleDAO {
    public Map<String, ScheduleCellDTO> getScheduleMatrix(int actorId, String role, String startDate, String endDate) {
        Map<String, ScheduleCellDTO> matrix = new HashMap<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT ws.Schedule_ID, ws.Doctor_Employee_ID, ws.Specialist_Employee_ID, ws.Staff_Employee_ID, ")
           .append("       ws.Work_Date, ws.Slot, ws.Start_Time, ws.End_Time, ws.Status, ")
           .append("       rm.Room_Name, ")
           .append("       ap.Appointment_ID, ap.Patient_ID, ap.Status AS Appointment_Status, ")
           .append("       p.Full_Name AS Patient_Name, p.Phone AS Patient_Phone ")
           .append("FROM Work_Schedule ws ")
           .append("LEFT JOIN Employee_Profile e ON (ws.Doctor_Employee_ID = e.Employee_ID OR ws.Specialist_Employee_ID = e.Employee_ID OR ws.Staff_Employee_ID = e.Employee_ID) ")
           .append("LEFT JOIN Room rm ON e.Room_ID = rm.Room_ID ")
           .append("LEFT JOIN Appointment ap ON ws.Schedule_ID = ap.Schedule_ID AND ap.Status != 'Canceled' ")
           .append("LEFT JOIN Patient p ON ap.Patient_ID = p.Patient_ID ")
           .append("WHERE ws.Work_Date BETWEEN ? AND ? ");
        if ("doctor".equalsIgnoreCase(role)) {
            sql.append("AND ws.Doctor_Employee_ID = ? ");
        } else if ("medical_specialist".equalsIgnoreCase(role) || "specialist".equalsIgnoreCase(role)) {
            sql.append("AND ws.Specialist_Employee_ID = ? ");
        } else if ("staff".equalsIgnoreCase(role)) {
            sql.append("AND (ws.Staff_Employee_ID = ? OR ws.Specialist_Employee_ID = ?) ");
        }
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            ps.setString(1, startDate);
            ps.setString(2, endDate);
            if ("doctor".equalsIgnoreCase(role) || "medical_specialist".equalsIgnoreCase(role) || "specialist".equalsIgnoreCase(role)) {
                ps.setInt(3, actorId);
            } else if ("staff".equalsIgnoreCase(role)) {
                ps.setInt(3, actorId);
                ps.setInt(4, actorId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ScheduleCellDTO cell = new ScheduleCellDTO();
                    cell.setScheduleId(rs.getInt("Schedule_ID"));
                    cell.setWorkDate(rs.getString("Work_Date"));
                    cell.setSlot(rs.getString("Slot"));
                    cell.setStartTime(rs.getString("Start_Time"));
                    cell.setEndTime(rs.getString("End_Time"));
                    cell.setSession("Undefined");
                    cell.setStatus(rs.getString("Status"));
                    cell.setRoomName(rs.getString("Room_Name"));
                    cell.setAppointmentId(rs.getInt("Appointment_ID"));
                    cell.setPatientId(rs.getInt("Patient_ID"));
                    cell.setPatientName(rs.getString("Patient_Name"));
                    cell.setPatientPhone(rs.getString("Patient_Phone"));
                    cell.setAppointmentStatus(rs.getString("Appointment_Status"));
                    String key = cell.getWorkDate() + "_" + cell.getSlot();
                    matrix.put(key, cell);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return matrix;
    }
    public Set<String> getRegisteredSlotKeys(int actorId, String role, String startDate, String endDate) {
        Set<String> set = new HashSet<>();
        StringBuilder sql = new StringBuilder("SELECT Work_Date, Slot FROM Work_Schedule WHERE Work_Date BETWEEN ? AND ? ");
        if ("doctor".equalsIgnoreCase(role)) {
            sql.append("AND Doctor_Employee_ID = ? ");
        } else if ("medical_specialist".equalsIgnoreCase(role) || "specialist".equalsIgnoreCase(role)) {
            sql.append("AND Specialist_Employee_ID = ? ");
        } else if ("staff".equalsIgnoreCase(role)) {
            sql.append("AND (Staff_Employee_ID = ? OR Specialist_Employee_ID = ?) ");
        }
        sql.append("AND Status NOT IN ('Canceled', 'Inactive', 'Disabled', 'Closed') ");
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            ps.setString(1, startDate);
            ps.setString(2, endDate);
            if ("doctor".equalsIgnoreCase(role) || "medical_specialist".equalsIgnoreCase(role) || "specialist".equalsIgnoreCase(role)) {
                ps.setInt(3, actorId);
            } else if ("staff".equalsIgnoreCase(role)) {
                ps.setInt(3, actorId);
                ps.setInt(4, actorId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    set.add(rs.getString("Work_Date") + "_" + rs.getString("Slot"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return set;
    }

    public Set<String> getClosedSlotKeys(int actorId, String role, String startDate, String endDate) {
        Set<String> set = new HashSet<>();
        StringBuilder sql = new StringBuilder("SELECT Work_Date, Slot FROM Work_Schedule WHERE Work_Date BETWEEN ? AND ? ");
        if ("doctor".equalsIgnoreCase(role)) {
            sql.append("AND Doctor_Employee_ID = ? ");
        } else if ("medical_specialist".equalsIgnoreCase(role) || "specialist".equalsIgnoreCase(role)) {
            sql.append("AND Specialist_Employee_ID = ? ");
        } else if ("staff".equalsIgnoreCase(role)) {
            sql.append("AND (Staff_Employee_ID = ? OR Specialist_Employee_ID = ?) ");
        }
        sql.append("AND Status IN ('Canceled', 'Inactive', 'Disabled', 'Closed') ");
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            ps.setString(1, startDate);
            ps.setString(2, endDate);
            if ("doctor".equalsIgnoreCase(role) || "medical_specialist".equalsIgnoreCase(role) || "specialist".equalsIgnoreCase(role)) {
                ps.setInt(3, actorId);
            } else if ("staff".equalsIgnoreCase(role)) {
                ps.setInt(3, actorId);
                ps.setInt(4, actorId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    set.add(rs.getString("Work_Date") + "_" + rs.getString("Slot"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return set;
    }
    public boolean registerScheduleBatch(int actorId, String role, List<ScheduleRegistrationDTO> list) {
        if (list == null || list.isEmpty()) {
            return false;
        }
        StringBuilder sql = new StringBuilder();
        sql.append("IF NOT EXISTS (SELECT 1 FROM Work_Schedule WHERE Work_Date = ? AND Slot = ? ");
        if ("doctor".equalsIgnoreCase(role)) {
            sql.append("AND Doctor_Employee_ID = ?) ");
        } else if ("medical_specialist".equalsIgnoreCase(role) || "specialist".equalsIgnoreCase(role)) {
            sql.append("AND Specialist_Employee_ID = ?) ");
        } else if ("staff".equalsIgnoreCase(role)) {
            sql.append("AND Staff_Employee_ID = ?) ");
        } else {
            sql.append(") ");
        }
        sql.append("BEGIN ")
           .append("INSERT INTO Work_Schedule (Doctor_Employee_ID, Specialist_Employee_ID, Staff_Employee_ID, Work_Date, Slot, Start_Time, End_Time, Status) ")
           .append("VALUES (?, ?, ?, ?, ?, ?, ?, 'Available') ")
           .append("END");
        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
                for (ScheduleRegistrationDTO item : list) {
                    int pIndex = 1;
                    ps.setString(pIndex++, item.getWorkDate());
                    ps.setString(pIndex++, item.getSlot());
                    if ("doctor".equalsIgnoreCase(role) || "medical_specialist".equalsIgnoreCase(role) || "specialist".equalsIgnoreCase(role) || "staff".equalsIgnoreCase(role)) {
                        ps.setInt(pIndex++, actorId);
                    }
                    if ("doctor".equalsIgnoreCase(role)) {
                        ps.setInt(pIndex++, actorId);
                        ps.setNull(pIndex++, java.sql.Types.INTEGER);
                        ps.setNull(pIndex++, java.sql.Types.INTEGER);
                    } else if ("medical_specialist".equalsIgnoreCase(role) || "specialist".equalsIgnoreCase(role)) {
                        ps.setNull(pIndex++, java.sql.Types.INTEGER);
                        ps.setInt(pIndex++, actorId);
                        ps.setNull(pIndex++, java.sql.Types.INTEGER);
                    } else if ("staff".equalsIgnoreCase(role)) {
                        ps.setNull(pIndex++, java.sql.Types.INTEGER);
                        ps.setNull(pIndex++, java.sql.Types.INTEGER);
                        ps.setInt(pIndex++, actorId);
                    } else {
                        ps.setNull(pIndex++, java.sql.Types.INTEGER);
                        ps.setNull(pIndex++, java.sql.Types.INTEGER);
                        ps.setNull(pIndex++, java.sql.Types.INTEGER);
                    }
                    ps.setString(pIndex++, item.getWorkDate());
                    ps.setString(pIndex++, item.getSlot());
                    ps.setString(pIndex++, item.getStartTime());
                    ps.setString(pIndex++, item.getEndTime());
                    ps.addBatch();
                }
                ps.executeBatch();
                conn.commit();
                return true;
            } catch (Exception e) {
                conn.rollback();
                e.printStackTrace();
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
    public List<User> getStaffAndDoctorList() {
        List<User> list = new ArrayList<>();
        String sql = "SELECT LOWER(r.Role_Name) AS Role_Type, e.Employee_ID AS Actor_ID, e.Full_Name, COALESCE(e.Specialty, N'Nhân viên') AS Specialty, " +
                     "CASE WHEN LOWER(r.Role_Name) = 'staff' THEN NULL ELSE COALESCE(rm.Room_Name, N'Chưa xếp phòng') END AS Room_Name " +
                     "FROM Employee_Profile e " +
                     "JOIN Account a ON e.Account_ID = a.Account_ID " +
                     "JOIN Role r ON a.Role_ID = r.Role_ID " +
                     "LEFT JOIN Room rm ON e.Room_ID = rm.Room_ID " +
                     "WHERE r.Role_Name IN ('Doctor', 'Medical_Specialist', 'Staff')";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                User u = new User();
                u.setRole(rs.getString("Role_Type"));
                u.setActorId(rs.getInt("Actor_ID"));
                u.setFullName(rs.getString("Full_Name"));
                u.setSpecialty(rs.getString("Specialty"));
                u.setRoomName(rs.getString("Room_Name"));
                list.add(u);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<User> getEmployeesByRoleType(String roleType) {
        List<User> list = new ArrayList<>();
        String targetRole = "Doctor";
        if ("medical_specialist".equalsIgnoreCase(roleType) || "specialist".equalsIgnoreCase(roleType)) {
            targetRole = "Medical_Specialist";
        } else if ("staff".equalsIgnoreCase(roleType)) {
            targetRole = "Staff";
        }
        String sql = "SELECT LOWER(r.Role_Name) AS Role_Type, r.Role_Name, e.Employee_ID AS Actor_ID, a.Account_ID, " +
                     "e.Full_Name, a.Email, COALESCE(e.Phone, N'Chưa có') AS Phone, COALESCE(e.Specialty, N'Chung') AS Specialty, " +
                     "CASE WHEN LOWER(r.Role_Name) = 'staff' THEN NULL ELSE COALESCE(rm.Room_Name, N'Chưa xếp phòng') END AS Room_Name, " +
                     "e.License_Number, a.Account_Status, e.DOB, e.Address " +
                     "FROM Employee_Profile e " +
                     "JOIN Account a ON e.Account_ID = a.Account_ID " +
                     "JOIN Role r ON a.Role_ID = r.Role_ID " +
                     "LEFT JOIN Room rm ON e.Room_ID = rm.Room_ID " +
                     "WHERE r.Role_Name = ? AND a.Account_Status != 'Deleted' " +
                     "ORDER BY e.Employee_ID ASC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, targetRole);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    User u = new User();
                    u.setRole(rs.getString("Role_Type"));
                    u.setActorId(rs.getInt("Actor_ID"));
                    u.setId(rs.getInt("Account_ID"));
                    u.setFullName(rs.getString("Full_Name"));
                    u.setEmail(rs.getString("Email"));
                    u.setPhone(rs.getString("Phone"));
                    u.setSpecialty(rs.getString("Specialty"));
                    u.setRoomName(rs.getString("Room_Name"));
                    u.setLicenseNumber(rs.getString("License_Number"));
                    u.setStatus(rs.getString("Account_Status"));
                    java.sql.Date dob = rs.getDate("DOB");
                    u.setDob(dob != null ? dob.toString() : null);
                    u.setAddress(rs.getString("Address"));
                    list.add(u);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
    public User getActorProfile(int actorId, String role) {
        String sql = "SELECT e.Employee_ID AS Actor_ID, e.Full_Name, COALESCE(e.Specialty, N'Nhân viên') AS Specialty, " +
                     "CASE WHEN LOWER(r.Role_Name) = 'staff' THEN NULL ELSE COALESCE(rm.Room_Name, N'Chưa xếp phòng') END AS Room_Name, e.License_Number, LOWER(r.Role_Name) AS Role, e.Phone " +
                     "FROM Employee_Profile e " +
                     "JOIN Account a ON e.Account_ID = a.Account_ID " +
                     "JOIN Role r ON a.Role_ID = r.Role_ID " +
                     "LEFT JOIN Room rm ON e.Room_ID = rm.Room_ID " +
                     "WHERE e.Employee_ID = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, actorId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    User u = new User();
                    u.setActorId(rs.getInt("Actor_ID"));
                    u.setFullName(rs.getString("Full_Name"));
                    u.setSpecialty(rs.getString("Specialty"));
                    u.setRoomName(rs.getString("Room_Name"));
                    u.setLicenseNumber(rs.getString("License_Number"));
                    u.setRole(rs.getString("Role"));
                    u.setPhone(rs.getString("Phone"));
                    return u;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<com.visioncare.model.TimeSlot> getDoctorSlotsForDate(int doctorId, String dateStr) {
        List<com.visioncare.model.TimeSlot> list = new ArrayList<>();
        ensureRealisticSchedules();
        String sql = "SELECT ws.Schedule_ID, ws.Doctor_Employee_ID, ws.Work_Date, ws.Slot, " +
                     "       CONVERT(VARCHAR(5), ws.Start_Time, 108) AS Start_Time_Str, " +
                     "       CONVERT(VARCHAR(5), ws.End_Time, 108) AS End_Time_Str, " +
                     "       ws.Status, " +
                     "       CASE " +
                     "         WHEN ws.Status = 'Booked' THEN 1 " +
                     "         WHEN EXISTS (SELECT 1 FROM Appointment ap WHERE ap.Schedule_ID = ws.Schedule_ID " +
                     "                      AND (ap.Status IN ('Confirmed', 'In_Progress', 'Completed') " +
                     "                           OR (ap.Status = 'Pending' AND DATEDIFF(MINUTE, ap.created_at, DATEADD(HOUR, 7, SYSUTCDATETIME())) < 15))) THEN 1 " +
                     "         ELSE 0 " +
                     "       END AS Is_Booked, " +
                     "       CASE " +
                     "         WHEN ws.Work_Date < CAST(DATEADD(HOUR, 7, SYSUTCDATETIME()) AS DATE) THEN 1 " +
                     "         WHEN ws.Work_Date = CAST(DATEADD(HOUR, 7, SYSUTCDATETIME()) AS DATE) " +
                     "              AND CAST(ws.Start_Time AS TIME) <= CAST(DATEADD(HOUR, 7, SYSUTCDATETIME()) AS TIME) THEN 1 " +
                     "         ELSE 0 " +
                     "       END AS Is_Past " +
                     "FROM Work_Schedule ws " +
                     "WHERE ws.Doctor_Employee_ID = ? AND ws.Work_Date = ? " +
                     "  AND ( " +
                     "        (CAST(ws.Start_Time AS TIME) >= '08:00:00' AND CAST(ws.Start_Time AS TIME) < '11:00:00') " + // Ca sáng: slot cuối 10:30 (10:30-11:00), 11:00-11:30 làm backup
                     "        OR " +
                     "        (CAST(ws.Start_Time AS TIME) >= '13:30:00' AND CAST(ws.Start_Time AS TIME) < '17:00:00') " + // Ca chiều: từ 13:30 đến 17:00, slot cuối 16:30 (16:30-17:00)
                     "      ) " +
                     "  AND ws.Status NOT IN ('Canceled', 'On_Leave', 'Inactive', 'Disabled', 'Closed') " +
                     "ORDER BY ws.Start_Time ASC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, doctorId);
            ps.setString(2, dateStr);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    com.visioncare.model.TimeSlot ts = new com.visioncare.model.TimeSlot();
                    ts.setId(rs.getInt("Schedule_ID"));
                    ts.setDoctorId(rs.getInt("Doctor_Employee_ID"));
                    ts.setDate(rs.getDate("Work_Date"));
                    String startStr = rs.getString("Start_Time_Str");
                    ts.setStartTime(startStr);
                    ts.setEndTime(rs.getString("End_Time_Str"));
                    ts.setSlotName(rs.getString("Slot"));
                    boolean isMorning = startStr != null && startStr.compareTo("12:00") < 0;
                    ts.setSession(isMorning ? "Morning" : "Afternoon");
                    boolean isBooked = rs.getInt("Is_Booked") == 1;
                    boolean isPast = rs.getInt("Is_Past") == 1;
                    ts.setBooked(isBooked);
                    ts.setPast(isPast);
                    list.add(ts);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public String getDoctorWorkShiftSummary(int doctorId, String dateStr) {
        List<com.visioncare.model.TimeSlot> slots = getDoctorSlotsForDate(doctorId, dateStr);
        if (slots.isEmpty()) {
            return "OFF";
        }
        boolean hasMorning = false;
        boolean hasAfternoon = false;
        for (com.visioncare.model.TimeSlot slot : slots) {
            if ("Morning".equalsIgnoreCase(slot.getSession())) {
                hasMorning = true;
            } else if ("Afternoon".equalsIgnoreCase(slot.getSession())) {
                hasAfternoon = true;
            }
        }
        if (hasMorning && hasAfternoon) {
            return "FULL";
        } else if (hasMorning) {
            return "MORNING";
        } else if (hasAfternoon) {
            return "AFTERNOON";
        }
        return "OFF";
    }

    public void ensureRealisticDoctorSchedules() {
        ensureRealisticSchedules();
    }

    public void ensureRealisticSchedules() {
        try (Connection conn = DBContext.getConnection()) {
            if (conn == null) return;

            // Đảm bảo cấu trúc cột và ràng buộc cho bảng Work_Schedule
            try (Statement st = conn.createStatement()) {
                st.execute("IF COL_LENGTH('dbo.Work_Schedule', 'Staff_Employee_ID') IS NULL " +
                           "ALTER TABLE dbo.Work_Schedule ADD Staff_Employee_ID INT NULL");
                st.execute("IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CHK_WS_Has_Employee') " +
                           "BEGIN " +
                           "  ALTER TABLE [dbo].[Work_Schedule] DROP CONSTRAINT [CHK_WS_Has_Employee]; " +
                           "  ALTER TABLE [dbo].[Work_Schedule] WITH CHECK ADD CONSTRAINT [CHK_WS_Has_Employee] " +
                           "  CHECK (([Doctor_Employee_ID] IS NOT NULL OR [Specialist_Employee_ID] IS NOT NULL OR [Staff_Employee_ID] IS NOT NULL)); " +
                           "END");
            } catch (Exception ignored) {}

            // Mẫu slot ca sáng (08:00 - 11:30)
            String[][] morningSlots = {
                {"Slot 1", "08:00:00", "08:30:00"},
                {"Slot 2", "08:30:00", "09:00:00"},
                {"Slot 3", "09:00:00", "09:30:00"},
                {"Slot 4", "09:30:00", "10:00:00"},
                {"Slot 5", "10:00:00", "10:30:00"},
                {"Slot 6", "10:30:00", "11:00:00"}
            };
            // Mẫu slot ca chiều (13:30 - 17:00)
            String[][] afternoonSlots = {
                {"Slot 8", "13:30:00", "14:00:00"},
                {"Slot 9", "14:00:00", "14:30:00"},
                {"Slot 10", "14:30:00", "15:00:00"},
                {"Slot 11", "15:00:00", "15:30:00"},
                {"Slot 12", "15:30:00", "16:00:00"},
                {"Slot 13", "16:00:00", "16:30:00"},
                {"Slot 14", "16:30:00", "17:00:00"}
            };

            java.time.LocalDate baseDate = java.time.LocalDate.now();

            // 1. Kiểm tra và bổ sung lịch Bác sĩ (ID 3 đến 8)
            String docCheckSql = "SELECT COUNT(*) FROM Work_Schedule WHERE Doctor_Employee_ID IS NOT NULL AND Work_Date >= CAST(GETDATE() AS DATE)";
            boolean needDocSeed = false;
            try (Statement st = conn.createStatement();
                 ResultSet rs = st.executeQuery(docCheckSql)) {
                if (rs.next() && rs.getInt(1) < 30) {
                    needDocSeed = true;
                }
            }
            if (needDocSeed) {
                String insertDocSql = "IF NOT EXISTS (SELECT 1 FROM Work_Schedule WHERE Doctor_Employee_ID = ? AND Work_Date = ? AND Slot = ?) " +
                                      "INSERT INTO Work_Schedule (Doctor_Employee_ID, Work_Date, Start_Time, End_Time, Slot, Status) VALUES (?, ?, ?, ?, ?, 'Available')";
                try (PreparedStatement ps = conn.prepareStatement(insertDocSql)) {
                    int[] fullDocs = {3, 6};
                    int[] morningDocs = {4, 7};
                    int[] afternoonDocs = {5, 8};
                    for (int dayOffset = 0; dayOffset < 14; dayOffset++) {
                        String dateStr = baseDate.plusDays(dayOffset).toString();
                        for (int docId : fullDocs) {
                            for (String[] s : morningSlots) insertDocSlot(ps, docId, dateStr, s[0], s[1], s[2]);
                            for (String[] s : afternoonSlots) insertDocSlot(ps, docId, dateStr, s[0], s[1], s[2]);
                        }
                        for (int docId : morningDocs) {
                            for (String[] s : morningSlots) insertDocSlot(ps, docId, dateStr, s[0], s[1], s[2]);
                        }
                        for (int docId : afternoonDocs) {
                            for (String[] s : afternoonSlots) insertDocSlot(ps, docId, dateStr, s[0], s[1], s[2]);
                        }
                    }
                }
            }

            // 2. Kiểm tra và bổ sung lịch KTV / Chuyên viên (ID 9, 10, 11)
            String specCheckSql = "SELECT COUNT(*) FROM Work_Schedule WHERE Specialist_Employee_ID IS NOT NULL AND Work_Date >= CAST(GETDATE() AS DATE)";
            boolean needSpecSeed = false;
            try (Statement st = conn.createStatement();
                 ResultSet rs = st.executeQuery(specCheckSql)) {
                if (rs.next() && rs.getInt(1) < 20) {
                    needSpecSeed = true;
                }
            }
            if (needSpecSeed) {
                String insertSpecSql = "IF NOT EXISTS (SELECT 1 FROM Work_Schedule WHERE Specialist_Employee_ID = ? AND Work_Date = ? AND Slot = ?) " +
                                       "INSERT INTO Work_Schedule (Specialist_Employee_ID, Work_Date, Start_Time, End_Time, Slot, Status) VALUES (?, ?, ?, ?, ?, 'Available')";
                try (PreparedStatement ps = conn.prepareStatement(insertSpecSql)) {
                    for (int dayOffset = 0; dayOffset < 14; dayOffset++) {
                        java.time.LocalDate workDate = baseDate.plusDays(dayOffset);
                        if (workDate.getDayOfWeek() == java.time.DayOfWeek.SUNDAY) continue; // Chủ nhật nghỉ
                        String dateStr = workDate.toString();
                        // Specialist 9: Full ngày
                        for (String[] s : morningSlots) insertSingleRoleSlot(ps, 9, dateStr, s[0], s[1], s[2]);
                        for (String[] s : afternoonSlots) insertSingleRoleSlot(ps, 9, dateStr, s[0], s[1], s[2]);
                        // Specialist 10: Ca sáng
                        for (String[] s : morningSlots) insertSingleRoleSlot(ps, 10, dateStr, s[0], s[1], s[2]);
                        // Specialist 11: Ca chiều
                        for (String[] s : afternoonSlots) insertSingleRoleSlot(ps, 11, dateStr, s[0], s[1], s[2]);
                    }
                }
            }

            // 3. Kiểm tra và bổ sung lịch Nhân viên tiếp đón & thu ngân (ID 12)
            String staffCheckSql = "SELECT COUNT(*) FROM Work_Schedule WHERE (Staff_Employee_ID IS NOT NULL OR (Specialist_Employee_ID IS NOT NULL AND Staff_Employee_ID IS NULL)) AND Work_Date >= CAST(GETDATE() AS DATE)";
            boolean needStaffSeed = false;
            try (Statement st = conn.createStatement();
                 ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM Work_Schedule WHERE Staff_Employee_ID = 12 AND Work_Date >= CAST(GETDATE() AS DATE)")) {
                if (rs.next() && rs.getInt(1) < 20) {
                    needStaffSeed = true;
                }
            }
            if (needStaffSeed) {
                String insertStaffSql = "IF NOT EXISTS (SELECT 1 FROM Work_Schedule WHERE Staff_Employee_ID = ? AND Work_Date = ? AND Slot = ?) " +
                                        "INSERT INTO Work_Schedule (Staff_Employee_ID, Work_Date, Start_Time, End_Time, Slot, Status) VALUES (?, ?, ?, ?, ?, 'Available')";
                try (PreparedStatement ps = conn.prepareStatement(insertStaffSql)) {
                    for (int dayOffset = 0; dayOffset < 14; dayOffset++) {
                        java.time.LocalDate workDate = baseDate.plusDays(dayOffset);
                        if (workDate.getDayOfWeek() == java.time.DayOfWeek.SUNDAY) continue; // Chủ nhật nghỉ
                        String dateStr = workDate.toString();
                        // Nhân viên 12 trực cả ngày (Ca sáng + Chiều tiếp đón bệnh nhân)
                        for (String[] s : morningSlots) insertSingleRoleSlot(ps, 12, dateStr, s[0], s[1], s[2]);
                        for (String[] s : afternoonSlots) insertSingleRoleSlot(ps, 12, dateStr, s[0], s[1], s[2]);
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("ensureRealisticSchedules note: " + e.getMessage());
        }
    }

    private void insertDocSlot(PreparedStatement ps, int docId, String dateStr, String slot, String start, String end) throws SQLException {
        ps.setInt(1, docId);
        ps.setString(2, dateStr);
        ps.setString(3, slot);
        ps.setInt(4, docId);
        ps.setString(5, dateStr);
        ps.setString(6, start);
        ps.setString(7, end);
        ps.setString(8, slot);
        ps.executeUpdate();
    }

    private void insertSingleRoleSlot(PreparedStatement ps, int actorId, String dateStr, String slot, String start, String end) throws SQLException {
        ps.setInt(1, actorId);
        ps.setString(2, dateStr);
        ps.setString(3, slot);
        ps.setInt(4, actorId);
        ps.setString(5, dateStr);
        ps.setString(6, start);
        ps.setString(7, end);
        ps.setString(8, slot);
        ps.executeUpdate();
    }
}
