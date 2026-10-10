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
        sql.append("SELECT ws.Schedule_ID, ws.Doctor_Employee_ID, ws.Specialist_Employee_ID, ")
           .append("       ws.Work_Date, ws.Slot, ws.Start_Time, ws.End_Time, ws.Status, ")
           .append("       COALESCE(rm.Room_Name, N'P.101') AS Room_Name, ")
           .append("       ap.Appointment_ID, ap.Patient_ID, ap.Status AS Appointment_Status, ")
           .append("       p.Full_Name AS Patient_Name, p.Phone AS Patient_Phone ")
           .append("FROM Work_Schedule ws ")
           .append("LEFT JOIN Employee_Profile e ON (ws.Doctor_Employee_ID = e.Employee_ID OR ws.Specialist_Employee_ID = e.Employee_ID) ")
           .append("LEFT JOIN Room rm ON e.Room_ID = rm.Room_ID ")
           .append("LEFT JOIN Appointment ap ON ws.Schedule_ID = ap.Schedule_ID AND ap.Status != 'Canceled' ")
           .append("LEFT JOIN Patient p ON ap.Patient_ID = p.Patient_ID ")
           .append("WHERE ws.Work_Date BETWEEN ? AND ? ");
        if ("doctor".equalsIgnoreCase(role)) {
            sql.append("AND ws.Doctor_Employee_ID = ? ");
        } else if ("medical_specialist".equalsIgnoreCase(role) || "specialist".equalsIgnoreCase(role) || "staff".equalsIgnoreCase(role)) {
            sql.append("AND ws.Specialist_Employee_ID = ? ");
        }
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            ps.setString(1, startDate);
            ps.setString(2, endDate);
            if ("doctor".equalsIgnoreCase(role) || "medical_specialist".equalsIgnoreCase(role) || "specialist".equalsIgnoreCase(role) || "staff".equalsIgnoreCase(role)) {
                ps.setInt(3, actorId);
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
        } else if ("medical_specialist".equalsIgnoreCase(role) || "specialist".equalsIgnoreCase(role) || "staff".equalsIgnoreCase(role)) {
            sql.append("AND Specialist_Employee_ID = ? ");
        }
        sql.append("AND Status NOT IN ('Canceled', 'Inactive', 'Disabled', 'Closed') ");
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            ps.setString(1, startDate);
            ps.setString(2, endDate);
            if ("doctor".equalsIgnoreCase(role) || "medical_specialist".equalsIgnoreCase(role) || "specialist".equalsIgnoreCase(role) || "staff".equalsIgnoreCase(role)) {
                ps.setInt(3, actorId);
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
        } else if ("medical_specialist".equalsIgnoreCase(role) || "specialist".equalsIgnoreCase(role) || "staff".equalsIgnoreCase(role)) {
            sql.append("AND Specialist_Employee_ID = ? ");
        }
        sql.append("AND Status IN ('Canceled', 'Inactive', 'Disabled', 'Closed') ");
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            ps.setString(1, startDate);
            ps.setString(2, endDate);
            if ("doctor".equalsIgnoreCase(role) || "medical_specialist".equalsIgnoreCase(role) || "specialist".equalsIgnoreCase(role) || "staff".equalsIgnoreCase(role)) {
                ps.setInt(3, actorId);
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
        } else if ("medical_specialist".equalsIgnoreCase(role) || "specialist".equalsIgnoreCase(role) || "staff".equalsIgnoreCase(role)) {
            sql.append("AND Specialist_Employee_ID = ?) ");
        } else {
            sql.append(") ");
        }
        sql.append("BEGIN ")
           .append("INSERT INTO Work_Schedule (Doctor_Employee_ID, Specialist_Employee_ID, Work_Date, Slot, Start_Time, End_Time, Status) ")
           .append("VALUES (?, ?, ?, ?, ?, ?, 'Available') ")
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
                    } else if ("medical_specialist".equalsIgnoreCase(role) || "specialist".equalsIgnoreCase(role) || "staff".equalsIgnoreCase(role)) {
                        ps.setNull(pIndex++, java.sql.Types.INTEGER);
                        ps.setInt(pIndex++, actorId);
                    } else {
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
        String sql = "SELECT LOWER(r.Role_Name) AS Role_Type, e.Employee_ID AS Actor_ID, e.Full_Name, COALESCE(e.Specialty, 'Nhân viên') AS Specialty, COALESCE(rm.Room_Name, 'Chưa xếp phòng') AS Room_Name " +
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
    public User getActorProfile(int actorId, String role) {
        String sql = "SELECT e.Employee_ID AS Actor_ID, e.Full_Name, COALESCE(e.Specialty, 'Nhân viên') AS Specialty, COALESCE(rm.Room_Name, 'Chưa xếp phòng') AS Room_Name, e.License_Number, LOWER(r.Role_Name) AS Role " +
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
        ensureRealisticDoctorSchedules();
        String sql = "SELECT ws.Schedule_ID, ws.Doctor_Employee_ID, ws.Work_Date, ws.Slot, " +
                     "       CONVERT(VARCHAR(5), ws.Start_Time, 108) AS Start_Time_Str, " +
                     "       CONVERT(VARCHAR(5), ws.End_Time, 108) AS End_Time_Str, " +
                     "       ws.Status, " +
                     "       CASE " +
                     "         WHEN ws.Status = 'Booked' THEN 1 " +
                     "         WHEN EXISTS (SELECT 1 FROM Appointment ap WHERE ap.Schedule_ID = ws.Schedule_ID AND ap.Status NOT IN ('Canceled', 'Rejected')) THEN 1 " +
                     "         ELSE 0 " +
                     "       END AS Is_Booked " +
                     "FROM Work_Schedule ws " +
                     "WHERE ws.Doctor_Employee_ID = ? AND ws.Work_Date = ? " +
                     "  AND CAST(ws.Start_Time AS TIME) < '17:30:00' " + // Bỏ toàn bộ ca tối
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
                    ts.setBooked(rs.getInt("Is_Booked") == 1);
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
        try (Connection conn = DBContext.getConnection()) {
            // Kiểm tra xem đã có slot ban ngày cho các bác sĩ trong tháng hiện tại chưa
            String checkSql = "SELECT COUNT(*) FROM Work_Schedule WHERE Work_Date >= CAST(GETDATE() AS DATE) AND CAST(Start_Time AS TIME) < '17:30:00'";
            try (Statement st = conn.createStatement();
                 ResultSet rs = st.executeQuery(checkSql)) {
                if (rs.next() && rs.getInt(1) >= 30) {
                    return; // Đã có đủ dữ liệu lịch trực ban ngày
                }
            }

            // Mẫu slot ca sáng và ca chiều
            String[][] morningSlots = {
                {"Slot 1", "08:00:00", "08:30:00"},
                {"Slot 2", "08:30:00", "09:00:00"},
                {"Slot 3", "09:00:00", "09:30:00"},
                {"Slot 4", "09:30:00", "10:00:00"},
                {"Slot 5", "10:00:00", "10:30:00"},
                {"Slot 6", "10:30:00", "11:00:00"},
                {"Slot 7", "11:00:00", "11:30:00"}
            };
            String[][] afternoonSlots = {
                {"Slot 8", "13:30:00", "14:00:00"},
                {"Slot 9", "14:00:00", "14:30:00"},
                {"Slot 10", "14:30:00", "15:00:00"},
                {"Slot 11", "15:00:00", "15:30:00"},
                {"Slot 12", "15:30:00", "16:00:00"},
                {"Slot 13", "16:00:00", "16:30:00"}
            };

            // Gán ca làm việc chân thực cho 6 bác sĩ (ID 3 đến 8) trong 14 ngày tới:
            // Bác sĩ 3 & 6: Full ngày (Sáng & Chiều)
            // Bác sĩ 4 & 7: Chỉ ca Sáng
            // Bác sĩ 5 & 8: Chỉ ca Chiều
            String insertSql = "IF NOT EXISTS (SELECT 1 FROM Work_Schedule WHERE Doctor_Employee_ID = ? AND Work_Date = ? AND Slot = ?) " +
                               "INSERT INTO Work_Schedule (Doctor_Employee_ID, Work_Date, Start_Time, End_Time, Slot, Status) VALUES (?, ?, ?, ?, ?, 'Available')";

            try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                java.time.LocalDate baseDate = java.time.LocalDate.now();
                for (int dayOffset = 0; dayOffset < 14; dayOffset++) {
                    java.time.LocalDate workDate = baseDate.plusDays(dayOffset);
                    String dateStr = workDate.toString();

                    int[] fullDocs = {3, 6};
                    int[] morningDocs = {4, 7};
                    int[] afternoonDocs = {5, 8};

                    // Full doctors (Sáng + Chiều)
                    for (int docId : fullDocs) {
                        for (String[] s : morningSlots) {
                            insertSlot(ps, docId, dateStr, s[0], s[1], s[2]);
                        }
                        for (String[] s : afternoonSlots) {
                            insertSlot(ps, docId, dateStr, s[0], s[1], s[2]);
                        }
                    }

                    // Morning only doctors
                    for (int docId : morningDocs) {
                        for (String[] s : morningSlots) {
                            insertSlot(ps, docId, dateStr, s[0], s[1], s[2]);
                        }
                    }

                    // Afternoon only doctors
                    for (int docId : afternoonDocs) {
                        for (String[] s : afternoonSlots) {
                            insertSlot(ps, docId, dateStr, s[0], s[1], s[2]);
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("ensureRealisticDoctorSchedules note: " + e.getMessage());
        }
    }

    private void insertSlot(PreparedStatement ps, int docId, String dateStr, String slot, String start, String end) throws SQLException {
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
}
