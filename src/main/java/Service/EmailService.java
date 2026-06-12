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
    // TODO: Thay thế bằng Email và App Password (Mật khẩu ứng dụng) của bạn
    private static final String SENDER_EMAIL = "email_cua_ban@gmail.com"; // VD: nguyenvanA@gmail.com
    private static final String SENDER_PASSWORD = "mat_khau_ung_dung"; // VD: abcdefghijklmnop (Không có dấu cách)

    public static boolean sendOTP(String recipientEmail, String otp) {
        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");

        Session session = Session.getInstance(props, new Authenticator() {
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(SENDER_EMAIL, SENDER_PASSWORD);
            }
        });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(SENDER_EMAIL));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(recipientEmail));
            message.setSubject("Mã OTP Khôi Phục Mật Khẩu - WearConnect");
            message.setText("Chào bạn,\n\nMã OTP để khôi phục mật khẩu của bạn là: " + otp + "\nMã có hiệu lực trong 5 phút.\n\nVui lòng không chia sẻ mã này cho bất kỳ ai.\n\nTrân trọng,\nĐội ngũ WearConnect");
            Transport.send(message);
            return true;
        } catch (MessagingException e) {
            e.printStackTrace();
            return false;
        }
    }
}