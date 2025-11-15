package dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import models.DailyRevenue;
import models.SalesReportData;
import models.TopProduct;

public class SalesReportDAO extends DBContext {
    
    private static final Logger LOGGER = Logger.getLogger(SalesReportDAO.class.getName());

    /**
     * Lấy tổng doanh thu trong khoảng thời gian
     */
    public double getTotalRevenue(String dateFrom, String dateTo, String branch) {
        String sql = "SELECT ISNULL(SUM(TotalPrice), 0) as TotalRevenue FROM [Order] " +
                    "WHERE OrderDate >= ? AND OrderDate <= ? AND Status = 3"; // Status 3 = Completed (Paid)
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, dateFrom);
            ps.setString(2, dateTo + " 23:59:59"); // Include full day
            
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getDouble("TotalRevenue");
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting total revenue", e);
        }
        return 0.0;
    }

    /**
     * Lấy tổng số đơn hàng trong khoảng thời gian
     */
    public int getTotalOrders(String dateFrom, String dateTo, String branch) {
        String sql = "SELECT COUNT(*) as TotalOrders FROM [Order] " +
                    "WHERE OrderDate >= ? AND OrderDate <= ? AND Status = 3";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, dateFrom);
            ps.setString(2, dateTo + " 23:59:59");
            
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("TotalOrders");
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting total orders", e);
        }
        return 0;
    }

    /**
     * Lấy tổng số khách hàng unique trong khoảng thời gian
     */
    public int getTotalCustomers(String dateFrom, String dateTo, String branch) {
        String sql = "SELECT COUNT(DISTINCT CustomerID) as TotalCustomers FROM [Order] " +
                    "WHERE OrderDate >= ? AND OrderDate <= ? AND Status = 3";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, dateFrom);
            ps.setString(2, dateTo + " 23:59:59");
            
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("TotalCustomers");
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting total customers", e);
        }
        return 0;
    }

    /**
     * Lấy danh sách top sản phẩm bán chạy
     */
    public List<TopProduct> getTopProducts(String dateFrom, String dateTo, String branch, int limit) {
        List<TopProduct> topProducts = new ArrayList<>();
        String sql = "SELECT TOP (?) p.ProductName, " +
                    "SUM(od.Quantity) as TotalQuantity, " +
                    "SUM(od.TotalPrice) as TotalRevenue " +
                    "FROM OrderDetail od " +
                    "JOIN ProductSize ps ON od.ProductSizeID = ps.ProductSizeID " +
                    "JOIN Product p ON ps.ProductID = p.ProductID " +
                    "JOIN [Order] o ON od.OrderID = o.OrderID " +
                    "WHERE o.OrderDate >= ? AND o.OrderDate <= ? AND o.Status = 3 " +
                    "GROUP BY p.ProductID, p.ProductName " +
                    "ORDER BY TotalRevenue DESC";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, limit);
            ps.setString(2, dateFrom);
            ps.setString(3, dateTo + " 23:59:59");
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                TopProduct product = new TopProduct(
                    rs.getString("ProductName"),
                    rs.getInt("TotalQuantity"),
                    rs.getDouble("TotalRevenue")
                );
                topProducts.add(product);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting top products", e);
        }
        return topProducts;
    }

    /**
     * Lấy doanh thu theo ngày
     */
    public List<DailyRevenue> getDailyRevenue(String dateFrom, String dateTo, String branch) {
        List<DailyRevenue> dailyRevenue = new ArrayList<>();
        String sql = "SELECT CONVERT(VARCHAR, CONVERT(DATE, OrderDate), 103) as OrderDate, " +
                    "SUM(TotalPrice) as DailyRevenue, " +
                    "COUNT(*) as OrderCount " +
                    "FROM [Order] " +
                    "WHERE OrderDate >= ? AND OrderDate <= ? AND Status = 3 " +
                    "GROUP BY CONVERT(DATE, OrderDate) " +
                    "ORDER BY CONVERT(DATE, OrderDate)";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, dateFrom);
            ps.setString(2, dateTo + " 23:59:59");
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                DailyRevenue daily = new DailyRevenue(
                    rs.getString("OrderDate"),
                    rs.getDouble("DailyRevenue"),
                    rs.getInt("OrderCount")
                );
                dailyRevenue.add(daily);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting daily revenue", e);
        }
        return dailyRevenue;
    }

    /**
     * Lấy doanh thu theo ngày của kỳ trước (cùng số ngày)
     */
    public List<DailyRevenue> getPreviousPeriodDailyRevenue(String dateFrom, String dateTo, String branch) {
        List<DailyRevenue> dailyRevenue = new ArrayList<>();
        
        try {
            // Tính số ngày giữa dateFrom và dateTo
            java.time.LocalDate fromDate = java.time.LocalDate.parse(dateFrom);
            java.time.LocalDate toDate = java.time.LocalDate.parse(dateTo);
            long daysDiff = java.time.temporal.ChronoUnit.DAYS.between(fromDate, toDate);
            
            // Tính khoảng thời gian kỳ trước
            java.time.LocalDate prevToDate = fromDate.minusDays(1);
            java.time.LocalDate prevFromDate = prevToDate.minusDays(daysDiff);
            
            String sql = "SELECT CONVERT(VARCHAR, CONVERT(DATE, OrderDate), 103) as OrderDate, " +
                        "SUM(TotalPrice) as DailyRevenue, " +
                        "COUNT(*) as OrderCount " +
                        "FROM [Order] " +
                        "WHERE OrderDate >= ? AND OrderDate <= ? AND Status = 3 " +
                        "GROUP BY CONVERT(DATE, OrderDate) " +
                        "ORDER BY CONVERT(DATE, OrderDate)";
            
            try (Connection conn = getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {
                
                ps.setString(1, prevFromDate.toString());
                ps.setString(2, prevToDate.toString() + " 23:59:59");
                
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    DailyRevenue daily = new DailyRevenue(
                        rs.getString("OrderDate"),
                        rs.getDouble("DailyRevenue"),
                        rs.getInt("OrderCount")
                    );
                    dailyRevenue.add(daily);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error getting previous period daily revenue", e);
        }
        return dailyRevenue;
    }

    /**
     * Tính tỷ lệ tăng trưởng so với kỳ trước
     */
    public double getRevenueGrowth(String dateFrom, String dateTo, String branch) {
        // Tính số ngày trong khoảng thời gian hiện tại
        String currentPeriodSql = "SELECT ISNULL(SUM(TotalPrice), 0) as CurrentRevenue FROM [Order] " +
                                 "WHERE OrderDate >= ? AND OrderDate <= ? AND Status = 3";
        
        // Tính doanh thu kỳ trước (cùng số ngày)
        String previousPeriodSql = "SELECT ISNULL(SUM(TotalPrice), 0) as PreviousRevenue FROM [Order] " +
                                  "WHERE OrderDate >= DATEADD(DAY, -DATEDIFF(DAY, ?, ?), ?) " +
                                  "AND OrderDate < ? AND Status = 3";
        
        try (Connection conn = getConnection()) {
            double currentRevenue = 0;
            double previousRevenue = 0;
            
            // Lấy doanh thu kỳ hiện tại
            try (PreparedStatement ps = conn.prepareStatement(currentPeriodSql)) {
                ps.setString(1, dateFrom);
                ps.setString(2, dateTo + " 23:59:59");
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    currentRevenue = rs.getDouble("CurrentRevenue");
                }
            }
            
            // Lấy doanh thu kỳ trước
            try (PreparedStatement ps = conn.prepareStatement(previousPeriodSql)) {
                ps.setString(1, dateFrom);
                ps.setString(2, dateTo);
                ps.setString(3, dateFrom);
                ps.setString(4, dateFrom);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    previousRevenue = rs.getDouble("PreviousRevenue");
                }
            }
            
            // Tính tỷ lệ tăng trưởng
            if (previousRevenue > 0) {
                return ((currentRevenue - previousRevenue) / previousRevenue) * 100;
            }
            
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error calculating revenue growth", e);
        }
        return 0.0;
    }

    /**
     * Lấy tất cả dữ liệu báo cáo
     */
    public SalesReportData getSalesReportData(String dateFrom, String dateTo, String branch) {
        double totalRevenue = getTotalRevenue(dateFrom, dateTo, branch);
        int totalOrders = getTotalOrders(dateFrom, dateTo, branch);
        int totalCustomers = getTotalCustomers(dateFrom, dateTo, branch);
        double avgOrderValue = totalOrders > 0 ? totalRevenue / totalOrders : 0;
        double growthRate = getRevenueGrowth(dateFrom, dateTo, branch);
        List<TopProduct> topProducts = getTopProducts(dateFrom, dateTo, branch, 5);
        List<DailyRevenue> dailyRevenue = getDailyRevenue(dateFrom, dateTo, branch);
        List<DailyRevenue> previousPeriodDailyRevenue = getPreviousPeriodDailyRevenue(dateFrom, dateTo, branch);
        
        SalesReportData data = new SalesReportData(totalRevenue, totalOrders, totalCustomers, 
                                  avgOrderValue, growthRate, topProducts, dailyRevenue);
        data.setPreviousPeriodDailyRevenue(previousPeriodDailyRevenue);
        return data;
    }
}