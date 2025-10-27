package dao;

import java.sql.*;
import java.util.*;
import models.*;

public class OrderDAO extends DBContext {

    private Connection externalConn; // ⚙️ Dùng nếu servlet truyền vào (trường hợp đặc biệt)

    // ✅ Constructor mặc định (dùng phổ biến)
    public OrderDAO() {
        super(); // ⚙️ Rất quan trọng — mở connection từ DBContext
        // Không tự động tạo bảng vì database đã có sẵn
        System.out.println("✅ OrderDAO initialized with existing database");
    }

    // ✅ Constructor có tham số (ít dùng, chỉ khi cần connection bên ngoài)
    public OrderDAO(Connection conn) {
        this.externalConn = conn;
    }

    // ✅ Hàm lấy connection — ưu tiên external nếu có
    private Connection useConnection() throws SQLException {
        if (externalConn != null) return externalConn;
        return getConnection();
    }
    
    // ✅ Public method để kiểm tra connection
    public Connection getConnection() {
        return connection;
    }

    // 🟢 Tạo đơn hàng mới cùng chi tiết
    public int createOrder(int customerID, int employeeID, int tableID, String note, List<OrderDetail> orderDetails) throws Exception {
        int orderId = 0;
        Connection con = null;

        try {
            con = useConnection();
            con.setAutoCommit(false);

            // 1️⃣ Tạo đơn hàng
            String sqlOrder = """
                INSERT INTO [Order] 
                (CustomerID, EmployeeID, TableID, OrderDate, Status, PaymentStatus, TotalPrice, Note)
                VALUES (?, ?, ?, GETDATE(), 0, 'Unpaid', 0, ?)
            """;
            try (PreparedStatement psOrder = con.prepareStatement(sqlOrder, Statement.RETURN_GENERATED_KEYS)) {
                psOrder.setInt(1, customerID);
                psOrder.setInt(2, employeeID);
                psOrder.setInt(3, tableID);
                psOrder.setString(4, note);
                psOrder.executeUpdate();

                try (ResultSet rs = psOrder.getGeneratedKeys()) {
                    if (rs.next()) orderId = rs.getInt(1);
                }
            }

            // 2️⃣ Chèn chi tiết (nếu có)
            if (orderDetails != null && !orderDetails.isEmpty()) {
                double totalPrice = 0;
                String sqlDetail = """
                    INSERT INTO [OrderDetail] 
                    (OrderID, ProductID, Quantity, TotalPrice, SpecialInstructions)
                    VALUES (?, ?, ?, ?, ?)
                """;
                try (PreparedStatement psDetail = con.prepareStatement(sqlDetail)) {
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

                    // Cập nhật tổng tiền
                    String sqlUpdate = "UPDATE [Order] SET TotalPrice = ? WHERE OrderID = ?";
                    try (PreparedStatement psUpdate = con.prepareStatement(sqlUpdate)) {
                        psUpdate.setDouble(1, totalPrice);
                        psUpdate.setInt(2, orderId);
                        psUpdate.executeUpdate();
                    }
                }
            }

            con.commit();
            return orderId;

        } catch (Exception e) {
            if (con != null) con.rollback();
            e.printStackTrace();
            throw e;
        } finally {
            // ⚙️ Đóng connection chỉ nếu không phải connection bên ngoài
            if (externalConn == null && con != null) con.close();
        }
    }

