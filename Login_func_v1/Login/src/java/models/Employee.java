package models;

import java.util.Date;

public class Employee extends User {
    private int employeeID;
    private String jobRole; // tránh trùng tên với role trong User
    private String specialization; // Pizza, Drinks, SideDishes (for Chef only)

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
    
    // Alias methods for compatibility
    public String getRole() {
        return jobRole;
    }
    
    public void setRole(String role) {
        this.jobRole = role;
    }

    public String getSpecialization() {
        return specialization;
    }

    public void setSpecialization(String specialization) {
        this.specialization = specialization;
    }
    
    // Helper method to get display name for specialization
    public String getSpecializationDisplay() {
        if (specialization == null) return "N/A";
        switch (specialization) {
            case "Pizza": return "Chef Pizza";
            case "Drinks": return "Chef Nước";
            case "SideDishes": return "Chef Side Dishes";
            default: return specialization;
        }
    }
    
    // Helper method to check if employee is a Chef
    public boolean isChef() {
        return specialization != null && 
               !specialization.trim().isEmpty() && 
               !specialization.equalsIgnoreCase("None");
    }

    // ===== toString =====
    @Override
    public String toString() {
        return "Employee{" +
                "employeeID=" + employeeID +
                ", jobRole='" + jobRole + '\'' +
                ", specialization='" + specialization + '\'' +
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
