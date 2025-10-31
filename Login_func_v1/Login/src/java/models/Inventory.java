package models;

import java.sql.Timestamp;

public class Inventory {

    private int inventoryID;
    private String itemName;
    private double quantity;
    private String unit;
    private Timestamp lastUpdated;

    public Inventory() {
    }

    public Inventory(int inventoryID, String itemName, double quantity, String unit, Timestamp lastUpdated) {
        this.inventoryID = inventoryID;
        this.itemName = itemName;
        this.quantity = quantity;
        this.unit = unit;
        this.lastUpdated = lastUpdated;
    }

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

    public double getQuantity() {
        return quantity;
    }

    public void setQuantity(double quantity) {
        this.quantity = quantity;
    }

    public String getUnit() {
        return unit;
    }

    public void setUnit(String unit) {
        this.unit = unit;
    }

    public Timestamp getLastUpdated() {
        return lastUpdated;
    }

    public void setLastUpdated(Timestamp lastUpdated) {
        this.lastUpdated = lastUpdated;
    }
}   
