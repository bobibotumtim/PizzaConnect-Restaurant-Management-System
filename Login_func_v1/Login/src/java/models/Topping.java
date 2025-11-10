package models;

import java.sql.Timestamp;

/**
 * Topping model - Now backed by Product + ProductSize (CategoryID = 3)
 * toppingID actually stores ProductSizeID from database
 */
public class Topping {
    private int toppingID; // Actually ProductSizeID after migration
    private String toppingName;
    private double price;
    private boolean isAvailable;
    private Timestamp createdDate;

    // Constructors
    public Topping() {
    }

    public Topping(int toppingID, String toppingName, double price, boolean isAvailable) {
        this.toppingID = toppingID;
        this.toppingName = toppingName;
        this.price = price;
        this.isAvailable = isAvailable;
    }

    // Getters and Setters
    public int getToppingID() {
        return toppingID;
    }

    public void setToppingID(int toppingID) {
        this.toppingID = toppingID;
    }

    public String getToppingName() {
        return toppingName;
    }

    public void setToppingName(String toppingName) {
        this.toppingName = toppingName;
    }

    public double getPrice() {
        return price;
    }

    public void setPrice(double price) {
        this.price = price;
    }

    public boolean isAvailable() {
        return isAvailable;
    }

    public void setAvailable(boolean available) {
        isAvailable = available;
    }

    public Timestamp getCreatedDate() {
        return createdDate;
    }

    public void setCreatedDate(Timestamp createdDate) {
        this.createdDate = createdDate;
    }

    @Override
    public String toString() {
        return "Topping{" +
                "toppingID=" + toppingID +
                ", toppingName='" + toppingName + '\'' +
                ", price=" + price +
                ", isAvailable=" + isAvailable +
                '}';
    }
}
