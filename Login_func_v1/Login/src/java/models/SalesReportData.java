package models;

import java.util.List;

public class SalesReportData {
    private double totalRevenue;
    private int totalOrders;
    private int totalCustomers;
    private double avgOrderValue;
    private double growthRate;
    private List<TopProduct> topProducts;
    private List<DailyRevenue> dailyRevenue;

    public SalesReportData() {
    }

    public SalesReportData(double totalRevenue, int totalOrders, int totalCustomers, 
                          double avgOrderValue, double growthRate, 
                          List<TopProduct> topProducts, List<DailyRevenue> dailyRevenue) {
        this.totalRevenue = totalRevenue;
        this.totalOrders = totalOrders;
        this.totalCustomers = totalCustomers;
        this.avgOrderValue = avgOrderValue;
        this.growthRate = growthRate;
        this.topProducts = topProducts;
        this.dailyRevenue = dailyRevenue;
    }

    // Getters and Setters
    public double getTotalRevenue() {
        return totalRevenue;
    }

    public void setTotalRevenue(double totalRevenue) {
        this.totalRevenue = totalRevenue;
    }

    public int getTotalOrders() {
        return totalOrders;
    }

    public void setTotalOrders(int totalOrders) {
        this.totalOrders = totalOrders;
    }

    public int getTotalCustomers() {
        return totalCustomers;
    }

    public void setTotalCustomers(int totalCustomers) {
        this.totalCustomers = totalCustomers;
    }

    public double getAvgOrderValue() {
        return avgOrderValue;
    }

    public void setAvgOrderValue(double avgOrderValue) {
        this.avgOrderValue = avgOrderValue;
    }

    public double getGrowthRate() {
        return growthRate;
    }

    public void setGrowthRate(double growthRate) {
        this.growthRate = growthRate;
    }

    public List<TopProduct> getTopProducts() {
        return topProducts;
    }

    public void setTopProducts(List<TopProduct> topProducts) {
        this.topProducts = topProducts;
    }

    public List<DailyRevenue> getDailyRevenue() {
        return dailyRevenue;
    }

    public void setDailyRevenue(List<DailyRevenue> dailyRevenue) {
        this.dailyRevenue = dailyRevenue;
    }

    @Override
    public String toString() {
        return "SalesReportData{" +
                "totalRevenue=" + totalRevenue +
                ", totalOrders=" + totalOrders +
                ", totalCustomers=" + totalCustomers +
                ", avgOrderValue=" + avgOrderValue +
                ", growthRate=" + growthRate +
                ", topProducts=" + topProducts +
                ", dailyRevenue=" + dailyRevenue +
                '}';
    }
}