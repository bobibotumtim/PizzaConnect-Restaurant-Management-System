package dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import models.Inventory;

public class InventoryDAO {
    // thay bằng class kết nối của bạn nếu khác
    private Connection getConn() throws Exception {
        return new DBContext().getConnection(); // hoặc DBUtils.getConnection()
    }

    // Lấy tổng số bản ghi
    public int getTotalInventoryCount() {
        String sql = "SELECT COUNT(*) FROM Inventory";
        try (Connection conn = getConn();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) { e.printStackTrace(); }
        return 0;
    }

    // Lấy tổng số bản ghi với search và status filter
    public int getTotalInventoryCount(String searchName, String statusFilter) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM Inventory WHERE 1=1");
        
        if (searchName != null && !searchName.trim().isEmpty()) {
            sql.append(" AND ItemName LIKE ?");
        }
        
        // Add status filter condition
        if (statusFilter != null && !statusFilter.equalsIgnoreCase("all")) {
            if (statusFilter.equalsIgnoreCase("active")) {
                sql.append(" AND Status = 'Active'");
            } else if (statusFilter.equalsIgnoreCase("inactive")) {
                sql.append(" AND Status = 'Inactive'");
            }
        }
        
        try (Connection conn = getConn();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            int paramIndex = 1;
            if (searchName != null && !searchName.trim().isEmpty()) {
                ps.setString(paramIndex++, "%" + searchName.trim() + "%");
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return 0;
    }

    // Lấy theo trang (page bắt đầu từ 1)
    public List<Inventory> getInventoriesByPage(int page, int pageSize) {
        List<Inventory> list = new ArrayList<>();
        String sql = "SELECT InventoryID, ItemName, Quantity, Unit, LastUpdated " +
                     "FROM Inventory " +
                     "ORDER BY InventoryID " +
                     "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        try (Connection conn = getConn();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            int offset = (page - 1) * pageSize;
            ps.setInt(1, offset);
            ps.setInt(2, pageSize);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Inventory inv = new Inventory();
                    inv.setInventoryID(rs.getInt("InventoryID"));
                    inv.setItemName(rs.getString("ItemName"));
                    inv.setQuantity(rs.getDouble("Quantity"));
                    inv.setUnit(rs.getString("Unit"));
                    inv.setLastUpdated(rs.getTimestamp("LastUpdated"));
                    list.add(inv);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    // Lấy theo trang với search và status filter
    public List<Inventory> getInventoriesByPage(int page, int pageSize, String searchName, String statusFilter) {
        List<Inventory> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT InventoryID, ItemName, Quantity, Unit, LastUpdated, Status " +
            "FROM Inventory WHERE 1=1"
        );
        
        if (searchName != null && !searchName.trim().isEmpty()) {
            sql.append(" AND ItemName LIKE ?");
        }
        
        // Add status filter condition
        if (statusFilter != null && !statusFilter.equalsIgnoreCase("all")) {
            if (statusFilter.equalsIgnoreCase("active")) {
                sql.append(" AND Status = 'Active'");
            } else if (statusFilter.equalsIgnoreCase("inactive")) {
                sql.append(" AND Status = 'Inactive'");
            }
        }
        
        sql.append(" ORDER BY InventoryID OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        
        try (Connection conn = getConn();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            int paramIndex = 1;
            if (searchName != null && !searchName.trim().isEmpty()) {
                ps.setString(paramIndex++, "%" + searchName.trim() + "%");
            }
            
            int offset = (page - 1) * pageSize;
            ps.setInt(paramIndex++, offset);
            ps.setInt(paramIndex, pageSize);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Inventory inv = new Inventory();
                    inv.setInventoryID(rs.getInt("InventoryID"));
                    inv.setItemName(rs.getString("ItemName"));
                    inv.setQuantity(rs.getDouble("Quantity"));
                    inv.setUnit(rs.getString("Unit"));
                    inv.setLastUpdated(rs.getTimestamp("LastUpdated"));
                    inv.setStatus(rs.getString("Status"));
                    list.add(inv);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    // Lấy 1 item theo ID
    public Inventory getById(int id) {
        String sql = "SELECT InventoryID, ItemName, Quantity, Unit, LastUpdated, Status FROM Inventory WHERE InventoryID = ?";
        try (Connection conn = getConn();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Inventory inv = new Inventory();
                    inv.setInventoryID(rs.getInt("InventoryID"));
                    inv.setItemName(rs.getString("ItemName"));
                    inv.setQuantity(rs.getDouble("Quantity"));
                    inv.setUnit(rs.getString("Unit"));
                    inv.setLastUpdated(rs.getTimestamp("LastUpdated"));
                    inv.setStatus(rs.getString("Status"));
                    return inv;
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

    // Insert (Status default Active, LastUpdated = GETDATE())
    public void insert(Inventory inv) {
        String sql = "INSERT INTO Inventory (ItemName, Quantity, Unit, Status, LastUpdated) VALUES (?, ?, ?, 'Active', GETDATE())";
        try (Connection conn = getConn();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, inv.getItemName());
            ps.setDouble(2, inv.getQuantity());
            ps.setString(3, inv.getUnit());
            ps.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); }
    }

    // Update (cập nhật LastUpdated = GETDATE(), giữ nguyên Status)
    public void update(Inventory inv) {
        String sql = "UPDATE Inventory SET ItemName = ?, Quantity = ?, Unit = ?, LastUpdated = GETDATE() WHERE InventoryID = ?";
        try (Connection conn = getConn();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, inv.getItemName());
            ps.setDouble(2, inv.getQuantity());
            ps.setString(3, inv.getUnit());
            ps.setInt(4, inv.getInventoryID());
            ps.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); }
    }

    // Toggle status Active <-> Inactive
    public void toggleStatus(int id) {
        String sql = "UPDATE Inventory SET Status = CASE WHEN Status = 'Active' THEN 'Inactive' ELSE 'Active' END, LastUpdated = GETDATE() WHERE InventoryID = ?";
        try (Connection conn = getConn();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); }
    }

    // Kiểm tra item có đang được dùng ở ProductIngredients (hoặc bảng liên quan)
    // Thay "ProductIngredients" và tên cột nếu khác
    public boolean isItemInUse(int id) {
        String sql = "SELECT COUNT(*) FROM ProductIngredients WHERE InventoryID = ?";
        try (Connection conn = getConn();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    // Check if item name exists (case insensitive)
    public boolean isNameExists(String itemName, Integer excludeId) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM Inventory WHERE LOWER(ItemName) = LOWER(?)");
        if (excludeId != null) {
            sql.append(" AND InventoryID != ?");
        }
        
        try (Connection conn = getConn();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            ps.setString(1, itemName.trim());
            if (excludeId != null) {
                ps.setInt(2, excludeId);
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    // Lấy thông tin item theo ID để hiển thị trong thông báo
    public String getItemNameById(int id) {
        String sql = "SELECT ItemName FROM Inventory WHERE InventoryID = ?";
        try (Connection conn = getConn();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("ItemName");
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

    // Trừ nguyên liệu khi chef hoàn thành món
    public boolean deductInventory(int inventoryId, double quantity) {
        String sql = "UPDATE Inventory SET Quantity = Quantity - ?, LastUpdated = GETDATE() WHERE InventoryID = ? AND Quantity >= ?";
        try (Connection conn = getConn();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDouble(1, quantity);
            ps.setInt(2, inventoryId);
            ps.setDouble(3, quantity);
            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
        } catch (Exception e) { 
            e.printStackTrace(); 
            return false;
        }
    }
    
    // Kiểm tra xem có đủ nguyên liệu không
    public boolean hasEnoughInventory(int inventoryId, double quantity) {
        String sql = "SELECT Quantity FROM Inventory WHERE InventoryID = ?";
        try (Connection conn = getConn();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, inventoryId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    double currentQuantity = rs.getDouble("Quantity");
                    return currentQuantity >= quantity;
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    // (Không cung cấp delete để tránh xóa vật lý; nếu cần vẫn có thể thêm)
}
