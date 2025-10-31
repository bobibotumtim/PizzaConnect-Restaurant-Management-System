package models;

public class OrderDiscount {
    private int orderId;
    private int discountId;
    private double amount;
    private String appliedDate;

    // Constructors
    public OrderDiscount() {
    }

    public OrderDiscount(int orderId, int discountId, double amount, String appliedDate) {
        this.orderId = orderId;
        this.discountId = discountId;
        this.amount = amount;
        this.appliedDate = appliedDate;
    }

    // Getters and Setters
    public int getOrderId() {
        return orderId;
    }

    public void setOrderId(int orderId) {
        this.orderId = orderId;
    }

    public int getDiscountId() {
        return discountId;
    }

    public void setDiscountId(int discountId) {
        this.discountId = discountId;
    }

    public double getAmount() {
        return amount;
    }

    public void setAmount(double amount) {
        this.amount = amount;
    }

    public String getAppliedDate() {
        return appliedDate;
    }

    public void setAppliedDate(String appliedDate) {
        this.appliedDate = appliedDate;
    }
}