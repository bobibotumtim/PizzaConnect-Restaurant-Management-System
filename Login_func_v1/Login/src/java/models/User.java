package models;

import java.util.Date;

public class User {
    private int userID;
    private String name;
    private String password;
    private int role; 
    private String email;
    private String phone;
    private Date dateOfBirth;
    private String gender; 
    private boolean isActive;


    public User() {
    }

    public User(int userID, String name, String password, int role, String email, String phone, Date dateOfBirth, String gender, boolean isActive) {
        this.userID = userID;
        this.name = name;
        this.password = password;
        this.role = role;
        this.email = email;
        this.phone = phone;
        this.dateOfBirth = dateOfBirth;
        this.gender = gender;
        this.isActive = isActive;
    }


    public User(int userID, String name, String email, String phone, int role) {
        this.userID = userID;
        this.name = name;
        this.email = email;
        this.phone = phone;
        this.role = role;
    }

    public int getUserID() {
        return userID;
    }

    public String getName() {
        return name;
    }

    public String getPassword() {
        return password;
    }

    public int getRole() {
        return role;
    }

    public String getEmail() {
        return email;
    }

    public String getPhone() {
        return phone;
    }

    public Date getDateOfBirth() {
        return dateOfBirth;
    }

    public String getGender() {
        return gender;
    }

    public boolean isActive() {
        return isActive;
    }

    // ===== SETTERS =====
    public void setUserID(int userID) {
        this.userID = userID;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public void setRole(int role) {
        this.role = role;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public void setDateOfBirth(Date dateOfBirth) {
        this.dateOfBirth = dateOfBirth;
    }

    public void setGender(String gender) {
        this.gender = gender;
    }

    public void setActive(boolean isActive) {
        this.isActive = isActive;
    }

    // ===== toString =====
    @Override
    public String toString() {
        return "User{" +
                "userID=" + userID +
                ", name='" + name + '\'' +
                ", email='" + email + '\'' +
                ", phone='" + phone + '\'' +
                ", role=" + role +
                ", gender='" + gender + '\'' +
                ", dateOfBirth=" + dateOfBirth +
                ", isActive=" + isActive +
                '}';
    }
}
