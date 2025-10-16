package dao;


import models.Inventory;
import java.sql.*;
import java.util.*;

public class InventoryDAO {
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    public List<Inventory> getAll() {
        List<Inventory> list = new ArrayList<>();
        String query = "SELECT * FROM Inventory ORDER BY InventoryID DESC";
        try {
            conn = new DBContext().getConnection();
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

    public void insert(String name, double quantity, String unit) {
        String query = "INSERT INTO Inventory (ItemName, Quantity, Unit, LastUpdated) VALUES (?, ?, ?, GETDATE())";
        try {
            conn = new DBContext().getConnection();
            ps = conn.prepareStatement(query);
            ps.setString(1, name);
            ps.setDouble(2, quantity);
            ps.setString(3, unit);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public Inventory getById(int id) {
        String query = "SELECT * FROM Inventory WHERE InventoryID=?";
        try {
            conn = new DBContext().getConnection();
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

    public void update(int id, String name, double quantity, String unit) {
        String query = "UPDATE Inventory SET ItemName=?, Quantity=?, Unit=?, LastUpdated=GETDATE() WHERE InventoryID=?";
        try {
            conn = new DBContext().getConnection();
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

    public void delete(int id) {
        String query = "DELETE FROM Inventory WHERE InventoryID=?";
        try {
            conn = new DBContext().getConnection();
            ps = conn.prepareStatement(query);
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

