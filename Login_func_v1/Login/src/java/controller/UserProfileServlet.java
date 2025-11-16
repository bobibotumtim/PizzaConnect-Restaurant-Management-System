package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import models.User;
import models.Customer;
import models.Discount;
import models.Employee;
import dao.UserDAO;
import dao.CustomerDAO;
import dao.EmployeeDAO;
import dao.DiscountDAO;
import dao.TokenDAO;
import utils.EmailUtil;
import java.io.IOException;
import java.sql.*;
import java.security.SecureRandom;
import java.util.HashMap;
import java.util.Map;
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

        User currentUser = (User) session.getAttribute("user");

        try {
            // Clear any previous messages and errors
            clearSessionMessages(request);

            // Load additional data based on user role
            if (currentUser.getRole() == 2) { // Employee
                EmployeeDAO employeeDAO = new EmployeeDAO();
                Employee employee = employeeDAO.getEmployeeByUserID(currentUser.getUserID());
                if (employee != null) {
                    request.setAttribute("employeeRole", employee.getRole());
                }
            }

            if (currentUser.getRole() == 3) { // Customer
                loadCustomerData(request, currentUser);
            }

        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error loading profile data: " + e.getMessage());
        }

        request.setAttribute("user", currentUser);
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
        String action = request.getParameter("action");

        // Clear previous messages
        clearSessionMessages(request);

        if ("updateProfile".equals(action)) {
            updateProfile(request, response, currentUser, session);
        } else if ("changePassword".equals(action)) {
            changePassword(request, response, currentUser, session);
        } else {
            setFieldError(request, "general", "Invalid action requested");
            forwardToProfile(request, response, currentUser, "personal");
        }
    }

    private void updateProfile(HttpServletRequest request, HttpServletResponse response,
            User currentUser, HttpSession session)
            throws ServletException, IOException {

        UserDAO userDAO = new UserDAO();

        // Get parameters
        String name = getTrimmedParameter(request, "name");
        String email = getTrimmedParameter(request, "email");
        String phone = getTrimmedParameter(request, "phone");
        String gender = getTrimmedParameter(request, "gender");
        String dobStr = getTrimmedParameter(request, "dateOfBirth");

        // Validate inputs with detailed error messages
        Map<String, String> fieldErrors = validateProfileInputs(currentUser, name, email, phone, gender, userDAO);

        if (!fieldErrors.isEmpty()) {
            request.setAttribute("fieldErrors", fieldErrors);
            forwardToProfile(request, response, currentUser, "personal");
            return;
        }

        // Parse date of birth
        Date dateOfBirth = null;
        if (dobStr != null && !dobStr.isEmpty()) {
            try {
                dateOfBirth = Date.valueOf(dobStr);

                // Validate age (at least 13 years old)
                java.util.Date minDate = new java.util.Date(
                        System.currentTimeMillis() - (13L * 365 * 24 * 60 * 60 * 1000));
                if (dateOfBirth.after(minDate)) {
                    setFieldError(request, "dateOfBirth", "You must be at least 13 years old");
                    forwardToProfile(request, response, currentUser, "personal");
                    return;
                }
            } catch (IllegalArgumentException e) {
                setFieldError(request, "dateOfBirth", "Invalid date format. Please use YYYY-MM-DD format");
                forwardToProfile(request, response, currentUser, "personal");
                return;
            }
        }

        // Check if any changes were made
        if (!hasProfileChanges(currentUser, name, email, phone, gender, dateOfBirth)) {
            request.setAttribute("successMessage", "No changes were made to your profile");
            forwardToProfile(request, response, currentUser, "personal");
            return;
        }

        // Create updated user object - Use current password properly
        User updatedUser = new User(
                currentUser.getUserID(),
                name,
                currentUser.getPassword(), // Keep current hashed password
                currentUser.getRole(),
                email.toLowerCase(),
                phone,
                dateOfBirth != null ? dateOfBirth : currentUser.getDateOfBirth(),
                gender,
                currentUser.isActive());

        // Save updates using proper update method
        try {
            boolean updated = userDAO.updateUserProfile(updatedUser);
            if (updated) {
                // Refresh user data from database
                User refreshedUser = userDAO.getUserById(currentUser.getUserID());
                if (refreshedUser != null) {
                    session.setAttribute("user", refreshedUser);
                    request.setAttribute("successMessage", "Your profile has been updated successfully!");
                } else {
                    setFieldError(request, "general", "Failed to refresh user data after update");
                }
            } else {
                setFieldError(request, "general", "Failed to update profile. Please try again.");
            }
        } catch (Exception e) {
            setFieldError(request, "general", "Update failed: " + e.getMessage());
        }

        forwardToProfile(request, response, currentUser, "personal");
    }

    private void changePassword(HttpServletRequest request, HttpServletResponse response,
            User currentUser, HttpSession session)
            throws ServletException, IOException {

        // Get password parameters
        String oldPassword = getTrimmedParameter(request, "oldPassword");
        String newPassword = getTrimmedParameter(request, "newPassword");
        String confirmPassword = getTrimmedParameter(request, "confirmPassword");

        // Validate password inputs with detailed error messages
        Map<String, String> fieldErrors = validatePasswordInputs(currentUser, oldPassword, newPassword,
                confirmPassword);

        if (!fieldErrors.isEmpty()) {
            request.setAttribute("fieldErrors", fieldErrors);
            request.setAttribute("passwordError", "Please correct the errors below");
            forwardToProfile(request, response, currentUser, "password");
            return;
        }

        // Generate OTP and send email
        String otpCode = generateOTP(6);
        String hashedNewPassword = BCrypt.hashpw(newPassword, BCrypt.gensalt());

        // Save OTP and hashed password temporarily
        TokenDAO tokenDAO = new TokenDAO();
        boolean otpSaved = tokenDAO.saveOTP(currentUser.getUserID(), otpCode, hashedNewPassword);

        if (!otpSaved) {
            setFieldError(request, "general", "Failed to generate verification code. Please try again.");
            forwardToProfile(request, response, currentUser, "password");
            return;
        }

        try {
            String subject = "Password Change Verification Code";
            String content = String.format(
                    """
                            Hello %s,

                            You have requested to change your password.

                            Your verification code is: %s
                            This code will expire in 5 minutes.

                            If you did not request this password change, please ignore this email and contact support immediately.

                            Best regards,
                            Pizza Store Team
                            """,
                    currentUser.getName(), otpCode);

            boolean emailSent = EmailUtil.sendEmail(currentUser.getEmail(), subject, content);

            if (emailSent) {
                // Store ONLY user ID in session for verification (not the entire user object)
                session.setAttribute("verifyingUserId", currentUser.getUserID());
                response.sendRedirect("verifyCode");
                return;
            } else {
                setFieldError(request, "general",
                        "Failed to send verification email. Please check your email address and try again.");
            }

        } catch (Exception e) {
            setFieldError(request, "general", "System error while sending verification email: " + e.getMessage());
        }

        forwardToProfile(request, response, currentUser, "password");
    }

    // -------------------- Validation Methods --------------------

    private Map<String, String> validateProfileInputs(User user, String name, String email,
            String phone, String gender, UserDAO userDAO) {
        Map<String, String> errors = new HashMap<>();

        // Name validation
        if (name == null || name.trim().isEmpty()) {
            errors.put("name", "Full name is required");
        } else if (name.trim().length() < 2) {
            errors.put("name", "Name must be at least 2 characters long");
        } else if (name.trim().length() > 100) {
            errors.put("name", "Name cannot exceed 100 characters");
        }

        // Email validation
        if (email == null || email.trim().isEmpty()) {
            errors.put("email", "Email address is required");
        } else if (!email.matches(EMAIL_REGEX)) {
            errors.put("email", "Please enter a valid email address (e.g., example@gmail.com)");
        } else if (userDAO.emailExists(email) && !email.equalsIgnoreCase(user.getEmail())) {
            errors.put("email", "This email address is already registered. Please use a different email.");
        }

        // Phone validation
        if (phone == null || phone.trim().isEmpty()) {
            errors.put("phone", "Phone number is required");
        } else if (!phone.matches(PHONE_REGEX)) {
            errors.put("phone", "Please enter a valid 10-digit phone number starting with 0 (e.g., 0912345678)");
        }

        // Gender validation
        if (gender == null || gender.trim().isEmpty()) {
            errors.put("gender", "Please select your gender");
        } else if (!gender.matches("^(Male|Female|Other)$")) {
            errors.put("gender", "Please select a valid gender option");
        }

        return errors;
    }

    private Map<String, String> validatePasswordInputs(User user, String oldPassword,
            String newPassword, String confirmPassword) {
        Map<String, String> errors = new HashMap<>();

        // Current password validation
        if (oldPassword == null || oldPassword.isEmpty()) {
            errors.put("oldPassword", "Please enter current password");
        } else if (oldPassword.length() < 8) {
            errors.put("oldPassword", "Password must be at least 8 characters");
        } else if (!BCrypt.checkpw(oldPassword, user.getPassword())) {
            errors.put("oldPassword", "Current password is incorrect");
        }

        // New password validation
        if (newPassword == null || newPassword.isEmpty()) {
            errors.put("newPassword", "Please enter new password");
        } else if (newPassword.length() < 8) {
            errors.put("newPassword", "New password must be at least 8 characters");
        } else if (newPassword.length() > 50) {
            errors.put("newPassword", "Password cannot exceed 50 characters");
        } else if (!newPassword.matches("^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).{8,}$")) {
            errors.put("newPassword", "Password must contain at least one uppercase letter, one lowercase letter, and one number");
        } else if (oldPassword != null && !oldPassword.isEmpty() && BCrypt.checkpw(newPassword, user.getPassword())) {
            errors.put("newPassword", "New password must be different from current password");
        }

        // Confirm password validation
        if (confirmPassword == null || confirmPassword.isEmpty()) {
            errors.put("confirmPassword", "Please confirm new password");
        } else if (!newPassword.equals(confirmPassword)) {
            errors.put("confirmPassword", "Passwords do not match");
        }

        return errors;
    }

    private boolean hasProfileChanges(User user, String name, String email, String phone,
            String gender, Date dateOfBirth) {
        boolean nameChanged = name != null && !name.equals(user.getName());
        boolean emailChanged = email != null && !email.equalsIgnoreCase(user.getEmail());
        boolean phoneChanged = phone != null && !phone.equals(user.getPhone());
        boolean genderChanged = gender != null && !gender.equals(user.getGender());
        boolean dobChanged = dateOfBirth != null &&
                (user.getDateOfBirth() == null || !dateOfBirth.equals(user.getDateOfBirth()));

        return nameChanged || emailChanged || phoneChanged || genderChanged || dobChanged;
    }

    // -------------------- Helper Methods --------------------

    private String getTrimmedParameter(HttpServletRequest request, String paramName) {
        String param = request.getParameter(paramName);
        return (param != null) ? param.trim() : null;
    }

    private String generateOTP(int length) {
        SecureRandom random = new SecureRandom();
        String chars = "0123456789";
        StringBuilder otp = new StringBuilder(length);
        for (int i = 0; i < length; i++) {
            otp.append(chars.charAt(random.nextInt(chars.length())));
        }
        return otp.toString();
    }

    private void setFieldError(HttpServletRequest request, String field, String message) {
        @SuppressWarnings("unchecked")
        Map<String, String> fieldErrors = (Map<String, String>) request.getAttribute("fieldErrors");
        if (fieldErrors == null) {
            fieldErrors = new HashMap<>();
            request.setAttribute("fieldErrors", fieldErrors);
        }
        fieldErrors.put(field, message);
    }

    private void clearSessionMessages(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.removeAttribute("successMessage");
            session.removeAttribute("errorMessage");
            session.removeAttribute("passwordSuccess");
            session.removeAttribute("passwordError");
        }

        // Clear request attributes
        request.removeAttribute("successMessage");
        request.removeAttribute("errorMessage");
        request.removeAttribute("passwordSuccess");
        request.removeAttribute("passwordError");
        request.removeAttribute("fieldErrors");
    }

    private void forwardToProfile(HttpServletRequest request, HttpServletResponse response, User user, String activeTab)
            throws ServletException, IOException {
        request.setAttribute("user", user);
        request.setAttribute("activeTab", activeTab);

        // Reload customer data if needed
        if (user.getRole() == 3) {
            loadCustomerData(request, user);
        }

        request.getRequestDispatcher(PROFILE_JSP_PATH).forward(request, response);
    }

    private void loadCustomerData(HttpServletRequest request, User currentUser) {
        try {
            CustomerDAO customerDAO = new CustomerDAO();
            DiscountDAO discountDAO = new DiscountDAO();

            // Get customer info and loyalty points
            Customer customer = customerDAO.getCustomerByUserID(currentUser.getUserID());
            if (customer != null) {
                int loyaltyPoints = customer.getLoyaltyPoint();
                request.setAttribute("loyaltyPoints", loyaltyPoints);

                // Get loyalty discount rate
                Discount discount = discountDAO.getLoyaltyDiscount();
                double rate = (discount != null) ? discount.getValue() : 1000.0;

                // Calculate loyalty value in VND
                double loyaltyValue = loyaltyPoints * rate;
                request.setAttribute("loyaltyValue", loyaltyValue);
            }

        } catch (Exception e) {
            System.err.println("Error loading customer data: " + e.getMessage());
        }
    }

    @Override
    public String getServletInfo() {
        return "Handles user profile updates and password change verification via OTP";
    }
}