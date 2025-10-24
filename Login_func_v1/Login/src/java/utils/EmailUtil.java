package utils;

import jakarta.mail.*;
import jakarta.mail.internet.*;
import java.io.InputStream;
import java.util.Properties;

public class EmailUtil {

    private static String FROM_EMAIL;
    private static String APP_PASSWORD;

    private static final String SMTP_HOST = "smtp.gmail.com";
    private static final String SMTP_PORT = "587";

    static {
        try (InputStream input = EmailUtil.class.getClassLoader().getResourceAsStream("config.properties")) {
            if (input == null) {
                throw new RuntimeException("config.properties not found in resources folder!");
            }

            Properties props = new Properties();
            props.load(input);

            FROM_EMAIL = props.getProperty("email");
            APP_PASSWORD = props.getProperty("password");

            if (FROM_EMAIL == null || APP_PASSWORD == null) {
                throw new RuntimeException("Missing 'email' or 'password' in config.properties");
            }

        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("Failed to load email configuration", e);
        }
    }

    public static boolean sendEmail(String toEmail, String subject, String content) {
        try {
            // config mail server
            Properties props = new Properties();
            props.put("mail.smtp.host", SMTP_HOST);
            props.put("mail.smtp.port", SMTP_PORT);
            props.put("mail.smtp.auth", "true");
            props.put("mail.smtp.starttls.enable", "true");
            props.put("mail.smtp.ssl.protocols", "TLSv1.2");

            // create session
            Session session = Session.getInstance(props, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(FROM_EMAIL, APP_PASSWORD);
                }
            });
            session.setDebug(true); // thêm dòng này để bật debug

            // create message
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(FROM_EMAIL, "FPT User Portal"));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject(subject);
            message.setText(content);

            // sending email
            Transport.send(message);
            System.out.println("[INFO] Email sent successfully to " + toEmail);
            return true;

        } catch (Exception e) {
            System.err.println("[ERROR] Failed to send email to " + toEmail);
            e.printStackTrace();
            return false;
        }
    }

    public static void main(String[] args) {
        boolean ok = EmailUtil.sendEmail("tjhbxgsudz100@gmail.com", "Test OTP", "123456");
        System.out.println(ok ? "Sent" : "Failed");
    }
}
