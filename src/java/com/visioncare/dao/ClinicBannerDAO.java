package com.visioncare.dao;

import com.visioncare.model.ClinicBanner;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class ClinicBannerDAO {

    public ClinicBannerDAO() {
        ensureTable();
    }

    private void ensureTable() {
        try (Connection conn = DBContext.getConnection();
             Statement st = conn.createStatement()) {
            String sql = "IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Clinic_Banner' AND xtype='U') "
                    + "BEGIN "
                    + "CREATE TABLE Clinic_Banner ( "
                    + "    Banner_Key VARCHAR(50) PRIMARY KEY, "
                    + "    Title NVARCHAR(200) NOT NULL, "
                    + "    Default_Filename VARCHAR(100) NOT NULL, "
                    + "    Image_Data VARBINARY(MAX) NULL, "
                    + "    Image_Mime_Type VARCHAR(50) NULL, "
                    + "    Updated_At DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME() "
                    + "); "
                    + "INSERT INTO Clinic_Banner (Banner_Key, Title, Default_Filename) VALUES "
                    + "('HERO_BANNER', N'Banner chính đầu trang (Hero Banner)', 'hero-bg.jpg'), "
                    + "('ABOUT_IMAGE', N'Hình ảnh giới thiệu Về chúng tôi (About Us)', 'about.jpg'); "
                    + "END";
            st.execute(sql);
        } catch (Exception e) {
            System.err.println("ClinicBannerDAO ensureTable error: " + e.getMessage());
        }
    }

    public List<ClinicBanner> getAll() {
        List<ClinicBanner> list = new ArrayList<>();
        String sql = "SELECT Banner_Key, Title, Default_Filename, "
                + "CASE WHEN Image_Data IS NOT NULL THEN 1 ELSE 0 END AS Has_Custom_Image, "
                + "CONVERT(VARCHAR(19), Updated_At, 120) AS Updated_At_Str "
                + "FROM Clinic_Banner ORDER BY Banner_Key ASC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new ClinicBanner(
                    rs.getString("Banner_Key"),
                    rs.getString("Title"),
                    rs.getString("Default_Filename"),
                    rs.getInt("Has_Custom_Image") == 1,
                    rs.getString("Updated_At_Str")
                ));
            }
        } catch (Exception e) {
            e.printStackTrace();
            list.add(new ClinicBanner("HERO_BANNER", "Banner chính đầu trang (Hero Banner)", "hero-bg.jpg", false, ""));
            list.add(new ClinicBanner("ABOUT_IMAGE", "Hình ảnh giới thiệu Về chúng tôi (About Us)", "about.jpg", false, ""));
        }
        return list;
    }

    public ClinicBanner getByKey(String key) {
        String sql = "SELECT Banner_Key, Title, Default_Filename, "
                + "CASE WHEN Image_Data IS NOT NULL THEN 1 ELSE 0 END AS Has_Custom_Image, "
                + "CONVERT(VARCHAR(19), Updated_At, 120) AS Updated_At_Str "
                + "FROM Clinic_Banner WHERE Banner_Key = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, key);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new ClinicBanner(
                        rs.getString("Banner_Key"),
                        rs.getString("Title"),
                        rs.getString("Default_Filename"),
                        rs.getInt("Has_Custom_Image") == 1,
                        rs.getString("Updated_At_Str")
                    );
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public ImageData getImageData(String key) {
        String sql = "SELECT Image_Data, Image_Mime_Type FROM Clinic_Banner WHERE Banner_Key = ? AND Image_Data IS NOT NULL";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, key);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new ImageData(rs.getBytes("Image_Data"), rs.getString("Image_Mime_Type"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean updateBanner(String key, byte[] imageData, String mimeType) throws Exception {
        String sql = "UPDATE Clinic_Banner SET Image_Data = ?, Image_Mime_Type = ?, Updated_At = SYSUTCDATETIME() WHERE Banner_Key = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBytes(1, imageData);
            ps.setString(2, mimeType);
            ps.setString(3, key);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean resetBanner(String key) throws Exception {
        String sql = "UPDATE Clinic_Banner SET Image_Data = NULL, Image_Mime_Type = NULL, Updated_At = SYSUTCDATETIME() WHERE Banner_Key = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, key);
            return ps.executeUpdate() > 0;
        }
    }

    public static final class ImageData {
        private final byte[] bytes;
        private final String mimeType;

        public ImageData(byte[] bytes, String mimeType) {
            this.bytes = bytes;
            this.mimeType = mimeType;
        }

        public byte[] getBytes() {
            return bytes;
        }

        public String getMimeType() {
            return mimeType;
        }
    }
}
