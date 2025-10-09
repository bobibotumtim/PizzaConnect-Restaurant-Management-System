package dao;

import models.Customer;
import java.sql.*;

public class CustomerDAO extends DBContext {

    public Customer getCustomerByUserID(int userID) {
    Customer cus = null;
    String sql = "SELECT c.CustomerID, c.UserID, c.Name AS CustomerName, "
            + "c.LoyaltyPoint, u.Username, u.Email AS UserEmail, "
            + "u.Password, u.Phone AS UserPhone, u.Role "
            + "FROM Customer c "
            + "JOIN [User] u ON c.UserID = u.UserID "
            + "WHERE c.UserID = ?";

    try (PreparedStatement ps = connection.prepareStatement(sql)) {
        ps.setInt(1, userID);
        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                cus = new Customer(
                        rs.getInt("CustomerID"),
                        rs.getString("CustomerName"),
                        rs.getInt("LoyaltyPoint"),
                        rs.getInt("UserID"),
                        rs.getString("Username"),
                        rs.getString("UserEmail"),
                        rs.getString("Password"),
                        rs.getString("UserPhone"),
                        rs.getInt("Role")
                );
            }
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return cus;
}

    public boolean insertCustomer(Customer customer) {
        String sql = "INSERT INTO Customer (UserID, Name, LoyaltyPoint) VALUES (?, ?, ?)";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, customer.getUserID());
            ps.setString(2, customer.getName());
            ps.setInt(3, customer.getLoyaltyPoint());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

}
