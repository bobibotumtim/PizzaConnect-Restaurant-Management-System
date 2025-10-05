package controller;


import dao.UserDAO;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import models.*;


/**
 *
 * @author duongtanki
 */
@WebServlet(name = "EditUserServlet", urlPatterns = {"/editUser"})

public class EditUserServlet extends HttpServlet {
    private UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Lay userID tu query string (vi du: editUser?userID=1)
        String idParam = request.getParameter("userID");
        if (idParam == null || idParam.isEmpty()) {
            response.getWriter().println("UserID khong hop le.");
            return;
        }

        try {
            int userID = Integer.parseInt(idParam);
            User user = userDAO.getUserId(userID);

            if (user != null) {
                request.setAttribute("user", user);
                RequestDispatcher rd = request.getRequestDispatcher("view/EditUser.jsp");
                rd.forward(request, response);
            } else {
                response.getWriter().println("Khong tim thay user.");
            }
        } catch (NumberFormatException e) {
            response.getWriter().println("UserID phai la so.");
        }
    }
}
