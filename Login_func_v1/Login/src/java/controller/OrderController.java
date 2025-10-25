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
        if (action == null || action.isEmpty()) {
            // Suy luận action từ URL nếu không có tham số action
            String requestURI = req.getRequestURI();
            if (requestURI.contains("add-order")) {
                action = "new"; // hỗ trợ đường dẫn /add-order
            } else if (requestURI.contains("manage-orders")) {
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

            case "getOrder":
                // Trả về JSON cho AJAX request
                int getOrderId = Integer.parseInt(req.getParameter("id"));
                Order getOrder = dao.getOrderById(getOrderId);
                resp.setContentType("application/json");
                resp.setCharacterEncoding("UTF-8");
                if (getOrder != null) {
                    resp.getWriter().write("{\"success\": true, \"order\": {" +
                        "\"orderID\": " + getOrder.getOrderID() + "," +
                        "\"customerID\": " + getOrder.getCustomerID() + "," +
                        "\"employeeID\": " + getOrder.getEmployeeID() + "," +
                        "\"tableID\": " + getOrder.getTableID() + "," +
                        "\"orderDate\": \"" + getOrder.getOrderDate() + "\"," +
                        "\"status\": " + getOrder.getStatus() + "," +
                        "\"paymentStatus\": \"" + getOrder.getPaymentStatus() + "\"," +
                        "\"totalPrice\": " + getOrder.getTotalPrice() + "," +
                        "\"note\": \"" + (getOrder.getNote() != null ? getOrder.getNote().replace("\"", "\\\"") : "") + "\"" +
                        "}}");
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
                
                for (Order order : orders) {
                    if (order.getStatus() == 2) { // Completed
                        completedOrders++;
                    }
                    totalRevenue += order.getTotalPrice();
                }
                
                req.setAttribute("totalOrders", totalOrders);
                req.setAttribute("completedOrders", completedOrders);
                req.setAttribute("totalRevenue", totalRevenue);
                
                req.getRequestDispatcher("/view/ManageOrders.jsp").forward(req, resp);
                break;
                
            default:
                List<Order> allOrders = dao.getAll();
                req.setAttribute("orders", allOrders);
                req.getRequestDispatcher("/view/order-list.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        
        String action = req.getParameter("action");
        
        if ("add".equals(action)) {
            // Xử lý thêm đơn hàng từ modal
            handleAddOrderFromModal(req, resp);
        } else if ("update".equals(action)) {
            // Xử lý cập nhật đơn hàng từ modal
            handleUpdateOrderFromModal(req, resp);
        } else {
            // Xử lý form cũ
            handleLegacyForm(req, resp);
        }
    }
    
    private void handleAddOrderFromModal(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        try {
            System.out.println("=== handleAddOrderFromModal START ===");
            
            String customerName = req.getParameter("customerName");
            String pizzaType = req.getParameter("pizzaType");
            int quantity = parseIntSafe(req.getParameter("quantity"));
            double price = parseDoubleSafe(req.getParameter("price"));
            double totalPrice = quantity * price;
            int status = parseIntSafe(req.getParameter("status"));
            
            System.out.println("Customer: " + customerName + ", Pizza: " + pizzaType + 
                            ", Qty: " + quantity + ", Price: " + price + ", Status: " + status);
            
            // Validation
            if (customerName == null || customerName.trim().isEmpty()) {
                System.out.println("ERROR: Customer name is empty");
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                resp.getWriter().write("Tên khách hàng không được để trống");
                return;
            }
            
            if (quantity <= 0 || price <= 0) {
                System.out.println("ERROR: Invalid quantity or price");
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                resp.getWriter().write("Số lượng và giá phải lớn hơn 0");
                return;
            }
            
            // Kiểm tra kết nối database
            OrderDAO dao = new OrderDAO();
            if (dao.getConnection() == null) {
                System.out.println("ERROR: Database connection is null");
                resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                resp.getWriter().write("Không thể kết nối database");
                return;
            }
            
            // Tạo OrderDetail cho pizza
            List<OrderDetail> details = new ArrayList<>();
            OrderDetail detail = new OrderDetail();
            detail.setProductID(1); // Giả sử product ID = 1 cho pizza
            detail.setQuantity(quantity);
            detail.setTotalPrice(totalPrice);
            detail.setSpecialInstructions("Loại: " + pizzaType);
            details.add(detail);
            
            System.out.println("Creating order with details: " + details.size());
            
            // Tạo đơn hàng với customerID = 1, employeeID = 1, tableID = 1
            int orderId = dao.createOrder(1, 1, 1, "Đơn hàng từ modal: " + customerName, details);
            
            System.out.println("Order created with ID: " + orderId);
            
            // Cập nhật trạng thái nếu khác pending
            if (status != 0) {
                dao.updateOrderStatus(orderId, status);
                System.out.println("Order status updated to: " + status);
            }
            
            resp.setStatus(HttpServletResponse.SC_OK);
            resp.getWriter().write("Đơn hàng đã được thêm thành công");
            System.out.println("=== handleAddOrderFromModal SUCCESS ===");
            
        } catch (Exception e) {
            System.out.println("=== handleAddOrderFromModal ERROR ===");
            e.printStackTrace();
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            resp.getWriter().write("Có lỗi xảy ra khi thêm đơn hàng: " + e.getMessage());
        }
    }
    
    private void handleUpdateOrderFromModal(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        try {
            System.out.println("=== handleUpdateOrderFromModal START ===");
            
            int orderID = parseIntSafe(req.getParameter("orderID"));
            int customerID = parseIntSafe(req.getParameter("customerID"));
            int employeeID = parseIntSafe(req.getParameter("employeeID"));
            int tableID = parseIntSafe(req.getParameter("tableID"));
            String orderDateStr = req.getParameter("orderDate");
            int status = parseIntSafe(req.getParameter("status"));
            String paymentStatus = req.getParameter("paymentStatus");
            double totalPrice = parseDoubleSafe(req.getParameter("totalPrice"));
            String note = req.getParameter("note");
            
            System.out.println("Updating Order ID: " + orderID + 
                            ", Customer: " + customerID + 
                            ", Employee: " + employeeID + 
                            ", Table: " + tableID + 
                            ", Status: " + status);
            
            // Validation
            if (orderID <= 0) {
                System.out.println("ERROR: Invalid Order ID");
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                resp.getWriter().write("Order ID không hợp lệ");
                return;
            }
            
            if (customerID <= 0 || employeeID <= 0 || tableID <= 0) {
                System.out.println("ERROR: Invalid IDs");
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                resp.getWriter().write("Customer ID, Employee ID và Table ID phải lớn hơn 0");
                return;
            }
            
            // Kiểm tra kết nối database
            OrderDAO dao = new OrderDAO();
            if (dao.getConnection() == null) {
                System.out.println("ERROR: Database connection is null");
                resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                resp.getWriter().write("Không thể kết nối database");
                return;
            }
            
            // Tạo Order object để update
            Order order = new Order();
            order.setOrderID(orderID);
            order.setCustomerID(customerID);
            order.setEmployeeID(employeeID);
            order.setTableID(tableID);
            order.setStatus(status);
            order.setPaymentStatus(paymentStatus);
            order.setTotalPrice(totalPrice);
            order.setNote(note);
            
            // Parse datetime nếu có
            if (orderDateStr != null && !orderDateStr.trim().isEmpty()) {
                try {
                    java.sql.Timestamp orderDate = java.sql.Timestamp.valueOf(orderDateStr.replace("T", " ") + ":00");
                    order.setOrderDate(orderDate);
                } catch (Exception e) {
                    System.out.println("Warning: Could not parse order date: " + orderDateStr);
                }
            }
            
            System.out.println("Updating order with data: " + order.toString());
            
            // Cập nhật đơn hàng
            dao.update(order);
            
            resp.setStatus(HttpServletResponse.SC_OK);
            resp.getWriter().write("Đơn hàng đã được cập nhật thành công");
            System.out.println("=== handleUpdateOrderFromModal SUCCESS ===");
            
        } catch (Exception e) {
            System.out.println("=== handleUpdateOrderFromModal ERROR ===");
            e.printStackTrace();
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            resp.getWriter().write("Có lỗi xảy ra khi cập nhật đơn hàng: " + e.getMessage());
        }
    }
    
    private void handleLegacyForm(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Lấy dữ liệu từ form
        String customerParam = req.getParameter("customerID");
        String employeeParam = req.getParameter("employeeID");
        String tableParam = req.getParameter("tableID");
        String note = req.getParameter("note");

        // Kiểm tra hợp lệ dữ liệu nhập
        int customerID = parseIntSafe(customerParam);
        int employeeID = parseIntSafe(employeeParam);
        int tableID = parseIntSafe(tableParam);

        // Nếu nhập sai (ví dụ chữ, rỗng) → báo lỗi
        if (customerID <= 0 || employeeID <= 0 || tableID <= 0) {
            req.setAttribute("error", "❌ Vui lòng nhập đúng định dạng số cho Customer ID, Employee ID và Table ID.");
            req.getRequestDispatcher("order-form.jsp").forward(req, resp);
            return;
        }

        // Tạo danh sách chi tiết trống (nếu chưa có chi tiết)
        List<OrderDetail> details = new ArrayList<>();

        OrderDAO dao = new OrderDAO();
        try {
            dao.createOrder(customerID, employeeID, tableID, note, details);
            resp.sendRedirect("OrderController?action=list");
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "⚠️ Không thể lưu đơn hàng. Vui lòng thử lại.");
            req.getRequestDispatcher("order-form.jsp").forward(req, resp);
        }
    }

    /**
     * Hàm tiện ích để parse số an toàn
     */
    private int parseIntSafe(String value) {
        try {
            return Integer.parseInt(value);
        } catch (Exception e) {
            return -1; // trả về -1 nếu không phải số
        }
    }
    
    /**
     * Hàm tiện ích để parse double an toàn
     */
    private double parseDoubleSafe(String value) {
        try {
            return Double.parseDouble(value);
        } catch (Exception e) {
            return -1.0; // trả về -1 nếu không phải số
        }
    }

}
