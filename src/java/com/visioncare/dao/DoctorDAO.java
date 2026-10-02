package com.visioncare.dao;

import com.visioncare.model.Doctor;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class DoctorDAO {

    public List<Doctor> getAll() throws Exception {
        List<Doctor> list = new ArrayList<>();
        String sql = "SELECT * FROM Doctor ORDER BY Doctor_ID";
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
        String sql = "SELECT * FROM Doctor WHERE Doctor_ID = ?";
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

    private Doctor mapRow(ResultSet rs) throws SQLException {
        Doctor d = new Doctor();
        d.setId(rs.getInt("Doctor_ID"));
        String fullName = rs.getString("Full_Name");
        d.setId(rs.getInt("Doctor_ID"));
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
        d.setSpecialty(hasColumn(rs, "Specialty") && rs.getString("Specialty") != null ? rs.getString("Specialty") : "Khám mắt tổng quát");
        d.setDepartmentKey("general");
        d.setDescription("Bác sĩ chuyên khoa tại phòng khám VisionCare.");
        
        if (hasColumn(rs, "Biography")) {
            d.setBiography(rs.getString("Biography"));
        }
        if (hasColumn(rs, "Achievements")) {
            d.setAchievements(rs.getString("Achievements"));
        }

        int imgId = (rs.getInt("Doctor_ID") % 4) + 1;
        d.setImage("doctors/doctors-" + imgId + ".jpg");
        d.setRating(5.0);
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
