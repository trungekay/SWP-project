package com.visioncare.dao;

import com.visioncare.model.User;

import java.sql.*;

/**
 * DAO xá»­ lÃ½ truy váº¥n liÃªn quan Ä‘áº¿n User (Ä‘Äƒng nháº­p, Ä‘Äƒng kÃ½).
 */
public class UserDAO {

    public User login(String email, String password) throws Exception {
        String sql = "SELECT a.Account_ID, a.Email, r.Role_Name, " +
                     "COALESCE(d.Full_Name, ms.Full_Name, s.Full_Name, dir.Full_Name, sa.Full_Name, p.Full_Name, a.Email) AS Display_Name, " +
                     "COALESCE(d.Doctor_ID, ms.Specialist_ID, s.Staff_ID, dir.Director_ID, sa.Admin_ID, p.Patient_ID, 0) AS Actor_ID, " +
                     "COALESCE(d.Specialty, ms.Specialty, s.Position, N'Khúc xạ & Nhãn khoa') AS Specialty_Info, " +
                     "COALESCE(rm.Room_Name, N'P.101 (Tầng 1)') AS Room_Info, " +
                     "d.License_Number, s.Position, " +
                     "p.Phone, p.DOB, p.Address " +
                     "FROM Account a " +
                     "JOIN Role r ON a.Role_ID = r.Role_ID " +
                     "LEFT JOIN Patient p ON a.Account_ID = p.Account_ID " +
                     "LEFT JOIN Doctor d ON a.Account_ID = d.Account_ID " +
                     "LEFT JOIN Room rm ON d.Room_ID = rm.Room_ID " +
                     "LEFT JOIN Medical_Specialist ms ON a.Account_ID = ms.Account_ID " +
                     "LEFT JOIN Staff s ON a.Account_ID = s.Account_ID " +
                     "LEFT JOIN Director dir ON a.Account_ID = dir.Account_ID " +
                     "LEFT JOIN System_Admin sa ON a.Account_ID = sa.Account_ID " +
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
                    u.setFullName(rs.getString("Display_Name"));
                    u.setActorId(rs.getInt("Actor_ID"));
                    u.setSpecialty(rs.getString("Specialty_Info"));
                    u.setRoomName(rs.getString("Room_Info"));
                    u.setLicenseNumber(rs.getString("License_Number"));
                    u.setPosition(rs.getString("Position"));
                    u.setPhone(rs.getString("Phone"));
                    
                    Date dobDate = rs.getDate("DOB");
                    u.setDob(dobDate != null ? dobDate.toString() : null);
                    u.setAddress(rs.getString("Address"));
                    
                    // Map DB roles to application roles
                    String roleName = rs.getString("Role_Name");
                    if ("System_Admin".equalsIgnoreCase(roleName)) u.setRole("admin");
                    else if ("Doctor".equalsIgnoreCase(roleName)) u.setRole("doctor");
                    else if ("Medical_Specialist".equalsIgnoreCase(roleName)) u.setRole("medical_specialist");
                    else if ("Staff".equalsIgnoreCase(roleName)) u.setRole("staff");
                    else if ("Director".equalsIgnoreCase(roleName)) u.setRole("director");
                    else if ("Patient".equalsIgnoreCase(roleName)) u.setRole("patient");
                    else u.setRole(roleName.toLowerCase());
                    
                    return u;
                }
            }
        }
        return null;
    }

    /
     * ÄÄƒng kÃ½ tÃ i khoáº£n má»›i.
     * Tráº£ vá» true náº¿u thÃ nh cÃ´ng.**
     */
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

    /**
     * Cập nhật thông tin profile của Patient
     */
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

    /**
     * Cập nhật mật khẩu
     */
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
