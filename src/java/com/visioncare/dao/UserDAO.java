package com.visioncare.dao;

import com.visioncare.model.User;

import java.sql.*;

public class UserDAO {

    public User login(String email, String password) throws Exception {
        String sql = "SELECT a.Account_ID, a.Email, a.Password, r.Role_Name, p.Full_Name, p.Phone, p.DOB, p.Address " +
                     "FROM Account a JOIN Role r ON a.Role_ID = r.Role_ID " +
                     "LEFT JOIN Patient p ON a.Account_ID = p.Account_ID " +
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
                    u.setPassword(rs.getString("Password"));
                    
                    String patientName = rs.getString("Full_Name");
                    u.setFullName(patientName != null ? patientName : rs.getString("Email"));
                    u.setPhone(rs.getString("Phone"));
                    
                    Date dobDate = rs.getDate("DOB");
                    u.setDob(dobDate != null ? dobDate.toString() : null);
                    u.setAddress(rs.getString("Address"));
                    
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

    public boolean register(User user) throws Exception {
        String insertAccount = "INSERT INTO Account (Role_ID, Email, Password) VALUES ((SELECT TOP 1 Role_ID FROM Role WHERE Role_Name = 'Patient'), ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(insertAccount, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, user.getEmail());
            ps.setString(2, user.getPassword());
            ps.executeUpdate();
            
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    int accId = rs.getInt(1);
                    String insertPatient = "INSERT INTO Patient (Account_ID, Phone, Full_Name) VALUES (?, ?, ?)";
                    try (PreparedStatement ps2 = conn.prepareStatement(insertPatient)) {
                        ps2.setInt(1, accId);
                        ps2.setString(2, user.getPhone());
                        ps2.setString(3, user.getFullName());
                        ps2.executeUpdate();
                    }
                    return true;
                }
            }
        }
        return false;
    }

    public User getByEmail(String email) throws Exception {
        String sql = "SELECT a.*, p.Full_Name, p.Phone, p.DOB, p.Address FROM Account a LEFT JOIN Patient p ON a.Account_ID = p.Account_ID WHERE a.Email = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    User u = new User();
                    u.setId(rs.getInt("Account_ID"));
                    u.setEmail(rs.getString("Email"));
                    u.setPassword(rs.getString("Password"));
                    u.setFullName(rs.getString("Full_Name"));
                    u.setPhone(rs.getString("Phone"));
                    
                    Date dobDate = rs.getDate("DOB");
                    u.setDob(dobDate != null ? dobDate.toString() : null);
                    u.setAddress(rs.getString("Address"));
                    
                    return u;
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

    public boolean updateProfile(User user) throws Exception {
        String sql = "UPDATE Patient SET Full_Name = ?, Phone = ?, DOB = ?, Address = ? WHERE Account_ID = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, user.getFullName());
            ps.setString(2, user.getPhone());
            if (user.getDob() != null && !user.getDob().isEmpty()) {
                ps.setDate(3, java.sql.Date.valueOf(user.getDob()));
            } else {
                ps.setNull(3, java.sql.Types.DATE);
            }
            ps.setString(4, user.getAddress());
            ps.setInt(5, user.getId());
            return ps.executeUpdate() > 0;
        }
    }

    public boolean updatePassword(int accountId, String newPassword) throws Exception {
        String sql = "UPDATE Account SET Password = ? WHERE Account_ID = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newPassword);
            ps.setInt(2, accountId);
            return ps.executeUpdate() > 0;
        }
    }
}
