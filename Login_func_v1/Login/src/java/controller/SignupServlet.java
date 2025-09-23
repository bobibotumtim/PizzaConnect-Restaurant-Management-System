package controller;

import dao.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
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

        HttpSession session = request.getSession();
        UserDAO dao = new UserDAO();

        // Kiểm tra user đã tồn tại
        
        if (dao.isUserExists(username)) {
            session.setAttribute("error", "Tên đăng nhập đã tồn tại!");
            response.sendRedirect("view/Signup.jsp");
            return;
        }

        // Kiểm tra mật khẩu lặp lại
        if (!password.equals(repassword)) {
            session.setAttribute("error", "Mật khẩu không trùng khớp!");
            response.sendRedirect("view/Signup.jsp");
            return;
        }
        User newUser = new User(0, username, mail, password, phone, 2);
        // Thêm user vào CSDL
        boolean inserted = dao.insertUser(newUser);

        if (inserted) {
            session.setAttribute("success", "Đăng ký thành công!");
        } else {
            session.setAttribute("error", "Có lỗi xảy ra khi đăng ký!");
        }

        response.sendRedirect("view/Signup.jsp");
    }
}
