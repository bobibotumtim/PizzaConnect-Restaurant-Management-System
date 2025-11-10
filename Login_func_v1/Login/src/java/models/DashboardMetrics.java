package models;

import java.sql.Timestamp;

/**
 * Model class for dashboard overview metrics
 * Contains key statistics for inventory monitoring dashboard
 */
public class DashboardMetrics {
    private int totalItems;
    private int lowStockItems;
    private int outOfStockItems;
    private int criticalItems;
    private double totalValue;
    private Timestamp lastUpdated;
    
    public DashboardMetrics() {}
    
    public DashboardMetrics(int totalItems, int lowStockItems, int outOfStockItems, 
                           int criticalItems, double totalValue, Timestamp lastUpdated) {
        this.totalItems = totalItems;
        this.lowStockItems = lowStockItems;
        this.outOfStockItems = outOfStockItems;
        this.criticalItems = criticalItems;
        this.totalValue = totalValue;
        this.lastUpdated = lastUpdated;
    }
    
    // Getters and Setters
    public int getTotalItems() { return totalItems; }
    public void setTotalItems(int totalItems) { this.totalItems = totalItems; }
    
    public int getLowStockItems() { return lowStockItems; }
    public void setLowStockItems(int lowStockItems) { this.lowStockItems = lowStockItems; }
    
    public int getOutOfStockItems() { return outOfStockItems; }
    public void setOutOfStockItems(int outOfStockItems) { this.outOfStockItems = outOfStockItems; }
    
    public int getCriticalItems() { return criticalItems; }
    public void setCriticalItems(int criticalItems) { this.criticalItems = criticalItems; }
    
    public double getTotalValue() { return totalValue; }
    public void setTotalValue(double totalValue) { this.totalValue = totalValue; }
    
    public Timestamp getLastUpdated() { return lastUpdated; }
    public void setLastUpdated(Timestamp lastUpdated) { this.lastUpdated = lastUpdated; }
    
    // Utility methods
    public double getLowStockPercentage() {
        return totalItems > 0 ? (double) lowStockItems / totalItems * 100 : 0;
    }
    
    public double getOutOfStockPercentage() {
        return totalItems > 0 ? (double) outOfStockItems / totalItems * 100 : 0;
    }
    
    public boolean hasAlerts() {
        return lowStockItems > 0 || outOfStockItems > 0;
    }
    
    @Override
    public String toString() {
        return "DashboardMetrics{" +
                "totalItems=" + totalItems +
                ", lowStockItems=" + lowStockItems +
                ", outOfStockItems=" + outOfStockItems +
                ", criticalItems=" + criticalItems +
                ", totalValue=" + totalValue +
                ", lastUpdated=" + lastUpdated +
                '}';
    }
}