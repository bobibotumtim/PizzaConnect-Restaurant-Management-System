package controller;

import java.io.IOException;
import jakarta.servlet.http.*;
import dao.TokenDAO;
import dao.UserDAO;

public class VerifyServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String token = request.getParameter("token");
        if (token == null || token.isEmpty()) {
            response.sendRedirect("error.jsp?msg=missing-token");
            return;
        }

        TokenDAO.TokenInfo info = TokenDAO.getTokenInfo(token);
        if (info != null && TokenDAO.verifyToken(token)) {
            UserDAO userDAO = new UserDAO();
            boolean updated = userDAO.resetPassword(String.valueOf(info.userId), info.newPasswordHash);

            if (updated) {
                TokenDAO.expireToken(token);
                HttpSession session = request.getSession(false);
                if (session != null)
                    session.invalidate();
                response.sendRedirect("Login.jsp?msg=password-updated");
            } else {
                response.sendRedirect("error.jsp?msg=update-failed");
            }
        } else {
            response.sendRedirect("error.jsp?msg=invalid-token");
        }
    }
}
