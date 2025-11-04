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
                
                list.add(d);
            }
        } catch (Exception e) { 
            e.printStackTrace(); 
        }
        return list;
    }
    
    // Cập nhật status của OrderDetail
    public boolean updateOrderDetailStatus(int orderDetailId, String status, int employeeId) {
        String sql = """
            UPDATE OrderDetail 
            SET Status = ?, EmployeeID = ?, 
                StartTime = CASE WHEN ? = 'In Progress' AND StartTime IS NULL THEN GETDATE() ELSE StartTime END,
                EndTime = CASE WHEN ? = 'Done' THEN GETDATE() ELSE NULL END
            WHERE OrderDetailID = ?
        """;
        
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, employeeId);
            ps.setString(3, status);
            ps.setString(4, status);
            ps.setInt(5, orderDetailId);
            
            return ps.executeUpdate() > 0;
        } catch (Exception e) { 
            e.printStackTrace(); 
            return false;
        }
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
}
