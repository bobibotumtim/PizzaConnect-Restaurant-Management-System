package dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import models.Product;

public class ProductDAO extends DBContext {

    // Map ResultSet to Product object
    private Product mapResultSetToProduct(ResultSet rs) throws SQLException {
        return new Product(
                rs.getInt("ProductID"),
                rs.getString("ProductName"),
                rs.getString("Description"),
                rs.getDouble("Price"),
                rs.getString("Category"),
                rs.getString("ImageURL"),
                rs.getBoolean("IsAvailable")
        );
    }

    // Get all available products
    public List<Product> getAllProducts() {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT * FROM Product WHERE IsAvailable = 1 ORDER BY Category, ProductName";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSetToProduct(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Get product by ID
    public Product getProductById(int productId) {
        String sql = "SELECT * FROM Product WHERE ProductID = ?";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToProduct(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // Add new product
    public int addProduct(Product product) {
        String sql = "INSERT INTO Product (ProductName, Description, Price, Category, ImageURL, IsAvailable) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, product.getProductName());
            ps.setString(2, product.getDescription());
            ps.setDouble(3, product.getPrice());
            ps.setString(4, product.getCategory());
            ps.setString(5, product.getImageUrl());
            ps.setBoolean(6, product.isAvailable());

            int affectedRows = ps.executeUpdate();
            if (affectedRows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    // Update product
    public boolean updateProduct(Product product) {
        String sql = "UPDATE Product SET ProductName=?, Description=?, Price=?, Category=?, ImageURL=?, IsAvailable=? WHERE ProductID=?";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, product.getProductName());
            ps.setString(2, product.getDescription());
            ps.setDouble(3, product.getPrice());
            ps.setString(4, product.getCategory());
            ps.setString(5, product.getImageUrl());
            ps.setBoolean(6, product.isAvailable());
            ps.setInt(7, product.getProductId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // Delete product (soft delete)
    public boolean deleteProduct(int productId) {
        String sql = "UPDATE Product SET IsAvailable = 0 WHERE ProductID = ? AND IsAvailable = 1";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, productId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // Get product availability map
    public Map<Integer, Double> getProductAvailability() {
    Map<Integer, Double> map = new HashMap<>();
    String sql = "SELECT ProductID, AvailableQuantity FROM v_ProductAvailable";

    try (Connection con = getConnection();
         PreparedStatement ps = con.prepareStatement(sql);
         ResultSet rs = ps.executeQuery()) {
        
        while (rs.next()) {
            map.put(rs.getInt("ProductID"), rs.getDouble("AvailableQuantity"));
        }

        System.out.println("✅ Loaded " + map.size() + " entries");
        map.forEach((id, qty) -> System.out.println("ProductID=" + id + " | Qty=" + qty));

    } catch (Exception e) {
        e.printStackTrace();
    }

    return map;
}


}
