package models;

public class DailyRevenue {
    private String date;
    private double revenue;
    private int orders;

    public DailyRevenue() {
    }

    public DailyRevenue(String date, double revenue, int orders) {
        this.date = date;
        this.revenue = revenue;
        this.orders = orders;
    }

    // Getters and Setters
    public String getDate() {
        return date;
    }

    public void setDate(String date) {
        this.date = date;
    }

    public double getRevenue() {
        return revenue;
    }

    public void setRevenue(double revenue) {
        this.revenue = revenue;
    }

    public int getOrders() {
        return orders;
    }

    public void setOrders(int orders) {
        this.orders = orders;
    }

    @Override
    public String toString() {
        return "DailyRevenue{" +
                "date='" + date + '\'' +
                ", revenue=" + revenue +
                ", orders=" + orders +
                '}';
    }
}