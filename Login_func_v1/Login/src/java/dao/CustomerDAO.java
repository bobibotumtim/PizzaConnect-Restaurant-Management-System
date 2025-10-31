package dao;

import models.Customer;
import java.sql.*;

public class CustomerDAO extends DBContext {

    // Get customer by UserID
    public Customer getCustomerByUserID(int userID) {
        String sql = """
            SELECT 
                c.CustomerID, c.UserID, c.LoyaltyPoint,
                u.Name AS UserName, u.Password, u.Role,
                u.Email, u.Phone, u.DateOfBirth, u.Gender, u.IsActive
            FROM Customer c
            INNER JOIN [User] u ON c.UserID = u.UserID
            WHERE c.UserID = ?
        """;

        try (Connection connection = getConnection();
            PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userID);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapCustomer(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("Lỗi khi lấy thông tin khách hàng theo UserID: " + e.getMessage());
        }
        return null;
    }

    // Add new customer
    public boolean insertCustomer(Customer customer) {
        String sql = """
            INSERT INTO Customer (UserID, LoyaltyPoint)
            VALUES (?, ?)
        """;
        try (Connection connection = getConnection();
            PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, customer.getUserID());
            ps.setInt(2, customer.getLoyaltyPoint());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Lỗi khi thêm khách hàng: " + e.getMessage());
        }
        return false;
    }

    // Update customer loyalty points
    public boolean updateCustomerPoints(int customerID, int newPoints) {
        String sql = "UPDATE Customer SET LoyaltyPoint = ? WHERE CustomerID = ?";
        try (Connection connection = getConnection();
            PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, newPoints);
            ps.setInt(2, customerID);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Lỗi khi cập nhật điểm thưởng: " + e.getMessage());
        }
        return false;
    }

    // Delete customer by CustomerID
    public boolean deleteCustomer(int customerID) {
        String sql = "DELETE FROM Customer WHERE CustomerID = ?";
        try (Connection connection = getConnection();
            PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, customerID);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("❌ Lỗi khi xóa khách hàng: " + e.getMessage());
        }
        return false;
    }

    // Map ResultSet to Customer object
    private Customer mapCustomer(ResultSet rs) throws SQLException {
        return new Customer(
                rs.getInt("CustomerID"),
                rs.getInt("LoyaltyPoint"),
                rs.getInt("UserID"),
                rs.getString("UserName"),
                rs.getString("Email"),
                rs.getString("Phone"),
                rs.getInt("Role")
        );
    }
}
