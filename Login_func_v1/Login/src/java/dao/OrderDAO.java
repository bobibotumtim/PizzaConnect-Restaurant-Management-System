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

    // Create a new order with order details
    public int createOrder(int staffId, String tableNumber, String customerName, String customerPhone, String notes, List<Orderdetail> orderDetails) throws Exception {
        int orderId = 0;
        Connection con = null;
        PreparedStatement ps1 = null;
        PreparedStatement ps2 = null;
        ResultSet rs = null;

        try {
            con = getConnection();
            con.setAutoCommit(false);

            // 1. Insert into Orders table
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

            // 2. Insert into OrderDetails table
            double totalMoney = 0;
            String sql2 = "INSERT INTO OrderDetail (OrderID, ProductID, Quantity, UnitPrice, TotalPrice, SpecialInstructions, EmployeeID, Status, StartTime, EndTime) "
                    + "VALUES (?, ?, ?, ?, ?, ?, NULL, 'Waiting', NULL, NULL)";
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

            // 3. Update total money in Orders table
            String sql3 = "UPDATE Orders SET TotalMoney = ? WHERE OrderID = ?";
            try (PreparedStatement ps3 = con.prepareStatement(sql3)) {
                ps3.setDouble(1, totalMoney);
                ps3.setInt(2, orderId);
                ps3.executeUpdate();
            }

            con.commit();

        } catch (Exception e) {
            if (con != null) {
                con.rollback();
            }
            throw e;
        } finally {
            try {
                if (rs != null) {
                    rs.close();
                }
                if (ps1 != null) {
                    ps1.close();
                }
                if (ps2 != null) {
                    ps2.close();
                }
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

    // Get all orders
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

    // Get order by ID
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

    // Get order details by OrderID
//    public List<Orderdetail> getOrderDetailsByOrderId(int orderId) {
//        List<Orderdetail> list = new ArrayList<>();
//        String sql = "SELECT od.*, p.ProductName FROM OrderDetails od " +
//                    "JOIN Product p ON od.ProductID = p.ProductID " +
//                    "WHERE od.OrderID = ?";
//        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
//            ps.setInt(1, orderId);
//            try (ResultSet rs = ps.executeQuery()) {
//                while (rs.next()) {
//                    Orderdetail detail = new Orderdetail(
//                            rs.getInt("OrderDetailID"),
//                            rs.getInt("OrderID"),
//                            rs.getInt("ProductID"),
//                            rs.getInt("Quantity"),
//                            rs.getDouble("UnitPrice"),
//                            rs.getDouble("TotalPrice"),
//                            rs.getString("SpecialInstructions")
//                    );
//                    list.add(detail);
//                }
//            }
//        } catch (Exception e) {
//            e.printStackTrace();
//        }
//        return list;
//    }
    public List<Orderdetail> getOrderDetailsByOrderId(int orderId) {
        List<Orderdetail> list = new ArrayList<>();
        String sql = "SELECT od.*, p.ProductName "
                + "FROM OrderDetail od "
                + "JOIN Product p ON od.ProductID = p.ProductID "
                + "WHERE od.OrderID = ?";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Orderdetail detail = new Orderdetail(
                            rs.getInt("OrderDetailID"),
                            rs.getInt("OrderID"),
                            rs.getInt("ProductID"),
                            rs.getString("ProductName"), // ✅ thêm product name
                            rs.getInt("Quantity"),
                            rs.getDouble("UnitPrice"),
                            rs.getDouble("TotalPrice"),
                            rs.getString("SpecialInstructions"),
                            rs.getObject("EmployeeID") != null ? rs.getInt("EmployeeID") : null,
                            rs.getString("Status"),
                            rs.getTimestamp("StartTime"),
                            rs.getTimestamp("EndTime")
                    );
                    list.add(detail);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Update order status
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

    public boolean updateOrderDetailStatus(int orderDetailId, String status, Integer employeeId) {
        String sql = "UPDATE OrderDetail SET Status = ?, EmployeeID = ?, "
                + "StartTime = CASE WHEN ? = 'Cooking' THEN GETDATE() ELSE StartTime END, "
                + "EndTime = CASE WHEN ? = 'Done' THEN GETDATE() ELSE EndTime END "
                + "WHERE OrderDetailID = ?";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, status);
            if (employeeId != null) {
                ps.setInt(2, employeeId);
            } else {
                ps.setNull(2, java.sql.Types.INTEGER);
            }
            ps.setString(3, status);
            ps.setString(4, status);
            ps.setInt(5, orderDetailId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Update payment status
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

    // Delete order by ID
    public boolean deleteOrder(int orderId) {
        String deleteDetailsSql = "DELETE FROM OrderDetail WHERE OrderID = ?";
        String deleteOrderSql = "DELETE FROM Orders WHERE OrderID = ?";
        try (Connection con = getConnection()) {
            con.setAutoCommit(false);

            // 1. Delete order details first
            try (PreparedStatement ps1 = con.prepareStatement(deleteDetailsSql)) {
                ps1.setInt(1, orderId);
                ps1.executeUpdate();
            }

            // 2. Then delete the order
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

    // Get orders by status
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

    // Count all orders
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

    // === OrderDetail DAO Section (bổ sung vào cuối OrderDAO) ===
    public List<Orderdetail> getOrderDetailsByStatus(String status) {
        List<Orderdetail> list = new ArrayList<>();
        String sql = """
        SELECT od.*, p.ProductName 
        FROM OrderDetail od
        JOIN Product p ON od.ProductID = p.ProductID
        WHERE od.Status = ?
        ORDER BY od.StartTime DESC
    """;

        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, status);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Orderdetail d = new Orderdetail();
                    d.setOrderDetailId(rs.getInt("OrderDetailID"));
                    d.setOrderId(rs.getInt("OrderID"));
                    d.setProductId(rs.getInt("ProductID"));
                    d.setQuantity(rs.getInt("Quantity"));
                    d.setTotalPrice(rs.getDouble("TotalPrice"));
                    d.setSpecialInstructions(rs.getString("SpecialInstructions"));
                    d.setEmployeeId(rs.getInt("EmployeeID"));
                    d.setStatus(rs.getString("Status"));
                    d.setStartTime(rs.getTimestamp("StartTime"));
                    d.setEndTime(rs.getTimestamp("EndTime"));
                    d.setProductName(rs.getString("ProductName"));
                    list.add(d);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean updateOrderDetailStatus(int orderDetailId, String status, int employeeId) {
        String sql = """
        UPDATE OrderDetail 
        SET Status = ?, 
            EmployeeID = ?, 
            StartTime = CASE WHEN ? = 'Cooking' THEN GETDATE() ELSE StartTime END,
            EndTime = CASE WHEN ? = 'Done' THEN GETDATE() ELSE EndTime END
        WHERE OrderDetailID = ?
    """;
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, employeeId);
            ps.setString(3, status);
            ps.setString(4, status);
            ps.setInt(5, orderDetailId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

}
