package models;

import java.util.Date;

public class Customer extends User {
    private int customerID;
    private int loyaltyPoint;
    private Date lastEarnedDate;

    public Customer() {
    }

    public Customer(int customerID, int loyaltyPoint, Date lastEarnedDate,
            int userID, String name, String password, int role,
            String email, String phone, Date dateOfBirth,
            String gender, boolean isActive) {
        super(userID, name, password, role, email, phone, dateOfBirth, gender, isActive);
        this.customerID = customerID;
        this.loyaltyPoint = loyaltyPoint;
        this.lastEarnedDate = lastEarnedDate;
    }

    public Customer(int customerID, int loyaltyPoint, Date lasEarnedDate, int userID, String name, String email,
            String phone, int role) {
        super(userID, name, email, phone, role);
        this.customerID = customerID;
        this.loyaltyPoint = loyaltyPoint;
        this.lastEarnedDate = lasEarnedDate;
    }

    public Customer(int loyaltyPoint, int userID, String name, String email, String phone, int role) {
        super(userID, name, email, phone, role);
        this.loyaltyPoint = loyaltyPoint;
    }

    public int getCustomerID() {
        return customerID;
    }

    public void setCustomerID(int customerID) {
        this.customerID = customerID;
    }

    public int getLoyaltyPoint() {
        return loyaltyPoint;
    }

    public void setLoyaltyPoint(int loyaltyPoint) {
        this.loyaltyPoint = loyaltyPoint;
    }

    public Date getLastEarnedDate() {
        return lastEarnedDate;
    }

    public void setLastEarnedDate(Date lastEarnedDate) {
        this.lastEarnedDate = lastEarnedDate;
    }

}
