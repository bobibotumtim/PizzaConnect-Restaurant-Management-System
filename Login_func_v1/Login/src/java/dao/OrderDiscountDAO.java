package dao;

import models.OrderDiscount;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class OrderDiscountDAO extends DBContext {

    // Lấy tất cả discount áp dụng cho một order
    public List<OrderDiscount> getDiscountsByOrderId(int orderId) {
        List<OrderDiscount> discounts = new ArrayList<>();
        String sql = "SELECT od.OrderID, od.DiscountID, od.Amount, od.AppliedDate, " +
                "d.Description, d.DiscountType, d.Value " +
                "FROM OrderDiscount od " +
                "INNER JOIN Discount d ON od.DiscountID = d.DiscountID " +
                "WHERE od.OrderID = ?";

        try (Connection connection = getConnection();
                PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, orderId);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                OrderDiscount orderDiscount = new OrderDiscount();
                orderDiscount.setOrderId(rs.getInt("OrderID"));
                orderDiscount.setDiscountId(rs.getInt("DiscountID"));
                orderDiscount.setAmount(rs.getDouble("Amount"));
                orderDiscount.setAppliedDate(rs.getString("AppliedDate"));

                discounts.add(orderDiscount);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return discounts;
    }

    // Tính tổng discount amount cho một order
    public double getTotalDiscountAmount(int orderId) {
        double totalDiscount = 0.0;
        String sql = "SELECT SUM(Amount) as TotalDiscount FROM OrderDiscount WHERE OrderID = ?";

        try (Connection connection = getConnection();
                PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, orderId);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                totalDiscount = rs.getDouble("TotalDiscount");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return totalDiscount;
    }

    // Thêm discount vào order
    public boolean addDiscountToOrder(OrderDiscount orderDiscount) {
        String sql = "INSERT INTO OrderDiscount (OrderID, DiscountID, Amount, AppliedDate) VALUES (?, ?, ?, ?)";

        try (Connection connection = getConnection();
                PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, orderDiscount.getOrderId());
            stmt.setInt(2, orderDiscount.getDiscountId());
            stmt.setDouble(3, orderDiscount.getAmount());
            stmt.setString(4, orderDiscount.getAppliedDate());

            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Xóa discount khỏi order
    public boolean removeDiscountFromOrder(int orderId, int discountId) {
        String sql = "DELETE FROM OrderDiscount WHERE OrderID = ? AND DiscountID = ?";

        try (Connection connection = getConnection();
                PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, orderId);
            stmt.setInt(2, discountId);

            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Kiểm tra xem discount đã được áp dụng cho order chưa
    public boolean isDiscountApplied(int orderId, int discountId) {
        String sql = "SELECT COUNT(*) FROM OrderDiscount WHERE OrderID = ? AND DiscountID = ?";

        try (Connection connection = getConnection();
                PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, orderId);
            stmt.setInt(2, discountId);

            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}