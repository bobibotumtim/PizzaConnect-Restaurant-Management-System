package dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import models.Product;

public class ProductDAO extends DBContext {

    // Helper method để tránh lặp code
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

    // Lấy tất cả sản phẩm
    public List<Product> getAllProducts() {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT * FROM Products WHERE IsAvailable = 1 ORDER BY Category, ProductName";
        try (Connection con = getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql); 
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSetToProduct(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Lấy sản phẩm theo ID
    public Product getProductById(int productId) {
        String sql = "SELECT * FROM Products WHERE ProductID = ?";
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

    // Thêm sản phẩm mới
    public boolean addProduct(Product product) {
        String sql = "INSERT INTO Products (ProductName, Description, Price, Category, ImageURL, IsAvailable) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, product.getProductName());
            ps.setString(2, product.getDescription());
            ps.setDouble(3, product.getPrice());
            ps.setString(4, product.getCategory());
            ps.setString(5, product.getImageUrl());
            ps.setBoolean(6, product.isAvailable());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // Cập nhật sản phẩm
    public boolean updateProduct(Product product) {
        String sql = "UPDATE Products SET ProductName=?, Description=?, Price=?, Category=?, ImageURL=?, IsAvailable=? WHERE ProductID=?";
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

    // Xóa sản phẩm (soft delete)
    public boolean deleteProduct(int productId) {
        String sql = "UPDATE Products SET IsAvailable = 0 WHERE ProductID = ?";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, productId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // Lấy tất cả danh mục
    public List<String> getAllCategories() {
        List<String> categories = new ArrayList<>();
        String sql = "SELECT DISTINCT Category FROM Products WHERE IsAvailable = 1 ORDER BY Category";
        try (Connection con = getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql); 
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                categories.add(rs.getString("Category"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return categories;
    }
}
