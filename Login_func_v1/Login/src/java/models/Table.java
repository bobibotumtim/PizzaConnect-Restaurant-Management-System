package models;

import java.io.Serializable;

public class Table implements Serializable {
    private int tableID;
    private String tableNumber;
    private int capacity;
    private String status;
    private boolean isActive;
    private boolean isLocked;
    private String lockedReason;
    private Integer lockedBy;
    private java.sql.Timestamp lockedAt;

    public Table() {
    }

    public Table(int tableID, String tableNumber, int capacity, String status, boolean isActive) {
        this.tableID = tableID;
        this.tableNumber = tableNumber;
        this.capacity = capacity;
        this.status = status;
        this.isActive = isActive;
    }
    
    public Table(int tableID, String tableNumber, int capacity, String status, boolean isActive, 
                 boolean isLocked, String lockedReason, Integer lockedBy, java.sql.Timestamp lockedAt) {
        this.tableID = tableID;
        this.tableNumber = tableNumber;
        this.capacity = capacity;
        this.status = status;
        this.isActive = isActive;
        this.isLocked = isLocked;
        this.lockedReason = lockedReason;
        this.lockedBy = lockedBy;
        this.lockedAt = lockedAt;
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

    public boolean isLocked() {
        return isLocked;
    }

    public void setLocked(boolean locked) {
        isLocked = locked;
    }

    public String getLockedReason() {
        return lockedReason;
    }

    public void setLockedReason(String lockedReason) {
        this.lockedReason = lockedReason;
    }

    public Integer getLockedBy() {
        return lockedBy;
    }

    public void setLockedBy(Integer lockedBy) {
        this.lockedBy = lockedBy;
    }

    public java.sql.Timestamp getLockedAt() {
        return lockedAt;
    }

    public void setLockedAt(java.sql.Timestamp lockedAt) {
        this.lockedAt = lockedAt;
    }
}