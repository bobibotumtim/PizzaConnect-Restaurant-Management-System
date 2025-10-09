package service;

import dao.OrderDAO;
import java.util.List;
import java.util.stream.Collectors;
import models.Order;

public class OrderService {
    private OrderDAO orderDAO;
    // Chúng ta có thể thêm ProductDAO ở đây nếu cần kiểm tra tồn kho
    // private ProductDAO productDAO; 

    public OrderService(OrderDAO orderDAO) {
        this.orderDAO = orderDAO;
    }

    public boolean processOrder(int orderId) {
        Order order = orderDAO.getOrderById(orderId);
        if (order != null && order.getStatus() == 0) { // 0 = Pending
            return orderDAO.updateOrderStatus(orderId, 1); // 1 = Processing
        }
        return false;
    }

    public boolean cancelOrder(int orderId) {
        Order order = orderDAO.getOrderById(orderId);
        // Quy tắc: Không cho hủy đơn hàng đã thanh toán
        if (order != null && !"Paid".equalsIgnoreCase(order.getPaymentStatus())) {
            return orderDAO.updateOrderStatus(orderId, 3); // 3 = Cancelled
        }
        return false;
    }

    public List<Order> getOrdersByStatus(int status) {
        // Lọc danh sách đơn hàng từ tất cả các đơn hàng
        return orderDAO.getAllOrders().stream()
                .filter(o -> o.getStatus() == status)
                .collect(Collectors.toList());
    }

    public boolean deleteOrder(int orderId) {
        Order order = orderDAO.getOrderById(orderId);
        // Quy tắc: Chỉ cho phép xóa đơn hàng Pending hoặc Cancelled
        if (order != null && (order.getStatus() == 0 || order.getStatus() == 3)) {
            return orderDAO.deleteOrder(orderId);
        }
        return false;
    }

    public boolean markOrderAsPaid(int orderId) {
        Order order = orderDAO.getOrderById(orderId);
        if (order != null) {
            return orderDAO.updatePaymentStatus(orderId, "Paid");
        }
        return false;
    }
}