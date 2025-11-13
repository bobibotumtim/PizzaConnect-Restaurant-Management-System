package dao;

import java.sql.*;
import java.util.*;
import models.OrderDetail;

public class OrderDetailDAO extends DBContext {
    private Connection conn;

    public OrderDetailDAO(Connection conn) {
        this.conn = conn;
    }

    public OrderDetailDAO() {
    }

    // Lấy OrderDetail theo OrderID với thông tin đầy đủ từ database mới
    public List<OrderDetail> getByOrderID(int orderID) throws SQLException {
        List<OrderDetail> list = new ArrayList<>();
        String sql = """
            SELECT od.*, p.ProductName, ps.SizeName, ps.SizeCode
            FROM OrderDetail od
            LEFT JOIN ProductSize ps ON od.ProductSizeID = ps.ProductSizeID
            LEFT JOIN Product p ON ps.ProductID = p.ProductID
            WHERE od.OrderID = ?
            ORDER BY od.OrderDetailID
        """;
        
        Connection connection = (conn != null) ? conn : getConnection();
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, orderID);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                OrderDetail d = new OrderDetail();
                d.setOrderDetailID(rs.getInt("OrderDetailID"));
                d.setOrderID(rs.getInt("OrderID"));
                d.setProductSizeID(rs.getInt("ProductSizeID"));
                d.setQuantity(rs.getInt("Quantity"));
                d.setTotalPrice(rs.getDouble("TotalPrice"));
                d.setSpecialInstructions(rs.getString("SpecialInstructions"));
                d.setEmployeeID(rs.getInt("EmployeeID"));
                d.setStatus(rs.getString("Status"));
                d.setStartTime(rs.getTimestamp("StartTime"));
                d.setEndTime(rs.getTimestamp("EndTime"));
                
                // Thông tin bổ sung
                d.setProductName(rs.getString("ProductName"));
                d.setSizeName(rs.getString("SizeName"));
                d.setSizeCode(rs.getString("SizeCode"));
                
