package models;

public class Employee {
    private int employeeID;
    private int userID;
    private String role; // Manager, Cashier, Waiter, Chef
    
    public Employee() {
    }
    
    public Employee(int employeeID, int userID, String role) {
        this.employeeID = employeeID;
        this.userID = userID;
        this.role = role;
    }
    
    public int getEmployeeID() {
        return employeeID;
    }
    
    public void setEmployeeID(int employeeID) {
        this.employeeID = employeeID;
    }
    
    public int getUserID() {
        return userID;
    }
    
    public void setUserID(int userID) {
        this.userID = userID;
    }
    
    public String getRole() {
        return role;
    }
    
    public void setRole(String role) {
        this.role = role;
    }
}
