package models;

import java.sql.Timestamp;

/**
 * Model class for critical item status monitoring
 * Represents the status of critical pizza ingredients and their monitoring data
 */
public class CriticalItemStatus {
    public enum CriticalCategory {
        DOUGH("Dough", "Essential for pizza base"),
        CHEESE("Cheese", "Primary pizza topping"),
        SAUCE("Sauce", "Pizza sauce and bases"),
        TOPPING("Topping", "Meat and vegetable toppings"),
        BEVERAGE("Beverage", "Drinks and beverages"),
        OTHER("Other", "Other ingredients");
        
        private final String displayName;
        private final String description;
        
        CriticalCategory(String displayName, String description) {
            this.displayName = displayName;
            this.description = description;
        }
        
        public String getDisplayName() { return displayName; }
        public String getDescription() { return description; }
    }
    
    public enum StatusLevel {
        CRITICAL(1, "Critical", "Immediate action required"),
        WARNING(2, "Warning", "Attention needed"),
        NORMAL(3, "Normal", "Stock levels adequate"),
        GOOD(4, "Good", "Stock levels healthy");
        
        private final int level;
        private final String displayName;
        private final String description;
        
        StatusLevel(int level, String displayName, String description) {
            this.level = level;
            this.displayName = displayName;
            this.description = description;
        }
        
        public int getLevel() { return level; }
        public String getDisplayName() { return displayName; }
        public String getDescription() { return description; }
    }
    
    private int inventoryID;
    private String itemName;
    private double currentQuantity;
    private double lowThreshold;
    private double criticalThreshold;
    private String unit;
    private CriticalCategory category;
    private int priority; // 1=High, 2=Medium, 3=Low
    private StatusLevel statusLevel;
    private double usageRate;
    private int daysUntilCritical;
    private boolean requiresAction;
    private String actionMessage;
    private Timestamp lastUpdated;
    private Timestamp lastRestocked;
    
    public CriticalItemStatus() {}
    
    public CriticalItemStatus(int inventoryID, String itemName, double currentQuantity,
                             double lowThreshold, double criticalThreshold, String unit,
                             CriticalCategory category, int priority) {
        this.inventoryID = inventoryID;
        this.itemName = itemName;
        this.currentQuantity = currentQuantity;
        this.lowThreshold = lowThreshold;
        this.criticalThreshold = criticalThreshold;
        this.unit = unit;
        this.category = category;
        this.priority = priority;
        this.lastUpdated = new Timestamp(System.currentTimeMillis());
        calculateStatus();
    }
    
    // Getters and Setters
    public int getInventoryID() { return inventoryID; }
    public void setInventoryID(int inventoryID) { this.inventoryID = inventoryID; }
    
    public String getItemName() { return itemName; }
    public void setItemName(String itemName) { this.itemName = itemName; }
    
    public double getCurrentQuantity() { return currentQuantity; }
    public void setCurrentQuantity(double currentQuantity) { 
        this.currentQuantity = currentQuantity;
        calculateStatus();
    }
    
    public double getLowThreshold() { return lowThreshold; }
    public void setLowThreshold(double lowThreshold) { this.lowThreshold = lowThreshold; }
    
    public double getCriticalThreshold() { return criticalThreshold; }
    public void setCriticalThreshold(double criticalThreshold) { this.criticalThreshold = criticalThreshold; }
    
    public String getUnit() { return unit; }
    public void setUnit(String unit) { this.unit = unit; }
    
    public CriticalCategory getCategory() { return category; }
    public void setCategory(CriticalCategory category) { this.category = category; }
    
    public int getPriority() { return priority; }
    public void setPriority(int priority) { this.priority = priority; }
    
    public StatusLevel getStatusLevel() { return statusLevel; }
    public void setStatusLevel(StatusLevel statusLevel) { this.statusLevel = statusLevel; }
    
    public double getUsageRate() { return usageRate; }
    public void setUsageRate(double usageRate) { 
        this.usageRate = usageRate;
        calculateDaysUntilCritical();
    }
    
    public int getDaysUntilCritical() { return daysUntilCritical; }
    public void setDaysUntilCritical(int daysUntilCritical) { this.daysUntilCritical = daysUntilCritical; }
    
