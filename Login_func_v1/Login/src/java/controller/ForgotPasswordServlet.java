package controller;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.security.SecureRandom;
import java.util.concurrent.TimeUnit;
import utils.EmailService;

public class ForgotPasswordServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        request.getRequestDispatcher("view/ForgotPassword.jsp").forward(request, response);
    }

    

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        UserDAO dao = new UserDAO();

        String action = request.getParameter("action");
        if (action == null) action = "";

        if ("request_otp".equals(action)) {
            String identifier = request.getParameter("identifier");
            if (identifier != null) identifier = identifier.trim();

            if (identifier == null || identifier.isEmpty()) {
                session.setAttribute("error", "Vui lòng nhập email hoặc số điện thoại.");
                response.sendRedirect(request.getContextPath() + "/view/ForgotPassword.jsp");
                return;
            }

            if (!dao.isUserExists(identifier)) {
                session.setAttribute("error", "Tài khoản không tồn tại!");
                response.sendRedirect(request.getContextPath() + "/view/ForgotPassword.jsp");
                return;
            }

            Integer userId = dao.findUserIdByIdentifier(identifier);
            if (userId == null) {
                session.setAttribute("error", "Không tìm thấy tài khoản phù hợp.");
                response.sendRedirect(request.getContextPath() + "/view/ForgotPassword.jsp");
                return;
            }

            String otp = generateOtp6Digits();
            long expireAt = System.currentTimeMillis() + TimeUnit.MINUTES.toMillis(5);

            if (isEmail(identifier)) {
                boolean sent = EmailService.sendOtp(getServletContext(), identifier, otp);
                if (sent) {
                    session.setAttribute("otpPhase", Boolean.TRUE);
                    session.setAttribute("otpUserId", userId);
                    session.setAttribute("otpCode", otp);
                    session.setAttribute("otpExpireAt", expireAt);
                    session.setAttribute("otpIdentifier", identifier);
                    session.setAttribute("success", "Đã gửi mã OTP tới email của bạn. Vui lòng kiểm tra hộp thư.");
                } else {
                    clearOtpSession(session);
                    session.setAttribute("error", "Không thể gửi OTP qua email lúc này. Thử lại sau.");
                    response.sendRedirect(request.getContextPath() + "/view/ForgotPassword.jsp");
                    return;
                }
            } else {
                // Chưa tích hợp SMS gateway: hiển thị OTP tạm thời cho số điện thoại
                session.setAttribute("otpPhase", Boolean.TRUE);
                session.setAttribute("otpUserId", userId);
                session.setAttribute("otpCode", otp);
                session.setAttribute("otpExpireAt", expireAt);
                session.setAttribute("otpIdentifier", identifier);
                session.setAttribute("success", "Đã gửi mã OTP tới số điện thoại của bạn. (Tạm thời hiển thị OTP: " + otp + ")");
            }

            response.sendRedirect(request.getContextPath() + "/view/ForgotPassword.jsp");
            return;
        }

        if ("verify_otp".equals(action)) {
            String inputOtp = request.getParameter("otp");
            String newPassword = request.getParameter("newPassword");
            String confirmPassword = request.getParameter("confirmPassword");

            Object otpCodeObj = session.getAttribute("otpCode");
            Object otpExpireAtObj = session.getAttribute("otpExpireAt");
            Object otpUserIdObj = session.getAttribute("otpUserId");

            if (otpCodeObj == null || otpExpireAtObj == null || otpUserIdObj == null) {
                session.setAttribute("error", "Phiên xác thực OTP không hợp lệ hoặc đã hết hạn.");
                response.sendRedirect(request.getContextPath() + "/view/ForgotPassword.jsp");
                return;
            }

            String otpCode = String.valueOf(otpCodeObj);
            long expireAt = (long) otpExpireAtObj;
            int userId = (int) otpUserIdObj;

            if (System.currentTimeMillis() > expireAt) {
                clearOtpSession(session);
                session.setAttribute("error", "Mã OTP đã hết hạn. Vui lòng yêu cầu lại.");
                response.sendRedirect(request.getContextPath() + "/view/ForgotPassword.jsp");
                return;
            }

            if (inputOtp == null || !inputOtp.trim().equals(otpCode)) {
                session.setAttribute("error", "Mã OTP không chính xác.");
                response.sendRedirect(request.getContextPath() + "/view/ForgotPassword.jsp");
                return;
            }

            if (newPassword == null || newPassword.length() < 6) {
                session.setAttribute("error", "Mật khẩu mới phải có ít nhất 6 ký tự.");
                response.sendRedirect(request.getContextPath() + "/view/ForgotPassword.jsp");
                return;
            }
            if (!newPassword.equals(confirmPassword)) {
                session.setAttribute("error", "Xác nhận mật khẩu không khớp.");
                response.sendRedirect(request.getContextPath() + "/view/ForgotPassword.jsp");
                return;
            }

            boolean ok = dao.resetPasswordByUserId(userId, newPassword);
            clearOtpSession(session);
            if (ok) {
                session.setAttribute("success", "Đổi mật khẩu thành công. Vui lòng đăng nhập lại.");
            } else {
                session.setAttribute("error", "Có lỗi xảy ra, thử lại sau!");
            }
            response.sendRedirect(request.getContextPath() + "/view/ForgotPassword.jsp");
            return;
        }

        response.sendRedirect(request.getContextPath() + "/view/ForgotPassword.jsp");
    }

    // sinh chuỗi ngẫu nhiên a‑zA‑Z0‑9
    private String generateTempPassword(int len) {
        String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
        SecureRandom rnd = new SecureRandom();
        StringBuilder sb = new StringBuilder(len);
        for (int i = 0; i < len; i++) sb.append(chars.charAt(rnd.nextInt(chars.length())));
        return sb.toString();
    }

    private String generateOtp6Digits() {
        SecureRandom rnd = new SecureRandom();
        int val = 100000 + rnd.nextInt(900000);
        return String.valueOf(val);
    }

    private boolean isEmail(String input) {
        return input != null && input.contains("@") && input.contains(".");
    }

    private void clearOtpSession(HttpSession session) {
        session.removeAttribute("otpPhase");
        session.removeAttribute("otpUserId");
        session.removeAttribute("otpCode");
        session.removeAttribute("otpExpireAt");
        session.removeAttribute("otpIdentifier");
    }
}
