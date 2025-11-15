package models;

import java.util.Date;

public class Employee extends User {
    private int employeeID;
    private String jobRole; // tránh trùng tên với role trong User

    public Employee() {
    }

    public Employee(int employeeID, String jobRole,
                    int userID, String name, String password, int userRole,
                    String email, String phone, Date dateOfBirth,
                    String gender, boolean isActive) {
        super(userID, name, password, userRole, email, phone, dateOfBirth, gender, isActive);
        this.employeeID = employeeID;
        this.jobRole = jobRole;
    }

    public Employee(int employeeID, String jobRole,
                    int userID, String name, String email, String phone, int userRole) {
        super(userID, name, email, phone, userRole);
        this.employeeID = employeeID;
        this.jobRole = jobRole;
    }

    public Employee(String jobRole,
                    int userID, String name, String email, String phone, int userRole) {
        super(userID, name, email, phone, userRole);
        this.jobRole = jobRole;
    }

    // Constructor nhận đối tượng User
    public Employee(int employeeID, String jobRole, User user) {
        super(user.getUserID(), user.getName(), user.getPassword(), user.getRole(),
              user.getEmail(), user.getPhone(), user.getDateOfBirth(),
              user.getGender(), user.isActive());
        this.employeeID = employeeID;
        this.jobRole = jobRole;
    }

    // ===== Getters & Setters =====
    public int getEmployeeID() {
        return employeeID;
    }

    public void setEmployeeID(int employeeID) {
        this.employeeID = employeeID;
    }

    public String getJobRole() {
        return jobRole;
    }

    public void setJobRole(String jobRole) {
        this.jobRole = jobRole;
    }
    
    // Alias methods for compatibility (cannot override getRole() from User)
    public String getEmployeeRole() {
        return jobRole;
    }
    
    public void setEmployeeRole(String role) {
        this.jobRole = role;
    }

    // Helper method to check if employee is a Chef
    public boolean isChef() {
        return jobRole != null && jobRole.equalsIgnoreCase("Chef");
    }

    // ===== toString =====
    @Override
    public String toString() {
        return "Employee{" +
                "employeeID=" + employeeID +
                ", jobRole='" + jobRole + '\'' +
                ", userID=" + getUserID() +
                ", name='" + getName() + '\'' +
                ", email='" + getEmail() + '\'' +
                ", phone='" + getPhone() + '\'' +
                ", systemRole=" + getRole() + // role từ User
                ", gender='" + getGender() + '\'' +
                ", dateOfBirth=" + getDateOfBirth() +
                ", isActive=" + isActive() +
                '}';
    }
}