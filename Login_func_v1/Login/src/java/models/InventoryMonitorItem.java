package models;

import java.math.BigDecimal;
import java.sql.Timestamp;

/**
 * Model class for Inventory Monitor items
 * Represents data from v_InventoryMonitor view
 */
public class InventoryMonitorItem {
    private int inventoryID;
    private String itemName;
    private BigDecimal quantity;
    private String unit;
    private String status;
    private BigDecimal lowThreshold;
    private BigDecimal criticalThreshold;
    private Timestamp lastUpdated;
    private String stockLevel;
    private BigDecimal percentOfLowLevel;
    
    // Default constructor
    public InventoryMonitorItem() {
    }
    
    // Full constructor
    public InventoryMonitorItem(int inventoryID, String itemName, BigDecimal quantity, 
                                String unit, String status, BigDecimal lowThreshold,
                                BigDecimal criticalThreshold, Timestamp lastUpdated, 
                                String stockLevel, BigDecimal percentOfLowLevel) {
        this.inventoryID = inventoryID;
        this.itemName = itemName;
        this.quantity = quantity;
        this.unit = unit;
        this.status = status;
        this.lowThreshold = lowThreshold;
        this.criticalThreshold = criticalThreshold;
        this.lastUpdated = lastUpdated;
        this.stockLevel = stockLevel;
        this.percentOfLowLevel = percentOfLowLevel;
    }
    
    // Getters and Setters
    public int getInventoryID() {
        return inventoryID;
    }

    public void setInventoryID(int inventoryID) {
        this.inventoryID = inventoryID;
    }

    public String getItemName() {
        return itemName;
    }

    public void setItemName(String itemName) {
        this.itemName = itemName;
    }

    public BigDecimal getQuantity() {
        return quantity;
    }

    public void setQuantity(BigDecimal quantity) {
        this.quantity = quantity;
    }

    public String getUnit() {
        return unit;
    }

    public void setUnit(String unit) {
        this.unit = unit;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public BigDecimal getLowThreshold() {
        return lowThreshold;
    }

    public void setLowThreshold(BigDecimal lowThreshold) {
        this.lowThreshold = lowThreshold;
    }

    public BigDecimal getCriticalThreshold() {
        return criticalThreshold;
    }

    public void setCriticalThreshold(BigDecimal criticalThreshold) {
        this.criticalThreshold = criticalThreshold;
    }

    public Timestamp getLastUpdated() {
        return lastUpdated;
    }

    public void setLastUpdated(Timestamp lastUpdated) {
        this.lastUpdated = lastUpdated;
    }

    public String getStockLevel() {
        return stockLevel;
    }

    public void setStockLevel(String stockLevel) {
        this.stockLevel = stockLevel;
    }

    public BigDecimal getPercentOfLowLevel() {
        return percentOfLowLevel;
    }

    public void setPercentOfLowLevel(BigDecimal percentOfLowLevel) {
        this.percentOfLowLevel = percentOfLowLevel;
    }
    
    // Utility methods
    
    /**
     * Get color hex code for warning level
     * @return Color hex code for the current stock level
     */
    public String getWarningLevelColor() {
        if (stockLevel == null) {
            return "#6B7280"; // Gray for unknown
        }
        
        switch (stockLevel.toUpperCase()) {
            case "CRITICAL":
                return "#DC2626"; // Red
            case "LOW":
                return "#F59E0B"; // Amber/Orange
            case "OK":
                return "#10B981"; // Green
            case "INACTIVE":
                return "#6B7280"; // Gray
            default:
                return "#6B7280"; // Gray for unknown
        }
    }
    
    /**
     * Get Lucide icon name for warning level
     * @return Icon name for the current stock level
     */
    public String getWarningLevelIcon() {
        if (stockLevel == null) {
            return "package";
        }
        
        switch (stockLevel.toUpperCase()) {
            case "CRITICAL":
                return "alert-triangle";
            case "LOW":
                return "alert-circle";
            case "OK":
                return "check-circle";
            case "INACTIVE":
                return "archive";
            default:
                return "package";
        }
    }
    
    /**
     * Check if item needs attention (CRITICAL or LOW)
     * @return true if item needs attention, false otherwise
     */
    public boolean needsAttention() {
        if (stockLevel == null) {
            return false;
        }
        
        String level = stockLevel.toUpperCase();
        return "CRITICAL".equals(level) || "LOW".equals(level);
    }
}
