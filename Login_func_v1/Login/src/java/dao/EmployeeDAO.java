package dao;

import java.sql.*;
import models.Employee;
import models.User;

public class EmployeeDAO extends DBContext {

    public Employee getEmployeeByUserID(int userID) {
        String sql = """
                SELECT e.EmployeeID, e.Role AS JobRole, u.*
                FROM Employee e
                JOIN [User] u ON e.UserID = u.UserID
                WHERE e.UserID = ?
                """;

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userID);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                User u = new User(
                        rs.getInt("UserID"),
                        rs.getString("Name"),
                        rs.getString("Password"),
                        rs.getInt("Role"), // Role của User (system role)
                        rs.getString("Email"),
                        rs.getString("Phone"),
                        rs.getDate("DateOfBirth"),
                        rs.getString("Gender"),
                        rs.getBoolean("isActive")
                );

                // Gán jobRole từ Employee table
                return new Employee(
                        rs.getInt("EmployeeID"),
                        rs.getString("JobRole"),
                        u
                );
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }
}
