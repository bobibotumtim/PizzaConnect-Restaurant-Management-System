package test;

import dao.DBContext;
import java.sql.*;

public class TestProductSize {
    public static void main(String[] args) {
        try {
            DBContext dbContext = new DBContext();
            Connection conn = dbContext.getConnection();
            
            // Test ProductSize table columns
            System.out.println("=== ProductSize Table Columns ===");
            DatabaseMetaData metaData = conn.getMetaData();
            ResultSet columns = metaData.getColumns(null, null, "ProductSize", null);
            while (columns.next()) {
                String columnName = columns.getString("COLUMN_NAME");
                String dataType = columns.getString("TYPE_NAME");
                System.out.println(columnName + " - " + dataType);
            }
            
            // Test some data
            System.out.println("\n=== Sample ProductSize Data ===");
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT TOP 5 * FROM ProductSize");
            while (rs.next()) {
                System.out.println("ProductSizeID: " + rs.getInt("ProductSizeID") + 
                                 ", ProductID: " + rs.getInt("ProductID") + 
                                 ", SizeName: " + rs.getString("SizeName"));
            }
            
            conn.close();
            
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}