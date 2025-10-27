package dao;

import java.sql.*;
import java.util.*;
import models.OrderDetail;

public class OrderDetailDAO {
    private Connection conn;

    public OrderDetailDAO(Connection conn) {
        this.conn = conn;
    }

    public OrderDetailDAO() {
    }
    
    

    public List<OrderDetail> getByOrderID(int orderID) {
        List<OrderDetail> list = new ArrayList<>();
        String sql = "SELECT * FROM OrderDetail WHERE OrderID=?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderID);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                OrderDetail d = new OrderDetail();
                d.setOrderDetailID(rs.getInt("OrderDetailID"));
                d.setOrderID(rs.getInt("OrderID"));
                d.setProductID(rs.getInt("ProductID"));
                d.setQuantity(rs.getInt("Quantity"));
                d.setTotalPrice(rs.getDouble("TotalPrice"));
                d.setSpecialInstructions(rs.getString("SpecialInstructions"));
                list.add(d);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }
}
