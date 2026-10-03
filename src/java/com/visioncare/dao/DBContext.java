package com.visioncare.dao;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.util.Properties;
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
                throw new RuntimeException("KhÃ´ng tÃ¬m tháº¥y file db.properties trÃªn classpath!");
            }
        } catch (Exception e) {
            throw new RuntimeException("Lá»—i khá»Ÿi táº¡o DBContext: " + e.getMessage(), e);
        }
    }
    public static Connection getConnection() throws Exception {
        return DriverManager.getConnection(URL, USERNAME, PASSWORD);
    }
}
