/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package models;

import java.util.Date;

/**
 *
 * @author Admin
 */
public class Order {
    private int orderId;
    private int staffId;
    private String tableNumber;
    private Date orderDate;
    private int status;
    private double totalMoney;
    private String paymentStatus;
    private String customerName;
    private String customerPhone;
    private String notes;

    public Order() {
    }

    public Order(int orderId, int staffId, String tableNumber, Date orderDate, int status, double totalMoney, String paymentStatus) {
        this.orderId = orderId;
        this.staffId = staffId;
        this.tableNumber = tableNumber;
        this.orderDate = orderDate;
        this.status = status;
        this.totalMoney = totalMoney;
        this.paymentStatus = paymentStatus;
    }

    public Order(int orderId, int staffId, String tableNumber, Date orderDate, int status, double totalMoney, String paymentStatus, String customerName, String customerPhone, String notes) {
        this.orderId = orderId;
        this.staffId = staffId;
        this.tableNumber = tableNumber;
        this.orderDate = orderDate;
        this.status = status;
        this.totalMoney = totalMoney;
        this.paymentStatus = paymentStatus;
        this.customerName = customerName;
        this.customerPhone = customerPhone;
        this.notes = notes;
    }

    public String getStatusText() {
        switch (this.status) {
            case 0: return "Pending";
            case 1: return "Processing";
            case 2: return "Completed";
            case 3: return "Cancelled";
            default: return "Unknown";
        }
    }

    // Getters
    public int getOrderId() {
        return orderId;
    }

    public int getStaffId() {
        return staffId;
    }

    public String getTableNumber() {
        return tableNumber;
    }

    public Date getOrderDate() {
        return orderDate;
    }

    public int getStatus() {
        return status;
    }

    public double getTotalMoney() {
        return totalMoney;
    }

    public String getPaymentStatus() {
        return paymentStatus;
    }

    public String getCustomerName() {
        return customerName;
    }

    public String getCustomerPhone() {
        return customerPhone;
    }

    public String getNotes() {
        return notes;
    }

    // Setters
    public void setOrderId(int orderId) {
        this.orderId = orderId;
    }

    public void setStaffId(int staffId) {
        this.staffId = staffId;
    }

    public void setTableNumber(String tableNumber) {
        this.tableNumber = tableNumber;
    }

    public void setOrderDate(Date orderDate) {
        this.orderDate = orderDate;
    }

    public void setStatus(int status) {
        this.status = status;
    }

    public void setTotalMoney(double totalMoney) {
        this.totalMoney = totalMoney;
    }

    public void setPaymentStatus(String paymentStatus) {
        this.paymentStatus = paymentStatus;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }

    public void setCustomerPhone(String customerPhone) {
        this.customerPhone = customerPhone;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    @Override
    public String toString() {
        return "Order{" + 
                "orderId=" + orderId + 
                ", staffId=" + staffId + 
                ", tableNumber='" + tableNumber + '\'' + 
                ", orderDate=" + orderDate + 
                ", status=" + status + 
                ", totalMoney=" + totalMoney + 
                ", paymentStatus='" + paymentStatus + '\'' + 
                ", customerName='" + customerName + '\'' + 
                ", customerPhone='" + customerPhone + '\'' + 
                ", notes='" + notes + '\'' + 
                '}';
    }
}
