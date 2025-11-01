package controller;

import dao.OrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;
import models.Order;
import models.OrderDetail;
import models.User;

public class ManageOrderServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Kiểm tra session và quyền admin/employee
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("Login");
            return;
        }
        
        User user = (User) session.getAttribute("user");
        if (user.getRole() != 1 && user.getRole() != 2) { // 1=admin, 2=employee
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied. Admin or Employee role required.");
            return;
        }
        
        String action = request.getParameter("action");
        OrderDAO orderDAO = new OrderDAO();
        
        if ("view".equals(action)) {
            // Xem chi tiết đơn hàng
            String orderIdStr = request.getParameter("orderId");
            if (orderIdStr != null) {
                try {
                    int orderId = Integer.parseInt(orderIdStr);
                    Order order = orderDAO.getOrderById(orderId);
                    List<Orderdetail> orderDetails = orderDAO.getOrderDetailsByOrderId(orderId);
                    
                    request.setAttribute("order", order);
                    request.setAttribute("orderDetails", orderDetails);
                    request.getRequestDispatcher("view/OrderDetail.jsp").forward(request, response);
                    return;
                } catch (NumberFormatException e) {
                    request.setAttribute("error", "Invalid order ID!");
                }
            }
        } else if ("filter".equals(action)) {
            // Lọc đơn hàng theo trạng thái
            String statusStr = request.getParameter("status");
            if (statusStr != null && !statusStr.isEmpty()) {
                try {
                    int status = Integer.parseInt(statusStr);
                    List<Order> orders = orderDAO.getOrdersByStatus(status);
                    request.setAttribute("orders", orders);
                    request.setAttribute("selectedStatus", status);
                } catch (NumberFormatException e) {
                    request.setAttribute("error", "Invalid status filter!");
                }
            } else {
                List<Order> orders = orderDAO.getAllOrders();
                request.setAttribute("orders", orders);
            }
        } else {
            // Mặc định: hiển thị tất cả đơn hàng
            List<Order> orders = orderDAO.getAllOrders();
            request.setAttribute("orders", orders);
        }
        
        request.setAttribute("currentUser", user);
        request.getRequestDispatcher("view/ManageOrders.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Kiểm tra session và quyền admin/employee
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("Login");
            return;
        }
        
        User user = (User) session.getAttribute("user");
        if (user.getRole() != 1 && user.getRole() != 2) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied. Admin or Employee role required.");
            return;
        }
        
        String action = request.getParameter("action");
        OrderDAO orderDAO = new OrderDAO();
        
        if ("updateStatus".equals(action)) {
            // Cập nhật trạng thái đơn hàng
            String orderIdStr = request.getParameter("orderId");
            String statusStr = request.getParameter("status");
            
            if (orderIdStr != null && statusStr != null) {
                try {
                    int orderId = Integer.parseInt(orderIdStr);
                    int status = Integer.parseInt(statusStr);
                    
                    boolean success = orderDAO.updateOrderStatus(orderId, status);
                    if (success) {
                        request.setAttribute("message", "Order status updated successfully!");
                    } else {
                        request.setAttribute("error", "Failed to update order status!");
                    }
                } catch (NumberFormatException e) {
                    request.setAttribute("error", "Invalid order ID or status!");
                }
            }
        } else if ("updatePayment".equals(action)) {
            // Cập nhật trạng thái thanh toán
            String orderIdStr = request.getParameter("orderId");
            String paymentStatus = request.getParameter("paymentStatus");
            
            if (orderIdStr != null && paymentStatus != null) {
                try {
                    int orderId = Integer.parseInt(orderIdStr);
                    
                    boolean success = orderDAO.updatePaymentStatus(orderId, paymentStatus);
                    if (success) {
                        request.setAttribute("message", "Payment status updated successfully!");
                    } else {
                        request.setAttribute("error", "Failed to update payment status!");
                    }
                } catch (NumberFormatException e) {
                    request.setAttribute("error", "Invalid order ID!");
                }
            }
        } else if ("delete".equals(action)) {
            // Xóa đơn hàng
            String orderIdStr = request.getParameter("orderId");
            
            if (orderIdStr != null) {
                try {
                    int orderId = Integer.parseInt(orderIdStr);
                    
                    boolean success = orderDAO.deleteOrder(orderId);
                    if (success) {
                        request.setAttribute("message", "Order deleted successfully!");
                    } else {
                        request.setAttribute("error", "Failed to delete order!");
                    }
                } catch (NumberFormatException e) {
                    request.setAttribute("error", "Invalid order ID!");
                }
            }
        }
        
        // Redirect để tránh resubmit
        response.sendRedirect("manage-orders");
    }
}