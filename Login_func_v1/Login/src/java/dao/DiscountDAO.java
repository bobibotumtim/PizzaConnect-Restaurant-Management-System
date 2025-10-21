package dao;

import models.Discount;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class DiscountDAO extends DBContext{

    private static final String SELECT_ALL_DISCOUNTS = "SELECT * FROM Discount WHERE IsActive = 1 AND StartDate <= ? AND (EndDate IS NULL OR EndDate >= ?)";
    private static final String INSERT_ORDER_DISCOUNT = "INSERT INTO OrderDiscount (OrderID, DiscountID, Amount) VALUES (?, ?, ?)";
    private static final String UPDATE_CUSTOMER_LOYALTY = "UPDATE Customer SET LoyaltyPoint = LoyaltyPoint - ?, LastEarnedDate = NULL WHERE CustomerID = ?";
    private static final String UPDATE_ORDER_TOTAL = "UPDATE [Order] SET TotalPrice = TotalPrice - ? WHERE OrderID = ?";

    public List<Discount> getAllActiveDiscounts() {
        List<Discount> discounts = new ArrayList<>();
        java.util.Date currentDate = new java.util.Date();
        java.sql.Date sqlDate = new java.sql.Date(currentDate.getTime());

        try (Connection connection = getConnection();
                PreparedStatement preparedStatement = connection.prepareStatement(SELECT_ALL_DISCOUNTS)) {
            preparedStatement.setDate(1, sqlDate);
            preparedStatement.setDate(2, sqlDate);
            ResultSet rs = preparedStatement.executeQuery();

            while (rs.next()) {
                Discount discount = new Discount();
                discount.setDiscountId(rs.getInt("DiscountID"));
                discount.setDescription(rs.getString("Description"));
                discount.setDiscountType(rs.getString("DiscountType"));
                discount.setValue(rs.getDouble("Value"));
                discount.setMaxDiscount(rs.getDouble("MaxDiscount"));
                discount.setMinOrderTotal(rs.getDouble("MinOrderTotal"));
                discount.setStartDate(rs.getDate("StartDate").toString());
                discount.setEndDate(rs.getDate("EndDate") != null ? rs.getDate("EndDate").toString() : null);
                discount.setActive(rs.getBoolean("IsActive"));
                discounts.add(discount);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return discounts;
    }

    public boolean applyDiscount(int orderId, int discountId, double totalPrice, int customerId, int pointsUsed) {
        Discount discount = getDiscountById(discountId);
        if (discount == null || !discount.isActive())
            return false;

        double discountAmount = calculateDiscountAmount(discount, totalPrice, pointsUsed);
        if (discountAmount <= 0)
            return false;

        try (Connection connection = getConnection()) {
            connection.setAutoCommit(false);

            // Insert into OrderDiscount
            try (PreparedStatement ps = connection.prepareStatement(INSERT_ORDER_DISCOUNT)) {
                ps.setInt(1, orderId);
                ps.setInt(2, discountId);
                ps.setDouble(3, discountAmount);
                ps.executeUpdate();
            }

            // Update Customer LoyaltyPoint
            if ("Loyalty".equals(discount.getDiscountType())) {
                try (PreparedStatement ps = connection.prepareStatement(UPDATE_CUSTOMER_LOYALTY)) {
                    ps.setInt(1, pointsUsed);
                    ps.setInt(2, customerId);
                    ps.executeUpdate();
                }
            }

            // Update Order TotalPrice
            try (PreparedStatement ps = connection.prepareStatement(UPDATE_ORDER_TOTAL)) {
                ps.setDouble(1, discountAmount);
                ps.setInt(2, orderId);
                ps.executeUpdate();
            }

            connection.commit();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    private Discount getDiscountById(int discountId) {
        String sql = "SELECT * FROM Discount WHERE DiscountID = ?";
        try (Connection connection = new DBContext().getConnection();
             PreparedStatement preparedStatement = connection.prepareStatement(sql)) {
            preparedStatement.setInt(1, discountId);
            ResultSet rs = preparedStatement.executeQuery();
            if (rs.next()) {
                Discount discount = new Discount();
                discount.setDiscountId(rs.getInt("DiscountID"));
                discount.setDescription(rs.getString("Description"));
                discount.setDiscountType(rs.getString("DiscountType"));
                discount.setValue(rs.getDouble("Value"));
                discount.setMaxDiscount(rs.getDouble("MaxDiscount"));
                discount.setMinOrderTotal(rs.getDouble("MinOrderTotal"));
                discount.setStartDate(rs.getDate("StartDate").toString());
                discount.setEndDate(rs.getDate("EndDate") != null ? rs.getDate("EndDate").toString() : null);
                discount.setActive(rs.getBoolean("IsActive"));
                return discount;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    private double calculateDiscountAmount(Discount discount, double totalPrice, int pointsUsed) {
        if (discount.getMinOrderTotal() > totalPrice)
            return 0;

        switch (discount.getDiscountType()) {
            case "Percentage":
                double amount = totalPrice * (discount.getValue() / 100);
                return discount.getMaxDiscount() != null ? Math.min(amount, discount.getMaxDiscount()) : amount;
            case "Fixed":
                return discount.getValue();
            case "Loyalty":
                return pointsUsed * discount.getValue();
            default:
                return 0;
        }
    }
}