package com.visioncare.dao;
import com.visioncare.model.User;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {
    public User login(String email, String password) throws Exception {
        String sql =
    "SELECT a.Account_ID, a.Email, a.Account_Status, r.Role_Name, " +
    "COALESCE(e.Full_Name, p.Full_Name, a.Email) AS Display_Name, " +
    "COALESCE(e.Employee_ID, p.Patient_ID, 0) AS Actor_ID, " +
    "COALESCE(e.Specialty, N'Khúc xạ & Nhãn khoa') AS Specialty_Info, " +
    "COALESCE(rm.Room_Name, N'P.101 (Tầng 1)') AS Room_Info, " +
    "e.License_Number, CAST(NULL AS NVARCHAR(100)) AS Position, " +
    "p.Phone, p.DOB, p.Address " +
    "FROM Account a " +
    "JOIN Role r ON a.Role_ID = r.Role_ID " +
    "LEFT JOIN Patient p ON a.Account_ID = p.Account_ID " +
    "LEFT JOIN Employee_Profile e ON a.Account_ID = e.Account_ID " +
    "LEFT JOIN Room rm ON e.Room_ID = rm.Room_ID " +
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
                    u.setPassword(password);
                    u.setStatus(rs.getString("Account_Status"));
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

    public boolean register(User user) throws Exception {
        String insertAccount = "INSERT INTO Account (Role_ID, Email, Password) VALUES ((SELECT TOP 1 Role_ID FROM Role WHERE Role_Name = 'Patient'), ?, ?)";
        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement ps = conn.prepareStatement(insertAccount, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, user.getEmail());
                ps.setString(2, user.getPassword());
                ps.executeUpdate();
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        int accId = rs.getInt(1);
                        
                        String checkPatient = "SELECT Patient_ID, Account_ID FROM Patient WHERE Phone = ?";
                        boolean patientExists = false;
                        boolean hasAccount = false;
                        try (PreparedStatement psCheck = conn.prepareStatement(checkPatient)) {
                            psCheck.setString(1, user.getPhone());
                            try (ResultSet rsCheck = psCheck.executeQuery()) {
                                if (rsCheck.next()) {
                                    patientExists = true;
                                    if (rsCheck.getObject("Account_ID") != null) {
                                        hasAccount = true;
                                    }
                                }
                            }
                        }
                        
                        if (patientExists) {
                            if (hasAccount) {
                                conn.rollback();
                                throw new Exception("Số điện thoại đã liên kết với tài khoản khác.");
                            } else {
                                String updatePatient = "UPDATE Patient SET Account_ID = ?, Full_Name = ? WHERE Phone = ?";
                                try (PreparedStatement psUpdate = conn.prepareStatement(updatePatient)) {
                                    psUpdate.setInt(1, accId);
                                    psUpdate.setString(2, user.getFullName());
                                    psUpdate.setString(3, user.getPhone());
                                    psUpdate.executeUpdate();
                                }
                            }
                        } else {
                            String insertPatient = "INSERT INTO Patient (Account_ID, Phone, Full_Name) VALUES (?, ?, ?)";
                            try (PreparedStatement psInsert = conn.prepareStatement(insertPatient)) {
                                psInsert.setInt(1, accId);
                                psInsert.setString(2, user.getPhone());
                                psInsert.setString(3, user.getFullName());
                                psInsert.executeUpdate();
                            }
                        }
                        conn.commit();
                        return true;
                    }
                }
            } catch (Exception e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
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

    public User getByPhone(String phone) throws Exception {
        String sql = "SELECT p.*, a.Email FROM Patient p JOIN Account a ON p.Account_ID = a.Account_ID WHERE p.Phone = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, phone);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    User u = new User();
                    u.setId(rs.getInt("Account_ID"));
                    u.setPhone(rs.getString("Phone"));
                    u.setEmail(rs.getString("Email"));
                    return u;
                }
            }
        }
        
        String sqlEmp = "SELECT e.*, a.Email FROM Employee_Profile e JOIN Account a ON e.Account_ID = a.Account_ID WHERE e.Phone = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sqlEmp)) {
            ps.setString(1, phone);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    User u = new User();
                    u.setId(rs.getInt("Account_ID"));
                    u.setPhone(rs.getString("Phone"));
                    u.setEmail(rs.getString("Email"));
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

    private static final String ADMIN_USER_SELECT =
            "SELECT a.Account_ID, a.Email, a.Account_Status, a.Role_ID, r.Role_Name, " +
            "COALESCE(p.Full_Name, e.Full_Name, a.Email) AS Full_Name, " +
            "COALESCE(p.Phone, e.Phone) AS Phone, p.DOB, p.Address " +
            "FROM Account a JOIN Role r ON a.Role_ID = r.Role_ID " +
            "LEFT JOIN Patient p ON a.Account_ID = p.Account_ID " +
            "LEFT JOIN Employee_Profile e ON a.Account_ID = e.Account_ID ";

    private User mapAdminUser(ResultSet rs) throws SQLException {
        User user = new User();
        user.setId(rs.getInt("Account_ID"));
        user.setEmail(rs.getString("Email"));
        user.setFullName(rs.getString("Full_Name"));
        user.setPhone(rs.getString("Phone"));
        user.setRoleId(rs.getInt("Role_ID"));
        user.setRole(rs.getString("Role_Name"));
        user.setStatus(rs.getString("Account_Status"));
        Date dob = rs.getDate("DOB");
        user.setDob(dob == null ? null : dob.toString());
        user.setAddress(rs.getString("Address"));
        return user;
    }

    public List<User> getAllUsers() throws Exception {
        List<User> users = new ArrayList<>();
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(ADMIN_USER_SELECT + "ORDER BY a.Account_ID DESC");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) users.add(mapAdminUser(rs));
        }
        return users;
    }

    public User getUserById(int accountId) throws Exception {
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(ADMIN_USER_SELECT + "WHERE a.Account_ID = ?")) {
            ps.setInt(1, accountId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapAdminUser(rs) : null;
            }
        }
    }

    public void updateUserRole(int accountId, int newRoleId) throws Exception {
        try (Connection conn = DBContext.getConnection()) {
            String fullName = "";
            String phone = "";
            String getInfo = "SELECT COALESCE(p.Full_Name, e.Full_Name) as fn, COALESCE(p.Phone, e.Phone) as ph " +
                             "FROM Account a " +
                             "LEFT JOIN Patient p ON a.Account_ID = p.Account_ID " +
                             "LEFT JOIN Employee_Profile e ON a.Account_ID = e.Account_ID " +
                             "WHERE a.Account_ID = ?";
            try (PreparedStatement ps = conn.prepareStatement(getInfo)) {
                ps.setInt(1, accountId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        fullName = rs.getString("fn");
                        phone = rs.getString("ph");
                    }
                }
            }

            String sql = "UPDATE Account SET Role_ID = ? WHERE Account_ID = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, newRoleId);
                ps.setInt(2, accountId);
                ps.executeUpdate();
            }
            
            if (newRoleId == 6) { // Patient
                try (PreparedStatement ps = conn.prepareStatement("DELETE FROM Employee_Profile WHERE Account_ID = ?")) {
                    ps.setInt(1, accountId);
                    ps.executeUpdate();
                }
                try (PreparedStatement ps = conn.prepareStatement(
                    "IF NOT EXISTS (SELECT 1 FROM Patient WHERE Account_ID = ?) " +
                    "INSERT INTO Patient (Account_ID, Full_Name, Phone) VALUES (?, ?, ?)")) {
                    ps.setInt(1, accountId);
                    ps.setInt(2, accountId);
                    ps.setString(3, fullName);
                    ps.setString(4, phone);
                    ps.executeUpdate();
                }
            } else { // Employee
                try (PreparedStatement ps = conn.prepareStatement("DELETE FROM Patient WHERE Account_ID = ?")) {
                    ps.setInt(1, accountId);
                    ps.executeUpdate();
                }
                try (PreparedStatement ps = conn.prepareStatement(
                    "IF NOT EXISTS (SELECT 1 FROM Employee_Profile WHERE Account_ID = ?) " +
                    "INSERT INTO Employee_Profile (Account_ID, Full_Name, Phone, License_Number) VALUES (?, ?, ?, ?)")) {
                    ps.setInt(1, accountId);
                    ps.setInt(2, accountId);
                    ps.setString(3, fullName);
                    ps.setString(4, phone);
                    if (newRoleId == 3) {
                        ps.setString(5, "DOC-" + accountId);
                    } else {
                        ps.setNull(5, java.sql.Types.VARCHAR);
                    }
                    ps.executeUpdate();
                }
            }
        }
    }

    public boolean updateAccountStatus(int accountId, String status) throws Exception {
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "UPDATE Account SET Account_Status = ? WHERE Account_ID = ?")) {
            ps.setString(1, status);
            ps.setInt(2, accountId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean addSystemUser(User user) throws Exception {
        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try {
                int accountId;
                try (PreparedStatement ps = conn.prepareStatement(
                        "INSERT INTO Account (Role_ID, Email, Password) VALUES (?, ?, ?)",
                        Statement.RETURN_GENERATED_KEYS)) {
                    ps.setInt(1, user.getRoleId());
                    ps.setString(2, user.getEmail());
                    ps.setString(3, user.getPassword());
                    ps.executeUpdate();
                    try (ResultSet keys = ps.getGeneratedKeys()) {
                        if (!keys.next()) throw new SQLException("Không lấy được Account_ID mới");
                        accountId = keys.getInt(1);
                    }
                }
                String phone = user.getPhone();
                if (user.getRoleId() == 6) {
                    try (PreparedStatement ps = conn.prepareStatement(
                            "INSERT INTO Patient (Account_ID, Full_Name, Phone) VALUES (?, ?, ?)")) {
                        ps.setInt(1, accountId);
                        ps.setString(2, user.getFullName());
                        ps.setString(3, phone == null || phone.trim().isEmpty() ? "000" + accountId : phone);
                        ps.executeUpdate();
                    }
                } else {
                    try (PreparedStatement ps = conn.prepareStatement(
                            "INSERT INTO Employee_Profile (Account_ID, Full_Name, Phone, License_Number) VALUES (?, ?, ?, ?)")) {
                        ps.setInt(1, accountId);
                        ps.setString(2, user.getFullName());
                        ps.setString(3, phone);
                        if (user.getRoleId() == 3) {
                            ps.setString(4, "DOC-" + accountId); 
                        } else {
                            ps.setNull(4, java.sql.Types.VARCHAR);
                        }
                        ps.executeUpdate();
                    }
                }
                conn.commit();
                return true;
            } catch (Exception e) {
                conn.rollback();
                throw e;
            }
        }
    }

    public boolean updateUserProfile(int accountId, String fullName, String phone) throws Exception {
        try (Connection conn = DBContext.getConnection()) {
            String table;
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT CASE WHEN EXISTS (SELECT 1 FROM Patient WHERE Account_ID = ?) " +
                    "THEN 'Patient' ELSE 'Employee_Profile' END")) {
                ps.setInt(1, accountId);
                try (ResultSet rs = ps.executeQuery()) {
                    rs.next();
                    table = rs.getString(1);
                }
            }
            try (PreparedStatement ps = conn.prepareStatement(
                    "UPDATE " + table + " SET Full_Name = ?, Phone = ? WHERE Account_ID = ?")) {
                ps.setString(1, fullName);
                ps.setString(2, phone);
                ps.setInt(3, accountId);
                return ps.executeUpdate() > 0;
            }
        }
    }

    public boolean updatePassword(int accountId, String newPassword) throws Exception {
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement("UPDATE Account SET Password = ? WHERE Account_ID = ?")) {
            ps.setString(1, newPassword);
            ps.setInt(2, accountId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean updateProfile(User user) throws Exception {
        try (Connection conn = DBContext.getConnection()) {
            String table;
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT CASE WHEN EXISTS (SELECT 1 FROM Patient WHERE Account_ID = ?) " +
                    "THEN 'Patient' ELSE 'Employee_Profile' END")) {
                ps.setInt(1, user.getId());
                try (ResultSet rs = ps.executeQuery()) {
                    rs.next();
                    table = rs.getString(1);
                }
            }
            if ("Patient".equals(table)) {
                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE Patient SET Full_Name = ?, Phone = ?, DOB = ?, Address = ? WHERE Account_ID = ?")) {
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
            } else {
                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE Employee_Profile SET Full_Name = ?, Phone = ? WHERE Account_ID = ?")) {
                    ps.setString(1, user.getFullName());
                    ps.setString(2, user.getPhone());
                    ps.setInt(3, user.getId());
                    return ps.executeUpdate() > 0;
                }
            }
        }
    }

    public boolean deleteUser(int accountId) throws Exception {
        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try {
                for (String table : new String[] {"Patient", "Employee_Profile"}) {
                    try (PreparedStatement ps = conn.prepareStatement(
                            "DELETE FROM " + table + " WHERE Account_ID = ?")) {
                        ps.setInt(1, accountId);
                        ps.executeUpdate();
                    }
                }
                int deleted;
                try (PreparedStatement ps = conn.prepareStatement(
                        "DELETE FROM Account WHERE Account_ID = ?")) {
                    ps.setInt(1, accountId);
                    deleted = ps.executeUpdate();
                }
                conn.commit();
                return deleted > 0;
            } catch (SQLException e) {
                conn.rollback();
                return false;
            }

        }
    }

}
