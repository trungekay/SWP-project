package com.visioncare.dao;

import com.visioncare.model.User;

import java.sql.*;

/**
 * DAO xử lý truy vấn liên quan đến User (đăng nhập, đăng ký).
 */
public class UserDAO {

    public User login(String email, String password) throws Exception {
        String sql = "SELECT a.Account_ID, a.Email, r.Role_Name " +
                     "FROM Account a JOIN Role r ON a.Role_ID = r.Role_ID " +
                     "WHERE a.Email = ? AND a.Password = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setString(2, password);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    User u = new User();
                    u.setId(rs.getInt("Account_ID"));
                    u.setEmail(rs.getString("Email"));
                    u.setFullName(email); // We don't join profile tables yet, just use email
                    
                    // Map DB roles to application roles
                    String roleName = rs.getString("Role_Name");
                    if ("System_Admin".equals(roleName)) u.setRole("admin");
                    else if ("Doctor".equals(roleName)) u.setRole("doctor");
                    else if ("Patient".equals(roleName)) u.setRole("patient");
                    else u.setRole(roleName.toLowerCase());
                    
                    return u;
                }
            }
        }
        return null;
    }

    /**
     * Đăng ký tài khoản mới.
     * Trả về true nếu thành công.
     */
    public boolean register(User user) throws Exception {
        String sql = "INSERT INTO users (full_name, email, password, phone, role) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, user.getFullName());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getPassword());
            ps.setString(4, user.getPhone());
            ps.setString(5, user.getRole() != null ? user.getRole() : "patient");
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Tìm user theo email.
     */
    public User getByEmail(String email) throws Exception {
        String sql = "SELECT * FROM users WHERE email = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    private User mapRow(ResultSet rs) throws SQLException {
        User u = new User();
        u.setId(rs.getInt("id"));
        u.setFullName(rs.getString("full_name"));
        u.setEmail(rs.getString("email"));
        u.setPassword(rs.getString("password"));
        u.setPhone(rs.getString("phone"));
        u.setRole(rs.getString("role"));
        return u;
    }
}
