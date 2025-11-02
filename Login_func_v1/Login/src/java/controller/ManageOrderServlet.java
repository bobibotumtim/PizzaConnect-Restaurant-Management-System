package controller;

import dao.OrderDAO;
import dao.ProductDAO;
import models.Order;
import models.OrderDetail;
import models.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "ManageOrderServlet", urlPatterns = {"/manage-orders"})
public class ManageOrderServlet extends HttpServlet {

    private static final int PAGE_SIZE = 10; // Số đơn hàng mỗi trang

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/Login");
            return;
        }

        User user = (User) session.getAttribute("user");
        request.setAttribute("currentUser", user);

        String action = request.getParameter("action");
        
        if ("getOrder".equals(action)) {
            handleGetOrder(request, response);
            return;
        }

        OrderDAO orderDAO = new OrderDAO();
        
        // Lấy trang hiện tại từ parameter, mặc định là trang 1
        int currentPage = 1;
        String pageParam = request.getParameter("page");
        if (pageParam != null && !pageParam.isEmpty()) {
            try {
                currentPage = Integer.parseInt(pageParam);
                if (currentPage < 1) currentPage = 1;
            } catch (NumberFormatException e) {
                currentPage = 1;
            }
        }

        List<Order> orders;
        int totalOrders;
        Integer selectedStatus = null;

        // Xử lý filter theo status
        if ("filter".equals(action)) {
            String statusParam = request.getParameter("status");
            if (statusParam != null && !statusParam.isEmpty()) {
                try {
                    selectedStatus = Integer.parseInt(statusParam);
                    orders = orderDAO.getOrdersByStatusWithPagination(selectedStatus, currentPage, PAGE_SIZE);
                    totalOrders = orderDAO.countOrdersByStatus(selectedStatus);
                } catch (NumberFormatException e) {
                    orders = orderDAO.getOrdersWithPagination(currentPage, PAGE_SIZE);
                    totalOrders = orderDAO.countAllOrders();
                }
            } else {
                orders = orderDAO.getOrdersWithPagination(currentPage, PAGE_SIZE);
                totalOrders = orderDAO.countAllOrders();
            }
        } else {
            orders = orderDAO.getOrdersWithPagination(currentPage, PAGE_SIZE);
            totalOrders = orderDAO.countAllOrders();
        }

        // Tính tổng số trang
        int totalPages = (int) Math.ceil((double) totalOrders / PAGE_SIZE);

        // Set attributes
        request.setAttribute("orders", orders);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalOrders", totalOrders);
        request.setAttribute("selectedStatus", selectedStatus);

        request.getRequestDispatcher("/view/ManageOrders.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        System.out.println("╔════════════════════════════════════════╗");
        System.out.println("║   ManageOrderServlet.doPost() CALLED  ║");
        System.out.println("╚════════════════════════════════════════╝");
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            System.out.println("❌ User not logged in - redirecting to Login");
            response.sendRedirect(request.getContextPath() + "/Login");
            return;
        }

        String action = request.getParameter("action");
        System.out.println("📋 Action received: " + action);
        
        OrderDAO orderDAO = new OrderDAO();

        try {
            switch (action != null ? action : "") {
                case "updateStatus":
                    System.out.println("➡️ Routing to handleUpdateStatus");
                    handleUpdateStatus(request, response, orderDAO);
                    break;
                case "updatePayment":
                    System.out.println("➡️ Routing to handleUpdatePayment");
                    handleUpdatePayment(request, response, orderDAO);
                    break;
                case "delete":
                    System.out.println("➡️ Routing to handleDelete");
                    handleDelete(request, response, orderDAO);
                    break;
                default:
                    System.out.println("⚠️ Unknown action: " + action + " - redirecting to manage-orders");
                    response.sendRedirect(request.getContextPath() + "/manage-orders");
                    break;
            }
        } catch (Exception e) {
            System.out.println("❌ Exception in doPost: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            doGet(request, response);
        }
    }

    private void handleGetOrder(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try {
            int orderId = Integer.parseInt(request.getParameter("id"));
            OrderDAO orderDAO = new OrderDAO();
            ProductDAO productDAO = new ProductDAO();
            
            Order order = orderDAO.getOrderById(orderId);
            if (order == null) {
                response.getWriter().write("{\"success\": false, \"message\": \"Order not found\"}");
                return;
            }

            List<OrderDetail> details = orderDAO.getOrderDetailsByOrderId(orderId);
            
            // Build JSON response
            StringBuilder json = new StringBuilder();
            json.append("{\"success\": true, \"order\": {");
            json.append("\"orderID\": ").append(order.getOrderID()).append(",");
            json.append("\"customerID\": ").append(order.getCustomerID()).append(",");
            json.append("\"tableID\": ").append(order.getTableID()).append(",");
            json.append("\"status\": ").append(order.getStatus()).append(",");
            json.append("\"paymentStatus\": \"").append(order.getPaymentStatus()).append("\",");
            json.append("\"totalPrice\": ").append(order.getTotalPrice()).append(",");
            json.append("\"note\": \"").append(order.getNote() != null ? order.getNote().replace("\"", "\\\"") : "").append("\"");
            json.append("}, \"details\": [");
            
            for (int i = 0; i < details.size(); i++) {
                OrderDetail detail = details.get(i);
                String productName = productDAO.getProductById(detail.getProductID()).getProductName();
                
                if (i > 0) json.append(",");
                json.append("{");
                json.append("\"productName\": \"").append(productName).append("\",");
                json.append("\"quantity\": ").append(detail.getQuantity()).append(",");
                json.append("\"totalPrice\": ").append(detail.getTotalPrice());
                json.append("}");
            }
            
            json.append("]}");
            response.getWriter().write(json.toString());
            
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"success\": false, \"message\": \"" + e.getMessage() + "\"}");
        }
    }

    private void handleUpdateStatus(HttpServletRequest request, HttpServletResponse response, OrderDAO orderDAO)
            throws IOException {
        try {
            int orderId = Integer.parseInt(request.getParameter("orderId"));
            int status = Integer.parseInt(request.getParameter("status"));
            
            System.out.println("🔄 Updating order status - OrderID: " + orderId + ", New Status: " + status);
            
            boolean success = orderDAO.updateOrderStatus(orderId, status);
            
            if (success) {
                System.out.println("✅ Order status updated successfully");
                request.getSession().setAttribute("message", "Cập nhật trạng thái đơn hàng thành công!");
            } else {
                System.out.println("❌ Failed to update order status");
                request.getSession().setAttribute("error", "Không thể cập nhật trạng thái đơn hàng.");
            }
        } catch (Exception e) {
            System.out.println("❌ Exception in handleUpdateStatus: " + e.getMessage());
            e.printStackTrace();
            request.getSession().setAttribute("error", "Lỗi: " + e.getMessage());
        }
        
        response.sendRedirect(request.getContextPath() + "/manage-orders");
    }

    private void handleUpdatePayment(HttpServletRequest request, HttpServletResponse response, OrderDAO orderDAO)
            throws IOException {
        try {
            int orderId = Integer.parseInt(request.getParameter("orderId"));
            String paymentStatus = request.getParameter("paymentStatus");
            
            System.out.println("💰 Updating payment status - OrderID: " + orderId + ", New Payment: " + paymentStatus);
            
            boolean success = orderDAO.updatePaymentStatus(orderId, paymentStatus);
            
            if (success) {
                System.out.println("✅ Payment status updated successfully");
                request.getSession().setAttribute("message", "Cập nhật trạng thái thanh toán thành công!");
            } else {
                System.out.println("❌ Failed to update payment status");
                request.getSession().setAttribute("error", "Không thể cập nhật trạng thái thanh toán.");
            }
        } catch (Exception e) {
            System.out.println("❌ Exception in handleUpdatePayment: " + e.getMessage());
            e.printStackTrace();
            request.getSession().setAttribute("error", "Lỗi: " + e.getMessage());
        }
        
        response.sendRedirect(request.getContextPath() + "/manage-orders");
    }

    private void handleDelete(HttpServletRequest request, HttpServletResponse response, OrderDAO orderDAO)
            throws IOException {
        try {
            int orderId = Integer.parseInt(request.getParameter("orderId"));
            
            System.out.println("🗑️ Deleting order - OrderID: " + orderId);
            
            boolean success = orderDAO.deleteOrder(orderId);
            
            if (success) {
                System.out.println("✅ Order deleted successfully");
                request.getSession().setAttribute("message", "Xóa đơn hàng thành công!");
            } else {
                System.out.println("❌ Failed to delete order");
                request.getSession().setAttribute("error", "Không thể xóa đơn hàng.");
            }
        } catch (Exception e) {
            System.out.println("❌ Exception in handleDelete: " + e.getMessage());
            e.printStackTrace();
            request.getSession().setAttribute("error", "Lỗi: " + e.getMessage());
        }
        
        response.sendRedirect(request.getContextPath() + "/manage-orders");
    }
}
