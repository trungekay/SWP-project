package com.visioncare.dao;

import com.visioncare.model.Doctor;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO xử lý truy vấn liên quan đến Bác sĩ.
 */
public class DoctorDAO {

    public List<Doctor> getAll() throws Exception {
        List<Doctor> list = new ArrayList<>();
        String sql = "SELECT * FROM Doctor ORDER BY Doctor_ID";
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
        String sql = "SELECT * FROM Doctor WHERE Doctor_ID = ?";
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

    private Doctor mapRow(ResultSet rs) throws SQLException {
        Doctor d = new Doctor();
        d.setId(rs.getInt("Doctor_ID"));
        d.setName(rs.getString("Full_Name"));
        d.setTitle("Bác sĩ"); // Default title
        d.setSpecialty("Khám mắt tổng quát"); // Default specialty
        d.setDepartmentKey("general"); 
        d.setDescription("Bác sĩ chuyên khoa tại phòng khám VisionCare.");
        
        // Randomize images somewhat based on ID so they don't all look identical
        int imgId = (rs.getInt("Doctor_ID") % 4) + 1;
        d.setImage("doctors/doctors-" + imgId + ".jpg"); 
        d.setRating(5.0);
        return d;
    }
}
