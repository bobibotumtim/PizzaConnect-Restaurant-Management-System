/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;


import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import models.*;

/**
 *
 * @author duongtanki
 */
@WebServlet(name = "UpdateUserServlet", urlPatterns = {"/updateUser"})
public class UpdateUserServlet extends HttpServlet {
    private UserDAO userDAO = new UserDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        int userID = Integer.parseInt(request.getParameter("userID"));
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String phone = request.getParameter("phone");
        int role = Integer.parseInt(request.getParameter("role"));

        // lấy username từ DB hoặc request (tùy bạn lưu thế nào)
        String username = request.getParameter("username");

        User user = new User(userID, username, email, password, phone, role);

        boolean updated = userDAO.updateUser(user);
        if (updated) {
            // quay lại trang chi tiết
            request.setAttribute("user", user);
            request.getRequestDispatcher("view/Detail.jsp").forward(request, response);
        } else {
            response.getWriter().println("Update thất bại!");
        }
    }
}

