package dao;

import models.Topping;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ToppingDAO {
    private Connection conn;

    public ToppingDAO() {
        try {
            conn = new DBContext().getConnection();
        } catch (Exception e) {
            System.err.println("❌ ToppingDAO Connection Error: " + e.getMessage());
        }
    }

    // Get all toppings (from Product + ProductSize where CategoryID = 3)
    public List<Topping> getAllToppings() {
        List<Topping> list = new ArrayList<>();
        String sql = "SELECT ps.ProductSizeID, p.ProductName, ps.Price, p.IsAvailable, p.CreatedDate " +
                     "FROM Product p " +
                     "INNER JOIN ProductSize ps ON p.ProductID = ps.ProductID " +
                     "WHERE p.CategoryID = 3 AND ps.SizeCode = 'F' " +
                     "ORDER BY p.ProductName";
        
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Topping t = new Topping();
                t.setToppingID(rs.getInt("ProductSizeID")); // Now using ProductSizeID
                t.setToppingName(rs.getString("ProductName"));
                t.setPrice(rs.getDouble("Price"));
                t.setAvailable(rs.getBoolean("IsAvailable"));
                t.setCreatedDate(rs.getTimestamp("CreatedDate"));
                list.add(t);
            }
        } catch (SQLException e) {
            System.err.println("❌ Error getting all toppings: " + e.getMessage());
        }
        return list;
    }

    // Get available toppings only
    public List<Topping> getAvailableToppings() {
        List<Topping> list = new ArrayList<>();
        String sql = "SELECT ps.ProductSizeID, p.ProductName, ps.Price, p.IsAvailable " +
                     "FROM Product p " +
                     "INNER JOIN ProductSize ps ON p.ProductID = ps.ProductID " +
                     "WHERE p.CategoryID = 3 AND ps.SizeCode = 'F' AND p.IsAvailable = 1 " +
                     "ORDER BY p.ProductName";
        
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Topping t = new Topping();
                t.setToppingID(rs.getInt("ProductSizeID")); // Now using ProductSizeID
                t.setToppingName(rs.getString("ProductName"));
                t.setPrice(rs.getDouble("Price"));
                t.setAvailable(rs.getBoolean("IsAvailable"));
                list.add(t);
            }
        } catch (SQLException e) {
            System.err.println("❌ Error getting available toppings: " + e.getMessage());
        }
        return list;
    }

    // Get topping by ProductSizeID
    public Topping getToppingByID(int productSizeID) {
        String sql = "SELECT ps.ProductSizeID, p.ProductName, ps.Price, p.IsAvailable, p.CreatedDate " +
                     "FROM Product p " +
                     "INNER JOIN ProductSize ps ON p.ProductID = ps.ProductID " +
                     "WHERE ps.ProductSizeID = ? AND p.CategoryID = 3";
        
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productSizeID);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                Topping t = new Topping();
                t.setToppingID(rs.getInt("ProductSizeID")); // Now using ProductSizeID
                t.setToppingName(rs.getString("ProductName"));
                t.setPrice(rs.getDouble("Price"));
                t.setAvailable(rs.getBoolean("IsAvailable"));
                t.setCreatedDate(rs.getTimestamp("CreatedDate"));
                return t;
            }
        } catch (SQLException e) {
            System.err.println("❌ Error getting topping by ID: " + e.getMessage());
        }
        return null;
    }

    // Add new topping (creates Product + ProductSize)
    public boolean addTopping(String toppingName, double price) {
        String sqlProduct = "INSERT INTO Product (ProductName, Description, CategoryID, ImageURL, IsAvailable) " +
                           "VALUES (?, ?, 3, ?, 1)";
        String sqlProductSize = "INSERT INTO ProductSize (ProductID, SizeCode, SizeName, Price, IsDeleted) " +
                               "VALUES (?, 'F', 'Fixed', ?, 0)";
        
        try {
            conn.setAutoCommit(false);
            
            // Insert Product
            PreparedStatement psProduct = conn.prepareStatement(sqlProduct, Statement.RETURN_GENERATED_KEYS);
            psProduct.setString(1, toppingName);
            psProduct.setString(2, "Topping - " + toppingName);
            psProduct.setString(3, toppingName.toLowerCase().replace(" ", "_") + ".jpg");
            psProduct.executeUpdate();
            
            // Get generated ProductID
            ResultSet rs = psProduct.getGeneratedKeys();
            if (rs.next()) {
                int productID = rs.getInt(1);
                
                // Insert ProductSize
                PreparedStatement psSize = conn.prepareStatement(sqlProductSize);
                psSize.setInt(1, productID);
                psSize.setDouble(2, price);
                psSize.executeUpdate();
                
                conn.commit();
                System.out.println("✅ Topping added: " + toppingName);
                return true;
            }
            
            conn.rollback();
            return false;
        } catch (SQLException e) {
            try {
                conn.rollback();
            } catch (SQLException ex) {
                System.err.println("❌ Rollback error: " + ex.getMessage());
            }
            System.err.println("❌ Error adding topping: " + e.getMessage());
            return false;
        } finally {
            try {
                conn.setAutoCommit(true);
            } catch (SQLException e) {
                System.err.println("❌ Error resetting auto-commit: " + e.getMessage());
            }
        }
    }

    // Update topping (updates Product + ProductSize)
    public boolean updateTopping(int productSizeID, String toppingName, double price, boolean isAvailable) {
        String sqlGetProductID = "SELECT ProductID FROM ProductSize WHERE ProductSizeID = ?";
        String sqlUpdateProduct = "UPDATE Product SET ProductName = ?, IsAvailable = ? WHERE ProductID = ?";
        String sqlUpdateSize = "UPDATE ProductSize SET Price = ? WHERE ProductSizeID = ?";
        
        try {
            conn.setAutoCommit(false);
            
            // Get ProductID
            PreparedStatement psGet = conn.prepareStatement(sqlGetProductID);
            psGet.setInt(1, productSizeID);
            ResultSet rs = psGet.executeQuery();
            
            if (rs.next()) {
                int productID = rs.getInt("ProductID");
                
                // Update Product
                PreparedStatement psProduct = conn.prepareStatement(sqlUpdateProduct);
                psProduct.setString(1, toppingName);
                psProduct.setBoolean(2, isAvailable);
                psProduct.setInt(3, productID);
                psProduct.executeUpdate();
                
                // Update ProductSize
                PreparedStatement psSize = conn.prepareStatement(sqlUpdateSize);
                psSize.setDouble(1, price);
                psSize.setInt(2, productSizeID);
                psSize.executeUpdate();
                
                conn.commit();
                System.out.println("✅ Topping updated: " + toppingName);
                return true;
            }
            
            conn.rollback();
            return false;
        } catch (SQLException e) {
            try {
                conn.rollback();
            } catch (SQLException ex) {
                System.err.println("❌ Rollback error: " + ex.getMessage());
            }
            System.err.println("❌ Error updating topping: " + e.getMessage());
            return false;
        } finally {
            try {
                conn.setAutoCommit(true);
            } catch (SQLException e) {
                System.err.println("❌ Error resetting auto-commit: " + e.getMessage());
            }
        }
    }

    // Delete topping (deletes ProductSize and Product)
    public boolean deleteTopping(int productSizeID) {
        String sqlGetProductID = "SELECT ProductID FROM ProductSize WHERE ProductSizeID = ?";
        String sqlDeleteSize = "DELETE FROM ProductSize WHERE ProductSizeID = ?";
        String sqlDeleteProduct = "DELETE FROM Product WHERE ProductID = ?";
        
        try {
            conn.setAutoCommit(false);
            
            // Get ProductID
            PreparedStatement psGet = conn.prepareStatement(sqlGetProductID);
            psGet.setInt(1, productSizeID);
            ResultSet rs = psGet.executeQuery();
            
            if (rs.next()) {
                int productID = rs.getInt("ProductID");
                
                // Delete ProductSize
                PreparedStatement psSize = conn.prepareStatement(sqlDeleteSize);
                psSize.setInt(1, productSizeID);
                psSize.executeUpdate();
                
                // Delete Product
                PreparedStatement psProduct = conn.prepareStatement(sqlDeleteProduct);
                psProduct.setInt(1, productID);
                psProduct.executeUpdate();
                
                conn.commit();
                System.out.println("✅ Topping deleted: ID " + productSizeID);
                return true;
            }
            
            conn.rollback();
            return false;
        } catch (SQLException e) {
            try {
                conn.rollback();
            } catch (SQLException ex) {
                System.err.println("❌ Rollback error: " + ex.getMessage());
            }
            System.err.println("❌ Error deleting topping: " + e.getMessage());
            return false;
        } finally {
            try {
                conn.setAutoCommit(true);
            } catch (SQLException e) {
                System.err.println("❌ Error resetting auto-commit: " + e.getMessage());
            }
        }
    }

    // Toggle topping availability
    public boolean toggleAvailability(int productSizeID) {
        String sqlGetProductID = "SELECT ProductID FROM ProductSize WHERE ProductSizeID = ?";
        String sqlToggle = "UPDATE Product SET IsAvailable = CASE WHEN IsAvailable = 1 THEN 0 ELSE 1 END WHERE ProductID = ?";
        
        try {
            // Get ProductID
            PreparedStatement psGet = conn.prepareStatement(sqlGetProductID);
            psGet.setInt(1, productSizeID);
            ResultSet rs = psGet.executeQuery();
            
            if (rs.next()) {
                int productID = rs.getInt("ProductID");
                
                // Toggle availability
                PreparedStatement psToggle = conn.prepareStatement(sqlToggle);
                psToggle.setInt(1, productID);
                int result = psToggle.executeUpdate();
                System.out.println("✅ Topping availability toggled: ID " + productSizeID);
                return result > 0;
            }
            return false;
        } catch (SQLException e) {
            System.err.println("❌ Error toggling topping availability: " + e.getMessage());
            return false;
        }
    }
}
