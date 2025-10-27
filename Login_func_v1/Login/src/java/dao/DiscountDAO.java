package dao;

import models.Discount;
import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

public class DiscountDAO extends DBContext {
    private static final Logger LOGGER = Logger.getLogger(DiscountDAO.class.getName());

    // Constants
    private static final int PAGE_SIZE = 10;
    private static final String TYPE_PERCENTAGE = "Percentage";
    private static final String TYPE_FIXED = "Fixed";
    private static final String TYPE_LOYALTY = "Loyalty";

    // SQL Queries
    private static final String SQL_UPDATE_EXPIRED_DISCOUNTS = "UPDATE Discount SET IsActive = 0 WHERE IsActive = 1 AND EndDate IS NOT NULL AND EndDate < CAST(GETDATE() AS DATE)";

    private static final String SQL_SELECT_DISCOUNTS_BY_STATUS = "SELECT * FROM Discount WHERE IsActive = ? ORDER BY DiscountID DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

    private static final String SQL_COUNT_DISCOUNTS_BY_STATUS = "SELECT COUNT(*) FROM Discount WHERE IsActive = ?";

    private static final String SQL_INSERT_DISCOUNT = "INSERT INTO Discount (Description, DiscountType, Value, MaxDiscount, MinOrderTotal, StartDate, EndDate, IsActive) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

    private static final String SQL_DEACTIVATE_DISCOUNT = "UPDATE Discount SET IsActive = 0 WHERE DiscountID = ?";

    private static final String SQL_CHECK_LOYALTY_DISCOUNT = "SELECT COUNT(*) FROM Discount WHERE DiscountType = 'Loyalty' AND IsActive = 1";

    private static final String SQL_CHECK_LOYALTY_EXCLUDING = "SELECT COUNT(*) FROM Discount WHERE DiscountType = 'Loyalty' AND IsActive = 1 AND DiscountID != ?";

    private static final String SQL_SELECT_DISCOUNT_BY_ID = "SELECT * FROM Discount WHERE DiscountID = ?";

    /**
     * Get discounts by status with pagination
     */
    public List<Discount> getDiscountsByStatus(boolean isActive, int page) {
        autoUpdateDiscountStatus();
        List<Discount> discounts = new ArrayList<>();
        int offset = (page - 1) * PAGE_SIZE;

        try (Connection connection = getConnection();
                PreparedStatement ps = connection.prepareStatement(SQL_SELECT_DISCOUNTS_BY_STATUS)) {

            ps.setBoolean(1, isActive);
            ps.setInt(2, offset);
            ps.setInt(3, PAGE_SIZE);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    discounts.add(extractDiscountFromResultSet(rs));
                }
            }

