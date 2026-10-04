package com.visioncare.dao;
import com.visioncare.model.ScheduleCellDTO;
import com.visioncare.model.ScheduleRegistrationDTO;
import com.visioncare.model.User;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
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
        } else if ("medical_specialist".equalsIgnoreCase(role) || "specialist".equalsIgnoreCase(role)) {
            sql.append("AND ws.Specialist_Employee_ID = ? ");
        }
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            ps.setString(1, startDate);
            ps.setString(2, endDate);
            if ("doctor".equalsIgnoreCase(role) || "medical_specialist".equalsIgnoreCase(role) || "specialist".equalsIgnoreCase(role)) {
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
        } else if ("medical_specialist".equalsIgnoreCase(role) || "specialist".equalsIgnoreCase(role)) {
            sql.append("AND Specialist_Employee_ID = ? ");
        }
        sql.append("AND Status NOT IN ('Canceled', 'Inactive', 'Disabled', 'Closed') ");
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            ps.setString(1, startDate);
            ps.setString(2, endDate);
            if ("doctor".equalsIgnoreCase(role) || "medical_specialist".equalsIgnoreCase(role) || "specialist".equalsIgnoreCase(role)) {
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
        } else if ("medical_specialist".equalsIgnoreCase(role) || "specialist".equalsIgnoreCase(role)) {
            sql.append("AND Specialist_Employee_ID = ? ");
        }
        sql.append("AND Status IN ('Canceled', 'Inactive', 'Disabled', 'Closed') ");
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            ps.setString(1, startDate);
            ps.setString(2, endDate);
            if ("doctor".equalsIgnoreCase(role) || "medical_specialist".equalsIgnoreCase(role) || "specialist".equalsIgnoreCase(role)) {
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
        } else if ("medical_specialist".equalsIgnoreCase(role) || "specialist".equalsIgnoreCase(role)) {
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
                    ps.setString(1, item.getWorkDate());
                    ps.setString(2, item.getSlot());
                    if ("doctor".equalsIgnoreCase(role) || "medical_specialist".equalsIgnoreCase(role) || "specialist".equalsIgnoreCase(role)) {
                        ps.setInt(3, actorId);
                    } else {
                        ps.setNull(3, java.sql.Types.INTEGER);
                    }
                    if ("doctor".equalsIgnoreCase(role)) {
                        ps.setInt(4, actorId);
                        ps.setNull(5, java.sql.Types.INTEGER);
                    } else if ("medical_specialist".equalsIgnoreCase(role) || "specialist".equalsIgnoreCase(role)) {
                        ps.setNull(4, java.sql.Types.INTEGER);
                        ps.setInt(5, actorId);
                    } else {
                        ps.setNull(4, java.sql.Types.INTEGER);
                        ps.setNull(5, java.sql.Types.INTEGER);
                    }
                    ps.setString(6, item.getWorkDate());
                    ps.setString(7, item.getSlot());
                    ps.setString(8, item.getStartTime());
                    ps.setString(9, item.getEndTime());
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
}
