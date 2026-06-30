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
                String rawValue = prop.getProperty(key);
                if (rawValue != null && !rawValue.isBlank()) {
                    rawValue = rawValue.trim();
                    if (rawValue.startsWith("${") && rawValue.endsWith("}")) {
                        String content = rawValue.substring(2, rawValue.length() - 1);
                        int colonIndex = content.indexOf(":");
                        String innerEnvKey = (colonIndex >= 0) ? content.substring(0, colonIndex).trim() : content.trim();
                        String innerDefault = (colonIndex >= 0) ? content.substring(colonIndex + 1).trim() : "";
                        
                        String resolved = System.getProperty(innerEnvKey);
                        if (resolved == null || resolved.isBlank()) {
                            resolved = System.getenv(innerEnvKey);
                        }
                        if (resolved != null && !resolved.isBlank()) {
                            return resolved.trim();
                        }
                        return innerDefault;
                    }
                    return rawValue;
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
            MimeMessage message = new MimeMessage(session);
            message.setFrom(new InternetAddress(authEmail));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(recipientEmail));
            message.setSubject("Mã OTP Khôi Phục Mật Khẩu - WearConnect", "UTF-8");
            String emailContent = "Chào bạn,\n\n"
                    + "Mã OTP để khôi phục mật khẩu của bạn là: " + otp + "\n"
                    + "Mã có hiệu lực trong 5 phút.\n\n"
                    + "Vui lòng không chia sẻ mã này cho bất kỳ ai.\n\n"
                    + "Trân trọng,\n"
                    + "Đội ngũ WearConnect";
            message.setContent(emailContent, "text/plain; charset=UTF-8");
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