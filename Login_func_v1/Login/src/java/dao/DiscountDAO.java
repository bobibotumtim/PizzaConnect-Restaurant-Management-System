package dao;

import models.Discount;
import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

public class DiscountDAO extends DBContext {
    private static final Logger LOGGER = Logger.getLogger(DiscountDAO.class.getName());
    private static final int PAGE_SIZE = 10;

    /**
     * Get discounts by status with pagination and additional filters
     */
    public List<Discount> getDiscountsByStatus(boolean isActive, int page, String type, String startDate,
            String endDate, String search) {
        autoUpdateDiscountStatus();
        List<Discount> discounts = new ArrayList<>();
        int offset = (page - 1) * PAGE_SIZE;

        // Build SQL query dynamically based on filters
        StringBuilder sqlBuilder = new StringBuilder();
        sqlBuilder.append("SELECT * FROM Discount WHERE IsActive = ?");
        List<Object> params = new ArrayList<>();
        params.add(isActive);

        // Add filter parameters (work together)
        if (type != null && !type.isEmpty()) {
            sqlBuilder.append(" AND DiscountType = ?");
            params.add(type);
        }

        if (startDate != null && !startDate.isEmpty()) {
            sqlBuilder.append(" AND (StartDate >= ? OR EndDate >= ?)");
            params.add(startDate);
            params.add(startDate);
        }

        if (endDate != null && !endDate.isEmpty()) {
            sqlBuilder.append(" AND (StartDate <= ? OR EndDate <= ? OR EndDate IS NULL)");
            params.add(endDate);
            params.add(endDate);
        }

        // Add search parameter (works independently)
        if (search != null && !search.isEmpty()) {
            sqlBuilder.append(" AND (Description LIKE ? OR CAST(Value AS VARCHAR) LIKE ?)");
            params.add("%" + search + "%");
            params.add("%" + search + "%");
        }

        sqlBuilder.append(" ORDER BY DiscountID DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        params.add(offset);
        params.add(PAGE_SIZE);

        String sql = sqlBuilder.toString();

        try (Connection connection = getConnection();
                PreparedStatement ps = connection.prepareStatement(sql)) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    discounts.add(extractDiscountFromResultSet(rs));
                }
            }

