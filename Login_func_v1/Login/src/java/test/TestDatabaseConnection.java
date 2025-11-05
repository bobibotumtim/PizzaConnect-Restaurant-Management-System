package test;

import dao.DBContext;
import java.sql.*;

public class TestDatabaseConnection {
    
    public static void main(String[] args) {
        System.out.println("=== Testing Database Connection ===");
        
        try {
            DBContext dbContext = new DBContext();
            Connection conn = dbContext.getConnection();
            
            if (conn != null) {
                System.out.println("✓ Database connection successful!");
                
                // Test if customer_feedback table exists
                String checkTableSQL = "SELECT COUNT(*) as table_count FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'customer_feedback'";
                PreparedStatement ps = conn.prepareStatement(checkTableSQL);
                ResultSet rs = ps.executeQuery();
                
                if (rs.next() && rs.getInt("table_count") > 0) {
                    System.out.println("✓ customer_feedback table exists");
                    
                    // Check data count
                    String countSQL = "SELECT COUNT(*) as total_count FROM customer_feedback";
                    PreparedStatement countPs = conn.prepareStatement(countSQL);
                    ResultSet countRs = countPs.executeQuery();
                    
                    if (countRs.next()) {
                        int totalCount = countRs.getInt("total_count");
                        System.out.println("✓ Found " + totalCount + " records in customer_feedback table");
                        
                        if (totalCount > 0) {
                            // Show sample data
                            String sampleSQL = "SELECT TOP 3 feedback_id, customer_name, rating, comment FROM customer_feedback ORDER BY feedback_id";
                            PreparedStatement samplePs = conn.prepareStatement(sampleSQL);
                            ResultSet sampleRs = samplePs.executeQuery();
                            
                            System.out.println("\nSample data:");
                            while (sampleRs.next()) {
                                System.out.println("  ID: " + sampleRs.getInt("feedback_id") + 
                                                 ", Customer: " + sampleRs.getString("customer_name") + 
                                                 ", Rating: " + sampleRs.getInt("rating") + 
                                                 ", Comment: " + sampleRs.getString("comment").substring(0, Math.min(50, sampleRs.getString("comment").length())) + "...");
                            }
                            sampleRs.close();
                            samplePs.close();
                        } else {
                            System.out.println("! No data found. Please run customer_feedback_setup.sql");
                        }
                    }
                    countRs.close();
                    countPs.close();
                } else {
                    System.out.println("✗ customer_feedback table does not exist");
                    System.out.println("  Please run customer_feedback_setup.sql first");
                }
                
                rs.close();
                ps.close();
                conn.close();
                
            } else {
                System.out.println("✗ Failed to connect to database");
            }
            
        } catch (Exception e) {
            System.out.println("✗ Error: " + e.getMessage());
            e.printStackTrace();
        }
        
        System.out.println("\n=== Test completed ===");
    }
}