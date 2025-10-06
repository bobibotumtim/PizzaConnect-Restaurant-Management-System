package utils;

import jakarta.servlet.ServletContext;
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

    public static boolean sendOtp(ServletContext context, String toEmail, String otp) {
        String host = context.getInitParameter("smtp.host");
        String port = context.getInitParameter("smtp.port");
        String username = context.getInitParameter("smtp.username");
        String password = context.getInitParameter("smtp.password");
        String from = context.getInitParameter("smtp.from");
        String starttls = context.getInitParameter("smtp.starttls");
        String auth = context.getInitParameter("smtp.auth");
        String sslProtocols = context.getInitParameter("smtp.ssl.protocols");
        String sslTrust = context.getInitParameter("smtp.ssl.trust");

        Properties props = new Properties();
        props.put("mail.smtp.host", host);
        props.put("mail.smtp.port", port);
        props.put("mail.smtp.starttls.enable", starttls != null ? starttls : "true");
        props.put("mail.smtp.auth", auth != null ? auth : "true");
        if (sslProtocols != null) props.put("mail.smtp.ssl.protocols", sslProtocols);
        if (sslTrust != null) props.put("mail.smtp.ssl.trust", sslTrust);
        props.put("mail.debug", "true");

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(username, password);
            }
        });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(from != null ? from : username));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject("Mã OTP khôi phục mật khẩu");
            message.setText("Mã OTP của bạn là: " + otp + "\nMã sẽ hết hạn sau 5 phút.");
            Transport.send(message);
            return true;
        } catch (MessagingException e) {
            e.printStackTrace();
            return false;
        }
    }
}


