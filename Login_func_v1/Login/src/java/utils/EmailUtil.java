package utils;

import brevo.*;
import brevoApi.*;
import brevoModel.CreateSmtpEmail;
import brevoModel.SendSmtpEmail;
import brevoModel.SendSmtpEmailSender;
import brevoModel.SendSmtpEmailTo;

import java.util.List;
import java.util.ArrayList;
import java.util.Properties;
import java.io.InputStream;
import java.io.FileInputStream;

public class EmailUtil {

    private static final String API_KEY;

    static {
        String key = null;
        try (InputStream input = new FileInputStream("nbproject/config.properties")) {
            Properties prop = new Properties();
            prop.load(input);
            key = prop.getProperty("brevo.apikey");
        } catch (Exception e) {
            System.err.println("Failed to load API key from config.properties");
            e.printStackTrace();
        }
        API_KEY = key;
    }

    public static void sendVerificationEmail(String toEmail, String userName, String verifyLink) {
        if (API_KEY == null || API_KEY.isEmpty()) {
            System.err.println("BREVO API key is missing! Please check config.properties");
            return;
        }

        try {
            // Initialize API client
            ApiClient defaultClient = Configuration.getDefaultApiClient();
            defaultClient.setApiKey(API_KEY);

            TransactionalEmailsApi apiInstance = new TransactionalEmailsApi();

            // Set sender (email đã verify trên Brevo)
            SendSmtpEmailSender sender = new SendSmtpEmailSender();
            sender.setEmail("tjhbxgsudz100@gmail.com"); // thay bằng email đã verify
            sender.setName("PizzaConnect");

            // Set recipient
            List<SendSmtpEmailTo> toList = new ArrayList<>();
            toList.add(new SendSmtpEmailTo().email(toEmail).name(userName));

            // Email subject & content
            String subject = "Confirm your password change";
            String content = "<p>Hello " + userName + ",</p>"
                    + "<p>Click the link below to confirm your password change:</p>"
                    + "<a href='" + verifyLink + "'>Verify Now</a>"
                    + "<p>If you didn’t request this, ignore this email.</p>";

            // Build email object
            SendSmtpEmail email = new SendSmtpEmail();
            email.setSender(sender);
            email.setTo(toList);
            email.setSubject(subject);
            email.setHtmlContent(content);

            // Send email
            CreateSmtpEmail response = apiInstance.sendTransacEmail(email);
            System.out.println("Email sent! Message ID: " + response.getMessageId());

        } catch (Exception e) {
            System.err.println("Failed to send email:");
            e.printStackTrace();
        }
    }
    
    public static void main(String[] args) {
        System.out.println("API_KEY=" + API_KEY);

    }
}
