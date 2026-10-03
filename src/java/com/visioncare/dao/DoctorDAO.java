package com.visioncare.dao;
import com.visioncare.model.Doctor;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
public class DoctorDAO {
    public List<Doctor> getAll() throws Exception {
        List<Doctor> list = new ArrayList<>();
        String sql = "SELECT e.* FROM Employee_Profile e JOIN Account a ON e.Account_ID = a.Account_ID WHERE a.Role_ID = 3 ORDER BY e.Employee_ID";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        }
        return list;
    }
    public Doctor getById(int id) throws Exception {
        String sql = "SELECT e.* FROM Employee_Profile e JOIN Account a ON e.Account_ID = a.Account_ID WHERE a.Role_ID = 3 AND e.Employee_ID = ?";
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
    public List<Doctor> getByDepartment(String departmentKey) throws Exception {
        return getAll();
    }
    public boolean assignDoctorToRoom(int doctorId, int roomId) throws Exception {
        String sql = "UPDATE Employee_Profile SET Room_ID = ? WHERE Employee_ID = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (roomId <= 0) {
                ps.setNull(1, Types.INTEGER); 
            } else {
                ps.setInt(1, roomId);
            }
            ps.setInt(2, doctorId);
            return ps.executeUpdate() > 0;
        }
    }
    public boolean unassignDoctorFromRoom(int roomId) throws Exception {
        String sql = "UPDATE Employee_Profile SET Room_ID = NULL WHERE Room_ID = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, roomId);
            return ps.executeUpdate() > 0;
        }
    }
    private Doctor mapRow(ResultSet rs) throws SQLException {
        Doctor d = new Doctor();
        d.setId(rs.getInt("Employee_ID"));
        String fullName = rs.getString("Full_Name");
        d.setName(fullName);
        String title = "Bác sĩ";
        if (fullName.startsWith("TS.BS."))
            title = "Tiến sĩ";
        else if (fullName.startsWith("ThS.BS."))
            title = "Thạc sĩ";
        else if (fullName.startsWith("BSCKII."))
            title = "Bác sĩ CKII";
        else if (fullName.startsWith("BSCKI."))
            title = "Bác sĩ CKI";
        d.setTitle(title);
        
        String specialty = hasColumn(rs, "Specialty") && rs.getString("Specialty") != null ? rs.getString("Specialty") : "Khám mắt tổng quát";
        d.setSpecialty(specialty);
        d.setDepartmentKey("general");
        d.setDescription("Bác sĩ chuyên khoa tại phòng khám VisionCare.");
        
        if (hasColumn(rs, "Biography") && rs.getString("Biography") != null) {
            d.setBiography(rs.getString("Biography"));
        } else {
            // Mock data phong phú nếu DB chưa có cột Biography
            d.setBiography("Bác sĩ " + fullName + " là một trong những chuyên gia hàng đầu trong lĩnh vực " + specialty + ". Với hơn 10 năm kinh nghiệm làm việc tại các bệnh viện lớn trong và ngoài nước, bác sĩ luôn tận tâm và mang đến giải pháp điều trị tối ưu nhất cho từng bệnh nhân.");
        }
        
        if (hasColumn(rs, "Achievements") && rs.getString("Achievements") != null) {
            d.setAchievements(rs.getString("Achievements"));
        } else {
            // Mock data phong phú nếu DB chưa có cột Achievements
            d.setAchievements("<ul class='mb-0'>" +
                              "<li>Tốt nghiệp loại Giỏi Đại học Y Dược TP.HCM</li>" +
                              "<li>Tu nghiệp chuyên sâu về " + specialty + " tại Singapore (2018)</li>" +
                              "<li>Thành viên Hội Nhãn khoa Việt Nam</li>" +
                              "<li>Đã thực hiện thành công hơn 5,000 ca phẫu thuật/điều trị phức tạp</li>" +
                              "</ul>");
        }
        
        int imgId = (rs.getInt("Employee_ID") % 4) + 1;
        d.setImage("doctors/doctors-" + imgId + ".jpg");
        d.setRating(5.0);
        if (hasColumn(rs, "Room_ID")) {
            d.setRoomId(rs.getInt("Room_ID"));
        }
        return d;
    }
    private boolean hasColumn(ResultSet rs, String columnName) throws SQLException {
        ResultSetMetaData rsmd = rs.getMetaData();
        int columns = rsmd.getColumnCount();
        for (int x = 1; x <= columns; x++) {
            if (columnName.equalsIgnoreCase(rsmd.getColumnName(x))) {
                return true;
            }
        }
        return false;
    }
}
