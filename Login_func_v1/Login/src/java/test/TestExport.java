package test;

import dao.SalesReportDAO;
import models.SalesReportData;
import java.io.FileOutputStream;
import java.io.IOException;

public class TestExport {
    public static void main(String[] args) {
        try {
            SalesReportDAO dao = new SalesReportDAO();
            
            // Get real data
            String dateFrom = "2025-11-03";
            String dateTo = "2025-11-03";
            String branch = "all";
            
            SalesReportData reportData = dao.getSalesReportData(dateFrom, dateTo, branch);
            System.out.println("Got report data: " + reportData);
            
            // Test CSV export
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
            
            // Write to file
            try (FileOutputStream fos = new FileOutputStream("test_export.csv")) {
                fos.write(csv.toString().getBytes("UTF-8"));
                System.out.println("CSV export test successful! File saved as test_export.csv");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}