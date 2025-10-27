package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import dao.OrderDAO;
import models.Order;
import java.util.List;

public class TestOrderServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        resp.setContentType("text/html;charset=UTF-8");
        
        StringBuilder result = new StringBuilder();
        result.append("<html><head><title>Test Orders</title></head><body>");
        result.append("<h1>Order Database Test</h1>");
        
        try {
            OrderDAO dao = new OrderDAO();
            
            // Test connection
            if (dao.getConnection() != null) {
                result.append("<p style='color:green'>✅ Database connection OK!</p>");
            } else {
                result.append("<p style='color:red'>❌ Database connection failed!</p>");
                resp.getWriter().write(result.toString() + "</body></html>");
                return;
            }
            
            // Test sample data creation
            dao.ensureSampleProducts();
            dao.ensureSampleOrders();
            result.append("<p>✅ Sample data ensured</p>");
            
            // Test getting orders
            List<Order> orders = dao.getAll();
            result.append("<h3>Orders in database: " + orders.size() + "</h3>");
            
            if (orders.isEmpty()) {
                result.append("<p style='color:orange'>⚠️ No orders found</p>");
            } else {
                result.append("<table border='1'>");
                result.append("<tr><th>ID</th><th>Customer</th><th>Table</th><th>Status</th><th>Total</th></tr>");
                for (Order order : orders) {
                    result.append("<tr>");
                    result.append("<td>").append(order.getOrderID()).append("</td>");
                    result.append("<td>").append(order.getCustomerID()).append("</td>");
                    result.append("<td>").append(order.getTableID()).append("</td>");
                    result.append("<td>").append(order.getStatus()).append("</td>");
                    result.append("<td>").append(order.getTotalPrice()).append("</td>");
                    result.append("</tr>");
                }
                result.append("</table>");
            }
            
        } catch (Exception e) {
            result.append("<p style='color:red'>❌ Error: " + e.getMessage() + "</p>");
            result.append("<pre>").append(e.toString()).append("</pre>");
        }
        
        result.append("<br><a href='manage-orders'>← Back to Orders</a>");
        result.append("</body></html>");
        resp.getWriter().write(result.toString());
    }
}