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
        String query = "SELECT * FROM Inventory ORDER BY InventoryID ASC";
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
                        rs.getString("Status"),
                        rs.getTimestamp("LastUpdated")
                ));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public void insert(Inventory i) {
        String query = "INSERT INTO Inventory (ItemName, Quantity, Unit, Status, LastUpdated) VALUES (?, ?, ?, 'Active', GETDATE())";
        try {
            conn = new DBContext().getConnection();
            ps = conn.prepareStatement(query);
            ps.setString(1, i.getItemName());
            ps.setDouble(2, i.getQuantity());
            ps.setString(3, i.getUnit());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void update(Inventory i) {
        String query = "UPDATE Inventory SET ItemName=?, Quantity=?, Unit=?, LastUpdated=GETDATE() WHERE InventoryID=?";
        try {
            conn = new DBContext().getConnection();
            ps = conn.prepareStatement(query);
            ps.setString(1, i.getItemName());
            ps.setDouble(2, i.getQuantity());
            ps.setString(3, i.getUnit());
            ps.setInt(4, i.getInventoryID());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void toggleStatus(int id) {
        String query = "UPDATE Inventory SET Status = CASE WHEN Status = 'Active' THEN 'Inactive' ELSE 'Active' END, LastUpdated=GETDATE() WHERE InventoryID=?";
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

