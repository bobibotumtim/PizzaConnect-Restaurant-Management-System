package dao;

import models.Discount;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

public class DiscountDAO extends DBContext {
    private static final Logger LOGGER = Logger.getLogger(DiscountDAO.class.getName());
    private static final String SELECT_ALL_DISCOUNTS = "SELECT * FROM Discount WHERE IsActive = 1 AND StartDate <= ? AND (EndDate IS NULL OR EndDate >= ?)";
    private static final String SELECT_ALL_WITH_INACTIVE = "SELECT * FROM Discount";
    private static final String INSERT_DISCOUNT = "INSERT INTO Discount (Description, DiscountType, Value, MaxDiscount, MinOrderTotal, StartDate, EndDate, IsActive) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
    private static final String UPDATE_DISCOUNT = "UPDATE Discount SET Description = ?, DiscountType = ?, Value = ?, MaxDiscount = ?, MinOrderTotal = ?, StartDate = ?, EndDate = ?, IsActive = ? WHERE DiscountID = ?";
    private static final String DEACTIVATE_DISCOUNT = "UPDATE Discount SET IsActive = 0 WHERE DiscountID = ?";
    private static final String SELECT_DISCOUNT_BY_ID = "SELECT * FROM Discount WHERE DiscountID = ?";

    public List<Discount> getAllActiveDiscounts() {
        return getDiscounts(SELECT_ALL_DISCOUNTS, true);
    }

    public List<Discount> getAllDiscounts() {
        return getDiscounts(SELECT_ALL_WITH_INACTIVE, false);
    }

