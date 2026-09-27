package com.visioncare.dao;

import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.util.Properties;

/**
 * Lá»›p quáº£n lÃ½ káº¿t ná»‘i cÆ¡ sá»Ÿ dá»¯ liá»‡u.
 * Äá»c cáº¥u hÃ¬nh tá»« db.properties trÃªn classpath.
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
                throw new RuntimeException("KhÃ´ng tÃ¬m tháº¥y file db.properties trÃªn classpath!");
            }
        } catch (Exception e) {
            throw new RuntimeException("Lá»—i khá»Ÿi táº¡o DBContext: " + e.getMessage(), e);
        }
    }

    /**
     * Táº¡o vÃ  tráº£ vá» má»™t Connection má»›i tá»›i database.
     * Gá»i xong pháº£i Ä‘Ã³ng Connection (dÃ¹ng try-with-resources).
     */
    public static Connection getConnection() throws Exception {
        return DriverManager.getConnection(URL, USERNAME, PASSWORD);
    }
}
