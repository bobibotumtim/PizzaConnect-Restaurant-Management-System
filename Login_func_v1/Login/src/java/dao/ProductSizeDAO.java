package dao;

import java.sql.Statement;
import models.ProductSize;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import models.ProductIngredient;

public class ProductSizeDAO extends DBContext {

    // Hàm này (chỉ đọc) có thể tự quản lý Connection
    public List<ProductSize> getSizesByProductId(int productId) {
        List<ProductSize> list = new ArrayList<>();
        String sql = "SELECT * FROM ProductSize WHERE ProductID = ? AND IsDeleted = 0";
        try (Connection con = getConnection(); // Tự quản lý
                 PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    // (Code map ResultSet to ProductSize...)
                    ProductSize psz = new ProductSize();
                    psz.setProductSizeId(rs.getInt("ProductSizeID"));
                    psz.setProductId(rs.getInt("ProductID"));
                    psz.setSizeCode(rs.getString("SizeCode"));
                    psz.setPrice(rs.getDouble("Price"));
                    list.add(psz);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * ✅ MỚI: Lấy sizes có sẵn cho POS (chỉ size có AvailableQuantity > 0)
     * Sử dụng VIEW v_ProductSizeAvailable để check inventory
     */
    public List<ProductSize> getAvailableSizesByProductId(int productId) {
        List<ProductSize> list = new ArrayList<>();
        String sql = """
            SELECT 
                v.ProductSizeID,
                v.ProductID,
                v.SizeCode,
                v.Price,
                v.AvailableQuantity
            FROM v_ProductSizeAvailable v
            WHERE v.ProductID = ?
              AND v.AvailableQuantity > 0
            ORDER BY 
                CASE v.SizeCode
                    WHEN 'S' THEN 1
                    WHEN 'M' THEN 2
                    WHEN 'L' THEN 3
                    WHEN 'F' THEN 4
                    ELSE 5
                END
        """;
        
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ProductSize psz = new ProductSize();
                    psz.setProductSizeId(rs.getInt("ProductSizeID"));
                    psz.setProductId(rs.getInt("ProductID"));
                    psz.setSizeCode(rs.getString("SizeCode"));
                    psz.setPrice(rs.getDouble("Price"));
                    psz.setAvailableQuantity(rs.getDouble("AvailableQuantity")); // ✅ SET AvailableQuantity
                    list.add(psz);
                }
            }
            System.out.println("✅ ProductSizeDAO.getAvailableSizesByProductId(" + productId + ") returned " + list.size() + " sizes");
        } catch (Exception e) {
            System.err.println("❌ Error in getAvailableSizesByProductId: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Thêm ProductSize và trả về ID mới (tự quản lý connection)
     */
    public int addProductSize(ProductSize size) {
        String sql = "INSERT INTO ProductSize (ProductID, SizeCode, Price) VALUES (?, ?, ?)";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, size.getProductId());
            ps.setString(2, size.getSizeCode());
            ps.setDouble(3, size.getPrice());

            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1); // Trả về ProductSizeID
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1; // Thất bại
    }

    // Hàm này (thay đổi CSDL) phải nhận Connection và ném lỗi
    public boolean deleteProductSizeByProductId(int productSizeId) {
        String sql = "UPDATE ProductSize SET IsDeleted = 1 WHERE ProductSizeID = ?";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, productSizeId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Get ProductSize by ID (for validation and general use)
    public ProductSize getProductSizeById(int productSizeId) {
        String sql = "SELECT * FROM ProductSize WHERE ProductSizeID = ? AND IsDeleted = 0";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, productSizeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    ProductSize psz = new ProductSize();
                    psz.setProductSizeId(rs.getInt("ProductSizeID"));
                    psz.setProductId(rs.getInt("ProductID"));
                    psz.setSizeCode(rs.getString("SizeCode"));
                    psz.setPrice(rs.getDouble("Price"));
                    return psz;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Cập nhật thông tin cơ bản của Size (tự quản lý connection)
     */
    public boolean updateProductSize(ProductSize size) {
        String sql = "UPDATE ProductSize SET SizeCode = ?, Price = ? WHERE ProductSizeID = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, size.getSizeCode());
            ps.setDouble(2, size.getPrice());
            ps.setInt(3, size.getProductSizeId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Check if size exists for product (for validation)
    public boolean isSizeExistsForProduct(int productId, String sizeName, Integer excludeId) {
        String sql = "SELECT COUNT(*) FROM ProductSize WHERE ProductID = ? AND SizeCode = ? AND IsDeleted = 0";
        if (excludeId != null) {
            sql += " AND ProductSizeID != ?";
        }
        
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, productId);
            ps.setString(2, sizeName);
            if (excludeId != null) {
                ps.setInt(3, excludeId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}
