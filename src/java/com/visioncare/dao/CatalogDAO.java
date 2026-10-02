package com.visioncare.dao;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class CatalogDAO {
    private static final String SERVICE_COLUMNS = "Service_ID, Service_Code, Service_Name, Price, Specialty_Code, Tag, Summary, Description, Image_Path";
    private static final String SUPPLY_COLUMNS = "Supply_ID, Supply_Name, Category, Batch_Code, Unit, Quantity, Price";

    public List<Map<String, Object>> listServices() throws Exception {
        List<Map<String, Object>> items = new ArrayList<>();
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement("SELECT " + SERVICE_COLUMNS + " FROM Service_Catalog ORDER BY CASE WHEN Service_Code IS NULL THEN 1 ELSE 0 END, Service_ID");
             ResultSet result = statement.executeQuery()) {
            while (result.next()) items.add(service(result));
        }
        return items;
    }

    public Map<String, Object> getService(int id) throws Exception {
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement("SELECT " + SERVICE_COLUMNS + " FROM Service_Catalog WHERE Service_ID = ?")) {
            statement.setInt(1, id);
            try (ResultSet result = statement.executeQuery()) {
                return result.next() ? service(result) : null;
            }
        }
    }

    public int saveService(int id, int accountId, String code, String name, BigDecimal price,
            String specialty, String tag, String summary, String description, String image) throws Exception {
        boolean create = id == 0;
        String sql = create
            ? "INSERT INTO Service_Catalog (Created_By, Service_Code, Service_Name, Price, Specialty_Code, Tag, Summary, Description, Image_Path) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)"
            : "UPDATE Service_Catalog SET Service_Code = ?, Service_Name = ?, Price = ?, Specialty_Code = ?, Tag = ?, Summary = ?, Description = ?, Image_Path = ? WHERE Service_ID = ?";
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
            statement.setString(column++, blankToNull(image));
            if (!create) statement.setInt(column, id);
            if (statement.executeUpdate() != 1) throw new IllegalArgumentException("Không tìm thấy dịch vụ cần cập nhật.");
            if (!create) return id;
            try (ResultSet keys = statement.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
            throw new IllegalStateException("Không đọc được mã dịch vụ vừa tạo.");
        }
    }

    public List<Map<String, Object>> listSupplies() throws Exception {
        List<Map<String, Object>> items = new ArrayList<>();
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement("SELECT " + SUPPLY_COLUMNS + " FROM Medical_Supply ORDER BY Supply_ID");
             ResultSet result = statement.executeQuery()) {
            while (result.next()) items.add(supply(result));
        }
        return items;
    }

    public Map<String, Object> getSupply(int id) throws Exception {
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement("SELECT " + SUPPLY_COLUMNS + " FROM Medical_Supply WHERE Supply_ID = ?")) {
            statement.setInt(1, id);
            try (ResultSet result = statement.executeQuery()) {
                return result.next() ? supply(result) : null;
            }
        }
    }

    public int saveSupply(int id, String name, String category, String batch,
            String unit, int quantity, BigDecimal price) throws Exception {
        boolean create = id == 0;
        String sql = create
            ? "INSERT INTO Medical_Supply (Supply_Name, Category, Batch_Code, Unit, Quantity, Price) VALUES (?, ?, ?, ?, ?, ?)"
            : "UPDATE Medical_Supply SET Supply_Name = ?, Category = ?, Batch_Code = ?, Unit = ?, Quantity = ?, Price = ? WHERE Supply_ID = ?";
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            statement.setString(1, name);
            statement.setString(2, category);
            statement.setString(3, blankToNull(batch));
            statement.setString(4, unit);
            statement.setInt(5, quantity);
            statement.setBigDecimal(6, price);
            if (!create) statement.setInt(7, id);
            if (statement.executeUpdate() != 1) throw new IllegalArgumentException("Không tìm thấy vật tư cần cập nhật.");
            if (!create) return id;
            try (ResultSet keys = statement.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
            throw new IllegalStateException("Không đọc được mã vật tư vừa tạo.");
        }
    }

    private Map<String, Object> service(ResultSet result) throws Exception {
        Map<String, Object> item = new HashMap<>();
        item.put("id", result.getInt("Service_ID"));
        item.put("code", result.getString("Service_Code"));
        item.put("name", result.getString("Service_Name"));
        item.put("price", result.getBigDecimal("Price"));
        item.put("specialty", result.getString("Specialty_Code"));
        item.put("tag", result.getString("Tag"));
        item.put("summary", result.getString("Summary"));
        item.put("description", result.getString("Description"));
        item.put("image", result.getString("Image_Path"));
        return item;
    }

    private Map<String, Object> supply(ResultSet result) throws Exception {
        Map<String, Object> item = new HashMap<>();
        item.put("id", result.getInt("Supply_ID"));
        item.put("name", result.getString("Supply_Name"));
        item.put("category", result.getString("Category"));
        item.put("batch", result.getString("Batch_Code"));
        item.put("unit", result.getString("Unit"));
        item.put("quantity", result.getInt("Quantity"));
        item.put("price", result.getBigDecimal("Price"));
        return item;
    }

    private String blankToNull(String value) {
        return value == null || value.isBlank() ? null : value;
    }
}
