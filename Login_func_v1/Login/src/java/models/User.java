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
public class User {
    private int userID;
    private String username;
    private String email;
    private String password;
    private String phone;
    private int role;    

    public User(int aInt, String string, String string1, String string2, int aInt1) {
    }

    public User(int userID, String username, String email, String phone) {
        this.userID = userID;
        this.username = username;
        this.email = email;
        this.phone = phone;
    }
    
    public User(int userID, String username, String email, String password, String phone, int role) {
        this.userID = userID;
        this.username = username;
        this.email = email;
        this.password = password;
        this.phone = phone;
        this.role = role;
    }

    public int getUserID() {
        return userID;
    }

    public String getUsername() {
        return username;
    }

    public String getEmail() {
        return email;
    }

    public String getPassword() {
        return password;
    }

    public String getPhone() {
        return phone;
    }

    public int getRole() {
        return role;
    }

    public void setUserID(int userID) {
        this.userID = userID;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public vemail=" + email + ", password=" + password + ", phone=" + phone + ", role=" + role + '}';
    }
    

    
    
}

