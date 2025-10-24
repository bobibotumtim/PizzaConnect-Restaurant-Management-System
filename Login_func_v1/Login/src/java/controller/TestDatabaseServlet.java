package controller;

import dao.OrderDAO;
import dao.DBContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;

public class TestDatabaseServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        resp.setContentType("text/html;charset=UTF-8");
        
        StringBuilder result = new StringBuilder();
        result.append("<html><head><title>Database Test</title></head><body>");
        result.append("<h1>Database Connection Test</h1>");
        
        try {
            // Test 1: Basic connection
            DBContext db = new DBContext();
            Connection conn = db.getConnection();
            
            if (conn != null && !conn.isClosed()) {
                result.append("<p style='color:green'>✅ Database connection successful!</p>");
                
                // Test 2: Check tables
                String checkTables = """
                    SELECT COUNT(*) as table_count 
                    FROM sys.tables 
                    WHERE name IN ('Order', 'OrderDetail', 'Product', 'Customer')
                """;
                
                try (Statement stmt = conn.createStatement();
                     ResultSet rs = stmt.executeQuery(checkTables)) {
                    if (rs.next()) {
                        int tableCount = rs.getInt("table_count");
                        result.append("<p>📊 Found " + tableCount + " required tables</p>");
                    }
                }
                
                // Test 3: Check data in Order table
                String checkOrders = "SELECT COUNT(*) as order_count FROM [Order]";
                try (Statement stmt = conn.createStatement();
                     ResultSet rs = stmt.executeQuery(checkOrders)) {
                    if (rs.next()) {
                        int orderCount = rs.getInt("order_count");
                        result.append("<p>📦 Found " + orderCount + " orders in database</p>");
                    }
                }
                
                // Test 4: Show actual orders
                String showOrders = "SELECT TOP 5 OrderID, CustomerID, TotalPrice, Status FROM [Order] ORDER BY OrderID";
                try (Statement stmt = conn.createStatement();
                     ResultSet rs = stmt.executeQuery(showOrders)) {
                    result.append("<h3>Sample Orders:</h3>");
                    result.append("<table border='1'><tr><th>OrderID</th><th>CustomerID</th><th>TotalPrice</th><th>Status</th></tr>");
                    while (rs.next()) {
                        result.append("<tr>");
                        result.append("<td>").append(rs.getInt("OrderID")).append("</td>");
                        result.append("<td>").append(rs.getInt("CustomerID")).append("</td>");
                        result.append("<td>").append(rs.getDouble("TotalPrice")).append("</td>");
                        result.append("<td>").append(rs.getInt("Status")).append("</td>");
                        result.append("</tr>");
                    }
                    result.append("</table>");
                }
                
                // Test 5: Test OrderDAO
                OrderDAO orderDAO = new OrderDAO();
                var orders = orderDAO.getAll();
                result.append("<h3>OrderDAO Results:</h3>");
                result.append("<p>OrderDAO returned " + orders.size() + " orders</p>");
                
                for (var order : orders) {
                    result.append("<p>Order #" + order.getOrderID() + 
                                " - Customer: " + order.getCustomerName() + 
                                " - Total: " + order.getTotalPrice() + "</p>");
                }
                
            } else {
                result.append("<p style='color:red'>❌ Database connection failed!</p>");
            }
            
        } catch (Exception e) {
            result.append("<p style='color:red'>❌ Error: " + e.getMessage() + "</p>");
            result.append("<pre>").append(e.toString()).append("</pre>");
        }
        
        result.append("</body></html>");
        resp.getWriter().write(result.toString());
    }
}