    private List<Discount> getDiscounts(String sql, boolean activeOnly) {
        List<Discount> discounts = new ArrayList<>();
        try (Connection connection = getConnection();
                PreparedStatement ps = connection.prepareStatement(sql)) {
            if (activeOnly) {
                java.util.Date currentDate = new java.util.Date();
                java.sql.Date sqlDate = new java.sql.Date(currentDate.getTime());
                ps.setDate(1, sqlDate);
                ps.setDate(2, sqlDate);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Discount discount = new Discount();
                    discount.setDiscountId(rs.getInt("DiscountID"));
                    discount.setDescription(rs.getString("Description"));
                    discount.setDiscountType(rs.getString("DiscountType"));
                    discount.setValue(rs.getDouble("Value"));
                    Double maxDiscount = rs.getDouble("MaxDiscount");
                    discount.setMaxDiscount(rs.wasNull() ? null : maxDiscount);
                    discount.setMinOrderTotal(rs.getDouble("MinOrderTotal"));
                    discount.setStartDate(rs.getDate("StartDate").toString());
                    discount.setEndDate(rs.getDate("EndDate") != null ? rs.getDate("EndDate").toString() : null);
                    discount.setActive(rs.getBoolean("IsActive"));
                    discounts.add(discount);
                }
            }
            LOGGER.info("Fetched " + discounts.size() + " discounts (activeOnly=" + activeOnly + ")");
        } catch (SQLException e) {
            LOGGER.severe("Error fetching discounts: " + e.getMessage());
        }
        return discounts;
    }

    public void addDiscount(Discount discount) throws SQLException {
        try (Connection connection = getConnection();
                PreparedStatement ps = connection.prepareStatement(INSERT_DISCOUNT)) {
            connection.setAutoCommit(false);
            try {
                ps.setString(1, discount.getDescription());
                ps.setString(2, discount.getDiscountType());
                ps.setDouble(3, discount.getValue());
                if (discount.getMaxDiscount() != null) {
                    ps.setDouble(4, discount.getMaxDiscount());
                } else {
                    ps.setNull(4, Types.DOUBLE);
                }
                ps.setDouble(5, discount.getMinOrderTotal());
                ps.setDate(6, Date.valueOf(discount.getStartDate()));
                if (discount.getEndDate() != null) {
                    ps.setDate(7, Date.valueOf(discount.getEndDate()));
                } else {
                    ps.setNull(7, Types.DATE);
                }
                ps.setBoolean(8, discount.isActive());
                int rowsAffected = ps.executeUpdate();
                if (rowsAffected == 0) {
                    throw new SQLException("Failed to insert discount: " + discount.getDescription());
                }
                connection.commit();
                LOGGER.info("Discount inserted: " + discount.getDescription());
            } catch (SQLException e) {
                connection.rollback();
                LOGGER.severe("Error inserting discount: " + e.getMessage());
                throw e;
            }
        }
    }

    public void updateDiscount(Discount discount) throws SQLException {
        try (Connection connection = getConnection();
                PreparedStatement ps = connection.prepareStatement(UPDATE_DISCOUNT)) {
            connection.setAutoCommit(false);
            try {
                ps.setString(1, discount.getDescription());
                ps.setString(2, discount.getDiscountType());
                ps.setDouble(3, discount.getValue());
                if (discount.getMaxDiscount() != null) {
                    ps.setDouble(4, discount.getMaxDiscount());
                } else {
                    ps.setNull(4, Types.DOUBLE);
                }
                ps.setDouble(5, discount.getMinOrderTotal());
                ps.setDate(6, Date.valueOf(discount.getStartDate()));
                if (discount.getEndDate() != null) {
                    ps.setDate(7, Date.valueOf(discount.getEndDate()));
                } else {
                    ps.setNull(7, Types.DATE);
                }
                ps.setBoolean(8, discount.isActive());
                ps.setInt(9, discount.getDiscountId());
                int rowsAffected = ps.executeUpdate();
                if (rowsAffected == 0) {
                    throw new SQLException("Failed to update discount ID: " + discount.getDiscountId());
                }
                connection.commit();
                LOGGER.info("Discount updated: ID " + discount.getDiscountId());
            } catch (SQLException e) {
                connection.rollback();
                LOGGER.severe("Error updating discount ID " + discount.getDiscountId() + ": " + e.getMessage());
                throw e;
            }
        }
    }

    public boolean deactivateDiscount(int discountId) throws SQLException {
        if (discountId <= 0) {
            LOGGER.warning("Invalid discount ID: " + discountId);
            throw new IllegalArgumentException("Invalid discount ID: " + discountId);
        }
        try (Connection connection = getConnection();
                PreparedStatement ps = connection.prepareStatement(DEACTIVATE_DISCOUNT)) {
            connection.setAutoCommit(false);
            try {
                ps.setInt(1, discountId);
                int rowsAffected = ps.executeUpdate();
                if (rowsAffected == 0) {
                    throw new SQLException("Failed to deactivate discount ID: " + discountId);
                }
                connection.commit();
                LOGGER.info("Discount deactivated: ID " + discountId);
                return true;
            } catch (SQLException e) {
                connection.rollback();
                LOGGER.severe("Error deactivating discount ID " + discountId + ": " + e.getMessage());
                throw e;
            }
        }
    }

    public Discount getDiscountById(int discountId) {
        try (Connection connection = getConnection();
                PreparedStatement ps = connection.prepareStatement(SELECT_DISCOUNT_BY_ID)) {
            ps.setInt(1, discountId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Discount discount = new Discount();
                    discount.setDiscountId(rs.getInt("DiscountID"));
                    discount.setDescription(rs.getString("Description"));
                    discount.setDiscountType(rs.getString("DiscountType"));
                    discount.setValue(rs.getDouble("Value"));
                    Double maxDiscount = rs.getDouble("MaxDiscount");
                    discount.setMaxDiscount(rs.wasNull() ? null : maxDiscount);
                    discount.setMinOrderTotal(rs.getDouble("MinOrderTotal"));
                    discount.setStartDate(rs.getDate("StartDate").toString());
                    discount.setEndDate(rs.getDate("EndDate") != null ? rs.getDate("EndDate").toString() : null);
                    discount.setActive(rs.getBoolean("IsActive"));
                    return discount;
                }
            }
        } catch (SQLException e) {
            LOGGER.severe("Error fetching discount ID " + discountId + ": " + e.getMessage());
        }
        return null;
    }

    public boolean applyDiscount(int orderId, int discountId, double totalPrice, int customerId, int pointsUsed) {
        Discount discount = getDiscountById(discountId);
        if (discount == null || !discount.isActive()) {
            LOGGER.warning("Discount ID " + discountId + " is null or inactive");
            return false;
        }

        double discountAmount = calculateDiscountAmount(discount, totalPrice, pointsUsed);
        if (discountAmount <= 0) {
            LOGGER.warning("Invalid discount amount for discount ID " + discountId);
            return false;
        }

        try (Connection connection = getConnection()) {
            connection.setAutoCommit(false);
            try {
                try (PreparedStatement ps = connection.prepareStatement(
                        "INSERT INTO OrderDiscount (OrderID, DiscountID, Amount) VALUES (?, ?, ?)")) {
                    ps.setInt(1, orderId);
                    ps.setInt(2, discountId);
                    ps.setDouble(3, discountAmount);
                    ps.executeUpdate();
                }

                if ("Loyalty".equals(discount.getDiscountType())) {
                    try (PreparedStatement ps = connection.prepareStatement(
                            "UPDATE Customer SET LoyaltyPoint = LoyaltyPoint - ?, LastEarnedDate = NULL WHERE CustomerID = ?")) {
                        ps.setInt(1, pointsUsed);
                        ps.setInt(2, customerId);
                        ps.executeUpdate();
                    }
                }

                try (PreparedStatement ps = connection.prepareStatement(
                        "UPDATE [Order] SET TotalPrice = TotalPrice - ? WHERE OrderID = ?")) {
                    ps.setDouble(1, discountAmount);
                    ps.setInt(2, orderId);
                    ps.executeUpdate();
                }

                connection.commit();
                LOGGER.info("Discount applied: Order ID " + orderId + ", Discount ID " + discountId);
                return true;
            } catch (SQLException e) {
                try {
                    connection.rollback();
                    LOGGER.severe("Error applying discount ID " + discountId + " to order ID " + orderId + ": "
                            + e.getMessage());
                } catch (SQLException rollbackEx) {
                    LOGGER.severe(
                            "Error during rollback for discount ID " + discountId + ": " + rollbackEx.getMessage());
                }
                return false;
            }
        } catch (SQLException e) {
            LOGGER.severe("Error getting connection for applyDiscount: " + e.getMessage());
            return false;
        }
    }

    private double calculateDiscountAmount(Discount discount, double totalPrice, int pointsUsed) {
        if (discount.getMinOrderTotal() > totalPrice) {
            LOGGER.warning("Order total " + totalPrice + " is below minimum " + discount.getMinOrderTotal());
            return 0;
        }
        switch (discount.getDiscountType()) {
            case "Percentage":
                double amount = totalPrice * (discount.getValue() / 100);
                double result = discount.getMaxDiscount() != null ? Math.min(amount, discount.getMaxDiscount())
                        : amount;
                LOGGER.info("Calculated Percentage discount: " + result);
                return result;
            case "Fixed":
                LOGGER.info("Calculated Fixed discount: " + discount.getValue());
                return discount.getValue();
            case "Loyalty":
                double loyaltyDiscount = pointsUsed * discount.getValue();
                LOGGER.info("Calculated Loyalty discount: " + loyaltyDiscount);
                return loyaltyDiscount;
            default:
                LOGGER.warning("Unknown discount type: " + discount.getDiscountType());
                return 0;
        }
    }
}