package com.visioncare.dao;
import com.visioncare.model.User;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {
    public User login(String email, String password) throws Exception {
        String sql =
    "SELECT a.Account_ID, a.Email, r.Role_Name, " +
    "COALESCE(e.Full_Name, p.Full_Name, a.Email) AS Display_Name, " +
    "COALESCE(e.Employee_ID, p.Patient_ID, 0) AS Actor_ID, " +
    "COALESCE(e.Specialty, N'Khúc xạ & Nhãn khoa') AS Specialty_Info, " +
    "COALESCE(rm.Room_Name, N'P.101 (Tầng 1)') AS Room_Info, " +
    "e.License_Number, CAST(NULL AS NVARCHAR(100)) AS Position, " +
    "p.Phone, p.DOB, p.Address, a.Account_Status, a.Password " +
    "FROM Account a " +
    "JOIN Role r ON a.Role_ID = r.Role_ID " +
    "LEFT JOIN Patient p ON a.Account_ID = p.Account_ID " +
    "LEFT JOIN Employee_Profile e ON a.Account_ID = e.Account_ID " +
    "LEFT JOIN Room rm ON e.Room_ID = rm.Room_ID " +
    "WHERE a.Email = ? AND (a.Password = ? OR a.Password = ?) AND a.Account_Status != 'Deleted'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setString(2, password);
            ps.setString(3, "NEW_" + password);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    User u = new User();
                    u.setId(rs.getInt("Account_ID"));
                    u.setEmail(rs.getString("Email"));
                    String dbPassword = rs.getString("Password");
                    u.setPassword(dbPassword);
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
                    u.setStatus(rs.getString("Account_Status"));
                    u.setFirstLogin(dbPassword != null && dbPassword.startsWith("NEW_"));
                    
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
            "SELECT a.Account_ID, a.Email, a.Account_Status, a.Role_ID, a.Password, r.Role_Name, " +
            "COALESCE(p.Full_Name, e.Full_Name, a.Email) AS Full_Name, " +
            "COALESCE(e.Employee_ID, p.Patient_ID, 0) AS Actor_ID, " +
            "COALESCE(p.Phone, e.Phone) AS Phone, p.DOB, p.Address, " +
            "e.License_Number, e.Specialty, e.Room_ID " +
            "FROM Account a JOIN Role r ON a.Role_ID = r.Role_ID " +
            "LEFT JOIN Patient p ON a.Account_ID = p.Account_ID " +
            "LEFT JOIN Employee_Profile e ON a.Account_ID = e.Account_ID ";

    private User mapAdminUser(ResultSet rs) throws SQLException {
        User user = new User();
        user.setId(rs.getInt("Account_ID"));
        user.setEmail(rs.getString("Email"));
        user.setFullName(rs.getString("Full_Name"));
        user.setActorId(rs.getInt("Actor_ID"));
        user.setPhone(rs.getString("Phone"));
        
        String dbPassword = rs.getString("Password");
        if (dbPassword != null) {
            user.setPassword(dbPassword);
            user.setFirstLogin(dbPassword.startsWith("NEW_"));
        }
        
        user.setRoleId(rs.getInt("Role_ID"));
        String roleName = rs.getString("Role_Name");
        if ("System_Admin".equalsIgnoreCase(roleName)) user.setRole("admin");
        else if ("Doctor".equalsIgnoreCase(roleName)) user.setRole("doctor");
        else if ("Medical_Specialist".equalsIgnoreCase(roleName)) user.setRole("medical_specialist");
        else if ("Staff".equalsIgnoreCase(roleName)) user.setRole("staff");
        else if ("Director".equalsIgnoreCase(roleName)) user.setRole("director");
        else if ("Patient".equalsIgnoreCase(roleName)) user.setRole("patient");
        else user.setRole(roleName != null ? roleName.toLowerCase() : "");
        user.setStatus(rs.getString("Account_Status"));
        Date dob = rs.getDate("DOB");
        user.setDob(dob == null ? null : dob.toString());
        user.setAddress(rs.getString("Address"));
        
        user.setLicenseNumber(rs.getString("License_Number"));
        user.setSpecialty(rs.getString("Specialty"));
        int roomId = rs.getInt("Room_ID");
        if (!rs.wasNull()) {
            user.setRoomName(String.valueOf(roomId));
        }
        
        return user;
    }

    public List<User> getAllUsers() throws Exception {
        List<User> users = new ArrayList<>();
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(ADMIN_USER_SELECT + "WHERE a.Account_Status != 'Deleted' ORDER BY a.Account_ID DESC");
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
            java.sql.Date dob = null;
            String address = "";
            int currentRoleId = 0;
            String getInfo = "SELECT a.Role_ID, COALESCE(p.Full_Name, e.Full_Name) as fn, COALESCE(p.Phone, e.Phone) as ph, " +
                             "COALESCE(p.DOB, e.DOB) as dob, COALESCE(p.Address, e.Address) as addr " +
                             "FROM Account a " +
                             "LEFT JOIN Patient p ON a.Account_ID = p.Account_ID " +
                             "LEFT JOIN Employee_Profile e ON a.Account_ID = e.Account_ID " +
                             "WHERE a.Account_ID = ?";
            try (PreparedStatement ps = conn.prepareStatement(getInfo)) {
                ps.setInt(1, accountId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        currentRoleId = rs.getInt("Role_ID");
                        fullName = rs.getString("fn");
                        phone = rs.getString("ph");
                        dob = rs.getDate("dob");
                        address = rs.getString("addr");
                    }
                }
            }

            conn.setAutoCommit(false);
            try {
                if (currentRoleId != newRoleId && currentRoleId != 0) {
                    String checkSchedule = "SELECT COUNT(*) FROM Work_Schedule ws " +
                                           "JOIN Employee_Profile ep ON ws.Doctor_Employee_ID = ep.Employee_ID OR ws.Specialist_Employee_ID = ep.Employee_ID OR ws.Staff_Employee_ID = ep.Employee_ID " +
                                           "WHERE ep.Account_ID = ? AND ws.Work_Date >= CAST(GETDATE() AS DATE)";
                    try (PreparedStatement psCheck = conn.prepareStatement(checkSchedule)) {
                        psCheck.setInt(1, accountId);
                        try (ResultSet rsCheck = psCheck.executeQuery()) {
                            if (rsCheck.next() && rsCheck.getInt(1) > 0) {
                                String reason = "đang có lịch làm việc sắp tới";
                                if (currentRoleId == 3 || currentRoleId == 4) {
                                    reason = "đang có ca khám bệnh hoặc lịch làm việc sắp tới";
                                }
                                String roleName = (currentRoleId == 3 || currentRoleId == 4) ? "Bác sĩ" : "Nhân sự";
                                throw new Exception("Không thể thay đổi quyền vì " + roleName + " này " + reason + ". Hãy xóa hoặc hoàn tất lịch trước.");
                            }
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
                    "INSERT INTO Patient (Account_ID, Full_Name, Phone, DOB, Address) VALUES (?, ?, ?, ?, ?)")) {
                    ps.setInt(1, accountId);
                    ps.setInt(2, accountId);
                    ps.setString(3, fullName);
                    ps.setString(4, phone);
                    ps.setDate(5, dob);
                    ps.setString(6, address);
                    ps.executeUpdate();
                }
            } else { // Employee
                try (PreparedStatement ps = conn.prepareStatement("DELETE FROM Patient WHERE Account_ID = ?")) {
                    ps.setInt(1, accountId);
                    ps.executeUpdate();
                }
                try (PreparedStatement ps = conn.prepareStatement(
                    "IF NOT EXISTS (SELECT 1 FROM Employee_Profile WHERE Account_ID = ?) " +
                    "INSERT INTO Employee_Profile (Account_ID, Full_Name, Phone, DOB, Address, License_Number) VALUES (?, ?, ?, ?, ?, ?)")) {
                    ps.setInt(1, accountId);
                    ps.setInt(2, accountId);
                    ps.setString(3, fullName);
                    ps.setString(4, phone);
                    ps.setDate(5, dob);
                    ps.setString(6, address);
                    ps.setNull(7, java.sql.Types.VARCHAR);
                    ps.executeUpdate();
                }
            }
            conn.commit();
            } catch (java.sql.SQLException ex) {
                conn.rollback();
                if (ex.getMessage() != null && ex.getMessage().contains("REFERENCE constraint")) {
                    throw new Exception("Không thể chuyển đổi quyền này vì người dùng đã có dữ liệu lịch sử. Bạn chỉ có thể chuyển đổi các tài khoản chưa phát sinh dữ liệu.");
                }
                throw ex;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    public boolean updateAccountStatus(int accountId, String status) throws Exception {
        try (Connection conn = DBContext.getConnection()) {
            if ("Inactive".equals(status)) {
                int roleId = 0;
                try (PreparedStatement psRole = conn.prepareStatement("SELECT Role_ID FROM Account WHERE Account_ID = ?")) {
                    psRole.setInt(1, accountId);
                    try (ResultSet rsRole = psRole.executeQuery()) {
                        if (rsRole.next()) {
                            roleId = rsRole.getInt(1);
                        }
                    }
                }
                
                String checkSchedule = "SELECT COUNT(*) FROM Work_Schedule ws " +
                                       "JOIN Employee_Profile ep ON ws.Doctor_Employee_ID = ep.Employee_ID OR ws.Specialist_Employee_ID = ep.Employee_ID OR ws.Staff_Employee_ID = ep.Employee_ID " +
                                       "WHERE ep.Account_ID = ? AND ws.Work_Date >= CAST(GETDATE() AS DATE)";
                try (PreparedStatement psCheck = conn.prepareStatement(checkSchedule)) {
                    psCheck.setInt(1, accountId);
                    try (ResultSet rsCheck = psCheck.executeQuery()) {
                        if (rsCheck.next() && rsCheck.getInt(1) > 0) {
                            String reason = "đang có lịch làm việc sắp tới";
                            if (roleId == 3 || roleId == 4) {
                                reason = "đang có ca khám bệnh hoặc lịch làm việc sắp tới";
                            }
                            String roleName = (roleId == 3 || roleId == 4) ? "Bác sĩ" : "Nhân sự";
                            throw new Exception("Không thể vô hiệu hóa vì " + roleName + " này " + reason + ". Hãy xóa hoặc hoàn tất lịch trước.");
                        }
                    }
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(
                     "UPDATE Account SET Account_Status = ? WHERE Account_ID = ?")) {
                ps.setString(1, status);
                ps.setInt(2, accountId);
                return ps.executeUpdate() > 0;
            }
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
                            "INSERT INTO Patient (Account_ID, Full_Name, Phone, DOB, Address) VALUES (?, ?, ?, ?, ?)")) {
                        ps.setInt(1, accountId);
                        ps.setString(2, user.getFullName());
                        ps.setString(3, phone == null || phone.trim().isEmpty() ? "000" + accountId : phone);
                        ps.setDate(4, user.getDob() != null && !user.getDob().isEmpty() ? java.sql.Date.valueOf(user.getDob()) : java.sql.Date.valueOf("2000-01-01"));
                        ps.setString(5, user.getAddress() != null && !user.getAddress().trim().isEmpty() ? user.getAddress().trim() : "");
                        ps.executeUpdate();
                    }
                } else {
                    try (PreparedStatement ps = conn.prepareStatement(
                            "INSERT INTO Employee_Profile (Account_ID, Full_Name, Phone, License_Number, Specialty, Room_ID, DOB, Address) VALUES (?, ?, ?, ?, ?, ?, ?, ?)")) {
                        ps.setInt(1, accountId);
                        ps.setString(2, user.getFullName());
                        ps.setString(3, phone);
                        
                        if (user.getLicenseNumber() != null && !user.getLicenseNumber().trim().isEmpty()) {
                            ps.setString(4, user.getLicenseNumber().trim());
                        } else {
                            ps.setNull(4, java.sql.Types.VARCHAR);
                        }

                        if (user.getSpecialty() != null && !user.getSpecialty().trim().isEmpty()) {
                            ps.setString(5, user.getSpecialty().trim());
                        } else {
                            ps.setNull(5, java.sql.Types.NVARCHAR);
                        }

                        if (user.getRoomName() != null && !user.getRoomName().trim().isEmpty()) {
                            try {
                                ps.setInt(6, Integer.parseInt(user.getRoomName().trim()));
                            } catch (NumberFormatException e) {
                                ps.setNull(6, java.sql.Types.INTEGER);
                            }
                        } else {
                            ps.setNull(6, java.sql.Types.INTEGER);
                        }
                        
                        if (user.getDob() != null && !user.getDob().isEmpty()) {
                            ps.setDate(7, java.sql.Date.valueOf(user.getDob()));
                        } else {
                            ps.setNull(7, java.sql.Types.DATE);
                        }

                        if (user.getAddress() != null && !user.getAddress().trim().isEmpty()) {
                            ps.setString(8, user.getAddress().trim());
                        } else {
                            ps.setString(8, "");
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

    public boolean updateUserProfile(int accountId, String fullName, String phone, String dob, String address) throws Exception {
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
            if ("Patient".equals(table)) {
                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE Patient SET Full_Name = ?, Phone = ?, DOB = ?, Address = ? WHERE Account_ID = ?")) {
                    ps.setString(1, fullName);
                    ps.setString(2, phone);
                    if (dob != null && !dob.trim().isEmpty()) {
                        ps.setDate(3, java.sql.Date.valueOf(dob));
                    } else {
                        ps.setNull(3, java.sql.Types.DATE);
                    }
                    ps.setString(4, address != null ? address : "");
                    ps.setInt(5, accountId);
                    return ps.executeUpdate() > 0;
                }
            } else {
                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE Employee_Profile SET Full_Name = ?, Phone = ?, DOB = ?, Address = ? WHERE Account_ID = ?")) {
                    ps.setString(1, fullName);
                    ps.setString(2, phone);
                    if (dob != null && !dob.trim().isEmpty()) {
                        ps.setDate(3, java.sql.Date.valueOf(dob));
                    } else {
                        ps.setNull(3, java.sql.Types.DATE);
                    }
                    ps.setString(4, address != null ? address : "");
                    ps.setInt(5, accountId);
                    return ps.executeUpdate() > 0;
                }
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
                        "UPDATE Employee_Profile SET Full_Name = ?, Phone = ?, DOB = ?, Address = ? WHERE Account_ID = ?")) {
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
        }
    }

    public boolean deleteUser(int accountId) throws Exception {
        if (hasActiveAppointments(accountId)) {
            int roleId = 0;
            try (Connection conn = DBContext.getConnection();
                 PreparedStatement ps = conn.prepareStatement("SELECT Role_ID FROM Account WHERE Account_ID = ?")) {
                ps.setInt(1, accountId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) roleId = rs.getInt(1);
                }
            }
            String reason = "đang có lịch làm việc sắp tới";
            String roleName = "Nhân sự";
            if (roleId == 3 || roleId == 4) {
                roleName = "Bác sĩ";
                reason = "đang có ca khám bệnh hoặc lịch làm việc sắp tới";
            } else if (roleId == 6) {
                roleName = "Bệnh nhân";
                reason = "đang có lịch hẹn khám chưa hoàn thành";
            }
            throw new Exception("Không thể xóa vì " + roleName + " này " + reason + ". Hãy xử lý lịch trình trước.");
        }
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "UPDATE Account SET Account_Status = 'Deleted' WHERE Account_ID = ?")) {
            ps.setInt(1, accountId);
            return ps.executeUpdate() > 0;
        }
    }

    private boolean hasActiveAppointments(int accountId) throws Exception {
        String appointmentSql = 
            "SELECT COUNT(*) FROM Appointment a " +
            "LEFT JOIN Patient p ON a.Patient_ID = p.Patient_ID " +
            "LEFT JOIN Work_Schedule ws ON a.Schedule_ID = ws.Schedule_ID " +
            "LEFT JOIN Employee_Profile e ON ws.Doctor_Employee_ID = e.Employee_ID OR ws.Specialist_Employee_ID = e.Employee_ID OR ws.Staff_Employee_ID = e.Employee_ID " +
            "WHERE (p.Account_ID = ? OR e.Account_ID = ?) " +
            "AND a.Status NOT IN ('Canceled', 'Completed')";
            
        String scheduleSql = 
            "SELECT COUNT(*) FROM Work_Schedule ws " +
            "JOIN Employee_Profile e ON ws.Doctor_Employee_ID = e.Employee_ID OR ws.Specialist_Employee_ID = e.Employee_ID OR ws.Staff_Employee_ID = e.Employee_ID " +
            "WHERE e.Account_ID = ? AND ws.Work_Date >= CAST(GETDATE() AS DATE) " +
            "AND ws.Status = 'Available'";
            
        try (Connection conn = DBContext.getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(appointmentSql)) {
                ps.setInt(1, accountId);
                ps.setInt(2, accountId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) return true;
                }
            }
            try (PreparedStatement ps = conn.prepareStatement(scheduleSql)) {
                ps.setInt(1, accountId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) return true;
                }
            }
        }
        return false;
    }

    public boolean updateDoctorProfile(int accountId, String license, String specialty, String roomIdStr) throws Exception {
        String sql = "UPDATE Employee_Profile SET License_Number = ?, Specialty = ?, Room_ID = ? WHERE Account_ID = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, license);
            ps.setString(2, specialty);
            if (roomIdStr == null || roomIdStr.trim().isEmpty()) {
                ps.setNull(3, java.sql.Types.INTEGER);
            } else {
                ps.setInt(3, Integer.parseInt(roomIdStr.trim()));
            }
            ps.setInt(4, accountId);
            return ps.executeUpdate() > 0;
        }
    }
}
