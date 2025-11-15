package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.BufferedReader;
import java.util.*;
import models.*;
import dao.*;
import java.sql.SQLException;

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
        
        // Block Chef access to POS
        Employee employee = (Employee) req.getSession().getAttribute("employee");
        if (employee != null && employee.isChef()) {
            System.out.println("🚫 Chef blocked from accessing POS");
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Chefs cannot access POS. Please use Chef Monitor.");
            return;
        }
        
        // Check if this is an API request
        String action = req.getParameter("action");
        if ("getProducts".equals(action)) {
            // Return JSON data for products
            handleProductsAPI(req, resp);
            return;
        } else if ("getTables".equals(action)) {
            // Return JSON data for tables
            handleTablesAPI(req, resp);
            return;
        } else if ("getOrder".equals(action)) {
            // Return JSON data for existing order
            handleGetOrderAPI(req, resp);
            return;
        } else if ("getToppings".equals(action)) {
            // Return JSON data for toppings
            handleToppingsAPI(req, resp);
            return;
        } else if ("getCategories".equals(action)) {
            // ✅ MỚI: Return JSON data for categories
            handleCategoriesAPI(req, resp);
            return;
        }
        
        // Check if editing existing order
        String orderIdParam = req.getParameter("orderId");
        if (orderIdParam != null && !orderIdParam.trim().isEmpty()) {
            try {
                int orderId = Integer.parseInt(orderIdParam);
                req.setAttribute("editOrderId", orderId);
                System.out.println("🔄 POS opened in EDIT mode for Order #" + orderId);
            } catch (NumberFormatException e) {
                System.err.println("❌ Invalid orderId parameter: " + orderIdParam);
            }
        }
        
        // Forward to POS page
        req.getRequestDispatcher("/view/pos.jsp").forward(req, resp);
    }
    
    /**
     * ✅ MỚI: Handle API request for categories data
     * Lấy tất cả categories có products available (loại trừ Topping)
     */
    private void handleCategoriesAPI(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        resp.setContentType("application/json; charset=UTF-8");
        
        try {
            CategoryDAO categoryDAO = new CategoryDAO();
            
            // Lấy tất cả categories có products available
            List<models.Category> categories = categoryDAO.getAvailableCategoriesForPOS();
            
            // Build JSON response
            StringBuilder json = new StringBuilder();
            json.append("{\"success\": true, \"categories\": [");
            
            for (int i = 0; i < categories.size(); i++) {
                models.Category category = categories.get(i);
                if (i > 0) json.append(",");
                json.append("{");
                json.append("\"categoryID\": ").append(category.getCategoryId()).append(",");
                json.append("\"categoryName\": \"").append(escapeJson(category.getCategoryName())).append("\",");
                json.append("\"description\": \"").append(escapeJson(category.getDescription())).append("\"");
                json.append("}");
            }
            
            json.append("]}");
            resp.getWriter().write(json.toString());
            
            System.out.println("✅ Categories API called - returned " + categories.size() + " categories");
            
        } catch (Exception e) {
            e.printStackTrace();
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            resp.getWriter().write("{\"success\": false, \"message\": \"" + escapeJson(e.getMessage()) + "\"}");
        }
    }
    
    /**
     * Handle API request for products data (moved from ProductAPIServlet)
     * ✅ UPDATED: Now uses v_ProductSizeAvailable VIEW to check inventory
     */
    private void handleProductsAPI(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        resp.setContentType("application/json; charset=UTF-8");
        
        try {
            ProductDAO productDAO = new ProductDAO();
            ProductSizeDAO productSizeDAO = new ProductSizeDAO();
            CategoryDAO categoryDAO = new CategoryDAO();
            
            // ✅ SỬA: Chỉ lấy products có AvailableQuantity > 0 (loại trừ Topping)
            System.out.println("🔄 Loading available products for POS...");
            List<Product> products = productDAO.getAvailableProductsForPOS();
            System.out.println("✅ Loaded " + products.size() + " available products");
            
            // Tạo JSON response
            StringBuilder json = new StringBuilder();
            json.append("{\"success\": true, \"categories\": {");
            
            // Group products by category
            String currentCategory = "";
            boolean firstCategory = true;
            
            for (Product product : products) {
                if (!product.getCategoryName().equals(currentCategory)) {
                    if (!firstCategory) {
                        json.append("],");
                    }
                    currentCategory = product.getCategoryName();
                    json.append("\"").append(currentCategory).append("\": [");
                    firstCategory = false;
                } else {
                    json.append(",");
                }
                
                // ✅ SỬA: Chỉ lấy sizes có AvailableQuantity > 0
                List<ProductSize> sizes = productSizeDAO.getAvailableSizesByProductId(product.getProductId());
                
                json.append("{");
                json.append("\"id\": ").append(product.getProductId()).append(",");
                json.append("\"name\": \"").append(escapeJson(product.getProductName())).append("\",");
                json.append("\"description\": \"").append(escapeJson(product.getDescription())).append("\",");
                json.append("\"category\": \"").append(escapeJson(product.getCategoryName())).append("\",");
                json.append("\"imageUrl\": \"").append(escapeJson(product.getImageUrl())).append("\",");
                json.append("\"sizes\": [");
                
                for (int i = 0; i < sizes.size(); i++) {
                    ProductSize size = sizes.get(i);
                    if (i > 0) json.append(",");
                    json.append("{");
                    json.append("\"sizeId\": ").append(size.getProductSizeId()).append(",");
                    json.append("\"sizeCode\": \"").append(size.getSizeCode()).append("\",");
                    json.append("\"sizeName\": \"").append(getSizeName(size.getSizeCode())).append("\",");
                    json.append("\"price\": ").append(size.getPrice());
                    json.append("}");
                }
                
                json.append("]}");
            }
            
            if (!firstCategory) {
                json.append("]");
            }
            json.append("}}");
            
            resp.getWriter().write(json.toString());
            
        } catch (Exception e) {
            e.printStackTrace();
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            resp.getWriter().write("{\"success\": false, \"message\": \"" + escapeJson(e.getMessage()) + "\"}");
        }
    }
    
    /**
     * Helper method to get size name from size code
     */
    private String getSizeName(String sizeCode) {
        switch (sizeCode) {
            case "S": return "Small";
            case "M": return "Medium";
            case "L": return "Large";
            case "F": return "Fixed";
            default: return sizeCode;
        }
    }
    
    /**
     * Helper method to escape JSON strings
     */
    private String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\"", "\\\"")
                 .replace("\\", "\\\\")
                 .replace("\n", "\\n")
                 .replace("\r", "\\r")
                 .replace("\t", "\\t");
    }

    /**
     * Handle API request for tables data
     */
    private void handleTablesAPI(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        resp.setContentType("application/json; charset=UTF-8");
        
        try {
            TableDAO tableDAO = new TableDAO();
            
            // Get all active tables with status
            List<models.Table> allTables = tableDAO.getActiveTablesWithStatus();
            
            // Filter out locked tables
            List<models.Table> tables = new ArrayList<>();
            int lockedCount = 0;
            for (models.Table table : allTables) {
                if (!table.isLocked()) {
                    tables.add(table);
                } else {
                    lockedCount++;
                }
            }
            
            // Build JSON response
            StringBuilder json = new StringBuilder();
            json.append("{\"success\": true, \"tables\": [");
            
            for (int i = 0; i < tables.size(); i++) {
                models.Table table = tables.get(i);
                if (i > 0) json.append(",");
                json.append("{");
                json.append("\"tableID\": ").append(table.getTableID()).append(",");
                json.append("\"tableNumber\": \"").append(escapeJson(table.getTableNumber())).append("\",");
                json.append("\"capacity\": ").append(table.getCapacity()).append(",");
                json.append("\"status\": \"").append(escapeJson(table.getStatus())).append("\"");
                json.append("}");
            }
            
            json.append("]}");
            resp.getWriter().write(json.toString());
            
            System.out.println("✅ Tables API called - returned " + tables.size() + " tables (filtered out " + lockedCount + " locked tables)");
            
        } catch (Exception e) {
            e.printStackTrace();
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            resp.getWriter().write("{\"success\": false, \"message\": \"" + escapeJson(e.getMessage()) + "\"}");
        }
    }

    /**
     * Handle API request to get existing order details
     */
    private void handleGetOrderAPI(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        resp.setContentType("application/json; charset=UTF-8");
        
        try {
            String orderIdParam = req.getParameter("orderId");
            if (orderIdParam == null || orderIdParam.trim().isEmpty()) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                resp.getWriter().write("{\"success\": false, \"message\": \"Order ID is required\"}");
                return;
            }
            
            int orderId = Integer.parseInt(orderIdParam);
            OrderDAO orderDAO = new OrderDAO();
            Order order = orderDAO.getOrderWithDetails(orderId);
            
            if (order == null) {
                resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                resp.getWriter().write("{\"success\": false, \"message\": \"Order not found\"}");
                return;
            }
            
            // Build JSON response
            StringBuilder json = new StringBuilder();
            json.append("{\"success\": true, \"order\": {");
            json.append("\"orderID\": ").append(order.getOrderID()).append(",");
            json.append("\"tableID\": ").append(order.getTableID()).append(",");
            json.append("\"customerID\": ").append(order.getCustomerID()).append(",");
            json.append("\"totalPrice\": ").append(order.getTotalPrice()).append(",");
            json.append("\"note\": \"").append(escapeJson(order.getNote())).append("\",");
            json.append("\"items\": [");
            
            List<OrderDetail> details = order.getDetails();
            if (details != null) {
                for (int i = 0; i < details.size(); i++) {
                    OrderDetail detail = details.get(i);
                    if (i > 0) json.append(",");
                    json.append("{");
                    json.append("\"orderDetailID\": ").append(detail.getOrderDetailID()).append(",");
                    json.append("\"productSizeID\": ").append(detail.getProductSizeID()).append(",");
                    json.append("\"productName\": \"").append(escapeJson(detail.getProductName())).append("\",");
                    json.append("\"sizeName\": \"").append(escapeJson(detail.getSizeName())).append("\",");
                    json.append("\"quantity\": ").append(detail.getQuantity()).append(",");
                    json.append("\"totalPrice\": ").append(detail.getTotalPrice()).append(",");
                    json.append("\"specialInstructions\": \"").append(escapeJson(detail.getSpecialInstructions())).append("\"");
                    json.append("}");
                }
            }
            
            json.append("]}}");
            resp.getWriter().write(json.toString());
            
            System.out.println("✅ Order API called - returned Order #" + orderId + " with " + 
                             (details != null ? details.size() : 0) + " items");
            
        } catch (NumberFormatException e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().write("{\"success\": false, \"message\": \"Invalid order ID format\"}");
        } catch (Exception e) {
            e.printStackTrace();
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            resp.getWriter().write("{\"success\": false, \"message\": \"" + escapeJson(e.getMessage()) + "\"}");
        }
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
            
            // Check if this is adding items to existing order or creating new order
            // Check root level "orderId" first (not in items array)
            int existingOrderId = 0;
            
            // Find orderId at root level (after "timestamp")
            String searchPattern = "\"timestamp\":";
            int timestampIdx = jsonData.indexOf(searchPattern);
            if (timestampIdx > 0) {
                // Look for orderId after timestamp
                String afterTimestamp = jsonData.substring(timestampIdx);
                existingOrderId = extractJsonInt(afterTimestamp, "orderId");
                System.out.println("🔍 Extracted orderId from root level: " + existingOrderId);
            }
            
            // Fallback: check orderID (capital)
            if (existingOrderId <= 0) {
                existingOrderId = extractJsonInt(jsonData, "orderID");
                System.out.println("🔍 Tried orderID (capital): " + existingOrderId);
            }
            
            System.out.println("🔍 Full JSON data: " + jsonData);
            
            if (existingOrderId > 0) {
                // EDIT MODE: Adding items to existing order
                System.out.println("📝 EDIT MODE: Adding items to Order #" + existingOrderId);
                
                try {
                    boolean success = addItemsToExistingOrder(jsonData, user, existingOrderId);
                    
                    if (success) {
                        String response = "{\"success\": true, \"message\": \"Items added successfully!\", \"orderId\": " + existingOrderId + "}";
                        resp.getWriter().write(response);
                        System.out.println("✅ Items added to Order #" + existingOrderId);
                    } else {
                        resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                        resp.getWriter().write("{\"success\": false, \"message\": \"Failed to add items\"}");
                    }
                } catch (Exception processEx) {
                    System.err.println("❌ Exception adding items: " + processEx.getMessage());
                    processEx.printStackTrace();
                    resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    resp.getWriter().write("{\"success\": false, \"message\": \"Exception: " + processEx.getMessage() + "\"}");
                }
                
            } else {
                // CREATE MODE: Creating new order
                System.out.println("🆕 CREATE MODE: Creating new order");
                
                // Extract and validate tableID
                int tableId = extractJsonInt(jsonData, "tableID");
                if (tableId <= 0) {
                    resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    resp.getWriter().write("{\"success\": false, \"message\": \"Table ID is required\"}");
                    System.err.println("❌ Table ID is missing or invalid");
                    return;
                }
                
                System.out.println("🪑 Selected Table ID: " + tableId);
                
                // Process order
                try {
                    int orderId = processOrderSimple(jsonData, user, tableId);
                    
                    if (orderId > 0) {
                        // ✅ NO NEED to update table status manually
                        // Table status (occupied) is calculated automatically from Order table
                        // See TableDAO.getActiveTablesWithStatus() for logic
                        
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
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            resp.getWriter().write("{\"success\": false, \"message\": \"Error: " + e.getMessage() + "\"}");
        }
    }
    
    private int processOrderSimple(String jsonData, User user, int tableId) {
        System.out.println("========================================");
        System.out.println("🍕 STARTING ORDER PROCESSING");
        System.out.println("========================================");
        
        List<CartItemWithToppings> cartItems = null; // Declare outside try block
        
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
            
            // Parse cart items from JSON (with toppings)
            cartItems = parseCartItemsWithToppings(jsonData);
            List<OrderDetail> orderDetails = new ArrayList<>();
            for (CartItemWithToppings item : cartItems) {
                orderDetails.add(item.getOrderDetail());
            }
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
            System.out.println("   Parameters: customerID=1, employeeID=" + employeeId + ", tableID=" + tableId);
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
                System.out.println("🔄 Parameters: customerID=1, employeeID=" + employeeId + ", tableID=" + tableId);
                System.out.println("🔄 Note: " + note);
                System.out.println("🔄 OrderDetails size: " + orderDetails.size());
                
                orderId = orderDAO.createOrder(1, employeeId, tableId, note, orderDetails);
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
                    orderId = orderDAO.createOrderWithAutoCustomerId(employeeId, tableId, note, orderDetails);
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
                
                // Save toppings for each order detail
                System.out.println("🍕 Saving toppings for order details...");
                OrderDAO orderDAO2 = new OrderDAO();
                Order createdOrder = orderDAO2.getOrderWithDetails(orderId);
                
                if (createdOrder != null && createdOrder.getDetails() != null) {
                    List<OrderDetail> savedDetails = createdOrder.getDetails();
                    
                    // Match saved details with cart items to save toppings
                    for (int i = 0; i < Math.min(savedDetails.size(), cartItems.size()); i++) {
                        OrderDetail savedDetail = savedDetails.get(i);
                        CartItemWithToppings cartItem = cartItems.get(i);
                        
                        if (cartItem.getToppings() != null && !cartItem.getToppings().isEmpty()) {
                            System.out.println("  💾 Saving " + cartItem.getToppings().size() + 
                                             " toppings for OrderDetailID=" + savedDetail.getOrderDetailID());
                            saveToppingsForOrderDetail(savedDetail.getOrderDetailID(), cartItem.getToppings());
                        }
                    }
                    System.out.println("✅ Toppings saved successfully!");
                } else {
                    System.err.println("⚠️ Could not load order details to save toppings");
                }
                
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

    // Simple JSON int extractor - improved to handle both string and int values
    private int extractJsonInt(String json, String key) {
        try {
            // Try with space after colon: "key": value
            String searchKey1 = "\"" + key + "\":";
            String searchKey2 = "\"" + key + "\" :"; // with space before colon
            
            int startIndex = json.indexOf(searchKey1);
            if (startIndex == -1) {
                startIndex = json.indexOf(searchKey2);
                if (startIndex == -1) {
                    System.err.println("❌ Key '" + key + "' not found in JSON");
                    return 0;
                }
                startIndex += searchKey2.length();
            } else {
                startIndex += searchKey1.length();
            }
            
            // Skip whitespace
            while (startIndex < json.length() && Character.isWhitespace(json.charAt(startIndex))) {
                startIndex++;
            }
            
            int endIndex = json.indexOf(",", startIndex);
            if (endIndex == -1) endIndex = json.indexOf("}", startIndex);
            if (endIndex == -1) return 0;
            
            String valueStr = json.substring(startIndex, endIndex).trim();
            
            // Check if value is a string (has quotes) or contains #
            if (valueStr.startsWith("\"") || valueStr.contains("#")) {
                // This is a string value like "#1", not a real integer OrderID
                System.out.println("⚠️ " + key + " is a string value: " + valueStr + " - treating as 0");
                return 0;
            }
            
            // Parse clean integer (no quotes, no #)
            int result = Integer.parseInt(valueStr);
            System.out.println("✅ Extracted " + key + " = " + result);
            return result;
        } catch (Exception e) {
            System.err.println("❌ Error extracting " + key + ": " + e.getMessage());
            return 0;
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
                defaultItem.setProductSizeID(1); // Use ProductSizeID
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
                    // Extract item details - now including sizeId
                    int productSizeId = extractItemSizeId(item);
                    String productName = extractItemName(item);
                    String sizeName = extractItemSizeName(item);
                    int quantity = extractItemQuantity(item);
                    double price = extractItemPrice(item);
                    String toppings = extractItemToppings(item);
                    double toppingPrice = extractItemToppingPrice(item); // NEW: Extract topping price
                    
                    OrderDetail detail = new OrderDetail();
                    detail.setProductSizeID(productSizeId > 0 ? productSizeId : 1); // Use ProductSizeID
                    detail.setQuantity(quantity > 0 ? quantity : 1);
                    detail.setTotalPrice((price + toppingPrice) * quantity); // Include topping price
                    
                    String instructions = productName;
                    if (sizeName != null && !sizeName.isEmpty()) {
                        instructions += " (" + sizeName + ")";
                    }
                    if (toppings != null && !toppings.isEmpty()) {
                        instructions += " + " + toppings;
                    }
                    detail.setSpecialInstructions(instructions);
                    
                    orderDetails.add(detail);
                    
                    System.out.println("✅ Item " + (i+1) + " parsed: ProductSizeID=" + detail.getProductSizeID() + 
                                     ", Quantity=" + detail.getQuantity() + 
                                     ", Price=" + detail.getTotalPrice() + 
                                     ", Instructions=" + detail.getSpecialInstructions());
                    
                } catch (Exception itemEx) {
                    System.err.println("❌ Error parsing item " + (i+1) + ": " + itemEx.getMessage());
                    // Create fallback item
                    OrderDetail fallbackDetail = new OrderDetail();
                    fallbackDetail.setProductSizeID(1); // Use ProductSizeID
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
            fallbackItem.setProductSizeID(1); // Use ProductSizeID
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
    
    // New method to extract ProductSizeID
    private int extractItemSizeId(String item) {
        try {
            String sizeIdPattern = "\"sizeId\":";
            int sizeIdIndex = item.indexOf(sizeIdPattern);
            if (sizeIdIndex != -1) {
                sizeIdIndex += sizeIdPattern.length();
                int endIndex = item.indexOf(",", sizeIdIndex);
                if (endIndex == -1) endIndex = item.length();
                String sizeIdStr = item.substring(sizeIdIndex, endIndex).trim().replace("\"", "");
                return Integer.parseInt(sizeIdStr);
            }
        } catch (Exception e) {
            System.err.println("Error extracting item sizeId: " + e.getMessage());
        }
        return 1; // Default
    }
    
    // New method to extract size name
    private String extractItemSizeName(String item) {
        try {
            String sizeNamePattern = "\"sizeName\":\"";
            int sizeNameIndex = item.indexOf(sizeNamePattern);
            if (sizeNameIndex != -1) {
                sizeNameIndex += sizeNamePattern.length();
                int endIndex = item.indexOf("\"", sizeNameIndex);
                if (endIndex != -1) {
                    return item.substring(sizeNameIndex, endIndex);
                }
            }
        } catch (Exception e) {
            System.err.println("Error extracting item size name: " + e.getMessage());
        }
        return "";
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
    
    private double extractItemToppingPrice(String item) {
        try {
            String toppingsPattern = "\"toppings\":[";
            int toppingsIndex = item.indexOf(toppingsPattern);
            if (toppingsIndex != -1) {
                toppingsIndex += toppingsPattern.length();
                int endIndex = item.indexOf("]", toppingsIndex);
                if (endIndex != -1) {
                    String toppingsStr = item.substring(toppingsIndex, endIndex);
                    // Parse topping prices and sum them
                    double totalToppingPrice = 0;
                    String[] toppingItems = toppingsStr.split("\\},\\{");
                    for (String topping : toppingItems) {
                        String pricePattern = "\"price\":";
                        int priceIdx = topping.indexOf(pricePattern);
                        if (priceIdx != -1) {
                            priceIdx += pricePattern.length();
                            int priceEnd = topping.indexOf(",", priceIdx);
                            if (priceEnd == -1) priceEnd = topping.indexOf("}", priceIdx);
                            if (priceEnd == -1) priceEnd = topping.length();
                            String priceStr = topping.substring(priceIdx, priceEnd).trim();
                            totalToppingPrice += Double.parseDouble(priceStr);
                        }
                    }
                    return totalToppingPrice;
                }
            }
        } catch (Exception e) {
            System.err.println("Error extracting topping price: " + e.getMessage());
        }
        return 0; // No toppings
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

    /**
     * Add items to existing order
     */
    private boolean addItemsToExistingOrder(String jsonData, User user, int orderId) {
        System.out.println("========================================");
        System.out.println("📝 ADDING ITEMS TO EXISTING ORDER #" + orderId);
        System.out.println("========================================");
        
        try {
            // Parse cart items from JSON - Filter ONLY NEW ITEMS
            List<CartItemWithToppings> allCartItems = parseCartItemsWithToppingsForEdit(jsonData);
            List<OrderDetail> newItems = new ArrayList<>();
            
            for (CartItemWithToppings cartItem : allCartItems) {
                newItems.add(cartItem.getOrderDetail());
            }
            
            System.out.println("   New items to add: " + newItems.size());
            
            if (newItems.isEmpty()) {
                System.err.println("❌ No items to add");
                return false;
            }
            
            // Debug new items
            for (int i = 0; i < newItems.size(); i++) {
                OrderDetail detail = newItems.get(i);
                System.out.println("   New Item " + (i+1) + ": ProductSizeID=" + detail.getProductSizeID() + 
                                 ", Quantity=" + detail.getQuantity() + 
                                 ", Price=" + detail.getTotalPrice());
            }
            
            // Add items to order
            OrderDAO orderDAO = new OrderDAO();
            List<Integer> newOrderDetailIds = orderDAO.addItemsToOrder(orderId, newItems);
            
            if (newOrderDetailIds != null && !newOrderDetailIds.isEmpty()) {
                System.out.println("✅ Added " + newOrderDetailIds.size() + " items to Order #" + orderId);
                
                // Save toppings for new items
                System.out.println("🍕 Saving toppings for new items...");
                for (int i = 0; i < Math.min(newOrderDetailIds.size(), allCartItems.size()); i++) {
                    int orderDetailId = newOrderDetailIds.get(i);
                    CartItemWithToppings cartItem = allCartItems.get(i);
                    
                    if (cartItem.getToppings() != null && !cartItem.getToppings().isEmpty()) {
                        System.out.println("  💾 Saving " + cartItem.getToppings().size() + 
                                         " toppings for OrderDetailID=" + orderDetailId);
                        saveToppingsForOrderDetail(orderDetailId, cartItem.getToppings());
                    }
                }
                System.out.println("✅ Toppings saved successfully!");
                
                System.out.println("✅✅✅ SUCCESS! Added items to Order #" + orderId + " ✅✅✅");
                return true;
            } else {
                System.err.println("❌ Failed to add items to order");
                return false;
            }
            
        } catch (Exception e) {
            System.err.println("========================================");
            System.err.println("❌ EXCEPTION in addItemsToExistingOrder");
            System.err.println("========================================");
            System.err.println("Exception type: " + e.getClass().getName());
            System.err.println("Exception message: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Handle API request for toppings data
     */
    private void handleToppingsAPI(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        resp.setContentType("application/json; charset=UTF-8");
        
        try {
            ToppingDAO toppingDAO = new ToppingDAO();
            List<Topping> toppings = toppingDAO.getAvailableToppings();
            
            // Build JSON response
            StringBuilder json = new StringBuilder();
            json.append("{\"success\": true, \"toppings\": [");
            
            for (int i = 0; i < toppings.size(); i++) {
                Topping t = toppings.get(i);
                if (i > 0) json.append(",");
                
                json.append("{")
                    .append("\"toppingID\": ").append(t.getToppingID()).append(",")
                    .append("\"toppingName\": \"").append(t.getToppingName()).append("\",")
                    .append("\"price\": ").append(t.getPrice())
                    .append("}");
            }
            
            json.append("]}");
            
            resp.getWriter().write(json.toString());
            System.out.println("✅ Toppings API: Returned " + toppings.size() + " toppings");
            
        } catch (Exception e) {
            System.err.println("❌ Error in handleToppingsAPI: " + e.getMessage());
            e.printStackTrace();
            resp.getWriter().write("{\"success\": false, \"message\": \"" + e.getMessage() + "\"}");
        }
    }
    
    /**
     * Parse toppings from item JSON string
     * Format: "toppings":[{"toppingID":1,"toppingName":"Extra Cheese","price":15000}]
     */
    private List<OrderDetailTopping> parseToppingsFromItem(String itemJson) {
        List<OrderDetailTopping> toppings = new ArrayList<>();
        
        try {
            // Find toppings array
            String toppingsStart = "\"toppings\":[";
            int startIdx = itemJson.indexOf(toppingsStart);
            
            if (startIdx == -1) {
                // No toppings in this item
                return toppings;
            }
            
            startIdx += toppingsStart.length();
            int endIdx = itemJson.indexOf("]", startIdx);
            
            if (endIdx == -1) {
                return toppings;
            }
            
            String toppingsJson = itemJson.substring(startIdx, endIdx);
            
            if (toppingsJson.trim().isEmpty()) {
                return toppings;
            }
            
            // Split by },{
            String[] toppingItems = toppingsJson.split("\\},\\{");
            
            for (String toppingItem : toppingItems) {
                toppingItem = toppingItem.replace("{", "").replace("}", "");
                
                // Extract toppingID and price
                int toppingID = extractJsonIntFromString(toppingItem, "toppingID");
                double price = extractJsonDoubleFromString(toppingItem, "price");
                
                if (toppingID > 0) {
                    OrderDetailTopping topping = new OrderDetailTopping();
                    topping.setToppingID(toppingID);
                    topping.setToppingPrice(price);
                    toppings.add(topping);
                    
                    System.out.println("  🍕 Parsed topping: ID=" + toppingID + ", Price=" + price);
                }
            }
            
        } catch (Exception e) {
            System.err.println("❌ Error parsing toppings: " + e.getMessage());
        }
        
        return toppings;
    }
    
    /**
     * Helper to extract int from JSON string
     */
    private int extractJsonIntFromString(String json, String key) {
        try {
            String searchKey = "\"" + key + "\":";
            int startIdx = json.indexOf(searchKey);
            if (startIdx == -1) return 0;
            
            startIdx += searchKey.length();
            int endIdx = json.indexOf(",", startIdx);
            if (endIdx == -1) endIdx = json.indexOf("}", startIdx);
            if (endIdx == -1) endIdx = json.length();
            
            String value = json.substring(startIdx, endIdx).trim();
            return Integer.parseInt(value);
        } catch (Exception e) {
            return 0;
        }
    }
    
    /**
     * Helper to extract double from JSON string
     */
    private double extractJsonDoubleFromString(String json, String key) {
        try {
            String searchKey = "\"" + key + "\":";
            int startIdx = json.indexOf(searchKey);
            if (startIdx == -1) return 0.0;
            
            startIdx += searchKey.length();
            int endIdx = json.indexOf(",", startIdx);
            if (endIdx == -1) endIdx = json.indexOf("}", startIdx);
            if (endIdx == -1) endIdx = json.length();
            
            String value = json.substring(startIdx, endIdx).trim();
            return Double.parseDouble(value);
        } catch (Exception e) {
            return 0.0;
        }
    }
    
    /**
     * Save toppings for an order detail
     */
    private void saveToppingsForOrderDetail(int orderDetailID, List<OrderDetailTopping> toppings) throws SQLException {
        if (toppings == null || toppings.isEmpty()) {
            return;
        }
        
        OrderDetailToppingDAO toppingDAO = new OrderDetailToppingDAO();
        
        for (OrderDetailTopping topping : toppings) {
            topping.setOrderDetailID(orderDetailID);
            boolean success = toppingDAO.addToppingToOrderDetail(
                orderDetailID, 
                topping.getToppingID(), 
                topping.getToppingPrice()
            );
            
            if (success) {
                System.out.println("  ✅ Saved topping: OrderDetailID=" + orderDetailID + 
                                 ", ToppingID=" + topping.getToppingID() + 
                                 ", Price=" + topping.getToppingPrice());
            } else {
                System.err.println("  ❌ Failed to save topping for OrderDetailID=" + orderDetailID);
            }
        }
    }
    
    /**
     * Parse cart items for EDIT mode - only NEW items (skip existing)
     */
    private List<CartItemWithToppings> parseCartItemsWithToppingsForEdit(String json) {
        List<CartItemWithToppings> allItems = parseCartItemsWithToppings(json);
        List<CartItemWithToppings> newItems = new ArrayList<>();
        
        // Filter: Only items that don't have "isExisting":true
        for (int i = 0; i < allItems.size(); i++) {
            // Check if this item has isExisting flag in original JSON
            // Simple heuristic: check if uniqueId starts with "existing-"
            String itemsStart = "\"items\":[";
            int startIdx = json.indexOf(itemsStart);
            if (startIdx > 0) {
                String itemsSection = json.substring(startIdx);
                // Count which item we're at
                int itemCount = 0;
                boolean foundExisting = false;
                
                // Look for the i-th item and check if it has "isExisting":true
                int searchIdx = 0;
                for (int j = 0; j <= i; j++) {
                    int uniqueIdIdx = itemsSection.indexOf("\"uniqueId\":", searchIdx);
                    if (uniqueIdIdx > 0) {
                        int nextComma = itemsSection.indexOf(",", uniqueIdIdx);
                        int nextBrace = itemsSection.indexOf("}", uniqueIdIdx);
                        int endIdx = (nextComma > 0 && nextComma < nextBrace) ? nextComma : nextBrace;
                        
                        String uniqueIdSection = itemsSection.substring(uniqueIdIdx, endIdx);
                        
                        if (j == i) {
                            // Check if next field is isExisting
                            int isExistingIdx = itemsSection.indexOf("\"isExisting\"", uniqueIdIdx);
                            if (isExistingIdx > 0 && isExistingIdx < uniqueIdIdx + 200) {
                                foundExisting = true;
                            }
                            break;
                        }
                        searchIdx = uniqueIdIdx + 10;
                    }
                }
                
                if (!foundExisting) {
                    newItems.add(allItems.get(i));
                    System.out.println("  ✅ Item " + (i+1) + " is NEW - will be added");
                } else {
                    System.out.println("  ⏭️ Item " + (i+1) + " is EXISTING - skipped");
                }
            }
        }
        
        return newItems;
    }
    
    /**
     * Parse cart items with toppings from JSON
     * Fixed to properly handle nested toppings array
     */
    private List<CartItemWithToppings> parseCartItemsWithToppings(String json) {
        List<CartItemWithToppings> cartItems = new ArrayList<>();
        
        try {
            System.out.println("🔍 Parsing cart items with toppings from JSON...");
            
            // Find items array in JSON
            String itemsStart = "\"items\":[";
            int startIndex = json.indexOf(itemsStart);
            
            if (startIndex == -1) {
                System.out.println("⚠️ No 'items' array found in JSON");
                return cartItems;
            }
            
            startIndex += itemsStart.length();
            
            // Find the closing bracket for items array by counting brackets
            int bracketCount = 0;
            int endIndex = startIndex;
            boolean inString = false;
            
            for (int i = startIndex; i < json.length(); i++) {
                char c = json.charAt(i);
                
                if (c == '"' && (i == 0 || json.charAt(i-1) != '\\')) {
                    inString = !inString;
                }
                
                if (!inString) {
                    if (c == '[' || c == '{') bracketCount++;
                    if (c == ']' || c == '}') bracketCount--;
                    
                    if (c == ']' && bracketCount == -1) {
                        endIndex = i;
                        break;
                    }
                }
            }
            
            String itemsJson = json.substring(startIndex, endIndex);
            System.out.println("📦 Items JSON extracted (length: " + itemsJson.length() + ")");
            
            // Parse each item by finding complete objects (not simple split)
            List<String> itemStrings = new ArrayList<>();
            int itemStart = 0;
            int depth = 0;
            inString = false;
            
            for (int i = 0; i < itemsJson.length(); i++) {
                char c = itemsJson.charAt(i);
                
                if (c == '"' && (i == 0 || itemsJson.charAt(i-1) != '\\')) {
                    inString = !inString;
                }
                
                if (!inString) {
                    if (c == '{') {
                        if (depth == 0) itemStart = i;
                        depth++;
                    }
                    if (c == '}') {
                        depth--;
                        if (depth == 0) {
                            itemStrings.add(itemsJson.substring(itemStart, i + 1));
                        }
                    }
                }
            }
            
            System.out.println("🔢 Found " + itemStrings.size() + " items to parse");
            
            for (int i = 0; i < itemStrings.size(); i++) {
                String itemJson = itemStrings.get(i);
                
                System.out.println("📝 Parsing item " + (i+1) + ": " + itemJson.substring(0, Math.min(100, itemJson.length())) + "...");
                
                try {
                    // Extract item details
                    int productSizeId = extractItemSizeId(itemJson);
                    String productName = extractItemName(itemJson);
                    String sizeName = extractItemSizeName(itemJson);
                    int quantity = extractItemQuantity(itemJson);
                    double basePrice = extractItemPrice(itemJson);
                    
                    // Parse toppings for this item FIRST (to calculate total price)
                    List<OrderDetailTopping> toppings = parseToppingsFromItem(itemJson);
                    
                    // Calculate topping total
                    double toppingTotal = 0;
                    for (OrderDetailTopping topping : toppings) {
                        toppingTotal += topping.getToppingPrice();
                    }
                    
                    // Calculate total price INCLUDING toppings (NO tax at OrderDetail level)
                    double itemTotal = (basePrice + toppingTotal) * quantity;
                    
                    // Create OrderDetail
                    OrderDetail detail = new OrderDetail();
                    detail.setProductSizeID(productSizeId > 0 ? productSizeId : 1);
                    detail.setQuantity(quantity > 0 ? quantity : 1);
                    detail.setTotalPrice(itemTotal); // ✅ Includes toppings (tax added at Order level)
                    
                    String instructions = productName;
                    if (sizeName != null && !sizeName.isEmpty()) {
                        instructions += " (" + sizeName + ")";
                    }
                    detail.setSpecialInstructions(instructions);
                    
                    // Create CartItemWithToppings
                    CartItemWithToppings cartItem = new CartItemWithToppings(detail);
                    cartItem.setToppings(toppings);
                    
                    cartItems.add(cartItem);
                    
                    System.out.println("✅ Item " + (i+1) + " parsed: ProductSizeID=" + detail.getProductSizeID() + 
                                     ", Quantity=" + detail.getQuantity() + 
                                     ", BasePrice=" + basePrice +
                                     ", ToppingTotal=" + toppingTotal +
                                     ", ItemTotal=" + itemTotal +
                                     ", Toppings=" + toppings.size());
                    
                } catch (Exception itemEx) {
                    System.err.println("❌ Error parsing item " + (i+1) + ": " + itemEx.getMessage());
                }
            }
            
        } catch (Exception e) {
            System.err.println("❌ Error in parseCartItemsWithToppings: " + e.getMessage());
            e.printStackTrace();
        }
        
        return cartItems;
    }
    
    /**
     * Add items to existing order
     */
    
}
