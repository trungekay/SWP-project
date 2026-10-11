package com.visioncare.dao;

import com.visioncare.model.ClinicGalleryItem;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ClinicGalleryDAO {

    public ClinicGalleryDAO() {
        ensureTableAndData();
    }

    private void ensureTableAndData() {
        try (Connection conn = DBContext.getConnection();
             Statement st = conn.createStatement()) {
            
            // 1. Tạo bảng nếu chưa có
            String createTableSql = "IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Clinic_Gallery' AND xtype='U') "
                    + "BEGIN "
                    + "CREATE TABLE Clinic_Gallery ( "
                    + "    Item_ID INT PRIMARY KEY, "
                    + "    Title NVARCHAR(200) NULL, "
                    + "    Description NVARCHAR(500) NULL, "
                    + "    Display_Order INT NOT NULL DEFAULT 1, "
                    + "    Default_Filename VARCHAR(100) NULL, "
                    + "    Image_Data VARBINARY(MAX) NULL, "
                    + "    Image_Mime_Type VARCHAR(50) NULL, "
                    + "    Updated_At DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME() "
                    + "); "
                    + "END "
                    + "ELSE "
                    + "BEGIN "
                    + "    IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Clinic_Gallery') AND name = 'Default_Filename' AND is_nullable = 0) "
                    + "    BEGIN "
                    + "        ALTER TABLE Clinic_Gallery ALTER COLUMN Default_Filename VARCHAR(100) NULL; "
                    + "    END "
                    + "END";
            st.execute(createTableSql);

            // 2. Khởi tạo sẵn 8 item mặc định tương ứng gallery-1.jpg đến gallery-8.jpg nếu bảng rỗng
            try (ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM Clinic_Gallery")) {
                if (rs.next() && rs.getInt(1) == 0) {
                    String[] defaultTitles = {
                        "Sảnh tiếp đón và quầy tư vấn dịch vụ",
                        "Phòng khám khúc xạ và kiểm tra thị lực tự động",
                        "Phòng khám nhãn khoa tổng quát và soi đáy mắt",
                        "Phòng phẫu thuật khúc xạ công nghệ cao (LASIK/SMILE)",
                        "Hệ thống máy chụp cắt lớp võng mạc OCT hiện đại",
                        "Khu vực phòng chờ tiện nghi, thân thiện cho bệnh nhân",
                        "Phòng tiểu phẫu vô trùng đạt chuẩn y tế",
                        "Trung tâm kính mắt chuyên sâu và tư vấn tròng kính"
                    };

                    String insertSql = "INSERT INTO Clinic_Gallery (Item_ID, Title, Description, Display_Order, Default_Filename) VALUES (?, ?, ?, ?, ?)";
                    try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                        for (int i = 1; i <= 8; i++) {
                            ps.setInt(1, i);
                            ps.setString(2, defaultTitles[i - 1]);
                            ps.setString(3, "Không gian hiện đại, tiện nghi tại VisionCare.");
                            ps.setInt(4, i);
                            ps.setString(5, "gallery-" + i + ".jpg");
                            ps.executeUpdate();
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("ClinicGalleryDAO ensureTableAndData error: " + e.getMessage());
        }
    }

    public List<ClinicGalleryItem> getAll() {
        List<ClinicGalleryItem> list = new ArrayList<>();
        String sql = "SELECT Item_ID, Title, Description, Display_Order, Default_Filename, "
                + "CASE WHEN Image_Data IS NOT NULL THEN 1 ELSE 0 END AS Has_Custom_Image, "
                + "CONVERT(VARCHAR(19), Updated_At, 120) AS Updated_At_Str "
                + "FROM Clinic_Gallery ORDER BY Display_Order ASC, Item_ID ASC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                ClinicGalleryItem item = new ClinicGalleryItem(
                    rs.getInt("Item_ID"),
                    rs.getString("Title"),
                    rs.getString("Description"),
                    rs.getInt("Display_Order"),
                    rs.getString("Default_Filename"),
                    rs.getInt("Has_Custom_Image") == 1,
                    rs.getString("Updated_At_Str")
                );
                list.add(item);
            }
        } catch (Exception e) {
            e.printStackTrace();
            for (int i = 1; i <= 8; i++) {
                list.add(new ClinicGalleryItem(i, "Ảnh giới thiệu " + i, "", i, "gallery-" + i + ".jpg", false, ""));
            }
        }
        return list;
    }

    public ClinicGalleryItem getById(int id) {
        String sql = "SELECT Item_ID, Title, Description, Display_Order, Default_Filename, "
                + "CASE WHEN Image_Data IS NOT NULL THEN 1 ELSE 0 END AS Has_Custom_Image, "
                + "CONVERT(VARCHAR(19), Updated_At, 120) AS Updated_At_Str "
                + "FROM Clinic_Gallery WHERE Item_ID = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new ClinicGalleryItem(
                        rs.getInt("Item_ID"),
                        rs.getString("Title"),
                        rs.getString("Description"),
                        rs.getInt("Display_Order"),
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

    public boolean insertItem(String title, String description, int displayOrder, byte[] imageData, String mimeType) throws Exception {
        String sql = "INSERT INTO Clinic_Gallery (Item_ID, Title, Description, Display_Order, Default_Filename, Image_Data, Image_Mime_Type, Updated_At) "
                + "VALUES ((SELECT ISNULL(MAX(Item_ID), 0) + 1 FROM Clinic_Gallery), ?, ?, ?, NULL, ?, ?, SYSUTCDATETIME())";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, title);
            ps.setString(2, description);
            ps.setInt(3, displayOrder);
            ps.setBytes(4, imageData);
            ps.setString(5, mimeType);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean updateItem(int id, String title, String description, int displayOrder, byte[] imageData, String mimeType) throws Exception {
        String sql;
        if (imageData != null && imageData.length > 0) {
            sql = "UPDATE Clinic_Gallery SET Title = ?, Description = ?, Display_Order = ?, Image_Data = ?, Image_Mime_Type = ?, Updated_At = SYSUTCDATETIME() WHERE Item_ID = ?";
        } else {
            sql = "UPDATE Clinic_Gallery SET Title = ?, Description = ?, Display_Order = ?, Updated_At = SYSUTCDATETIME() WHERE Item_ID = ?";
        }

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, title);
            ps.setString(2, description);
            ps.setInt(3, displayOrder);
            if (imageData != null && imageData.length > 0) {
                ps.setBytes(4, imageData);
                ps.setString(5, mimeType);
                ps.setInt(6, id);
            } else {
                ps.setInt(4, id);
            }
            return ps.executeUpdate() > 0;
        }
    }

    public boolean deleteItem(int id) throws Exception {
        String sql = "DELETE FROM Clinic_Gallery WHERE Item_ID = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean resetToDefault(int id) throws Exception {
        String sql = "UPDATE Clinic_Gallery SET Image_Data = NULL, Image_Mime_Type = NULL, Updated_At = SYSUTCDATETIME() WHERE Item_ID = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }

    public ImageData getImageData(int id) throws Exception {
        String sql = "SELECT Image_Data, Image_Mime_Type FROM Clinic_Gallery WHERE Item_ID = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next() && rs.getBytes("Image_Data") != null) {
                    return new ImageData(rs.getBytes("Image_Data"), rs.getString("Image_Mime_Type"));
                }
            }
        }
        return null;
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
