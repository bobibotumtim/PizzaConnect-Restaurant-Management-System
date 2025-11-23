package dao;

import models.Customer;
import java.sql.*;

public class CustomerDAO extends DBContext {

    // Get customer by UserID - FIXED
    public Customer getCustomerByUserID(int userID) {
        String sql = """
                    SELECT
                        c.CustomerID, c.UserID, c.LoyaltyPoint, c.LastEarnedDate,
                        u.Name, u.Email, u.Phone, u.DateOfBirth, u.Gender, u.IsActive
                    FROM Customer c
                    INNER JOIN [User] u ON c.UserID = u.UserID
                    WHERE c.UserID = ? AND u.IsActive = 1
                """;

        try (Connection connection = getConnection();
                PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userID);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapCustomerFromJoin(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("Lỗi khi lấy thông tin khách hàng theo UserID: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    // New method to map customer from joined query
    private Customer mapCustomerFromJoin(ResultSet rs) throws SQLException {
        Customer customer = new Customer();
        customer.setCustomerID(rs.getInt("CustomerID"));
        customer.setUserID(rs.getInt("UserID"));
        customer.setLoyaltyPoint(rs.getInt("LoyaltyPoint"));
        customer.setLastEarnedDate(rs.getTimestamp("LastEarnedDate"));

        // Set information from User table
        customer.setName(rs.getString("Name"));
        customer.setEmail(rs.getString("Email"));
        customer.setPhone(rs.getString("Phone"));
        customer.setDateOfBirth(rs.getDate("DateOfBirth"));
        customer.setGender(rs.getString("Gender"));
        customer.setActive(rs.getBoolean("IsActive"));

        return customer;
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

    // Add new customer and return ID
    public int insertCustomerReturnId(Customer customer) {
        String sql = """
                    INSERT INTO Customer (UserID, LoyaltyPoint)
                    VALUES (?, ?)
                """;
        try (Connection connection = getConnection();
                PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, customer.getUserID());
            ps.setInt(2, customer.getLoyaltyPoint());

            int affectedRows = ps.executeUpdate();
            if (affectedRows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("Lỗi khi thêm khách hàng: " + e.getMessage());
        }
        return -1;
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



    // Map ResultSet to Customer object - Keep original for backward compatibility
    private Customer mapCustomer(ResultSet rs) throws SQLException {
        java.sql.Date lastEarnedDateSql = rs.getDate("LastEarnedDate");
        java.util.Date lastEarnedDate = (lastEarnedDateSql != null) ? new java.util.Date(lastEarnedDateSql.getTime())
                : null;

        return new Customer(
                rs.getInt("CustomerID"),
                rs.getInt("LoyaltyPoint"),
                lastEarnedDate,
                rs.getInt("UserID"),
                rs.getString("UserName"),
                rs.getString("Password"),
                rs.getInt("Role"),
                rs.getString("Email"),
                rs.getString("Phone"),
                rs.getDate("DateOfBirth"),
                rs.getString("Gender"),
                rs.getBoolean("IsActive"));
    }
}