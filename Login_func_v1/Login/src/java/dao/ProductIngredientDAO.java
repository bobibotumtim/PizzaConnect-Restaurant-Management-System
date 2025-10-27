package dao;

import models.ProductIngredient;
import java.sql.*;
import java.util.*;

public class ProductIngredientDAO extends DBContext {

    // Get all inventories for dropdowns
    public List<Map<String, Object>> getAllInventories() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT InventoryID, ItemName, Unit FROM Inventory";
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


    // Get ingredients by product ID
    public List<ProductIngredient> getIngredientsByProduct(int productId) {
        List<ProductIngredient> list = new ArrayList<>();
        String sql = """
            SELECT pi.ProductID, pi.InventoryID, pi.QuantityNeeded, pi.Unit, i.ItemName
            FROM ProductIngredients pi
            JOIN Inventory i ON pi.InventoryID = i.InventoryID
            WHERE pi.ProductID = ?
        """;
        try (Connection connection = getConnection();
            PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ProductIngredient pi = new ProductIngredient();
                    pi.setProductId(rs.getInt("ProductID"));
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

    // Add ingredient to product
    public boolean addIngredientToProduct(int productId, int inventoryId, double quantityNeeded, String unit) {
        String sql = "INSERT INTO ProductIngredients (ProductID, InventoryID, QuantityNeeded, Unit) VALUES (?, ?, ?, ?)";
        try (Connection connection = getConnection();
            PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, productId);
            ps.setInt(2, inventoryId);
            ps.setDouble(3, quantityNeeded);
            ps.setString(4, unit);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Update ingredient for product
    public boolean updateIngredient(ProductIngredient pi) {
        String sql = "UPDATE ProductIngredients SET QuantityNeeded=?, Unit=? WHERE ProductID=? AND InventoryID=?";
        try (Connection connection = getConnection();
            PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setDouble(1, pi.getQuantityNeeded());
            ps.setString(2, pi.getUnit());
            ps.setInt(3, pi.getProductId());
            ps.setInt(4, pi.getInventoryId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Delete ingredient from product
    public boolean deleteIngredientFromProduct(int productId, int inventoryId) {
        String sql = "DELETE FROM ProductIngredients WHERE ProductID=? AND InventoryID=?";
        try (Connection connection = getConnection();
            PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, productId);
            ps.setInt(2, inventoryId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
