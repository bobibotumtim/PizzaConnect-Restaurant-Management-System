package dao;

import java.sql.Statement;
import models.ProductSize;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

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

    // Hàm này (thay đổi CSDL) phải nhận Connection và ném lỗi
    public int addProductSize(ProductSize size, Connection con) throws SQLException {
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
        String sql = "SELECT * FROM ProductSize WHERE ProductSizeID = ?";
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
