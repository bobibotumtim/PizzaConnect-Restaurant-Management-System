package controller;

import dao.SalesReportDAO;
import models.SalesReportData;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;

public class TestExportDirectServlet extends HttpServlet {
    
    private final SalesReportDAO salesReportDAO = new SalesReportDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            // Get real data from database
            String dateFrom = "2025-11-03";
            String dateTo = "2025-11-03";
            String branch = "all";
            
            SalesReportData reportData = salesReportDAO.getSalesReportData(dateFrom, dateTo, branch);
            
            // Export as CSV
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
            
            // Set response headers for CSV download
            response.setContentType("text/csv; charset=UTF-8");
            response.setHeader("Content-Disposition", 
                "attachment; filename=\"SalesReport_" + dateFrom + "_" + dateTo + ".csv\"");
            
            // Write CSV data
            response.getWriter().write(csv.toString());
            response.getWriter().flush();
            
        } catch (Exception e) {
            e.printStackTrace();
            response.setContentType("text/html");
            response.getWriter().write("<h1>Export Test Error</h1><pre>" + e.getMessage() + "</pre>");
        }
    }
}