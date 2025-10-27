package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import dao.TokenDAO;
import dao.UserDAO;
import models.User;

public class VerifyCodeServlet extends HttpServlet {

    // Forward path của JSP (relative với web content root)
    private static final String VERIFY_JSP = "/view/VerifyCode.jsp";
    private static final String PROFILE_JSP = "/view/UserProfile.jsp";
    private static final String LOGIN_REDIRECT = "Login";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(LOGIN_REDIRECT); // nếu chưa login → redirect
            return;
        }

        // forward tới VerifyCode.jsp
        request.getRequestDispatcher(VERIFY_JSP).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(LOGIN_REDIRECT);
            return;
        }

        String otp = request.getParameter("otp");
        if (otp == null || otp.isEmpty()) {
            request.setAttribute("error", "Please enter the verification code!");
            request.getRequestDispatcher(VERIFY_JSP).forward(request, response);
            return;
        }

        User user = (User) session.getAttribute("user");
        // Lấy mật khẩu tạm được lưu khi gửi OTP
        String pendingPassword = (String) session.getAttribute("pendingPassword");

        if (pendingPassword == null) {
            request.setAttribute("error", "No pending password change found!");
            request.getRequestDispatcher(VERIFY_JSP).forward(request, response);
            return;
        }

        // Kiểm tra OTP
        TokenDAO tokenDAO = new TokenDAO();
        boolean isValid = tokenDAO.verifyOTP(user.getUserID(), otp);

        if (isValid) {
            // Cập nhật mật khẩu mới
            UserDAO userDAO = new UserDAO();
            boolean updated = userDAO.updatePassword(user.getUserID(), pendingPassword);

            if (updated) {
                user.setPassword(pendingPassword);
                session.setAttribute("user", user);
                session.removeAttribute("pendingPassword");
                request.setAttribute("message", "Password changed successfully!");
                request.getRequestDispatcher(PROFILE_JSP).forward(request, response);
            } else {
                request.setAttribute("error", "Failed to update password. Try again later.");
                request.getRequestDispatcher(VERIFY_JSP).forward(request, response);
            }
        } else {
            request.setAttribute("error", "Invalid or expired verification code!");
            request.getRequestDispatcher(VERIFY_JSP).forward(request, response);
        }
    }
}
