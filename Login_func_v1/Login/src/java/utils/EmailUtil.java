package utils;

import jakarta.mail.*;
import jakarta.mail.internet.*;
import java.util.Properties;

public class EmailUtil {

    private static final String FROM_EMAIL = "duongsieuga@gmail.com"; 
    private static final String APP_PASSWORD = "hrdcqbjuvgpuzrze";

    public static boolean sendEmail(String toEmail, String subject, String content) {
        try {
            // Config mail server
            Properties props = new Properties();
            props.put("mail.smtp.host", "smtp.gmail.com");
            props.put("mail.smtp.port", "587");
            props.put("mail.smtp.auth", "true");
            props.put("mail.smtp.starttls.enable", "true");
            props.put("mail.smtp.ssl.protocols", "TLSv1.2");

            // Create session
            Session session = Session.getInstance(props, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(FROM_EMAIL, APP_PASSWORD);
                }
            });

            // Create message
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(FROM_EMAIL, "Pizza Store"));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject(subject);
            message.setText(content);

            // Send email
            Transport.send(message);
            System.out.println("[INFO] Email sent successfully to " + toEmail);
            return true;

        } catch (Exception e) {
            System.err.println("[ERROR] Failed to send email to " + toEmail);
            e.printStackTrace();
            return false;
        }
    }

    // Test method
    public static void main(String[] args) {
        boolean sent = EmailUtil.sendEmail("test@gmail.com", "Test OTP", "Your OTP code is: 123456");
        System.out.println(sent ? "Email sent successfully" : "Failed to send email");
    }
}