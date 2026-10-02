package com.visioncare.util;
import javax.mail.*;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import java.util.Properties;
public class EmailUtil {
    private static final String SENDER_EMAIL = "hotro.visioncare@gmail.com";
    private static final String SENDER_PASSWORD = "gmpizjvpsdxssjwe";
    public static void sendOtpEmail(String recipientEmail, String otp) throws Exception {
        Properties properties = new Properties();
        properties.put("mail.smtp.auth", "true");
        properties.put("mail.smtp.starttls.enable", "true");
        properties.put("mail.smtp.host", "smtp.gmail.com");
        properties.put("mail.smtp.port", "587");
        Session session = Session.getInstance(properties, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(SENDER_EMAIL, SENDER_PASSWORD);
            }
        });
        MimeMessage message = new MimeMessage(session);
        message.setFrom(new InternetAddress(SENDER_EMAIL));
        message.setRecipient(Message.RecipientType.TO, new InternetAddress(recipientEmail));
        message.setSubject("Mã OTP Xác thực - VisionCare", "UTF-8");
        String htmlContent = "<div style='font-family: Arial, sans-serif; padding: 20px; text-align: center;'>"
                + "<h2 style='color: #0d9488;'>Xác thực tài khoản VisionCare</h2>"
                + "<p>Mã OTP của bạn là:</p>"
                + "<h1 style='color: #1c355e; letter-spacing: 5px;'>" + otp + "</h1>"
                + "<p>Mã này có hiệu lực trong 5 phút. Vui lòng không chia sẻ mã này với người khác.</p>"
                + "</div>";
        message.setContent(htmlContent, "text/html; charset=UTF-8");
        Transport.send(message);
        System.out.println("====== OTP SENT TO " + recipientEmail + " : " + otp + " ======");
    }
}
