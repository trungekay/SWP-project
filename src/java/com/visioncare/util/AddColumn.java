package com.visioncare.util;

import com.visioncare.dao.DBContext;
import java.sql.Connection;
import java.sql.Statement;

public class AddColumn {
    public static void main(String[] args) {
        try (Connection conn = DBContext.getConnection();
             Statement stmt = conn.createStatement()) {
             
            String sql = "ALTER TABLE Employee_Profile ADD DOB DATE, Address NVARCHAR(255);";
            stmt.executeUpdate(sql);
            System.out.println("ALTER TABLE SUCCESS!");
            
        } catch (Exception e) {
            System.out.println(e.getMessage());
        }
    }
}
