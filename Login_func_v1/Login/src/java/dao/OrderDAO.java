/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.*;
import models.*;

/**
 *
 * @author duongtanki
 */
public class OrderDAO extends DBContext {

    // Tạo đơn hàng mới
    public int createOrder(int staffId, String tableNumber, String customerName, String customerPhone, String notes, List<Orderdetail> orderDetails) throws Exception {
        int orderId = 0;
        Connection con = null;
        PreparedStatement ps1 = null;
        PreparedStatement ps2 = null;
        ResultSet rs = null;

        try {
            con = getConnection();
            con.setAutoCommit(false);

            // 1. Insert Orders
            String sql1 = "INSERT INTO Orders (StaffID, TableNumber, Status, TotalMoney, PaymentStatus, CustomerName, CustomerPhone, Notes) VALUES (?, ?, 0, 0, 'Unpaid', ?, ?, ?)";
            ps1 = con.prepareStatement(sql1, Statement.RETURN_GENERATED_KEYS);
            ps1.setInt(1, staffId);
            ps1.setString(2, tableNumber);
            ps1.setString(3, customerName);
            ps1.setString(4, customerPhone);
            ps1.setString(5, notes);
            ps1.executeUpdate();

            rs = ps1.getGeneratedKeys();
            if (rs.next()) {
                orderId = rs.getInt(1);
            }

            // 2. Insert OrderDetails và tính tổng tiền
            double totalMoney = 0;
            String sql2 = "INSERT INTO OrderDetails (OrderID, ProductID, Quantity, UnitPrice, TotalPrice, SpecialInstructions) VALUES (?, ?, ?, ?, ?, ?)";
            ps2 = con.prepareStatement(sql2);
            for (Orderdetail detail : orderDetails) {
                detail.setOrderId(orderId);
                ps2.setInt(1, detail.getOrderId());
                ps2.setInt(2, detail.getProductId());
                ps2.setInt(3, detail.getQuantity());
                ps2.setDouble(4, detail.getUnitPrice());
                ps2.setDouble(5, detail.getTotalPrice());
                ps2.setString(6, detail.getSpecialInstructions());
                ps2.addBatch();
                totalMoney += detail.getTotalPrice();
            }
            ps2.executeBatch();

            // 3. Cập nhật tổng tiền cho đơn hàng
            String sql3 = "UPDATE Orders SET TotalMoney = ? WHERE OrderID = ?";
            try (PreparedStatement ps3 = con.prepareStatement(sql3)) {
                ps3.setDouble(1, totalMoney);
                ps3.setInt(2, orderId);
                ps3.executeUpdate();
            }

            con.commit();

        } catch (Exception e) {
            if (con != null) con.rollback();
            throw e;
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps1 != null) ps1.close();
                if (ps2 != null) ps2.close();
                if (con != null) {
                    con.setAutoCommit(true);
                    con.close();
                }
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }
        return orderId;
    }



    // Lấy tất cả đơn hàng
    public List<Order> getAllOrders() {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT * FROM Orders ORDER BY OrderDate DESC";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Order order = new Order(
                        rs.getInt("OrderID"),
                        rs.getInt("StaffID"),
                        rs.getString("TableNumber"),
                        rs.getTimestamp("OrderDate"),
                        rs.getInt("Status"),
                        rs.getDouble("TotalMoney"),
                        rs.getString("PaymentStatus"),
                        rs.getString("CustomerName"),
                        rs.getString("CustomerPhone"),
                        rs.getString("Notes")
                );
                list.add(order);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Lấy đơn hàng theo ID
    public Order getOrderById(int orderId) {
        String sql = "SELECT * FROM Orders WHERE OrderID = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new Order(
                            rs.getInt("OrderID"),
                            rs.getInt("StaffID"),
                            rs.getString("TableNumber"),
                            rs.getTimestamp("OrderDate"),
                            rs.getInt("Status"),
                            rs.getDouble("TotalMoney"),
                            rs.getString("PaymentStatus"),
                            rs.getString("CustomerName"),
                            rs.getString("CustomerPhone"),
                            rs.getString("Notes")
                    );
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // Lấy chi tiết đơn hàng
    public List<Orderdetail> getOrderDetailsByOrderId(int orderId) {
        List<Orderdetail> list = new ArrayList<>();
        String sql = "SELECT od.*, p.ProductName FROM OrderDetails od " +
                    "JOIN Products p ON od.ProductID = p.ProductID " +
                    "WHERE od.OrderID = ?";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Orderdetail detail = new Orderdetail(
                            rs.getInt("OrderDetailID"),
                            rs.getInt("OrderID"),
                            rs.getInt("ProductID"),
                            rs.getInt("Quantity"),
                            rs.getDouble("UnitPrice"),
                            rs.getDouble("TotalPrice"),
                            rs.getString("SpecialInstructions")
                    );
                    list.add(detail);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Cập nhật trạng thái đơn hàng
    public boolean updateOrderStatus(int orderId, int status) {
        String sql = "UPDATE Orders SET Status = ? WHERE OrderID = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, status);
            ps.setInt(2, orderId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // Cập nhật trạng thái thanh toán
    public boolean updatePaymentStatus(int orderId, String paymentStatus) {
        String sql = "UPDATE Orders SET PaymentStatus = ? WHERE OrderID = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, paymentStatus);
            ps.setInt(2, orderId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // Xóa đơn hàng
    public boolean deleteOrder(int orderId) {
        String deleteDetailsSql = "DELETE FROM OrderDetails WHERE OrderID = ?";
        String deleteOrderSql = "DELETE FROM Orders WHERE OrderID = ?";
        try (Connection con = getConnection()) {
            con.setAutoCommit(false);
            
            // 1. Xóa chi tiết đơn hàng trước
            try (PreparedStatement ps1 = con.prepareStatement(deleteDetailsSql)) {
                ps1.setInt(1, orderId);
                ps1.executeUpdate();
            }

            // 2. Sau đó xóa đơn hàng
            try (PreparedStatement ps2 = con.prepareStatement(deleteOrderSql)) {
                ps2.setInt(1, orderId);
                int result = ps2.executeUpdate();
                con.commit();
                return result > 0;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // Lấy đơn hàng theo trạng thái
    public List<Order> getOrdersByStatus(int status) {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT * FROM Orders WHERE Status = ? ORDER BY OrderDate DESC";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, status);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order order = new Order(
                            rs.getInt("OrderID"),
                            rs.getInt("StaffID"),
                            rs.getString("TableNumber"),
                            rs.getTimestamp("OrderDate"),
                            rs.getInt("Status"),
                            rs.getDouble("TotalMoney"),
                            rs.getString("PaymentStatus"),
                            rs.getString("CustomerName"),
                            rs.getString("CustomerPhone"),
                            rs.getString("Notes")
                    );
                    list.add(order);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Đếm số đơn hàng
    public int countAllOrders() {
        int count = 0;
        String sql = "SELECT COUNT(*) FROM Orders";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                count = rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return count;
    }
    
    // ===== CHATBOT-SPECIFIC METHODS =====
    
    /**
     * Get customer's recent orders by phone number
     * Used by chatbot to show order history
     * 
     * @param customerPhone Customer phone number
     * @param limit Maximum number of orders to retrieve
     * @return List of recent orders
     */
    public List<Order> getCustomerRecentOrders(String customerPhone, int limit) {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT TOP (?) * FROM Orders " +
                     "WHERE CustomerPhone = ? " +
                     "ORDER BY OrderDate DESC";
        
        try (Connection con = getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, limit);
            ps.setString(2, customerPhone);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order order = new Order(
                            rs.getInt("OrderID"),
                            rs.getInt("StaffID"),
                            rs.getString("TableNumber"),
                            rs.getTimestamp("OrderDate"),
                            rs.getInt("Status"),
                            rs.getDouble("TotalMoney"),
                            rs.getString("PaymentStatus"),
                            rs.getString("CustomerName"),
                            rs.getString("CustomerPhone"),
                            rs.getString("Notes")
                    );
                    list.add(order);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
    
    /**
     * Get order details with product information
     * Used by chatbot to show detailed order information
     * 
     * @param orderId Order ID
     * @return OrderWithDetails object containing order and its items
     */
    public OrderWithDetails getOrderDetails(int orderId) {
        OrderWithDetails orderDetails = new OrderWithDetails();
        
        // Get order information
        Order order = getOrderById(orderId);
        if (order == null) {
            return null;
        }
        orderDetails.setOrder(order);
        
        // Get order items with product details
        String sql = "SELECT od.*, p.ProductName, p.Description, p.ImageURL " +
                     "FROM OrderDetails od " +
                     "JOIN Product p ON od.ProductID = p.ProductID " +
                     "WHERE od.OrderID = ?";
        
        List<OrderDetailWithProduct> items = new ArrayList<>();
        
        try (Connection con = getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    OrderDetailWithProduct item = new OrderDetailWithProduct();
                    item.setOrderDetailId(rs.getInt("OrderDetailID"));
                    item.setOrderId(rs.getInt("OrderID"));
                    item.setProductId(rs.getInt("ProductID"));
                    item.setProductName(rs.getString("ProductName"));
                    item.setQuantity(rs.getInt("Quantity"));
                    item.setUnitPrice(rs.getDouble("UnitPrice"));
                    item.setTotalPrice(rs.getDouble("TotalPrice"));
                    item.setSpecialInstructions(rs.getString("SpecialInstructions"));
                    items.add(item);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        orderDetails.setItems(items);
        return orderDetails;
    }
    
    /**
     * Get customer's order count
     * Used by chatbot for analytics
     * 
     * @param customerPhone Customer phone number
     * @return Total number of orders
     */
    public int getCustomerOrderCount(String customerPhone) {
        int count = 0;
        String sql = "SELECT COUNT(*) FROM Orders WHERE CustomerPhone = ?";
        
        try (Connection conn = getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, customerPhone);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    count = rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return count;
    }
    
    /**
     * Get customer's total spending
     * Used by chatbot to show customer statistics
     * 
     * @param customerPhone Customer phone number
     * @return Total amount spent
     */
    public double getCustomerTotalSpending(String customerPhone) {
        double total = 0;
        String sql = "SELECT SUM(TotalMoney) FROM Orders " +
                     "WHERE CustomerPhone = ? AND Status != 3";  // Exclude cancelled orders
        
        try (Connection conn = getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, customerPhone);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    total = rs.getDouble(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return total;
    }
    
    /**
     * Helper class to hold order with detailed items
     */
    public static class OrderWithDetails {
        private Order order;
        private List<OrderDetailWithProduct> items;
        
        public OrderWithDetails() {
            this.items = new ArrayList<>();
        }
        
        public Order getOrder() {
            return order;
        }
        
        public void setOrder(Order order) {
            this.order = order;
        }
        
        public List<OrderDetailWithProduct> getItems() {
            return items;
        }
        
        public void setItems(List<OrderDetailWithProduct> items) {
            this.items = items;
        }
    }
    
    /**
     * Helper class for order detail with product info
     */
    public static class OrderDetailWithProduct {
        private int orderDetailId;
        private int orderId;
        private int productId;
        private String productName;
        private int quantity;
        private double unitPrice;
        private double totalPrice;
        private String specialInstructions;
        
        // Getters and Setters
        public int getOrderDetailId() {
            return orderDetailId;
        }
        
        public void setOrderDetailId(int orderDetailId) {
            this.orderDetailId = orderDetailId;
        }
        
        public int getOrderId() {
            return orderId;
        }
        
        public void setOrderId(int orderId) {
            this.orderId = orderId;
        }
        
        public int getProductId() {
            return productId;
        }
        
        public void setProductId(int productId) {
            this.productId = productId;
        }
        
        public String getProductName() {
            return productName;
        }
        
        public void setProductName(String productName) {
            this.productName = productName;
        }
        
        public int getQuantity() {
            return quantity;
        }
        
        public void setQuantity(int quantity) {
            this.quantity = quantity;
        }
        
        public double getUnitPrice() {
            return unitPrice;
        }
        
        public void setUnitPrice(double unitPrice) {
            this.unitPrice = unitPrice;
        }
        
        public double getTotalPrice() {
            return totalPrice;
        }
        
        public void setTotalPrice(double totalPrice) {
            this.totalPrice = totalPrice;
        }
        
        public String getSpecialInstructions() {
            return specialInstructions;
        }
        
        public void setSpecialInstructions(String specialInstructions) {
            this.specialInstructions = specialInstructions;
        }
    }
}
