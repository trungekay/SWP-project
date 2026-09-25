package com.visioncare.dao;

import com.visioncare.model.Department;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO xử lý truy vấn liên quan đến Chuyên khoa.
 */
public class DepartmentDAO {

    /**
     * Lấy danh sách tất cả chuyên khoa.
     */
    public List<Department> getAll() throws Exception {
        List<Department> list = new ArrayList<>();
        String sql = "SELECT * FROM departments ORDER BY id";
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
     * Lấy chuyên khoa theo key.
     */
    public Department getByKey(String key) throws Exception {
        String sql = "SELECT * FROM departments WHERE dept_key = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, key);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    private Department mapRow(ResultSet rs) throws SQLException {
        Department d = new Department();
        d.setId(rs.getInt("id"));
        d.setKey(rs.getString("dept_key"));
        d.setName(rs.getString("name"));
        d.setIcon(rs.getString("icon"));
        d.setDescription(rs.getString("description"));
        return d;
    }
}
