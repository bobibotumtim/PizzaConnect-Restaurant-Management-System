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

        String phone = request.getParameter("phone");
        String pass = request.getParameter("pass");

        UserDAO dao = new UserDAO();
        User user = null;
        try {
            user = dao.checkLogin(phone, pass);   
        } catch (Exception e) {
            request.setAttribute("mess", "We are unable to process your login at the moment. Please try again later.");
            request.getRequestDispatcher("view/Login.jsp").forward(request, response);
            return;
        }

        if (user == null) {
            request.setAttribute("mess", "Tên đăng nhập hoặc mật khẩu không đúng!");
            request.getRequestDispatcher("view/Login.jsp").forward(request, response);
            return;
        }

        HttpSession session = request.getSession();
        session.setAttribute("user", user); 

        // Chuyển trang tuỳ role
        if (user.getRole() == 1) {
            response.sendRedirect("dashboard"); 
        } else {
            CustomerDAO cdao = new CustomerDAO();
            {
                Customer acc = cdao.getCustomerByUserID(user.getUserID());
                if (acc == null) { 
                    request.setAttribute("error",
                            "No profile information found. Please contact support or complete your profile.");
                    request.getRequestDispatcher("view/Detail.jsp").forward(request, response);
                    return;
                }
                request.setAttribute("customer", acc);
                request.setAttribute("user", user);
                request.getRequestDispatcher("view/Home.jsp").forward(request, response);
            }
        }
    }

}
