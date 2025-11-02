package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.BufferedReader;
import java.util.*;
import models.*;
import dao.*;

public class POSServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        // Check if user is logged in
        User user = (User) req.getSession().getAttribute("user");
        if (user == null) {
            resp.sendRedirect("Login");
            return;
        }
        
        // Forward to POS page
        req.getRequestDispatcher("/view/pos.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        System.out.println("╔════════════════════════════════════════╗");
        System.out.println("║   POSServlet.doPost() CALLED          ║");
        System.out.println("╚════════════════════════════════════════╝");
        
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json; charset=UTF-8");
        
        // Check if user is logged in
        User user = (User) req.getSession().getAttribute("user");
        System.out.println("🔐 Checking user session...");
        if (user == null) {
            System.err.println("❌ User not logged in - session is null");
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            resp.getWriter().write("{\"success\": false, \"message\": \"Not logged in\"}");
            return;
        }
        
        System.out.println("✅ User logged in: UserID=" + user.getUserID() + ", Name=" + user.getName());
        
        // Validate user ID
        if (user.getUserID() <= 0) {
            System.err.println("❌ Invalid UserID: " + user.getUserID());
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().write("{\"success\": false, \"message\": \"Invalid user ID\"}");
            return;
        }
        
        try {
            // Read JSON from request body
            StringBuilder sb = new StringBuilder();
            String line;
            BufferedReader reader = req.getReader();
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
            
            // Parse JSON manually (simple version)
            String jsonData = sb.toString();
            System.out.println("📥 Received POS order data: " + jsonData);
            
            // Validate JSON data
            if (jsonData == null || jsonData.trim().isEmpty()) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                resp.getWriter().write("{\"success\": false, \"message\": \"Empty JSON data received\"}");
                System.err.println("❌ Empty JSON data received");
                return;
            }
            
            // Process order
            try {
                int orderId = processOrderSimple(jsonData, user);
                
                if (orderId > 0) {
                    String response = "{\"success\": true, \"message\": \"Order created successfully!\", \"orderId\": " + orderId + "}";
                    resp.getWriter().write(response);
                    System.out.println("✅ POS order processed successfully! Order ID: " + orderId);
                } else {
                    resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    resp.getWriter().write("{\"success\": false, \"message\": \"Failed to create order - returned 0\"}");
                    System.err.println("❌ processOrderSimple returned 0");
                }
            } catch (Exception processEx) {
                System.err.println("❌ Exception in processOrderSimple: " + processEx.getMessage());
                processEx.printStackTrace();
                resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                resp.getWriter().write("{\"success\": false, \"message\": \"Exception: " + processEx.getMessage() + "\"}");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            resp.getWriter().write("{\"success\": false, \"message\": \"Error: " + e.getMessage() + "\"}");
        }
    }
    
    private int processOrderSimple(String jsonData, User user) {
        System.out.println("========================================");
        System.out.println("🍕 STARTING ORDER PROCESSING");
        System.out.println("========================================");
        
        try {
            // Extract basic info from JSON
            String customerName = extractJsonValue(jsonData, "customerName");
            if (customerName == null || customerName.isEmpty()) {
                customerName = "Walk-in Customer";
            }
            
            double total = extractJsonDouble(jsonData, "total");
            double discount = extractJsonDouble(jsonData, "discount");
            double subtotal = extractJsonDouble(jsonData, "subtotal");
            
            System.out.println("📋 Order Information:");
            System.out.println("   Customer: " + customerName);
            System.out.println("   Subtotal: " + subtotal + " VND");
            System.out.println("   Discount: " + discount + "%");
            System.out.println("   Total: " + total + " VND");
            System.out.println("   User ID: " + user.getUserID());
            System.out.println("   User Name: " + user.getName());
            
            // Parse cart items from JSON
            List<OrderDetail> orderDetails = parseCartItems(jsonData);
            System.out.println("   Items count: " + orderDetails.size());
            
            // Debug order details
            for (int i = 0; i < orderDetails.size(); i++) {
                OrderDetail detail = orderDetails.get(i);
                System.out.println("   Item " + (i+1) + ": ProductID=" + detail.getProductID() + 
                                 ", Quantity=" + detail.getQuantity() + 
                                 ", Price=" + detail.getTotalPrice() + 
                                 ", Instructions=" + detail.getSpecialInstructions());
            }
            
            // Create order in database
            OrderDAO orderDAO = new OrderDAO();
            String note = String.format("POS Order - Customer: %s, Discount: %.1f%%, Items: %d", 
                                      customerName, discount, orderDetails.size());
            
            int orderId = 0;
            
            // DETAILED DATABASE CONNECTION TEST
            System.out.println("🔍 Testing database connection...");
            try {
                OrderDAO testDAO = new OrderDAO();
                java.sql.Connection conn = testDAO.getConnection();
                if (conn != null) {
                    System.out.println("✅ Database connection OK");
                    
                    // Test if Order table exists
                    try {
                        java.sql.PreparedStatement testPs = conn.prepareStatement("SELECT COUNT(*) FROM [Order]");
                        java.sql.ResultSet testRs = testPs.executeQuery();
                        if (testRs.next()) {
                            int orderCount = testRs.getInt(1);
                            System.out.println("✅ Order table exists with " + orderCount + " records");
                        }
                        testRs.close();
                        testPs.close();
                    } catch (Exception tableEx) {
                        System.err.println("❌ Order table does not exist or is inaccessible: " + tableEx.getMessage());
                        throw new Exception("Order table missing. Please run POS_Database_Setup_Complete.sql first!");
                    }
                    
                    // Test if Product table exists
                    try {
                        java.sql.PreparedStatement testPs = conn.prepareStatement("SELECT COUNT(*) FROM Product");
                        java.sql.ResultSet testRs = testPs.executeQuery();
                        if (testRs.next()) {
                            int productCount = testRs.getInt(1);
                            System.out.println("✅ Product table exists with " + productCount + " records");
                        }
                        testRs.close();
                        testPs.close();
                    } catch (Exception tableEx) {
                        System.err.println("❌ Product table does not exist: " + tableEx.getMessage());
                        throw new Exception("Product table missing. Please run POS_Database_Setup_Complete.sql first!");
                    }
                    
                } else {
                    System.err.println("❌ Database connection is NULL");
                    throw new Exception("Database connection failed - check DBContext configuration");
                }
            } catch (Exception connEx) {
                System.err.println("❌ Database connection test failed: " + connEx.getMessage());
                throw new Exception("Cannot connect to database: " + connEx.getMessage());
            }
            
            // Get proper EmployeeID from Employee table
            int employeeId = getEmployeeIdByUserId(user.getUserID());
            if (employeeId == 0) {
                System.out.println("⚠️ User does not have Employee record, using default EmployeeID = 1");
                employeeId = 1;
            }
            
            // Try to create order using available method
            System.out.println("🔄 Attempting to create order in database...");
            System.out.println("   Parameters: customerID=1, employeeID=" + employeeId + ", tableID=1");
            System.out.println("   Note: " + note);
            System.out.println("   OrderDetails count: " + orderDetails.size());
            
            try {
                // Validate parameters before calling createOrder
                System.out.println("🔍 Validating order parameters:");
                System.out.println("   CustomerID: 1");
                System.out.println("   EmployeeID: " + user.getUserID());
                System.out.println("   TableID: 1");
                System.out.println("   Note: " + note);
                System.out.println("   OrderDetails count: " + orderDetails.size());
                
                if (orderDetails.isEmpty()) {
                    System.err.println("❌ OrderDetails list is empty!");
                    throw new Exception("Cannot create order with empty order details");
                }
                
                // Use the existing createOrder method (customerID, employeeID, tableID, note, orderDetails)
                System.out.println("🔄 Calling orderDAO.createOrder...");
                System.out.println("🔄 Parameters: customerID=1, employeeID=" + employeeId + ", tableID=1");
                System.out.println("🔄 Note: " + note);
                System.out.println("🔄 OrderDetails size: " + orderDetails.size());
                
                orderId = orderDAO.createOrder(1, employeeId, 1, note, orderDetails);
                System.out.println("📊 OrderDAO.createOrder returned: " + orderId);
                
                if (orderId > 0) {
                    System.out.println("✅ Order created successfully with OrderDAO.createOrder: " + orderId);
                } else {
                    System.err.println("❌ OrderDAO.createOrder returned 0 - order creation failed");
                }
                
            } catch (Exception ex) {
                System.err.println("❌ OrderDAO.createOrder failed with error: " + ex.getClass().getSimpleName());
                System.err.println("❌ Error message: " + ex.getMessage());
                ex.printStackTrace();
                
                // Try alternative method if available
                System.out.println("🔄 Trying alternative order creation method...");
                try {
                    orderId = orderDAO.createOrderWithAutoCustomerId(employeeId, 1, note, orderDetails);
                    System.out.println("📊 Alternative method returned: " + orderId);
                    
                    if (orderId > 0) {
                        System.out.println("✅ Order created with alternative method: " + orderId);
                    } else {
                        System.err.println("❌ Alternative method also returned 0");
                    }
                } catch (Exception altEx) {
                    System.err.println("❌ Alternative method also failed: " + altEx.getMessage());
                    altEx.printStackTrace();
                    throw new Exception("All database order creation methods failed: " + ex.getMessage());
                }
            }
            
            System.out.println("========================================");
            System.out.println("📊 FINAL RESULT: orderId = " + orderId);
            System.out.println("========================================");
            
            if (orderId > 0) {
                System.out.println("✅✅✅ SUCCESS! Order ID: " + orderId + " ✅✅✅");
                return orderId;
            } else {
                System.err.println("❌❌❌ FAILED! OrderID is 0 ❌❌❌");
                System.err.println("This should NOT happen since quick-test works!");
                System.err.println("Check the logs above for the actual error");
                return 0;
            }
            
        } catch (Exception e) {
            System.err.println("========================================");
            System.err.println("❌ EXCEPTION in processOrderSimple");
            System.err.println("========================================");
            System.err.println("Exception type: " + e.getClass().getName());
            System.err.println("Exception message: " + e.getMessage());
            System.err.println("Stack trace:");
            e.printStackTrace();
            return 0;
        }
    }
    
    // Simple JSON value extractor
    private String extractJsonValue(String json, String key) {
        try {
            String searchKey = "\"" + key + "\":\"";
            int startIndex = json.indexOf(searchKey);
            if (startIndex == -1) return null;
            
            startIndex += searchKey.length();
            int endIndex = json.indexOf("\"", startIndex);
            if (endIndex == -1) return null;
            
            return json.substring(startIndex, endIndex);
        } catch (Exception e) {
            return null;
        }
    }
    
    // Simple JSON double extractor
    private double extractJsonDouble(String json, String key) {
        try {
            String searchKey = "\"" + key + "\":";
            int startIndex = json.indexOf(searchKey);
            if (startIndex == -1) return 0.0;
            
            startIndex += searchKey.length();
            int endIndex = json.indexOf(",", startIndex);
            if (endIndex == -1) endIndex = json.indexOf("}", startIndex);
            if (endIndex == -1) return 0.0;
            
            String valueStr = json.substring(startIndex, endIndex).trim();
            return Double.parseDouble(valueStr);
        } catch (Exception e) {
            return 0.0;
        }
    }
    
    // Parse cart items from JSON (improved implementation)
    private List<OrderDetail> parseCartItems(String json) {
        List<OrderDetail> orderDetails = new ArrayList<>();
        
        try {
            System.out.println("🔍 Parsing cart items from JSON...");
            System.out.println("📄 JSON length: " + json.length());
            
            // Find items array in JSON
            String itemsStart = "\"items\":[";
            int startIndex = json.indexOf(itemsStart);
            if (startIndex == -1) {
                System.out.println("⚠️ No 'items' array found in JSON, creating default item");
                // Create default item if no items found
                OrderDetail defaultItem = new OrderDetail();
                defaultItem.setProductID(1);
                defaultItem.setQuantity(1);
                defaultItem.setTotalPrice(extractJsonDouble(json, "total"));
                defaultItem.setSpecialInstructions("POS Order - No items array found");
                orderDetails.add(defaultItem);
                return orderDetails;
            }
            
            startIndex += itemsStart.length();
            int endIndex = json.indexOf("]", startIndex);
            if (endIndex == -1) {
                System.out.println("⚠️ No closing bracket for items array");
                return orderDetails;
            }
            
            String itemsJson = json.substring(startIndex, endIndex);
            System.out.println("📦 Items JSON: " + itemsJson);
            
            // Parse each item in the array
            String[] items = itemsJson.split("\\},\\{");
            System.out.println("🔢 Found " + items.length + " items to parse");
            
            for (int i = 0; i < items.length; i++) {
                String item = items[i];
                // Clean up the item string
                item = item.replace("{", "").replace("}", "");
                
                System.out.println("📝 Parsing item " + (i+1) + ": " + item);
                
                try {
                    // Extract item details
                    int productId = extractItemId(item);
                    String productName = extractItemName(item);
                    int quantity = extractItemQuantity(item);
                    double price = extractItemPrice(item);
                    String toppings = extractItemToppings(item);
                    
                    OrderDetail detail = new OrderDetail();
                    detail.setProductID(productId > 0 ? productId : 1); // Default to product 1 if not found
                    detail.setQuantity(quantity > 0 ? quantity : 1);
                    detail.setTotalPrice(price * quantity);
                    
                    String instructions = productName;
                    if (toppings != null && !toppings.isEmpty()) {
                        instructions += " + " + toppings;
                    }
                    detail.setSpecialInstructions(instructions);
                    
                    orderDetails.add(detail);
                    
                    System.out.println("✅ Item " + (i+1) + " parsed: ProductID=" + detail.getProductID() + 
                                     ", Quantity=" + detail.getQuantity() + 
                                     ", Price=" + detail.getTotalPrice() + 
                                     ", Instructions=" + detail.getSpecialInstructions());
                    
                } catch (Exception itemEx) {
                    System.err.println("❌ Error parsing item " + (i+1) + ": " + itemEx.getMessage());
                    // Create fallback item
                    OrderDetail fallbackDetail = new OrderDetail();
                    fallbackDetail.setProductID(1);
                    fallbackDetail.setQuantity(1);
                    fallbackDetail.setTotalPrice(50000); // Default price
                    fallbackDetail.setSpecialInstructions("Parse error item " + (i+1));
                    orderDetails.add(fallbackDetail);
                }
            }
            
            System.out.println("📦 Successfully parsed " + orderDetails.size() + " items from cart");
            
        } catch (Exception e) {
            System.err.println("❌ Error parsing cart items: " + e.getMessage());
            e.printStackTrace();
            
            // Fallback: create single item based on total
            OrderDetail fallbackItem = new OrderDetail();
            fallbackItem.setProductID(1);
            fallbackItem.setQuantity(1);
            fallbackItem.setTotalPrice(extractJsonDouble(json, "total"));
            fallbackItem.setSpecialInstructions("POS Order - Parse error fallback");
            orderDetails.add(fallbackItem);
            
            System.out.println("🔄 Created fallback item with total: " + fallbackItem.getTotalPrice());
        }
        
        return orderDetails;
    }
    
    // Helper methods for parsing item details
    private int extractItemId(String item) {
        try {
            String idPattern = "\"id\":";
            int idIndex = item.indexOf(idPattern);
            if (idIndex != -1) {
                idIndex += idPattern.length();
                int endIndex = item.indexOf(",", idIndex);
                if (endIndex == -1) endIndex = item.length();
                String idStr = item.substring(idIndex, endIndex).trim().replace("\"", "");
                return Integer.parseInt(idStr);
            }
        } catch (Exception e) {
            System.err.println("Error extracting item ID: " + e.getMessage());
        }
        return 1; // Default
    }
    
    private String extractItemName(String item) {
        try {
            String namePattern = "\"name\":\"";
            int nameIndex = item.indexOf(namePattern);
            if (nameIndex != -1) {
                nameIndex += namePattern.length();
                int endIndex = item.indexOf("\"", nameIndex);
                if (endIndex != -1) {
                    return item.substring(nameIndex, endIndex);
                }
            }
        } catch (Exception e) {
            System.err.println("Error extracting item name: " + e.getMessage());
        }
        return "Unknown Item";
    }
    
    private int extractItemQuantity(String item) {
        try {
            String qtyPattern = "\"quantity\":";
            int qtyIndex = item.indexOf(qtyPattern);
            if (qtyIndex != -1) {
                qtyIndex += qtyPattern.length();
                int endIndex = item.indexOf(",", qtyIndex);
                if (endIndex == -1) endIndex = item.length();
                String qtyStr = item.substring(qtyIndex, endIndex).trim();
                return Integer.parseInt(qtyStr);
            }
        } catch (Exception e) {
            System.err.println("Error extracting item quantity: " + e.getMessage());
        }
        return 1; // Default
    }
    
    private double extractItemPrice(String item) {
        try {
            String pricePattern = "\"price\":";
            int priceIndex = item.indexOf(pricePattern);
            if (priceIndex != -1) {
                priceIndex += pricePattern.length();
                int endIndex = item.indexOf(",", priceIndex);
                if (endIndex == -1) endIndex = item.length();
                String priceStr = item.substring(priceIndex, endIndex).trim();
                return Double.parseDouble(priceStr);
            }
        } catch (Exception e) {
            System.err.println("Error extracting item price: " + e.getMessage());
        }
        return 50000; // Default price
    }
    
    private String extractItemToppings(String item) {
        try {
            String toppingsPattern = "\"toppings\":[";
            int toppingsIndex = item.indexOf(toppingsPattern);
            if (toppingsIndex != -1) {
                toppingsIndex += toppingsPattern.length();
                int endIndex = item.indexOf("]", toppingsIndex);
                if (endIndex != -1) {
                    String toppingsStr = item.substring(toppingsIndex, endIndex);
                    // Simple parsing of toppings array
                    return toppingsStr.replace("\"", "").replace(",", ", ");
                }
            }
        } catch (Exception e) {
            System.err.println("Error extracting item toppings: " + e.getMessage());
        }
        return "";
    }
    
    // Create simple order directly in database
    private int createSimpleOrderInDB(String customerName, double total, double discount, int userId) {
        try {
            System.out.println("🔄 Attempting to create simple order in database...");
            
            // Create minimal order using direct SQL approach
            OrderDAO orderDAO = new OrderDAO();
            
            // Create single order detail
            List<OrderDetail> orderDetails = new ArrayList<>();
            OrderDetail detail = new OrderDetail();
            detail.setProductID(1); // Default product
            detail.setQuantity(1);
            detail.setTotalPrice(total);
            detail.setSpecialInstructions("POS Order - " + customerName);
            orderDetails.add(detail);
            
            String note = String.format("POS - %s - %.0f VND (%.1f%% discount)", customerName, total, discount);
            
            // Try the most basic createOrder method with correct parameters
            System.out.println("🔄 Calling orderDAO.createOrder(1, " + userId + ", 1, \"" + note + "\", " + orderDetails.size() + " items)");
            int result = orderDAO.createOrder(1, userId, 1, note, orderDetails); // customerID=1, employeeID=userId, tableID=1
            System.out.println("📊 OrderDAO.createOrder returned: " + result);
            return result;
            
        } catch (Exception e) {
            System.err.println("❌ Simple order creation failed: " + e.getMessage());
            e.printStackTrace();
            return 0;
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