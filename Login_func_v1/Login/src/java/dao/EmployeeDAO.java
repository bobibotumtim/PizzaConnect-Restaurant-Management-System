package dao;

import java.sql.*;
import models.Employee;
import models.User;

public class EmployeeDAO extends DBContext {

    public Employee getEmployeeByUserID(int userID) {
        String sql = """
                SELECT e.EmployeeID, e.Role AS JobRole, e.Specialization, u.*
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

                // Gán jobRole và specialization từ Employee table
                Employee employee = new Employee(
                        rs.getInt("EmployeeID"),
                        rs.getString("JobRole"),
                        u
                );
                employee.setSpecialization(rs.getString("Specialization"));
                
                return employee;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    public Employee getEmployeeByUserId(int userID) {
        return getEmployeeByUserID(userID);
    }

    public int insertEmployee(Employee employee) {
        String sql = "INSERT INTO Employee (UserID, Role, Specialization) VALUES (?, ?, ?)";
        
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, employee.getUserID());
            ps.setString(2, employee.getRole());
            ps.setString(3, employee.getSpecialization());
            
            int affectedRows = ps.executeUpdate();
            
            if (affectedRows > 0) {
                ResultSet rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        return -1;
    }

    public boolean updateEmployeeRole(int userID, String role) {
        String sql = "UPDATE Employee SET Role = ? WHERE UserID = ?";
        
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, role);
            ps.setInt(2, userID);
            
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        return false;
    }

    public boolean deleteEmployee(int userID) {
        String sql = "DELETE FROM Employee WHERE UserID = ?";
        
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userID);
            
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        return false;
    }
}
