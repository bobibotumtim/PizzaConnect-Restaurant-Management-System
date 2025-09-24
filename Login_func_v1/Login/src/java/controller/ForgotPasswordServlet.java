package controller;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.security.SecureRandom;

public class ForgotPasswordServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("view/ForgotPassword.jsp").forward(request, response);
    }

    

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String user = request.getParameter("user");
        if (user != null) user = user.trim();
        HttpSession session = request.getSession();
        UserDAO dao = new UserDAO();

        // kiểm tra tồn tại
        if (!dao.isUserExists(user)) {
            session.setAttribute("error", "Tài khoản không tồn tại!");
            response.sendRedirect(request.getContextPath() + "/view/ForgotPassword.jsp");
            return;
        }

        // sinh mật khẩu mới tạm thời
        String newPass = generateTempPassword(8);

        boolean ok = dao.resetPassword(user, newPass);

        if (ok) {
            // TODO: gửi email chứa mật khẩu/URL reset nếu bạn có SMTP
            session.setAttribute("success",
                "Mật khẩu mới đã được đặt: " + newPass + ". Vui lòng đăng nhập và đổi lại.");
        } else {
            session.setAttribute("error", "Có lỗi xảy ra, thử lại sau!");
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
}
