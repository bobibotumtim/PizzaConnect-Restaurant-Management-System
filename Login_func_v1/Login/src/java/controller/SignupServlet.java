package controller;

import dao.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import models.Customer;
import models.User;

@WebServlet("/signup")
public class SignupServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        
        // Lay du lieu tu form
        String username = request.getParameter("user");
        String password = request.getParameter("pass");
        String repassword = request.getParameter("repass");
        String phone = request.getParameter("phone");
        String mail = request.getParameter("mail");
        String fullname = request.getParameter("fullname");

        HttpSession session = request.getSession();
        UserDAO userDao = new UserDAO();
        CustomerDAO cusDao = new CustomerDAO();

        // Kiem tra user da ton tai
        if (userDao.isUserExists(username)) {
            session.setAttribute("error", "Ten dang nhap hoac Email/Phone da ton tai!");
            response.sendRedirect("view/Signup.jsp");
            return;
        }

        // Kiem tra mat khau lap lai
        if (!password.equals(repassword)) {
            session.setAttribute("error", "Mat khau khong trung khop!");
            response.sendRedirect("view/Signup.jsp");
            return;
        }

        // Insert User
        User newUser = new User(0, username, mail, password, phone, 3);
        int newUserId = userDao.insertUser(newUser);

        if (newUserId > 0) {
            // Insert Customer
            Customer cus = new Customer(0, fullname, 0, newUserId, username, mail, password, phone, 3);
            boolean cusInserted = cusDao.insertCustomer(cus);

            if (cusInserted) {
                session.setAttribute("success", "Dang ky thanh cong!");
            } else {
                session.setAttribute("error", "User da tao nhung khong luu duoc Customer!");
            }
        } else {
            session.setAttribute("error", "Co loi xay ra khi dang ky User!");
        }

        response.sendRedirect("view/Signup.jsp");
    }
}

