package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import dao.*;
import models.*;
import java.util.*;

public class QuickTestServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        resp.setContentType("text/html; charset=UTF-8");
        
        try {
            resp.getWriter().println("<html><body>");
            resp.getWriter().println("<h1>🧪 Quick Order Test</h1>");
            
            // Test creating a simple order
            resp.getWriter().println("<h2>Testing OrderDAO.createOrder directly...</h2>");
            
            OrderDAO orderDAO = new OrderDAO();
            
            // Create simple test order details
            List<OrderDetail> testDetails = new ArrayList<>();
            OrderDetail detail = new OrderDetail();
            detail.setProductID(1);
            detail.setQuantity(1);
            detail.setTotalPrice(150000);
            detail.setSpecialInstructions("Quick test order");
            testDetails.add(detail);
            
            resp.getWriter().println("<p>📝 Test parameters:</p>");
            resp.getWriter().println("<ul>");
            resp.getWriter().println("<li>CustomerID: 1</li>");
            resp.getWriter().println("<li>EmployeeID: 1</li>");
            resp.getWriter().println("<li>TableID: 1</li>");
            resp.getWriter().println("<li>Note: Quick test from servlet</li>");
            resp.getWriter().println("<li>OrderDetails: " + testDetails.size() + " items</li>");
            resp.getWriter().println("<li>ProductID: " + detail.getProductID() + "</li>");
            resp.getWriter().println("<li>Quantity: " + detail.getQuantity() + "</li>");
            resp.getWriter().println("<li>TotalPrice: " + detail.getTotalPrice() + "</li>");
            resp.getWriter().println("</ul>");
            
            try {
                resp.getWriter().println("<p>🔄 Calling orderDAO.createOrder...</p>");
                
                int orderId = orderDAO.createOrder(1, 1, 1, "Quick test from servlet", testDetails);
                
                resp.getWriter().println("<p>📊 Result: " + orderId + "</p>");
                
                if (orderId > 0) {
                    resp.getWriter().println("<p style='color:green'>✅ SUCCESS! Order created with ID: " + orderId + "</p>");
                    
                    // Verify the order was actually created
                    try {
                        Order createdOrder = orderDAO.getOrderById(orderId);
                        if (createdOrder != null) {
                            resp.getWriter().println("<p style='color:green'>✅ Order verification successful!</p>");
                            resp.getWriter().println("<p>Order details:</p>");
                            resp.getWriter().println("<ul>");
                            resp.getWriter().println("<li>OrderID: " + createdOrder.getOrderID() + "</li>");
                            resp.getWriter().println("<li>CustomerID: " + createdOrder.getCustomerID() + "</li>");
                            resp.getWriter().println("<li>EmployeeID: " + createdOrder.getEmployeeID() + "</li>");
                            resp.getWriter().println("<li>TotalPrice: " + createdOrder.getTotalPrice() + "</li>");
                            resp.getWriter().println("<li>Note: " + createdOrder.getNote() + "</li>");
                            resp.getWriter().println("</ul>");
                        } else {
                            resp.getWriter().println("<p style='color:orange'>⚠️ Order created but cannot retrieve it</p>");
                        }
                    } catch (Exception verifyEx) {
                        resp.getWriter().println("<p style='color:orange'>⚠️ Order created but verification failed: " + verifyEx.getMessage() + "</p>");
                    }
                    
                } else {
                    resp.getWriter().println("<p style='color:red'>❌ FAILED! OrderDAO.createOrder returned 0</p>");
                    
                    // Try to diagnose why it returned 0
                    resp.getWriter().println("<h3>🔍 Diagnosis:</h3>");
                    
                    // Check if Customer exists
                    try {
                        java.sql.Connection conn = orderDAO.getConnection();
                        java.sql.PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM Customer WHERE CustomerID = 1");
                        java.sql.ResultSet rs = ps.executeQuery();
                        if (rs.next()) {
                            int customerCount = rs.getInt(1);
                            if (customerCount > 0) {
                                resp.getWriter().println("<p style='color:green'>✅ Customer ID 1 exists</p>");
                            } else {
                                resp.getWriter().println("<p style='color:red'>❌ Customer ID 1 does not exist!</p>");
                            }
                        }
                        rs.close();
                        ps.close();
                    } catch (Exception custEx) {
                        resp.getWriter().println("<p style='color:red'>❌ Error checking customer: " + custEx.getMessage() + "</p>");
                    }
                    
                    // Check if Product exists
                    try {
                        java.sql.Connection conn = orderDAO.getConnection();
                        java.sql.PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM Product WHERE ProductID = 1");
                        java.sql.ResultSet rs = ps.executeQuery();
                        if (rs.next()) {
                            int productCount = rs.getInt(1);
                            if (productCount > 0) {
                                resp.getWriter().println("<p style='color:green'>✅ Product ID 1 exists</p>");
                            } else {
                                resp.getWriter().println("<p style='color:red'>❌ Product ID 1 does not exist!</p>");
                            }
                        }
                        rs.close();
                        ps.close();
                    } catch (Exception prodEx) {
                        resp.getWriter().println("<p style='color:red'>❌ Error checking product: " + prodEx.getMessage() + "</p>");
                    }
                }
                
            } catch (Exception ex) {
                resp.getWriter().println("<p style='color:red'>❌ Exception during order creation: " + ex.getMessage() + "</p>");
                resp.getWriter().println("<pre>");
                ex.printStackTrace(resp.getWriter());
                resp.getWriter().println("</pre>");
            }
            
            resp.getWriter().println("<hr>");
            resp.getWriter().println("<p><a href='pos.jsp'>🍕 Back to POS</a></p>");
            resp.getWriter().println("<p><a href='test-db'>🔧 Database Test</a></p>");
            resp.getWriter().println("</body></html>");
            
        } catch (Exception e) {
            resp.getWriter().println("<p style='color:red'>❌ Servlet error: " + e.getMessage() + "</p>");
            e.printStackTrace();
        }
    }
}