package test;

import dao.SalesReportDAO;
import models.SalesReportData;
import java.io.IOException;
import java.io.PrintWriter;

public class TestExportServlet {
    public static void main(String[] args) {
        try {
            SalesReportDAO dao = new SalesReportDAO();
            
            // Get real data
            String dateFrom = "2025-11-03";
            String dateTo = "2025-11-03";
            String branch = "all";
            
            SalesReportData reportData = dao.getSalesReportData(dateFrom, dateTo, branch);
            
            // Simulate CSV export
            StringBuilder csv = new StringBuilder();
            
            // Header
            csv.append("SALES REPORT - PIZZA CONNECT\n");
            csv.append("Period:,").append(dateFrom).append(" to ").append(dateTo).append("\n");
            csv.append("Branch:,All Branches\n");
            csv.append("\n");
            
            // Summary Statistics
            csv.append("SUMMARY STATISTICS\n");
            csv.append("Metric,Value\n");
            csv.append("Total Revenue,").append(reportData.getTotalRevenue()).append("\n");
            csv.append("Total Orders,").append(reportData.getTotalOrders()).append("\n");
            csv.append("Total Customers,").append(reportData.getTotalCustomers()).append("\n");
            csv.append("Average Order Value,").append(reportData.getAvgOrderValue()).append("\n");
            csv.append("Growth Rate (%),").append(reportData.getGrowthRate()).append("\n");
            csv.append("\n");
            
            // Top Products
            csv.append("TOP PRODUCTS\n");
            csv.append("Rank,Product Name,Quantity,Revenue\n");
            if (reportData.getTopProducts() != null) {
                int rank = 1;
                for (models.TopProduct product : reportData.getTopProducts()) {
                    csv.append(rank++).append(",")
                       .append("\"").append(product.getProductName()).append("\",")
                       .append(product.getQuantity()).append(",")
                       .append(product.getRevenue()).append("\n");
                }
            }
            csv.append("\n");
            
            // Daily Revenue
            csv.append("DAILY REVENUE\n");
            csv.append("Date,Revenue,Orders\n");
            if (reportData.getDailyRevenue() != null) {
                for (models.DailyRevenue daily : reportData.getDailyRevenue()) {
                    csv.append("\"").append(daily.getDate()).append("\",")
                       .append(daily.getRevenue()).append(",")
                       .append(daily.getOrders()).append("\n");
                }
            }
            
            System.out.println("=== CSV Export Content ===");
            System.out.println(csv.toString());
            System.out.println("=== End CSV Content ===");
            
            // Test HTML export (PDF alternative)
            StringBuilder html = new StringBuilder();
            html.append("<!DOCTYPE html>");
            html.append("<html><head><title>Sales Report</title></head><body>");
            html.append("<h1>SALES REPORT - PIZZA CONNECT</h1>");
            html.append("<p>Period: ").append(dateFrom).append(" to ").append(dateTo).append("</p>");
            html.append("<h2>Summary Statistics</h2>");
            html.append("<table border='1'>");
            html.append("<tr><th>Metric</th><th>Value</th></tr>");
            html.append("<tr><td>Total Revenue</td><td>").append(String.format("%,.0f ₫", reportData.getTotalRevenue())).append("</td></tr>");
            html.append("<tr><td>Total Orders</td><td>").append(reportData.getTotalOrders()).append("</td></tr>");
            html.append("<tr><td>Total Customers</td><td>").append(reportData.getTotalCustomers()).append("</td></tr>");
            html.append("</table>");
            html.append("</body></html>");
            
            System.out.println("\n=== HTML Export Content ===");
            System.out.println(html.toString());
            System.out.println("=== End HTML Content ===");
            
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}