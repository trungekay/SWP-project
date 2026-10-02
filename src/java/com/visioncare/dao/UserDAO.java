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

    public java.util.List<User> getAllUsers() throws Exception {
        java.util.List<User> list = new java.util.ArrayList<>();
        String sql = "SELECT a.Account_ID, a.Email, a.Account_Status, r.Role_ID, r.Role_Name, " +
                     "COALESCE(p.Full_Name, d.Full_Name, s.Full_Name, ms.Full_Name, sa.Full_Name, dir.Full_Name) as Full_Name, " +
                     "p.Phone, p.DOB, p.Address " +
                     "FROM Account a " +
                     "JOIN Role r ON a.Role_ID = r.Role_ID " +
                     "LEFT JOIN Patient p ON a.Account_ID = p.Account_ID " +
                     "LEFT JOIN Doctor d ON a.Account_ID = d.Account_ID " +
                     "LEFT JOIN Staff s ON a.Account_ID = s.Account_ID " +
                     "LEFT JOIN Medical_Specialist ms ON a.Account_ID = ms.Account_ID " +
                     "LEFT JOIN System_Admin sa ON a.Account_ID = sa.Account_ID " +
                     "LEFT JOIN Director dir ON a.Account_ID = dir.Account_ID " +
                     "ORDER BY a.Account_ID DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                User u = new User();
                u.setId(rs.getInt("Account_ID"));
                u.setEmail(rs.getString("Email"));
                u.setFullName(rs.getString("Full_Name"));
                u.setPhone(rs.getString("Phone"));
                u.setRoleId(rs.getInt("Role_ID"));
                u.setRole(rs.getString("Role_Name"));
                u.setStatus(rs.getString("Account_Status"));
                list.add(u);
            }
        }
        return list;
    }

    public boolean deleteUser(int accountId) throws Exception {
        try (Connection conn = DBContext.getConnection()) {
            String[] profileTables = {"System_Admin", "Director", "Staff", "Doctor", "Medical_Specialist", "Patient"};
            for (String table : profileTables) {
                String sqlDelProfile = "DELETE FROM " + table + " WHERE Account_ID = ?";
                try (PreparedStatement ps = conn.prepareStatement(sqlDelProfile)) {
                    ps.setInt(1, accountId);
                    ps.executeUpdate();
                } catch (Exception e) {}
            }
            String sqlDelAcc = "DELETE FROM Account WHERE Account_ID = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlDelAcc)) {
                ps.setInt(1, accountId);
                return ps.executeUpdate() > 0;
            }
        }
    }

    public boolean addSystemUser(User user) throws Exception {
        String insertAccount = "INSERT INTO Account (Role_ID, Email, Password, Account_Status) VALUES (?, ?, ?, 'Active')";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(insertAccount, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, user.getRoleId());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getPassword());
            ps.executeUpdate();
            
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    int accId = rs.getInt(1);
                    String insertDetail = "";
                    if (user.getRoleId() == 1) insertDetail = "INSERT INTO System_Admin (Account_ID, Full_Name) VALUES (?, ?)";
                    else if (user.getRoleId() == 2) insertDetail = "INSERT INTO Director (Account_ID, Full_Name) VALUES (?, ?)";
                    else if (user.getRoleId() == 5) insertDetail = "INSERT INTO Staff (Account_ID, Full_Name) VALUES (?, ?)";
                    else if (user.getRoleId() == 3) insertDetail = "INSERT INTO Doctor (Account_ID, Full_Name, License_Number) VALUES (?, ?, ?)";
                    else if (user.getRoleId() == 4) insertDetail = "INSERT INTO Medical_Specialist (Account_ID, Full_Name) VALUES (?, ?)";
                    else insertDetail = "INSERT INTO Patient (Account_ID, Full_Name, Phone) VALUES (?, ?, ?)";
                    
                    if (!insertDetail.isEmpty()) {
                        try (PreparedStatement ps2 = conn.prepareStatement(insertDetail)) {
                            ps2.setInt(1, accId);
                            ps2.setString(2, user.getFullName());
                            if (user.getRoleId() == 3) {
                                ps2.setString(3, "DOC-" + accId); 
                            } else if (user.getRoleId() == 6) {
                                String phone = (user.getPhone() != null && !user.getPhone().trim().isEmpty()) ? user.getPhone() : "000" + accId;
                                ps2.setString(3, phone);
                            }
                            ps2.executeUpdate();
                        } catch(Exception e) {}
                    }
                    return true;
                }
            }
        }
        return false;
    }

    public User getUserById(int accountId) throws Exception {
        String sql = "SELECT a.Account_ID, a.Email, a.Account_Status, r.Role_ID, r.Role_Name, " +
                     "COALESCE(p.Full_Name, d.Full_Name, s.Full_Name, ms.Full_Name, sa.Full_Name, dir.Full_Name) as Full_Name, " +
                     "p.Phone, p.DOB, p.Address " +
                     "FROM Account a " +
                     "JOIN Role r ON a.Role_ID = r.Role_ID " +
                     "LEFT JOIN Patient p ON a.Account_ID = p.Account_ID " +
                     "LEFT JOIN Doctor d ON a.Account_ID = d.Account_ID " +
                     "LEFT JOIN Staff s ON a.Account_ID = s.Account_ID " +
                     "LEFT JOIN Medical_Specialist ms ON a.Account_ID = ms.Account_ID " +
                     "LEFT JOIN System_Admin sa ON a.Account_ID = sa.Account_ID " +
                     "LEFT JOIN Director dir ON a.Account_ID = dir.Account_ID " +
                     "WHERE a.Account_ID = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    User u = new User();
                    u.setId(rs.getInt("Account_ID"));
                    u.setEmail(rs.getString("Email"));
                    u.setFullName(rs.getString("Full_Name"));
                    u.setPhone(rs.getString("Phone"));
                    u.setRoleId(rs.getInt("Role_ID"));
                    u.setRole(rs.getString("Role_Name"));
                    u.setStatus(rs.getString("Account_Status"));
                    return u;
                }
            }
        }
        return null;
    }

    public void updateUserRole(int accountId, int newRoleId) throws Exception {
        String sql = "UPDATE Account SET Role_ID = ? WHERE Account_ID = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, newRoleId);
            ps.setInt(2, accountId);
            ps.executeUpdate();
        }
    }

    public void updateAccountStatus(int accountId, String status) throws Exception {
        String sql = "UPDATE Account SET Account_Status = ? WHERE Account_ID = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, accountId);
            ps.executeUpdate();
        }
    }

    public void updateUserProfile(int accountId, String fullName, String phone) throws Exception {
        try (Connection conn = DBContext.getConnection()) {
            String[] tables = {"System_Admin", "Director", "Staff", "Doctor", "Medical_Specialist"};
            for (String table : tables) {
                String sql = "UPDATE " + table + " SET Full_Name = ? WHERE Account_ID = ?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, fullName);
                    ps.setInt(2, accountId);
                    ps.executeUpdate();
                } catch(Exception e) {}
            }
            
            String sqlPatient = "UPDATE Patient SET Full_Name = ?, Phone = ? WHERE Account_ID = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlPatient)) {
                ps.setString(1, fullName);
                ps.setString(2, phone);
                ps.setInt(3, accountId);
                ps.executeUpdate();
            }
        }
    }
}
