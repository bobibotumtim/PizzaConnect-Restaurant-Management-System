package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import models.User;
import utils.EmailUtil;
import dao.TokenDAO;
import dao.UserDAO;
import java.io.IOException;
import java.sql.Date;
import org.mindrot.jbcrypt.BCrypt;

public class UserProfileServlet extends HttpServlet {

    private static final String PHONE_REGEX = "^0[1-9]\\d{8}$";
    private static final String EMAIL_REGEX = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$";
    private static final String JSP_PATH = "/view/UserProfile.jsp";
    private static final String LOGIN_REDIRECT = "Login";
    private static final String APP_URL = "http://localhost:8080/Login";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(LOGIN_REDIRECT);
            return;
        }

        User user = (User) session.getAttribute("user");
        request.setAttribute("user", user);
        request.getRequestDispatcher(JSP_PATH).forward(request, response);
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

        String name = getTrimmedParameter(request, "name");
        String email = getTrimmedParameter(request, "email");
        String phone = getTrimmedParameter(request, "phone");
        String gender = getTrimmedParameter(request, "gender");
        String dobStr = getTrimmedParameter(request, "dateOfBirth");
        String oldPassword = getTrimmedParameter(request, "oldPassword");
        String newPassword = getTrimmedParameter(request, "newPassword");
        String confirmPassword = getTrimmedParameter(request, "confirmPassword");

        Date dateOfBirth = null;
        if (dobStr != null && !dobStr.isEmpty()) {
            try {
                dateOfBirth = Date.valueOf(dobStr);
            } catch (IllegalArgumentException e) {
                request.setAttribute("error", "Invalid date format!");
                request.setAttribute("user", currentUser);
                request.getRequestDispatcher(JSP_PATH).forward(request, response);
                return;
            }
        }

        String error = validateInputs(currentUser, email, phone, oldPassword, newPassword, confirmPassword);
        if (error != null) {
            request.setAttribute("error", error);
            request.setAttribute("user", currentUser);
            request.getRequestDispatcher(JSP_PATH).forward(request, response);
            return;
        }

        if (!hasChanges(currentUser, name, email, phone, gender, dateOfBirth, newPassword)) {
            request.setAttribute("message", "No changes were made!");
            request.setAttribute("user", currentUser);
            request.getRequestDispatcher(JSP_PATH).forward(request, response);
            return;
        }

        if (newPassword != null && !newPassword.isEmpty()) {
            String hashedNewPassword = BCrypt.hashpw(newPassword, BCrypt.gensalt());
            String token = TokenDAO.createToken(currentUser.getUserID(), hashedNewPassword);

            if (token != null) {
                String verifyLink = APP_URL + "/verify?token=" + token;
                EmailUtil.sendVerificationEmail(currentUser.getEmail(), currentUser.getName(), verifyLink);
                request.setAttribute("message", "Verification email sent! Please check your inbox.");
                request.setAttribute("user", currentUser);
                request.getRequestDispatcher(JSP_PATH).forward(request, response);
                return;
            } else {
                request.setAttribute("error", "Failed to create token. Try again.");
                request.setAttribute("user", currentUser);
                request.getRequestDispatcher(JSP_PATH).forward(request, response);
                return;
            }
        }

        User updatedUser = new User(
                currentUser.getUserID(),
                name != null && !name.isEmpty() ? name : currentUser.getName(),
                currentUser.getPassword(),
                currentUser.getRole(),
                email.toLowerCase(),
                phone,
                dateOfBirth != null ? dateOfBirth : currentUser.getDateOfBirth(),
                gender != null ? gender : currentUser.getGender(),
                currentUser.isActive());

        UserDAO userDAO = new UserDAO();
        boolean updated;
        try {
            updated = userDAO.updateUser(updatedUser);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Update failed: " + e.getMessage());
            request.setAttribute("user", currentUser);
            request.getRequestDispatcher(JSP_PATH).forward(request, response);
            return;
        }

        if (updated) {
            session.setAttribute("user", updatedUser);
            request.setAttribute("user", updatedUser);
            request.setAttribute("message", "Profile updated successfully!");
        } else {
            request.setAttribute("error", "Failed to update profile!");
            request.setAttribute("user", currentUser);
        }

        request.getRequestDispatcher(JSP_PATH).forward(request, response);
    }

    private String getTrimmedParameter(HttpServletRequest request, String paramName) {
        String param = request.getParameter(paramName);
        return param != null ? param.trim() : null;
    }

    private String validateInputs(User user, String email, String phone,
            String oldPassword, String newPassword, String confirmPassword) {

        if (email == null || email.isEmpty() || phone == null || phone.isEmpty()) {
            return "Required fields cannot be empty!";
        }

        if (!email.matches(EMAIL_REGEX)) {
            return "Invalid email format!";
        }

        if (!phone.matches(PHONE_REGEX)) {
            return "Invalid phone number format!";
        }

        if (oldPassword != null && !oldPassword.isEmpty()) {
            if (!org.mindrot.jbcrypt.BCrypt.checkpw(oldPassword, user.getPassword())) {
                return "Old password is incorrect!";
            }
            if (newPassword == null || newPassword.isEmpty() || !newPassword.equals(confirmPassword)) {
                return "New password does not match or is empty!";
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

    @Override
    public String getServletInfo() {
        return "Handles user profile display and updates based on new User schema";
    }
}
