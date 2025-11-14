package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import dao.TokenDAO;
import dao.UserDAO;
import models.User;
import org.mindrot.jbcrypt.BCrypt;

public class VerifyCodeServlet extends HttpServlet {

    private static final String VERIFY_JSP = "/view/VerifyCode.jsp";
    private static final String LOGIN_REDIRECT = "Login";
    private static final String PROFILE_REDIRECT = "profile";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("verifyingUserId") == null) {
            response.sendRedirect(LOGIN_REDIRECT);
            return;
        }

        request.getRequestDispatcher(VERIFY_JSP).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("verifyingUserId") == null) {
            response.sendRedirect(LOGIN_REDIRECT);
            return;
        }

        String otp = request.getParameter("otp");
        if (otp == null || otp.trim().isEmpty()) {
            request.setAttribute("error", "Please enter the verification code!");
            request.getRequestDispatcher(VERIFY_JSP).forward(request, response);
            return;
        }

        Integer userId = (Integer) session.getAttribute("verifyingUserId");

        if (userId == null) {
            request.setAttribute("error", "Session expired. Please try again.");
            request.getRequestDispatcher(VERIFY_JSP).forward(request, response);
            return;
        }

        System.out.println("🔍 Verifying OTP: " + otp + " for user ID: " + userId);

        // Verify OTP
        TokenDAO tokenDAO = new TokenDAO();
        boolean isValid = tokenDAO.verifyOTP(userId, otp.trim());

        if (isValid) {
            System.out.println("✅ OTP is valid, getting hashed password...");

            // Get new hashed password
            String hashedNewPassword = tokenDAO.getHashedPasswordFromOTP(otp.trim());

            if (hashedNewPassword != null) {
                System.out.println("✅ Hashed password retrieved: " + hashedNewPassword.substring(0, 20) + "...");

                // Update password - sử dụng phương thức mới
                UserDAO userDAO = new UserDAO();
                boolean updated = userDAO.updatePassword(userId, hashedNewPassword);

                if (updated) {
                    System.out.println("✅ Password updated successfully in database");

                    // Mark OTP as used
                    tokenDAO.markOTPUsed(otp.trim());
                    System.out.println("OTP marked as used");

                    // Invalidate session to logout user
                    if (session != null) {
                        session.invalidate();
                    }
                    System.out.println("Session invalidated");
                    HttpSession newSession = request.getSession(true);

                    System.out.println("Redirecting to login page");
                    response.sendRedirect(LOGIN_REDIRECT);
                    return;
                } else {
                    System.out.println("❌ Failed to update password in database");
                    request.setAttribute("error", "Failed to update password. Please try again.");
                    request.getRequestDispatcher(VERIFY_JSP).forward(request, response);
                }
            } else {
                System.out.println("Could not retrieve hashed password from OTP");
                request.setAttribute("error", "Invalid or expired verification code!");
                request.getRequestDispatcher(VERIFY_JSP).forward(request, response);
            }
        } else {
            System.out.println("OTP is invalid or expired");
            request.setAttribute("error", "Invalid or expired verification code!");
            request.getRequestDispatcher(VERIFY_JSP).forward(request, response);
        }
    }
}