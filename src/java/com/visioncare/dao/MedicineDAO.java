package com.visioncare.dao;

import com.visioncare.model.Medicine;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class MedicineDAO {
    private static final String COLUMNS = "Medicine_ID, Supply_Name, Category, Price, " +
            "CASE WHEN Image_Data IS NULL THEN 0 ELSE 1 END AS Has_Image";

    public List<Medicine> list() throws Exception {
        List<Medicine> items = new ArrayList<>();
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(
                     "SELECT " + COLUMNS + " FROM Medicine ORDER BY Medicine_ID");
             ResultSet result = statement.executeQuery()) {
            while (result.next()) items.add(read(result));
        }
        return items;
    }

    /** Medicines available for a doctor's prescription, excluding glasses and accessories. */
    public List<Medicine> listPrescribable() throws Exception {
        List<Medicine> items = new ArrayList<>();
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(
                     "SELECT " + COLUMNS + " FROM Medicine " +
                     "WHERE Category = N'Thuốc & dung dịch' ORDER BY Supply_Name, Medicine_ID");
             ResultSet result = statement.executeQuery()) {
            while (result.next()) items.add(read(result));
        }
        return items;
    }

    public Medicine get(int id) throws Exception {
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(
                     "SELECT " + COLUMNS + " FROM Medicine WHERE Medicine_ID = ?")) {
            statement.setInt(1, id);
            try (ResultSet result = statement.executeQuery()) {
                return result.next() ? read(result) : null;
            }
        }
    }

    public int save(int id, String name, String category, BigDecimal price,
                    byte[] imageData, String imageMimeType) throws Exception {
        boolean create = id == 0;
        String sql = create
                ? "INSERT INTO Medicine (Supply_Name, Category, Price, Image_Data, Image_Mime_Type) VALUES (?, ?, ?, ?, ?)"
                : "UPDATE Medicine SET Supply_Name = ?, Category = ?, Price = ?" +
                  (imageData == null ? "" : ", Image_Data = ?, Image_Mime_Type = ?") + " WHERE Medicine_ID = ?";
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            statement.setString(1, name);
            statement.setString(2, category);
            statement.setBigDecimal(3, price);
            int column = 4;
            if (create || imageData != null) {
                statement.setBytes(column++, imageData);
                statement.setString(column++, imageMimeType);
            }
            if (!create) statement.setInt(column, id);
            if (statement.executeUpdate() != 1) {
                throw new IllegalArgumentException("Không tìm thấy vật tư bán lẻ cần cập nhật.");
            }
            if (!create) return id;
            try (ResultSet keys = statement.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
            throw new IllegalStateException("Không đọc được mã vật tư bán lẻ vừa tạo.");
        }
    }

    public boolean delete(int id) throws Exception {
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(
                     "DELETE FROM Medicine WHERE Medicine_ID = ?")) {
            statement.setInt(1, id);
            return statement.executeUpdate() == 1;
        }
    }

    public ImageData getImage(int id) throws Exception {
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(
                     "SELECT Image_Data, Image_Mime_Type FROM Medicine WHERE Medicine_ID = ?")) {
            statement.setInt(1, id);
            try (ResultSet result = statement.executeQuery()) {
                if (!result.next()) return null;
                byte[] bytes = result.getBytes(1);
                return bytes == null ? null : new ImageData(bytes, result.getString(2));
            }
        }
    }

    private Medicine read(ResultSet result) throws Exception {
        return new Medicine(result.getInt("Medicine_ID"), result.getString("Supply_Name"),
                result.getString("Category"), result.getBigDecimal("Price"),
                result.getBoolean("Has_Image"));
    }

    public static final class ImageData {
        private final byte[] bytes;
        private final String mimeType;

        public ImageData(byte[] bytes, String mimeType) {
            this.bytes = bytes;
            this.mimeType = mimeType;
        }

        public byte[] getBytes() { return bytes; }
        public String getMimeType() { return mimeType; }
    }
}
