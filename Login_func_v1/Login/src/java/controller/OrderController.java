package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.*;
import dao.*;
import models.*;

public class OrderController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        if (action == null) {
            // Nếu truy cập /manage-orders thì mặc định là action=manage
            String requestURI = req.getRequestURI();
            if (requestURI.contains("manage-orders")) {
                action = "manage";
            } else {
                action = "list";
            }
        }
        
        System.out.println("OrderController - Action: " + action + ", URI: " + req.getRequestURI());

        OrderDAO dao = new OrderDAO();
        
        // Không thêm dữ liệu mẫu vì database đã có sẵn
        System.out.println("OrderController - Using existing database data");

        switch (action) {
            case "new":
                req.getRequestDispatcher("/view/order-form.jsp").forward(req, resp);
                break;

            case "edit":
                int editId = Integer.parseInt(req.getParameter("id"));
                Order editOrder = dao.getOrderById(editId);
                req.setAttribute("order", editOrder);
                req.getRequestDispatcher("/view/order-form.jsp").forward(req, resp);
                break;
                
            case "filter":
                String statusStr = req.getParameter("status");
                if (statusStr != null && !statusStr.isEmpty()) {
                    try {
                        int status = Integer.parseInt(statusStr);
                        List<Order> filteredOrders = dao.getOrdersByStatus(status);
                        req.setAttribute("orders", filteredOrders);
                        req.setAttribute("selectedStatus", status);
                    } catch (NumberFormatException e) {
                        req.setAttribute("error", "Invalid status filter!");
                    }
                } else {
                    List<Order> orders = dao.getAll();
                    req.setAttribute("orders", orders);
                }
                req.getRequestDispatcher("/view/ManageOrders.jsp").forward(req, resp);
                break;
                
            case "getOrder":
                // Trả về JSON cho AJAX request (cho edit modal)
                int orderId = Integer.parseInt(req.getParameter("id"));
                Order orderData = dao.getOrderById(orderId);

                resp.setContentType("application/json; charset=UTF-8");
                if (orderData != null) {
                    StringBuilder sb = new StringBuilder();
                    sb.append("{\"success\": true, \"order\": {");
                    sb.append("\"orderID\": ").append(orderData.getOrderID()).append(',');
                    sb.append("\"customerID\": ").append(orderData.getCustomerID()).append(',');
                    sb.append("\"employeeID\": ").append(orderData.getEmployeeID()).append(',');
                    sb.append("\"tableID\": ").append(orderData.getTableID()).append(',');
                    sb.append("\"orderDate\": \"").append(orderData.getOrderDate() != null ? orderData.getOrderDate() : "").append("\",");
                    sb.append("\"status\": ").append(orderData.getStatus()).append(',');
                    sb.append("\"paymentStatus\": \"").append(escapeJson(orderData.getPaymentStatus() != null ? orderData.getPaymentStatus() : "Unpaid")).append("\",");
                    sb.append("\"totalPrice\": ").append(orderData.getTotalPrice()).append(',');
                    sb.append("\"note\": \"").append(escapeJson(orderData.getNote() != null ? orderData.getNote() : "")).append("\"");
                    sb.append("}}");
                    resp.getWriter().write(sb.toString());
                } else {
                    resp.getWriter().write("{\"success\": false, \"message\": \"Order not found\"}");
                }
                break;



            case "delete":
                int delId = Integer.parseInt(req.getParameter("id"));
                dao.deleteOrder(delId);
                resp.sendRedirect("OrderController?action=list");
                break;

            case "detail":
                int id = Integer.parseInt(req.getParameter("id"));
                List<OrderDetail> details = dao.getOrderDetailsByOrderId(id);
                req.setAttribute("details", details);
                req.getRequestDispatcher("/view/order-detail.jsp").forward(req, resp);
                break;

            case "manage":
                List<Order> orders = dao.getAll();
                req.setAttribute("orders", orders);
                
                // Tính toán thống kê
                int totalOrders = orders.size();
                int completedOrders = 0;
                double totalRevenue = 0.0;
                
                for (Order o : orders) {
                    if (o.getStatus() == 2) { // Completed
                        completedOrders++;
                    }
                    totalRevenue += o.getTotalPrice();
                }
                
                req.setAttribute("totalOrders", totalOrders);
                req.setAttribute("completedOrders", completedOrders);
                req.setAttribute("totalRevenue", totalRevenue);
                
                req.getRequestDispatcher("/view/ManageOrders.jsp").forward(req, resp);
                break;
                
            default:
                // Mặc định: hiển thị tất cả đơn hàng với giao diện PizzaConnect
                List<Order> allOrders = dao.getAll();
                req.setAttribute("orders", allOrders);
                req.getRequestDispatcher("/view/ManageOrders.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        
        // Add CORS headers
        resp.setHeader("Access-Control-Allow-Origin", "*");
        resp.setHeader("Access-Control-Allow-Methods", "POST, GET, OPTIONS");
        resp.setHeader("Access-Control-Allow-Headers", "Content-Type");
        
        String action = req.getParameter("action");
        
        if ("add".equals(action) || "addFromModal".equals(action)) {
            // Xử lý thêm đơn hàng từ modal
            handleAddOrderFromModal(req, resp);
        } else if ("update".equals(action) || "updateFromModal".equals(action)) {
            // Xử lý cập nhật đơn hàng từ modal
            handleUpdateOrderFromModal(req, resp);
        } else if ("updateStatus".equals(action)) {
            // Cập nhật trạng thái đơn hàng
            handleUpdateStatus(req, resp);
        } else if ("updatePayment".equals(action)) {
            // Cập nhật trạng thái thanh toán
            handleUpdatePayment(req, resp);
        } else if ("delete".equals(action)) {
            // Xóa đơn hàng
            handleDeleteOrder(req, resp);
        } else {
            // Xử lý form cũ
            handleLegacyForm(req, resp);
        }
    }
    
    private void handleAddOrderFromModal(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            System.out.println("=== handleAddOrderFromModal START ===");

            String[] pizzaTypes = req.getParameterValues("pizzaType");
            String[] quantities = req.getParameterValues("quantity");
            String[] prices = req.getParameterValues("price");
            int status = parseIntSafe(req.getParameter("status"));

            // Validation: at least 1 item
            if (pizzaTypes == null || quantities == null || prices == null
                    || pizzaTypes.length == 0 || quantities.length == 0 || prices.length == 0
                    || !(pizzaTypes.length == quantities.length && quantities.length == prices.length)) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                resp.getWriter().write("Invalid Product Data");
                return;
            }

            // Check database connection
            OrderDAO dao = new OrderDAO();
            if (dao.getConnection() == null) {
                System.out.println("ERROR: Database connection is null");
                resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                resp.getWriter().write("Cannot connect to database");
                return;
            }

            // Tạo danh sách chi tiết từ nhiều dòng
            List<OrderDetail> details = new ArrayList<>();
            for (int i = 0; i < pizzaTypes.length; i++) {
                int qty = parseIntSafe(quantities[i]);
                double unitPrice = parseDoubleSafe(prices[i]);
                if (qty <= 0 || unitPrice <= 0) {
                    resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    resp.getWriter().write("Quantity and price must be greater than 0 (row " + (i + 1) + ")");
                    return;
                }
                OrderDetail d = new OrderDetail();
                d.setProductID(mapPizzaTypeToProductId(pizzaTypes[i])); // Map pizza type to real ProductID
                d.setQuantity(qty);
                d.setTotalPrice(qty * unitPrice);
                d.setSpecialInstructions("Type: " + pizzaTypes[i]);
                details.add(d);
            }

            System.out.println("Creating order with details: " + details.size());

            // Create order with auto customer ID, employeeID = 1, tableID = 1
            int orderId = dao.createOrderWithAutoCustomerId(1, 1, "Order from modal", details);
            System.out.println("Order created with ID: " + orderId);

            // Update status if not pending
            if (status != 0) {
                dao.updateOrderStatus(orderId, status);
                System.out.println("Order status updated to: " + status);
            }

            resp.setStatus(HttpServletResponse.SC_OK);
            resp.getWriter().write("Order added successfully");
            System.out.println("=== handleAddOrderFromModal SUCCESS ===");

        } catch (Exception e) {
            System.out.println("=== handleAddOrderFromModal ERROR ===");
            e.printStackTrace();
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            resp.getWriter().write("Error adding order: " + e.getMessage());
        }
    }
    
    private void handleUpdateOrderFromModal(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        try {
            System.out.println("=== handleUpdateOrderFromModal START ===");
            System.out.println("Request method: " + req.getMethod());
            System.out.println("Content type: " + req.getContentType());
            
            // Set response type and CORS headers immediately
            resp.setContentType("text/plain; charset=UTF-8");
            resp.setHeader("Access-Control-Allow-Origin", "*");
            resp.setHeader("Access-Control-Allow-Methods", "POST, GET, OPTIONS");
            resp.setHeader("Access-Control-Allow-Headers", "Content-Type");
            
            int orderID = parseIntSafe(req.getParameter("orderID"));
            int status = parseIntSafe(req.getParameter("status"));
            String paymentStatus = req.getParameter("paymentStatus");
            String note = req.getParameter("note");
            
            System.out.println("Updating Order ID: " + orderID + 
                            ", Status: " + status + 
                            ", PaymentStatus: " + paymentStatus +
                            ", Note: " + note);
            
            // Validation
            if (orderID <= 0) {
                System.out.println("ERROR: Invalid Order ID");
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                resp.setContentType("application/json; charset=UTF-8");
                resp.getWriter().write("{\"success\": false, \"message\": \"Invalid Order ID\"}");
                return;
            }
            
            // Check database connection
            OrderDAO dao = new OrderDAO();
            if (dao.getConnection() == null) {
                System.out.println("ERROR: Database connection is null");
                resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                resp.setContentType("application/json; charset=UTF-8");
                resp.getWriter().write("{\"success\": false, \"message\": \"Cannot connect to database\"}");
                return;
            }
            
            // Update status, payment and note
            boolean success = dao.updateOrderStatusPaymentAndNote(orderID, status, paymentStatus, note);
            
            if (!success) {
                System.out.println("ERROR: Failed to update order");
                resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                resp.setContentType("application/json; charset=UTF-8");
                resp.getWriter().write("{\"success\": false, \"message\": \"Failed to update order\"}");
                return;
            }
            
            resp.setStatus(HttpServletResponse.SC_OK);
            resp.setContentType("application/json; charset=UTF-8");
            resp.getWriter().write("{\"success\": true, \"message\": \"Order updated successfully!\"}");
            System.out.println("=== handleUpdateOrderFromModal SUCCESS ===");
            
        } catch (Exception e) {
            System.out.println("=== handleUpdateOrderFromModal ERROR ===");
            e.printStackTrace();
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            resp.setContentType("application/json; charset=UTF-8");
            resp.getWriter().write("{\"success\": false, \"message\": \"" + e.getMessage() + "\"}");
        }
    }
    
    private void handleLegacyForm(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Lấy dữ liệu từ form
        String customerParam = req.getParameter("customerID");
        String employeeParam = req.getParameter("employeeID");
        String tableParam = req.getParameter("tableID");
        String note = req.getParameter("note");

        // Validate input data
        int customerID = parseIntSafe(customerParam);
        int employeeID = parseIntSafe(employeeParam);
        int tableID = parseIntSafe(tableParam);

        // If invalid input (e.g. text, empty) → show error
        if (customerID <= 0 || employeeID <= 0 || tableID <= 0) {
            resp.setContentType("text/plain; charset=UTF-8");
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().write("❌ Please enter valid numbers for Customer ID, Employee ID and Table ID.");
            return;
        }

        // Create empty details list (if no details yet)
        List<OrderDetail> details = new ArrayList<>();

        OrderDAO dao = new OrderDAO();
        try {
            dao.createOrder(customerID, employeeID, tableID, note, details);
            resp.sendRedirect("OrderController?action=list");
        } catch (Exception e) {
            e.printStackTrace();
            resp.setContentType("text/plain; charset=UTF-8");
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            resp.getWriter().write("⚠️ Cannot save order. Please try again: " + e.getMessage());
        }
    }

    /**
     * Utility function to safely parse integer
     */
    private int parseIntSafe(String value) {
        try {
            return Integer.parseInt(value);
        } catch (Exception e) {
            return -1; // return -1 if not a number
        }
    }
    
    /**
     * Utility function to safely parse double
     */
    private double parseDoubleSafe(String value) {
        try {
            return Double.parseDouble(value);
        } catch (Exception e) {
            return -1.0; // return -1 if not a number
        }
    }

    
    private void handleUpdateStatus(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            int orderId = Integer.parseInt(req.getParameter("orderId"));
            int status = Integer.parseInt(req.getParameter("status"));
            
            OrderDAO dao = new OrderDAO();
            boolean success = dao.updateOrderStatus(orderId, status);
            
            if (success) {
                req.setAttribute("message", "Order status updated successfully!");
            } else {
                req.setAttribute("error", "Failed to update order status!");
            }
        } catch (Exception e) {
            req.setAttribute("error", "Error updating status: " + e.getMessage());
        }
        
        resp.sendRedirect("manage-orders");
    }
    
    private void handleUpdatePayment(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            int orderId = Integer.parseInt(req.getParameter("orderId"));
            String paymentStatus = req.getParameter("paymentStatus");
            
            OrderDAO dao = new OrderDAO();
            boolean success = dao.updatePaymentStatus(orderId, paymentStatus);
            
            if (success) {
                req.setAttribute("message", "Payment status updated successfully!");
            } else {
                req.setAttribute("error", "Failed to update payment status!");
            }
        } catch (Exception e) {
            req.setAttribute("error", "Error updating payment: " + e.getMessage());
        }
        
        resp.sendRedirect("manage-orders");
    }
    
    private void handleDeleteOrder(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            int orderId = Integer.parseInt(req.getParameter("orderId"));
            
            OrderDAO dao = new OrderDAO();
            boolean success = dao.deleteOrder(orderId);
            
            if (success) {
                req.setAttribute("message", "Order deleted successfully!");
            } else {
                req.setAttribute("error", "Failed to delete order!");
            }
        } catch (Exception e) {
            req.setAttribute("error", "Error deleting order: " + e.getMessage());
        }
        
        resp.sendRedirect("manage-orders");
    }
    
    /**
     * Map pizza type to ProductID - temporarily using fixed IDs
     */
    private int mapPizzaTypeToProductId(String pizzaType) {
        switch (pizzaType) {
            case "Pepperoni": return 1;
            case "Hawaiian": return 2;
            case "Margherita": return 3;
            case "BBQ Chicken": return 1; // fallback to 1
            case "Veggie": return 2; // fallback to 2
            default: return 1; // default fallback
        }
    }
    
    /**
     * Escape string for JSON - handle special characters
     */
    private String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\")
                  .replace("\"", "\\\"")
                  .replace("\n", "\\n")
                  .replace("\r", "\\r")
                  .replace("\t", "\\t")
                  .replace("\b", "\\b")
                  .replace("\f", "\\f");
    }
}