    // 🟢 Lấy danh sách đơn hàng theo trạng thái
    public List<Order> getOrdersByStatus(int status) {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT * FROM [Order] WHERE Status = ? ORDER BY OrderDate DESC";

        try (Connection con = useConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, status);
            try (ResultSet rs = ps.executeQuery()) {
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
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        System.out.println("✅ Orders loaded by status " + status + ": " + list.size());
        return list;
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
                
                // Load OrderDetails cho mỗi order (dùng cùng connection, tránh đóng connection ngoài vòng lặp)
                List<OrderDetail> details = getOrderDetailsByOrderId(o.getOrderID(), con);
                o.setDetails(details);
                
                list.add(o);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        System.out.println("✅ Orders loaded: " + list.size());
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

    // 🟢 Lấy danh sách chi tiết đơn hàng – sử dụng connection truyền vào (không đóng connection cha)
    private List<OrderDetail> getOrderDetailsByOrderId(int orderId, Connection con) {
        List<OrderDetail> list = new ArrayList<>();
        String sql = """
            SELECT od.*, p.ProductName 
            FROM OrderDetail od
            LEFT JOIN Product p ON od.ProductID = p.ProductID
            WHERE od.OrderID = ?
        """;
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    OrderDetail detail = new OrderDetail();
                    detail.setOrderDetailID(rs.getInt("OrderDetailID"));
                    detail.setOrderID(rs.getInt("OrderID"));
                    detail.setProductID(rs.getInt("ProductID"));
                    detail.setQuantity(rs.getInt("Quantity"));
                    detail.setTotalPrice(rs.getDouble("TotalPrice"));
                    String productName = rs.getString("ProductName");
                    String specialInstructions = rs.getString("SpecialInstructions");
                    if (productName != null) {
                        detail.setSpecialInstructions("Loại: " + productName + (specialInstructions != null ? " - " + specialInstructions : ""));
                    } else {
                        detail.setSpecialInstructions(specialInstructions);
                    }
                    list.add(detail);
                }
            }
        } catch (Exception e) {
            System.out.println("Error getting order details: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    // 🟢 Lấy danh sách chi tiết đơn hàng – API công khai (dùng connection riêng, an toàn khi gọi độc lập)
    public List<OrderDetail> getOrderDetailsByOrderId(int orderId) {
        List<OrderDetail> list = new ArrayList<>();
        try (Connection con = useConnection()) {
            if (con == null) return list;
            return getOrderDetailsByOrderId(orderId, con);
        } catch (Exception e) {
            System.out.println("Error getting order details (public): " + e.getMessage());
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

    // 🟢 Xóa đơn hàng (và chi tiết)
    public boolean deleteOrder(int orderId) {
        String deleteDetails = "DELETE FROM [OrderDetail] WHERE OrderID = ?";
        String deleteOrder = "DELETE FROM [Order] WHERE OrderID = ?";
        try (Connection con = useConnection()) {
            con.setAutoCommit(false);

            try (PreparedStatement ps1 = con.prepareStatement(deleteDetails)) {
                ps1.setInt(1, orderId);
                ps1.executeUpdate();
            }

            int result;
            try (PreparedStatement ps2 = con.prepareStatement(deleteOrder)) {
                ps2.setInt(1, orderId);
                result = ps2.executeUpdate();
            }

            con.commit();
            return result > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // 🟢 Thêm dữ liệu mẫu để test
    public void insertSampleData() {
        try {
            // Kiểm tra xem đã có dữ liệu chưa
            if (countAllOrders() > 0) {
                System.out.println("✅ Sample data already exists");
                return;
            }
            
            // Thêm đơn hàng mẫu
            String sql = """
                INSERT INTO [Order] 
                (CustomerID, EmployeeID, TableID, OrderDate, Status, PaymentStatus, TotalPrice, Note)
                VALUES 
                (1, 1, 1, GETDATE(), 0, 'Unpaid', 400000, 'Đơn hàng mẫu 1'),
                (2, 1, 2, GETDATE(), 2, 'Paid', 500000, 'Đơn hàng mẫu 2')
            """;
            
            try (Connection con = useConnection();
                 PreparedStatement ps = con.prepareStatement(sql)) {
                ps.executeUpdate();
                System.out.println("✅ Sample orders inserted successfully");
            }
            
            // Thêm OrderDetail mẫu
            String detailSql = """
                INSERT INTO OrderDetail (OrderID, ProductID, Quantity, TotalPrice, SpecialInstructions)
                VALUES 
                (1, 1, 2, 400000, 'Loại: Pepperoni'),
                (2, 2, 2, 500000, 'Loại: Hawaiian')
            """;
            
            try (Connection con = useConnection();
                 PreparedStatement ps = con.prepareStatement(detailSql)) {
                ps.executeUpdate();
                System.out.println("✅ Sample order details inserted successfully");
            }
            
        } catch (Exception e) {
            System.out.println("⚠️ Error inserting sample data: " + e.getMessage());
        }
    }
    
    // 🟢 Tạo bảng nếu chưa tồn tại
    private void createTablesIfNotExist() {
        try {
            Connection con = useConnection();
            if (con == null) {
                System.out.println("❌ Cannot create tables - no database connection");
                return;
            }
            
            // Tạo bảng Customer
            String createCustomerTable = """
                IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Customer')
                CREATE TABLE Customer (
                    CustomerID int IDENTITY(1,1) PRIMARY KEY,
                    CustomerName nvarchar(100) NOT NULL,
                    Phone nvarchar(20),
                    Email nvarchar(100),
                    Address nvarchar(200)
                )
            """;
            
            // Tạo bảng Product
            String createProductTable = """
                IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Product')
                CREATE TABLE Product (
                    ProductID int IDENTITY(1,1) PRIMARY KEY,
                    ProductName nvarchar(100) NOT NULL,
                    Price decimal(10,2) NOT NULL,
                    Description nvarchar(500),
                    Category nvarchar(50)
                )
            """;
            
            // Tạo bảng Order
            String createOrderTable = """
                IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Order')
                CREATE TABLE [Order] (
                    OrderID int IDENTITY(1,1) PRIMARY KEY,
                    CustomerID int NOT NULL,
                    EmployeeID int NOT NULL,
                    TableID int NOT NULL,
                    OrderDate datetime2 DEFAULT GETDATE(),
                    Status int DEFAULT 0,
                    PaymentStatus nvarchar(20) DEFAULT 'Unpaid',
                    TotalPrice decimal(10,2) DEFAULT 0,
                    Note nvarchar(500)
                )
            """;
            
            // Tạo bảng OrderDetail
            String createOrderDetailTable = """
                IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'OrderDetail')
                CREATE TABLE OrderDetail (
                    OrderDetailID int IDENTITY(1,1) PRIMARY KEY,
                    OrderID int NOT NULL,
                    ProductID int NOT NULL,
                    Quantity int NOT NULL,
                    TotalPrice decimal(10,2) NOT NULL,
                    SpecialInstructions nvarchar(500)
                )
            """;
            
            // Thực thi các câu lệnh tạo bảng
            try (Statement stmt = con.createStatement()) {
                stmt.execute(createCustomerTable);
                System.out.println("✅ Customer table created/verified");
                
                stmt.execute(createProductTable);
                System.out.println("✅ Product table created/verified");
                
                stmt.execute(createOrderTable);
                System.out.println("✅ Order table created/verified");
                
                stmt.execute(createOrderDetailTable);
                System.out.println("✅ OrderDetail table created/verified");
            }
            
            // Thêm dữ liệu mẫu cho Customer và Product
            insertSampleCustomersAndProducts(con);
            
        } catch (Exception e) {
            System.out.println("❌ Error creating tables: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    private void insertSampleCustomersAndProducts(Connection con) {
        try {
            // Thêm Customer mẫu
            String insertCustomer = """
                IF NOT EXISTS (SELECT 1 FROM Customer WHERE CustomerID = 1)
                INSERT INTO Customer (CustomerName, Phone, Email) VALUES 
                ('Nguyễn Vân A', '0123456789', 'vana@email.com'),
                ('Trần Thị B', '0987654321', 'thib@email.com')
            """;
            
            // Thêm Product mẫu
            String insertProduct = """
                IF NOT EXISTS (SELECT 1 FROM Product WHERE ProductID = 1)
                INSERT INTO Product (ProductName, Price, Description, Category) VALUES 
                ('Pepperoni Pizza', 200000, 'Pizza với pepperoni và phô mai', 'Pizza'),
                ('Hawaiian Pizza', 250000, 'Pizza với dứa và giăm bông', 'Pizza'),
                ('Margherita Pizza', 180000, 'Pizza cổ điển với cà chua và mozzarella', 'Pizza')
            """;
            
            try (Statement stmt = con.createStatement()) {
                stmt.execute(insertCustomer);
                System.out.println("✅ Sample customers inserted");
                
                stmt.execute(insertProduct);
                System.out.println("✅ Sample products inserted");
            }
            
        } catch (Exception e) {
            System.out.println("❌ Error inserting sample customers/products: " + e.getMessage());
        }
    }

    // 🟢 Đếm tổng số đơn hàng
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

    // 🟢 Thêm đơn hàng đơn giản (form thêm)
    public void insert(Order o) {
        String sql = """
            INSERT INTO [Order] 
            (CustomerID, EmployeeID, TableID, OrderDate, Status, PaymentStatus, TotalPrice, Note)
            VALUES (?, ?, ?, GETDATE(), ?, ?, ?, ?)
        """;
        try (Connection con = useConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, o.getCustomerID());
            ps.setInt(2, o.getEmployeeID());
            ps.setInt(3, o.getTableID());
            ps.setInt(4, o.getStatus());
            ps.setString(5, o.getPaymentStatus());
            ps.setDouble(6, o.getTotalPrice());
            ps.setString(7, o.getNote());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // 🟢 Cập nhật đơn hàng (form sửa)
    public void update(Order o) {
        String sql = """
            UPDATE [Order]
            SET CustomerID=?, EmployeeID=?, TableID=?, OrderDate=?, Status=?, PaymentStatus=?, TotalPrice=?, Note=?
            WHERE OrderID=?
        """;
        try (Connection con = useConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            System.out.println("🔄 Updating Order ID: " + o.getOrderID());
            System.out.println("   CustomerID: " + o.getCustomerID());
            System.out.println("   EmployeeID: " + o.getEmployeeID());
            System.out.println("   TableID: " + o.getTableID());
            System.out.println("   Status: " + o.getStatus());
            System.out.println("   PaymentStatus: " + o.getPaymentStatus());
            System.out.println("   TotalPrice: " + o.getTotalPrice());
            System.out.println("   Note: " + o.getNote());
            
            ps.setInt(1, o.getCustomerID());
            ps.setInt(2, o.getEmployeeID());
            ps.setInt(3, o.getTableID());
            
            // Xử lý OrderDate - nếu null thì giữ nguyên
            if (o.getOrderDate() != null) {
                ps.setTimestamp(4, new java.sql.Timestamp(o.getOrderDate().getTime()));
            } else {
                ps.setTimestamp(4, new java.sql.Timestamp(System.currentTimeMillis()));
            }
            
            ps.setInt(5, o.getStatus());
            ps.setString(6, o.getPaymentStatus());
            ps.setDouble(7, o.getTotalPrice());
            ps.setString(8, o.getNote());
            ps.setInt(9, o.getOrderID());
            
            int rowsAffected = ps.executeUpdate();
            System.out.println("✅ Order updated successfully. Rows affected: " + rowsAffected);
            
        } catch (Exception e) {
            System.out.println("❌ Error updating order: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
