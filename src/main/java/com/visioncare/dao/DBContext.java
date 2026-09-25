package com.visioncare.dao;

import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.util.Properties;

/**
 * Lớp quản lý kết nối cơ sở dữ liệu.
 * Đọc cấu hình từ db.properties trên classpath.
 */
public class DBContext {

    private static String DRIVER;
    private static String URL;
    private static String USERNAME;
    private static String PASSWORD;

    static {
        try (InputStream is = DBContext.class.getClassLoader()
                .getResourceAsStream("db.properties")) {
            Properties props = new Properties();
            if (is != null) {
                props.load(is);
                DRIVER   = props.getProperty("db.driver");
                URL      = props.getProperty("db.url");
                USERNAME = props.getProperty("db.username");
                PASSWORD = props.getProperty("db.password");
                Class.forName(DRIVER);
            } else {
                throw new RuntimeException("Không tìm thấy file db.properties trên classpath!");
            }
        } catch (Exception e) {
            throw new RuntimeException("Lỗi khởi tạo DBContext: " + e.getMessage(), e);
        }
    }

    /**
     * Tạo và trả về một Connection mới tới database.
     * Gọi xong phải đóng Connection (dùng try-with-resources).
     */
    public static Connection getConnection() throws Exception {
        return DriverManager.getConnection(URL, USERNAME, PASSWORD);
    }
}
