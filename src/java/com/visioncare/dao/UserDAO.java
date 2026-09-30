package com.visioncare.dao;

import com.visioncare.model.User;

import java.sql.*;

/**
 * DAO xá»­ lÃ½ truy váº¥n liÃªn quan Ä‘áº¿n User (Ä‘Äƒng nháº­p, Ä‘Äƒng kÃ½).
 */
public class UserDAO {

    public User login(String email, String password) throws Exception {
        String sql = "SELECT a.Account_ID, a.Email, r.Role_Name, p.Full_Name, p.Phone, p.DOB, p.Address " +
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
                    
                    // Populate from Patient if exists
                    String patientName = rs.getString("Full_Name");
                    u.setFullName(patientName != null ? patientName : rs.getString("Email"));
                    u.setPhone(rs.getString("Phone"));
                    
                    Date dobDate = rs.getDate("DOB");
                    u.setDob(dobDate != null ? dobDate.toString() : null);
                    u.setAddress(rs.getString("Address"));
                    
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
     * ÄÄƒng kÃ½ tÃ i khoáº£n má»›i.
     * Tráº£ vá» true náº¿u thÃ nh cÃ´ng.
     */
    public boolean register(User user) throws Exception {
        String insertAccount = "INSERT INTO Account (Role_ID, Email, Password, Active) VALUES ((SELECT TOP 1 Role_ID FROM Role WHERE Role_Name = 'Patient'), ?, ?, 1)";
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

    /**
     * TÃ¬m user theo email.
     */
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
}
