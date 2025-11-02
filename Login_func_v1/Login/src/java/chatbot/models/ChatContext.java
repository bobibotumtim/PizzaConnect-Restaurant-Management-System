package chatbot.models;

import models.User;
import models.Customer;
import models.Order;
import models.Product;
import java.util.List;
import java.util.ArrayList;

/**
 * Context object that holds conversation state and user information
 */
public class ChatContext {
    
    private String sessionId;
    private User user;
    private Customer customer;
    private String language;
    private List<ChatMessage> messageHistory;
    private List<Order> recentOrders;
    private List<Product> availableProducts;
    
    public ChatContext() {
        this.messageHistory = new ArrayList<>();
        this.recentOrders = new ArrayList<>();
        this.availableProducts = new ArrayList<>();
        this.language = "vi"; // Default to Vietnamese
    }
    
    public ChatContext(String sessionId) {
        this();
        this.sessionId = sessionId;
    }
    
    // Getters and Setters
    
    public String getSessionId() {
        return sessionId;
    }
    
    public void setSessionId(String sessionId) {
        this.sessionId = sessionId;
    }
    
    public User getUser() {
        return user;
    }
    
    public void setUser(User user) {
        this.user = user;
    }
    
    public Customer getCustomer() {
        return customer;
    }
    
    public void setCustomer(Customer customer) {
        this.customer = customer;
    }
    
    public String getLanguage() {
        return language;
    }
    
    public void setLanguage(String language) {
        this.language = language;
    }
    
    public List<ChatMessage> getMessageHistory() {
        return messageHistory;
    }
    
    public void setMessageHistory(List<ChatMessage> messageHistory) {
        this.messageHistory = messageHistory;
    }
    
    public void addMessage(ChatMessage message) {
        this.messageHistory.add(message);
    }
    
    public List<Order> getRecentOrders() {
        return recentOrders;
    }
    
    public void setRecentOrders(List<Order> recentOrders) {
        this.recentOrders = recentOrders;
    }
    
    public List<Product> getAvailableProducts() {
        return availableProducts;
    }
    
    public void setAvailableProducts(List<Product> availableProducts) {
        this.availableProducts = availableProducts;
    }
    
    /**
     * Get customer name for personalization
     */
    public String getCustomerName() {
        if (customer != null && customer.getName() != null) {
            return customer.getName();
        }
        if (user != null && user.getName() != null) {
            return user.getName();
        }
        return "Guest";
    }
    
    /**
     * Get loyalty points if customer is logged in
     */
    public int getLoyaltyPoints() {
        if (customer != null) {
            return customer.getLoyaltyPoint();
        }
        return 0;
    }
    
    /**
     * Check if user is authenticated
     */
    public boolean isAuthenticated() {
        return user != null;
    }
    
    /**
     * Get order history summary as string
     */
    public String getOrderHistory() {
        if (recentOrders == null || recentOrders.isEmpty()) {
            return "No previous orders";
        }
        
        StringBuilder sb = new StringBuilder();
        for (Order order : recentOrders) {
            sb.append(String.format("Order #%d - %s - %.2f VND; ", 
                    order.getOrderId(), 
                    order.getStatus(), 
                    order.getTotalMoney()));
        }
        return sb.toString();
    }
    
    /**
     * Get product catalog summary as string
     */
    public String getProductCatalog() {
        if (availableProducts == null || availableProducts.isEmpty()) {
            return "No products available";
        }
        
        StringBuilder sb = new StringBuilder();
        for (Product product : availableProducts) {
            sb.append(String.format("%s - %.2f VND; ", 
                    product.getProductName(), 
                    product.getPrice()));
        }
        return sb.toString();
    }
}
