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
    private Date date;
    private String userName;
    private double totalMoney;
    private int status;
    private String address;

    public Order(int orderId, Date date, String userName, double totalMoney, int status, String address) {
        this.orderId = orderId;
        this.date = date;
        this.userName = userName;
        this.totalMoney = totalMoney;
        this.status = status;
        this.address = address;
    }

    public Order() {
    }
// model/Order.java
public String getStatusText() {
    switch (this.status) {
        case 0: return "Pending";
        case 1: return "Processing";
        case 2: return "Completed";
        case 3: return "Cancelled";
        default: return "Unknown";
    }
}

    public int getOrderId() {
        return orderId;
    }

    public Date getDate() {
        return date;
    }

    public String getUserName() {
        return userName;
    }

    public double getTotalMoney() {
        return totalMoney;
    }

    public int getStatus() {
        return status;
    }

    public String getAddress() {
        return address;
    }

    public void setOrderId(int orderId) {
        this.orderId = orderId;
    }

    public void setDate(Date date) {
        this.date = date;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public void setTotalMoney(double totalMoney) {
        this.totalMoney = totalMoney;
    }
    public void setStatus(int status) {
        this.status = status;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    @Override
    public String toString() {
        return "Order{" + "orderId=" + orderId + ", date=" + date + ", userName=" + userName + ", totalMoney=" + totalMoney + ", status=" + status + ", address=" + address + '}';
    }
    
}
