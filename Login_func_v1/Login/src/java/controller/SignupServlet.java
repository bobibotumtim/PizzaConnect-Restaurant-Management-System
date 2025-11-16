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
        
        // 🔹 Server-side validation
        
        // Validate fullname
        if (fullname == null || fullname.trim().isEmpty()) {
            session.setAttribute("error", "Full name is required!");
            response.sendRedirect("view/Signup.jsp");
            return;
        }
        fullname = fullname.trim();
        if (fullname.length() < 2 || fullname.length() > 100) {
            session.setAttribute("error", "Full name must be 2-100 characters!");
            response.sendRedirect("view/Signup.jsp");
            return;
        }
        
        // Validate email
        if (email == null || email.trim().isEmpty()) {
            session.setAttribute("error", "Email is required!");
            response.sendRedirect("view/Signup.jsp");
            return;
        }
        email = email.trim().toLowerCase();
        if (!email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")) {
            session.setAttribute("error", "Invalid email format!");
            response.sendRedirect("view/Signup.jsp");
            return;
        }
        
        // Validate phone (optional but if provided must be valid)
        if (phone != null && !phone.trim().isEmpty()) {
            phone = phone.trim();
            if (!phone.matches("^[0-9]{10}$")) {
                session.setAttribute("error", "Phone number must be 10 digits!");
                response.sendRedirect("view/Signup.jsp");
                return;
            }
        }
        
        // Validate password
        if (password == null || password.isEmpty()) {
            session.setAttribute("error", "Password is required!");
            response.sendRedirect("view/Signup.jsp");
            return;
        }
        if (password.length() < 8) {
            session.setAttribute("error", "Password must be at least 8 characters!");
            response.sendRedirect("view/Signup.jsp");
            return;
        }
        if (password.length() > 50) {
            session.setAttribute("error", "Password cannot exceed 50 characters!");
            response.sendRedirect("view/Signup.jsp");
            return;
        }
        // Strong password validation: must contain uppercase, lowercase, and digit
        if (!password.matches("^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).{8,}$")) {
            session.setAttribute("error", "Password must contain at least one uppercase letter, one lowercase letter, and one number!");
            response.sendRedirect("view/Signup.jsp");
            return;
        }
        
        // Validate password match
        if (repassword == null || !password.equals(repassword)) {
            session.setAttribute("error", "Passwords do not match!");
            response.sendRedirect("view/Signup.jsp");
            return;
        }
        
        // Validate gender
        if (gender == null || gender.trim().isEmpty()) {
            session.setAttribute("error", "Please select gender!");
            response.sendRedirect("view/Signup.jsp");
            return;
        }
        if (!gender.equals("Male") && !gender.equals("Female") && !gender.equals("Other")) {
            session.setAttribute("error", "Invalid gender selection!");
            response.sendRedirect("view/Signup.jsp");
            return;
        }
        
        // Validate birthdate
        if (birthdateStr == null || birthdateStr.trim().isEmpty()) {
            session.setAttribute("error", "Please enter date of birth!");
            response.sendRedirect("view/Signup.jsp");
            return;
        }

        UserDAO userDao = new UserDAO();
        CustomerDAO cusDao = new CustomerDAO();

        // Check if user already exists (by email or phone)
        if (userDao.isUserExists(email)) {
            session.setAttribute("error", "Email is already registered!");
            response.sendRedirect("view/Signup.jsp");
            return;
        }
        
        if (phone != null && !phone.isEmpty() && userDao.isUserExists(phone)) {
            session.setAttribute("error", "Phone number is already registered!");
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
