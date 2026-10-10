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
    public static void sendAccountCredentialsEmail(String recipientEmail, String password) throws Exception {
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
        message.setSubject("Thông tin tài khoản VisionCare", "UTF-8");
        String htmlContent = "<div style='font-family: Arial, sans-serif; padding: 20px; text-align: center;'>"
                + "<h2 style='color: #0d9488;'>Chào mừng bạn đến với VisionCare</h2>"
                + "<p>Tài khoản của bạn đã được tạo thành công.</p>"
                + "<p><b>Tài khoản (Email):</b> " + recipientEmail + "</p>"
                + "<p><b>Mật khẩu:</b> " + password + "</p>"
                + "<p>Vui lòng đăng nhập và đổi mật khẩu để bảo mật tài khoản.</p>"
                + "</div>";
        message.setContent(htmlContent, "text/html; charset=UTF-8");
        Transport.send(message);
        System.out.println("====== CREDENTIALS SENT TO " + recipientEmail + " ======");
    }

    public static void sendAppointmentConfirmationEmail(
            String recipientEmail,
            String patientName,
            int appointmentId,
            String doctorName,
            String specialty,
            String appointmentDate,
            String timeSlot,
            long feeAmount) {
        new Thread(() -> {
            try {
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
                message.setFrom(new InternetAddress(SENDER_EMAIL, "Phòng Khám Mắt VisionCare", "UTF-8"));
                message.setRecipient(Message.RecipientType.TO, new InternetAddress(recipientEmail));
                message.setSubject("Xác nhận Đặt lịch khám thành công #" + appointmentId + " - VisionCare", "UTF-8");

                java.text.NumberFormat nf = java.text.NumberFormat.getInstance(new java.util.Locale("vi", "VN"));
                String formattedFee = nf.format(feeAmount) + " ₫";

                String html = "<div style='font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; border: 1px solid #e2e8f0; border-radius: 12px; overflow: hidden;'>"
                        + "<div style='background-color: #18a05e; color: #ffffff; padding: 24px; text-align: center;'>"
                        + "<h1 style='margin: 0; font-size: 24px;'>VisionCare Eye Clinic</h1>"
                        + "<p style='margin: 6px 0 0; font-size: 15px;'>Xác Nhận Đặt Lịch Khám Thành Công</p>"
                        + "</div>"
                        + "<div style='padding: 24px; background-color: #ffffff; color: #334155; line-height: 1.6;'>"
                        + "<p>Kính gửi quý khách <b>" + patientName + "</b>,</p>"
                        + "<p>Lịch hẹn khám mắt của quý khách tại <b>VisionCare</b> đã được ghi nhận và thanh toán phí khám ban đầu thành công!</p>"
                        + "<div style='background-color: #f8fafc; border-left: 4px solid #18a05e; padding: 16px; margin: 20px 0; border-radius: 4px;'>"
                        + "<p style='margin: 4px 0;'><b>Mã lịch hẹn:</b> <span style='color: #18a05e; font-size: 16px; font-weight: bold;'>#VC" + appointmentId + "</span></p>"
                        + "<p style='margin: 4px 0;'><b>Bác sĩ khám:</b> " + doctorName + "</p>"
                        + "<p style='margin: 4px 0;'><b>Chuyên khoa / Dịch vụ:</b> " + specialty + "</p>"
                        + "<p style='margin: 4px 0;'><b>Ngày khám:</b> " + appointmentDate + "</p>"
                        + "<p style='margin: 4px 0;'><b>Khung giờ:</b> " + timeSlot + "</p>"
                        + "<p style='margin: 4px 0;'><b>Phí khám ban đầu đã trả:</b> " + formattedFee + " (Đã thanh toán)</p>"
                        + "</div>"
                        + "<h4 style='color: #0f172a; margin-top: 24px; margin-bottom: 8px;'>Lưu ý trước khi đến khám:</h4>"
                        + "<ul style='padding-left: 20px; color: #64748b; font-size: 14px;'>"
                        + "<li>Vui lòng đến trước giờ hẹn <b>10-15 phút</b> để hoàn tất thủ tục tiếp đón.</li>"
                        + "<li>Nếu quý khách đang đeo kính áp tròng, hãy tạm ngưng sử dụng ít nhất 24 giờ trước khi khám khúc xạ.</li>"
                        + "<li>Mang theo CCCD/BHYT và các kết quả khám mắt trước đó (nếu có).</li>"
                        + "</ul>"
                        + "<p style='margin-top: 24px;'>Nếu cần hỗ trợ dời lịch hoặc tư vấn thêm, quý khách vui lòng liên hệ hotline: <b>1800 599 988</b>.</p>"
                        + "</div>"
                        + "<div style='background-color: #f1f5f9; padding: 16px; text-align: center; color: #94a3b8; font-size: 12px;'>"
                        + "<p style='margin: 0;'>VisionCare Eye Clinic — 123 Lê Lợi, Quận 1, TP.HCM</p>"
                        + "</div>"
                        + "</div>";

                message.setContent(html, "text/html; charset=UTF-8");
                Transport.send(message);
                System.out.println("====== APPOINTMENT CONFIRMATION SENT TO " + recipientEmail + " (Appt #" + appointmentId + ") ======");
            } catch (Exception e) {
                System.err.println("sendAppointmentConfirmationEmail error: " + e.getMessage());
            }
        }).start();
    }
}
