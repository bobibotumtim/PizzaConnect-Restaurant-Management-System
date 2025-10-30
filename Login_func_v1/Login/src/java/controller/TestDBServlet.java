package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import dao.*;
import models.*;
import java.util.*;

public class TestDBServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        resp.setContentType("text/html; charset=UTF-8");
        
        try {
            resp.getWriter().println("<html><body>");
            resp.getWriter().println("<h1>🔧 Database Test Results</h1>");
            
            // Test 1: Basic connection
            resp.getWriter().println("<h2>1. Database Connection Test</h2>");
            try {
                OrderDAO orderDAO = new OrderDAO();
                Connection conn = orderDAO.getConnection();
                if (conn != null && !conn.isClosed()) {
                    resp.getWriter().println("<p style='color:green'>✅ Database connection successful!</p>");
                    resp.getWriter().println("<p>Database: " + conn.getCatalog() + "</p>");
                } else {
                    resp.getWriter().println("<p style='color:red'>❌ Database connection failed!</p>");
                }
            } catch (Exception e) {
                resp.getWriter().println("<p style='color:red'>❌ Connection error: " + e.getMessage() + "</p>");
            }
            
            // Test 2: Table checks
            resp.getWriter().println("<h2>2. Table Existence Test</h2>");
            try {
                OrderDAO orderDAO = new OrderDAO();
                Connection conn = orderDAO.getConnection();
                
                // Check Customer table
                try {
                    PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM Customer");
                    ResultSet rs = ps.executeQuery();
                    if (rs.next()) {
                        int count = rs.getInt(1);
                        resp.getWriter().println("<p style='color:green'>✅ Customer table: " + count + " records</p>");
                    }
                    rs.close();
                    ps.close();
                } catch (Exception e) {
                    resp.getWriter().println("<p style='color:red'>❌ Customer table error: " + e.getMessage() + "</p>");
                }
                
                // Check Product table
                try {
                    PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM Product");
                    ResultSet rs = ps.executeQuery();
                    if (rs.next()) {
                        int count = rs.getInt(1);
                        resp.getWriter().println("<p style='color:green'>✅ Product table: " + count + " records</p>");
                    }
                    rs.close();
                    ps.close();
                } catch (Exception e) {
                    resp.getWriter().println("<p style='color:red'>❌ Product table error: " + e.getMessage() + "</p>");
                }
                
                // Check Order table
                try {
                    PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM [Order]");
                    ResultSet rs = ps.executeQuery();
                    if (rs.next()) {
                        int count = rs.getInt(1);
                        resp.getWriter().println("<p style='color:green'>✅ Order table: " + count + " records</p>");
                    }
                    rs.close();
                    ps.close();
                } catch (Exception e) {
                    resp.getWriter().println("<p style='color:red'>❌ Order table error: " + e.getMessage() + "</p>");
                }
                
            } catch (Exception e) {
                resp.getWriter().println("<p style='color:red'>❌ Table check error: " + e.getMessage() + "</p>");
            }
            
            // Test 3: Order creation test
            resp.getWriter().println("<h2>3. Order Creation Test</h2>");
            try {
                OrderDAO orderDAO = new OrderDAO();
                
                // Create test order details
                List<OrderDetail> testDetails = new ArrayList<>();
                OrderDetail detail = new OrderDetail();
                detail.setProductID(1);
                detail.setQuantity(1);
                detail.setTotalPrice(150000);
                detail.setSpecialInstructions("Test order from servlet");
                testDetails.add(detail);
                
                resp.getWriter().println("<p>🔄 Attempting to create test order...</p>");
                resp.getWriter().println("<p>CustomerID: 1, EmployeeID: 1, TableID: 1</p>");
                resp.getWriter().println("<p>Note: Test order from TestDBServlet</p>");
                resp.getWriter().println("<p>OrderDetails: " + testDetails.size() + " items</p>");
                
                int orderId = orderDAO.createOrder(1, 1, 1, "Test order from TestDBServlet", testDetails);
                
                if (orderId > 0) {
                    resp.getWriter().println("<p style='color:green'>✅ Test order created successfully! Order ID: " + orderId + "</p>");
                    
                    // Clean up test order
                    try {
                        Connection conn = orderDAO.getConnection();
                        PreparedStatement ps1 = conn.prepareStatement("DELETE FROM OrderDetail WHERE OrderID = ?");
                        ps1.setInt(1, orderId);
                        ps1.executeUpdate();
                        ps1.close();
                        
                        PreparedStatement ps2 = conn.prepareStatement("DELETE FROM [Order] WHERE OrderID = ?");
                        ps2.setInt(1, orderId);
                        ps2.executeUpdate();
                        ps2.close();
                        
                        resp.getWriter().println("<p style='color:blue'>🧹 Test order cleaned up</p>");
                    } catch (Exception cleanEx) {
                        resp.getWriter().println("<p style='color:orange'>⚠️ Cleanup failed: " + cleanEx.getMessage() + "</p>");
                    }
                } else {
                    resp.getWriter().println("<p style='color:red'>❌ Test order creation failed - returned 0</p>");
                }
                
            } catch (Exception e) {
                resp.getWriter().println("<p style='color:red'>❌ Order creation test failed: " + e.getMessage() + "</p>");
                e.printStackTrace();
            }
            
            resp.getWriter().println("<hr>");
            resp.getWriter().println("<p><a href='pos.jsp'>🍕 Go to POS System</a></p>");
            resp.getWriter().println("<p><a href='debug_pos.jsp'>🔧 Go to Debug Page</a></p>");
            resp.getWriter().println("</body></html>");
            
        } catch (Exception e) {
            resp.getWriter().println("<p style='color:red'>❌ Servlet error: " + e.getMessage() + "</p>");
            e.printStackTrace();
        }
    }
}