package dao;

import java.sql.*;
import java.util.*;
import models.*;

public class OrderDAO extends DBContext {

    private Connection externalConn; // ✅ thêm biến connection truyền từ servlet

    // ✅ Constructor mặc định (vẫn giữ, dùng khi không truyền conn)
    public OrderDAO() {}

    // ✅ Constructor có tham số Connection (dành cho servlet cách 2)
    public OrderDAO(Connection conn) {
        this.externalConn = conn;
    }

    // ✅ Hàm lấy connection: nếu servlet truyền vào thì dùng connection đó, nếu không thì dùng DBContext
    private Connection useConnection() throws SQLException {
        if (externalConn != null) return externalConn;
        return getConnection();
    }

    // 🟢 Tạo đơn hàng mới
    public int createOrder(int customerID, int employeeID, int tableID, String note, List<OrderDetail> orderDetails) throws Exception {
        int orderId = 0;
        Connection con = null;
        PreparedStatement psOrder = null;
        PreparedStatement psDetail = null;
        ResultSet rs = null;

        try {
            con = useConnection();
            con.setAutoCommit(false);

            String sqlOrder = "INSERT INTO [Order] (CustomerID, EmployeeID, TableID, OrderDate, Status, PaymentStatus, TotalPrice, Note) "
                    + "VALUES (?, ?, ?, GETDATE(), 0, 'Unpaid', 0, ?)";
            psOrder = con.prepareStatement(sqlOrder, Statement.RETURN_GENERATED_KEYS);
            psOrder.setInt(1, customerID);
            psOrder.setInt(2, employeeID);
            psOrder.setInt(3, tableID);
            psOrder.setString(4, note);
            psOrder.executeUpdate();

            rs = psOrder.getGeneratedKeys();
            if (rs.next()) {
                orderId = rs.getInt(1);
            }

            double totalPrice = 0;
            String sqlDetail = "INSERT INTO [OrderDetail] (OrderID, ProductID, Quantity, TotalPrice, SpecialInstructions) VALUES (?, ?, ?, ?, ?)";
            psDetail = con.prepareStatement(sqlDetail);

            for (OrderDetail d : orderDetails) {
                psDetail.setInt(1, orderId);
                psDetail.setInt(2, d.getProductID());
                psDetail.setInt(3, d.getQuantity());
                psDetail.setDouble(4, d.getTotalPrice());
                psDetail.setString(5, d.getSpecialInstructions());
                psDetail.addBatch();
                totalPrice += d.getTotalPrice();
            }
            psDetail.executeBatch();

            String sqlUpdate = "UPDATE [Order] SET TotalPrice = ? WHERE OrderID = ?";
            try (PreparedStatement psUpdate = con.prepareStatement(sqlUpdate)) {
                psUpdate.setDouble(1, totalPrice);
                psUpdate.setInt(2, orderId);
                psUpdate.executeUpdate();
            }

            con.commit();
        } catch (Exception e) {
            if (con != null) con.rollback();
            throw e;
        } finally {
            if (rs != null) rs.close();
            if (psOrder != null) psOrder.close();
            if (psDetail != null) psDetail.close();
            if (externalConn == null && con != null) con.close(); // 🔥 chỉ đóng nếu là connection nội bộ
        }
        return orderId;
    }

    // 🟢 Lấy danh sách đơn hàng
    public List<Order> getAll() {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT * FROM [Order] ORDER BY OrderDate DESC";
        try (Connection con = useConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Order o = new Order();
                o.setOrderID(rs.getInt("OrderID"));
                o.setCustomerID(rs.getInt("CustomerID"));
                o.setEmployeeID(rs.getInt("EmployeeID"));
                o.setTableID(rs.getInt("TableID"));
                o.setOrderDate(rs.getTimestamp("OrderDate"));
                o.setStatus(rs.getInt("Status"));
                o.setPaymentStatus(rs.getString("PaymentStatus"));
                o.setTotalPrice(rs.getDouble("TotalPrice"));
                o.setNote(rs.getString("Note"));
                list.add(o);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 🟢 Lấy đơn hàng theo ID
    public Order getOrderById(int orderId) {
        String sql = "SELECT * FROM [Order] WHERE OrderID = ?";
        try (Connection con = useConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new Order(
                            rs.getInt("OrderID"),
                            rs.getInt("CustomerID"),
                            rs.getInt("EmployeeID"),
                            rs.getInt("TableID"),
                            rs.getTimestamp("OrderDate"),
                            rs.getInt("Status"),
                            rs.getString("PaymentStatus"),
                            rs.getDouble("TotalPrice"),
                            rs.getString("Note")
                    );
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // 🟢 Lấy danh sách chi tiết đơn hàng
    public List<OrderDetail> getOrderDetailsByOrderId(int orderId) {
        List<OrderDetail> list = new ArrayList<>();
        String sql = "SELECT od.*, p.ProductName FROM [OrderDetail] od "
                + "JOIN [Product] p ON od.ProductID = p.ProductID "
                + "WHERE od.OrderID = ?";
        try (Connection con = useConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    OrderDetail od = new OrderDetail(
                            rs.getInt("OrderDetailID"),
                            rs.getInt("OrderID"),
                            rs.getInt("ProductID"),
                            rs.getInt("Quantity"),
                            rs.getDouble("TotalPrice"),
                            rs.getString("SpecialInstructions")
                    );
                    list.add(od);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 🟢 Cập nhật trạng thái đơn hàng
    public boolean updateOrderStatus(int orderId, int status) {
        String sql = "UPDATE [Order] SET Status = ? WHERE OrderID = ?";
        try (Connection con = useConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, status);
            ps.setInt(2, orderId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // 🟢 Cập nhật trạng thái thanh toán
    public boolean updatePaymentStatus(int orderId, String paymentStatus) {
        String sql = "UPDATE [Order] SET PaymentStatus = ? WHERE OrderID = ?";
        try (Connection con = useConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, paymentStatus);
            ps.setInt(2, orderId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // 🟢 Xóa đơn hàng và chi tiết
    public boolean deleteOrder(int orderId) {
        String deleteDetails = "DELETE FROM [OrderDetail] WHERE OrderID = ?";
        String deleteOrder = "DELETE FROM [Order] WHERE OrderID = ?";
        try (Connection con = useConnection()) {
            con.setAutoCommit(false);
            try (PreparedStatement ps1 = con.prepareStatement(deleteDetails)) {
                ps1.setInt(1, orderId);
                ps1.executeUpdate();
            }
            try (PreparedStatement ps2 = con.prepareStatement(deleteOrder)) {
                ps2.setInt(1, orderId);
                int result = ps2.executeUpdate();
                con.commit();
                return result > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // 🟢 Đếm tổng số đơn
    public int countAllOrders() {
        String sql = "SELECT COUNT(*) FROM [Order]";
        try (Connection con = useConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }
}
