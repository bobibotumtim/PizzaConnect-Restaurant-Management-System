package test;

import dao.DBContext;
import java.sql.*;

public class TestDatabaseSchema {
    public static void main(String[] args) {
        try {
            DBContext dbContext = new DBContext();
            Connection conn = dbContext.getConnection();
            
            // Test Product table columns
            System.out.println("=== Product Table Columns ===");
            DatabaseMetaData metaData = conn.getMetaData();
            ResultSet columns = metaData.getColumns(null, null, "Product", null);
            while (columns.next()) {
                String columnName = columns.getString("COLUMN_NAME");
                String dataType = columns.getString("TYPE_NAME");
                System.out.println(columnName + " - " + dataType);
            }
            
            // Test OrderDetail table columns
            System.out.println("\n=== OrderDetail Table Columns ===");
            columns = metaData.getColumns(null, null, "OrderDetail", null);
            while (columns.next()) {
                String columnName = columns.getString("COLUMN_NAME");
                String dataType = columns.getString("TYPE_NAME");
                System.out.println(columnName + " - " + dataType);
            }
            
            // Test Order table columns
            System.out.println("\n=== Order Table Columns ===");
            columns = metaData.getColumns(null, null, "Order", null);
            while (columns.next()) {
                String columnName = columns.getString("COLUMN_NAME");
                String dataType = columns.getString("TYPE_NAME");
                System.out.println(columnName + " - " + dataType);
            }
            
            conn.close();
            
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}