            LOGGER.info(String.format(
                    "Fetched %d %s discounts for page %d with filters - Type: %s, StartDate: %s, EndDate: %s, Search: %s",
                    discounts.size(), isActive ? "ACTIVE" : "INACTIVE", page, type, startDate, endDate, search));

        } catch (SQLException e) {
            LOGGER.severe("Error fetching discounts: " + e.getMessage());
        }
        return discounts;
    }

    /**
     * Get count of discounts by status with additional filters
     */
    public int getDiscountsCountByStatus(boolean isActive, String type, String startDate, String endDate,
            String search) {
        autoUpdateDiscountStatus();

        // Build count query dynamically based on filters
        StringBuilder sqlBuilder = new StringBuilder();
        sqlBuilder.append("SELECT COUNT(*) FROM Discount WHERE IsActive = ?");
        List<Object> params = new ArrayList<>();
        params.add(isActive);

        // Add filter parameters (work together)
        if (type != null && !type.isEmpty()) {
            sqlBuilder.append(" AND DiscountType = ?");
            params.add(type);
        }

        if (startDate != null && !startDate.isEmpty()) {
            sqlBuilder.append(" AND (StartDate >= ? OR EndDate >= ?)");
            params.add(startDate);
            params.add(startDate);
        }

        if (endDate != null && !endDate.isEmpty()) {
            sqlBuilder.append(" AND (StartDate <= ? OR EndDate <= ? OR EndDate IS NULL)");
            params.add(endDate);
            params.add(endDate);
        }

        // Add search parameter (works independently)
        if (search != null && !search.isEmpty()) {
            sqlBuilder.append(" AND (Description LIKE ? OR CAST(Value AS VARCHAR) LIKE ?)");
            params.add("%" + search + "%");
            params.add("%" + search + "%");
        }

        String sql = sqlBuilder.toString();

        try (Connection connection = getConnection();
                PreparedStatement ps = connection.prepareStatement(sql)) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

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

        String sql = "INSERT INTO Discount (Description, DiscountType, Value, MaxDiscount, MinOrderTotal, StartDate, EndDate, IsActive) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection connection = getConnection();
                PreparedStatement ps = connection.prepareStatement(sql)) {

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
     * Update discount - decides between immediate update or scheduled update based
     * on start date
     */
    public boolean updateDiscount(Discount discount) {
        if (!validateDiscount(discount) || discount.getDiscountId() <= 0) {
            return false;
        }

        // Check if discount start date is tomorrow or later (future discount)
        if (isStartDateTomorrowOrLater(discount.getDiscountId())) {
            // Future discount - update immediately
            return updateDiscountImmediately(discount);
        } else {
            // Active or past discount - schedule update for end of day
            return scheduleDiscountUpdate(discount);
        }
    }

    /**
     * Update discount immediately in the database
     */
    private boolean updateDiscountImmediately(Discount discount) {
        String sql = "UPDATE Discount SET Description = ?, DiscountType = ?, Value = ?, MaxDiscount = ?, MinOrderTotal = ?, StartDate = ?, EndDate = ? WHERE DiscountID = ?";

        try (Connection connection = getConnection();
                PreparedStatement ps = connection.prepareStatement(sql)) {

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

            ps.setInt(8, discount.getDiscountId());

            int rowsAffected = ps.executeUpdate();
            if (rowsAffected > 0) {
                LOGGER.info("Discount updated immediately: ID " + discount.getDiscountId());
                return true;
            }
        } catch (SQLException e) {
            LOGGER.severe("Error updating discount immediately: " + e.getMessage());
        }
        return false;
    }

    /**
     * Schedule discount update for end of day
     */
    private boolean scheduleDiscountUpdate(Discount discount) {
        String sql = "EXEC ScheduleDiscountUpdate @DiscountID = ?, @Description = ?, @DiscountType = ?, @Value = ?, @MaxDiscount = ?, @MinOrderTotal = ?, @StartDate = ?, @EndDate = ?";

        try (Connection connection = getConnection();
                PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setInt(1, discount.getDiscountId());
            ps.setString(2, discount.getDescription().trim());
            ps.setString(3, discount.getDiscountType());
            ps.setDouble(4, discount.getValue());

            if (discount.getMaxDiscount() != null && discount.getMaxDiscount() > 0) {
                ps.setDouble(5, discount.getMaxDiscount());
            } else {
                ps.setNull(5, Types.DOUBLE);
            }

            ps.setDouble(6, discount.getMinOrderTotal());
            ps.setDate(7, Date.valueOf(discount.getStartDate()));

            if (discount.getEndDate() != null && !discount.getEndDate().trim().isEmpty()) {
                ps.setDate(8, Date.valueOf(discount.getEndDate()));
            } else {
                ps.setNull(8, Types.DATE);
            }

            ps.executeUpdate();
            LOGGER.info("Discount update scheduled: ID " + discount.getDiscountId());
            return true;

        } catch (SQLException e) {
            LOGGER.severe("Error scheduling discount update: " + e.getMessage());
            return false;
        }
    }

    /**
     * Check if discount is scheduled for update
     */
    public boolean isScheduledForUpdate(int discountID) {
        String sql = "SELECT 1 FROM DiscountUpdateQueue WHERE DiscountID = ?";

        try (Connection connection = getConnection();
                PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, discountID);
            ResultSet rs = stmt.executeQuery();
            return rs.next();
        } catch (SQLException e) {
            LOGGER.severe("Error checking scheduled update: " + e.getMessage());
            return false;
        }
    }

    /**
     * Schedule discount deletion for end of day
     */
    public boolean scheduleDiscountDeletion(int discountID) {
        String sql = "EXEC ScheduleDeletion @EntityType = 'Discount', @EntityID = ?";

        try (Connection connection = getConnection();
                PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, discountID);
            stmt.executeUpdate();
            LOGGER.info("Discount deletion scheduled: ID " + discountID);
            return true;
        } catch (SQLException e) {
            LOGGER.severe("Error scheduling discount deletion: " + e.getMessage());
            return false;
        }
    }

    /**
     * Check if a discount is scheduled for deletion
     */
    public boolean isScheduledForDeletion(int discountID) {
        String sql = "SELECT 1 FROM DeletionQueue WHERE EntityType = 'Discount' AND EntityID = ?";

        try (Connection connection = getConnection();
                PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, discountID);
            ResultSet rs = stmt.executeQuery();
            return rs.next();
        } catch (SQLException e) {
            LOGGER.severe("Error checking scheduled deletion: " + e.getMessage());
            return false;
        }
    }

    /**
     * Check if discount start date is tomorrow or later (future discount)
     */
    public boolean isStartDateTomorrowOrLater(int discountID) {
        String sql = "SELECT 1 FROM Discount WHERE DiscountID = ? AND StartDate >= CAST(GETDATE() AS DATE)";

        try (Connection connection = getConnection();
                PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, discountID);
            ResultSet rs = stmt.executeQuery();
            return rs.next();
        } catch (SQLException e) {
            LOGGER.severe("Error checking discount start date: " + e.getMessage());
            return false;
        }
    }

    /**
     * Get current start date of discount
     */
    public String getDiscountStartDate(int discountID) {
        String sql = "SELECT StartDate FROM Discount WHERE DiscountID = ?";

        try (Connection connection = getConnection();
                PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, discountID);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getDate("StartDate").toString();
            }
        } catch (SQLException e) {
            LOGGER.severe("Error getting discount start date: " + e.getMessage());
        }
        return null;
    }

    /**
     * Hard delete discount (only for discounts that haven't started yet)
     */
    public boolean hardDeleteDiscount(int discountID) {
        String sql = "DELETE FROM Discount WHERE DiscountID = ?";

        try (Connection connection = getConnection();
                PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, discountID);
            int rowsAffected = stmt.executeUpdate();

            if (rowsAffected > 0) {
                LOGGER.info("Discount hard deleted: ID " + discountID);
                return true;
            }
        } catch (SQLException e) {
            LOGGER.severe("Error hard deleting discount: " + e.getMessage());
        }
        return false;
    }

    /**
     * Smart delete discount - decides between hard delete or scheduled deletion
     */
    public boolean smartDeleteDiscount(int discountID) {
        // Check if discount is already scheduled for deletion or update
        if (isScheduledForDeletion(discountID) || isScheduledForUpdate(discountID)) {
            LOGGER.warning("Discount already scheduled for operation: ID " + discountID);
            return false;
        }

        // Check if start date is tomorrow or later (future discount)
        if (isStartDateTomorrowOrLater(discountID)) {
            // Hard delete if discount hasn't started yet
            return hardDeleteDiscount(discountID);
        } else {
            // Schedule deletion for active or started discounts
            return scheduleDiscountDeletion(discountID);
        }
    }

    /**
     * Check if there is already an active loyalty discount
     */
    public boolean hasActiveLoyaltyDiscount() {
        String sql = "SELECT COUNT(*) FROM Discount WHERE DiscountType = 'Loyalty' AND IsActive = 1";
        return getCount(sql) > 0;
    }

    /**
     * Check if there is already an active loyalty discount excluding a specific ID
     */
    public boolean hasActiveLoyaltyDiscountExcluding(int excludeDiscountId) {
        String sql = "SELECT COUNT(*) FROM Discount WHERE DiscountType = 'Loyalty' AND IsActive = 1 AND DiscountID != ?";

        try (Connection connection = getConnection();
                PreparedStatement ps = connection.prepareStatement(sql)) {

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
        String sql = "SELECT * FROM Discount WHERE DiscountID = ?";

        try (Connection connection = getConnection();
                PreparedStatement ps = connection.prepareStatement(sql)) {

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

    /**
     * Check if discount description already exists
     */
    public boolean discountDescriptionExists(String description) {
        return discountDescriptionExists(description, 0);
    }

    /**
     * Check if discount description already exists excluding a specific ID
     */
    public boolean discountDescriptionExists(String description, int excludeDiscountId) {
        String sql;
        if (excludeDiscountId > 0) {
            sql = "SELECT COUNT(*) FROM Discount WHERE Description = ? AND DiscountID != ? AND IsActive = 1";
        } else {
            sql = "SELECT COUNT(*) FROM Discount WHERE Description = ? AND IsActive = 1";
        }

        try (Connection connection = getConnection();
                PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setString(1, description);
            if (excludeDiscountId > 0) {
                ps.setInt(2, excludeDiscountId);
            }

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            LOGGER.severe("Error checking discount description: " + e.getMessage());
        }
        return false;
    }

    // Private helper methods

    /**
     * Automatically update discount status for expired discounts
     */
    private void autoUpdateDiscountStatus() {
        String sql = "UPDATE Discount SET IsActive = 0 WHERE IsActive = 1 AND EndDate IS NOT NULL AND EndDate < CAST(GETDATE() AS DATE)";

        try (Connection connection = getConnection();
                PreparedStatement ps = connection.prepareStatement(sql)) {

            int expiredCount = ps.executeUpdate();
            if (expiredCount > 0) {
                LOGGER.info("Auto-deactivated " + expiredCount + " expired discounts");
            }
        } catch (SQLException e) {
            LOGGER.severe("Error auto-updating discount status: " + e.getMessage());
        }
    }

    /**
     * Validate discount basic information
     */
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

    /**
     * Validate discount dates
     */
    private boolean validateDiscountDates(Discount discount) {
        try {
            LocalDate today = LocalDate.now();
            LocalDate tomorrow = today.plusDays(1);
            LocalDate startDate = LocalDate.parse(discount.getStartDate());

            // Start date must be tomorrow or later
            if (startDate.isBefore(tomorrow)) {
                LOGGER.warning("Start date must be tomorrow or later");
                return false;
            }

            if (discount.getEndDate() != null && !discount.getEndDate().trim().isEmpty()) {
                LocalDate endDate = LocalDate.parse(discount.getEndDate());
                LocalDate dayAfterTomorrow = today.plusDays(2);

                // End date must be at least 2 days from today
                if (endDate.isBefore(dayAfterTomorrow)) {
                    LOGGER.warning("End date must be at least 2 days from today");
                    return false;
                }

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

    /**
     * Set discount parameters for prepared statement
     */
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

    /**
     * Extract discount object from result set
     */
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

    /**
     * Get count from database query
     */
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
}