package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.*;
import dao.*;
import models.*;

@WebServlet("/test-dashboard-data")
public class TestDashboardDataServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        resp.setContentType("text/html;charset=UTF-8");
        PrintWriter out = resp.getWriter();
        
        out.println("<html><head><title>Test Dashboard Data</title></head><body>");
        out.println("<h1>Dashboard Data Test</h1>");
        
        OrderDAO orderDAO = new OrderDAO();
        ProductDAO productDAO = new ProductDAO();
        
        // Test 1: Check orders
        out.println("<h2>1. All Orders</h2>");
        List<Order> allOrders = orderDAO.getAll();
        out.println("<p>Total orders: " + allOrders.size() + "</p>");
        
        if (allOrders.isEmpty()) {
            out.println("<p style='color:red;'>❌ No orders found in database!</p>");
        } else {
            out.println("<table border='1'>");
            out.println("<tr><th>OrderID</th><th>Date</th><th>Status</th><th>Total</th><th>Details Count</th></tr>");
            for (Order order : allOrders) {
                List<OrderDetail> details = order.getDetails();
                int detailCount = (details != null) ? details.size() : 0;
                out.println("<tr>");
                out.println("<td>" + order.getOrderID() + "</td>");
                out.println("<td>" + order.getOrderDate() + "</td>");
                out.println("<td>" + order.getStatus() + "</td>");
                out.println("<td>" + order.getTotalPrice() + "</td>");
                out.println("<td>" + detailCount + "</td>");
                out.println("</tr>");
            }
            out.println("</table>");
        }
        
        // Test 2: Check order details
        out.println("<h2>2. Order Details</h2>");
        Map<String, Integer> dishCounts = new HashMap<>();
        
        for (Order order : allOrders) {
            List<OrderDetail> details = order.getDetails();
            if (details != null && !details.isEmpty()) {
                out.println("<h3>Order #" + order.getOrderID() + " Details:</h3>");
                out.println("<ul>");
                for (OrderDetail detail : details) {
                    Product product = productDAO.getProductById(detail.getProductID());
                    String productName = (product != null) ? product.getProductName() : "Unknown";
                    
                    out.println("<li>ProductID: " + detail.getProductID() + 
                               " | Name: " + productName + 
                               " | Qty: " + detail.getQuantity() + "</li>");
                    
                    dishCounts.put(productName, dishCounts.getOrDefault(productName, 0) + detail.getQuantity());
                }
                out.println("</ul>");
            }
        }
        
        // Test 3: Show dish counts
        out.println("<h2>3. Dish Counts (Best Dishes)</h2>");
        if (dishCounts.isEmpty()) {
            out.println("<p style='color:red;'>❌ No dishes counted!</p>");
        } else {
            List<Map.Entry<String, Integer>> sortedDishes = new ArrayList<>(dishCounts.entrySet());
            sortedDishes.sort((a, b) -> b.getValue().compareTo(a.getValue()));
            
            out.println("<table border='1'>");
            out.println("<tr><th>Dish Name</th><th>Total Quantity</th></tr>");
            for (Map.Entry<String, Integer> entry : sortedDishes) {
                out.println("<tr><td>" + entry.getKey() + "</td><td>" + entry.getValue() + "</td></tr>");
            }
            out.println("</table>");
        }
        
        // Test 4: Check products
        out.println("<h2>4. Available Products</h2>");
        List<Product> products = productDAO.getAllProducts();
        out.println("<p>Total products: " + products.size() + "</p>");
        if (!products.isEmpty()) {
            out.println("<ul>");
            for (Product p : products) {
                out.println("<li>ID: " + p.getProductId() + " | " + p.getProductName() + " | " + p.getPrice() + "</li>");
            }
            out.println("</ul>");
        }
        
        out.println("</body></html>");
    }
}
