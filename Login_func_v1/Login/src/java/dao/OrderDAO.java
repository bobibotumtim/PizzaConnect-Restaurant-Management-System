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
import java.time.LocalDate;

import java.util.*;
import models.*;

/**
 *
 * @author duongtanki
 */
public class OrderDAO extends MyDAO {

    public int createOrder(String username, String fullname, String phone, String address, List<Shoes> cart) throws Exception {
    int orderId = 0;
    Connection con = null;
    PreparedStatement ps1 = null;
    PreparedStatement ps2 = null;
    ResultSet rs = null;

    try {
        con = getConnection();
        con.setAutoCommit(false);

        // 1. Insert Orders
        String sql1 = "INSERT INTO Orders (account_id, fullname, phone, address, status, order_date) VALUES (?, ?, ?, ?, 'Pending', GETDATE())";
        ps1 = con.prepareStatement(sql1, Statement.RETURN_GENERATED_KEYS);
        ps1.setString(1, username);
        ps1.setString(2, fullname);
        ps1.setString(3, phone);
        ps1.setString(4, address);
        ps1.executeUpdate();

        rs = ps1.getGeneratedKeys();
        if (rs.next()) {
            orderId = rs.getInt(1);
        }

        // 2. Insert OrderDetails
        String sql2 = "INSERT INTO OrderDetails (order_id, product_id, quantity, price) VALUES (?, ?, ?, ?)";
        ps2 = con.prepareStatement(sql2);
        for (Shoes s : cart) {
            ps2.setInt(1, orderId);
            ps2.setInt(2, s.getId());
            ps2.setInt(3, 1);
            ps2.setDouble(4, s.getPrice());
            ps2.addBatch();
        }
        ps2.executeBatch();

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



//    public int countAll() {
//        int count = 0;
//        String sql = "SELECT COUNT(*) FROM [Orders]"; // Đảm bảo đúng tên bảng Orders
//        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
//
//            if (rs.next()) {
//                count = rs.getInt(1);
//            }
//        } catch (Exception e) {
//            e.printStackTrace();
//        }
//        return count;
//    }

//    public int insertOrder(LocalDate orderDate, String userName, double totalMoney, String address) throws SQLException {
//        String sql = "INSERT INTO orders (order_date, user_name, total_money, address, status) VALUES (?, ?, ?, ?, ?)";
//
//        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
//
//            pstmt.setDate(1, java.sql.Date.valueOf(orderDate));
//            pstmt.setString(2, userName);
//            pstmt.setDouble(3, totalMoney);
//            pstmt.setString(4, address);
//            pstmt.setString(5, "PENDING");
//
//            int affectedRows = pstmt.executeUpdate();
//
//            if (affectedRows == 0) {
//                throw new SQLException("Creating order failed, no rows affected.");
//            }
//
//            try (ResultSet generatedKeys = pstmt.getGeneratedKeys()) {
//                if (generatedKeys.next()) {
//                    return generatedKeys.getInt(1);
//                } else {
//                    throw new SQLException("Creating order failed, no ID obtained.");
//                }
//            }
//        }
//    }
//
//    public boolean insertOrder(String userName, String address, double totalMoney, int status) {
//        String sql = "INSERT INTO [Order] (UserName, Address, TotalMoney, Status, Date) VALUES (?, ?, ?, ?, GETDATE())";
//
//        try (Connection con = new DBContext().getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
//
//            ps.setString(1, userName);
//            ps.setString(2, address);
//            ps.setDouble(3, totalMoney);
//            ps.setInt(4, status);
//
//            return ps.executeUpdate() > 0;
//        } catch (Exception e) {
//            e.printStackTrace();
//            return false;
//        }
//    }
    public int insertOrder(LocalDate orderDate, String userName, double totalMoney, String address) throws SQLException {
        String sql = "INSERT INTO Orders (Date, UserName, TotalMoney, Address, Status) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            pstmt.setDate(1, java.sql.Date.valueOf(orderDate));
            pstmt.setString(2, userName);
            pstmt.setDouble(3, totalMoney);
            pstmt.setString(4, address);
            pstmt.setInt(5, 0); // 0 = pending

            int affectedRows = pstmt.executeUpdate();

            if (affectedRows == 0) {
                throw new SQLException("Creating order failed, no rows affected.");
            }

            try (ResultSet generatedKeys = pstmt.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    return generatedKeys.getInt(1);
                } else {
                    throw new SQLException("Creating order failed, no ID obtained.");
                }
            }
        }
    }