            LOGGER.info(String.format("Fetched %d %s discounts for page %d",
                    discounts.size(), isActive ? "ACTIVE" : "INACTIVE", page));

        } catch (SQLException e) {
            LOGGER.severe("Error fetching discounts: " + e.getMessage());
        }
        return discounts;
    }

    /**
     * Get count of discounts by status
     */
    public int getDiscountsCountByStatus(boolean isActive) {
        autoUpdateDiscountStatus();
        try (Connection connection = getConnection();
                PreparedStatement ps = connection.prepareStatement(SQL_COUNT_DISCOUNTS_BY_STATUS)) {

            ps.setBoolean(1, isActive);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            LOGGER.severe("Error counting discounts: " + e.getMessage());
        }
        return 0;
    }

    /**
     * Add new discount
     */
    public boolean addDiscount(Discount discount) {
        if (!validateDiscount(discount)) {
            return false;
        }

        try (Connection connection = getConnection();
                PreparedStatement ps = connection.prepareStatement(SQL_INSERT_DISCOUNT)) {

            setDiscountParameters(ps, discount);
            ps.setBoolean(8, true);

            int rowsAffected = ps.executeUpdate();
            if (rowsAffected > 0) {
                LOGGER.info("Discount added successfully: " + discount.getDescription());
                return true;
            }
        } catch (SQLException e) {
            LOGGER.severe("Error adding discount: " + e.getMessage());
        }
        return false;
    }

    /**
     * Update discount - creates new discount and deactivates old one
     */
    public boolean updateDiscount(Discount discount) {
        if (!validateDiscount(discount) || discount.getDiscountId() <= 0) {
            return false;
        }

        Connection connection = null;
        try {
            connection = getConnection();
            connection.setAutoCommit(false);

            // Deactivate old discount
            if (!deactivateDiscount(connection, discount.getDiscountId())) {
                throw new SQLException("Failed to deactivate old discount");
            }

            // Insert new discount
            if (!insertNewDiscount(connection, discount)) {
                throw new SQLException("Failed to insert new discount");
            }

            connection.commit();
            LOGGER.info("Discount updated successfully: ID " + discount.getDiscountId());
            return true;

        } catch (SQLException e) {
            rollbackTransaction(connection);
            LOGGER.severe("Error updating discount: " + e.getMessage());
            return false;
        } finally {
            closeConnection(connection);
        }
    }

    /**
     * Deactivate discount
     */
    public boolean deactivateDiscount(int discountId) {
        if (discountId <= 0) {
            LOGGER.warning("Invalid discount ID for deactivation");
            return false;
        }

        try (Connection connection = getConnection();
                PreparedStatement ps = connection.prepareStatement(SQL_DEACTIVATE_DISCOUNT)) {

            ps.setInt(1, discountId);
            int rowsAffected = ps.executeUpdate();

            if (rowsAffected > 0) {
                LOGGER.info("Discount deactivated: ID " + discountId);
                return true;
            }
        } catch (SQLException e) {
            LOGGER.severe("Error deactivating discount: " + e.getMessage());
        }
        return false;
    }

    /**
     * Check if there is already an active loyalty discount
     */
    public boolean hasActiveLoyaltyDiscount() {
        return getCount(SQL_CHECK_LOYALTY_DISCOUNT) > 0;
    }

    /**
     * Check if there is already an active loyalty discount excluding a specific ID
     */
    public boolean hasActiveLoyaltyDiscountExcluding(int excludeDiscountId) {
        try (Connection connection = getConnection();
                PreparedStatement ps = connection.prepareStatement(SQL_CHECK_LOYALTY_EXCLUDING)) {

            ps.setInt(1, excludeDiscountId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            LOGGER.severe("Error checking active loyalty discounts: " + e.getMessage());
        }
        return false;
    }

    /**
     * Get discount by ID
     */
    public Discount getDiscountById(int discountId) {
        try (Connection connection = getConnection();
                PreparedStatement ps = connection.prepareStatement(SQL_SELECT_DISCOUNT_BY_ID)) {

            ps.setInt(1, discountId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return extractDiscountFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.severe("Error fetching discount: " + e.getMessage());
        }
        return null;
    }

    // Private helper methods
    private void autoUpdateDiscountStatus() {
        try (Connection connection = getConnection();
                PreparedStatement ps = connection.prepareStatement(SQL_UPDATE_EXPIRED_DISCOUNTS)) {

            int expiredCount = ps.executeUpdate();
            if (expiredCount > 0) {
                LOGGER.info("Auto-deactivated " + expiredCount + " expired discounts");
            }
        } catch (SQLException e) {
            LOGGER.severe("Error auto-updating discount status: " + e.getMessage());
        }
    }

    private boolean validateDiscount(Discount discount) {
        if (discount.getDescription() == null || discount.getDescription().trim().isEmpty()) {
            LOGGER.warning("Discount description cannot be empty");
            return false;
        }
        if (discount.getValue() <= 0) {
            LOGGER.warning("Discount value must be positive");
            return false;
        }
        return validateDiscountDates(discount);
    }

    private boolean validateDiscountDates(Discount discount) {
        try {
            LocalDate today = LocalDate.now();
            LocalDate startDate = LocalDate.parse(discount.getStartDate());

            if (startDate.isBefore(today)) {
                LOGGER.warning("Start date cannot be in the past");
                return false;
            }

            if (discount.getEndDate() != null && !discount.getEndDate().trim().isEmpty()) {
                LocalDate endDate = LocalDate.parse(discount.getEndDate());
                if (endDate.isBefore(startDate)) {
                    LOGGER.warning("End date cannot be before start date");
                    return false;
                }
            }
            return true;
        } catch (Exception e) {
            LOGGER.warning("Invalid date format: " + e.getMessage());
            return false;
        }
    }

    private void setDiscountParameters(PreparedStatement ps, Discount discount) throws SQLException {
        ps.setString(1, discount.getDescription().trim());
        ps.setString(2, discount.getDiscountType());
        ps.setDouble(3, discount.getValue());

        if (discount.getMaxDiscount() != null && discount.getMaxDiscount() > 0) {
            ps.setDouble(4, discount.getMaxDiscount());
        } else {
            ps.setNull(4, Types.DOUBLE);
        }

        ps.setDouble(5, discount.getMinOrderTotal());
        ps.setDate(6, Date.valueOf(discount.getStartDate()));

        if (discount.getEndDate() != null && !discount.getEndDate().trim().isEmpty()) {
            ps.setDate(7, Date.valueOf(discount.getEndDate()));
        } else {
            ps.setNull(7, Types.DATE);
        }
    }

    private Discount extractDiscountFromResultSet(ResultSet rs) throws SQLException {
        Discount discount = new Discount();
        discount.setDiscountId(rs.getInt("DiscountID"));
        discount.setDescription(rs.getString("Description"));
        discount.setDiscountType(rs.getString("DiscountType"));
        discount.setValue(rs.getDouble("Value"));

        double maxDiscount = rs.getDouble("MaxDiscount");
        discount.setMaxDiscount(rs.wasNull() ? null : maxDiscount);

        discount.setMinOrderTotal(rs.getDouble("MinOrderTotal"));
        discount.setStartDate(rs.getDate("StartDate").toString());

        Date endDate = rs.getDate("EndDate");
        discount.setEndDate(endDate != null ? endDate.toString() : null);

        discount.setActive(rs.getBoolean("IsActive"));
        return discount;
    }

    private boolean deactivateDiscount(Connection connection, int discountId) throws SQLException {
        try (PreparedStatement ps = connection.prepareStatement(SQL_DEACTIVATE_DISCOUNT)) {
            ps.setInt(1, discountId);
            return ps.executeUpdate() > 0;
        }
    }

    private boolean insertNewDiscount(Connection connection, Discount discount) throws SQLException {
        try (PreparedStatement ps = connection.prepareStatement(SQL_INSERT_DISCOUNT)) {
            setDiscountParameters(ps, discount);
            ps.setBoolean(8, true);
            return ps.executeUpdate() > 0;
        }
    }

    private int getCount(String sql) {
        try (Connection connection = getConnection();
                PreparedStatement ps = connection.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {

            return rs.next() ? rs.getInt(1) : 0;
        } catch (SQLException e) {
            LOGGER.severe("Error counting records: " + e.getMessage());
            return 0;
        }
    }

    private void rollbackTransaction(Connection connection) {
        if (connection != null) {
            try {
                connection.rollback();
            } catch (SQLException ex) {
                LOGGER.severe("Error rolling back transaction: " + ex.getMessage());
            }
        }
    }
}