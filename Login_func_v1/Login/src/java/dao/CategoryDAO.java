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

    // Get all categories
    public List<Category> getAllCategories() {
        List<Category> list = new ArrayList<>();
        String sql = "SELECT * FROM Category ORDER BY CategoryName";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSetToCategory(rs));
            }
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
}
