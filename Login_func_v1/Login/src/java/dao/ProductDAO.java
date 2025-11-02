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
            rs.getBoolean("IsAvailable"),
            rs.getInt("StockQuantity") // ✅ SỬA: Thêm StockQuantity
        );
    }

    // Lấy tất cả sản phẩm
    public List<Product> getAllProducts() {
        List<Product> list = new ArrayList<>();
        // ✅ SỬA: Thêm StockQuantity vào câu lệnh SELECT
        String sql = "SELECT * FROM Products WHERE IsAvailable = 1 ORDER BY Category, ProductName";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
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
        // ✅ SỬA: Thêm StockQuantity vào câu lệnh SELECT
        String sql = "SELECT * FROM Products WHERE ProductID = ?"; // Tạm bỏ IsAvailable để admin có thể xem sản phẩm đã ẩn
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
    
    // ... (Các hàm getProductsByCategory, getAllCategories tương tự)

    // Thêm sản phẩm mới
    public boolean addProduct(Product product) {
        // ✅ SỬA: Thêm StockQuantity vào câu lệnh INSERT
        String sql = "INSERT INTO Products (ProductName, Description, Price, Category, ImageURL, IsAvailable, StockQuantity) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, product.getProductName());
            ps.setString(2, product.getDescription());
            ps.setDouble(3, product.getPrice());
            ps.setString(4, product.getCategory());
            ps.setString(5, product.getImageUrl());
            ps.setBoolean(6, product.isAvailable());
            ps.setInt(7, product.getStockQuantity()); // ✅ SỬA: Thêm tham số StockQuantity
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // Cập nhật sản phẩm
    public boolean updateProduct(Product product) {
        // ✅ SỬA: Thêm StockQuantity vào câu lệnh UPDATE
        String sql = "UPDATE Products SET ProductName=?, Description=?, Price=?, Category=?, ImageURL=?, IsAvailable=?, StockQuantity=? WHERE ProductID=?";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, product.getProductName());
            ps.setString(2, product.getDescription());
            ps.setDouble(3, product.getPrice());
            ps.setString(4, product.getCategory());
            ps.setString(5, product.getImageUrl());
            ps.setBoolean(6, product.isAvailable());
            ps.setInt(7, product.getStockQuantity()); // ✅ SỬA: Thêm tham số StockQuantity
            ps.setInt(8, product.getProductId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // ... (Hàm deleteProduct và getAllCategories không cần thay đổi)
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
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                categories.add(rs.getString("Category"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return categories;
    }
<<<<<<< Updated upstream
}
=======

    return map;
}

    // ===== CHATBOT-SPECIFIC METHODS =====
    
    /**
     * Get products by category with availability filter
     * Used by chatbot to show menu items by category
     * 
     * @param category Product category
     * @param availableOnly If true, only return available products
     * @return List of products in the category
     */
    public List<Product> getProductsByCategory(String category, boolean availableOnly) {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT * FROM Product WHERE Category = ?";
        
        if (availableOnly) {
            sql += " AND IsAvailable = 1";
        }
        
        sql += " ORDER BY ProductName";
        
        try (Connection con = getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, category);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToProduct(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
    
    /**
     * Search products by keyword in name or description
     * Used by chatbot to find products based on user queries
     * 
     * @param keyword Search keyword
     * @return List of matching products
     */
    public List<Product> searchProducts(String keyword) {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT * FROM Product " +
                     "WHERE (ProductName LIKE ? OR Description LIKE ?) " +
                     "AND IsAvailable = 1 " +
                     "ORDER BY ProductName";
        
        try (Connection con = getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {
            String searchPattern = "%" + keyword + "%";
            ps.setString(1, searchPattern);
            ps.setString(2, searchPattern);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToProduct(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
    
    /**
     * Get popular products (most ordered)
     * Used by chatbot for recommendations
     * 
     * @param limit Maximum number of products to return
     * @return List of popular products
     */
    public List<Product> getPopularProducts(int limit) {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT TOP (?) p.* " +
                     "FROM Product p " +
                     "LEFT JOIN OrderDetails od ON p.ProductID = od.ProductID " +
                     "WHERE p.IsAvailable = 1 " +
                     "GROUP BY p.ProductID, p.ProductName, p.Description, p.Price, " +
                     "         p.Category, p.ImageURL, p.IsAvailable " +
                     "ORDER BY COUNT(od.OrderDetailID) DESC";
        
        try (Connection con = getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, limit);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToProduct(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        // If no order history, return random available products
        if (list.isEmpty()) {
            String fallbackSql = "SELECT TOP (?) * FROM Product " +
                                "WHERE IsAvailable = 1 " +
                                "ORDER BY NEWID()";
            try (Connection con = getConnection(); 
                 PreparedStatement ps = con.prepareStatement(fallbackSql)) {
                ps.setInt(1, limit);
                
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        list.add(mapResultSetToProduct(rs));
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        
        return list;
    }
    
    /**
     * Get all distinct categories
     * Used by chatbot to show available categories
     * 
     * @return List of category names
     */
    public List<String> getAllCategories() {
        List<String> categories = new ArrayList<>();
        String sql = "SELECT DISTINCT Category FROM Product " +
                     "WHERE IsAvailable = 1 AND Category IS NOT NULL " +
                     "ORDER BY Category";
        
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
    
    /**
     * Get products by multiple IDs
     * Used by chatbot to fetch specific products
     * 
     * @param productIds List of product IDs
     * @return List of products
     */
    public List<Product> getProductsByIds(List<Integer> productIds) {
        List<Product> list = new ArrayList<>();
        
        if (productIds == null || productIds.isEmpty()) {
            return list;
        }
        
        // Build IN clause
        StringBuilder sql = new StringBuilder("SELECT * FROM Product WHERE ProductID IN (");
        for (int i = 0; i < productIds.size(); i++) {
            sql.append("?");
            if (i < productIds.size() - 1) {
                sql.append(",");
            }
        }
        sql.append(")");
        
        try (Connection con = getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            
            for (int i = 0; i < productIds.size(); i++) {
                ps.setInt(i + 1, productIds.get(i));
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToProduct(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

}
>>>>>>> Stashed changes
