package models;

import java.util.Date;

public class Feedback {
    private int feedbackId;
    private int customerId;
    private int orderId;
    private int productId;
    private int rating;
    private Date feedbackDate;
    private String comment;

    // Constructors
    public Feedback() {
    }

    public Feedback(int feedbackId, int customerId, int orderId, int productId, int rating, Date feedbackDate,
            String comment) {
        this.feedbackId = feedbackId;
        this.customerId = customerId;
        this.orderId = orderId;
        this.productId = productId;
        this.rating = rating;
        this.feedbackDate = feedbackDate;
        this.comment = comment;
    }

    // Getters and Setters
    public int getFeedbackId() {
        return feedbackId;
    }

    public void setFeedbackId(int feedbackId) {
        this.feedbackId = feedbackId;
    }

    public int getCustomerId() {
        return customerId;
    }

    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }

    public int getOrderId() {
        return orderId;
    }

    public void setOrderId(int orderId) {
        this.orderId = orderId;
    }

    public int getProductId() {
        return productId;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    public int getRating() {
        return rating;
    }

    public void setRating(int rating) {
        this.rating = rating;
    }

    public Date getFeedbackDate() {
        return feedbackDate;
    }

    public void setFeedbackDate(Date feedbackDate) {
        this.feedbackDate = feedbackDate;
    }

    public String getComment() {
        return comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }
}