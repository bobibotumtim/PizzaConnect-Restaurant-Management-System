package models;

public class Customer extends User{
    private int customerID;
    private String name;
    private int loyaltyPoint;

    public Customer(int customerID, String name, int loyaltyPoint, 
                    int userID, String username, String Email, String password, 
                    String phone, int role) {
        super(userID, username, Email, password, phone, role);
        this.customerID = customerID;
        this.name = name;
        this.loyaltyPoint = loyaltyPoint;
    }

    public int getCustomerID() {
        return customerID;
    }

    public void setCustomerID(int customerID) {
        this.customerID = customerID;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getLoyaltyPoint() {
        return loyaltyPoint;
    }

    public void setLoyaltyPoint(int loyaltyPoint) {
        this.loyaltyPoint = loyaltyPoint;
    }
    
    
}
