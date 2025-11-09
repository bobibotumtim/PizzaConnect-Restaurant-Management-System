package models;

public class OrderDetailTopping {
    private int orderDetailToppingID;
    private int orderDetailID;
    private int productSizeID;  // Schema mới: ProductSizeID thay vì ToppingID
    private double productPrice; // Schema mới: ProductPrice thay vì ToppingPrice
    
    // For display purposes
    private String toppingName;
    private String sizeName;

    // Constructors
    public OrderDetailTopping() {
    }

    public OrderDetailTopping(int orderDetailID, int productSizeID, double productPrice) {
        this.orderDetailID = orderDetailID;
        this.productSizeID = productSizeID;
        this.productPrice = productPrice;
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

    public int getProductSizeID() {
        return productSizeID;
    }

    public void setProductSizeID(int productSizeID) {
        this.productSizeID = productSizeID;
    }

    public double getProductPrice() {
        return productPrice;
    }

    public void setProductPrice(double productPrice) {
        this.productPrice = productPrice;
    }

    public String getToppingName() {
        return toppingName;
    }

    public void setToppingName(String toppingName) {
        this.toppingName = toppingName;
    }

    public String getSizeName() {
        return sizeName;
    }

    public void setSizeName(String sizeName) {
        this.sizeName = sizeName;
    }

    // Backward compatibility - deprecated methods
    @Deprecated
    public int getToppingID() {
        return productSizeID;
    }

    @Deprecated
    public void setToppingID(int toppingID) {
        this.productSizeID = toppingID;
    }

    @Deprecated
    public double getToppingPrice() {
        return productPrice;
    }

    @Deprecated
    public void setToppingPrice(double toppingPrice) {
        this.productPrice = toppingPrice;
    }

    @Override
    public String toString() {
        return "OrderDetailTopping{" +
                "orderDetailToppingID=" + orderDetailToppingID +
                ", orderDetailID=" + orderDetailID +
                ", productSizeID=" + productSizeID +
                ", productPrice=" + productPrice +
                ", toppingName='" + toppingName + '\'' +
                ", sizeName='" + sizeName + '\'' +
                '}';
    }
}
