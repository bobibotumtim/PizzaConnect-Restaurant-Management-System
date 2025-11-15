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
     * Lấy tất cả dữ liệu báo cáo
     */
    public SalesReportData getSalesReportData(String dateFrom, String dateTo, String branch) {
        double totalRevenue = getTotalRevenue(dateFrom, dateTo, branch);
        int totalOrders = getTotalOrders(dateFrom, dateTo, branch);
        int totalCustomers = getTotalCustomers(dateFrom, dateTo, branch);
        double avgOrderValue = totalOrders > 0 ? totalRevenue / totalOrders : 0;
        List<TopProduct> topProducts = getTopProducts(dateFrom, dateTo, branch, 5);
        List<DailyRevenue> dailyRevenue = getDailyRevenue(dateFrom, dateTo, branch);
        
        // Không còn so sánh kỳ trước - chỉ hiển thị dữ liệu thực tế
        SalesReportData data = new SalesReportData(totalRevenue, totalOrders, totalCustomers, 
                                  avgOrderValue, 0.0, topProducts, dailyRevenue);
        return data;
    }
}