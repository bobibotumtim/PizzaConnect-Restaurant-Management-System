package dao;

import models.OrderDetailTopping;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class OrderDetailToppingDAO {
    private Connection conn;

    public OrderDetailToppingDAO() {
        try {
            conn = new DBContext().getConnection();
        } catch (Exception e) {
            System.err.println("❌ OrderDetailToppingDAO Connection Error: " + e.getMessage());
        }
    }

    // Add topping to order detail (now using ProductSizeID)
    public boolean addToppingToOrderDetail(int orderDetailID, int productSizeID, double toppingPrice) {
        String sql = "INSERT INTO OrderDetailTopping (OrderDetailID, ProductSizeID, ProductPrice) VALUES (?, ?, ?)";
        
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderDetailID);
            ps.setInt(2, productSizeID);
            ps.setDouble(3, toppingPrice);
            int result = ps.executeUpdate();
            System.out.println("✅ Topping added to OrderDetail: " + orderDetailID);
            return result > 0;
        } catch (SQLException e) {
            System.err.println("❌ Error adding topping to order detail: " + e.getMessage());
            return false;
        }
    }

    // Get toppings for an order detail (now using ProductSizeID)
    public List<OrderDetailTopping> getToppingsByOrderDetailID(int orderDetailID) {
        List<OrderDetailTopping> list = new ArrayList<>();
        String sql = "SELECT odt.*, p.ProductName as ToppingName " +
                     "FROM OrderDetailTopping odt " +
                     "JOIN ProductSize ps ON odt.ProductSizeID = ps.ProductSizeID " +
                     "JOIN Product p ON ps.ProductID = p.ProductID " +
                     "WHERE odt.OrderDetailID = ?";
        
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderDetailID);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                OrderDetailTopping odt = new OrderDetailTopping();
                odt.setOrderDetailToppingID(rs.getInt("OrderDetailToppingID"));
                odt.setOrderDetailID(rs.getInt("OrderDetailID"));
                odt.setToppingID(rs.getInt("ProductSizeID")); // Now using ProductSizeID
                odt.setToppingPrice(rs.getDouble("ProductPrice"));
                odt.setToppingName(rs.getString("ToppingName"));
                list.add(odt);
            }
        } catch (SQLException e) {
            System.err.println("❌ Error getting toppings for order detail: " + e.getMessage());
        }
        return list;
    }

    // Get total topping price for an order detail
    public double getTotalToppingPrice(int orderDetailID) {
        String sql = "SELECT ISNULL(SUM(ProductPrice), 0) as TotalToppingPrice " +
                     "FROM OrderDetailTopping WHERE OrderDetailID = ?";
        
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderDetailID);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getDouble("TotalToppingPrice");
            }
        } catch (SQLException e) {
            System.err.println("❌ Error getting total topping price: " + e.getMessage());
        }
        return 0;
    }

    // Count toppings for an order detail
    public int countToppingsForOrderDetail(int orderDetailID) {
        String sql = "SELECT COUNT(*) as ToppingCount FROM OrderDetailTopping WHERE OrderDetailID = ?";
        
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderDetailID);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("ToppingCount");
            }
        } catch (SQLException e) {
            System.err.println("❌ Error counting toppings: " + e.getMessage());
        }
        return 0;
    }

    // Delete all toppings for an order detail
    public boolean deleteToppingsByOrderDetailID(int orderDetailID) {
        String sql = "DELETE FROM OrderDetailTopping WHERE OrderDetailID = ?";
        
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderDetailID);
            ps.executeUpdate();
            System.out.println("✅ Toppings deleted for OrderDetail: " + orderDetailID);
            return true;
        } catch (SQLException e) {
            System.err.println("❌ Error deleting toppings: " + e.getMessage());
            return false;
        }
    }
}
