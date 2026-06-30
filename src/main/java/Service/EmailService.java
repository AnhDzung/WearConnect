package Service;

import java.util.Properties;
import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.MessagingException;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

public class EmailService {

    private static String getConfig(String key, String envKey, String defaultValue) {
        String sysProp = System.getProperty(key);
        if (sysProp != null && !sysProp.isBlank()) return sysProp.trim();

        String sysPropEnv = System.getProperty(envKey);
        if (sysPropEnv != null && !sysPropEnv.isBlank()) return sysPropEnv.trim();

        String envValue = System.getenv(envKey);
        if (envValue != null && !envValue.isBlank()) return envValue.trim();

        try (java.io.InputStream input = EmailService.class.getClassLoader().getResourceAsStream("application.properties")) {
            if (input != null) {
                Properties prop = new Properties();
                prop.load(input);
                String value = prop.getProperty(key);
                if (value != null && !value.isBlank()) {
                    if (value.contains("${")) {
                        int colonIndex = value.indexOf(":");
                        if (colonIndex > 0) {
                            String resolvedEnvKey = value.substring(value.indexOf("${") + 2, colonIndex).trim();
                            String resolvedDefault = value.substring(colonIndex + 1, value.indexOf("}")).trim();
                            return getConfig(key, resolvedEnvKey, resolvedDefault);
                        }
                    }
                    return value.trim();
                }
            }
        } catch (Exception e) {
            // Ignore properties load error
        }

        return defaultValue;
    }

    public static boolean sendOTP(String recipientEmail, String otp) {
        String senderEmail = getConfig("mail.sender.email", "EMAIL_SENDER", "wearconnect.hotro@gmail.com"); 
        String senderPassword = getConfig("mail.sender.app-password", "EMAIL_APP_PASSWORD", "AnhDung_14062003"); 

        if (senderPassword != null) {
            senderPassword = senderPassword.replaceAll("\\s+", ""); // Loại bỏ khoảng trắng nếu dán nhầm App Password có dấu cách
        }

        System.out.println("[EmailService] Đang đăng nhập Gmail bằng tài khoản: " + senderEmail);

        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");

        final String authEmail = senderEmail;
        final String authPassword = senderPassword;

        Session session = Session.getInstance(props, new Authenticator() {
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(authEmail, authPassword);
            }
        });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(authEmail));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(recipientEmail));
            message.setSubject("Mã OTP Khôi Phục Mật Khẩu - WearConnect");
            message.setText("Chào bạn,\n\nMã OTP để khôi phục mật khẩu của bạn là: " + otp + "\nMã có hiệu lực trong 5 phút.\n\nVui lòng không chia sẻ mã này cho bất kỳ ai.\n\nTrân trọng,\nĐội ngũ WearConnect");
            Transport.send(message);
            System.out.println("[EmailService] Gửi email thành công tới: " + recipientEmail);
            return true;
        } catch (MessagingException e) {
            System.err.println("[EmailService] LỖI GỬI EMAIL: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
}