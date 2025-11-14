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
     * Retrieves discounts by status with pagination and filtering
     * 
     * @param isActive  true for active discounts, false for inactive
     * @param page      the page number for pagination
     * @param type      filter by discount type (Percentage, Fixed, Loyalty)
     * @param startDate filter by start date (minimum date)
     * @param endDate   filter by end date (maximum date)
     * @param search    search term for description or value
     * @return list of discounts matching the criteria
     */
    public List<Discount> getDiscountsByStatus(boolean isActive, int page, String type,
            String startDate, String endDate, String search) {
        autoUpdateDiscountStatus();
        List<Discount> discounts = new ArrayList<>();
        int offset = (page - 1) * PAGE_SIZE;

        // Build SQL query dynamically based on filters
        StringBuilder sqlBuilder = new StringBuilder();
        sqlBuilder.append("SELECT * FROM Discount WHERE IsActive = ?");
        List<Object> params = new ArrayList<>();
        params.add(isActive);

        // Add filter parameters
        if (type != null && !type.isEmpty()) {
            sqlBuilder.append(" AND DiscountType = ?");
            params.add(type);
        }

        if (startDate != null && !startDate.isEmpty()) {
            sqlBuilder.append(" AND StartDate >= ?");
            params.add(startDate);
        }

        if (endDate != null && !endDate.isEmpty()) {
            sqlBuilder.append(" AND (EndDate <= ? OR EndDate IS NULL)");
            params.add(endDate);
        }

        // Add search parameter
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

            // Set all parameters
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
     * Gets the count of discounts by status with additional filters
     * 
     * @param isActive  true for active discounts, false for inactive
     * @param type      filter by discount type
     * @param startDate filter by start date
     * @param endDate   filter by end date
     * @param search    search term
     * @return count of discounts matching the criteria
     */
    public int getDiscountsCountByStatus(boolean isActive, String type, String startDate,
            String endDate, String search) {
        autoUpdateDiscountStatus();

        // Build count query dynamically
        StringBuilder sqlBuilder = new StringBuilder();
        sqlBuilder.append("SELECT COUNT(*) FROM Discount WHERE IsActive = ?");
        List<Object> params = new ArrayList<>();
        params.add(isActive);

        // Add filter parameters
        if (type != null && !type.isEmpty()) {
            sqlBuilder.append(" AND DiscountType = ?");
            params.add(type);
        }

        if (startDate != null && !startDate.isEmpty()) {
            sqlBuilder.append(" AND StartDate >= ?");
            params.add(startDate);
        }

        if (endDate != null && !endDate.isEmpty()) {
            sqlBuilder.append(" AND (EndDate <= ? OR EndDate IS NULL)");
            params.add(endDate);
        }

        // Add search parameter
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
     * Retrieves the active loyalty discount (there can be only one active loyalty
     * discount at a time)
     * 
     * @return the active loyalty discount or null if not found
     */
    public Discount getLoyaltyDiscount() {
        autoUpdateDiscountStatus();

        String sql = "SELECT TOP 1 * FROM Discount WHERE DiscountType = 'Loyalty' AND IsActive = 1 ORDER BY DiscountID DESC";

        try (Connection connection = getConnection();
                PreparedStatement ps = connection.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                Discount discount = extractDiscountFromResultSet(rs);
                LOGGER.info("Found active loyalty discount: ID " + discount.getDiscountId());
                return discount;
            } else {
                LOGGER.info("No active loyalty discount found");
                return null;
            }

        } catch (SQLException e) {
            LOGGER.severe("Error fetching loyalty discount: " + e.getMessage());
            return null;
        }
    }

    /**
     * Adds a new discount to the database
     * 
     * @param discount the discount object to add
     * @return true if successful, false otherwise
     */
    public boolean addDiscount(Discount discount) {
        if (!validateDiscount(discount)) {
            return false;
        }

        String sql = "INSERT INTO Discount (Description, DiscountType, Value, MaxDiscount, " +
                "MinOrderTotal, StartDate, EndDate, IsActive) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

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
     * Updates an existing discount (only if start date is in future)
     * 
     * @param discount the discount object with updated values
     * @return true if successful, false otherwise
     */
    public boolean updateDiscount(Discount discount) {
        if (!validateDiscount(discount) || discount.getDiscountId() <= 0) {
            return false;
        }

        // Only update if discount hasn't started yet (start date > today)
        if (isStartDateInFuture(discount.getDiscountId())) {
            return updateDiscountImmediately(discount);
        } else {
            LOGGER.warning("Cannot update discount that has already started: ID " + discount.getDiscountId());
            return false;
        }
    }

    /**
     * Immediately updates discount in database
     */
    private boolean updateDiscountImmediately(Discount discount) {
        String sql = "UPDATE Discount SET Description = ?, DiscountType = ?, Value = ?, " +
                "MaxDiscount = ?, MinOrderTotal = ?, StartDate = ?, EndDate = ? " +
                "WHERE DiscountID = ?";

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
     * Schedules discount deletion for end of day
     * 
     * @param discountID the ID of discount to delete
     * @return true if successful, false otherwise
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
     * Checks if discount is scheduled for deletion
     * 
     * @param discountID the discount ID to check
     * @return true if scheduled for deletion, false otherwise
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
     * Checks if discount start date is in future (can be edited)
     * 
     * @param discountID the discount ID to check
     * @return true if start date > today, false otherwise
     */
    public boolean isStartDateInFuture(int discountID) {
        String sql = "SELECT 1 FROM Discount WHERE DiscountID = ? AND StartDate > CAST(GETDATE() AS DATE)";

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
     * Checks if discount can be edited (start date > today)
     * 
     * @param discountID the discount ID to check
     * @return true if editable, false otherwise
     */
    public boolean canEditDiscount(int discountID) {
        return isStartDateInFuture(discountID);
    }

    /**
     * Gets current start date of discount
     * 
     * @param discountID the discount ID
     * @return start date as string or null if not found
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
     * Hard deletes discount (only for discounts that haven't started yet)
     * 
     * @param discountID the discount ID to delete
     * @return true if successful, false otherwise
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
     * Smart delete - decides between hard delete or scheduled deletion
     * 
     * @param discountID the discount ID to delete
     * @return true if successful, false otherwise
     */
    public boolean smartDeleteDiscount(int discountID) {
        // Check if discount is already scheduled for deletion
        if (isScheduledForDeletion(discountID)) {
            LOGGER.warning("Discount already scheduled for deletion: ID " + discountID);
            return false;
        }

        // Check if start date is in future
        if (isStartDateInFuture(discountID)) {
            // Hard delete if discount hasn't started yet
            return hardDeleteDiscount(discountID);
        } else {
            // Schedule deletion for active or started discounts
            return scheduleDiscountDeletion(discountID);
        }
    }

    /**
     * Checks if there is already an active loyalty discount
     * 
     * @return true if active loyalty discount exists, false otherwise
     */
    public boolean hasActiveLoyaltyDiscount() {
        String sql = "SELECT COUNT(*) FROM Discount WHERE DiscountType = 'Loyalty' AND IsActive = 1";
        return getCount(sql) > 0;
    }

    /**
     * Checks if there is already an active loyalty discount excluding a specific ID
     * 
     * @param excludeDiscountId the discount ID to exclude from check
     * @return true if active loyalty discount exists, false otherwise
     */
    public boolean hasActiveLoyaltyDiscountExcluding(int excludeDiscountId) {
        String sql = "SELECT COUNT(*) FROM Discount WHERE DiscountType = 'Loyalty' " +
                "AND IsActive = 1 AND DiscountID != ?";

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
     * Gets discount by ID
     * 
     * @param discountId the discount ID
     * @return Discount object or null if not found
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
     * Checks if discount description already exists
     * 
     * @param description the description to check
     * @return true if exists, false otherwise
     */
    public boolean discountDescriptionExists(String description) {
        return discountDescriptionExists(description, 0);
    }

    /**
     * Checks if discount description already exists excluding a specific ID
     * 
     * @param description       the description to check
     * @param excludeDiscountId the discount ID to exclude
     * @return true if exists, false otherwise
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

    // ==================== PRIVATE HELPER METHODS ====================

    /**
     * Automatically updates discount status for expired discounts
     */
    private void autoUpdateDiscountStatus() {
        String sql = "UPDATE Discount SET IsActive = 0 WHERE IsActive = 1 " +
                "AND EndDate IS NOT NULL AND EndDate < CAST(GETDATE() AS DATE)";

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
     * Validates discount basic information
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
     * Validates discount dates
     */
    private boolean validateDiscountDates(Discount discount) {
        try {
            LocalDate today = LocalDate.now();
            LocalDate startDate = LocalDate.parse(discount.getStartDate());

            // Start date must be today or later
            if (startDate.isBefore(today)) {
                LOGGER.warning("Start date must be today or later");
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

    /**
     * Sets discount parameters for prepared statement
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
     * Extracts discount object from result set
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
     * Gets count from database query
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