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

        // kiem tra ton tai
        if (!dao.isUserExists(user)) {
            session.setAttribute("error", "Tai khoan khong ton tai!");
            response.sendRedirect(request.getContextPath() + "/view/ForgotPassword.jsp");
            return;
        }

        // sinh mat khau moi tam thoi
        String newPass = generateTempPassword(8);

        boolean ok = dao.resetPassword(user, newPass);

        if (ok) {
            // TODO: gui email chua mat khau/URL reset neu ban co SMTP
            session.setAttribute("success",
                "Mat khau moi da duoc dat: " + newPass + ". Vui long dang nhap va doi lai.");
        } else {
            session.setAttribute("error", "Co loi xay ra, thu lai sau!");
        }

        response.sendRedirect(request.getContextPath() + "/view/ForgotPassword.jsp");
    }

    // sinh chuoi ngau nhien a-zA-Z0-9
    private String generateTempPassword(int len) {
        String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
        SecureRandom rnd = new SecureRandom();
        StringBuilder sb = new StringBuilder(len);
        for (int i = 0; i < len; i++) sb.append(chars.charAt(rnd.nextInt(chars.length())));
        return sb.toString();
    }
}
