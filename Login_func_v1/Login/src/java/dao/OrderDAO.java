package dao;

import java.sql.*;
import java.util.*;
import models.*;

public class OrderDAO extends DBContext {

    private Connection externalConn; // ⚙️ Use if servlet passes in (special case)

    // Default constructor (commonly used)
    public OrderDAO() {
        super(); // Very important — opens connection from DBContext
    }

    // ✅ Constructor with parameter (rarely used, only when external connection needed)
    public OrderDAO(Connection conn) {
        this.externalConn = conn;
    }

    // ✅ Get connection function — prioritize external if available
    private Connection useConnection() throws SQLException {
        if (externalConn != null) return externalConn;
        return super.getConnection();
    }

    // 🟢 Create new order with details
    public int createOrder(int customerID, int employeeID, int tableID, String note, List<OrderDetail> orderDetails) throws Exception {
        int orderId = 0;
        Connection con = null;

        try {
            con = useConnection();
            con.setAutoCommit(false);

            // 1️⃣ Create order (CustomerID = NULL for walk-in customers)
            String sqlOrder = """
                INSERT INTO [Order] 
                (CustomerID, EmployeeID, TableID, OrderDate, Status, PaymentStatus, TotalPrice, Note)
                VALUES (?, ?, ?, GETDATE(), 0, 'Unpaid', 0, ?)
            """;
            try (PreparedStatement psOrder = con.prepareStatement(sqlOrder, Statement.RETURN_GENERATED_KEYS)) {
                psOrder.setNull(1, java.sql.Types.INTEGER);  // CustomerID = NULL (will be updated at payment if customer has account)
                psOrder.setInt(2, employeeID);
                psOrder.setInt(3, tableID);
                psOrder.setString(4, note);
                psOrder.executeUpdate();

                try (ResultSet rs = psOrder.getGeneratedKeys()) {
                    if (rs.next()) orderId = rs.getInt(1);
                }
            }

            // 2️⃣ Insert details (if any)
            if (orderDetails != null && !orderDetails.isEmpty()) {
                double totalPrice = 0;
                String sqlDetail = """
                    INSERT INTO [OrderDetail] 
                    (OrderID, ProductSizeID, Quantity, TotalPrice, SpecialInstructions, Status)
                    VALUES (?, ?, ?, ?, ?, 'Waiting')
                """;
                try (PreparedStatement psDetail = con.prepareStatement(sqlDetail)) {
                    for (OrderDetail d : orderDetails) {
                        psDetail.setInt(1, orderId);
                        psDetail.setInt(2, d.getProductSizeID());
                        psDetail.setInt(3, d.getQuantity());
                        psDetail.setDouble(4, d.getTotalPrice());
                        psDetail.setString(5, d.getSpecialInstructions());
                        psDetail.addBatch();
                        totalPrice += d.getTotalPrice();
                    }
                    psDetail.executeBatch();

                    // Update total price (including 10% tax)
                    double totalWithTax = totalPrice * 1.1;
                    System.out.println("🧮 Calculating total: " + totalPrice + " → with tax: " + totalWithTax);
                    String sqlUpdate = "UPDATE [Order] SET TotalPrice = ? WHERE OrderID = ?";
                    try (PreparedStatement psUpdate = con.prepareStatement(sqlUpdate)) {
                        psUpdate.setDouble(1, totalWithTax);
                        psUpdate.setInt(2, orderId);
                        int updated = psUpdate.executeUpdate();
                        System.out.println("✅ Order #" + orderId + " total updated to: " + totalWithTax + " (rows affected: " + updated + ")");
                    }
                }
            }

            // 3️⃣ Update table status to occupied (lowercase for consistency)
            if (tableID > 0) {
                String sqlUpdateTable = "UPDATE [Table] SET Status = 'occupied' WHERE TableID = ?";
                try (PreparedStatement psTable = con.prepareStatement(sqlUpdateTable)) {
                    psTable.setInt(1, tableID);
                    int rowsUpdated = psTable.executeUpdate();
                    if (rowsUpdated > 0) {
                        System.out.println("✅ Table #" + tableID + " set to occupied (Order #" + orderId + " created)");
                    } else {
                        System.err.println("⚠️ Failed to update table status for Table #" + tableID);
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
            // ⚙️ Close connection only if not external connection
            if (externalConn == null && con != null) con.close();
        }
    }

    // 🟢 Get list of orders by status
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

    // 🟢 Get all orders
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

        return list;
    }



    // 🟢 Get order by ID
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

    // 🟢 Get order details list – use passed connection (don't close parent connection)
    // 🆕 UPDATED: Loại trừ món bị Cancelled khi hiển thị
    private List<OrderDetail> getOrderDetailsByOrderId(int orderId, Connection con) {
        List<OrderDetail> list = new ArrayList<>();
        String sql = """
            SELECT od.*, p.ProductName, ps.SizeName, ps.SizeCode
            FROM OrderDetail od
            LEFT JOIN ProductSize ps ON od.ProductSizeID = ps.ProductSizeID
            LEFT JOIN Product p ON ps.ProductID = p.ProductID
            WHERE od.OrderID = ? AND od.Status != 'Cancelled'
            ORDER BY od.OrderDetailID
        """;
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    OrderDetail detail = new OrderDetail();
                    detail.setOrderDetailID(rs.getInt("OrderDetailID"));
                    detail.setOrderID(rs.getInt("OrderID"));
                    detail.setProductSizeID(rs.getInt("ProductSizeID"));
                    detail.setQuantity(rs.getInt("Quantity"));
                    detail.setTotalPrice(rs.getDouble("TotalPrice"));
                    detail.setSpecialInstructions(rs.getString("SpecialInstructions"));
                    detail.setEmployeeID(rs.getInt("EmployeeID"));
                    detail.setStatus(rs.getString("Status"));
                    detail.setStartTime(rs.getTimestamp("StartTime"));
                    detail.setEndTime(rs.getTimestamp("EndTime"));
                    
                    // Thông tin bổ sung để hiển thị
                    detail.setProductName(rs.getString("ProductName"));
                    detail.setSizeName(rs.getString("SizeName"));
                    detail.setSizeCode(rs.getString("SizeCode"));
                    
                    list.add(detail);
                }
            }
        } catch (Exception e) {
            System.out.println("Error getting order details: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    // 🟢 Get order details list – Public API (use separate connection, safe when called independently)
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

    // 🟢 Update order status
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

    // 🟢 Update payment status
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

    // 🟢 Update order status, payment and note
    public boolean updateOrderStatusPaymentAndNote(int orderId, int status, String paymentStatus, String note) {
        String sql = "UPDATE [Order] SET Status = ?, PaymentStatus = ?, Note = ? WHERE OrderID = ?";
        try (Connection con = useConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, status);
            ps.setString(2, paymentStatus);
            ps.setString(3, note);
            ps.setInt(4, orderId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // 🟢 Delete order (and details)
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

    // 🟢 Insert sample data for testing
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
    
    // 🟢 Create tables if not exist
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

    // 🟢 Count total orders
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

    // 🟢 Insert simple order (add form)
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

    // 🟢 Update order (edit form)
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
            
            // Force commit nếu autocommit = false
            if (!con.getAutoCommit()) {
                con.commit();
                System.out.println("✅ Transaction committed");
            }
            
        } catch (Exception e) {
            System.out.println("❌ Error updating order: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    // 🟢 Simple method to only update status and payment
    public boolean updateOrderStatusAndPayment(int orderId, int status, String paymentStatus) {
        String sql = "UPDATE [Order] SET Status=?, PaymentStatus=? WHERE OrderID=?";
        try (Connection con = useConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            System.out.println("🔄 Quick update Order ID: " + orderId + ", Status: " + status + ", Payment: " + paymentStatus);
            
            ps.setInt(1, status);
            ps.setString(2, paymentStatus);
            ps.setInt(3, orderId);
            
            int rowsAffected = ps.executeUpdate();
            System.out.println("✅ Quick update successful. Rows affected: " + rowsAffected);
            
            // Force commit
            if (!con.getAutoCommit()) {
                con.commit();
                System.out.println("✅ Transaction committed");
            }
            
            return rowsAffected > 0;
            
        } catch (Exception e) {
            System.out.println("❌ Error in quick update: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    // 🟢 Get next customer ID
    public int getNextCustomerId() {
        String sql = "SELECT ISNULL(MAX(CustomerID), 0) + 1 FROM [Order]";
        try (Connection con = useConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 1; // fallback
    }
    
    // 🟢 Create order with auto-increment customer ID
    public int createOrderWithAutoCustomerId(int employeeID, int tableID, String note, List<OrderDetail> orderDetails) throws Exception {
        int orderId = 0;
        Connection con = null;

        try {
            con = useConnection();
            con.setAutoCommit(false);

            // 1️⃣ CustomerID = NULL for walk-in customers (will be updated at payment)
            System.out.println("✅ Creating order with CustomerID = NULL (walk-in customer)");

            // 2️⃣ Tạo đơn hàng
            String sqlOrder = """
                INSERT INTO [Order] 
                (CustomerID, EmployeeID, TableID, OrderDate, Status, PaymentStatus, TotalPrice, Note)
                VALUES (?, ?, ?, GETDATE(), 0, 'Unpaid', 0, ?)
            """;
            try (PreparedStatement psOrder = con.prepareStatement(sqlOrder, Statement.RETURN_GENERATED_KEYS)) {
                psOrder.setNull(1, java.sql.Types.INTEGER);  // CustomerID = NULL
                psOrder.setInt(2, employeeID);
                psOrder.setInt(3, tableID);
                psOrder.setString(4, note);
                psOrder.executeUpdate();

                try (ResultSet rs = psOrder.getGeneratedKeys()) {
                    if (rs.next()) orderId = rs.getInt(1);
                }
            }

            // 3️⃣ Chèn chi tiết (nếu có)
            if (orderDetails != null && !orderDetails.isEmpty()) {
                double totalPrice = 0;
                String sqlDetail = """
                    INSERT INTO [OrderDetail] 
                    (OrderID, ProductSizeID, Quantity, TotalPrice, SpecialInstructions, Status)
                    VALUES (?, ?, ?, ?, ?, 'Waiting')
                """;
                try (PreparedStatement psDetail = con.prepareStatement(sqlDetail)) {
                    for (OrderDetail d : orderDetails) {
                        psDetail.setInt(1, orderId);
                        psDetail.setInt(2, d.getProductSizeID());
                        psDetail.setInt(3, d.getQuantity());
                        psDetail.setDouble(4, d.getTotalPrice());
                        psDetail.setString(5, d.getSpecialInstructions());
                        psDetail.addBatch();
                        totalPrice += d.getTotalPrice();
                    }
                    psDetail.executeBatch();

                    // Cập nhật tổng tiền (including 10% tax)
                    double totalWithTax = totalPrice * 1.1;
                    System.out.println("🧮 [Alternative] Calculating total: " + totalPrice + " → with tax: " + totalWithTax);
                    String sqlUpdate = "UPDATE [Order] SET TotalPrice = ? WHERE OrderID = ?";
                    try (PreparedStatement psUpdate = con.prepareStatement(sqlUpdate)) {
                        psUpdate.setDouble(1, totalWithTax);
                        psUpdate.setInt(2, orderId);
                        int updated = psUpdate.executeUpdate();
                        System.out.println("✅ [Alternative] Order #" + orderId + " total updated to: " + totalWithTax + " (rows affected: " + updated + ")");
                        psUpdate.executeUpdate();
                    }
                }
            }

            con.commit();
            System.out.println("✅ Order created successfully with ID: " + orderId);
            return orderId;

        } catch (Exception e) {
            if (con != null) con.rollback();
            System.out.println("❌ Error creating order: " + e.getMessage());
            e.printStackTrace();
            throw e;
        } finally {
            if (externalConn == null && con != null) {
                con.setAutoCommit(true);
                con.close();
            }
        }
    }
    
    // 🟢 Ensure sample products exist in database
    public void ensureSampleProducts() {
        try (Connection con = useConnection()) {
            // Kiểm tra xem đã có products chưa
            String checkSql = "SELECT COUNT(*) FROM Product";
            try (PreparedStatement ps = con.prepareStatement(checkSql);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next() && rs.getInt(1) > 0) {
                    return; // Đã có products
                }
            }
            
            // Tạo sample products
            String insertSql = """
                INSERT INTO Product (ProductName, Price, Description, Category) VALUES 
                ('Pepperoni Pizza', 25.00, 'Classic pepperoni pizza', 'Pizza'),
                ('Hawaiian Pizza', 28.00, 'Ham and pineapple pizza', 'Pizza'),
                ('Margherita Pizza', 22.00, 'Fresh mozzarella and basil', 'Pizza')
            """;
            
            try (PreparedStatement ps = con.prepareStatement(insertSql)) {
                ps.executeUpdate();
                System.out.println("✅ Sample products created");
            }
            
        } catch (Exception e) {
            System.out.println("⚠️ Error creating sample products: " + e.getMessage());
        }
    }
    
    // 🟢 Ensure sample orders exist in database
    public void ensureSampleOrders() {
        try (Connection con = useConnection()) {
            // Kiểm tra xem đã có orders chưa
            String checkSql = "SELECT COUNT(*) FROM [Order]";
            try (PreparedStatement ps = con.prepareStatement(checkSql);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next() && rs.getInt(1) > 0) {
                    return; // Đã có orders
                }
            }
            
            // Tạo sample customers trước (nếu chưa có)
            String insertCustomerSql = """
                IF NOT EXISTS (SELECT 1 FROM Customer WHERE CustomerID = 1)
                INSERT INTO Customer (UserID, LoyaltyPoint) VALUES 
                (4, 0),
                (5, 0),
                (6, 0)
            """;
            
            try (PreparedStatement ps = con.prepareStatement(insertCustomerSql)) {
                ps.executeUpdate();
                System.out.println("✅ Sample customers ensured");
            }
            
            // Tạo sample orders
            String insertOrderSql = """
                INSERT INTO [Order] (CustomerID, EmployeeID, TableID, OrderDate, Status, PaymentStatus, TotalPrice, Note) VALUES 
                (1, 1, 1, GETDATE(), 0, 'Unpaid', 25.00, 'Sample order 1'),
                (2, 1, 2, GETDATE(), 1, 'Unpaid', 56.00, 'Sample order 2'),
                (3, 1, 3, GETDATE(), 2, 'Paid', 22.00, 'Sample order 3')
            """;
            
            try (PreparedStatement ps = con.prepareStatement(insertOrderSql)) {
                ps.executeUpdate();
                System.out.println("✅ Sample orders created");
            }
            
            // Tạo sample order details
            String insertDetailSql = """
                INSERT INTO OrderDetail (OrderID, ProductID, Quantity, TotalPrice, SpecialInstructions) VALUES 
                (1, 1, 1, 25.00, 'Loại: Pepperoni'),
                (2, 2, 2, 56.00, 'Loại: Hawaiian'),
                (3, 3, 1, 22.00, 'Loại: Margherita')
            """;
            
            try (PreparedStatement ps = con.prepareStatement(insertDetailSql)) {
                ps.executeUpdate();
                System.out.println("✅ Sample order details created");
            }
            
        } catch (Exception e) {
            System.out.println("⚠️ Error creating sample orders: " + e.getMessage());
        }
    }
    
    // 🟢 Get orders with pagination
    public List<Order> getOrdersWithPagination(int page, int pageSize) {
        List<Order> list = new ArrayList<>();
        int offset = (page - 1) * pageSize;
        String sql = "SELECT * FROM [Order] ORDER BY OrderDate DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        try (Connection con = useConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, offset);
            ps.setInt(2, pageSize);
            
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
                    
                    // Load OrderDetails
                    List<OrderDetail> details = getOrderDetailsByOrderId(o.getOrderID(), con);
                    o.setDetails(details);
                    
                    list.add(o);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        System.out.println("✅ Orders loaded with pagination (page " + page + "): " + list.size());
        return list;
    }
    
    // 🟢 Get orders by status with pagination
    public List<Order> getOrdersByStatusWithPagination(int status, int page, int pageSize) {
        List<Order> list = new ArrayList<>();
        int offset = (page - 1) * pageSize;
        String sql = "SELECT * FROM [Order] WHERE Status = ? ORDER BY OrderDate DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        try (Connection con = useConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, status);
            ps.setInt(2, offset);
            ps.setInt(3, pageSize);
            
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
                    
                    // Load OrderDetails
                    List<OrderDetail> details = getOrderDetailsByOrderId(o.getOrderID(), con);
                    o.setDetails(details);
                    
                    list.add(o);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        System.out.println("✅ Orders loaded by status " + status + " with pagination (page " + page + "): " + list.size());
        return list;
    }
    
    // 🟢 Count orders by status
    public int countOrdersByStatus(int status) {
        String sql = "SELECT COUNT(*) FROM [Order] WHERE Status = ?";
        try (Connection con = useConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, status);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Add items to existing order
     * Used when waiter adds more items to an order from POS
     */
    public List<Integer> addItemsToOrder(int orderId, List<OrderDetail> newItems) throws Exception {
        Connection con = null;
        List<Integer> newOrderDetailIds = new ArrayList<>();
        
        try {
            con = useConnection();
            con.setAutoCommit(false);
            
            // Insert new order details and get generated IDs
            String sqlDetail = """
                INSERT INTO [OrderDetail] 
                (OrderID, ProductSizeID, Quantity, TotalPrice, SpecialInstructions, Status)
                VALUES (?, ?, ?, ?, ?, 'Waiting')
            """;
            
            double additionalTotal = 0;
            try (PreparedStatement psDetail = con.prepareStatement(sqlDetail, Statement.RETURN_GENERATED_KEYS)) {
                for (OrderDetail d : newItems) {
                    psDetail.setInt(1, orderId);
                    psDetail.setInt(2, d.getProductSizeID());
                    psDetail.setInt(3, d.getQuantity());
                    psDetail.setDouble(4, d.getTotalPrice());
                    psDetail.setString(5, d.getSpecialInstructions());
                    psDetail.executeUpdate();
                    
                    // Get generated OrderDetailID
                    try (ResultSet rs = psDetail.getGeneratedKeys()) {
                        if (rs.next()) {
                            int newDetailId = rs.getInt(1);
                            newOrderDetailIds.add(newDetailId);
                            System.out.println("  ✅ Created OrderDetail #" + newDetailId);
                        }
                    }
                    
                    additionalTotal += d.getTotalPrice();
                }
            }
            
            // Update total price of order (including 10% tax for new items)
            double additionalWithTax = additionalTotal * 1.1;
            System.out.println("🧮 [Add Items] Additional total: " + additionalTotal + " → with tax: " + additionalWithTax);
            String sqlUpdate = "UPDATE [Order] SET TotalPrice = TotalPrice + ? WHERE OrderID = ?";
            try (PreparedStatement psUpdate = con.prepareStatement(sqlUpdate)) {
                psUpdate.setDouble(1, additionalWithTax);
                psUpdate.setInt(2, orderId);
                int updated = psUpdate.executeUpdate();
                System.out.println("✅ [Add Items] Order #" + orderId + " total updated (added: " + additionalWithTax + ", rows affected: " + updated + ")");
            }
            
            con.commit();
            System.out.println("✅ Added " + newItems.size() + " items to Order #" + orderId);
            return newOrderDetailIds;
            
        } catch (Exception e) {
            if (con != null) con.rollback();
            System.err.println("❌ Error adding items to order: " + e.getMessage());
            e.printStackTrace();
            throw e;
        } finally {
            if (externalConn == null && con != null) con.close();
        }
    }

    /**
     * Get order with all details (for editing in POS)
     */
    public Order getOrderWithDetails(int orderId) throws SQLException {
        Order order = getOrderById(orderId);
        if (order != null) {
            List<OrderDetail> details = getOrderDetailsByOrderId(orderId);
            
            // Load toppings for each order detail
            OrderDetailToppingDAO toppingDAO = new OrderDetailToppingDAO();
            for (OrderDetail detail : details) {
                List<OrderDetailTopping> toppings = toppingDAO.getToppingsByOrderDetailID(detail.getOrderDetailID());
                detail.setToppings(toppings);
            }
            
            order.setDetails(details);
        }
        return order;
    }
    
    /**
     * 🟢 Auto-update Order status khi waiter serve món
     * Logic:
     * - Nếu có ít nhất 1 món Served → Order status = 2 (Dining)
     * - Order chỉ chuyển sang Completed (3) khi click "Mark as Paid" trong ManageOrders
     */
    public boolean autoUpdateOrderStatusIfAllServed(int orderId) {
        String sql = """
            SELECT 
                COUNT(*) as TotalItems,
                SUM(CASE WHEN Status = 'Served' THEN 1 ELSE 0 END) as ServedItems
            FROM OrderDetail
            WHERE OrderID = ? AND Status != 'Cancelled'
        """;
        
        try (Connection con = useConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int totalItems = rs.getInt("TotalItems");
                    int servedItems = rs.getInt("ServedItems");
                    
                    System.out.println("🔍 DEBUG Order #" + orderId + " - Total: " + totalItems + ", Served: " + servedItems);
                    
                    // Lấy current order status
                    Order order = getOrderById(orderId);
                    if (order == null) {
                        System.err.println("❌ Order #" + orderId + " not found!");
                        return false;
                    }
                    
                    int currentStatus = order.getStatus();
                    int newStatus = currentStatus;
                    
                    System.out.println("🔍 DEBUG Order #" + orderId + " - Current Status: " + currentStatus);
                    
                    // Logic: Nếu có món đã serve → Dining (không tự động chuyển Completed)
                    if (servedItems > 0) {
                        // Có món đã serve → Dining
                        newStatus = 2;
                        System.out.println("🔍 DEBUG Order #" + orderId + " - Should be Dining (2) - Served: " + servedItems + "/" + totalItems);
                    }
                    
                    // Chỉ update nếu status thay đổi và order đang ở Ready hoặc Dining
                    // Không tự động chuyển sang Completed - cần click "Mark as Paid"
                    if (newStatus != currentStatus && currentStatus >= 1 && currentStatus < 3) {
                        boolean updated = updateOrderStatus(orderId, newStatus);
                        if (updated) {
                            System.out.println("✅ Auto-updated Order #" + orderId + " status: " + 
                                             currentStatus + " → " + newStatus + 
                                             " (Served: " + servedItems + "/" + totalItems + ")");
                        }
                        return updated;
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("❌ Error auto-updating order status after serve: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
    
    // 🟢 Lấy danh sách Order theo TableID (chưa hoàn thành)
    public List<Order> getOrdersByTableId(int tableId) {
        List<Order> orders = new ArrayList<>();
        String sql = """
            SELECT o.*, c.LoyaltyPoint, u.Name as CustomerName
            FROM [Order] o
            LEFT JOIN Customer c ON o.CustomerID = c.CustomerID
            LEFT JOIN [User] u ON c.UserID = u.UserID
            WHERE o.TableID = ? AND o.Status < 4
            ORDER BY o.OrderDate DESC
        """;
        
        try (Connection con = useConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, tableId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order order = new Order();
                    order.setOrderID(rs.getInt("OrderID"));
                    order.setCustomerID(rs.getInt("CustomerID"));
                    order.setEmployeeID(rs.getInt("EmployeeID"));
                    order.setTableID(rs.getInt("TableID"));
                    order.setOrderDate(rs.getTimestamp("OrderDate"));
                    order.setStatus(rs.getInt("Status"));
                    order.setPaymentStatus(rs.getString("PaymentStatus"));
                    order.setTotalPrice(rs.getDouble("TotalPrice"));
                    order.setNote(rs.getString("Note"));
                    orders.add(order);
                }
            }
        } catch (Exception e) {
            System.out.println("Error getting orders by table: " + e.getMessage());
        }
        return orders;
    }

    // 🟢 Get orders by customer ID with pagination (for user profile)
    public List<Object[]> getOrdersByCustomerId(int customerId, int page, int pageSize) {
        List<Object[]> orders = new ArrayList<>();
        int offset = (page - 1) * pageSize;

        String sql = """
                    SELECT
                        o.OrderID, o.OrderDate, o.TotalPrice, o.Status, o.PaymentStatus, o.Note,
                        t.TableNumber,
                        COUNT(od.OrderDetailID) as ItemCount,
                        u.Name as CustomerName
                    FROM [Order] o
                    LEFT JOIN [Table] t ON o.TableID = t.TableID
                    LEFT JOIN OrderDetail od ON o.OrderID = od.OrderID
                    LEFT JOIN Customer c ON o.CustomerID = c.CustomerID
                    LEFT JOIN [User] u ON c.UserID = u.UserID
                    WHERE o.CustomerID = ?
                    GROUP BY o.OrderID, o.OrderDate, o.TotalPrice, o.Status, o.PaymentStatus, o.Note, t.TableNumber, u.Name
                    ORDER BY o.OrderDate DESC
                    OFFSET ? ROWS FETCH NEXT ? ROWS ONLY
                """;

        try (Connection con = useConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, customerId);
            ps.setInt(2, offset);
            ps.setInt(3, pageSize);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Object[] orderData = new Object[] {
                            rs.getInt("OrderID"),
                            rs.getTimestamp("OrderDate"),
                            rs.getDouble("TotalPrice"),
                            rs.getInt("Status"),
                            rs.getString("PaymentStatus"),
                            rs.getString("Note"),
                            rs.getString("TableNumber"),
                            rs.getInt("ItemCount"),
                            rs.getString("CustomerName")
                    };
                    orders.add(orderData);
                }
            }

        } catch (Exception e) {
            System.out.println("❌ Error getting orders by customer ID: " + e.getMessage());
            e.printStackTrace();
        }

        System.out.println("✅ Orders loaded for customer " + customerId + " (page " + page + "): " + orders.size());
        return orders;
    }

    // 🟢 Count total orders by customer ID
    public int getOrdersCountByCustomerId(int customerId) {
        String sql = "SELECT COUNT(*) FROM [Order] WHERE CustomerID = ?";

        try (Connection con = useConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }

        } catch (Exception e) {
            System.out.println("❌ Error counting orders by customer ID: " + e.getMessage());
            e.printStackTrace();
        }
        return 0;
    }
    
    /**
     * 🆕 Tự động cập nhật Order status dựa trên OrderDetail status
     * Logic:
     * - Nếu có OrderDetail nào status = 'Waiting' hoặc 'Preparing' → Order status = 0 (Waiting)
     * - Nếu tất cả OrderDetail status = 'Ready' → Order status = 1 (Ready)
     * - Không tự động chuyển sang Dining (2) - cần waiter click button "Serve"
     * 
     * @param orderId Order ID cần cập nhật
     * @return true nếu cập nhật thành công
     */
    public boolean autoUpdateOrderStatusBasedOnDetails(int orderId) {
        String sql = """
            SELECT 
                COUNT(*) as TotalItems,
                SUM(CASE WHEN Status IN ('Waiting', 'Preparing') THEN 1 ELSE 0 END) as NotReadyItems,
                SUM(CASE WHEN Status = 'Ready' THEN 1 ELSE 0 END) as ReadyItems
            FROM OrderDetail
            WHERE OrderID = ? AND Status != 'Cancelled'
        """;
        
        try (Connection con = useConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int totalItems = rs.getInt("TotalItems");
                    int notReadyItems = rs.getInt("NotReadyItems");
                    int readyItems = rs.getInt("ReadyItems");
                    
                    // Lấy current order status
                    Order order = getOrderById(orderId);
                    if (order == null) return false;
                    
                    int currentStatus = order.getStatus();
                    int newStatus = currentStatus;
                    
                    // Logic tự động cập nhật
                    if (notReadyItems > 0) {
                        // Có món đang chờ hoặc đang làm → Waiting
                        newStatus = 0;
                    } else if (readyItems == totalItems && totalItems > 0) {
                        // Tất cả món đã Ready → Ready (chỉ khi đang ở Waiting)
                        if (currentStatus == 0) {
                            newStatus = 1;
                        }
                    }
                    
                    // Chỉ update nếu status thay đổi
                    if (newStatus != currentStatus && currentStatus < 2) {
                        // Chỉ auto-update khi order đang ở Waiting (0) hoặc Ready (1)
                        // Không tự động thay đổi khi đã Dining (2), Completed (3), Cancelled (4)
                        boolean updated = updateOrderStatus(orderId, newStatus);
                        if (updated) {
                            System.out.println("✅ Auto-updated Order #" + orderId + " status: " + 
                                             currentStatus + " → " + newStatus + 
                                             " (Not Ready: " + notReadyItems + ", Ready: " + readyItems + ")");
                        }
                        return updated;
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("❌ Error auto-updating order status: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    /**
     * 🆕 Tự động tính lại TotalPrice của Order dựa trên OrderDetail (loại trừ món Cancelled)
     * Logic:
     * - Tính tổng TotalPrice của các OrderDetail có Status != 'Cancelled'
     * - Cộng thêm 10% thuế
     * - Cập nhật vào Order.TotalPrice
     * 
     * @param orderId Order ID cần recalculate
     * @return true nếu cập nhật thành công
     */
    public boolean recalculateOrderTotalPrice(int orderId) {
        String sqlCalculate = """
            SELECT ISNULL(SUM(TotalPrice), 0) as SubTotal
            FROM OrderDetail
            WHERE OrderID = ? AND Status != 'Cancelled'
        """;
        
        try (Connection con = useConnection();
             PreparedStatement ps = con.prepareStatement(sqlCalculate)) {
            
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    double subTotal = rs.getDouble("SubTotal");
                    double totalWithTax = subTotal * 1.1; // Cộng 10% thuế
                    
                    // Cập nhật TotalPrice vào Order
                    String sqlUpdate = "UPDATE [Order] SET TotalPrice = ? WHERE OrderID = ?";
                    try (PreparedStatement psUpdate = con.prepareStatement(sqlUpdate)) {
                        psUpdate.setDouble(1, totalWithTax);
                        psUpdate.setInt(2, orderId);
                        int updated = psUpdate.executeUpdate();
                        
                        if (updated > 0) {
                            System.out.println("✅ Recalculated Order #" + orderId + " total: " + 
                                             subTotal + " → with tax: " + totalWithTax);
                            return true;
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("❌ Error recalculating order total price: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    // 🟢 Get all orders by customer ID (for Order History)
    public List<Order> getOrdersByCustomerId(int customerId) {
        List<Order> orders = new ArrayList<>();
        String sql = """
            SELECT o.*, t.TableNumber
            FROM [Order] o
            LEFT JOIN [Table] t ON o.TableID = t.TableID
            WHERE o.CustomerID = ?
            ORDER BY o.OrderDate DESC
        """;

        try (Connection con = useConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, customerId);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order order = new Order();
                    order.setOrderID(rs.getInt("OrderID"));
                    order.setCustomerID(rs.getInt("CustomerID"));
                    order.setEmployeeID(rs.getInt("EmployeeID"));
                    order.setTableID(rs.getInt("TableID"));
                    order.setOrderDate(rs.getTimestamp("OrderDate"));
                    order.setStatus(rs.getInt("Status"));
                    order.setPaymentStatus(rs.getString("PaymentStatus"));
                    order.setTotalPrice(rs.getDouble("TotalPrice"));
                    order.setNote(rs.getString("Note"));
                    
                    // Load OrderDetails for each order
                    List<OrderDetail> details = getOrderDetailsByOrderId(order.getOrderID(), con);
                    order.setDetails(details);
                    
                    orders.add(order);
                }
            }

        } catch (Exception e) {
            System.err.println("❌ Error getting orders by customer ID: " + e.getMessage());
            e.printStackTrace();
        }

        System.out.println("✅ Loaded " + orders.size() + " orders for customer #" + customerId);
        return orders;
    }

    // 🟢 Get orders by customer ID with pagination (for Order History)
    public List<Order> getOrdersByCustomerIdWithPagination(int customerId, int page, int pageSize) {
        List<Order> orders = new ArrayList<>();
        int offset = (page - 1) * pageSize;
        
        String sql = """
            SELECT o.*, t.TableNumber
            FROM [Order] o
            LEFT JOIN [Table] t ON o.TableID = t.TableID
            WHERE o.CustomerID = ?
            ORDER BY o.OrderDate DESC
            OFFSET ? ROWS FETCH NEXT ? ROWS ONLY
        """;

        try (Connection con = useConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, customerId);
            ps.setInt(2, offset);
            ps.setInt(3, pageSize);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order order = new Order();
                    order.setOrderID(rs.getInt("OrderID"));
                    order.setCustomerID(rs.getInt("CustomerID"));
                    order.setEmployeeID(rs.getInt("EmployeeID"));
                    order.setTableID(rs.getInt("TableID"));
                    order.setOrderDate(rs.getTimestamp("OrderDate"));
                    order.setStatus(rs.getInt("Status"));
                    order.setPaymentStatus(rs.getString("PaymentStatus"));
                    order.setTotalPrice(rs.getDouble("TotalPrice"));
                    order.setNote(rs.getString("Note"));
                    
                    // Load OrderDetails for each order
                    List<OrderDetail> details = getOrderDetailsByOrderId(order.getOrderID(), con);
                    order.setDetails(details);
                    
                    orders.add(order);
                }
            }

        } catch (Exception e) {
            System.err.println("❌ Error getting paginated orders by customer ID: " + e.getMessage());
            e.printStackTrace();
        }

        System.out.println("✅ Loaded " + orders.size() + " orders for customer #" + customerId + " (page " + page + ")");
        return orders;
    }

    // ===== FEEDBACK CONTEXT HELPER METHODS =====

    /**
     * Lấy thông tin order với customer details cho feedback context
     * @param orderId ID của order
     * @return Map chứa thông tin order và customer, hoặc null nếu không tìm thấy
     */
    public Map<String, Object> getOrderDetailsForFeedback(int orderId) {
        String sql = """
            SELECT 
                o.OrderID, o.CustomerID, o.OrderDate, o.TotalPrice, o.Status, o.PaymentStatus,
                c.CustomerID, u.UserID, u.Name as CustomerName, u.Email, u.Phone
            FROM [Order] o
            LEFT JOIN Customer c ON o.CustomerID = c.CustomerID
            LEFT JOIN [User] u ON c.UserID = u.UserID
            WHERE o.OrderID = ?
        """;
        
        try (Connection con = useConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, orderId);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Map<String, Object> orderInfo = new HashMap<>();
                    
                    // Order information
                    orderInfo.put("orderId", rs.getInt("OrderID"));
                    orderInfo.put("customerID", rs.getInt("CustomerID"));
                    orderInfo.put("orderDate", rs.getTimestamp("OrderDate"));
                    orderInfo.put("totalPrice", rs.getDouble("TotalPrice"));
                    orderInfo.put("status", rs.getInt("Status"));
                    orderInfo.put("paymentStatus", rs.getString("PaymentStatus"));
                    
                    // Customer information
                    String customerName = rs.getString("CustomerName");
                    if (customerName != null && !customerName.isEmpty()) {
                        orderInfo.put("customerName", customerName);
                        orderInfo.put("email", rs.getString("Email"));
                        orderInfo.put("phone", rs.getString("Phone"));
                        orderInfo.put("isGuest", false);
                    } else {
                        // Guest customer
                        orderInfo.put("customerName", "Guest Customer");
                        orderInfo.put("customerId", "GUEST_" + orderId);
                        orderInfo.put("isGuest", true);
                    }
                    
                    return orderInfo;
                }
            }
            
        } catch (Exception e) {
            System.err.println("❌ Error getting order details for feedback: " + e.getMessage());
            e.printStackTrace();
        }
        
        return null;
    }

    /**
     * Lấy danh sách tên món ăn trong order (để hiển thị trong feedback form)
     * 🆕 UPDATED: Loại trừ món bị Cancelled
     * @param orderId ID của order
     * @return String chứa danh sách tên món, cách nhau bởi dấu phẩy
     */
    public String getOrderItemsSummary(int orderId) {
        String sql = """
            SELECT 
                p.ProductName, 
                ps.SizeName,
                od.Quantity
            FROM OrderDetail od
            LEFT JOIN ProductSize ps ON od.ProductSizeID = ps.ProductSizeID
            LEFT JOIN Product p ON ps.ProductID = p.ProductID
            WHERE od.OrderID = ? AND od.Status != 'Cancelled'
            ORDER BY od.OrderDetailID
        """;
        
        StringBuilder summary = new StringBuilder();
        
        try (Connection con = useConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, orderId);
            
            try (ResultSet rs = ps.executeQuery()) {
                boolean first = true;
                while (rs.next()) {
                    if (!first) {
                        summary.append(", ");
                    }
                    
                    String productName = rs.getString("ProductName");
                    String sizeName = rs.getString("SizeName");
                    int quantity = rs.getInt("Quantity");
                    
                    summary.append(quantity).append("x ");
                    if (productName != null) {
                        summary.append(productName);
                    }
                    if (sizeName != null && !sizeName.isEmpty()) {
                        summary.append(" (").append(sizeName).append(")");
                    }
                    
                    first = false;
                }
            }
            
        } catch (Exception e) {
            System.err.println("❌ Error getting order items summary: " + e.getMessage());
            e.printStackTrace();
        }
        
        return summary.length() > 0 ? summary.toString() : "No items";
    }

    /**
     * Lấy thông tin customer từ order (hỗ trợ cả logged-in và guest customers)
     * @param orderId ID của order
     * @return Map chứa thông tin customer
     */
    public Map<String, Object> getCustomerInfoFromOrder(int orderId) {
        String sql = """
            SELECT 
                o.CustomerID, o.OrderID,
                c.CustomerID, u.UserID, u.Name, u.Email, u.Phone
            FROM [Order] o
            LEFT JOIN Customer c ON o.CustomerID = c.CustomerID
            LEFT JOIN [User] u ON c.UserID = u.UserID
            WHERE o.OrderID = ?
        """;
        
        try (Connection con = useConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, orderId);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Map<String, Object> customerInfo = new HashMap<>();
                    
                    String userName = rs.getString("Name");
                    
                    if (userName != null && !userName.isEmpty()) {
                        // Logged-in customer
                        customerInfo.put("customerId", String.valueOf(rs.getInt("CustomerID")));
                        customerInfo.put("customerName", userName);
                        customerInfo.put("email", rs.getString("Email"));
                        customerInfo.put("phone", rs.getString("Phone"));
                        customerInfo.put("isGuest", false);
                    } else {
                        // Guest customer
                        customerInfo.put("customerId", "GUEST_" + orderId);
                        customerInfo.put("customerName", "Guest Customer");
                        customerInfo.put("isGuest", true);
                    }
                    
                    return customerInfo;
                }
            }
            
        } catch (Exception e) {
            System.err.println("❌ Error getting customer info from order: " + e.getMessage());
            e.printStackTrace();
        }
        
        return null;
    }

    /**
     * Kiểm tra xem order có tồn tại và đã thanh toán chưa
     * @param orderId ID của order
     * @return true nếu order tồn tại và đã thanh toán
     */
    public boolean isOrderPaid(int orderId) {
        String sql = "SELECT PaymentStatus FROM [Order] WHERE OrderID = ?";
        
        try (Connection con = useConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, orderId);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String paymentStatus = rs.getString("PaymentStatus");
                    return "Paid".equalsIgnoreCase(paymentStatus);
                }
            }
            
        } catch (Exception e) {
            System.err.println("❌ Error checking order payment status: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }
}
