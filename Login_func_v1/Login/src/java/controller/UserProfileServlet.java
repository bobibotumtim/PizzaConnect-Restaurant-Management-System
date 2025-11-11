package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import models.User;
import models.Customer;
import models.Employee;
import models.Discount;
import models.CustomerDiscount;
import dao.UserDAO;
import dao.CustomerDAO;
import dao.EmployeeDAO;
import dao.DiscountDAO;
import dao.CustomerDiscountDAO;
import dao.OrderDAO;
import dao.TokenDAO;
import utils.EmailUtil;
import java.io.IOException;
import java.sql.Date;
import java.security.SecureRandom;
import java.util.List;
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

            // Load active discounts for all users
            DiscountDAO discountDAO = new DiscountDAO();
            List<Discount> activeDiscounts = discountDAO.getDiscountsByStatus(true, 1, null, null, null, null);
            request.setAttribute("activeDiscounts", activeDiscounts);

        } catch (Exception e) {
            request.setAttribute("error", "Error loading profile data: " + e.getMessage());
        }

        request.setAttribute("user", currentUser);
        request.getRequestDispatcher(PROFILE_JSP_PATH).forward(request, response);
    }

    private void loadCustomerData(HttpServletRequest request, User currentUser) {
        try {
            CustomerDAO customerDAO = new CustomerDAO();
            CustomerDiscountDAO customerDiscountDAO = new CustomerDiscountDAO();
            OrderDAO orderDAO = new OrderDAO();

            // Get customer info
            Customer customer = customerDAO.getCustomerByUserID(currentUser.getUserID());
            if (customer != null) {
                // Get loyalty points and vouchers
                int loyaltyPoints = customerDiscountDAO.getCustomerLoyaltyPoints(customer.getCustomerID());
                List<CustomerDiscount> customerDiscounts = customerDiscountDAO
                        .getCustomerDiscounts(customer.getCustomerID());

                request.setAttribute("loyaltyPoints", loyaltyPoints);
                request.setAttribute("customerDiscounts", customerDiscounts);

                // Get order history with pagination
                int page = 1;
                String pageParam = request.getParameter("orderPage");
                if (pageParam != null && !pageParam.isEmpty()) {
                    page = Integer.parseInt(pageParam);
                }

                int pageSize = 8;
                List<Object[]> orders = orderDAO.getOrdersByCustomerId(customer.getCustomerID(), page, pageSize);
                int totalOrders = orderDAO.getOrdersCountByCustomerId(customer.getCustomerID());
                int totalPages = (int) Math.ceil((double) totalOrders / pageSize);

                request.setAttribute("orders", orders);
                request.setAttribute("orderCurrentPage", page);
                request.setAttribute("orderTotalPages", totalPages);
                request.setAttribute("orderTotalOrders", totalOrders);
            }

        } catch (Exception e) {
            request.setAttribute("error", "Error loading customer data: " + e.getMessage());
        }
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
                currentUser.isActive());

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
    // [Các helper methods giữ nguyên từ code cũ]
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