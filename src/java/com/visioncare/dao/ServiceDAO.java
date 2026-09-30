package com.visioncare.dao;

import com.visioncare.model.Service;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class ServiceDAO {
    
    // Hàm lấy danh sách toàn bộ dịch vụ để hiển thị
    public List<Service> getAllServices() throws Exception {
        List<Service> services = new ArrayList<>();
        String sql = "SELECT Service_ID, Service_Name, Price FROM Service_Catalog ORDER BY Service_Name ASC";
        
        // Sử dụng try-with-resources để tự động đóng kết nối (Tránh memory leak)
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
             
            while (rs.next()) {
                Service s = new Service(
                    rs.getInt("Service_ID"),
                    rs.getString("Service_Name"),
                    rs.getDouble("Price")
                );
                services.add(s);
            }
        }
        return services;
    }
}
