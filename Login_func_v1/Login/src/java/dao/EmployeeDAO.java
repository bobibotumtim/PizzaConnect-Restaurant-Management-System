package dao;

import models.Employee;
import java.sql.*;
import java.util.logging.Level;
import java.util.logging.Logger;

public class EmployeeDAO {
    private final DBContext dbContext;
    
    public EmployeeDAO() {
        this.dbContext = new DBContext();
    }
    
    // Insert new employee
    public int insertEmployee(Employee employee) {
        String sql = "INSERT INTO Employee (UserID, Role) VALUES (?, ?)";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = dbContext.getConnection();
            ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setInt(1, employee.getUserID());
            ps.setString(2, employee.getRole());
            
            int affectedRows = ps.executeUpdate();
            
            if (affectedRows > 0) {
                rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            Logger.getLogger(EmployeeDAO.class.getName()).log(Level.SEVERE, "Error inserting employee", e);
        } finally {
            closeResources(conn, ps, rs);
        }
        return -1;
    }
    
    // Get employee by UserID
    public Employee getEmployeeByUserId(int userId) {
        String sql = "SELECT * FROM Employee WHERE UserID = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = dbContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            rs = ps.executeQuery();
            
            if (rs.next()) {
                Employee employee = new Employee();
                employee.setEmployeeID(rs.getInt("EmployeeID"));
                employee.setUserID(rs.getInt("UserID"));
                employee.setRole(rs.getString("Role"));
                return employee;
            }
        } catch (SQLException e) {
            Logger.getLogger(EmployeeDAO.class.getName()).log(Level.SEVERE, "Error getting employee by user ID", e);
        } finally {
            closeResources(conn, ps, rs);
        }
        return null;
    }
    
    // Update employee role
    public boolean updateEmployeeRole(int userId, String role) {
        String sql = "UPDATE Employee SET Role = ? WHERE UserID = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        
        try {
            conn = dbContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, role);
            ps.setInt(2, userId);
            
            int affectedRows = ps.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            Logger.getLogger(EmployeeDAO.class.getName()).log(Level.SEVERE, "Error updating employee role", e);
        } finally {
            closeResources(conn, ps, null);
        }
        return false;
    }
    
    // Delete employee by UserID
    public boolean deleteEmployee(int userId) {
        String sql = "DELETE FROM Employee WHERE UserID = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        
        try {
            conn = dbContext.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            
            int affectedRows = ps.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            Logger.getLogger(EmployeeDAO.class.getName()).log(Level.SEVERE, "Error deleting employee", e);
        } finally {
            closeResources(conn, ps, null);
        }
        return false;
    }
    
    // Close resources
    private void closeResources(Connection conn, PreparedStatement ps, ResultSet rs) {
        if (rs != null) {
            try {
                rs.close();
            } catch (SQLException e) {
                Logger.getLogger(EmployeeDAO.class.getName()).log(Level.WARNING, "Error closing ResultSet", e);
            }
        }
        if (ps != null) {
            try {
                ps.close();
            } catch (SQLException e) {
                Logger.getLogger(EmployeeDAO.class.getName()).log(Level.WARNING, "Error closing PreparedStatement", e);
            }
        }
        DBContext.closeConnection(conn);
    }
}