                list.add(d);
            }
        } catch (Exception e) { 
            e.printStackTrace(); 
        } finally {
            if (conn == null && connection != null) {
                try { connection.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
        return list;
    }
    
    // Lấy OrderDetail theo status cho ChefMonitor
    public List<OrderDetail> getOrderDetailsByStatus(String status) {
        List<OrderDetail> list = new ArrayList<>();
        String sql = """
            SELECT od.*, p.ProductName, ps.SizeName, ps.SizeCode, o.TableID
            FROM OrderDetail od
            LEFT JOIN ProductSize ps ON od.ProductSizeID = ps.ProductSizeID
            LEFT JOIN Product p ON ps.ProductID = p.ProductID
            LEFT JOIN [Order] o ON od.OrderID = o.OrderID
            WHERE od.Status = ?
            ORDER BY od.OrderDetailID
        """;
        
        OrderDetailToppingDAO toppingDAO = new OrderDetailToppingDAO();
        
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, status);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                OrderDetail d = new OrderDetail();
                d.setOrderDetailID(rs.getInt("OrderDetailID"));
                d.setOrderID(rs.getInt("OrderID"));
                d.setProductSizeID(rs.getInt("ProductSizeID"));
                d.setQuantity(rs.getInt("Quantity"));
                d.setTotalPrice(rs.getDouble("TotalPrice"));
                d.setSpecialInstructions(rs.getString("SpecialInstructions"));
                d.setEmployeeID(rs.getInt("EmployeeID"));
                d.setStatus(rs.getString("Status"));
                d.setStartTime(rs.getTimestamp("StartTime"));
                d.setEndTime(rs.getTimestamp("EndTime"));
                
                // Thông tin bổ sung
                d.setProductName(rs.getString("ProductName"));
                d.setSizeName(rs.getString("SizeName"));
                d.setSizeCode(rs.getString("SizeCode"));
                
                // Load toppings
                d.setToppings(toppingDAO.getToppingsByOrderDetailID(d.getOrderDetailID()));
                
                list.add(d);
            }
        } catch (Exception e) { 
            e.printStackTrace(); 
        }
        return list;
    }
    
    // Cập nhật status của OrderDetail
    public boolean updateOrderDetailStatus(int orderDetailId, String status, int employeeId) {
        System.out.println("🔍 DEBUG: Updating OrderDetail #" + orderDetailId + " to status: " + status + ", EmployeeID: " + employeeId);
        
        String sql = """
            UPDATE OrderDetail 
            SET Status = ?, 
                EmployeeID = CASE WHEN ? > 0 THEN ? ELSE EmployeeID END,
                StartTime = CASE WHEN ? = 'Preparing' AND StartTime IS NULL THEN GETDATE() ELSE StartTime END,
                EndTime = CASE WHEN ? IN ('Ready', 'Served', 'Cancelled') THEN GETDATE() ELSE NULL END
            WHERE OrderDetailID = ?
        """;
        
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, employeeId);
            ps.setInt(3, employeeId);
            ps.setString(4, status);
            ps.setString(5, status);
            ps.setInt(6, orderDetailId);
            
            int rowsAffected = ps.executeUpdate();
            System.out.println("🔍 DEBUG: OrderDetail #" + orderDetailId + " - Rows affected: " + rowsAffected);
            
            return rowsAffected > 0;
        } catch (Exception e) { 
            e.printStackTrace(); 
            return false;
        }
    }
    
    // Kiểm tra xem tất cả món trong order đã được served chưa
    public boolean areAllItemsServed(int orderId) {
        String sql = """
            SELECT COUNT(*) as total,
                   SUM(CASE WHEN Status = 'Served' THEN 1 ELSE 0 END) as served
            FROM OrderDetail
            WHERE OrderID = ? AND Status != 'Cancelled'
        """;
        
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                int total = rs.getInt("total");
                int served = rs.getInt("served");
                return total > 0 && total == served;
            }
        } catch (Exception e) { 
            e.printStackTrace(); 
        }
        return false;
    }
    
    // Thêm OrderDetail mới
    public boolean addOrderDetail(OrderDetail detail) {
        String sql = """
            INSERT INTO OrderDetail (OrderID, ProductSizeID, Quantity, TotalPrice, SpecialInstructions, Status)
            VALUES (?, ?, ?, ?, ?, 'Waiting')
        """;
        
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, detail.getOrderID());
            ps.setInt(2, detail.getProductSizeID());
            ps.setInt(3, detail.getQuantity());
            ps.setDouble(4, detail.getTotalPrice());
            ps.setString(5, detail.getSpecialInstructions());
            
            return ps.executeUpdate() > 0;
        } catch (Exception e) { 
            e.printStackTrace(); 
            return false;
        }
    }
    
    // Lấy OrderDetail theo status VÀ category (for Chef specialization)
    public List<OrderDetail> getOrderDetailsByStatusAndCategory(String status, String categoryName) {
        List<OrderDetail> list = new ArrayList<>();
        String sql = """
            SELECT od.*, p.ProductName, ps.SizeName, ps.SizeCode, o.TableID, c.CategoryName
            FROM OrderDetail od
            LEFT JOIN ProductSize ps ON od.ProductSizeID = ps.ProductSizeID
            LEFT JOIN Product p ON ps.ProductID = p.ProductID
            LEFT JOIN Category c ON p.CategoryID = c.CategoryID
            LEFT JOIN [Order] o ON od.OrderID = o.OrderID
            WHERE od.Status = ? AND c.CategoryName = ?
            ORDER BY od.OrderDetailID
        """;
        
        OrderDetailToppingDAO toppingDAO = new OrderDetailToppingDAO();
        
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setString(2, categoryName);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                OrderDetail d = new OrderDetail();
                d.setOrderDetailID(rs.getInt("OrderDetailID"));
                d.setOrderID(rs.getInt("OrderID"));
                d.setProductSizeID(rs.getInt("ProductSizeID"));
                d.setQuantity(rs.getInt("Quantity"));
                d.setTotalPrice(rs.getDouble("TotalPrice"));
                d.setSpecialInstructions(rs.getString("SpecialInstructions"));
                d.setEmployeeID(rs.getInt("EmployeeID"));
                d.setStatus(rs.getString("Status"));
                d.setStartTime(rs.getTimestamp("StartTime"));
                d.setEndTime(rs.getTimestamp("EndTime"));
                
                // Thông tin bổ sung
                d.setProductName(rs.getString("ProductName"));
                d.setSizeName(rs.getString("SizeName"));
                d.setSizeCode(rs.getString("SizeCode"));
                
                // Load toppings
                d.setToppings(toppingDAO.getToppingsByOrderDetailID(d.getOrderDetailID()));
                
                list.add(d);
            }
        } catch (Exception e) { 
            e.printStackTrace(); 
        }
        return list;
    }
    
    // Map specialization to category name
    public String mapSpecializationToCategory(String specialization) {
        if (specialization == null) return null;
        switch (specialization) {
            case "Pizza": return "Pizza";
            case "Drinks": return "Drink";
            case "SideDishes": return "Side Dishes";
            default: return null;
        }
    }
}
