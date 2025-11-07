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

    // Get all toppings
    public List<Topping> getAllToppings() {
        List<Topping> list = new ArrayList<>();
        String sql = "SELECT * FROM Topping ORDER BY ToppingName";
        
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Topping t = new Topping();
                t.setToppingID(rs.getInt("ToppingID"));
                t.setToppingName(rs.getString("ToppingName"));
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
        String sql = "SELECT * FROM Topping WHERE IsAvailable = 1 ORDER BY ToppingName";
        
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Topping t = new Topping();
                t.setToppingID(rs.getInt("ToppingID"));
                t.setToppingName(rs.getString("ToppingName"));
                t.setPrice(rs.getDouble("Price"));
                t.setAvailable(rs.getBoolean("IsAvailable"));
                list.add(t);
            }
        } catch (SQLException e) {
            System.err.println("❌ Error getting available toppings: " + e.getMessage());
        }
        return list;
    }

    // Get topping by ID
    public Topping getToppingByID(int toppingID) {
        String sql = "SELECT * FROM Topping WHERE ToppingID = ?";
        
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, toppingID);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                Topping t = new Topping();
                t.setToppingID(rs.getInt("ToppingID"));
                t.setToppingName(rs.getString("ToppingName"));
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

    // Add new topping
    public boolean addTopping(String toppingName, double price) {
        String sql = "INSERT INTO Topping (ToppingName, Price, IsAvailable) VALUES (?, ?, 1)";
        
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, toppingName);
            ps.setDouble(2, price);
            int result = ps.executeUpdate();
            System.out.println("✅ Topping added: " + toppingName);
            return result > 0;
        } catch (SQLException e) {
            System.err.println("❌ Error adding topping: " + e.getMessage());
            return false;
        }
    }

    // Update topping
    public boolean updateTopping(int toppingID, String toppingName, double price, boolean isAvailable) {
        String sql = "UPDATE Topping SET ToppingName = ?, Price = ?, IsAvailable = ? WHERE ToppingID = ?";
        
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, toppingName);
            ps.setDouble(2, price);
            ps.setBoolean(3, isAvailable);
            ps.setInt(4, toppingID);
            int result = ps.executeUpdate();
            System.out.println("✅ Topping updated: " + toppingName);
            return result > 0;
        } catch (SQLException e) {
            System.err.println("❌ Error updating topping: " + e.getMessage());
            return false;
        }
    }

    // Delete topping
    public boolean deleteTopping(int toppingID) {
        String sql = "DELETE FROM Topping WHERE ToppingID = ?";
        
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, toppingID);
            int result = ps.executeUpdate();
            System.out.println("✅ Topping deleted: ID " + toppingID);
            return result > 0;
        } catch (SQLException e) {
            System.err.println("❌ Error deleting topping: " + e.getMessage());
            return false;
        }
    }

    // Toggle topping availability
    public boolean toggleAvailability(int toppingID) {
        String sql = "UPDATE Topping SET IsAvailable = CASE WHEN IsAvailable = 1 THEN 0 ELSE 1 END WHERE ToppingID = ?";
        
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, toppingID);
            int result = ps.executeUpdate();
            System.out.println("✅ Topping availability toggled: ID " + toppingID);
            return result > 0;
        } catch (SQLException e) {
            System.err.println("❌ Error toggling topping availability: " + e.getMessage());
            return false;
        }
    }
}
