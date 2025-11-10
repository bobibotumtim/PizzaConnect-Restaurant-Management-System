package models;

/**
 * OrderDetailTopping model - Now uses ProductSizeID instead of ToppingID
 * toppingID field actually stores ProductSizeID from database
 */
public class OrderDetailTopping {
    private int orderDetailToppingID;
    private int orderDetailID;
    private int toppingID; // Actually ProductSizeID after migration
    private double toppingPrice;
    
    // For display purposes
    private String toppingName;

    // Constructors
    public OrderDetailTopping() {
    }

    public OrderDetailTopping(int orderDetailID, int toppingID, double toppingPrice) {
        this.orderDetailID = orderDetailID;
        this.toppingID = toppingID;
        this.toppingPrice = toppingPrice;
    }

    // Getters and Setters
    public int getOrderDetailToppingID() {
        return orderDetailToppingID;
    }

    public void setOrderDetailToppingID(int orderDetailToppingID) {
        this.orderDetailToppingID = orderDetailToppingID;
    }

    public int getOrderDetailID() {
        return orderDetailID;
    }

    public void setOrderDetailID(int orderDetailID) {
        this.orderDetailID = orderDetailID;
    }

    public int getToppingID() {
        return toppingID;
    }

    public void setToppingID(int toppingID) {
        this.toppingID = toppingID;
    }

    public double getToppingPrice() {
        return toppingPrice;
    }

    public void setToppingPrice(double toppingPrice) {
        this.toppingPrice = toppingPrice;
    }

    public String getToppingName() {
        return toppingName;
    }

    public void setToppingName(String toppingName) {
        this.toppingName = toppingName;
    }

    @Override
    public String toString() {
        return "OrderDetailTopping{" +
                "orderDetailToppingID=" + orderDetailToppingID +
                ", orderDetailID=" + orderDetailID +
                ", toppingID=" + toppingID +
                ", toppingPrice=" + toppingPrice +
                ", toppingName='" + toppingName + '\'' +
                '}';
    }
}
