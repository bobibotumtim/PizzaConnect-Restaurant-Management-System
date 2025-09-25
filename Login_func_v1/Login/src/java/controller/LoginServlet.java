package controller;

import dao.CustomerDAO;
import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import models.*;

public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher("view/Login.jsp").forward(req, resp);
    }
    
    

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String user = request.getParameter("user");
        String pass = request.getParameter("pass");

        UserDAO dao = new UserDAO();
        User account = dao.checkLogin(user, pass);     // null nếu sai

        if (account == null) {
            request.setAttribute("mess", "Tên đăng nhập hoặc mật khẩu không đúng!");
            request.getRequestDispatcher("view/Login.jsp").forward(request, response);
            return;
        }

        HttpSession session = request.getSession();
        session.setAttribute("user", account);   // LƯU duy nhất 1 biến object

        // Chuyển trang tuỳ role
        if (account.getRole() == 1) {
            response.sendRedirect("admin");   // đổi URL admin của bạn
        } else {
            CustomerDAO cdao = new CustomerDAO();
            Customer acc = cdao.getCustomerByUserID(account.getUserID());
            request.setAttribute("customer", acc);
            request.setAttribute("user", account);
            request.getRequestDispatcher("view/Detail.jsp").forward(request, response);
            //response.sendRedirect("home");
        }
    }
}
