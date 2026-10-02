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
    private static final String SERVICE_COLUMNS = "Service_ID, Service_Code, Service_Name, Price, Specialty_Name, Tag, Summary, Description, Image_Path, CASE WHEN Image_Data IS NULL THEN 0 ELSE 1 END AS Has_Image";
    private static final String SUPPLY_COLUMNS = "Supply_ID, Supply_Name, Category, Batch_Code, Unit, Quantity, Price, CASE WHEN Image_Data IS NULL THEN 0 ELSE 1 END AS Has_Image";

    public List<String> listSpecialties() throws Exception {
        List<String> names = new ArrayList<>();
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(
                     "SELECT DISTINCT Specialty_Name FROM Service_Catalog WHERE Specialty_Name IS NOT NULL AND LTRIM(RTRIM(Specialty_Name)) <> '' ORDER BY Specialty_Name");
             ResultSet result = statement.executeQuery()) {
            while (result.next()) names.add(result.getString(1));
        }
        return names;
    }

    public List<CatalogService> listServices() throws Exception {
        List<CatalogService> items = new ArrayList<>();
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement("SELECT " + SERVICE_COLUMNS + " FROM Service_Catalog ORDER BY CASE WHEN Service_Code IS NULL THEN 1 ELSE 0 END, Service_ID");
             ResultSet result = statement.executeQuery()) {
            while (result.next()) items.add(service(result));
        }
        return items;
    }

    public CatalogService getService(int id) throws Exception {
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement("SELECT " + SERVICE_COLUMNS + " FROM Service_Catalog WHERE Service_ID = ?")) {
            statement.setInt(1, id);
            try (ResultSet result = statement.executeQuery()) {
                return result.next() ? service(result) : null;
            }
        }
    }

    public int saveService(int id, int accountId, String code, String name, BigDecimal price,
            String specialty, String tag, String summary, String description,
            byte[] imageData, String imageMimeType) throws Exception {
        boolean create = id == 0;
        String sql = create
            ? "INSERT INTO Service_Catalog (Created_By, Service_Code, Service_Name, Price, Specialty_Name, Tag, Summary, Description, Image_Data, Image_Mime_Type) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
            : "UPDATE Service_Catalog SET Service_Code = ?, Service_Name = ?, Price = ?, Specialty_Name = ?, Tag = ?, Summary = ?, Description = ?" +
              (imageData == null ? "" : ", Image_Data = ?, Image_Mime_Type = ?") + " WHERE Service_ID = ?";
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            int column = 1;
            if (create) statement.setInt(column++, accountId);
            statement.setString(column++, blankToNull(code));
            statement.setString(column++, name);
            statement.setBigDecimal(column++, price);
            statement.setString(column++, blankToNull(specialty));
            statement.setString(column++, blankToNull(tag));
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

    public List<MedicalSupply> listSupplies() throws Exception {
        List<MedicalSupply> items = new ArrayList<>();
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement("SELECT " + SUPPLY_COLUMNS + " FROM Medical_Supply ORDER BY Supply_ID");
             ResultSet result = statement.executeQuery()) {
            while (result.next()) items.add(supply(result));
        }
        return items;
    }

    public MedicalSupply getSupply(int id) throws Exception {
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement("SELECT " + SUPPLY_COLUMNS + " FROM Medical_Supply WHERE Supply_ID = ?")) {
            statement.setInt(1, id);
            try (ResultSet result = statement.executeQuery()) {
                return result.next() ? supply(result) : null;
            }
        }
    }

    public int saveSupply(int id, String name, String category, String batch,
            String unit, int quantity, BigDecimal price, byte[] imageData,
            String imageMimeType) throws Exception {
        boolean create = id == 0;
        String sql = create
            ? "INSERT INTO Medical_Supply (Supply_Name, Category, Batch_Code, Unit, Quantity, Price, Image_Data, Image_Mime_Type) VALUES (?, ?, ?, ?, ?, ?, ?, ?)"
            : "UPDATE Medical_Supply SET Supply_Name = ?, Category = ?, Batch_Code = ?, Unit = ?, Quantity = ?, Price = ?" +
              (imageData == null ? "" : ", Image_Data = ?, Image_Mime_Type = ?") + " WHERE Supply_ID = ?";
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            statement.setString(1, name);
            statement.setString(2, category);
            statement.setString(3, blankToNull(batch));
            statement.setString(4, unit);
            statement.setInt(5, quantity);
            statement.setBigDecimal(6, price);
            int column = 7;
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
                result.getString("Specialty_Name"), result.getString("Tag"),
                result.getString("Summary"), result.getString("Description"),
                result.getString("Image_Path"), result.getBoolean("Has_Image"));
    }

    private MedicalSupply supply(ResultSet result) throws Exception {
        return new MedicalSupply(
                result.getInt("Supply_ID"), result.getString("Supply_Name"),
                result.getString("Category"), result.getString("Batch_Code"),
                result.getString("Unit"), result.getInt("Quantity"),
                result.getBigDecimal("Price"), result.getBoolean("Has_Image"));
    }

    public ImageData getImage(String kind, int id) throws Exception {
        String table = "service".equals(kind) ? "Service_Catalog" :
                "supply".equals(kind) ? "Medical_Supply" : null;
        if (table == null) return null;
        String key = "service".equals(kind) ? "Service_ID" : "Supply_ID";
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
        return value == null || value.isBlank() ? null : value;
    }
}
