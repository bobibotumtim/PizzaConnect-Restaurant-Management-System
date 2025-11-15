package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.*;
import dao.*;
import models.*;

public class DashboardController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Check authentication - Only Admin allowed
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect("Login");
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        Employee employee = (Employee) session.getAttribute("employee");
        
        // Only Admin (role 1) can access Admin Dashboard
        if (currentUser.getRole() != 1) {
            // Redirect Manager to Manager Dashboard
            if (currentUser.getRole() == 2 && employee != null && "Manager".equalsIgnoreCase(employee.getJobRole())) {
                resp.sendRedirect("manager-dashboard");
                return;
            }
            // Redirect other employees to their dashboard
            else if (currentUser.getRole() == 2) {
                resp.sendRedirect("waiter-dashboard");
                return;
            }
            // Redirect customers to home
            else {
                resp.sendRedirect("home");
                return;
            }
        }

        OrderDAO orderDAO = new OrderDAO();
        
        // Get filter parameter (default: today)
        String filter = req.getParameter("filter");
        if (filter == null || filter.isEmpty()) {
            filter = "today";
        }
        
        // Get all orders
        List<Order> allOrders = orderDAO.getAll();
        
        // Filter orders by time period
        allOrders = filterOrdersByTimePeriod(allOrders, filter);
        
        // Calculate statistics
        int totalOrders = allOrders.size();
        int pendingOrders = 0;
        int processingOrders = 0;
        int completedOrders = 0;
        int cancelledOrders = 0;
        double totalRevenue = 0.0;
        double totalPaid = 0.0;
        double totalUnpaid = 0.0;
        
        // Map to count dishes
        Map<String, Integer> dishCounts = new HashMap<>();
        
        for (Order order : allOrders) {
            // Count by status
            switch(order.getStatus()) {
                case 0: pendingOrders++; break;
                case 1: processingOrders++; break;
                case 2: completedOrders++; break;
                case 3: cancelledOrders++; break;
            }
            
            // Calculate total revenue
            totalRevenue += order.getTotalPrice();
            
            // Calculate paid/unpaid
            if ("Paid".equals(order.getPaymentStatus())) {
                totalPaid += order.getTotalPrice();
            } else {
                totalUnpaid += order.getTotalPrice();
            }
            
            // Count dishes from OrderDetails
            List<OrderDetail> details = order.getDetails();
            if (details != null) {
                for (OrderDetail detail : details) {
                    // Get product name from ProductID instead of SpecialInstructions
                    String dishName = getProductNameById(detail.getProductID());
                    dishCounts.put(dishName, dishCounts.getOrDefault(dishName, 0) + detail.getQuantity());
                }
            }
        }
        
        // Sort dishes by quantity (top 5)
        List<Map.Entry<String, Integer>> topDishes = new ArrayList<>(dishCounts.entrySet());
        topDishes.sort((a, b) -> b.getValue().compareTo(a.getValue()));
        List<Map.Entry<String, Integer>> top5Dishes = topDishes.size() > 5 
            ? topDishes.subList(0, 5) 
            : topDishes;
        
        // Calculate hourly revenue (24h)
        double[] hourlyRevenue = new double[24];
        Calendar cal = Calendar.getInstance();
        for (Order order : allOrders) {
            if (order.getOrderDate() != null) {
                cal.setTime(order.getOrderDate());
                int hour = cal.get(Calendar.HOUR_OF_DAY);
                hourlyRevenue[hour] += order.getTotalPrice();
            }
        }
        
        // Send data to JSP
        req.setAttribute("totalOrders", totalOrders);
        req.setAttribute("pendingOrders", pendingOrders);
        req.setAttribute("processingOrders", processingOrders);
        req.setAttribute("completedOrders", completedOrders);
        req.setAttribute("cancelledOrders", cancelledOrders);
        req.setAttribute("totalRevenue", totalRevenue);
        req.setAttribute("totalPaid", totalPaid);
        req.setAttribute("totalUnpaid", totalUnpaid);
        req.setAttribute("top5Dishes", top5Dishes);
        req.setAttribute("hourlyRevenue", hourlyRevenue);
        req.setAttribute("currentFilter", filter);
        
        req.getRequestDispatcher("/view/Dashboard.jsp").forward(req, resp);
    }
    
    private List<Order> filterOrdersByTimePeriod(List<Order> orders, String filter) {
        if (orders == null || orders.isEmpty()) return orders;
        
        Calendar now = Calendar.getInstance();
        Calendar filterDate = Calendar.getInstance();
        
        switch (filter.toLowerCase()) {
            case "today":
                // Filter orders from today
                filterDate.set(Calendar.HOUR_OF_DAY, 0);
                filterDate.set(Calendar.MINUTE, 0);
                filterDate.set(Calendar.SECOND, 0);
                filterDate.set(Calendar.MILLISECOND, 0);
                break;
                
            case "week":
                // Filter orders from this week (Monday to Sunday)
                filterDate.set(Calendar.DAY_OF_WEEK, Calendar.MONDAY);
                filterDate.set(Calendar.HOUR_OF_DAY, 0);
                filterDate.set(Calendar.MINUTE, 0);
                filterDate.set(Calendar.SECOND, 0);
                filterDate.set(Calendar.MILLISECOND, 0);
                break;
                
            case "month":
                // Filter orders from this month
                filterDate.set(Calendar.DAY_OF_MONTH, 1);
                filterDate.set(Calendar.HOUR_OF_DAY, 0);
                filterDate.set(Calendar.MINUTE, 0);
                filterDate.set(Calendar.SECOND, 0);
                filterDate.set(Calendar.MILLISECOND, 0);
                break;
                
            case "year":
                // Filter orders from this year
                filterDate.set(Calendar.DAY_OF_YEAR, 1);
                filterDate.set(Calendar.HOUR_OF_DAY, 0);
                filterDate.set(Calendar.MINUTE, 0);
                filterDate.set(Calendar.SECOND, 0);
                filterDate.set(Calendar.MILLISECOND, 0);
                break;
                
            default:
                return orders; // No filter
        }
        
        List<Order> filteredOrders = new ArrayList<>();
        for (Order order : orders) {
            if (order.getOrderDate() != null && order.getOrderDate().after(filterDate.getTime())) {
                filteredOrders.add(order);
            }
        }
        
        return filteredOrders;
    }
    
    private String getProductNameById(int productId) {
        try {
            ProductDAO productDAO = new ProductDAO();
            Product product = productDAO.getBaseProductById(productId);
            if (product != null) {
                return product.getProductName();
            }
        } catch (Exception e) {
            System.err.println("Error getting product name for ID " + productId + ": " + e.getMessage());
        }
        return "Unknown Product";
    }
}
