package dao;

import java.sql.Statement;
import models.ProductSize;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
<<<<<<< Updated upstream
import java.util.List;
=======
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import models.ProductIngredient;
>>>>>>> Stashed changes

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

<<<<<<< Updated upstream
    // Hàm này (thay đổi CSDL) phải nhận Connection và ném lỗi
    public int addProductSize(ProductSize size, Connection con) throws SQLException {
=======
    /**
     * ✅ MỚI: Lấy sizes có sẵn cho POS
     * Sử dụng VIEW v_ProductSizeAvailable để check inventory
     * 
     * Logic:
     * - Nếu size KHÔNG có trong view → Không có ingredients → Hiển thị unlimited (999)
     * - Nếu size CÓ trong view → Có ingredients → Hiển thị số lượng thực tế (kể cả 0)
     */
    public List<ProductSize> getAvailableSizesByProductId(int productId) {
        List<ProductSize> list = new ArrayList<>();
        
        // Bước 1: Lấy TẤT CẢ sizes của product (kể cả không có ingredients)
        String sqlAllSizes = """
            SELECT 
                ps.ProductSizeID,
                ps.ProductID,
                ps.SizeCode,
                ps.Price
            FROM ProductSize ps
            WHERE ps.ProductID = ?
              AND ps.IsDeleted = 0
            ORDER BY 
                CASE ps.SizeCode
                    WHEN 'S' THEN 1
                    WHEN 'M' THEN 2
                    WHEN 'L' THEN 3
                    WHEN 'F' THEN 4
                    ELSE 5
                END
        """;
        
        // Bước 2: Lấy AvailableQuantity từ view (chỉ có sizes có ingredients)
        String sqlAvailQty = """
            SELECT 
                ProductSizeID,
                AvailableQuantity
            FROM v_ProductSizeAvailable
            WHERE ProductID = ?
        """;
        
        try (Connection con = getConnection()) {
            // Lấy tất cả sizes
            Map<Integer, ProductSize> sizeMap = new HashMap<>();
            try (PreparedStatement ps = con.prepareStatement(sqlAllSizes)) {
                ps.setInt(1, productId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        ProductSize psz = new ProductSize();
                        psz.setProductSizeId(rs.getInt("ProductSizeID"));
                        psz.setProductId(rs.getInt("ProductID"));
                        psz.setSizeCode(rs.getString("SizeCode"));
                        psz.setPrice(rs.getDouble("Price"));
                        psz.setAvailableQuantity(999); // Default: unlimited
                        sizeMap.put(psz.getProductSizeId(), psz);
                    }
                }
            }
            
            // Cập nhật AvailableQuantity cho sizes có ingredients
            try (PreparedStatement ps = con.prepareStatement(sqlAvailQty)) {
                ps.setInt(1, productId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        int sizeId = rs.getInt("ProductSizeID");
                        double availQty = rs.getDouble("AvailableQuantity");
                        
                        ProductSize psz = sizeMap.get(sizeId);
                        if (psz != null) {
                            // Size có trong view → Có ingredients → Dùng số lượng thực tế
                            psz.setAvailableQuantity(availQty);
                            System.out.println("🔍 ProductSizeID=" + sizeId + 
                                             ", SizeCode=" + psz.getSizeCode() + 
                                             ", AvailableQuantity=" + availQty + " (has ingredients)");
                        }
                    }
                }
            }
            
            // Thêm vào list
            list.addAll(sizeMap.values());
            
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
>>>>>>> Stashed changes
        String sql = "INSERT INTO ProductSize (ProductID, SizeCode, Price) VALUES (?, ?, ?)";
        try (PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, size.getProductId());
            ps.setString(2, size.getSizeCode());
            ps.setDouble(3, size.getPrice());

            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1); // Trả về ProductSizeID
                } else {
                    throw new SQLException("Thêm ProductSize thất bại, không lấy được ID.");
                }
            }
        }
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

    public ProductSize getSizeById(int productSizeId) {
        String sql = "SELECT ps.*, p.ProductName FROM ProductSize ps LEFT JOIN Product p ON ps.ProductID = p.ProductID WHERE ps.ProductSizeID = ?";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

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
    
    // Lấy ProductSize với thông tin Product để hiển thị
    public ProductSize getSizeWithProductInfo(int productSizeId) {
        String sql = """
            SELECT ps.*, p.ProductName, p.Description, c.CategoryName
            FROM ProductSize ps 
            LEFT JOIN Product p ON ps.ProductID = p.ProductID
            LEFT JOIN Category c ON p.CategoryID = c.CategoryID
            WHERE ps.ProductSizeID = ? AND ps.IsDeleted = 0
        """;
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
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
     * MỚI: Cập nhật thông tin cơ bản của Size (Hàm này (thay đổi CSDL) phải
     * nhận Connection và ném lỗi)
     */
    public boolean updateProductSize(ProductSize size, Connection con) throws SQLException {
        String sql = "UPDATE ProductSize SET SizeCode = ?, Price = ? WHERE ProductSizeID = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, size.getSizeCode());
            ps.setDouble(2, size.getPrice());
            ps.setInt(3, size.getProductSizeId());
            return ps.executeUpdate() > 0;
        }
        // Ném lỗi ra ngoài để Service rollback
    }
}