    public boolean isRequiresAction() { return requiresAction; }
    public void setRequiresAction(boolean requiresAction) { this.requiresAction = requiresAction; }
    
    public String getActionMessage() { return actionMessage; }
    public void setActionMessage(String actionMessage) { this.actionMessage = actionMessage; }
    
    public Timestamp getLastUpdated() { return lastUpdated; }
    public void setLastUpdated(Timestamp lastUpdated) { this.lastUpdated = lastUpdated; }
    
    public Timestamp getLastRestocked() { return lastRestocked; }
    public void setLastRestocked(Timestamp lastRestocked) { this.lastRestocked = lastRestocked; }
    
    // Utility methods
    private void calculateStatus() {
        if (currentQuantity <= 0) {
            this.statusLevel = StatusLevel.CRITICAL;
            this.requiresAction = true;
            this.actionMessage = "OUT OF STOCK - Immediate restocking required for " + itemName;
        } else if (currentQuantity <= criticalThreshold) {
            this.statusLevel = StatusLevel.CRITICAL;
            this.requiresAction = true;
            this.actionMessage = "CRITICAL LOW - " + itemName + " below critical threshold (" + 
                               currentQuantity + " " + unit + " remaining)";
        } else if (currentQuantity <= lowThreshold) {
            this.statusLevel = StatusLevel.WARNING;
            this.requiresAction = true;
            this.actionMessage = "LOW STOCK - " + itemName + " needs restocking soon (" + 
                               currentQuantity + " " + unit + " remaining)";
        } else if (currentQuantity <= lowThreshold * 1.5) {
            this.statusLevel = StatusLevel.NORMAL;
            this.requiresAction = false;
            this.actionMessage = itemName + " stock levels are adequate";
        } else {
            this.statusLevel = StatusLevel.GOOD;
            this.requiresAction = false;
            this.actionMessage = itemName + " stock levels are healthy";
        }
    }
    
    private void calculateDaysUntilCritical() {
        if (usageRate > 0 && currentQuantity > criticalThreshold) {
            double quantityUntilCritical = currentQuantity - criticalThreshold;
            this.daysUntilCritical = (int) Math.ceil(quantityUntilCritical / usageRate);
        } else {
            this.daysUntilCritical = currentQuantity <= criticalThreshold ? 0 : -1;
        }
    }
    
    public String getStatusClass() {
        switch (statusLevel) {
            case CRITICAL:
                return "status-critical bg-danger text-white";
            case WARNING:
                return "status-warning bg-warning text-dark";
            case NORMAL:
                return "status-normal bg-info text-white";
            case GOOD:
                return "status-good bg-success text-white";
            default:
                return "status-unknown bg-secondary text-white";
        }
    }
    
    public String getPriorityClass() {
        switch (priority) {
            case 1:
                return "priority-high border-danger";
            case 2:
                return "priority-medium border-warning";
            case 3:
                return "priority-low border-info";
            default:
                return "priority-normal border-secondary";
        }
    }
    
    public String getCategoryIcon() {
        switch (category) {
            case DOUGH:
                return "fas fa-bread-slice";
            case CHEESE:
                return "fas fa-cheese";
            case SAUCE:
                return "fas fa-bottle-droplet";
            case TOPPING:
                return "fas fa-pizza-slice";
            case BEVERAGE:
                return "fas fa-coffee";
            case OTHER:
            default:
                return "fas fa-box";
        }
    }
    
    public double getStockPercentage() {
        if (lowThreshold <= 0) return 100;
        return Math.min(100, (currentQuantity / lowThreshold) * 100);
    }
    
    public boolean isHighPriority() {
        return priority == 1;
    }
    
    public boolean isCriticalCategory() {
        return category == CriticalCategory.DOUGH || 
               category == CriticalCategory.CHEESE || 
               category == CriticalCategory.SAUCE;
    }
    
    @Override
    public String toString() {
        return "CriticalItemStatus{" +
                "inventoryID=" + inventoryID +
                ", itemName='" + itemName + '\'' +
                ", currentQuantity=" + currentQuantity +
                ", category=" + category +
                ", statusLevel=" + statusLevel +
                ", priority=" + priority +
                ", requiresAction=" + requiresAction +
                '}';
    }
}