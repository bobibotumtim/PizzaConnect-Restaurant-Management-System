package dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import models.Category;

public class CategoryDAO extends DBContext {

    private Category mapResultSetToCategory(ResultSet rs) throws SQLException {
        return new Category(
                rs.getInt("CategoryID"),
                rs.getString("CategoryName"),
                rs.getString("Description")
        );
    }

    // Get all categories sorted by custom display order
    public List<Category> getAllCategories() {
        List<Category> list = new ArrayList<>();
        String sql = "SELECT * FROM Category WHERE IsDeleted = 0";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSetToCategory(rs));
            }
            
            // Sort by custom display order
            list.sort((c1, c2) -> {
                int order1 = getCategoryDisplayOrder(c1.getCategoryName());
                int order2 = getCategoryDisplayOrder(c2.getCategoryName());
                return Integer.compare(order1, order2);
            });
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Get category by ID
    public Category getCategoryById(int id) {
        String sql = "SELECT * FROM Category WHERE CategoryID = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToCategory(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
    
    // Get category by Name
    public int getCategoryIdByName(String categoryName, Connection con) throws SQLException {
        String sql = "SELECT CategoryID FROM Category WHERE CategoryName = ? AND IsDeleted = 0";
        
        // Không dùng try-with-resources cho Connection
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, categoryName);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("CategoryID");
                }
            }
        }
        // Nếu không tìm thấy, ném lỗi để Service rollback
        throw new SQLException("Category không tồn tại: " + categoryName);
    }

    // Add new category
    public boolean addCategory(Category category) {
        String sql = "INSERT INTO Category (CategoryName, Description) VALUES (?, ?)";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, category.getCategoryName());
            ps.setString(2, category.getDescription());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // Update category
    public boolean updateCategory(Category category) {
        String sql = "UPDATE Category SET CategoryName=?, Description=? WHERE CategoryID=?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, category.getCategoryName());
            ps.setString(2, category.getDescription());
            ps.setInt(3, category.getCategoryId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // Delete category
    public boolean deleteCategory(int id) {
        String sql = "UPDATE Category SET IsDeleted = 1 WHERE CategoryID=?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Get category by Name
    public Category getCategoryByName(String categoryName) {
        String sql = "SELECT * FROM Category WHERE CategoryName = ? AND (IsDeleted = 0 OR IsDeleted IS NULL)";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, categoryName);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToCategory(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
    
    // Check if category name exists (for validation)
    public boolean isCategoryNameExists(String categoryName, Integer excludeId) {
        String sql = "SELECT COUNT(*) FROM Category WHERE CategoryName = ? AND (IsDeleted = 0 OR IsDeleted IS NULL)";
        if (excludeId != null) {
            sql += " AND CategoryID != ?";
        }
        
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, categoryName);
            if (excludeId != null) {
                ps.setInt(2, excludeId);
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
    
    // Get all category names excluding a specific category (for Chef filter)
    public List<String> getAllCategoryNamesExcluding(String excludedCategory) {
        List<String> list = new ArrayList<>();
        String sql = "SELECT CategoryName FROM Category WHERE IsDeleted = 0 AND CategoryName != ? ORDER BY CategoryName";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, excludedCategory);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(rs.getString("CategoryName"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Get display order for category sorting
     * Order: Appetizer -> Pizza -> Drink -> Side Dish -> Dessert
     */
    private int getCategoryDisplayOrder(String categoryName) {
        return switch (categoryName.toLowerCase()) {
            case "appetizer" -> 1;
            case "pizza" -> 2;
            case "drink" -> 3;
            case "side dish", "sidedish" -> 4;
            case "dessert" -> 5;
            default -> 99; // Unknown categories go to the end
        };
    }

    /**
     * ✅ Get categories with products available for POS
     * Only get categories with at least 1 product with AvailableQuantity > 0
     * Exclude "Topping" category
     * Sorted by custom display order: Appetizer -> Pizza -> Drink -> Side Dish -> Dessert
     */
    public List<Category> getAvailableCategoriesForPOS() {
        List<Category> list = new ArrayList<>();
        
        String sql = """
            SELECT DISTINCT 
                c.CategoryID,
                c.CategoryName,
                c.Description
            FROM Category c
            JOIN Product p ON c.CategoryID = p.CategoryID
            WHERE c.CategoryName != 'Topping'
              AND c.IsDeleted = 0
              AND p.IsAvailable = 1
        """;
        
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                list.add(mapResultSetToCategory(rs));
            }
            
            // Sort by custom display order
            list.sort((c1, c2) -> {
                int order1 = getCategoryDisplayOrder(c1.getCategoryName());
                int order2 = getCategoryDisplayOrder(c2.getCategoryName());
                return Integer.compare(order1, order2);
            });
            
            System.out.println("✅ CategoryDAO.getAvailableCategoriesForPOS() returned " + list.size() + " categories in custom order");
        } catch (Exception e) {
            System.err.println("❌ Error in getAvailableCategoriesForPOS: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }
}
