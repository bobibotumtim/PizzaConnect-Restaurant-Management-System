package dao;

import models.CustomerDiscount;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

public class CustomerDiscountDAO extends DBContext {
    private static final Logger LOGGER = Logger.getLogger(CustomerDiscountDAO.class.getName());

    // Get customer discounts with discount details
    public List<CustomerDiscount> getCustomerDiscounts(int customerId) {
        List<CustomerDiscount> customerDiscounts = new ArrayList<>();
        String sql = """
                    SELECT cd.*, d.Description, d.DiscountType, d.Value, d.MaxDiscount, d.MinOrderTotal
                    FROM CustomerDiscount cd
                    JOIN Discount d ON cd.DiscountID = d.DiscountID
                    WHERE cd.CustomerID = ? AND cd.IsUsed = 0 AND cd.Quantity > 0
                    AND (cd.ExpiryDate IS NULL OR cd.ExpiryDate >= CAST(GETDATE() AS DATE))
                    ORDER BY cd.ExpiryDate ASC, cd.LastEarnedDate DESC
                """;

        try (Connection connection = getConnection();
                PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CustomerDiscount cd = mapCustomerDiscount(rs);
                    customerDiscounts.add(cd);
                }
            }

        } catch (SQLException e) {
            LOGGER.severe("Error getting customer discounts: " + e.getMessage());
        }
        return customerDiscounts;
    }

    // Get customer loyalty points
    public int getCustomerLoyaltyPoints(int customerId) {
        String sql = """
                    SELECT SUM(cd.Quantity) as TotalPoints
                    FROM CustomerDiscount cd
                    JOIN Discount d ON cd.DiscountID = d.DiscountID
                    WHERE cd.CustomerID = ? AND d.DiscountType = 'Loyalty' AND cd.IsUsed = 0
                    AND (cd.ExpiryDate IS NULL OR cd.ExpiryDate >= CAST(GETDATE() AS DATE))
                """;

        try (Connection connection = getConnection();
                PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("TotalPoints");
                }
            }

        } catch (SQLException e) {
            LOGGER.severe("Error getting customer loyalty points: " + e.getMessage());
        }
        return 0;
    }

    // Add or update customer discount
    public boolean addCustomerDiscount(CustomerDiscount customerDiscount) {
        String sql = """
                    IF EXISTS (SELECT 1 FROM CustomerDiscount WHERE CustomerID = ? AND DiscountID = ?)
                        UPDATE CustomerDiscount
                        SET Quantity = Quantity + ?, LastEarnedDate = GETDATE()
                        WHERE CustomerID = ? AND DiscountID = ?
                    ELSE
                        INSERT INTO CustomerDiscount (CustomerID, DiscountID, Quantity, ExpiryDate, LastEarnedDate)
                        VALUES (?, ?, ?, ?, GETDATE())
                """;

        try (Connection connection = getConnection();
                PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setInt(1, customerDiscount.getCustomerId());
            ps.setInt(2, customerDiscount.getDiscountId());
            ps.setInt(3, customerDiscount.getQuantity());
            ps.setInt(4, customerDiscount.getCustomerId());
            ps.setInt(5, customerDiscount.getDiscountId());
            ps.setInt(6, customerDiscount.getCustomerId());
            ps.setInt(7, customerDiscount.getDiscountId());
            ps.setInt(8, customerDiscount.getQuantity());

            if (customerDiscount.getExpiryDate() != null) {
                ps.setDate(9, new Date(customerDiscount.getExpiryDate().getTime()));
            } else {
                ps.setNull(9, Types.DATE);
            }

            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;

        } catch (SQLException e) {
            LOGGER.severe("Error adding customer discount: " + e.getMessage());
            return false;
        }
    }

    // Use a discount (decrease quantity)
    public boolean useDiscount(int customerDiscountId, int quantityUsed) {
        String sql = """
                    UPDATE CustomerDiscount
                    SET Quantity = Quantity - ?, IsUsed = CASE WHEN Quantity - ? <= 0 THEN 1 ELSE 0 END,
                        UsedDate = GETDATE()
                    WHERE CustomerDiscountID = ? AND Quantity >= ?
                """;

        try (Connection connection = getConnection();
                PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setInt(1, quantityUsed);
            ps.setInt(2, quantityUsed);
            ps.setInt(3, customerDiscountId);
            ps.setInt(4, quantityUsed);

            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;

        } catch (SQLException e) {
            LOGGER.severe("Error using discount: " + e.getMessage());
            return false;
        }
    }

    // Initialize customer with loyalty points (when new customer is created)
    public boolean initializeCustomerLoyalty(int customerId) {
        String sql = """
                    INSERT INTO CustomerDiscount (CustomerID, DiscountID, Quantity, LastEarnedDate)
                    SELECT ?, DiscountID, 0, GETDATE()
                    FROM Discount
                    WHERE DiscountType = 'Loyalty' AND IsActive = 1
                    AND NOT EXISTS (
                        SELECT 1 FROM CustomerDiscount
                        WHERE CustomerID = ? AND DiscountID = Discount.DiscountID
                    )
                """;

        try (Connection connection = getConnection();
                PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setInt(1, customerId);
            ps.setInt(2, customerId);

            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;

        } catch (SQLException e) {
            LOGGER.severe("Error initializing customer loyalty: " + e.getMessage());
            return false;
        }
    }

    // Map ResultSet to CustomerDiscount object
    private CustomerDiscount mapCustomerDiscount(ResultSet rs) throws SQLException {
        CustomerDiscount cd = new CustomerDiscount();
        cd.setCustomerDiscountId(rs.getInt("CustomerDiscountID"));
        cd.setCustomerId(rs.getInt("CustomerID"));
        cd.setDiscountId(rs.getInt("DiscountID"));
        cd.setQuantity(rs.getInt("Quantity"));

        // Helper method makes date assignments cleaner
        cd.setExpiryDate(sqlDateToUtilDate(rs.getDate("ExpiryDate")));
        cd.setLastEarnedDate(sqlTimestampToUtilDate(rs.getTimestamp("LastEarnedDate")));
        cd.setUsedDate(sqlTimestampToUtilDate(rs.getTimestamp("UsedDate")));

        cd.setUsed(rs.getBoolean("IsUsed"));

        // Discount details
        cd.setDescription(rs.getString("Description"));
        cd.setDiscountType(rs.getString("DiscountType"));
        cd.setValue(rs.getDouble("Value"));

        double maxDiscount = rs.getDouble("MaxDiscount");
        cd.setMaxDiscount(rs.wasNull() ? null : maxDiscount); // Correctly handles NULL for Double wrapper

        cd.setMinOrderTotal(rs.getDouble("MinOrderTotal"));

        return cd;
    }

    // Helper method for java.sql.Date -> java.util.Date conversion
    private java.util.Date sqlDateToUtilDate(java.sql.Date sqlDate) {
        return (sqlDate != null) ? new java.util.Date(sqlDate.getTime()) : null;
    }

    // Helper method for java.sql.Timestamp -> java.util.Date conversion
    private java.util.Date sqlTimestampToUtilDate(java.sql.Timestamp sqlTimestamp) {
        return (sqlTimestamp != null) ? new java.util.Date(sqlTimestamp.getTime()) : null;
    }
}