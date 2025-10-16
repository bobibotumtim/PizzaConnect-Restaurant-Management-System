package controller;

import dao.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.Date;
import models.Customer;
import models.User;

@WebServlet("/signup")
public class SignupServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 🔹 Lấy dữ liệu từ form
        String fullname = request.getParameter("fullname");
        String password = request.getParameter("pass");
        String repassword = request.getParameter("repass");
        String phone = request.getParameter("phone");
        String email = request.getParameter("mail");
        String gender = request.getParameter("gender");
        String birthdateStr = request.getParameter("birthdate");

        HttpSession session = request.getSession();
        UserDAO userDao = new UserDAO();
        CustomerDAO cusDao = new CustomerDAO();

        // 🔹 Kiểm tra user đã tồn tại (dựa vào email hoặc phone)
        if (userDao.isUserExists(email)) {
            session.setAttribute("error", "Email đã tồn tại!");
            response.sendRedirect("view/Signup.jsp");
            return;
        }
        
        if (userDao.isUserExists(phone)) {
            session.setAttribute("error", "Số điện thoại đã tồn tại!");
            response.sendRedirect("view/Signup.jsp");
            return;
        }

        // 🔹 Kiểm tra mật khẩu khớp
        if (!password.equals(repassword)) {
            session.setAttribute("error", "Mật khẩu không trùng khớp!");
            response.sendRedirect("view/Signup.jsp");
            return;
        }

        // 🔹 Kiểm tra định dạng ngày sinh
        Date birthdate = null;
        try {
            if (birthdateStr != null && !birthdateStr.trim().isEmpty()) {
                birthdate = Date.valueOf(birthdateStr);
            }
        } catch (IllegalArgumentException e) {
            session.setAttribute("error", "Ngày sinh không hợp lệ!");
            response.sendRedirect("view/Signup.jsp");
            return;
        }

        // 🔹 Tạo đối tượng User (role=3: Customer, isActive=true)
        User newUser = new User(
                0,
                fullname,
                password,
                3,             // Role: Customer
                email,
                phone,
                birthdate,
                gender,
                true
        );

        // 🔹 Lưu User vào DB
        int newUserId = userDao.insertUser(newUser);

        if (newUserId > 0) {
            // 🔹 Tạo bản ghi Customer tương ứng
            Customer cus = new Customer( 0, newUserId, fullname, email, phone, 3 );

            boolean cusInserted = cusDao.insertCustomer(cus);

            if (cusInserted) {
                session.setAttribute("success", "Đăng ký thành công!");
            } else {
                session.setAttribute("error", "User đã tạo nhưng không thể lưu Customer!");
            }
        } else {
            session.setAttribute("error", "Có lỗi xảy ra khi đăng ký tài khoản!");
        }

        response.sendRedirect("view/Signup.jsp");
    }
}
