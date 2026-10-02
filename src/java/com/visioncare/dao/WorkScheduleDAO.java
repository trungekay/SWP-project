package com.visioncare.dao;

import com.visioncare.model.ScheduleCellDTO;
import com.visioncare.model.ScheduleRegistrationDTO;
import com.visioncare.model.User;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.*;

/**
 * DAO xu ly truy van va cap nhat Lich lam viec (Work_Schedule)
 * theo CSDL eye_clinic_db_v2.
 */
public class WorkScheduleDAO {

    /**
     * Lay ma tran lich lam viec theo actorId va khoang ngay (startOfWeek -> endOfWeek).
     * Key cua Map: "yyyy-MM-dd_SlotId" (vi du: "2026-10-01_Slot 1").
     */
    public Map<String, ScheduleCellDTO> getScheduleMatrix(int actorId, String role, String startDate, String endDate) {
        Map<String, ScheduleCellDTO> matrix = new HashMap<>();

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT ws.Schedule_ID, ws.Doctor_ID, ws.Specialist_ID, ws.Staff_ID, ")
           .append("       ws.Work_Date, ws.Slot, ws.Start_Time, ws.End_Time, ws.Session, ws.Status, ")
           .append("       COALESCE(rm.Room_Name, N'P.101') AS Room_Name, ")
           .append("       ap.Appointment_ID, ap.Patient_ID, ap.Status AS Appointment_Status, ")
           .append("       p.Full_Name AS Patient_Name, p.Phone AS Patient_Phone ")
           .append("FROM Work_Schedule ws ")
           .append("LEFT JOIN Doctor d ON ws.Doctor_ID = d.Doctor_ID ")
           .append("LEFT JOIN Room rm ON d.Room_ID = rm.Room_ID ")
           .append("LEFT JOIN Appointment ap ON ws.Schedule_ID = ap.Schedule_ID AND ap.Status != 'Canceled' ")
           .append("LEFT JOIN Patient p ON ap.Patient_ID = p.Patient_ID ")
           .append("WHERE ws.Work_Date BETWEEN ? AND ? ");

        if ("doctor".equalsIgnoreCase(role)) {
            sql.append("AND ws.Doctor_ID = ? ");
        } else if ("medical_specialist".equalsIgnoreCase(role) || "specialist".equalsIgnoreCase(role)) {
            sql.append("AND ws.Specialist_ID = ? ");
        } else if ("staff".equalsIgnoreCase(role)) {
            sql.append("AND ws.Staff_ID = ? ");
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
                    cell.setSession(rs.getString("Session"));
                    cell.setStatus(rs.getString("Status"));
                    cell.setRoomName(rs.getString("Room_Name"));

                    cell.setAppointmentId(rs.getInt("Appointment_ID"));
                    cell.setPatientId(rs.getInt("Patient_ID"));
                    cell.setPatientName(rs.getString("Patient_Name"));
                    cell.setPatientPhone(rs.getString("Patient_Phone"));
                    cell.setAppointmentStatus(rs.getString("Appointment_Status"));

                    // Key: "yyyy-MM-dd_Slot 1"
                    String key = cell.getWorkDate() + "_" + cell.getSlot();
                    matrix.put(key, cell);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return matrix;
    }

    /**
     * Lay danh sach cac Key (yyyy-MM-dd_Slot X) ma Actor da dang ky trong khoang ngay.
     */
    public Set<String> getRegisteredSlotKeys(int actorId, String role, String startDate, String endDate) {
        Set<String> set = new HashSet<>();
        StringBuilder sql = new StringBuilder("SELECT Work_Date, Slot FROM Work_Schedule WHERE Work_Date BETWEEN ? AND ? ");
        
        if ("doctor".equalsIgnoreCase(role)) {
            sql.append("AND Doctor_ID = ? ");
        } else if ("medical_specialist".equalsIgnoreCase(role) || "specialist".equalsIgnoreCase(role)) {
            sql.append("AND Specialist_ID = ? ");
        } else if ("staff".equalsIgnoreCase(role)) {
            sql.append("AND Staff_ID = ? ");
        }

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            ps.setString(1, startDate);
            ps.setString(2, endDate);
            ps.setInt(3, actorId);

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

    /**
     * Dang ky hang loat ca lam viec vao bang Work_Schedule theo Transaction Batch.
     * Su dung IF NOT EXISTS de dam bao khong bi trung lap du lieu.
     */
    public boolean registerScheduleBatch(int actorId, String role, List<ScheduleRegistrationDTO> list) {
        if (list == null || list.isEmpty()) {
            return false;
        }

        StringBuilder sql = new StringBuilder();
        sql.append("IF NOT EXISTS (SELECT 1 FROM Work_Schedule WHERE Work_Date = ? AND Slot = ? ");
        if ("doctor".equalsIgnoreCase(role)) {
            sql.append("AND Doctor_ID = ?) ");
        } else if ("medical_specialist".equalsIgnoreCase(role) || "specialist".equalsIgnoreCase(role)) {
            sql.append("AND Specialist_ID = ?) ");
        } else if ("staff".equalsIgnoreCase(role)) {
            sql.append("AND Staff_ID = ?) ");
        } else {
            sql.append(") ");
        }
        sql.append("BEGIN ")
           .append("INSERT INTO Work_Schedule (Doctor_ID, Specialist_ID, Staff_ID, Work_Date, Slot, Start_Time, End_Time, Session, Status) ")
           .append("VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'Available') ")
           .append("END");

        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);

            try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
                for (ScheduleRegistrationDTO item : list) {
                    // Check params
                    ps.setString(1, item.getWorkDate());
                    ps.setString(2, item.getSlot());
                    ps.setInt(3, actorId);

                    // Insert params
                    if ("doctor".equalsIgnoreCase(role)) {
                        ps.setInt(4, actorId);
                        ps.setNull(5, java.sql.Types.INTEGER);
                        ps.setNull(6, java.sql.Types.INTEGER);
                    } else if ("medical_specialist".equalsIgnoreCase(role) || "specialist".equalsIgnoreCase(role)) {
                        ps.setNull(4, java.sql.Types.INTEGER);
                        ps.setInt(5, actorId);
                        ps.setNull(6, java.sql.Types.INTEGER);
                    } else if ("staff".equalsIgnoreCase(role)) {
                        ps.setNull(4, java.sql.Types.INTEGER);
                        ps.setNull(5, java.sql.Types.INTEGER);
                        ps.setInt(6, actorId);
                    } else {
                        ps.setNull(4, java.sql.Types.INTEGER);
                        ps.setNull(5, java.sql.Types.INTEGER);
                        ps.setNull(6, java.sql.Types.INTEGER);
                    }

                    ps.setString(7, item.getWorkDate());
                    ps.setString(8, item.getSlot());
                    ps.setString(9, item.getStartTime());
                    ps.setString(10, item.getEndTime());
                    ps.setString(11, item.getSession());

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

    /**
     * Lay danh sach tat ca Bac si, Chuyen vien, Nhan vien de hien thi trong Switcher chon xem.
     */
    public List<User> getStaffAndDoctorList() {
        List<User> list = new ArrayList<>();
        String sql = "SELECT 'doctor' AS Role_Type, d.Doctor_ID AS Actor_ID, d.Full_Name, d.Specialty, rm.Room_Name " +
                     "FROM Doctor d LEFT JOIN Room rm ON d.Room_ID = rm.Room_ID " +
                     "UNION ALL " +
                     "SELECT 'medical_specialist' AS Role_Type, ms.Specialist_ID AS Actor_ID, ms.Full_Name, ms.Specialty, N'Phòng Kỹ Thuật' AS Room_Name " +
                     "FROM Medical_Specialist ms " +
                     "UNION ALL " +
                     "SELECT 'staff' AS Role_Type, s.Staff_ID AS Actor_ID, s.Full_Name, s.Position, N'Quầy Lễ Tân' AS Room_Name " +
                     "FROM Staff s";

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

    /**
     * Lay thong tin chi tiet cua mot Actor theo actorId va role.
     */
    public User getActorProfile(int actorId, String role) {
        String sql = "";
        if ("doctor".equalsIgnoreCase(role)) {
            sql = "SELECT d.Doctor_ID AS Actor_ID, d.Full_Name, d.Specialty, rm.Room_Name, d.License_Number, 'doctor' AS Role " +
                  "FROM Doctor d LEFT JOIN Room rm ON d.Room_ID = rm.Room_ID WHERE d.Doctor_ID = ?";
        } else if ("medical_specialist".equalsIgnoreCase(role) || "specialist".equalsIgnoreCase(role)) {
            sql = "SELECT ms.Specialist_ID AS Actor_ID, ms.Full_Name, ms.Specialty, N'Phòng Đo Khúc Xạ' AS Room_Name, '' AS License_Number, 'medical_specialist' AS Role " +
                  "FROM Medical_Specialist ms WHERE ms.Specialist_ID = ?";
        } else if ("staff".equalsIgnoreCase(role)) {
            sql = "SELECT s.Staff_ID AS Actor_ID, s.Full_Name, s.Position AS Specialty, N'Quầy Lễ Tân' AS Room_Name, '' AS License_Number, 'staff' AS Role " +
                  "FROM Staff s WHERE s.Staff_ID = ?";
        } else {
            return null;
        }

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
