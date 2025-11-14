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

        // Verify OTP
        TokenDAO tokenDAO = new TokenDAO();
        boolean isValid = tokenDAO.verifyOTP(userId, otp.trim());

        if (isValid) {
            // Get new hashed password
            String hashedNewPassword = tokenDAO.getHashedPasswordFromOTP(otp.trim());

            if (hashedNewPassword != null) {
                // Update password
                UserDAO userDAO = new UserDAO();
                boolean updated = userDAO.updatePassword(userId, hashedNewPassword);

                if (updated) {
                    // Mark OTP as used
                    tokenDAO.markOTPUsed(otp.trim());

                    // Invalidate session to logout user
                    if (session != null) {
                        session.invalidate();
                    }

                    // Set success message and redirect to login
                    HttpSession newSession = request.getSession(true);

                    response.sendRedirect(LOGIN_REDIRECT);
                    return;
                } else {
                    request.setAttribute("error", "Failed to update password. Please try again.");
                    request.getRequestDispatcher(VERIFY_JSP).forward(request, response);
                }
            } else {
                request.setAttribute("error", "Invalid or expired verification code!");
                request.getRequestDispatcher(VERIFY_JSP).forward(request, response);
            }
        } else {
            request.setAttribute("error", "Invalid or expired verification code!");
            request.getRequestDispatcher(VERIFY_JSP).forward(request, response);
        }
    }
}