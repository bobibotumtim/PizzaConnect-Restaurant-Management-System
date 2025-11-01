package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.BufferedReader;
import java.util.*;
import models.*;
import dao.*;

public class SimplePOSServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        System.out.println("===========================================");
        System.out.println("SimplePOSServlet CALLED!");
        System.out.println("===========================================");
        
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json; charset=UTF-8");
        
        try {
            // Read JSON
            StringBuilder sb = new StringBuilder();
            BufferedReader reader = req.getReader();
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
            String jsonData = sb.toString();
            
            System.out.println("📥 Received JSON: " + jsonData);
            
            // Get user from session
            User user = (User) req.getSession().getAttribute("user");
            if (user == null) {
                System.out.println("❌ User not logged in");
                resp.getWriter().write("{\"success\": false, \"message\": \"Not logged in\"}");
                return;
            }
            
            System.out.println("✅ User: " + user.getName() + " (ID: " + user.getUserID() + ")");
            
            // Create simple order
            OrderDAO orderDAO = new OrderDAO();
            
            // Create one order detail
            List<OrderDetail> details = new ArrayList<>();
            OrderDetail detail = new OrderDetail();
            detail.setProductID(1);
            detail.setQuantity(1);
            detail.setTotalPrice(150000);
            detail.setSpecialInstructions("Simple POS order");
            details.add(detail);
            
            // Get EmployeeID from Employee table based on UserID
            int employeeId = getEmployeeIdByUserId(user.getUserID());
            if (employeeId == 0) {
                System.out.println("⚠️ User does not have Employee record, using default EmployeeID = 1");
                employeeId = 1;
            }
            
            System.out.println("🔄 Creating order...");
            System.out.println("   CustomerID: 1");
            System.out.println("   EmployeeID: " + employeeId + " (fixed)");
            System.out.println("   TableID: 1");
            System.out.println("   Details: " + details.size() + " items");
            
            int orderId = orderDAO.createOrder(1, employeeId, 1, "Simple POS order", details);
            
            System.out.println("📊 Result: orderId = " + orderId);
            
            if (orderId > 0) {
                System.out.println("✅✅✅ SUCCESS! Order ID: " + orderId);
                resp.getWriter().write("{\"success\": true, \"orderId\": " + orderId + ", \"message\": \"Order created!\"}");
            } else {
                System.out.println("❌❌❌ FAILED! Returned 0");
                resp.getWriter().write("{\"success\": false, \"message\": \"Order creation returned 0\"}");
            }
            
        } catch (Exception e) {
            System.out.println("❌ Exception: " + e.getMessage());
            e.printStackTrace();
            resp.getWriter().write("{\"success\": false, \"message\": \"Exception: " + e.getMessage() + "\"}");
        }
    }
    
    // Helper method to get EmployeeID from UserID
    private int getEmployeeIdByUserId(int userId) {
        try {
            OrderDAO orderDAO = new OrderDAO();
            java.sql.Connection conn = orderDAO.getConnection();
            java.sql.PreparedStatement ps = conn.prepareStatement(
                "SELECT EmployeeID FROM Employee WHERE UserID = ?"
            );
            ps.setInt(1, userId);
            java.sql.ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                int empId = rs.getInt("EmployeeID");
                System.out.println("✅ Found EmployeeID: " + empId + " for UserID: " + userId);
                rs.close();
                ps.close();
                return empId;
            }
            
            rs.close();
            ps.close();
            System.out.println("⚠️ No Employee record found for UserID: " + userId);
            return 0;
            
        } catch (Exception e) {
            System.out.println("❌ Error getting EmployeeID: " + e.getMessage());
            return 0;
        }
    }
}
