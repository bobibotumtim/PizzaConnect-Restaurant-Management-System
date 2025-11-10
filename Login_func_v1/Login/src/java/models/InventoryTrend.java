package models;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

/**
 * Model class for inventory trend analysis
 * Contains historical data and trend calculations for inventory items
 */
public class InventoryTrend {
    public static class TrendPoint {
        private Timestamp date;
        private double quantity;
        private String changeType;
        
        public TrendPoint() {}
        
        public TrendPoint(Timestamp date, double quantity, String changeType) {
            this.date = date;
            this.quantity = quantity;
            this.changeType = changeType;
        }
        
        // Getters and Setters
        public Timestamp getDate() { return date; }
        public void setDate(Timestamp date) { this.date = date; }
        
        public double getQuantity() { return quantity; }
        public void setQuantity(double quantity) { this.quantity = quantity; }
        
        public String getChangeType() { return changeType; }
        public void setChangeType(String changeType) { this.changeType = changeType; }
    }
    
    public enum TrendDirection {
        INCREASING("Increasing"),
        DECREASING("Decreasing"),
        STABLE("Stable"),
        VOLATILE("Volatile");
        
        private final String displayName;
        
        TrendDirection(String displayName) {
            this.displayName = displayName;
        }
        
        public String getDisplayName() { return displayName; }
    }
    
    private int inventoryID;
    private String itemName;
    private String unit;
    private List<TrendPoint> trendData;
    private double currentQuantity;
    private double averageConsumption;
    private double dailyUsageRate;
    private TrendDirection trendDirection;
    private int daysUntilEmpty;
    private double forecastAccuracy;
    private Timestamp analysisDate;
    
    public InventoryTrend() {
        this.trendData = new ArrayList<>();
    }
    
    public InventoryTrend(int inventoryID, String itemName, String unit) {
        this.inventoryID = inventoryID;
        this.itemName = itemName;
        this.unit = unit;
        this.trendData = new ArrayList<>();
        this.analysisDate = new Timestamp(System.currentTimeMillis());
    }
    
    // Getters and Setters
    public int getInventoryID() { return inventoryID; }
    public void setInventoryID(int inventoryID) { this.inventoryID = inventoryID; }
    
    public String getItemName() { return itemName; }
    public void setItemName(String itemName) { this.itemName = itemName; }
    
    public String getUnit() { return unit; }
    public void setUnit(String unit) { this.unit = unit; }
    
    public List<TrendPoint> getTrendData() { return trendData; }
    public void setTrendData(List<TrendPoint> trendData) { this.trendData = trendData; }
    
    public double getCurrentQuantity() { return currentQuantity; }
    public void setCurrentQuantity(double currentQuantity) { this.currentQuantity = currentQuantity; }
    
    public double getAverageConsumption() { return averageConsumption; }
    public void setAverageConsumption(double averageConsumption) { this.averageConsumption = averageConsumption; }
    
    public double getDailyUsageRate() { return dailyUsageRate; }
    public void setDailyUsageRate(double dailyUsageRate) { this.dailyUsageRate = dailyUsageRate; }
    
    public TrendDirection getTrendDirection() { return trendDirection; }
    public void setTrendDirection(TrendDirection trendDirection) { this.trendDirection = trendDirection; }
    
    public int getDaysUntilEmpty() { return daysUntilEmpty; }
    public void setDaysUntilEmpty(int daysUntilEmpty) { this.daysUntilEmpty = daysUntilEmpty; }
    
    public double getForecastAccuracy() { return forecastAccuracy; }
    public void setForecastAccuracy(double forecastAccuracy) { this.forecastAccuracy = forecastAccuracy; }
    
    public Timestamp getAnalysisDate() { return analysisDate; }
    public void setAnalysisDate(Timestamp analysisDate) { this.analysisDate = analysisDate; }
    
    // Utility methods
    public void addTrendPoint(Timestamp date, double quantity, String changeType) {
        trendData.add(new TrendPoint(date, quantity, changeType));
    }
    
    public void calculateTrendMetrics() {
        if (trendData.isEmpty()) {
            this.averageConsumption = 0;
            this.dailyUsageRate = 0;
            this.trendDirection = TrendDirection.STABLE;
            this.daysUntilEmpty = -1;
            return;
        }
        
        // Calculate average consumption
        double totalConsumption = 0;
        int consumptionPoints = 0;
        
        for (int i = 1; i < trendData.size(); i++) {
            TrendPoint current = trendData.get(i);
            TrendPoint previous = trendData.get(i - 1);
            
            if ("USAGE".equals(current.getChangeType())) {
                double consumption = previous.getQuantity() - current.getQuantity();
                if (consumption > 0) {
                    totalConsumption += consumption;
                    consumptionPoints++;
                }
            }
        }
        
        this.averageConsumption = consumptionPoints > 0 ? totalConsumption / consumptionPoints : 0;
        
        // Calculate daily usage rate (assuming data points are daily)
        this.dailyUsageRate = this.averageConsumption;
        
        // Determine trend direction
        if (trendData.size() >= 3) {
            double firstHalf = 0, secondHalf = 0;
            int midPoint = trendData.size() / 2;
            
            for (int i = 0; i < midPoint; i++) {
                firstHalf += trendData.get(i).getQuantity();
            }
            for (int i = midPoint; i < trendData.size(); i++) {
                secondHalf += trendData.get(i).getQuantity();
            }
            
            firstHalf /= midPoint;
            secondHalf /= (trendData.size() - midPoint);
            
            double change = ((secondHalf - firstHalf) / firstHalf) * 100;
            
            if (Math.abs(change) < 5) {
                this.trendDirection = TrendDirection.STABLE;
            } else if (change > 0) {
                this.trendDirection = TrendDirection.INCREASING;
            } else {
                this.trendDirection = TrendDirection.DECREASING;
            }
        }
        
        // Calculate days until empty
        if (dailyUsageRate > 0 && currentQuantity > 0) {
            this.daysUntilEmpty = (int) Math.ceil(currentQuantity / dailyUsageRate);
        } else {
            this.daysUntilEmpty = -1; // Unknown or infinite
        }
        
        // Set forecast accuracy (simplified calculation)
        this.forecastAccuracy = trendData.size() >= 7 ? 85.0 : 60.0;
    }
    
    public String getTrendDirectionClass() {
        switch (trendDirection) {
            case INCREASING:
                return "trend-up text-success";
            case DECREASING:
                return "trend-down text-danger";
            case STABLE:
                return "trend-stable text-info";
            case VOLATILE:
                return "trend-volatile text-warning";
            default:
                return "trend-unknown text-muted";
        }
    }
    
    public String getStockStatusClass() {
        if (daysUntilEmpty <= 3) {
            return "text-danger";
        } else if (daysUntilEmpty <= 7) {
            return "text-warning";
        } else {
            return "text-success";
        }
    }
    
    @Override
    public String toString() {
        return "InventoryTrend{" +
                "inventoryID=" + inventoryID +
                ", itemName='" + itemName + '\'' +
                ", currentQuantity=" + currentQuantity +
                ", averageConsumption=" + averageConsumption +
                ", dailyUsageRate=" + dailyUsageRate +
                ", trendDirection=" + trendDirection +
                ", daysUntilEmpty=" + daysUntilEmpty +
                ", dataPoints=" + trendData.size() +
                '}';
    }
}