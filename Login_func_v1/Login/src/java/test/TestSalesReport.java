package test;

import dao.SalesReportDAO;
import models.SalesReportData;
import models.TopProduct;
import models.DailyRevenue;
import java.util.List;

public class TestSalesReport {
    public static void main(String[] args) {
        try {
            SalesReportDAO dao = new SalesReportDAO();
            
            // Test với dữ liệu mẫu - sử dụng ngày có dữ liệu
            String dateFrom = "2025-11-03";
            String dateTo = "2025-11-03";
            String branch = "all";
            
            System.out.println("Testing SalesReportDAO...");
            
            // Test individual methods
            double totalRevenue = dao.getTotalRevenue(dateFrom, dateTo, branch);
            System.out.println("Total Revenue: " + totalRevenue);
            
            int totalOrders = dao.getTotalOrders(dateFrom, dateTo, branch);
            System.out.println("Total Orders: " + totalOrders);
            
            int totalCustomers = dao.getTotalCustomers(dateFrom, dateTo, branch);
            System.out.println("Total Customers: " + totalCustomers);
            
            List<TopProduct> topProducts = dao.getTopProducts(dateFrom, dateTo, branch, 5);
            System.out.println("Top Products: " + topProducts.size());
            
            List<DailyRevenue> dailyRevenue = dao.getDailyRevenue(dateFrom, dateTo, branch);
            System.out.println("Daily Revenue entries: " + dailyRevenue.size());
            
            // Test complete report data
            SalesReportData reportData = dao.getSalesReportData(dateFrom, dateTo, branch);
            System.out.println("Complete report data created successfully!");
            System.out.println("Report: " + reportData);
            
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}