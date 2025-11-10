package dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import models.*;

/**
 * Data Access Object for Inventory Monitoring Dashboard
 * Handles database operations for dashboard metrics, alerts, trends, and critical items
 */
public class MonitorDAO {
    
    // Database connection method - using same pattern as other DAOs
    private Connection getConn() throws Exception {
        return new DBContext().getConnection();
    }
    
    /**
     * Get dashboard overview metrics
     * @return DashboardMetrics object with key statistics
     */
    public DashboardMetrics getDashboardMetrics() {
        DashboardMetrics metrics = new DashboardMetrics();
        
        String sql = "SELECT " +
                    "COUNT(*) as totalItems, " +
                    "SUM(CASE WHEN i.Quantity <= it.LowStockThreshold THEN 1 ELSE 0 END) as lowStockItems, " +
                    "SUM(CASE WHEN i.Quantity <= 0 THEN 1 ELSE 0 END) as outOfStockItems, " +
                    "SUM(CASE WHEN ci.IsActive = 1 THEN 1 ELSE 0 END) as criticalItems, " +
                    "GETDATE() as lastUpdated " +
                    "FROM Inventory i " +
                    "LEFT JOIN InventoryThresholds it ON i.InventoryID = it.InventoryID AND it.IsActive = 1 " +
                    "LEFT JOIN CriticalItems ci ON i.InventoryID = ci.InventoryID AND ci.IsActive = 1 " +
                    "WHERE i.Status = 'Active'";
        
        try (Connection conn = getConn();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            if (rs.next()) {
                metrics.setTotalItems(rs.getInt("totalItems"));
                metrics.setLowStockItems(rs.getInt("lowStockItems"));
                metrics.setOutOfStockItems(rs.getInt("outOfStockItems"));
                metrics.setCriticalItems(rs.getInt("criticalItems"));
                metrics.setLastUpdated(rs.getTimestamp("lastUpdated"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        return metrics;
    }
    
    /**
     * Get list of low stock alerts
     * @return List of AlertItem objects for low stock items
     */
    public List<AlertItem> getLowStockAlerts() {
        List<AlertItem> alerts = new ArrayList<>();
        
        String sql = "SELECT i.InventoryID, i.ItemName, i.Quantity, i.Unit, " +
                    "it.LowStockThreshold, it.CriticalThreshold, " +
                    "ci.Priority, ci.Category " +
                    "FROM Inventory i " +
                    "INNER JOIN InventoryThresholds it ON i.InventoryID = it.InventoryID AND it.IsActive = 1 " +
                    "LEFT JOIN CriticalItems ci ON i.InventoryID = ci.InventoryID AND ci.IsActive = 1 " +
                    "WHERE i.Status = 'Active' AND i.Quantity > 0 AND i.Quantity <= it.LowStockThreshold " +
                    "ORDER BY " +
                    "CASE WHEN i.Quantity <= it.CriticalThreshold THEN 1 ELSE 2 END, " +
                    "COALESCE(ci.Priority, 3), i.ItemName";
        
        try (Connection conn = getConn();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                int inventoryID = rs.getInt("InventoryID");
                String itemName = rs.getString("ItemName");
                double quantity = rs.getDouble("Quantity");
                String unit = rs.getString("Unit");
                double lowThreshold = rs.getDouble("LowStockThreshold");
                double criticalThreshold = rs.getDouble("CriticalThreshold");
                int priority = rs.getInt("Priority");
                
                // Determine alert type and priority
                AlertItem.AlertType alertType = quantity <= criticalThreshold ? 
                    AlertItem.AlertType.CRITICAL_LOW : AlertItem.AlertType.LOW_STOCK;
                
                AlertItem.Priority alertPriority = AlertItem.Priority.MEDIUM;
                if (priority == 1) alertPriority = AlertItem.Priority.HIGH;
                else if (priority == 3) alertPriority = AlertItem.Priority.LOW;
                
                AlertItem alert = new AlertItem(inventoryID, itemName, quantity, 
                                              lowThreshold, unit, alertType, alertPriority);
                alerts.add(alert);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        return alerts;
    }
    
    /**
     * Get list of out of stock alerts
     * @return List of AlertItem objects for out of stock items
     */
    public List<AlertItem> getOutOfStockAlerts() {
        List<AlertItem> alerts = new ArrayList<>();
        
        String sql = "SELECT i.InventoryID, i.ItemName, i.Quantity, i.Unit, " +
                    "it.LowStockThreshold, it.CriticalThreshold, " +
                    "ci.Priority, ci.Category " +
                    "FROM Inventory i " +
                    "INNER JOIN InventoryThresholds it ON i.InventoryID = it.InventoryID AND it.IsActive = 1 " +
                    "LEFT JOIN CriticalItems ci ON i.InventoryID = ci.InventoryID AND ci.IsActive = 1 " +
                    "WHERE i.Status = 'Active' AND i.Quantity <= 0 " +
                    "ORDER BY COALESCE(ci.Priority, 3), i.ItemName";
        
        try (Connection conn = getConn();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                int inventoryID = rs.getInt("InventoryID");
                String itemName = rs.getString("ItemName");
                double quantity = rs.getDouble("Quantity");
                String unit = rs.getString("Unit");
                double lowThreshold = rs.getDouble("LowStockThreshold");
                int priority = rs.getInt("Priority");
                
                AlertItem.Priority alertPriority = AlertItem.Priority.HIGH; // Out of stock is always high priority
                if (priority == 1) alertPriority = AlertItem.Priority.HIGH;
                
                AlertItem alert = new AlertItem(inventoryID, itemName, quantity, 
                                              lowThreshold, unit, AlertItem.AlertType.OUT_OF_STOCK, alertPriority);
                alerts.add(alert);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        return alerts;
    }
    
    /**
     * Get all alerts (both low stock and out of stock)
     * @return List of all AlertItem objects
     */
    public List<AlertItem> getAllAlerts() {
        List<AlertItem> allAlerts = new ArrayList<>();
        allAlerts.addAll(getOutOfStockAlerts()); // Out of stock first (higher priority)
        allAlerts.addAll(getLowStockAlerts());
        return allAlerts;
    }
    
    /**
     * Get inventory trends for the past 7 days
     * @param inventoryID Specific inventory item ID, or 0 for all items
     * @return List of InventoryTrend objects
     */
    public List<InventoryTrend> getInventoryTrends(int inventoryID) {
        List<InventoryTrend> trends = new ArrayList<>();
        
        StringBuilder sql = new StringBuilder(
            "SELECT DISTINCT i.InventoryID, i.ItemName, i.Unit, i.Quantity " +
            "FROM Inventory i " +
            "INNER JOIN InventoryLog il ON i.InventoryID = il.InventoryID " +
            "WHERE i.Status = 'Active' AND il.LogDate >= DATEADD(DAY, -7, GETDATE())"
        );
        
        if (inventoryID > 0) {
            sql.append(" AND i.InventoryID = ?");
        }
        
        sql.append(" ORDER BY i.ItemName");
        
        try (Connection conn = getConn();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            if (inventoryID > 0) {
                ps.setInt(1, inventoryID);
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int id = rs.getInt("InventoryID");
                    String itemName = rs.getString("ItemName");
                    String unit = rs.getString("Unit");
                    double currentQuantity = rs.getDouble("Quantity");
                    
                    InventoryTrend trend = new InventoryTrend(id, itemName, unit);
                    trend.setCurrentQuantity(currentQuantity);
                    
                    // Get trend data for this item
                    loadTrendData(trend);
                    trend.calculateTrendMetrics();
                    
                    trends.add(trend);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        return trends;
    }
    
    /**
     * Load trend data points for a specific inventory item
     * @param trend InventoryTrend object to populate with data
     */
    private void loadTrendData(InventoryTrend trend) {
        String sql = "SELECT LogDate, NewQuantity, ChangeType " +
                    "FROM InventoryLog " +
                    "WHERE InventoryID = ? AND LogDate >= DATEADD(DAY, -7, GETDATE()) " +
                    "ORDER BY LogDate";
        
        try (Connection conn = getConn();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, trend.getInventoryID());
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Timestamp date = rs.getTimestamp("LogDate");
                    double quantity = rs.getDouble("NewQuantity");
                    String changeType = rs.getString("ChangeType");
                    
                    trend.addTrendPoint(date, quantity, changeType);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    /**
     * Get critical items status for pizza ingredients
     * @return List of CriticalItemStatus objects
     */
    public List<CriticalItemStatus> getCriticalItemsStatus() {
        List<CriticalItemStatus> criticalItems = new ArrayList<>();
        
        String sql = "SELECT i.InventoryID, i.ItemName, i.Quantity, i.Unit, " +
                    "it.LowStockThreshold, it.CriticalThreshold, " +
                    "ci.Priority, ci.Category, i.LastUpdated " +
                    "FROM Inventory i " +
                    "INNER JOIN CriticalItems ci ON i.InventoryID = ci.InventoryID AND ci.IsActive = 1 " +
                    "INNER JOIN InventoryThresholds it ON i.InventoryID = it.InventoryID AND it.IsActive = 1 " +
                    "WHERE i.Status = 'Active' " +
                    "ORDER BY ci.Priority, i.ItemName";
        
        try (Connection conn = getConn();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                int inventoryID = rs.getInt("InventoryID");
                String itemName = rs.getString("ItemName");
                double quantity = rs.getDouble("Quantity");
                String unit = rs.getString("Unit");
                double lowThreshold = rs.getDouble("LowStockThreshold");
                double criticalThreshold = rs.getDouble("CriticalThreshold");
                int priority = rs.getInt("Priority");
                String categoryStr = rs.getString("Category");
                Timestamp lastUpdated = rs.getTimestamp("LastUpdated");
                
                // Map category string to enum
                CriticalItemStatus.CriticalCategory category = CriticalItemStatus.CriticalCategory.OTHER;
                try {
                    category = CriticalItemStatus.CriticalCategory.valueOf(categoryStr.toUpperCase());
                } catch (Exception e) {
                    // Keep default OTHER category
                }
                
                CriticalItemStatus criticalItem = new CriticalItemStatus(
                    inventoryID, itemName, quantity, lowThreshold, criticalThreshold, 
                    unit, category, priority
                );
                criticalItem.setLastUpdated(lastUpdated);
                
                // Calculate usage rate from recent logs
                double usageRate = calculateUsageRate(inventoryID);
                criticalItem.setUsageRate(usageRate);
                
                criticalItems.add(criticalItem);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        return criticalItems;
    }
    
    /**
     * Calculate daily usage rate for an inventory item based on recent logs
     * @param inventoryID Inventory item ID
     * @return Daily usage rate
     */
    private double calculateUsageRate(int inventoryID) {
        String sql = "SELECT AVG(OldQuantity - NewQuantity) as avgUsage " +
                    "FROM InventoryLog " +
                    "WHERE InventoryID = ? AND ChangeType = 'USAGE' " +
                    "AND LogDate >= DATEADD(DAY, -7, GETDATE()) " +
                    "AND OldQuantity > NewQuantity";
        
        try (Connection conn = getConn();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, inventoryID);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble("avgUsage");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        return 0.0;
    }
    
    /**
     * Update inventory thresholds
     * @param inventoryID Inventory item ID
     * @param lowThreshold New low stock threshold
     * @param criticalThreshold New critical threshold
     * @return true if update successful
     */
    public boolean updateThresholds(int inventoryID, double lowThreshold, double criticalThreshold) {
        String sql = "UPDATE InventoryThresholds SET " +
                    "LowStockThreshold = ?, CriticalThreshold = ? " +
                    "WHERE InventoryID = ? AND IsActive = 1";
        
        try (Connection conn = getConn();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setDouble(1, lowThreshold);
            ps.setDouble(2, criticalThreshold);
            ps.setInt(3, inventoryID);
            
            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
            
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Log inventory change for trend analysis
     * @param inventoryID Inventory item ID
     * @param oldQuantity Previous quantity
     * @param newQuantity New quantity
     * @param changeType Type of change (UPDATE, USAGE, RESTOCK)
     * @param reason Reason for change
     */
    public void logInventoryChange(int inventoryID, double oldQuantity, double newQuantity, 
                                  String changeType, String reason) {
        String sql = "INSERT INTO InventoryLog (InventoryID, OldQuantity, NewQuantity, ChangeType, ChangeReason, LogDate) " +
                    "VALUES (?, ?, ?, ?, ?, GETDATE())";
        
        try (Connection conn = getConn();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, inventoryID);
            ps.setDouble(2, oldQuantity);
            ps.setDouble(3, newQuantity);
            ps.setString(4, changeType);
            ps.setString(5, reason);
            
            ps.executeUpdate();
            
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    /**
     * Get inventory item details by ID
     * @param inventoryID Inventory item ID
     * @return Inventory object or null if not found
     */
    public Inventory getInventoryById(int inventoryID) {
        String sql = "SELECT InventoryID, ItemName, Quantity, Unit, LastUpdated, Status " +
                    "FROM Inventory WHERE InventoryID = ?";
        
        try (Connection conn = getConn();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, inventoryID);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Inventory inv = new Inventory();
                    inv.setInventoryID(rs.getInt("InventoryID"));
                    inv.setItemName(rs.getString("ItemName"));
                    inv.setQuantity(rs.getDouble("Quantity"));
                    inv.setUnit(rs.getString("Unit"));
                    inv.setLastUpdated(rs.getTimestamp("LastUpdated"));
                    inv.setStatus(rs.getString("Status"));
                    return inv;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        return null;
    }
    
    /**
     * Get all inventory items with threshold information for display
     * @return List of inventory items with threshold data
     */
    public List<InventoryDisplayItem> getAllInventoryForDisplay() {
        List<InventoryDisplayItem> items = new ArrayList<>();
        
        String sql = "SELECT i.InventoryID, i.ItemName, i.Quantity, i.Unit, i.Status, " +
                    "it.LowStockThreshold, it.CriticalThreshold, " +
                    "ci.Category, ci.Priority " +
                    "FROM Inventory i " +
                    "LEFT JOIN InventoryThresholds it ON i.InventoryID = it.InventoryID AND it.IsActive = 1 " +
                    "LEFT JOIN CriticalItems ci ON i.InventoryID = ci.InventoryID AND ci.IsActive = 1 " +
                    "WHERE i.Status = 'Active' " +
                    "ORDER BY i.ItemName";
        
        try (Connection conn = getConn();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                InventoryDisplayItem item = new InventoryDisplayItem();
                item.inventoryID = rs.getInt("InventoryID");
                item.itemName = rs.getString("ItemName");
                item.quantity = rs.getDouble("Quantity");
                item.unit = rs.getString("Unit");
                item.lowThreshold = rs.getDouble("LowStockThreshold");
                item.criticalThreshold = rs.getDouble("CriticalThreshold");
                item.category = rs.getString("Category");
                item.priority = rs.getInt("Priority");
                
                // Set default thresholds if not found
                if (item.lowThreshold <= 0) item.lowThreshold = 15.0;
                if (item.criticalThreshold <= 0) item.criticalThreshold = 8.0;
                if (item.category == null) item.category = "OTHER";
                
                items.add(item);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        return items;
    }
    
    /**
     * Inner class for inventory display data
     */
    public static class InventoryDisplayItem {
        public int inventoryID;
        public String itemName;
        public double quantity;
        public String unit;
        public double lowThreshold;
        public double criticalThreshold;
        public String category;
        public int priority;
        
        public String getStatus() {
            if (quantity <= 0) return "critical";
            if (quantity <= criticalThreshold) return "critical";
            if (quantity <= lowThreshold) return "low";
            return "ok";
        }
        
        public int getPercentage() {
            if (lowThreshold <= 0) return 100;
            double maxForCalculation = Math.max(lowThreshold * 2, quantity * 1.2);
            return (int) Math.min(100, (quantity / maxForCalculation) * 100);
        }
        
        public String getVietnameseName() {
            switch (itemName.toLowerCase()) {
                case "dough": return "Bot lam banh";
                case "cheese": return "Pho mai Mozzarella";
                case "ham": return "Thit jambon";
                case "pineapple": return "Thom (dua)";
                case "ground coffee": return "Ca phe bot";
                case "condensed milk": return "Sua dac";
                case "sliced peach": return "Dao lat";
                case "dried tea": return "Tra kho";
                default: return itemName;
            }
        }
        
        public String getVietnameseCategory() {
            if (category == null) return "Khac";
            switch (category.toUpperCase()) {
                case "DOUGH": return "Nguyen lieu chinh";
                case "CHEESE": return "Nguyen lieu chinh";
                case "SAUCE": return "Nguyen lieu chinh";
                case "TOPPING": return "Topping";
                case "BEVERAGE": return "Do uong";
                default: return "Khac";
            }
        }
        
        public String getStatusText() {
            switch (getStatus()) {
                case "ok": return "Du hang";
                case "low": return "Sap het";
                case "critical": return "Can nhap gap";
                default: return "Khong xac dinh";
            }
        }
    }
}