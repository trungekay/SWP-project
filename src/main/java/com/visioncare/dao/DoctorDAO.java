package com.visioncare.dao;

import com.visioncare.model.Doctor;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO xử lý truy vấn liên quan đến Bác sĩ.
 */
public class DoctorDAO {

    /**
     * Lấy danh sách tất cả bác sĩ.
     */
    public List<Doctor> getAll() throws Exception {
        List<Doctor> list = new ArrayList<>();
        String sql = "SELECT * FROM doctors ORDER BY id";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        }
        return list;
    }

    /**
     * Lấy bác sĩ theo ID.
     */
    public Doctor getById(int id) throws Exception {
        String sql = "SELECT * FROM doctors WHERE id = ?";
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

    /**
     * Lấy danh sách bác sĩ theo chuyên khoa (department_key).
     */
    public List<Doctor> getByDepartment(String departmentKey) throws Exception {
        List<Doctor> list = new ArrayList<>();
        String sql = "SELECT * FROM doctors WHERE department_key = ? ORDER BY id";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, departmentKey);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        }
        return list;
    }

    /**
     * Map một dòng ResultSet thành đối tượng Doctor.
     */
    private Doctor mapRow(ResultSet rs) throws SQLException {
        Doctor d = new Doctor();
        d.setId(rs.getInt("id"));
        d.setName(rs.getString("name"));
        d.setTitle(rs.getString("title"));
        d.setSpecialty(rs.getString("specialty"));
        d.setDepartmentKey(rs.getString("department_key"));
        d.setDescription(rs.getString("description"));
        d.setImage(rs.getString("image"));
        d.setRating(rs.getDouble("rating"));
        return d;
    }
}
