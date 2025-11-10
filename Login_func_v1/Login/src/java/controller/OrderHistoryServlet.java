package controller;

import dao.OrderDAO;
import models.Order;
import models.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "OrderHistoryServlet", urlPatterns = {"/order-history"})
public class OrderHistoryServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/Login");
            return;
        }

        User user = (User) session.getAttribute("user");
        request.setAttribute("currentUser", user);
        
        // Only allow customers to access
        if (user.getRole() != 3) { // 3 = Customer role
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Only customers can access order history");
            return;
        }

        OrderDAO orderDAO = new OrderDAO();
        
        // Get customer's orders
        List<Order> orders = orderDAO.getOrdersByCustomerId(user.getUserID());
        
        request.setAttribute("orders", orders);
        request.setAttribute("totalOrders", orders.size());
        
        request.getRequestDispatcher("/view/OrderHistory.jsp").forward(request, response);
    }
}
