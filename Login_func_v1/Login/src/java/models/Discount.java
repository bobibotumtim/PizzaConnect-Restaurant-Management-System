package models;

public class Discount {
    private int discountId;
    private String description;
    private String discountType;
    private double value;
    private Double maxDiscount;
    private double minOrderTotal;
    private String startDate;
    private String endDate;
    private boolean active;

    // Constructors
    public Discount() {
    }

    public Discount(int discountId, String description, String discountType, double value,
            Double maxDiscount, double minOrderTotal, String startDate,
            String endDate, boolean active) {
        this.discountId = discountId;
        this.description = description;
        this.discountType = discountType;
        this.value = value;
        this.maxDiscount = maxDiscount;
        this.minOrderTotal = minOrderTotal;
        this.startDate = startDate;
        this.endDate = endDate;
        this.active = active;
    }

    // Getters and Setters
    public int getDiscountId() {
        return discountId;
    }

    public void setDiscountId(int discountId) {
        this.discountId = discountId;
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

    public String getStartDate() {
        return startDate;
    }

    public void setStartDate(String startDate) {
        this.startDate = startDate;
    }

    public String getEndDate() {
        return endDate;
    }

    public void setEndDate(String endDate) {
        this.endDate = endDate;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }
}