package models;

import java.util.Date;

public class Customer extends User {
    private int customerID;
    private int loyaltyPoint;

    public Customer() {
    }

    public Customer(int customerID, int loyaltyPoint,
                    int userID, String name, String password, int role,
                    String email, String phone, Date dateOfBirth,
                    String gender, boolean isActive) {
        super(userID, name, password, role, email, phone, dateOfBirth, gender, isActive);
        this.customerID = customerID;
        this.loyaltyPoint = loyaltyPoint;
    }

    public Customer(int customerID, int loyaltyPoint, int userID, String name, String email, String phone, int role) {
        super(userID, name, email, phone, role);
        this.customerID = customerID;
        this.loyaltyPoint = loyaltyPoint;
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

    
}