    public void insertOrderDetails(int orderId, Map<Integer, OrderItem> itemMap) throws SQLException {
        String sql = "INSERT INTO order_details (order_id, product_id, quantity, price, total_price) VALUES (?, ?, ?, ?, ?)";

        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {

            for (Map.Entry<Integer, OrderItem> entry : itemMap.entrySet()) {
                Integer productId = entry.getKey();
                OrderItem orderItem = entry.getValue();

                int quantity = orderItem.getQuantity();
                double price = orderItem.getProduct().getPrice();
                double totalPrice = price * quantity;

                pstmt.setInt(1, orderId);
                pstmt.setInt(2, productId);
                pstmt.setInt(3, quantity);
                pstmt.setDouble(4, price);
                pstmt.setDouble(5, totalPrice);

                pstmt.addBatch();
            }

            pstmt.executeBatch();
        }
    }

    public List<Order> getAllOrders() {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT * FROM [Orders] ORDER BY Date DESC";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                int id = rs.getInt("OrderID");
                System.out.println("🟢 Found order ID from DB: " + id);

                Order order = new Order(
                        id,
                        rs.getTimestamp("Date"),
                        rs.getString("UserName"),
                        rs.getDouble("TotalMoney"),
                        rs.getInt("Status"),
                        rs.getString("Address")
                );
                list.add(order);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

//    public boolean checkExistUsername(String username) {
//        String sql = "SELECT * FROM [User] WHERE username = ?";
//        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
//            ps.setString(1, username);
//            ResultSet rs = ps.executeQuery();
//            return rs.next(); // true nếu tồn tại
//        } catch (Exception e) {
//            e.printStackTrace();
//        }
//        return false;
//    }

//    public void insertUser(User user) {
//        String sql = "INSERT INTO [User] (username, password, fullname, email, role) VALUES (?, ?, ?, ?, ?)";
//        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
//            ps.setString(1, user.getUsername());
//            ps.setString(2, user.getPassword());
//            ps.setInt(5, user.getRole());
//            ps.executeUpdate();
//        } catch (Exception e) {
//            e.printStackTrace();
//        }
//    }

    public void updateStatus(int orderId, int status) {
        String sql = "UPDATE [Orders] SET Status = ? WHERE OrderID = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, status);
            ps.setInt(2, orderId);
            ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public boolean deleteOrderById(int orderId) {
        String deleteDetailsSql = "DELETE FROM [OrderDetails] WHERE OrderID = ?";
        String deleteOrderSql = "DELETE FROM [Orders] WHERE OrderID = ?";
        try (Connection con = new DBContext().getConnection()) {

            // 1. Xóa chi tiết đơn hàng trước
            try (PreparedStatement ps1 = con.prepareStatement(deleteDetailsSql)) {
                ps1.setInt(1, orderId);
                ps1.executeUpdate();
            }

            // 2. Sau đó xóa đơn hàng
            try (PreparedStatement ps2 = con.prepareStatement(deleteOrderSql)) {
                ps2.setInt(1, orderId);
                return ps2.executeUpdate() > 0;
            }

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

//    public void addOrder(Order order) {
//        String sql = "INSERT INTO [Orders] (userName, address, totalMoney, status, date) VALUES (?, ?, ?, ?, GETDATE())";
//        try {
//            DBContext db = new DBContext(); // Tạo đối tượng
//            Connection conn = db.getConnection(); // Gọi phương thức không static
//            PreparedStatement ps = conn.prepareStatement(sql);
//
//            ps.setString(1, order.getUserName());
//            ps.setString(2, order.getAddress());
//            ps.setDouble(3, order.getTotalMoney());
//            ps.setInt(4, order.getStatus());
//
//            ps.executeUpdate();
//            ps.close();
//            conn.close();
//        } catch (Exception e) {
//            e.printStackTrace();
//        }
//    }
    
    public Order getOrderById(int orderId) {
    String sql = "SELECT * FROM Orders WHERE OrderID = ?";
    try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setInt(1, orderId);
        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return new Order(
                        rs.getInt("OrderID"),
                        rs.getTimestamp("Date"),
                        rs.getString("UserName"),
                        rs.getDouble("TotalMoney"),
                        rs.getInt("Status"),
                        rs.getString("Address")
                );
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
    return null;
}

//    public List<Category> getAllCategories() {
//    List<Category> list = new ArrayList<>();
//    String sql = "SELECT id, name FROM Category";
//    try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
//        while (rs.next()) {
//            list.add(new Category(rs.getInt("id"), rs.getString("name")));
//        }
//    } catch (Exception e) {
//        e.printStackTrace();
//    }
//    return list;
//}

}
