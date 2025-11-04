package test;

import dao.DBContext;
import java.sql.*;

public class TestDataExists {
    public static void main(String[] args) {
        try {
            DBContext dbContext = new DBContext();
            Connection conn = dbContext.getConnection();
            
            // Check Orders
            System.out.println("=== Orders Count ===");
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT COUNT(*) as OrderCount FROM [Order]");
            if (rs.next()) {
                System.out.println("Total Orders: " + rs.getInt("OrderCount"));
            }
            
            // Check OrderDetails
            System.out.println("\n=== OrderDetails Count ===");
            rs = stmt.executeQuery("SELECT COUNT(*) as DetailCount FROM OrderDetail");
            if (rs.next()) {
                System.out.println("Total OrderDetails: " + rs.getInt("DetailCount"));
            }
            
            // Check completed orders in recent dates
            System.out.println("\n=== Recent Completed Orders ===");
            rs = stmt.executeQuery("SELECT COUNT(*) as CompletedCount FROM [Order] WHERE Status = 2 AND OrderDate >= '2024-11-01'");
            if (rs.next()) {
                System.out.println("Completed Orders since Nov 1: " + rs.getInt("CompletedCount"));
            }
            
            // Check sample OrderDetail data
            System.out.println("\n=== Sample OrderDetail Data ===");
            rs = stmt.executeQuery("SELECT TOP 3 od.OrderDetailID, od.OrderID, od.ProductSizeID, od.Quantity, od.TotalPrice FROM OrderDetail od");
            while (rs.next()) {
                System.out.println("OrderDetailID: " + rs.getInt("OrderDetailID") + 
                                 ", OrderID: " + rs.getInt("OrderID") + 
                                 ", ProductSizeID: " + rs.getInt("ProductSizeID") +
                                 ", Quantity: " + rs.getInt("Quantity") +
                                 ", TotalPrice: " + rs.getDouble("TotalPrice"));
            }
            
            conn.close();
            
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}