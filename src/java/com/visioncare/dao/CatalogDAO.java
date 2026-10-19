package com.visioncare.dao;

import com.visioncare.model.CatalogService;
import com.visioncare.model.MedicalSupply;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class CatalogDAO {
    private static final String SERVICE_COLUMNS = "sc.Service_ID, sc.Service_Code, sc.Service_Name, sc.Price, sc.Category, sc.Summary, sc.Description, sc.Image_Path, CASE WHEN sc.Image_Data IS NULL THEN 0 ELSE 1 END AS Has_Image";

    public List<CatalogService> listServices() throws Exception {
        List<CatalogService> items = new ArrayList<>();
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement("SELECT " + SERVICE_COLUMNS + " FROM Service_Catalog sc ORDER BY CASE WHEN sc.Service_Code IS NULL THEN 1 ELSE 0 END, sc.Service_ID");
             ResultSet result = statement.executeQuery()) {
            while (result.next()) items.add(service(result));
        }
        return items;
    }

    public List<CatalogService> listSurgeryServices() throws Exception {
        List<CatalogService> items = new ArrayList<>();
        String sql = "SELECT " + SERVICE_COLUMNS + " FROM Service_Catalog sc "
                + "WHERE sc.Service_Code IN ('LS-03', 'TT-05') OR sc.Service_Code LIKE 'PT-%' "
                + "ORDER BY sc.Service_Code";
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet result = statement.executeQuery()) {
            while (result.next()) items.add(service(result));
        }
        return items;
    }

    public CatalogService getService(int id) throws Exception {
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement("SELECT " + SERVICE_COLUMNS + " FROM Service_Catalog sc WHERE sc.Service_ID = ?")) {
            statement.setInt(1, id);
            try (ResultSet result = statement.executeQuery()) {
                return result.next() ? service(result) : null;
            }
        }
    }

    public boolean deleteService(int id) throws Exception {
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement("DELETE FROM Service_Catalog WHERE Service_ID = ?")) {
            statement.setInt(1, id);
            return statement.executeUpdate() == 1;
        }
    }

    public int saveService(int id, String code, String name, BigDecimal price,
            String category, String summary, String description,
            byte[] imageData, String imageMimeType) throws Exception {
        boolean create = id == 0;
        String sql = create
            ? "INSERT INTO Service_Catalog (Service_Code, Service_Name, Price, Category, Summary, Description, Image_Data, Image_Mime_Type) VALUES (?, ?, ?, ?, ?, ?, ?, ?)"
            : "UPDATE Service_Catalog SET Service_Code = ?, Service_Name = ?, Price = ?, Category = ?, Summary = ?, Description = ?" +
              (imageData == null ? "" : ", Image_Data = ?, Image_Mime_Type = ?") + " WHERE Service_ID = ?";
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            int column = 1;
            statement.setString(column++, blankToNull(code));
            statement.setString(column++, name);
            statement.setBigDecimal(column++, price);
            statement.setString(column++, category);
            statement.setString(column++, blankToNull(summary));
            statement.setString(column++, blankToNull(description));
            if (create || imageData != null) {
                statement.setBytes(column++, imageData);
                statement.setString(column++, imageMimeType);
            }
            if (!create) statement.setInt(column, id);
            if (statement.executeUpdate() != 1) throw new IllegalArgumentException("Không tìm thấy dịch vụ cần cập nhật.");
            if (!create) return id;
            try (ResultSet keys = statement.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
            throw new IllegalStateException("Không đọc được mã dịch vụ vừa tạo.");
        }
    }

    // Each catalog kind has its own table and identifier. The kind comes from the servlet URL.
    private String table(String kind) {
        switch (kind) {
            case "supply": return "Medical_Supply";
            case "consumable": return "Consumables";
            default: throw new IllegalArgumentException("Loại vật tư không hợp lệ.");
        }
    }

    private String key(String kind) {
        switch (kind) {
            case "supply": return "Supply_ID";
            case "consumable": return "Consumable_ID";
            default: throw new IllegalArgumentException("Loại vật tư không hợp lệ.");
        }
    }

    public List<MedicalSupply> listSupplies(String kind) throws Exception {
        List<MedicalSupply> items = new ArrayList<>();
        String id = key(kind);
        String sql = "SELECT " + id + " AS Supply_ID, Supply_Name, Category, Price, " +
                "CASE WHEN Image_Data IS NULL THEN 0 ELSE 1 END AS Has_Image FROM " + table(kind) + " ORDER BY " + id;
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet result = statement.executeQuery()) {
            while (result.next()) items.add(supply(result));
        }
        return items;
    }

    public MedicalSupply getSupply(String kind, int id) throws Exception {
        String sql = "SELECT " + key(kind) + " AS Supply_ID, Supply_Name, Category, Price, " +
                "CASE WHEN Image_Data IS NULL THEN 0 ELSE 1 END AS Has_Image FROM " + table(kind) +
                " WHERE " + key(kind) + " = ?";
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, id);
            try (ResultSet result = statement.executeQuery()) {
                return result.next() ? supply(result) : null;
            }
        }
    }

    public boolean deleteSupply(String kind, int id) throws Exception {
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(
                     "DELETE FROM " + table(kind) + " WHERE " + key(kind) + " = ?")) {
            statement.setInt(1, id);
            return statement.executeUpdate() == 1;
        }
    }

    public int saveSupply(String kind, int id, String name, String category,
            BigDecimal price, byte[] imageData, String imageMimeType) throws Exception {
        boolean create = id == 0;
        String sql = create
            ? "INSERT INTO " + table(kind) + " (Supply_Name, Category, Price, Image_Data, Image_Mime_Type) VALUES (?, ?, ?, ?, ?)"
            : "UPDATE " + table(kind) + " SET Supply_Name = ?, Category = ?, Price = ?" +
              (imageData == null ? "" : ", Image_Data = ?, Image_Mime_Type = ?") + " WHERE " + key(kind) + " = ?";
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
            if (statement.executeUpdate() != 1) throw new IllegalArgumentException("Không tìm thấy vật tư cần cập nhật.");
            if (!create) return id;
            try (ResultSet keys = statement.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
            throw new IllegalStateException("Không đọc được mã vật tư vừa tạo.");
        }
    }

    private CatalogService service(ResultSet result) throws Exception {
        return new CatalogService(
                result.getInt("Service_ID"), result.getString("Service_Code"),
                result.getString("Service_Name"), result.getBigDecimal("Price"),
                result.getString("Category"),
                result.getString("Summary"), result.getString("Description"),
                result.getString("Image_Path"),
                result.getBoolean("Has_Image"));
    }

    private MedicalSupply supply(ResultSet result) throws Exception {
        return new MedicalSupply(
                result.getInt("Supply_ID"), result.getString("Supply_Name"),
                result.getString("Category"),
                result.getBigDecimal("Price"), result.getBoolean("Has_Image"));
    }

    public ImageData getImage(String kind, int id) throws Exception {
        String table = "service".equals(kind) ? "Service_Catalog" :
                "supply".equals(kind) || "consumable".equals(kind) ? table(kind) : null;
        if (table == null) return null;
        String key = "service".equals(kind) ? "Service_ID" : key(kind);
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(
                     "SELECT Image_Data, Image_Mime_Type FROM " + table + " WHERE " + key + " = ?")) {
            statement.setInt(1, id);
            try (ResultSet result = statement.executeQuery()) {
                if (!result.next() || result.getBytes(1) == null) return null;
                return new ImageData(result.getBytes(1), result.getString(2));
            }
        }
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

    private String blankToNull(String value) {
        return value == null || value.trim().isEmpty() ? null : value;
    }
}
