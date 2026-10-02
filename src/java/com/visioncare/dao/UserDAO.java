package com.visioncare.dao;

import com.visioncare.model.User;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
/**
 * DAO xá»­ lÃ½ truy váº¥n liÃªn quan Ä‘áº¿n User (Ä‘Äƒng nháº­p, Ä‘Äƒng kÃ½).
 */
public class UserDAO {

    public User login(String email, String password) throws Exception {
        String sql = "SELECT a.Account_ID, a.Email, r.Role_Name, COALESCE(p.Full_Name, e.Full_Name) as Full_Name, COALESCE(p.Phone, e.Phone) as Phone, p.DOB, p.Address " +
                     "FROM Account a JOIN Role r ON a.Role_ID = r.Role_ID " +
                     "LEFT JOIN Patient p ON a.Account_ID = p.Account_ID " +
                     "LEFT JOIN Employee_Profile e ON a.Account_ID = e.Account_ID " +
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
                    // Map DB roles to application roles
                    String roleName = rs.getString("Role_Name");
                    if ("Admin".equals(roleName)) u.setRole("admin");
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
        String sql = "SELECT a.*, COALESCE(p.Full_Name, e.Full_Name) as Full_Name, COALESCE(p.Phone, e.Phone) as Phone, p.DOB, p.Address FROM Account a LEFT JOIN Patient p ON a.Account_ID = p.Account_ID LEFT JOIN Employee_Profile e ON a.Account_ID = e.Account_ID WHERE a.Email = ?";
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

    private User mapUserFromResultSet(ResultSet rs) throws SQLException {
        User u = new User();
        u.setId(rs.getInt("Account_ID"));
        u.setEmail(rs.getString("Email"));
        u.setRoleId(rs.getInt("Role_ID"));
        u.setStatus(rs.getString("Account_Status"));
        
        String roleName = rs.getString("Role_Name");
        u.setRole(roleName);
        
        String fullName = rs.getString("Full_Name");
        u.setFullName(fullName != null ? fullName : rs.getString("Email"));
        
        try { u.setPhone(rs.getString("Phone")); } catch (SQLException e) {}
        try {
            Date dobDate = rs.getDate("DOB");
            u.setDob(dobDate != null ? dobDate.toString() : null);
        } catch (SQLException e) {}
        try { u.setAddress(rs.getString("Address")); } catch (SQLException e) {}
        
        return u;
    }

    public List<User> getAllUsers() throws Exception {
        List<User> list = new ArrayList<>();
        String sql = "SELECT a.Account_ID, a.Email, a.Account_Status, r.Role_ID, r.Role_Name, " +
                     "COALESCE(p.Full_Name, e.Full_Name) as Full_Name, " +
                     "COALESCE(p.Phone, e.Phone) as Phone, p.DOB, p.Address " +
                     "FROM Account a " +
                     "JOIN Role r ON a.Role_ID = r.Role_ID " +
                     "LEFT JOIN Patient p ON a.Account_ID = p.Account_ID " +
                     "LEFT JOIN Employee_Profile e ON a.Account_ID = e.Account_ID " +
                     "ORDER BY a.Account_ID DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapUserFromResultSet(rs));
            }
        }
        return list;
    }

    public boolean updateAccountStatus(int accountId, String status) throws Exception {
        String sql = "UPDATE Account SET Account_Status = ? WHERE Account_ID = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, accountId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean deleteUser(int accountId) throws Exception {
        try (Connection conn = DBContext.getConnection()) {
            // Cố gắng xóa các record liên kết ở các bảng vai trò trước
            String[] profileTables = {"Employee_Profile", "Patient"};
            for (String table : profileTables) {
                try (PreparedStatement ps = conn.prepareStatement("DELETE FROM " + table + " WHERE Account_ID = ?")) {
                    ps.setInt(1, accountId);
                    ps.executeUpdate();
                } catch (SQLException ignored) {
                    // Nếu bảng này bị vướng khóa ngoại cấp 3 (như lịch khám, hóa đơn...), nó sẽ throw lỗi.
                    // Ta cứ kệ, để đến lệnh xóa Account bên dưới nó sẽ tự bắt lỗi và trả về false.
                }
            }
            
            // Cuối cùng xóa Account
            String sql = "DELETE FROM Account WHERE Account_ID = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, accountId);
                return ps.executeUpdate() > 0;
            } catch (SQLException e) {
                return false; // Constraint error implies dependent records exist
            }
        }
    }

    public boolean addSystemUser(User user) throws Exception {
        String insertAccount = "INSERT INTO Account (Role_ID, Email, Password, Account_Status, Auth_Provider) VALUES (?, ?, ?, 'Active', 'Local')";
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
                    if (user.getRoleId() == 5) { // Patient
                        insertDetail = "INSERT INTO Patient (Account_ID, Full_Name, Phone) VALUES (?, ?, ?)";
                    } else {
                        insertDetail = "INSERT INTO Employee_Profile (Account_ID, Full_Name, Phone, License_Number) VALUES (?, ?, ?, ?)";
                    }
                    
                    if (!insertDetail.isEmpty()) {
                        try (PreparedStatement ps2 = conn.prepareStatement(insertDetail)) {
                            ps2.setInt(1, accId);
                            ps2.setString(2, user.getFullName());
                            String phone = (user.getPhone() != null && !user.getPhone().trim().isEmpty()) ? user.getPhone() : "000" + accId;
                            ps2.setString(3, phone);
                            if (user.getRoleId() != 5) {
                                if (user.getRoleId() == 2 || user.getRoleId() == 3) {
                                    ps2.setString(4, "DOC-" + accId); // Dummy license
                                } else {
                                    ps2.setNull(4, Types.VARCHAR);
                                }
                            }
                            ps2.executeUpdate();
                        }
                    }
                    return true;
                }
            }
        }
        return false;
    }

    public User getUserById(int accountId) throws Exception {
        String sql = "SELECT a.Account_ID, a.Email, a.Account_Status, r.Role_ID, r.Role_Name, " +
                     "COALESCE(p.Full_Name, e.Full_Name) as Full_Name, " +
                     "COALESCE(p.Phone, e.Phone) as Phone, p.DOB, p.Address " +
                     "FROM Account a " +
                     "JOIN Role r ON a.Role_ID = r.Role_ID " +
                     "LEFT JOIN Patient p ON a.Account_ID = p.Account_ID " +
                     "LEFT JOIN Employee_Profile e ON a.Account_ID = e.Account_ID " +
                     "WHERE a.Account_ID = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapUserFromResultSet(rs);
                }
            }
        }
        return null;
    }
    
    public boolean updateUserRole(int accountId, int newRoleId) throws Exception {
        String sql = "UPDATE Account SET Role_ID = ? WHERE Account_ID = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, newRoleId);
            ps.setInt(2, accountId);
            return ps.executeUpdate() > 0;
        }
    }
}
