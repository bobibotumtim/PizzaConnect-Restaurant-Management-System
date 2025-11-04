package test;

import dao.DBContext;
import java.sql.*;

public class TestOrderDates {
    public static void main(String[] args) {
        try {
            DBContext dbContext = new DBContext();
            Connection conn = dbContext.getConnection();
            
            // Check Order dates and status
            System.out.println("=== Order Dates and Status ===");
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT OrderID, OrderDate, Status, TotalPrice FROM [Order] ORDER BY OrderDate DESC");
            while (rs.next()) {
                System.out.println("OrderID: " + rs.getInt("OrderID") + 
                                 ", Date: " + rs.getTimestamp("OrderDate") + 
                                 ", Status: " + rs.getInt("Status") +
                                 ", TotalPrice: " + rs.getDouble("TotalPrice"));
            }
            
            // Test our query directly
            System.out.println("\n=== Testing Revenue Query ===");
            String sql = "SELECT SUM(TotalPrice) as TotalRevenue FROM [Order] WHERE OrderDate >= ? AND OrderDate <= ? AND Status = 2";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, "2024-11-04");
            ps.setString(2, "2024-11-04 23:59:59");
            rs = ps.executeQuery();
            if (rs.next()) {
                System.out.println("Total Revenue for 2024-11-04: " + rs.getDouble("TotalRevenue"));
            }
            
            conn.close();
            
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}