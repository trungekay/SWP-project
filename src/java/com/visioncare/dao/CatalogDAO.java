package com.visioncare.dao;

import com.visioncare.model.CatalogService;
import com.visioncare.model.MedicalSupply;
import com.visioncare.model.ServiceWorkflowStep;
import com.visioncare.model.SupplyCategory;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class CatalogDAO {
    private static final String CONSUMABLE_CATEGORY = SupplyCategory.MEDICAL_CONSUMABLES.getVietnameseName();
    private static final String SERVICE_COLUMNS_START = "sc.Service_ID, sc.Service_Code, sc.Service_Name, sc.Price, sc.Category, sc.Summary, sc.Description, ";
    private static final String SERVICE_COLUMNS_END = ", CASE WHEN sc.Image_Data IS NULL THEN 0 ELSE 1 END AS Has_Image, "
            + "ISNULL(sc.Requires_Pre_Op, 0) AS Requires_Pre_Op, "
            + "sc.Prerequisite_Service_ID, "
            + "prereq.Service_Name AS Prerequisite_Service_Name, "
            + "prereq.Price AS Prerequisite_Service_Price, "
            + "ISNULL(sc.Allow_Direct_Booking, 1) AS Allow_Direct_Booking";

    private String serviceColumns(Connection connection) throws SQLException {
        // Fallback for older DB instances without Image_Path
        String imagePath = "sc.Image_Path";
        if (connection != null) {
            try (ResultSet columns = connection.getMetaData().getColumns(
                    connection.getCatalog(), "dbo", "Service_Catalog", "Image_Path")) {
                if (!columns.next()) {
                    imagePath = "CAST(NULL AS varchar(255))";
                }
            } catch (Exception ignored) {}
        }
        return SERVICE_COLUMNS_START + imagePath + " AS Image_Path" + SERVICE_COLUMNS_END;
    }

    public List<CatalogService> listServices() throws Exception {
        List<CatalogService> items = new ArrayList<>();
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement("SELECT " + serviceColumns(connection) + " FROM Service_Catalog sc "
                     + "LEFT JOIN Service_Catalog prereq ON sc.Prerequisite_Service_ID = prereq.Service_ID "
                     + "ORDER BY CASE WHEN sc.Service_Code IS NULL THEN 1 ELSE 0 END, sc.Service_ID");
             ResultSet result = statement.executeQuery()) {
            while (result.next()) items.add(service(result));
        }
        try {
            Map<Integer, List<ServiceWorkflowStep>> stepsMap = getAllWorkflowStepsMap();
            for (CatalogService cs : items) {
                if (stepsMap.containsKey(cs.getId())) {
                    cs.setWorkflowSteps(stepsMap.get(cs.getId()));
                }
            }
        } catch (Exception ignored) {
            // In case table hasn't been created yet
        }
        return items;
    }

    public List<CatalogService> listBookableServices() throws Exception {
        List<CatalogService> items = new ArrayList<>();
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement("SELECT " + serviceColumns(connection) + " FROM Service_Catalog sc "
                     + "LEFT JOIN Service_Catalog prereq ON sc.Prerequisite_Service_ID = prereq.Service_ID "
                     + "WHERE sc.Allow_Direct_Booking = 1 "
                     + "ORDER BY CASE WHEN sc.Service_Code IS NULL THEN 1 ELSE 0 END, sc.Service_ID");
             ResultSet result = statement.executeQuery()) {
            while (result.next()) items.add(service(result));
        }
        try {
            Map<Integer, List<ServiceWorkflowStep>> stepsMap = getAllWorkflowStepsMap();
            for (CatalogService cs : items) {
                if (stepsMap.containsKey(cs.getId())) {
                    cs.setWorkflowSteps(stepsMap.get(cs.getId()));
                }
            }
        } catch (Exception ignored) {}
        return items;
    }

    public List<CatalogService> listSurgeryServices() throws Exception {
        List<CatalogService> items = new ArrayList<>();
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement("SELECT " + serviceColumns(connection) + " FROM Service_Catalog sc "
                     + "LEFT JOIN Service_Catalog prereq ON sc.Prerequisite_Service_ID = prereq.Service_ID "
                     + "WHERE sc.Requires_Pre_Op = 1 OR sc.Category = N'Điều trị và thủ thuật' OR sc.Service_Code IN ('LS-03', 'TT-05') OR sc.Service_Code LIKE 'PT-%' "
                     + "ORDER BY sc.Service_Code");
             ResultSet result = statement.executeQuery()) {
            while (result.next()) items.add(service(result));
        }
        try {
            Map<Integer, List<ServiceWorkflowStep>> stepsMap = getAllWorkflowStepsMap();
            for (CatalogService cs : items) {
                if (stepsMap.containsKey(cs.getId())) {
                    cs.setWorkflowSteps(stepsMap.get(cs.getId()));
                }
            }
        } catch (Exception ignored) {}
        return items;
    }

    public CatalogService getService(int id) throws Exception {
        CatalogService svc = null;
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement("SELECT " + serviceColumns(connection) + " FROM Service_Catalog sc "
                     + "LEFT JOIN Service_Catalog prereq ON sc.Prerequisite_Service_ID = prereq.Service_ID "
                     + "WHERE sc.Service_ID = ?")) {
            statement.setInt(1, id);
            try (ResultSet result = statement.executeQuery()) {
                if (result.next()) svc = service(result);
            }
        }
        if (svc != null) {
            try {
                svc.setWorkflowSteps(listWorkflowSteps(id));
            } catch (Exception ignored) {}
        }
        return svc;
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
            byte[] imageData, String imageMimeType,
            boolean requiresPreOp, Integer prerequisiteServiceId, boolean allowDirectBooking,
            List<ServiceWorkflowStep> workflowSteps) throws Exception {
        boolean create = id == 0;
        String sql = create
            ? "INSERT INTO Service_Catalog (Service_Code, Service_Name, Price, Category, Summary, Description, Requires_Pre_Op, Prerequisite_Service_ID, Allow_Direct_Booking, Image_Data, Image_Mime_Type) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
            : "UPDATE Service_Catalog SET Service_Code = ?, Service_Name = ?, Price = ?, Category = ?, Summary = ?, Description = ?, Requires_Pre_Op = ?, Prerequisite_Service_ID = ?, Allow_Direct_Booking = ?" +
              (imageData == null ? "" : ", Image_Data = ?, Image_Mime_Type = ?") + " WHERE Service_ID = ?";
        try (Connection connection = DBContext.getConnection()) {
            connection.setAutoCommit(false);
            int savedId = id;
            try (PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                int column = 1;
                statement.setString(column++, blankToNull(code));
                statement.setString(column++, name);
                statement.setBigDecimal(column++, price);
                statement.setString(column++, category);
                statement.setString(column++, blankToNull(summary));
                statement.setString(column++, blankToNull(description));
                statement.setBoolean(column++, requiresPreOp);
                if (prerequisiteServiceId != null && prerequisiteServiceId > 0) {
                    statement.setInt(column++, prerequisiteServiceId);
                } else {
                    statement.setNull(column++, java.sql.Types.INTEGER);
                }
                statement.setBoolean(column++, allowDirectBooking);
                if (create || imageData != null) {
                    statement.setBytes(column++, imageData);
                    statement.setString(column++, imageMimeType);
                }
                if (!create) statement.setInt(column, id);
                if (statement.executeUpdate() != 1) {
                    connection.rollback();
                    throw new IllegalArgumentException("Không tìm thấy dịch vụ cần cập nhật.");
                }
                if (create) {
                    try (ResultSet keys = statement.getGeneratedKeys()) {
                        if (keys.next()) savedId = keys.getInt(1);
                        else {
                            connection.rollback();
                            throw new IllegalStateException("Không đọc được mã dịch vụ vừa tạo.");
                        }
                    }
                }
            }

            // Save workflow steps
            if (workflowSteps != null) {
                try (PreparedStatement delStmt = connection.prepareStatement("DELETE FROM Service_Workflow_Step WHERE Service_ID = ?")) {
                    delStmt.setInt(1, savedId);
                    delStmt.executeUpdate();
                }
                if (!workflowSteps.isEmpty()) {
                    String stepSql = "INSERT INTO Service_Workflow_Step (Service_ID, Step_Name, Step_Stage, Step_Order, Description) VALUES (?, ?, ?, ?, ?)";
                    try (PreparedStatement stepStmt = connection.prepareStatement(stepSql)) {
                        int order = 1;
                        for (ServiceWorkflowStep step : workflowSteps) {
                            if (step.getStepName() == null || step.getStepName().trim().isEmpty()) continue;
                            stepStmt.setInt(1, savedId);
                            stepStmt.setString(2, step.getStepName().trim());
                            stepStmt.setString(3, step.getStepStage() != null ? step.getStepStage().trim() : "PRE_EXAM");
                            stepStmt.setInt(4, step.getStepOrder() > 0 ? step.getStepOrder() : order++);
                            stepStmt.setString(5, blankToNull(step.getDescription()));
                            stepStmt.addBatch();
                        }
                        stepStmt.executeBatch();
                    }
                }
            }

            connection.commit();
            return savedId;
        }
    }

    public int saveService(int id, String code, String name, BigDecimal price,
            String category, String summary, String description,
            byte[] imageData, String imageMimeType) throws Exception {
        return saveService(id, code, name, price, category, summary, description,
                imageData, imageMimeType, false, null, true, null);
    }

    public List<ServiceWorkflowStep> listWorkflowSteps(int serviceId) throws Exception {
        List<ServiceWorkflowStep> steps = new ArrayList<>();
        String sql = "SELECT Step_ID, Service_ID, Step_Name, Step_Stage, Step_Order, Description "
                   + "FROM Service_Workflow_Step WHERE Service_ID = ? ORDER BY Step_Order ASC, Step_ID ASC";
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, serviceId);
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    steps.add(new ServiceWorkflowStep(
                            rs.getInt("Step_ID"),
                            rs.getInt("Service_ID"),
                            rs.getString("Step_Name"),
                            rs.getString("Step_Stage"),
                            rs.getInt("Step_Order"),
                            rs.getString("Description")));
                }
            }
        }
        return steps;
    }

    public Map<Integer, List<ServiceWorkflowStep>> getAllWorkflowStepsMap() throws Exception {
        Map<Integer, List<ServiceWorkflowStep>> map = new HashMap<>();
        String sql = "SELECT Step_ID, Service_ID, Step_Name, Step_Stage, Step_Order, Description "
                   + "FROM Service_Workflow_Step ORDER BY Service_ID, Step_Order ASC, Step_ID ASC";
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet rs = statement.executeQuery()) {
            while (rs.next()) {
                int sId = rs.getInt("Service_ID");
                map.computeIfAbsent(sId, k -> new ArrayList<>()).add(new ServiceWorkflowStep(
                        rs.getInt("Step_ID"),
                        sId,
                        rs.getString("Step_Name"),
                        rs.getString("Step_Stage"),
                        rs.getInt("Step_Order"),
                        rs.getString("Description")));
            }
        }
        return map;
    }

    public boolean updateServiceImage(int serviceId, byte[] imageData, String mimeType) throws Exception {
        String sql = "UPDATE Service_Catalog SET Image_Data = ?, Image_Mime_Type = ? WHERE Service_ID = ?";
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setBytes(1, imageData);
            statement.setString(2, mimeType);
            statement.setInt(3, serviceId);
            return statement.executeUpdate() == 1;
        }
    }

    public boolean resetServiceImage(int serviceId) throws Exception {
        String sql = "UPDATE Service_Catalog SET Image_Data = NULL, Image_Mime_Type = NULL WHERE Service_ID = ?";
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, serviceId);
            return statement.executeUpdate() == 1;
        }
    }

    public List<MedicalSupply> listConsumables() throws Exception {
        List<MedicalSupply> items = new ArrayList<>();
        String sql = "SELECT Supply_ID, Supply_Name, Category, Price, "
                + "CASE WHEN Image_Data IS NULL THEN 0 ELSE 1 END AS Has_Image "
                + "FROM Medical_Supply WHERE Category = ?"
                + " ORDER BY Supply_Name";
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, CONSUMABLE_CATEGORY);
            try (ResultSet result = statement.executeQuery()) {
                while (result.next()) items.add(supply(result));
            }
        }
        return items;
    }

    public MedicalSupply getConsumable(int id) throws Exception {
        String sql = "SELECT Supply_ID, Supply_Name, Category, Price, "
                + "CASE WHEN Image_Data IS NULL THEN 0 ELSE 1 END AS Has_Image "
                + "FROM Medical_Supply WHERE Supply_ID = ? AND Category = ?";
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, id);
            statement.setString(2, CONSUMABLE_CATEGORY);
            try (ResultSet result = statement.executeQuery()) {
                return result.next() ? supply(result) : null;
            }
        }
    }

    public int saveConsumable(int id, String name, String category,
            BigDecimal price, byte[] imageData, String imageMimeType) throws Exception {
        boolean create = id == 0;
        String sql = create
            ? "INSERT INTO Medical_Supply (Supply_Name, Category, Price, Image_Data, Image_Mime_Type) VALUES (?, ?, ?, ?, ?)"
            : "UPDATE Medical_Supply SET Supply_Name = ?, Category = ?, Price = ?" +
              (imageData == null ? "" : ", Image_Data = ?, Image_Mime_Type = ?") + " WHERE Supply_ID = ? AND Category = ?";
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            int column = 1;
            statement.setString(column++, name);
            statement.setString(column++, category);
            statement.setBigDecimal(column++, price);
            if (create || imageData != null) {
                statement.setBytes(column++, imageData);
                statement.setString(column++, imageMimeType);
            }
            if (!create) {
                statement.setInt(column++, id);
                statement.setString(column, CONSUMABLE_CATEGORY);
            }
            if (statement.executeUpdate() != 1) throw new IllegalArgumentException("Không tìm thấy vật tư cần cập nhật.");
            if (!create) return id;
            try (ResultSet keys = statement.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
            throw new IllegalStateException("Không đọc được mã vật tư vừa tạo.");
        }
    }

    public boolean deleteConsumable(int id) throws Exception {
        String sql = "DELETE FROM Medical_Supply WHERE Supply_ID = ? AND Category = ?";
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, id);
            statement.setString(2, CONSUMABLE_CATEGORY);
            return statement.executeUpdate() == 1;
        }
    }

    private CatalogService service(ResultSet result) throws Exception {
        int id = result.getInt("Service_ID");
        String code = result.getString("Service_Code");
        String name = result.getString("Service_Name");
        BigDecimal price = result.getBigDecimal("Price");
        String category = result.getString("Category");
        String summary = result.getString("Summary");
        String description = result.getString("Description");
        String imagePath = result.getString("Image_Path");
        boolean hasImage = result.getBoolean("Has_Image");
        boolean requiresPreOp = result.getBoolean("Requires_Pre_Op");
        int preOpId = result.getInt("Prerequisite_Service_ID");
        Integer prerequisiteServiceId = result.wasNull() ? null : preOpId;
        String prerequisiteServiceName = result.getString("Prerequisite_Service_Name");
        BigDecimal prerequisiteServicePrice = result.getBigDecimal("Prerequisite_Service_Price");
        boolean allowDirectBooking = result.getBoolean("Allow_Direct_Booking");

        CatalogService svc = new CatalogService(
                id, code, name, price, category, summary, description,
                imagePath, hasImage, requiresPreOp, prerequisiteServiceId,
                prerequisiteServiceName, allowDirectBooking);
        svc.setPrerequisiteServicePrice(prerequisiteServicePrice);
        return svc;
    }

    private MedicalSupply supply(ResultSet result) throws Exception {
        return new MedicalSupply(
                result.getInt("Supply_ID"), result.getString("Supply_Name"),
                result.getString("Category"),
                result.getBigDecimal("Price"), result.getBoolean("Has_Image"));
    }

    public ImageData getImage(String kind, int id) throws Exception {
        boolean service = "service".equals(kind);
        if (!service && !"consumable".equals(kind)) return null;
        String sql = service
                ? "SELECT Image_Data, Image_Mime_Type FROM Service_Catalog WHERE Service_ID = ?"
                : "SELECT Image_Data, Image_Mime_Type FROM Medical_Supply WHERE Supply_ID = ? AND Category = ?";
        try (Connection connection = DBContext.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, id);
            if (!service) statement.setString(2, CONSUMABLE_CATEGORY);
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
