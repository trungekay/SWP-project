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
                        + "<p style='margin: 4px 0;'><b>Mã lịch hẹn:</b> <span style='color: #18a05e; font-size: 16px; font-weight: bold;'>#APT-" + appointmentId + "</span></p>"
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

    public static void sendAppointmentCancellationEmail(
            String recipientEmail,
            String patientName,
            int appointmentId,
            String doctorName,
            String specialty,
            String appointmentDate,
            String timeSlot,
            String cancellationReason) {
        if (recipientEmail == null || recipientEmail.trim().isEmpty()) {
            return;
        }
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
                message.setSubject("Xác nhận Hủy lịch khám #" + appointmentId + " thành công - VisionCare", "UTF-8");

                String reasonHtml = (cancellationReason != null && !cancellationReason.trim().isEmpty())
                        ? "<p style='margin: 4px 0;'><b>Lý do hủy:</b> " + cancellationReason.trim() + "</p>"
                        : "";

                String html = "<div style='font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; border: 1px solid #e2e8f0; border-radius: 12px; overflow: hidden;'>"
                        + "<div style='background-color: #e11d48; color: #ffffff; padding: 24px; text-align: center;'>"
                        + "<h1 style='margin: 0; font-size: 24px;'>VisionCare Eye Clinic</h1>"
                        + "<p style='margin: 6px 0 0; font-size: 15px;'>Xác Nhận Hủy Lịch Khám Thành Công</p>"
                        + "</div>"
                        + "<div style='padding: 24px; background-color: #ffffff; color: #334155; line-height: 1.6;'>"
                        + "<p>Kính gửi quý khách <b>" + patientName + "</b>,</p>"
                        + "<p>Yêu cầu hủy lịch khám mắt của quý khách tại <b>VisionCare</b> đã được nhân viên tiếp đón tiếp nhận và <b>duyệt hủy thành công</b>.</p>"
                        + "<div style='background-color: #fff1f2; border-left: 4px solid #e11d48; padding: 16px; margin: 20px 0; border-radius: 4px;'>"
                        + "<p style='margin: 4px 0;'><b>Mã lịch hẹn:</b> <span style='color: #e11d48; font-size: 16px; font-weight: bold;'>#APT-" + appointmentId + "</span></p>"
                        + "<p style='margin: 4px 0;'><b>Bác sĩ khám:</b> " + (doctorName != null ? doctorName : "Bác sĩ phụ trách") + "</p>"
                        + "<p style='margin: 4px 0;'><b>Chuyên khoa / Dịch vụ:</b> " + (specialty != null ? specialty : "Khám mắt chuyên khoa") + "</p>"
                        + "<p style='margin: 4px 0;'><b>Ngày khám:</b> " + (appointmentDate != null ? appointmentDate : "") + "</p>"
                        + "<p style='margin: 4px 0;'><b>Khung giờ:</b> " + (timeSlot != null ? timeSlot : "") + "</p>"
                        + reasonHtml
                        + "</div>"
                        + "<h4 style='color: #0f172a; margin-top: 24px; margin-bottom: 8px;'>Thông tin về việc hoàn phí khám:</h4>"
                        + "<p style='color: #64748b; font-size: 14px; margin: 0 0 12px;'>"
                        + "Do lịch hẹn của quý khách đã thanh toán phí khám trước và được hủy hợp lệ trước giờ tiếp đón, quý khách đủ điều kiện để được xử lý hoàn phí theo quy định của phòng khám."
                        + "</p>"
                        + "<ul style='padding-left: 20px; color: #64748b; font-size: 14px;'>"
                        + "<li>Nhân viên lễ tân / kế toán sẽ tiến hành liên hệ hoặc xử lý chuyển khoản hoàn tiền theo thông tin đã đăng ký.</li>"
                        + "<li>Nếu quý khách muốn đặt lại một lịch hẹn khác phù hợp hơn, vui lòng truy cập website VisionCare để chọn ca khám mới.</li>"
                        + "</ul>"
                        + "<p style='margin-top: 24px;'>Nếu cần hỗ trợ thêm, quý khách vui lòng liên hệ hotline: <b>1800 599 988</b>.</p>"
                        + "</div>"
                        + "<div style='background-color: #f1f5f9; padding: 16px; text-align: center; color: #94a3b8; font-size: 12px;'>"
                        + "<p style='margin: 0;'>VisionCare Eye Clinic — 123 Lê Lợi, Quận 1, TP.HCM</p>"
                        + "</div>"
                        + "</div>";

                message.setContent(html, "text/html; charset=UTF-8");
                Transport.send(message);
                System.out.println("====== APPOINTMENT CANCELLATION EMAIL SENT TO " + recipientEmail + " (Appt #" + appointmentId + ") ======");
            } catch (Exception e) {
                System.err.println("sendAppointmentCancellationEmail error: " + e.getMessage());
            }
        }).start();
    }

    public static String rescheduleEmailBody(com.visioncare.dao.PatientRescheduleDAO.Change change) {
        var previous=change.previous();var updated=change.updated();
        StringBuilder html=new StringBuilder("<div style='font-family:Arial,sans-serif;line-height:1.6;color:#334155'><h2>Xác nhận đổi lịch khám</h2><p>Kính gửi ");
        html.append(WorkflowTokens.html((String)updated.get("patientName"))).append(",</p><p>Lịch khám #APT-").append(updated.get("id")).append(" đã được thay đổi thành công.</p>");
        for(var entry:java.util.List.of(java.util.Map.entry("Lịch cũ",previous),java.util.Map.entry("Lịch mới đã xác nhận",updated))) {
            var visit=entry.getValue();
            String date=((java.sql.Date)visit.get("date")).toLocalDate().format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy"));
            html.append("<h3>").append(entry.getKey()).append("</h3><p>Bác sĩ: ").append(WorkflowTokens.html((String)visit.get("doctorName")))
                .append("<br>Ngày khám: ").append(date).append("<br>Ca khám: ").append(visit.get("time")).append(" - ").append(visit.get("endTime")).append(" (giờ Việt Nam)</p>");
        }
        return html.append("<p>Phí khám đã thanh toán được giữ nguyên; quý khách không cần thanh toán lại phí khám cho lần đổi này.</p><p>Vui lòng đến trước giờ hẹn 10–15 phút để làm thủ tục tiếp đón.</p><p>Trân trọng,<br>VisionCare</p></div>").toString();
    }

    public static void sendRescheduleConfirmationEmail(com.visioncare.dao.PatientRescheduleDAO.Change change)throws Exception {
        String recipient=(String)change.updated().get("email");
        if(recipient==null||recipient.isBlank())throw new IllegalArgumentException("Bệnh nhân chưa có email nhận thông báo.");
        Properties props=new Properties();
        props.put("mail.smtp.auth","true");props.put("mail.smtp.starttls.enable","true");
        props.put("mail.smtp.host","smtp.gmail.com");props.put("mail.smtp.port","587");
        props.put("mail.smtp.connectiontimeout","10000");props.put("mail.smtp.timeout","10000");props.put("mail.smtp.writetimeout","10000");
        Session session=Session.getInstance(props,new Authenticator(){@Override protected PasswordAuthentication getPasswordAuthentication(){return new PasswordAuthentication(SENDER_EMAIL,SENDER_PASSWORD);}});
        MimeMessage message=new MimeMessage(session);
        message.setFrom(new InternetAddress(SENDER_EMAIL,"VisionCare","UTF-8"));
        message.setRecipient(Message.RecipientType.TO,new InternetAddress(recipient));
        message.setSubject("VisionCare - Xác nhận đổi lịch khám #APT-"+change.updated().get("id"),"UTF-8");
        message.setContent(rescheduleEmailBody(change),"text/html; charset=UTF-8");
        Transport.send(message);
    }

    /** Synchronous send: the persisted outbox owns retries, not a detached thread. */
    public static void sendRefundDecisionEmail(java.util.Map<String,Object> mail) throws Exception {sendRefundMail(mail,false);}
    public static void sendRefundDecisionTestEmail(java.util.Map<String,Object> mail) throws Exception {sendRefundMail(mail,true);}
    private static void sendRefundMail(java.util.Map<String,Object> mail,boolean test) throws Exception {
        String recipient=(String)mail.get("email");
        if(recipient==null||recipient.isBlank())throw new IllegalArgumentException("Bệnh nhân chưa có email nhận thông báo.");
        boolean approved=Boolean.TRUE.equals(mail.get("approved"));
        Properties props=new Properties();
        props.put("mail.smtp.auth","true");props.put("mail.smtp.starttls.enable","true");
        props.put("mail.smtp.host","smtp.gmail.com");props.put("mail.smtp.port","587");
        props.put("mail.smtp.connectiontimeout","10000");props.put("mail.smtp.timeout","10000");props.put("mail.smtp.writetimeout","10000");
        Session session=Session.getInstance(props,new Authenticator(){@Override protected PasswordAuthentication getPasswordAuthentication(){return new PasswordAuthentication(SENDER_EMAIL,SENDER_PASSWORD);}});
        MimeMessage message=new MimeMessage(session);
        message.setFrom(new InternetAddress(SENDER_EMAIL,"VisionCare","UTF-8"));
        message.setRecipient(Message.RecipientType.TO,new InternetAddress(recipient));
        message.setSubject((test?"[KIỂM THỬ] ":"")+(approved?"VisionCare - Yêu cầu hoàn tiền đã được duyệt":"VisionCare - Kết quả yêu cầu hoàn tiền"),"UTF-8");
        String text="<p>Xin chào "+WorkflowTokens.html((String)mail.get("name"))+",</p>";
        if(test){text+="<h3>EMAIL KIỂM THỬ KÊNH THÔNG BÁO HOÀN TIỀN</h3><p>Thư này chỉ kiểm tra khả năng gửi email của yêu cầu #REF-"+mail.get("id")+". Đây không phải quyết định phê duyệt hoặc xác nhận đã chi trả.</p><p>Trạng thái thực tế tại thời điểm kiểm thử: "+WorkflowTokens.html((String)mail.get("currentStatus"))+".</p><p>Nội dung thông báo sau khi được duyệt: Phòng khám sẽ thực hiện hoàn tiền trong vòng 1 tuần. Nếu bị từ chối, email thông báo sẽ kèm lý do của director.</p>";}
        else{text+="<p>Yêu cầu hoàn tiền #REF-"+mail.get("id")+" ";text+=approved?"đã được duyệt. Phòng khám sẽ thực hiện hoàn tiền trong vòng 1 tuần.</p>":"không được phê duyệt.</p><p>Lý do: "+WorkflowTokens.html((String)mail.get("note"))+"</p>";}
        message.setContent(text+"<p>Trân trọng,<br>VisionCare</p>","text/html; charset=UTF-8");Transport.send(message);
    }
}
