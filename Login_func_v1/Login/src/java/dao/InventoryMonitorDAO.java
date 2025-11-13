package dao;

import models.InventoryMonitorItem;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * DAO class for Inventory Monitor functionality
 * Handles data retrieval from v_InventoryMonitor view
 */
public class InventoryMonitorDAO {
    
    /**
     * Get database connection using DBContext
     * @return Connection object
     * @throws SQLException if connection fails
     */
    private Connection getConn() throws SQLException {
        return new DBContext().getConnection();
    }
    
    /**
     * Helper method to map ResultSet to InventoryMonitorItem
     * @param rs ResultSet from query
     * @return InventoryMonitorItem object
     * @throws SQLException if mapping fails
     */
    private InventoryMonitorItem mapResultSetToItem(ResultSet rs) throws SQLException {
        InventoryMonitorItem item = new InventoryMonitorItem();
        item.setInventoryID(rs.getInt("InventoryID"));
        item.setItemName(rs.getString("ItemName"));
        item.setQuantity(rs.getBigDecimal("Quantity"));
        item.setUnit(rs.getString("Unit"));
        item.setStatus(rs.getString("Status"));
        item.setLowThreshold(rs.getBigDecimal("LowThreshold"));
        item.setCriticalThreshold(rs.getBigDecimal("CriticalThreshold"));
        item.setLastUpdated(rs.getTimestamp("LastUpdated"));
        item.setStockLevel(rs.getString("StockLevel"));
        item.setPercentOfLowLevel(rs.getBigDecimal("PercentOfLowLevel"));
        return item;
    }
    
    /**
     * Get all inventory monitor items sorted by priority
     * Priority order: CRITICAL (1), LOW (2), OK (3), INACTIVE (4)
     * @return List of all inventory monitor items
     */
    public List<InventoryMonitorItem> getAllMonitorItems() {
        List<InventoryMonitorItem> items = new ArrayList<>();
        String sql = "SELECT * FROM v_InventoryMonitor ORDER BY " +
                    "CASE StockLevel " +
                    "WHEN 'CRITICAL' THEN 1 " +
                    "WHEN 'LOW' THEN 2 " +
                    "WHEN 'OK' THEN 3 " +
                    "WHEN 'INACTIVE' THEN 4 " +
                    "ELSE 5 END, ItemName";
        
        try (Connection conn = getConn();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                items.add(mapResultSetToItem(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return items;
    }
    
    /**
     * Get items filtered by specific warning level
     * @param warningLevel The warning level to filter by (CRITICAL, LOW, OK, INACTIVE)
     * @return List of items with specified warning level
     */
    public List<InventoryMonitorItem> getItemsByWarningLevel(String warningLevel) {
        List<InventoryMonitorItem> items = new ArrayList<>();
        String sql = "SELECT * FROM v_InventoryMonitor WHERE StockLevel = ? ORDER BY ItemName";
        
        try (Connection conn = getConn();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, warningLevel);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    items.add(mapResultSetToItem(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return items;
    }

    /**
     * Search items by item name (case insensitive)
     * @param searchTerm The search term to match against item names
     * @return List of items matching the search term
     */
    public List<InventoryMonitorItem> searchItems(String searchTerm) {
        List<InventoryMonitorItem> items = new ArrayList<>();
        String sql = "SELECT * FROM v_InventoryMonitor WHERE ItemName LIKE ? ORDER BY " +
                    "CASE StockLevel " +
                    "WHEN 'CRITICAL' THEN 1 " +
                    "WHEN 'LOW' THEN 2 " +
                    "WHEN 'OK' THEN 3 " +
                    "WHEN 'INACTIVE' THEN 4 " +
                    "ELSE 5 END, ItemName";
        
        try (Connection conn = getConn();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, "%" + searchTerm + "%");
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    items.add(mapResultSetToItem(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return items;
    }
    
    /**
     * Search items with filter by warning level
     * Combines search and filter functionality
     * @param searchTerm The search term to match against item names
     * @param warningLevel The warning level to filter by
     * @return List of items matching both search and filter criteria
     */
    public List<InventoryMonitorItem> searchItemsWithFilter(String searchTerm, String warningLevel) {
        List<InventoryMonitorItem> items = new ArrayList<>();
        String sql = "SELECT * FROM v_InventoryMonitor WHERE ItemName LIKE ? AND StockLevel = ? ORDER BY ItemName";
        
        try (Connection conn = getConn();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, "%" + searchTerm + "%");
            ps.setString(2, warningLevel);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    items.add(mapResultSetToItem(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return items;
    }

    /**
     * Get count of items for each warning level
     * @return Map with warning level as key and count as value
     */
    public Map<String, Integer> getWarningLevelCounts() {
        Map<String, Integer> counts = new HashMap<>();
        
        // Initialize all levels with 0
        counts.put("CRITICAL", 0);
        counts.put("LOW", 0);
        counts.put("OK", 0);
        counts.put("INACTIVE", 0);
        
        String sql = "SELECT StockLevel, COUNT(*) as Count FROM v_InventoryMonitor GROUP BY StockLevel";
        
        try (Connection conn = getConn();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                String level = rs.getString("StockLevel");
                int count = rs.getInt("Count");
                counts.put(level, count);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return counts;
    }
}
