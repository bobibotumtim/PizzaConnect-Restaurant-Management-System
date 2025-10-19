package dao;

import models.ProductIngredient;
import java.sql.*;
import java.util.*;

public class ProductIngredientDAO extends DBContext {

    public List<ProductIngredient> getIngredientsByProduct(int productId) {
        List<ProductIngredient> list = new ArrayList<>();
        String sql = """
            SELECT pi.ProductID, pi.InventoryID, pi.QuantityNeeded, pi.Unit, i.ItemName
            FROM ProductIngredients pi
            JOIN Inventory i ON pi.InventoryID = i.InventoryID
            WHERE pi.ProductID = ?
        """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
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

    public boolean updateIngredient(ProductIngredient pi) {
        String sql = "UPDATE ProductIngredients SET QuantityNeeded=?, Unit=? WHERE ProductID=? AND InventoryID=?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
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
}
