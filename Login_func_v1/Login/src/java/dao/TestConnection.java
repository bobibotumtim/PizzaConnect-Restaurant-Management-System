package dao;

import java.sql.*;

public class TestConnection {
    
    public static void main(String[] args) {
        testDatabaseConnection();
        createTablesIfNotExist();
    }
    
    public static void testDatabaseConnection() {
        try {
            DBContext db = new DBContext();
            Connection conn = db.getConnection();
            
            if (conn != null && !conn.isClosed()) {
                System.out.println("✅ Database connection successful!");
                
                // Test query
                String sql = "SELECT COUNT(*) FROM sys.tables WHERE name IN ('Order', 'OrderDetail', 'Product', 'Customer')";
                try (PreparedStatement ps = conn.prepareStatement(sql);
                     ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        int tableCount = rs.getInt(1);
                        System.out.println("📊 Found " + tableCount + " required tables");
                    }
                }
            } else {
                System.out.println("❌ Database connection failed!");
            }
        } catch (Exception e) {
            System.out.println("❌ Database connection error: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    public static void createTablesIfNotExist() {
        try {
            DBContext db = new DBContext();
            Connection conn = db.getConnection();
            
            if (conn == null) {
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
            try (Statement stmt = conn.createStatement()) {
                stmt.execute(createCustomerTable);
                System.out.println("✅ Customer table created/verified");
                
                stmt.execute(createProductTable);
                System.out.println("✅ Product table created/verified");
                
                stmt.execute(createOrderTable);
                System.out.println("✅ Order table created/verified");
                
                stmt.execute(createOrderDetailTable);
                System.out.println("✅ OrderDetail table created/verified");
            }
            
            // Thêm dữ liệu mẫu
            insertSampleData(conn);
            
        } catch (Exception e) {
            System.out.println("❌ Error creating tables: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    private static void insertSampleData(Connection conn) {
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
            
            try (Statement stmt = conn.createStatement()) {
                stmt.execute(insertCustomer);
                System.out.println("✅ Sample customers inserted");
                
                stmt.execute(insertProduct);
                System.out.println("✅ Sample products inserted");
            }
            
        } catch (Exception e) {
            System.out.println("❌ Error inserting sample data: " + e.getMessage());
        }
    }
}
