package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import models.User;
import dao.UserDAO;
import java.io.IOException;

/**
 * Servlet for handling user profile display and updates.
 */
public class UserProfileServlet extends HttpServlet {
    private static final String PHONE_REGEX = "^0[1-9]\\d{8}$";
    private static final String EMAIL_REGEX = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$";
    private static final String JSP_PATH = "/view/UserProfile.jsp";
    private static final String LOGIN_REDIRECT = "Login";

    /**
     * Handles GET requests to display the user profile page.
     */
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

    /**
     * Handles POST requests to update user profile information.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(LOGIN_REDIRECT);
            return;
        }

        User user = (User) session.getAttribute("user");
        User theUser = new User(user.getUserID(), user.getUsername(), user.getEmail(), user.getPassword(), user.getPhone(), user.getRole());
        String email = getTrimmedParameter(request, "email");
        String phone = getTrimmedParameter(request, "phone");
        String oldPassword = getTrimmedParameter(request, "oldPassword");
        String newPassword = getTrimmedParameter(request, "newPassword");
        String confirmPassword = getTrimmedParameter(request, "confirmPassword");

        // Validate inputs
        String error = validateInputs(theUser, email, phone, oldPassword, newPassword, confirmPassword);
        if (error != null) {
            request.setAttribute("error", error);
            request.setAttribute("user", user);
            request.getRequestDispatcher(JSP_PATH).forward(request, response);
            return;
        }

        // Check for changes
        if (!hasChanges(theUser, email, phone, newPassword)) {
            request.setAttribute("message", "No changes were made!");
            request.setAttribute("user", user);
            request.getRequestDispatcher(JSP_PATH).forward(request, response);
            return;
        }

        // Update user object
        updateUser(theUser, email, phone, newPassword);

        // Save to database
        UserDAO userDAO = new UserDAO();
        boolean updated;
        try {
            updated = userDAO.updateUser(theUser);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Update failed: " + e.getMessage());
            request.setAttribute("user", user);
            request.getRequestDispatcher(JSP_PATH).forward(request, response);
            return;
        }

        // Update session and response
        if (updated) {
            session.setAttribute("user", theUser);
            request.setAttribute("user", theUser);
            request.setAttribute("message", "Profile updated successfully!");
        } else {
            request.setAttribute("user", user);
            request.setAttribute("error", "Failed to update profile!");
        }
        
        request.getRequestDispatcher(JSP_PATH).forward(request, response);
    }

    /**
     * Retrieves and trims a parameter from the request, handling null cases.
     */
    private String getTrimmedParameter(HttpServletRequest request, String paramName) {
        String param = request.getParameter(paramName);
        return param != null ? param.trim() : null;
    }

    /**
     * Validates input fields for user profile update.
     * Returns an error message if validation fails, null otherwise.
     */
    private String validateInputs(User user, String email, String phone, String oldPassword,
                                 String newPassword, String confirmPassword) {
        // Check for empty required fields
        if (email == null || email.isEmpty() || phone == null || phone.isEmpty()) {
            return "Required fields cannot be empty!";
        }

        // Validate email and phone formats
        if (!email.matches(EMAIL_REGEX)) {
            return "Invalid email format!";
        }
        if (!phone.matches(PHONE_REGEX)) {
            return "Invalid phone number!";
        }

        // Validate password if provided
        if (oldPassword != null && !oldPassword.isEmpty()) {
            if (!oldPassword.equals(user.getPassword())) {
                return "Old password is incorrect!";
            }
            if (newPassword == null || newPassword.isEmpty() || !newPassword.equals(confirmPassword)) {
                return "New password does not match or is empty!";
            }
        }

        return null;
    }

    /**
     * Checks if there are any changes in the provided fields compared to the current user data.
     * Returns true if there are changes, false otherwise.
     */
    private boolean hasChanges(User user, String email, String phone, String newPassword) {
        boolean emailChanged = !email.equalsIgnoreCase(user.getEmail());
        boolean phoneChanged = !phone.equals(user.getPhone());
        boolean passwordChanged = newPassword != null && !newPassword.isEmpty();
        return emailChanged || phoneChanged || passwordChanged;
    }

    /**
     * Updates user object with new values.
     */
    private void updateUser(User user, String email, String phone, String newPassword) {
        user.setEmail(email.toLowerCase());
        user.setPhone(phone);
        if (newPassword != null && !newPassword.isEmpty()) {
            user.setPassword(newPassword);
        }
    }

    /**
     * Returns a short description of the servlet.
     */
    @Override
    public String getServletInfo() {
        return "Handles user profile display and updates";
    }
}
