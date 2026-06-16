package Service;

import java.util.Properties;
import javax.mail.Authenticator;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;

public class EmailService {

    public static boolean sendOTP(String recipientEmail, String otp) {
        // TẠM THỜI GÁN CỨNG ĐỂ TEST (Nhớ sửa lại thành email và app password thật của bạn nhé)
        String senderEmail = "wearconnect.hotro@gmail.com"; 
        String senderPassword = "AnhDung_14062003"; // 16 ký tự viết liền, KHÔNG dấu cách

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