package models;

import java.io.Serializable;

public class Table implements Serializable {
    private int tableID;
    private String tableNumber;
    private int capacity;
    private String status;
    private boolean isActive;

    public Table() {
    }

    public Table(int tableID, String tableNumber, int capacity, String status, boolean isActive) {
        this.tableID = tableID;
        this.tableNumber = tableNumber;
        this.capacity = capacity;
        this.status = status;
        this.isActive = isActive;
    }

    // Getters and Setters
    public int getTableID() {
        return tableID;
    }

    public void setTableID(int tableID) {
        this.tableID = tableID;
    }

    public String getTableNumber() {
        return tableNumber;
    }

    public void setTableNumber(String tableNumber) {
        this.tableNumber = tableNumber;
    }

    public int getCapacity() {
        return capacity;
    }

    public void setCapacity(int capacity) {
        this.capacity = capacity;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public boolean isActive() {
        return isActive;
    }

    public void setActive(boolean active) {
        isActive = active;
    }
}