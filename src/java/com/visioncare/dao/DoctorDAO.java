package com.visioncare.dao;

import com.visioncare.model.Doctor;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO xá»­ lÃ½ truy váº¥n liÃªn quan Ä‘áº¿n BÃ¡c sÄ©.
 */
public class DoctorDAO {

    public List<Doctor> getAll() throws Exception {
        List<Doctor> list = new ArrayList<>();
        String sql = "SELECT e.* FROM Employee_Profile e JOIN Account a ON e.Account_ID = a.Account_ID WHERE a.Role_ID = 3 ORDER BY e.Employee_ID";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        }
        return list;
    }

    public Doctor getById(int id) throws Exception {
        String sql = "SELECT e.* FROM Employee_Profile e JOIN Account a ON e.Account_ID = a.Account_ID WHERE a.Role_ID = 3 AND e.Employee_ID = ?";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    public List<Doctor> getByDepartment(String departmentKey) throws Exception {
        // Since department is not fully implemented in the new DB yet, return all
        return getAll();
    }

    public boolean assignDoctorToRoom(int doctorId, int roomId) throws Exception {
        String sql = "UPDATE Employee_Profile SET Room_ID = ? WHERE Employee_ID = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (roomId <= 0) {
                ps.setNull(1, Types.INTEGER); // Unassign room if 0
            } else {
                ps.setInt(1, roomId);
            }
            ps.setInt(2, doctorId);
            return ps.executeUpdate() > 0;
        }
    }

    private Doctor mapRow(ResultSet rs) throws SQLException {
        Doctor d = new Doctor();
        d.setId(rs.getInt("Employee_ID"));
        String fullName = rs.getString("Full_Name");
        d.setName(fullName);

        // Parse title from full name
        String title = "Bác sĩ";
        if (fullName.startsWith("TS.BS."))
            title = "Tiến sĩ";
        else if (fullName.startsWith("ThS.BS."))
            title = "Thạc sĩ";
        else if (fullName.startsWith("BSCKII."))
            title = "Bác sĩ CKII";
        else if (fullName.startsWith("BSCKI."))
            title = "Bác sĩ CKI";

        d.setTitle(title);
        d.setSpecialty(hasColumn(rs, "Specialty") && rs.getString("Specialty") != null ? rs.getString("Specialty") : "Khám mắt tổng quát");
        d.setDepartmentKey("general");
        d.setDescription("Bác sĩ chuyên khoa tại phòng khám VisionCare.");
        
        if (hasColumn(rs, "Biography")) {
            d.setBiography(rs.getString("Biography"));
        }
        if (hasColumn(rs, "Achievements")) {
            d.setAchievements(rs.getString("Achievements"));
        }

        // Randomize images somewhat based on ID so they don't all look identical
        int imgId = (rs.getInt("Employee_ID") % 4) + 1;
        d.setImage("doctors/doctors-" + imgId + ".jpg");
        d.setRating(5.0);
        
        if (hasColumn(rs, "Room_ID")) {
            d.setRoomId(rs.getInt("Room_ID"));
        }
        
        return d;
    }

    private boolean hasColumn(ResultSet rs, String columnName) throws SQLException {
        ResultSetMetaData rsmd = rs.getMetaData();
        int columns = rsmd.getColumnCount();
        for (int x = 1; x <= columns; x++) {
            if (columnName.equalsIgnoreCase(rsmd.getColumnName(x))) {
                return true;
            }
        }
        return false;
    }
}
