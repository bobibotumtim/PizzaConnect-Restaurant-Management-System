package dao;

import models.ProductIngredient;
import java.sql.*;
import java.util.*;

public class ProductIngredientDAO extends DBContext {

    /**
     * Lấy tất cả nguyên liệu trong kho (cho dropdown)
     * (Hàm này chỉ ĐỌC, nên tự quản lý Connection)
     */
    public List<Map<String, Object>> getAllInventories() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT InventoryID, ItemName, Unit FROM Inventory WHERE Quantity > 0 AND Status != 'Inactive'"; // Chỉ lấy hàng còn và đang active
        try (Connection connection = getConnection();
             PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> item = new HashMap<>();
                item.put("inventoryID", rs.getInt("InventoryID"));
                item.put("inventoryName", rs.getString("ItemName"));
                item.put("unit", rs.getString("Unit"));
                list.add(item);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Lấy tất cả thành phần của MỘT size
     * (Hàm này chỉ ĐỌC, nên tự quản lý Connection)
     */
    public List<ProductIngredient> getIngredientsByProductSizeId(int productSizeId) {
        List<ProductIngredient> list = new ArrayList<>();
        String sql = """
            SELECT pi.ProductSizeID, pi.InventoryID, pi.QuantityNeeded, pi.Unit, i.ItemName
            FROM ProductIngredient pi
            JOIN Inventory i ON pi.InventoryID = i.InventoryID
            WHERE pi.ProductSizeID = ?
            ORDER BY i.ItemName
        """;
        try (Connection connection = getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {
            
            ps.setInt(1, productSizeId);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ProductIngredient pi = new ProductIngredient();
                    pi.setProductSizeId(rs.getInt("ProductSizeID"));
                    pi.setInventoryId(rs.getInt("InventoryID"));
                    pi.setQuantityNeeded(rs.getDouble("QuantityNeeded"));
                    pi.setUnit(rs.getString("Unit"));
                    pi.setItemName(rs.getString("ItemName"));
                    list.add(pi);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Thêm MỘT thành phần (tự quản lý connection)
     */
    public boolean addIngredient(ProductIngredient pi) {
        String sql = "INSERT INTO ProductIngredient (ProductSizeID, InventoryID, QuantityNeeded, Unit) VALUES (?, ?, ?, ?)";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, pi.getProductSizeId());
            ps.setInt(2, pi.getInventoryId());
            ps.setDouble(3, pi.getQuantityNeeded());
            ps.setString(4, pi.getUnit());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Xóa TẤT CẢ thành phần của MỘT size (tự quản lý connection)
     */
    public boolean deleteAllIngredientsByProductSizeId(int productSizeId) {
        String sql = "DELETE FROM ProductIngredient WHERE ProductSizeID = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, productSizeId);
            ps.executeUpdate();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    /**
     * Cập nhật thông tin nguyên liệu (tự quản lý connection)
     */
    public boolean updateIngredient(ProductIngredient pi) {
        String sql = "UPDATE ProductIngredient SET QuantityNeeded=?, Unit=? WHERE ProductSizeID=? AND InventoryID=?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setDouble(1, pi.getQuantityNeeded());
            ps.setString(2, pi.getUnit());
            ps.setInt(3, pi.getProductSizeId());
            ps.setInt(4, pi.getInventoryId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Xóa một thành phần (tự quản lý connection)
     */
    public boolean deleteIngredient(int productSizeId, int inventoryId) {
        String sql = "DELETE FROM ProductIngredient WHERE ProductSizeID=? AND InventoryID=?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, productSizeId);
            ps.setInt(2, inventoryId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Check if ingredient exists for product size (for validation)
     */
    public boolean isIngredientExistsForProductSize(int productSizeId, int inventoryId) {
        String sql = "SELECT COUNT(*) FROM ProductIngredient WHERE ProductSizeID = ? AND InventoryID = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, productSizeId);
            ps.setInt(2, inventoryId);
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
    
    /**
     * Check if inventory exists (for validation)
     */
    public boolean isInventoryExists(int inventoryId) {
        String sql = "SELECT COUNT(*) FROM Inventory WHERE InventoryID = ? AND Quantity > 0";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, inventoryId);
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
    
    /**
     * Lấy danh sách nguyên liệu cần trừ cho một ProductSize với số lượng món
     * Trả về Map với key là InventoryID và value là số lượng cần trừ
     */
    public Map<Integer, Double> getIngredientsToDeduct(int productSizeId, int quantity) {
        Map<Integer, Double> ingredientsMap = new HashMap<>();
        String sql = "SELECT InventoryID, QuantityNeeded FROM ProductIngredient WHERE ProductSizeID = ?";
        
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, productSizeId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int inventoryId = rs.getInt("InventoryID");
                    double quantityNeeded = rs.getDouble("QuantityNeeded");
                    ingredientsMap.put(inventoryId, quantityNeeded * quantity);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return ingredientsMap;
    }
}