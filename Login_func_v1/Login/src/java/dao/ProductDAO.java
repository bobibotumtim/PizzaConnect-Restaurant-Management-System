package dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import models.Product;

public class ProductDAO extends DBContext {

    // Helper map, không thay đổi
    private Product mapResultSetToProduct(ResultSet rs) throws SQLException {
        Product product = new Product();
        product.setProductId(rs.getInt("ProductID"));
        product.setProductName(rs.getString("ProductName"));
        product.setDescription(rs.getString("Description"));
        product.setImageUrl(rs.getString("ImageURL"));
        product.setAvailable(rs.getBoolean("IsAvailable"));
        product.setCategoryName(rs.getString("CategoryName"));
        // Lưu ý: KHÔNG set List<ProductSize> ở đây
        return product;
    }

    // SỬA LẠI: Chỉ lấy danh sách Product cơ bản (không kèm size)
    public List<Product> getAllBaseProducts() {
        List<Product> list = new ArrayList<>();
        String sql = """
            SELECT p.ProductID, p.ProductName, p.Description, c.CategoryName, 
                   p.ImageURL, p.IsAvailable
            FROM Product p
            JOIN Category c ON p.CategoryID = c.CategoryID
            WHERE p.IsAvailable = 1 AND c.IsDeleted = 0
            ORDER BY c.CategoryName, p.ProductName
        """;
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

    // SỬA LẠI: Chỉ lấy 1 Product cơ bản (không kèm size)
    public Product getBaseProductById(int productId) {
        String sql = """
            SELECT p.ProductID, p.ProductName, p.Description, c.CategoryName,
                   p.ImageURL, p.IsAvailable
            FROM Product p
            JOIN Category c ON p.CategoryID = c.CategoryID
            WHERE p.ProductID = ?
        """;
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
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

    // SỬA LẠI: Hàm addProduct chỉ INSERT vào bảng Product
    // Nhận Connection và CategoryID từ Service, ném lỗi ra ngoài
    public int addProduct(Product product, int categoryId, Connection con) throws SQLException {
        String sql = "INSERT INTO Product (ProductName, Description, CategoryID, ImageURL, IsAvailable) VALUES (?, ?, ?, ?, ?)";
        
        try (PreparedStatement psProd = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            psProd.setString(1, product.getProductName());
            psProd.setString(2, product.getDescription());
            psProd.setInt(3, categoryId); // Lấy ID từ Service
            psProd.setString(4, product.getImageUrl());
            psProd.setBoolean(5, product.isAvailable());
            
            int affectedRows = psProd.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("Thêm product thất bại.");
            }

            try (ResultSet rs = psProd.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1); // Trả về ProductID mới
                } else {
                    throw new SQLException("Không lấy được ProductID vừa tạo.");
                }
            }
        }
    }

    // SỬA LẠI: Hàm updateProduct chỉ UPDATE bảng Product
    public boolean updateProduct(Product product, int categoryId, Connection con) throws SQLException {
        String sql = "UPDATE Product SET ProductName=?, Description=?, CategoryID=?, ImageURL=?, IsAvailable=? WHERE ProductID=?";
        try (PreparedStatement psProd = con.prepareStatement(sql)) {
            psProd.setString(1, product.getProductName());
            psProd.setString(2, product.getDescription());
            psProd.setInt(3, categoryId);
            psProd.setString(4, product.getImageUrl());
            psProd.setBoolean(5, product.isAvailable());
            psProd.setInt(6, product.getProductId());
            return psProd.executeUpdate() > 0;
        }
    }

    // Hàm này có thể tự quản lý vì là 1 lệnh UPDATE đơn giản
    public boolean deleteProduct(int productId) {
        String sql = "UPDATE Product SET IsAvailable = 0 WHERE ProductID = ?";
        try (Connection con = getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, productId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // SỬA LẠI: Lấy Map (ProductSizeID -> AvailableQuantity) từ View
    public Map<Integer, Double> getProductSizeAvailabilityMap() {
        Map<Integer, Double> map = new HashMap<>();
        // Lấy từ View mới mà chúng ta đã tạo
        String sql = "SELECT ProductSizeID, AvailableQuantity FROM v_ProductSizeAvailable";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                map.put(rs.getInt("ProductSizeID"), rs.getDouble("AvailableQuantity"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return map;
    }
    
    public boolean updateBaseProduct(Product product, int categoryId, Connection con) throws SQLException {
        String sql = "UPDATE Product SET ProductName=?, Description=?, CategoryID=?, ImageURL=?, IsAvailable=? WHERE ProductID=?";
        try (PreparedStatement psProd = con.prepareStatement(sql)) {
            psProd.setString(1, product.getProductName());
            psProd.setString(2, product.getDescription());
            psProd.setInt(3, categoryId);
            psProd.setString(4, product.getImageUrl());
            psProd.setBoolean(5, product.isAvailable());
            psProd.setInt(6, product.getProductId());
            return psProd.executeUpdate() > 0;
        }
    }

    /**
     * MỚI: Đếm tổng số sản phẩm (để phân trang)
     */
    public int getBaseProductCount(String searchName, String statusFilter) throws SQLException {
        // Xây dựng câu SQL động
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM Product p JOIN Category c ON p.CategoryID = c.CategoryID WHERE c.IsDeleted = 0");
        if (searchName != null && !searchName.isEmpty()) {
            sql.append(" AND p.ProductName LIKE ?");
        }
        if (statusFilter != null && !statusFilter.isEmpty() && !"all".equals(statusFilter)) {
            sql.append(" AND p.IsAvailable = ?");
        }

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            
            int paramIndex = 1;
            if (searchName != null && !searchName.isEmpty()) {
                ps.setString(paramIndex++, "%" + searchName + "%");
            }
            if (statusFilter != null && !statusFilter.isEmpty() && !"all".equals(statusFilter)) {
                ps.setBoolean(paramIndex++, "available".equals(statusFilter));
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    /**
     * MỚI: Lấy sản phẩm cơ bản (đã phân trang và lọc)
     */
    public List<Product> getBaseProductsPaginated(String searchName, String statusFilter, int page, int pageSize) throws SQLException {
        List<Product> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("""
            SELECT p.ProductID, p.ProductName, p.Description, c.CategoryName, p.ImageURL, p.IsAvailable
            FROM Product p JOIN Category c ON p.CategoryID = c.CategoryID
            WHERE c.IsDeleted = 0 
        """);

        // Thêm điều kiện lọc
        if (searchName != null && !searchName.isEmpty()) {
            sql.append(" AND p.ProductName LIKE ?");
        }
        if (statusFilter != null && !statusFilter.isEmpty() && !"all".equals(statusFilter)) {
            sql.append(" AND p.IsAvailable = ?");
        }

        // Thêm phân trang (SQL Server)
        sql.append(" ORDER BY p.ProductID OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            
            int paramIndex = 1;
            if (searchName != null && !searchName.isEmpty()) {
                ps.setString(paramIndex++, "%" + searchName + "%");
            }
            if (statusFilter != null && !statusFilter.isEmpty() && !"all".equals(statusFilter)) {
                ps.setBoolean(paramIndex++, "available".equals(statusFilter));
            }
            
            ps.setInt(paramIndex++, (page - 1) * pageSize);
            ps.setInt(paramIndex++, pageSize);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    // Dùng lại hàm mapResultSetToProduct của bạn
                    list.add(mapResultSetToProduct(rs)); 
                }
            }
        }
        return list;
    }
}