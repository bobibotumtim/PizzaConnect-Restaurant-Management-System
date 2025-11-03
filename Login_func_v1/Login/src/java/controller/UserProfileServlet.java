package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import models.User;
import dao.UserDAO;
import dao.TokenDAO;
import utils.EmailUtil;
import java.io.IOException;
import java.sql.Date;
import java.security.SecureRandom;
import org.mindrot.jbcrypt.BCrypt;

public class UserProfileServlet extends HttpServlet {

    private static final String PHONE_REGEX = "^0[1-9]\\d{8}$";
    private static final String EMAIL_REGEX = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$";
    private static final String PROFILE_JSP_PATH = "/view/UserProfile.jsp";
    private static final String VERIFY_REDIRECT = "verifyCode";
    private static final String LOGIN_REDIRECT = "Login";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(LOGIN_REDIRECT);
            return;
        }

        request.setAttribute("user", session.getAttribute("user"));
        request.getRequestDispatcher(PROFILE_JSP_PATH).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(LOGIN_REDIRECT);
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        UserDAO userDAO = new UserDAO();

        // get parameters
        String name = getTrimmedParameter(request, "name");
        String email = getTrimmedParameter(request, "email");
        String phone = getTrimmedParameter(request, "phone");
        String gender = getTrimmedParameter(request, "gender");
        String dobStr = getTrimmedParameter(request, "dateOfBirth");
        String oldPassword = getTrimmedParameter(request, "oldPassword");
        String newPassword = getTrimmedParameter(request, "newPassword");
        String confirmPassword = getTrimmedParameter(request, "confirmPassword");

        Date dateOfBirth = parseDate(dobStr, request, response, currentUser);
        if (dateOfBirth == null && dobStr != null && !dobStr.isEmpty())
            return;

        String validationError = validateInputs(currentUser, email, phone, oldPassword, newPassword, confirmPassword,
                userDAO);
        if (validationError != null) {
            forwardWithError(request, response, currentUser, validationError);
            return;
        }

        // check if any changes were made
        if (!hasChanges(currentUser, name, email, phone, gender, dateOfBirth, newPassword)) {
            forwardWithMessage(request, response, currentUser, "No changes were made!");
            return;
        }

        // sending OTP if password is changed
        if (newPassword != null && !newPassword.isEmpty()) {
            String hashedNewPassword = BCrypt.hashpw(newPassword, BCrypt.gensalt());
            String otpCode = generateOTP(6);

            // save OTP and hashed password temporarily
            TokenDAO tokenDAO = new TokenDAO();
            tokenDAO.saveOTP(currentUser.getUserID(), otpCode, hashedNewPassword);

            try {
                String subject = "Password Change Verification Code";
                String content = String.format("""
                        Hello %s,

                        Your verification code is: %s
                        This code will expire in 5 minutes.

                        If you did not request this, please ignore this email.
                        """, currentUser.getName(), otpCode);

                EmailUtil.sendEmail(currentUser.getEmail(), subject, content);
                session.setAttribute("otpUserId", currentUser.getUserID());
                response.sendRedirect(VERIFY_REDIRECT);
                return;

            } catch (Exception e) {
                forwardWithError(request, response, currentUser, "Failed to send OTP email: " + e.getMessage());
                return;
            }
        }

        // if no password change, proceed to update other info
        User updatedUser = new User(
                currentUser.getUserID(),
                name != null && !name.isEmpty() ? name : currentUser.getName(),
                (newPassword != null && !newPassword.isEmpty()) ? newPassword : currentUser.getPassword(),
                currentUser.getRole(),
                email.toLowerCase(),
                phone,
                dateOfBirth != null ? dateOfBirth : currentUser.getDateOfBirth(),
                gender != null ? gender : currentUser.getGender(),
                currentUser.isActive()
        );

        // save updates
        boolean updated;
        try {
            updated = userDAO.updateUser(updatedUser);
            if (updated) {
                session.setAttribute("user", updatedUser);
                forwardWithMessage(request, response, updatedUser, "Profile updated successfully!");
            } else {
                forwardWithError(request, response, currentUser, "Failed to update profile!");
            }
        } catch (Exception e) {
            forwardWithError(request, response, currentUser, "Update failed: " + e.getMessage());
        }
    }

    // -------------------- Helper Methods --------------------

    private String getTrimmedParameter(HttpServletRequest request, String paramName) {
        String param = request.getParameter(paramName);
        return (param != null) ? param.trim() : null;
    }

    private Date parseDate(String dobStr, HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {
        if (dobStr == null || dobStr.isEmpty())
            return null;
        try {
            return Date.valueOf(dobStr);
        } catch (IllegalArgumentException e) {
            forwardWithError(request, response, user, "Invalid date format!");
            return null;
        }
    }

    private String validateInputs(User user, String email, String phone,
            String oldPassword, String newPassword, String confirmPassword,
            UserDAO userDAO) {
        if (email == null || email.isEmpty() || phone == null || phone.isEmpty()) {
            return "Required fields cannot be empty!";
        }
        if (!email.matches(EMAIL_REGEX))
            return "Invalid email format!";
        if (!phone.matches(PHONE_REGEX))
            return "Invalid phone number format!";

        if (userDAO.emailExists(email) && !email.equalsIgnoreCase(user.getEmail())) {
            return "Email is already registered!";
        }

        if (oldPassword != null && !oldPassword.isEmpty()) {
            if (!BCrypt.checkpw(oldPassword, user.getPassword())) {
                return "Old password is incorrect!";
            }
            if (newPassword == null || newPassword.isEmpty() || !newPassword.equals(confirmPassword)) {
                return "New password does not match or is empty!";
            }
            if (newPassword.length() < 8) {
                return "Password must be at least 8 characters!";
            }
        }
        return null;
    }

    private boolean hasChanges(User user, String name, String email, String phone,
                               String gender, Date dateOfBirth, String newPassword) {
        return (name != null && !name.equalsIgnoreCase(user.getName()))
                || (email != null && !email.equalsIgnoreCase(user.getEmail()))
                || (phone != null && !phone.equals(user.getPhone()))
                || (gender != null && !gender.equalsIgnoreCase(user.getGender()))
                || (dateOfBirth != null && !dateOfBirth.equals(user.getDateOfBirth()))
                || (newPassword != null && !newPassword.isEmpty());
    }

    private String generateOTP(int length) {
        SecureRandom random = new SecureRandom();
        String chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        StringBuilder otp = new StringBuilder(length);
        for (int i = 0; i < length; i++)
            otp.append(chars.charAt(random.nextInt(chars.length())));
        return otp.toString();
    }

    private void forwardWithError(HttpServletRequest request, HttpServletResponse response, User user, String error)
            throws ServletException, IOException {
        request.setAttribute("error", error);
        request.setAttribute("user", user);
        request.getRequestDispatcher(PROFILE_JSP_PATH).forward(request, response);
    }

    private void forwardWithMessage(HttpServletRequest request, HttpServletResponse response, User user, String msg)
            throws ServletException, IOException {
        request.setAttribute("message", msg);
        request.setAttribute("user", user);
        request.getRequestDispatcher(PROFILE_JSP_PATH).forward(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Handles user profile updates and password change verification via OTP";
    }
}
