package models;

import java.sql.Timestamp;

/**
 * Model class for inventory alert items
 * Represents items that require attention due to low stock or other issues
 */
public class AlertItem {
    public enum AlertType {
        LOW_STOCK("Low Stock"),
        OUT_OF_STOCK("Out of Stock"),
        CRITICAL_LOW("Critical Low"),
        EXPIRING_SOON("Expiring Soon");
        
        private final String displayName;
        
        AlertType(String displayName) {
            this.displayName = displayName;
        }
        
        public String getDisplayName() {
            return displayName;
        }
    }
    
    public enum Priority {
        HIGH(1, "High"),
        MEDIUM(2, "Medium"),
        LOW(3, "Low");
        
        private final int level;
        private final String displayName;
        
        Priority(int level, String displayName) {
            this.level = level;
            this.displayName = displayName;
        }
        
        public int getLevel() { return level; }
        public String getDisplayName() { return displayName; }
    }
    
    private int inventoryID;
    private String itemName;
    private double currentQuantity;
    private double threshold;
    private String unit;
    private AlertType alertType;
    private Priority priority;
    private String message;
    private boolean acknowledged;
    private Timestamp alertDate;
    private Timestamp acknowledgedDate;
    
    public AlertItem() {}
    
    public AlertItem(int inventoryID, String itemName, double currentQuantity, 
                    double threshold, String unit, AlertType alertType, Priority priority) {
        this.inventoryID = inventoryID;
        this.itemName = itemName;
        this.currentQuantity = currentQuantity;
        this.threshold = threshold;
        this.unit = unit;
        this.alertType = alertType;
        this.priority = priority;
        this.acknowledged = false;
        this.alertDate = new Timestamp(System.currentTimeMillis());
        this.message = generateMessage();
    }
    
    // Getters and Setters
    public int getInventoryID() { return inventoryID; }
    public void setInventoryID(int inventoryID) { this.inventoryID = inventoryID; }
    
    public String getItemName() { return itemName; }
    public void setItemName(String itemName) { this.itemName = itemName; }
    
    public double getCurrentQuantity() { return currentQuantity; }
    public void setCurrentQuantity(double currentQuantity) { this.currentQuantity = currentQuantity; }
    
    public double getThreshold() { return threshold; }
    public void setThreshold(double threshold) { this.threshold = threshold; }
    
    public String getUnit() { return unit; }
    public void setUnit(String unit) { this.unit = unit; }
    
    public AlertType getAlertType() { return alertType; }
    public void setAlertType(AlertType alertType) { 
        this.alertType = alertType;
        this.message = generateMessage();
    }
    
    public Priority getPriority() { return priority; }
    public void setPriority(Priority priority) { this.priority = priority; }
    
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
    
    public boolean isAcknowledged() { return acknowledged; }
    public void setAcknowledged(boolean acknowledged) { 
        this.acknowledged = acknowledged;
        if (acknowledged && acknowledgedDate == null) {
            this.acknowledgedDate = new Timestamp(System.currentTimeMillis());
        }
    }
    
    public Timestamp getAlertDate() { return alertDate; }
    public void setAlertDate(Timestamp alertDate) { this.alertDate = alertDate; }
    
    public Timestamp getAcknowledgedDate() { return acknowledgedDate; }
    public void setAcknowledgedDate(Timestamp acknowledgedDate) { this.acknowledgedDate = acknowledgedDate; }
    
    // Utility methods
    private String generateMessage() {
        if (alertType == null) return "";
        
        switch (alertType) {
            case OUT_OF_STOCK:
                return itemName + " is out of stock. Immediate restocking required.";
            case CRITICAL_LOW:
                return itemName + " is critically low (" + currentQuantity + " " + unit + 
                       "). Below critical threshold of " + threshold + " " + unit + ".";
            case LOW_STOCK:
                return itemName + " is running low (" + currentQuantity + " " + unit + 
                       "). Below threshold of " + threshold + " " + unit + ".";
            case EXPIRING_SOON:
                return itemName + " is expiring soon. Check expiration dates.";
            default:
                return itemName + " requires attention.";
        }
    }
    
    public String getAlertTypeClass() {
        switch (alertType) {
            case OUT_OF_STOCK:
            case CRITICAL_LOW:
                return "alert-danger";
            case LOW_STOCK:
                return "alert-warning";
            case EXPIRING_SOON:
                return "alert-info";
            default:
                return "alert-secondary";
        }
    }
    
    public String getPriorityClass() {
        switch (priority) {
            case HIGH:
                return "priority-high";
            case MEDIUM:
                return "priority-medium";
            case LOW:
                return "priority-low";
            default:
                return "priority-medium";
        }
    }
    
    @Override
    public String toString() {
        return "AlertItem{" +
                "inventoryID=" + inventoryID +
                ", itemName='" + itemName + '\'' +
                ", currentQuantity=" + currentQuantity +
                ", threshold=" + threshold +
                ", unit='" + unit + '\'' +
                ", alertType=" + alertType +
                ", priority=" + priority +
                ", acknowledged=" + acknowledged +
                ", alertDate=" + alertDate +
                '}';
    }
}