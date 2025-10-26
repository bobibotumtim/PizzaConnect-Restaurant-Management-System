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

            case "getOrder": {
                // Trả về JSON cho AJAX request (bao gồm cả details)
                int getOrderId = Integer.parseInt(req.getParameter("id"));
                Order order = dao.getOrderById(getOrderId);
                List<OrderDetail> details = dao.getOrderDetailsByOrderId(getOrderId);
                resp.setContentType("application/json");
                resp.setCharacterEncoding("UTF-8");
                if (order != null) {
                    StringBuilder sb = new StringBuilder();
                    sb.append('{')
                      .append("\"success\":true,")
                      .append("\"order\":{")
                      .append("\"orderID\":").append(order.getOrderID()).append(',')
                      .append("\"customerID\":").append(order.getCustomerID()).append(',')
                      .append("\"employeeID\":").append(order.getEmployeeID()).append(',')
                      .append("\"tableID\":").append(order.getTableID()).append(',')
                      .append("\"orderDate\":\"").append(order.getOrderDate()).append("\",")
                      .append("\"status\":").append(order.getStatus()).append(',')
                      .append("\"paymentStatus\":\"").append(order.getPaymentStatus() != null ? order.getPaymentStatus() : "").append("\",")
                      .append("\"totalPrice\":").append(order.getTotalPrice()).append(',')
                      .append("\"note\":\"");
                    String safeNote = order.getNote() != null ? order.getNote().replace("\\", "\\\\").replace("\"", "\\\"") : "";
                    sb.append(safeNote).append("\",");
                    // details
                    sb.append("\"details\":[");
                    for (int i = 0; i < details.size(); i++) {
                        OrderDetail d = details.get(i);
                        String si = d.getSpecialInstructions();
                        String safeSI = si != null ? si.replace("\\", "\\\\").replace("\"", "\\\"") : "";
                        sb.append('{')
                          .append("\"orderDetailID\":").append(d.getOrderDetailID()).append(',')
                          .append("\"productID\":").append(d.getProductID()).append(',')
                          .append("\"quantity\":").append(d.getQuantity()).append(',')
                          .append("\"totalPrice\":").append(d.getTotalPrice()).append(',')
                          .append("\"specialInstructions\":\"").append(safeSI).append("\"")
                          .append('}');
                        if (i < details.size() - 1) sb.append(',');
                    }
                    sb.append(']');
                    sb.append('}'); // end order
                    sb.append('}'); // end root
                    resp.getWriter().write(sb.toString());
                } else {
                    resp.getWriter().write("{\"success\": false, \"message\": \"Order not found\"}");
                }
                break;
            }

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

            // Kiểm tra kết nối database
            OrderDAO dao = new OrderDAO();
            if (dao.getConnection() == null) {
                System.out.println("ERROR: Database connection is null");
                resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                resp.getWriter().write("Không thể kết nối database");
                return;
            }

            // Tạo danh sách chi tiết từ nhiều dòng
            List<OrderDetail> details = new ArrayList<>();
            for (int i = 0; i < pizzaTypes.length; i++) {
                int qty = parseIntSafe(quantities[i]);
                double unitPrice = parseDoubleSafe(prices[i]);
                if (qty <= 0 || unitPrice <= 0) {
                    resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    resp.getWriter().write("Số lượng và giá phải lớn hơn 0 (dòng " + (i + 1) + ")");
                    return;
                }
                OrderDetail d = new OrderDetail();
                d.setProductID(1); // Map tạm: 1 = pizza chung
                d.setQuantity(qty);
                d.setTotalPrice(qty * unitPrice);
                d.setSpecialInstructions("Loại: " + pizzaTypes[i]);
                details.add(d);
            }

            System.out.println("Creating order with details: " + details.size());

            // Tạo đơn hàng với customerID = 1, employeeID = 1, tableID = 1
            int orderId = dao.createOrder(1, 1, 1, "Đơn hàng từ modal", details);
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
