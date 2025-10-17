package controller;

import dao.UserDAO;
import dao.OrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import models.User;

@WebServlet(name = "DashboardServlet", urlPatterns = {"/dashboard"})
public class DashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Kiểm tra session và quyền admin
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("Login");
            return;
        }
        
        User user = (User) session.getAttribute("user");
        if (user.getRole() != 1) { // 1 = admin role
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied. Admin role required.");
            return;
        }
        
        // Lấy thống kê
        UserDAO userDAO = new UserDAO();
        OrderDAO orderDAO = new OrderDAO();
        
        int totalUsers = userDAO.getAllUsers().size();
        int totalOrders = orderDAO.countAllOrders();
        
        request.setAttribute("currentUser", user);
        request.setAttribute("totalOrders", totalOrders);
        request.setAttribute("totalUsers", totalUsers);
        
        request.getRequestDispatcher("view/Dashboard.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Redirect to GET method
        doGet(request, response);
    }
}

