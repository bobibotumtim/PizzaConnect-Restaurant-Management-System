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

        // Get customer ID from user ID
        dao.CustomerDAO customerDAO = new dao.CustomerDAO();
        models.Customer customer = customerDAO.getCustomerByUserID(user.getUserID());
        
        if (customer == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Customer profile not found");
            return;
        }

        OrderDAO orderDAO = new OrderDAO();
        
        // Pagination parameters
        int pageSize = 5; // 5 orders per page
        int currentPage = 1;
        
        String pageParam = request.getParameter("page");
        if (pageParam != null && !pageParam.isEmpty()) {
            try {
                currentPage = Integer.parseInt(pageParam);
                if (currentPage < 1) currentPage = 1;
            } catch (NumberFormatException e) {
                currentPage = 1;
            }
        }
        
        // Get total count for pagination
        int totalOrders = orderDAO.getOrdersCountByCustomerId(customer.getCustomerID());
        int totalPages = (int) Math.ceil((double) totalOrders / pageSize);
        
        // Get paginated orders
        List<Order> orders = orderDAO.getOrdersByCustomerIdWithPagination(
            customer.getCustomerID(), 
            currentPage, 
            pageSize
        );
        
        // Calculate completed orders and total spent (from all orders, not just current page)
        int completedOrders = 0;
        double totalSpent = 0;
        List<Order> allOrders = orderDAO.getOrdersByCustomerId(customer.getCustomerID());
        for (Order order : allOrders) {
            if (order.getStatus() == 3) {
                completedOrders++;
                totalSpent += order.getTotalPrice();
            }
        }
        
        // Debug log
        System.out.println("🔍 OrderHistoryServlet - CustomerID: " + customer.getCustomerID());
        System.out.println("🔍 OrderHistoryServlet - Total Orders: " + totalOrders);
        System.out.println("🔍 OrderHistoryServlet - Current Page: " + currentPage + "/" + totalPages);
        System.out.println("🔍 OrderHistoryServlet - Orders on this page: " + (orders != null ? orders.size() : "null"));
        
        request.setAttribute("orders", orders);
        request.setAttribute("totalOrders", totalOrders);
        request.setAttribute("completedOrders", completedOrders);
        request.setAttribute("totalSpent", totalSpent);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("pageSize", pageSize);
        
        request.getRequestDispatcher("/view/OrderHistory.jsp").forward(request, response);
    }
}
