package controller;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.security.SecureRandom;
import java.time.Instant;
import java.util.Date;
import java.util.Properties;
import jakarta.servlet.ServletContext;
import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.MessagingException;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

public class ForgotPasswordServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // stage: email -> enter email, otp -> enter OTP, reset -> reset password
        String stage = request.getParameter("stage");
        if (stage == null) stage = "email";
        request.setAttribute("stage", stage);
        request.getRequestDispatcher("view/ForgotPassword.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) action = "sendOtp"; // default step 1

        HttpSession sessionHttp = request.getSession();
        UserDAO dao = new UserDAO();

        switch (action) {
            case "sendOtp": {
                String email = request.getParameter("email");
                if (email != null) email = email.trim();
                if (email == null || email.isEmpty()) {
                    sessionHttp.setAttribute("error", "Please enter an email!");
                    response.sendRedirect(request.getContextPath() + "/view/ForgotPassword.jsp?stage=email");
                    return;
                }

                if (!dao.isUserExists(email)) {
                    sessionHttp.setAttribute("error", "Email does not exist in the system!");
                    response.sendRedirect(request.getContextPath() + "/view/ForgotPassword.jsp?stage=email");
                    return;
                }

                String otp = generateNumericOtp(6);
                long expireAt = Instant.now().plusSeconds(300).toEpochMilli(); // 5 minutes

                sessionHttp.setAttribute("fp_email", email);
                sessionHttp.setAttribute("fp_otp", otp);
                sessionHttp.setAttribute("fp_otp_exp", expireAt);

                boolean mailed = sendOtpEmail(getServletContext(), email, otp);
                if (mailed) {
                    sessionHttp.setAttribute("success", "OTP has been sent to your email.");
                    response.sendRedirect(request.getContextPath() + "/view/ForgotPassword.jsp?stage=otp");
                } else {
                    sessionHttp.setAttribute("error", "Failed to send OTP email. Please contact support or try again.");
                    response.sendRedirect(request.getContextPath() + "/view/ForgotPassword.jsp?stage=email");
                }
                return;
            }
            case "verifyOtp": {
                String inputOtp = request.getParameter("otp");
                String savedOtp = (String) sessionHttp.getAttribute("fp_otp");
                Long exp = (Long) sessionHttp.getAttribute("fp_otp_exp");

                if (savedOtp == null || exp == null) {
                    sessionHttp.setAttribute("error", "OTP has not been initialized. Please request again.");
                    response.sendRedirect(request.getContextPath() + "/view/ForgotPassword.jsp?stage=email");
                    return;
                }

                if (Instant.now().toEpochMilli() > exp) {
                    sessionHttp.setAttribute("error", "OTP has expired. Please request a new one.");
                    clearOtp(sessionHttp);
                    response.sendRedirect(request.getContextPath() + "/view/ForgotPassword.jsp?stage=email");
                    return;
                }

                if (inputOtp == null || !savedOtp.equals(inputOtp.trim())) {
                    sessionHttp.setAttribute("error", "Invalid OTP!");
                    response.sendRedirect(request.getContextPath() + "/view/ForgotPassword.jsp?stage=otp");
                    return;
                }

                sessionHttp.setAttribute("fp_verified", Boolean.TRUE);
                sessionHttp.setAttribute("success", "OTP verified successfully. Please set a new password.");
                response.sendRedirect(request.getContextPath() + "/view/ForgotPassword.jsp?stage=reset");
                return;
            }
            case "resetPassword": {
                Object verified = sessionHttp.getAttribute("fp_verified");
                String email = (String) sessionHttp.getAttribute("fp_email");
                if (!(verified instanceof Boolean) || !((Boolean) verified) || email == null) {
                    sessionHttp.setAttribute("error", "Invalid verification session. Please try again.");
                    response.sendRedirect(request.getContextPath() + "/view/ForgotPassword.jsp?stage=email");
                    return;
                }

                String newPass = request.getParameter("newPassword");
                String confirm = request.getParameter("confirmPassword");
                
                // Validate password not empty and match
                if (newPass == null || confirm == null || newPass.trim().isEmpty() || !newPass.equals(confirm)) {
                    sessionHttp.setAttribute("error", "Password is invalid or does not match!");
                    response.sendRedirect(request.getContextPath() + "/view/ForgotPassword.jsp?stage=reset");
                    return;
                }
                
                // Validate password strength: min 8 chars, 1 uppercase, 1 lowercase, 1 digit
                if (!isValidPassword(newPass)) {
                    sessionHttp.setAttribute("error", "Password must be at least 8 characters with 1 uppercase, 1 lowercase, and 1 digit!");
                    response.sendRedirect(request.getContextPath() + "/view/ForgotPassword.jsp?stage=reset");
                    return;
                }

                boolean ok = dao.resetPassword(email, newPass);
                if (ok) {
                    sessionHttp.setAttribute("success", "Password reset successfully. Please log in.");
                    clearOtp(sessionHttp);
                    response.sendRedirect(request.getContextPath() + "/view/Login.jsp");
                } else {
                    sessionHttp.setAttribute("error", "An error occurred while resetting the password. Please try again later!");
                    response.sendRedirect(request.getContextPath() + "/view/ForgotPassword.jsp?stage=reset");
                }
                return;
            }
            default: {
                response.sendRedirect(request.getContextPath() + "/view/ForgotPassword.jsp?stage=email");
            }
        }
    }

    private String generateNumericOtp(int len) {
        SecureRandom rnd = new SecureRandom();
        String digits = "0123456789";
        StringBuilder sb = new StringBuilder(len);
        for (int i = 0; i < len; i++) sb.append(digits.charAt(rnd.nextInt(digits.length())));
        return sb.toString();
    }
    
    // Validate password: min 8 chars, 1 uppercase, 1 lowercase, 1 digit
    private boolean isValidPassword(String password) {
        if (password == null || password.length() < 8) {
            return false;
        }
        // Pattern: ^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$
        return password.matches("^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).{8,}$");
    }

    private void clearOtp(HttpSession session) {
        session.removeAttribute("fp_email");
        session.removeAttribute("fp_otp");
        session.removeAttribute("fp_otp_exp");
        session.removeAttribute("fp_verified");
    }

    // Send OTP via email using SMTP configuration from web.xml/context.xml
    private boolean sendOtpEmail(ServletContext ctx, String toEmail, String otp) {
        try {
            String host = getConfig(ctx, "mail.host");
            String port = getConfig(ctx, "mail.port", "587");
            String username = getConfig(ctx, "mail.username");
            String password = getConfig(ctx, "mail.password");
            String from = getConfig(ctx, "mail.from", username);
            String starttls = getConfig(ctx, "mail.starttls", "true");
            String sslEnable = getConfig(ctx, "mail.ssl", "false");
            String debug = getConfig(ctx, "mail.debug", "false");

            // minimal validation to avoid NPE when setting Properties
            if (host == null || host.isEmpty() || username == null || username.isEmpty() || password == null || password.isEmpty()) {
                return false;
            }
            if (from == null || from.isEmpty()) {
                from = username;
            }

            Properties props = new Properties();
            props.put("mail.smtp.auth", "true");
            props.put("mail.smtp.host", host);
            props.put("mail.smtp.port", port);

            // configure TLS/SSL based on port
            if ("true".equalsIgnoreCase(sslEnable)) {
                // SSL implicit (usually port 465)
                props.put("mail.smtp.ssl.enable", "true");
                props.put("mail.smtp.starttls.enable", "false");
                props.put("mail.smtp.socketFactory.port", port);
                props.put("mail.smtp.socketFactory.class", "javax.net.ssl.SSLSocketFactory");
            } else {
                // STARTTLS (usually port 587)
                props.put("mail.smtp.ssl.enable", "false");
                props.put("mail.smtp.starttls.enable", starttls);
                props.put("mail.smtp.starttls.required", "true");
            }

            // trust all if needed to avoid self-signed cert errors
            props.put("mail.smtp.ssl.trust", host);

            Session mailSession = Session.getInstance(props, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(username, password);
                }
            });
            mailSession.setDebug("true".equalsIgnoreCase(debug));

            Message message = new MimeMessage(mailSession);
            message.setFrom(new InternetAddress(from));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject("Password Recovery OTP");
            message.setSentDate(new Date());
            message.setText("Your OTP is: " + otp + "\nThe code is valid for 5 minutes.");

            Transport.send(message);
            return true;
        } catch (MessagingException ex) {
            ex.printStackTrace();
            return false;
        }
    }

    private String getConfig(ServletContext ctx, String key) {
        String v = ctx.getInitParameter(key);
        if (v == null || v.isEmpty()) v = System.getProperty(key);
        if (v == null || v.isEmpty()) v = System.getenv(key);
        return v;
    }

    private String getConfig(ServletContext ctx, String key, String def) {
        String v = getConfig(ctx, key);
        return (v == null || v.isEmpty()) ? def : v;
    }
}