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
                    String dishName = extractDishName(detail.getSpecialInstructions());
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
    
    private String extractDishName(String specialInstructions) {
        if (specialInstructions == null) return "Unknown";
        
        // Extract from "Type: Pepperoni" -> "Pepperoni"
        if (specialInstructions.startsWith("Type: ") || specialInstructions.startsWith("Loại: ")) {
            String[] parts = specialInstructions.split(" - ");
            String dishPart = parts[0].replace("Type: ", "").replace("Loại: ", "").trim();
            return dishPart;
        }
        
        return specialInstructions;
    }
}
