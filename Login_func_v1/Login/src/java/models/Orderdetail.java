/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package models;

/**
 *
 * @author Admin
 */
public class Orderdetail {
    private int orderDetailId;
    private int orderId;
    private int productId;
    private int quantity;
    private double unitPrice;
    private double totalPrice;
    private String specialInstructions;

    public Orderdetail() {
    }

    public Orderdetail(int orderId, int productId, int quantity, double unitPrice) {
        this.orderId = orderId;
        this.productId = productId;
        this.quantity = quantity;
        this.unitPrice = unitPrice;
        this.totalPrice = quantity * unitPrice;
    }

    public Orderdetail(int orderDetailId, int orderId, int productId, int quantity, double unitPrice, double totalPrice, String specialInstructions) {
        this.orderDetailId = orderDetailId;
        this.orderId = orderId;
        this.productId = productId;
        this.quantity = quantity;
        this.unitPrice = unitPrice;
        this.totalPrice = totalPrice;
        this.specialInstructions = specialInstructions;
    }

    // Getters
    public int getOrderDetailId() {
        return orderDetailId;
    }

    public int getOrderId() {
        return orderId;
    }

    public int getProductId() {
        return productId;
    }

    public int getQuantity() {
        return quantity;
    }

    public double getUnitPrice() {
        return unitPrice;
    }

    public double getTotalPrice() {
        return totalPrice;
    }

    public String getSpecialInstructions() {
        return specialInstructions;
    }

    // Setters
    public void setOrderDetailId(int orderDetailId) {
        this.orderDetailId = orderDetailId;
    }

    public void setOrderId(int orderId) {
        this.orderId = orderId;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
        this.totalPrice = quantity * unitPrice; // Auto calculate total price
    }

    public void setUnitPrice(double unitPrice) {
        this.unitPrice = unitPrice;
        this.totalPrice = quantity * unitPrice; // Auto calculate total price
    }

    public void setTotalPrice(double totalPrice) {
        this.totalPrice = totalPrice;
    }

    public void setSpecialInstructions(String specialInstructions) {
        this.specialInstructions = specialInstructions;
    }

    @Override
    public String toString() {
        return "Orderdetail{" + 
                "orderDetailId=" + orderDetailId + 
                ", orderId=" + orderId + 
                ", productId=" + productId + 
                ", quantity=" + quantity + 
                ", unitPrice=" + unitPrice + 
                ", totalPrice=" + totalPrice + 
                ", specialInstructions='" + specialInstructions + '\'' + 
                '}';
    }
}
