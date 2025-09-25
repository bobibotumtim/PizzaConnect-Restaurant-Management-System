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
        
        // Lấy dữ liệu từ form
        String username = request.getParameter("user");
        String password = request.getParameter("pass");
        String repassword = request.getParameter("repass");
        String phone = request.getParameter("phone");
        String mail = request.getParameter("mail");
        String fullname = request.getParameter("fullname");

        HttpSession session = request.getSession();
        UserDAO userDao = new UserDAO();
        CustomerDAO cusDao = new CustomerDAO();

        // Kiểm tra user đã tồn tại
        if (userDao.isUserExists(username)) {
            session.setAttribute("error", "Tên đăng nhập hoặc Email/Phone đã tồn tại!");
            response.sendRedirect("view/Signup.jsp");
            return;
        }

        // Kiểm tra mật khẩu lặp lại
        if (!password.equals(repassword)) {
            session.setAttribute("error", "Mật khẩu không trùng khớp!");
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
                session.setAttribute("success", "Đăng ký thành công!");
            } else {
                session.setAttribute("error", "User đã tạo nhưng không lưu được Customer!");
            }
        } else {
            session.setAttribute("error", "Có lỗi xảy ra khi đăng ký User!");
        }

        response.sendRedirect("view/Signup.jsp");
    }
}

