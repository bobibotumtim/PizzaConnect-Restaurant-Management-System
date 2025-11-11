package controller;

import dao.DBContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

@WebServlet("/test-inventory")
public class TestInventoryServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        out.println("<!DOCTYPE html>");
        out.println("<html><head><title>Test Inventory</title>");
        out.println("<style>");
        out.println("body { font-family: Arial; margin: 20px; }");
        out.println(".success { color: green; font-weight: bold; }");
        out.println(".error { color: red; font-weight: bold; }");
        out.println("table { border-collapse: collapse; margin: 20px 0; width: 100%; }");
        out.println("th, td { border: 1px solid #ddd; padding: 8px; }");
        out.println("th { background-color: #f97316; color: white; }");
        out.println("</style></head><body>");
        
        out.println("<h1>Inventory Database Test</h1>");
        
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            DBContext dbContext = new DBContext();
            conn = dbContext.getConnection();
            
            if (conn != null && !conn.isClosed()) {
                out.println("<p class='success'>✓ Database connected!</p>");
                out.println("<p>Database: " + conn.getMetaData().getDatabaseProductName() + "</p>");
            } else {
                out.println("<p class='error'>✗ Database connection failed!</p>");
                return;
            }
            
            // Check table exists
            DatabaseMetaData metaData = conn.getMetaData();
            ResultSet tables = metaData.getTables(null, null, "Inventory", null);
            
            if (tables.next()) {
                out.println("<p class='success'>✓ Inventory table exists</p>");
            } else {
                out.println("<p class='error'>✗ Inventory table NOT found!</p>");
            }
            tables.close();
            
            // Count records
            String countSql = "SELECT COUNT(*) as total FROM Inventory";
            ps = conn.prepareStatement(countSql);
            rs = ps.executeQuery();
            
            int totalCount = 0;
            if (rs.next()) {
                totalCount = rs.getInt("total");
                out.println("<h2>Total Records: " + totalCount + "</h2>");
                
                if (totalCount == 0) {
                    out.println("<p class='error'>⚠ No data! Table is empty.</p>");
                    out.println("<p>You need to add inventory items first.</p>");
                }
            }
            rs.close();
            ps.close();
            
            // Show records if any
            if (totalCount > 0) {
                out.println("<h2>First 10 Records</h2>");
                out.println("<table>");
                
                String selectSql = "SELECT TOP 10 * FROM Inventory ORDER BY InventoryID";
                ps = conn.prepareStatement(selectSql);
                rs = ps.executeQuery();
                
                // Print column headers dynamically
                ResultSetMetaData rsmd = rs.getMetaData();
                int columnCount = rsmd.getColumnCount();
                out.println("<tr>");
                for (int i = 1; i <= columnCount; i++) {
                    out.println("<th>" + rsmd.getColumnName(i) + "</th>");
                }
                out.println("</tr>");
                
                while (rs.next()) {
                    out.println("<tr>");
                    for (int i = 1; i <= columnCount; i++) {
                        out.println("<td>" + rs.getString(i) + "</td>");
                    }
                    out.println("</tr>");
                }
                out.println("</table>");
            }
            
        } catch (Exception e) {
            out.println("<p class='error'>Error: " + e.getMessage() + "</p>");
            out.println("<pre>");
            e.printStackTrace(out);
            out.println("</pre>");
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (ps != null) try { ps.close(); } catch (Exception e) {}
            if (conn != null) try { conn.close(); } catch (Exception e) {}
        }
        
        out.println("<hr>");
        out.println("<p><a href='manageinventory'>← Back to Manage Inventory</a></p>");
        out.println("</body></html>");
    }
}
