package models;

import java.util.Date;

public class CustomerDiscount {
    private int customerDiscountId;
    private int customerId;
    private int discountId;
    private int quantity;
    private Date expiryDate;
    private boolean isUsed;
    private Date lastEarnedDate;
    private Date usedDate;

    // Additional fields for display
    private String description;
    private String discountType;
    private double value;
    private Double maxDiscount;
    private double minOrderTotal;

    // Constructors
    public CustomerDiscount() {
    }

    public CustomerDiscount(int customerDiscountId, int customerId, int discountId, int quantity,
            Date expiryDate, boolean isUsed, Date lastEarnedDate, Date usedDate) {
        this.customerDiscountId = customerDiscountId;
        this.customerId = customerId;
        this.discountId = discountId;
        this.quantity = quantity;
        this.expiryDate = expiryDate;
        this.isUsed = isUsed;
        this.lastEarnedDate = lastEarnedDate;
        this.usedDate = usedDate;
    }

    // Getters and Setters
    public int getCustomerDiscountId() {
        return customerDiscountId;
    }

    public void setCustomerDiscountId(int customerDiscountId) {
        this.customerDiscountId = customerDiscountId;
    }

    public int getCustomerId() {
        return customerId;
    }

    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }

    public int getDiscountId() {
        return discountId;
    }

    public void setDiscountId(int discountId) {
        this.discountId = discountId;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public Date getExpiryDate() {
        return expiryDate;
    }

    public void setExpiryDate(Date expiryDate) {
        this.expiryDate = expiryDate;
    }

    public boolean isUsed() {
        return isUsed;
    }

    public void setUsed(boolean used) {
        isUsed = used;
    }

    public Date getLastEarnedDate() {
        return lastEarnedDate;
    }

    public void setLastEarnedDate(Date lastEarnedDate) {
        this.lastEarnedDate = lastEarnedDate;
    }

    public Date getUsedDate() {
        return usedDate;
    }

    public void setUsedDate(Date usedDate) {
        this.usedDate = usedDate;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getDiscountType() {
        return discountType;
    }

    public void setDiscountType(String discountType) {
        this.discountType = discountType;
    }

    public double getValue() {
        return value;
    }

    public void setValue(double value) {
        this.value = value;
    }

    public Double getMaxDiscount() {
        return maxDiscount;
    }

    public void setMaxDiscount(Double maxDiscount) {
        this.maxDiscount = maxDiscount;
    }

    public double getMinOrderTotal() {
        return minOrderTotal;
    }

    public void setMinOrderTotal(double minOrderTotal) {
        this.minOrderTotal = minOrderTotal;
    }
}