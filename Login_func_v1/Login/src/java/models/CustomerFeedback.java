package models;

import java.sql.Date;
import java.sql.Time;
import java.sql.Timestamp;

public class CustomerFeedback {
    private int feedbackId;
    private String customerId;
    private String customerName;
    private int orderId;
    private Date orderDate;
    private Time orderTime;
    private int rating;
    private String comment;
    private Date feedbackDate;
    private String pizzaOrdered;
    private String response;
    private boolean hasResponse;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Default constructor
    public CustomerFeedback() {
    }

    // Full constructor
    public CustomerFeedback(int feedbackId, String customerId, String customerName, int orderId, 
                           Date orderDate, Time orderTime, int rating, String comment, 
                           Date feedbackDate, String pizzaOrdered, String response, 
                           boolean hasResponse, Timestamp createdAt, Timestamp updatedAt) {
        this.feedbackId = feedbackId;
        this.customerId = customerId;
        this.customerName = customerName;
        this.orderId = orderId;
        this.orderDate = orderDate;
        this.orderTime = orderTime;
        this.rating = rating;
        this.comment = comment;
        this.feedbackDate = feedbackDate;
        this.pizzaOrdered = pizzaOrdered;
        this.response = response;
        this.hasResponse = hasResponse;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    // Constructor without ID (for creating new feedback)
    public CustomerFeedback(String customerId, String customerName, int orderId, 
                           Date orderDate, Time orderTime, int rating, String comment, 
                           Date feedbackDate, String pizzaOrdered) {
        this.customerId = customerId;
        this.customerName = customerName;
        this.orderId = orderId;
        this.orderDate = orderDate;
        this.orderTime = orderTime;
        this.rating = rating;
        this.comment = comment;
        this.feedbackDate = feedbackDate;
        this.pizzaOrdered = pizzaOrdered;
        this.hasResponse = false;
    }

    // ===== GETTERS =====
    public int getFeedbackId() {
        return feedbackId;
    }

    public String getCustomerId() {
        return customerId;
    }

    public String getCustomerName() {
        return customerName;
    }

    public int getOrderId() {
        return orderId;
    }

    public Date getOrderDate() {
        return orderDate;
    }

    public Time getOrderTime() {
        return orderTime;
    }

    public int getRating() {
        return rating;
    }

    public String getComment() {
        return comment;
    }

    public Date getFeedbackDate() {
        return feedbackDate;
    }

    public String getPizzaOrdered() {
        return pizzaOrdered;
    }

    public String getResponse() {
        return response;
    }
public boolean isHasResponse() {
        return hasResponse;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    // ===== SETTERS =====
    public void setFeedbackId(int feedbackId) {
        this.feedbackId = feedbackId;
    }

    public void setCustomerId(String customerId) {
        this.customerId = customerId;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }

    public void setOrderId(int orderId) {
        this.orderId = orderId;
    }

    public void setOrderDate(Date orderDate) {
        this.orderDate = orderDate;
    }

    public void setOrderTime(Time orderTime) {
        this.orderTime = orderTime;
    }

    public void setRating(int rating) {
        this.rating = rating;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }

    public void setFeedbackDate(Date feedbackDate) {
        this.feedbackDate = feedbackDate;
    }

    public void setPizzaOrdered(String pizzaOrdered) {
        this.pizzaOrdered = pizzaOrdered;
    }

    public void setResponse(String response) {
        this.response = response;
    }

    public void setHasResponse(boolean hasResponse) {
        this.hasResponse = hasResponse;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }

    // ===== UTILITY METHODS =====
    
    /**
     * Get star rating as string for display (★★★★☆)
     */
    public String getStarRating() {
        StringBuilder stars = new StringBuilder();
        for (int i = 1; i <= 5; i++) {
            if (i <= rating) {
                stars.append("★");
            } else {
                stars.append("☆");
            }
        }
        return stars.toString();
    }

    /**
     * Get rating level as text
     */
    public String getRatingLevel() {
        switch (rating) {
            case 5: return "Xuất sắc";
            case 4: return "Tốt";
            case 3: return "Trung bình";
            case 2: return "Kém";
            case 1: return "Rất kém";
            default: return "Chưa đánh giá";
        }
    }

    /**
     * Get response status as text
     */
    public String getResponseStatus() {
        return hasResponse ? "Đã phản hồi" : "Chờ phản hồi";
    }

    /**
     * Check if feedback is positive (4-5 stars)
     */
    public boolean isPositive() {
        return rating >= 4;
    }

    /**
     * Check if feedback needs urgent attention (1-2 stars and no response)
     */
    public boolean needsUrgentAttention() {
        return rating <= 2 && !hasResponse;
    }

    // ===== toString =====
    @Override
    public String toString() {
        return "CustomerFeedback{" +
                "feedbackId=" + feedbackId +
", customerId='" + customerId + '\'' +
                ", customerName='" + customerName + '\'' +
                ", orderId=" + orderId +
                ", orderDate=" + orderDate +
                ", orderTime=" + orderTime +
                ", rating=" + rating +
                ", comment='" + comment + '\'' +
                ", feedbackDate=" + feedbackDate +
                ", pizzaOrdered='" + pizzaOrdered + '\'' +
                ", response='" + response + '\'' +
                ", hasResponse=" + hasResponse +
                ", createdAt=" + createdAt +
                ", updatedAt=" + updatedAt +
                '}';
    }
}


