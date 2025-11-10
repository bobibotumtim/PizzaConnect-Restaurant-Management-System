package dao;

import models.Table;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

public class TableDAO extends DBContext {
    private static final Logger LOGGER = Logger.getLogger(TableDAO.class.getName());

    public List<Table> getAllTables() {
        List<Table> tables = new ArrayList<>();
        String sql = "SELECT * FROM [Table] ORDER BY TableNumber";

        try (Connection connection = getConnection();
                PreparedStatement stmt = connection.prepareStatement(sql);
                ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                Table table = new Table();
                table.setTableID(rs.getInt("TableID"));
                table.setTableNumber(rs.getString("TableNumber"));
                table.setCapacity(rs.getInt("Capacity"));
                table.setActive(rs.getBoolean("IsActive"));
                tables.add(table);
            }
        } catch (SQLException e) {
            LOGGER.severe("Error fetching all tables: " + e.getMessage());
        }
        return tables;
    }

    public Table getTableById(int tableID) {
        Table table = null;
        String sql = "SELECT * FROM [Table] WHERE TableID = ?";

        try (Connection connection = getConnection();
                PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, tableID);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                table = new Table();
                table.setTableID(rs.getInt("TableID"));
                table.setTableNumber(rs.getString("TableNumber"));
                table.setCapacity(rs.getInt("Capacity"));
                table.setActive(rs.getBoolean("IsActive"));
            }
        } catch (SQLException e) {
            LOGGER.severe("Error fetching table by ID: " + e.getMessage());
        }
        return table;
    }

    public Table getTableByNumber(String tableNumber) {
        Table table = null;
        String sql = "SELECT * FROM [Table] WHERE TableNumber = ?";

        try (Connection connection = getConnection();
                PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setString(1, tableNumber);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                table = new Table();
                table.setTableID(rs.getInt("TableID"));
                table.setTableNumber(rs.getString("TableNumber"));
                table.setCapacity(rs.getInt("Capacity"));
                table.setActive(rs.getBoolean("IsActive"));
            }
        } catch (SQLException e) {
            LOGGER.severe("Error fetching table by number: " + e.getMessage());
        }
        return table;
    }

    public boolean addTable(Table table) {
        String sql = "INSERT INTO [Table] (TableNumber, Capacity, IsActive) VALUES (?, ?, ?)";

        try (Connection connection = getConnection();
                PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setString(1, table.getTableNumber());
            stmt.setInt(2, table.getCapacity());
            stmt.setBoolean(3, table.isActive());

            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.severe("Error adding table: " + e.getMessage());
            return false;
        }
    }

    public boolean updateTable(Table table) {
        String sql = "UPDATE [Table] SET TableNumber = ?, Capacity = ?, IsActive = ? WHERE TableID = ?";

        try (Connection connection = getConnection();
                PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setString(1, table.getTableNumber());
            stmt.setInt(2, table.getCapacity());
            stmt.setBoolean(3, table.isActive());
            stmt.setInt(4, table.getTableID());

            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.severe("Error updating table: " + e.getMessage());
            return false;
        }
    }

    /**
     * Schedule table deletion instead of immediate delete
     * Table will be deactivated at the end of the day via scheduled job
     */
    public boolean scheduleTableDeletion(int tableID) {
        String sql = "EXEC ScheduleDeletion @EntityType = 'Table', @EntityID = ?";

        try (Connection connection = getConnection();
                PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, tableID);
            stmt.executeUpdate();
            LOGGER.info("Table deletion scheduled: ID " + tableID);
            return true;
        } catch (SQLException e) {
            LOGGER.severe("Error scheduling table deletion: " + e.getMessage());
            return false;
        }
    }

    /**
     * Check if a table is scheduled for deletion
     */
    public boolean isScheduledForDeletion(int tableID) {
        String sql = "SELECT 1 FROM DeletionQueue WHERE EntityType = 'Table' AND EntityID = ?";

        try (Connection connection = getConnection();
                PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, tableID);
            ResultSet rs = stmt.executeQuery();
            return rs.next();
        } catch (SQLException e) {
            LOGGER.severe("Error checking scheduled deletion: " + e.getMessage());
            return false;
        }
    }

    /**
     * Get tables with deletion status information
     * Useful for UI to display scheduled deletions
     */
    public List<Table> getAllTablesWithDeletionStatus() {
        List<Table> tables = new ArrayList<>();
        String sql = """
                SELECT t.*,
                       CASE
                           WHEN dq.EntityID IS NOT NULL THEN 1
                           ELSE 0
                       END AS IsScheduledForDeletion
                FROM [Table] t
                LEFT JOIN DeletionQueue dq ON t.TableID = dq.EntityID
                    AND dq.EntityType = 'Table'
                WHERE t.IsActive = 1
                ORDER BY t.TableNumber
                """;

        try (Connection connection = getConnection();
                PreparedStatement stmt = connection.prepareStatement(sql);
                ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                Table table = new Table();
                table.setTableID(rs.getInt("TableID"));
                table.setTableNumber(rs.getString("TableNumber"));
                table.setCapacity(rs.getInt("Capacity"));
                table.setActive(rs.getBoolean("IsActive"));
                tables.add(table);
            }
        } catch (SQLException e) {
            LOGGER.severe("Error fetching tables with deletion status: " + e.getMessage());
        }
        return tables;
    }

    /**
     * Immediate table deletion (kept for backward compatibility)
     * Use scheduleTableDeletion instead for delayed deletion
     */
    public boolean deleteTable(int tableID) {
        String sql = "UPDATE [Table] SET IsActive = 0 WHERE TableID = ?";

        try (Connection connection = getConnection();
                PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, tableID);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.severe("Error deleting table: " + e.getMessage());
            return false;
        }
    }

    public List<Table> getActiveTables() {
        List<Table> tables = new ArrayList<>();
        String sql = "SELECT * FROM [Table] WHERE IsActive = 1 ORDER BY TableNumber";

        try (Connection connection = getConnection();
                PreparedStatement stmt = connection.prepareStatement(sql);
                ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                Table table = new Table();
                table.setTableID(rs.getInt("TableID"));
                table.setTableNumber(rs.getString("TableNumber"));
                table.setCapacity(rs.getInt("Capacity"));
                table.setActive(rs.getBoolean("IsActive"));
                tables.add(table);
            }
        } catch (SQLException e) {
            LOGGER.severe("Error fetching active tables: " + e.getMessage());
        }
        return tables;
    }

    public List<Table> getInactiveTables() {
        List<Table> tables = new ArrayList<>();
        String sql = "SELECT * FROM [Table] WHERE IsActive = 0 ORDER BY TableNumber";

        try (Connection connection = getConnection();
                PreparedStatement stmt = connection.prepareStatement(sql);
                ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                Table table = new Table();
                table.setTableID(rs.getInt("TableID"));
                table.setTableNumber(rs.getString("TableNumber"));
                table.setCapacity(rs.getInt("Capacity"));
                table.setActive(rs.getBoolean("IsActive"));
                tables.add(table);
            }
        } catch (SQLException e) {
            LOGGER.severe("Error fetching inactive tables: " + e.getMessage());
        }
        return tables;
    }

    public List<Table> getTablesByCapacity(int minCapacity) {
        List<Table> tables = new ArrayList<>();
        String sql = "SELECT * FROM [Table] WHERE Capacity >= ? AND IsActive = 1 ORDER BY Capacity, TableNumber";

        try (Connection connection = getConnection();
                PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, minCapacity);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                Table table = new Table();
                table.setTableID(rs.getInt("TableID"));
                table.setTableNumber(rs.getString("TableNumber"));
                table.setCapacity(rs.getInt("Capacity"));
                table.setActive(rs.getBoolean("IsActive"));
                tables.add(table);
            }
        } catch (SQLException e) {
            LOGGER.severe("Error fetching tables by capacity: " + e.getMessage());
        }
        return tables;
    }

    /**
     * Get table status by ID
     */
    public String getTableStatus(int tableID) {
        String sql = "SELECT [Status] FROM [Table] WHERE TableID = ?";
        
        try (Connection connection = getConnection();
                PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, tableID);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getString("Status");
            }
        } catch (SQLException e) {
            LOGGER.severe("Error fetching table status: " + e.getMessage());
        }
        return null;
    }

    /**
     * Update table status
     */
    public boolean updateTableStatus(int tableID, String status) {
        String sql = "UPDATE [Table] SET [Status] = ? WHERE TableID = ?";
        
        try (Connection connection = getConnection();
                PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setString(1, status);
            stmt.setInt(2, tableID);
            
            int rowsAffected = stmt.executeUpdate();
            if (rowsAffected > 0) {
                LOGGER.info("Table status updated: ID " + tableID + " -> " + status);
                return true;
            }
            return false;
        } catch (SQLException e) {
            LOGGER.severe("Error updating table status: " + e.getMessage());
            return false;
        }
    }

    /**
     * Get all available (empty) tables
     */
    public List<Table> getAvailableTables() {
        List<Table> tables = new ArrayList<>();
        String sql = "SELECT * FROM [Table] WHERE [Status] = 'available' AND IsActive = 1 ORDER BY TableNumber";

        try (Connection connection = getConnection();
                PreparedStatement stmt = connection.prepareStatement(sql);
                ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                Table table = new Table();
                table.setTableID(rs.getInt("TableID"));
                table.setTableNumber(rs.getString("TableNumber"));
                table.setCapacity(rs.getInt("Capacity"));
                table.setStatus(rs.getString("Status"));
                table.setActive(rs.getBoolean("IsActive"));
                tables.add(table);
            }
        } catch (SQLException e) {
            LOGGER.severe("Error fetching available tables: " + e.getMessage());
        }
        return tables;
    }

    /**
     * Get all occupied (in-use) tables
     */
    public List<Table> getOccupiedTables() {
        List<Table> tables = new ArrayList<>();
        String sql = "SELECT * FROM [Table] WHERE [Status] = 'unavailable' AND IsActive = 1 ORDER BY TableNumber";

        try (Connection connection = getConnection();
                PreparedStatement stmt = connection.prepareStatement(sql);
                ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                Table table = new Table();
                table.setTableID(rs.getInt("TableID"));
                table.setTableNumber(rs.getString("TableNumber"));
                table.setCapacity(rs.getInt("Capacity"));
                table.setStatus(rs.getString("Status"));
                table.setActive(rs.getBoolean("IsActive"));
                tables.add(table);
            }
        } catch (SQLException e) {
            LOGGER.severe("Error fetching occupied tables: " + e.getMessage());
        }
        return tables;
    }

    /**
     * Get all active tables with ACTUAL status (considering active orders)
     * Uses VIEW to calculate real-time status based on Order table
     */
    public List<Table> getActiveTablesWithStatus() {
        List<Table> tables = new ArrayList<>();
        
        // Use VIEW that calculates actual status based on active orders
        // ActualStatus will be: 'available', 'occupied', or 'unavailable'
        String sql = """
            SELECT 
                t.TableID,
                t.TableNumber,
                t.Capacity,
                t.[Status] AS TableStatus,
                t.IsActive,
                COUNT(o.OrderID) AS ActiveOrderCount,
                CASE 
                    WHEN t.[Status] = 'unavailable' THEN 'unavailable'
                    WHEN COUNT(o.OrderID) > 0 THEN 'occupied'
                    ELSE 'available'
                END AS ActualStatus
            FROM [Table] t
            LEFT JOIN [Order] o ON t.TableID = o.TableID AND o.[Status] < 4
            WHERE t.IsActive = 1
            GROUP BY t.TableID, t.TableNumber, t.Capacity, t.[Status], t.IsActive
            ORDER BY t.TableNumber
        """;

        try (Connection connection = getConnection();
                PreparedStatement stmt = connection.prepareStatement(sql);
                ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                Table table = new Table();
                table.setTableID(rs.getInt("TableID"));
                table.setTableNumber(rs.getString("TableNumber"));
                table.setCapacity(rs.getInt("Capacity"));
                // Use ActualStatus instead of TableStatus for display
                table.setStatus(rs.getString("ActualStatus"));
                table.setActive(rs.getBoolean("IsActive"));
                tables.add(table);
                
                // Debug log
                LOGGER.info("Table " + table.getTableNumber() + 
                           " - DB Status: " + rs.getString("TableStatus") + 
                           " - Actual Status: " + rs.getString("ActualStatus") +
                           " - Active Orders: " + rs.getInt("ActiveOrderCount"));
            }
        } catch (SQLException e) {
            LOGGER.severe("Error fetching active tables with status: " + e.getMessage());
            e.printStackTrace();
        }
        return tables;
    }
}