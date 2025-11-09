package dao;

import models.OrderDetailTopping;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class OrderDetailToppingDAO extends DBContext {
    private Connection conn;

    public OrderDetailToppingDAO() {
    }
    
    public OrderDetailToppingDAO(Connection conn) {
        this.conn = conn;
    }

    // Add topping to order detail (Schema mới: ProductSizeID + ProductPrice)
    public boolean addToppingToOrderDetail(int orderDetailID, int productSizeID, double productPrice) throws SQLException {
        String sql = "INSERT INTO OrderDetailTopping (OrderDetailID, ProductSizeID, ProductPrice) VALUES (?, ?, ?)";
        
        Connection connection = (conn != null) ? conn : getConnection();
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, orderDetailID);
            ps.setInt(2, productSizeID);
            ps.setDouble(3, productPrice);
            int result = ps.executeUpdate();
            System.out.println("✅ Topping added to OrderDetail: " + orderDetailID);
            return result > 0;
        } catch (SQLException e) {
            System.err.println("❌ Error adding topping to order detail: " + e.getMessage());
            return false;
        } finally {
            if (conn == null && connection != null) {
                try { connection.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }

    // Get toppings for an order detail (Schema mới)
    public List<OrderDetailTopping> getToppingsByOrderDetailID(int orderDetailID) throws SQLException {
        List<OrderDetailTopping> list = new ArrayList<>();
        String sql = """
            SELECT odt.*, 
                   p.ProductName AS ToppingName,
                   ps.SizeName,
                   ps.SizeCode
            FROM OrderDetailTopping odt
            JOIN ProductSize ps ON odt.ProductSizeID = ps.ProductSizeID
            JOIN Product p ON ps.ProductID = p.ProductID
            WHERE odt.OrderDetailID = ?
        """;
        
        Connection connection = (conn != null) ? conn : getConnection();
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, orderDetailID);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                OrderDetailTopping odt = new OrderDetailTopping();
                odt.setOrderDetailToppingID(rs.getInt("OrderDetailToppingID"));
                odt.setOrderDetailID(rs.getInt("OrderDetailID"));
                odt.setProductSizeID(rs.getInt("ProductSizeID"));
                odt.setProductPrice(rs.getDouble("ProductPrice"));
                odt.setToppingName(rs.getString("ToppingName"));
                odt.setSizeName(rs.getString("SizeName"));
                list.add(odt);
            }
        } catch (SQLException e) {
            System.err.println("❌ Error getting toppings for order detail: " + e.getMessage());
        } finally {
            if (conn == null && connection != null) {
                try { connection.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
        return list;
    }

    // Get total topping price for an order detail
    public double getTotalToppingPrice(int orderDetailID) throws SQLException {
        String sql = "SELECT ISNULL(SUM(ProductPrice), 0) as TotalToppingPrice " +
                     "FROM OrderDetailTopping WHERE OrderDetailID = ?";
        
        Connection connection = (conn != null) ? conn : getConnection();
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, orderDetailID);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getDouble("TotalToppingPrice");
            }
        } catch (SQLException e) {
            System.err.println("❌ Error getting total topping price: " + e.getMessage());
        } finally {
            if (conn == null && connection != null) {
                try { connection.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
        return 0;
    }

    // Count toppings for an order detail
    public int countToppingsForOrderDetail(int orderDetailID) throws SQLException {
        String sql = "SELECT COUNT(*) as ToppingCount FROM OrderDetailTopping WHERE OrderDetailID = ?";
        
        Connection connection = (conn != null) ? conn : getConnection();
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, orderDetailID);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("ToppingCount");
            }
        } catch (SQLException e) {
            System.err.println("❌ Error counting toppings: " + e.getMessage());
        } finally {
            if (conn == null && connection != null) {
                try { connection.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
        return 0;
    }

    // Delete all toppings for an order detail
    public boolean deleteToppingsByOrderDetailID(int orderDetailID) throws SQLException {
        String sql = "DELETE FROM OrderDetailTopping WHERE OrderDetailID = ?";
        
        Connection connection = (conn != null) ? conn : getConnection();
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, orderDetailID);
            ps.executeUpdate();
            System.out.println("✅ Toppings deleted for OrderDetail: " + orderDetailID);
            return true;
        } catch (SQLException e) {
            System.err.println("❌ Error deleting toppings: " + e.getMessage());
            return false;
        } finally {
            if (conn == null && connection != null) {
                try { connection.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }
}
