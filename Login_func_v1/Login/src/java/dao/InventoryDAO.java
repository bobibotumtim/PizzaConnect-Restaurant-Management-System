package dao;


import models.Inventory;
import java.sql.*;
import java.util.*;

public class InventoryDAO extends DBContext {
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    // Get all inventory items
    public List<Inventory> getAll() {
        List<Inventory> list = new ArrayList<>();
        String query = "SELECT * FROM Inventory ORDER BY InventoryID DESC";
        try {
            conn = getConnection();
            ps = conn.prepareStatement(query);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(new Inventory(
                    rs.getInt("InventoryID"),
                    rs.getString("ItemName"),
                    rs.getDouble("Quantity"),
                    rs.getString("Unit"),
                    rs.getTimestamp("LastUpdated")
                ));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Create new inventory item
    public void insert(String name, double quantity, String unit) {
        String query = "INSERT INTO Inventory (ItemName, Quantity, Unit, LastUpdated) VALUES (?, ?, ?, GETDATE())";
        try {
            conn = getConnection();
            ps = conn.prepareStatement(query);
            ps.setString(1, name);
            ps.setDouble(2, quantity);
            ps.setString(3, unit);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // Get inventory item by ID
    public Inventory getById(int id) {
        String query = "SELECT * FROM Inventory WHERE InventoryID=?";
        try {
            conn = getConnection();
            ps = conn.prepareStatement(query);
            ps.setInt(1, id);
            rs = ps.executeQuery();
            if (rs.next()) {
                return new Inventory(
                    rs.getInt("InventoryID"),
                    rs.getString("ItemName"),
                    rs.getDouble("Quantity"),
                    rs.getString("Unit"),
                    rs.getTimestamp("LastUpdated")
                );
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // Update inventory item
    public void update(int id, String name, double quantity, String unit) {
        String query = "UPDATE Inventory SET ItemName=?, Quantity=?, Unit=?, LastUpdated=GETDATE() WHERE InventoryID=?";
        try {
            conn = getConnection();
            ps = conn.prepareStatement(query);
            ps.setString(1, name);
            ps.setDouble(2, quantity);
            ps.setString(3, unit);
            ps.setInt(4, id);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // Delete inventory item
    public void delete(int id) {
        String query = "DELETE FROM Inventory WHERE InventoryID=?";
        try {
            conn = getConnection();
            ps = conn.prepareStatement(query);
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

