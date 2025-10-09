-- Pizza Orders Database Script
-- Thêm vào database pizza_demo_DB hiện có

USE pizza_demo_DB;
GO

-- Tạo bảng Products (Pizza Menu) - chỉ tạo nếu chưa tồn tại
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Products' AND xtype='U')
CREATE TABLE Products (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    ProductName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(500),
    Price DECIMAL(10,2) NOT NULL,
    Category NVARCHAR(50), -- Pizza, Drink, Side, etc.
    ImageURL NVARCHAR(255),
    IsAvailable BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE()
);

-- Tạo bảng Orders (Đơn hàng) - chỉ tạo nếu chưa tồn tại
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Orders' AND xtype='U')
CREATE TABLE Orders (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    StaffID INT NOT NULL,
    TableNumber NVARCHAR(10),
    OrderDate DATETIME DEFAULT GETDATE(),
    Status INT NOT NULL, -- 0=Pending, 1=Processing, 2=Completed, 3=Cancelled
    TotalMoney DECIMAL(10,2) NOT NULL,
    PaymentStatus NVARCHAR(20) DEFAULT 'Unpaid', -- Unpaid, Paid, Refunded
    CustomerName NVARCHAR(100),
    CustomerPhone NVARCHAR(20),
    Notes NVARCHAR(500),
    FOREIGN KEY (StaffID) REFERENCES [User](UserID)
);

-- Tạo bảng OrderDetails (Chi tiết đơn hàng) - chỉ tạo nếu chưa tồn tại
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='OrderDetails' AND xtype='U')
CREATE TABLE OrderDetails (
    OrderDetailID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,
    TotalPrice DECIMAL(10,2) NOT NULL,
    SpecialInstructions NVARCHAR(200),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) ON DELETE CASCADE,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- Thêm dữ liệu mẫu cho Products (chỉ thêm nếu chưa có)
IF NOT EXISTS (SELECT * FROM Products WHERE ProductName = 'Margherita Pizza')
INSERT INTO Products (ProductName, Description, Price, Category, IsAvailable) VALUES
('Margherita Pizza', 'Classic tomato sauce, mozzarella, fresh basil', 15.99, 'Pizza', 1),
('Pepperoni Pizza', 'Tomato sauce, mozzarella, pepperoni', 18.99, 'Pizza', 1),
('BBQ Chicken Pizza', 'BBQ sauce, chicken, red onions, mozzarella', 21.99, 'Pizza', 1),
('Vegetarian Pizza', 'Tomato sauce, mixed vegetables, mozzarella', 17.99, 'Pizza', 1),
('Supreme Pizza', 'Pepperoni, sausage, peppers, onions, mushrooms', 24.99, 'Pizza', 1),
('Coca Cola', 'Refreshing cola drink', 3.99, 'Drink', 1),
('Pepsi', 'Classic pepsi cola', 3.99, 'Drink', 1),
('French Fries', 'Crispy golden fries', 5.99, 'Side', 1),
('Garlic Bread', 'Toasted bread with garlic butter', 4.99, 'Side', 1),
('Caesar Salad', 'Fresh lettuce, croutons, parmesan, caesar dressing', 8.99, 'Side', 1);

-- Thêm dữ liệu mẫu cho Orders (chỉ thêm nếu chưa có)
IF NOT EXISTS (SELECT * FROM Orders WHERE OrderID = 1)
INSERT INTO Orders (StaffID, TableNumber, Status, TotalMoney, PaymentStatus, CustomerName, CustomerPhone) VALUES
(2, 'T01', 2, 45.97, 'Paid', 'John Doe', '0901234567'),
(2, 'T02', 1, 32.98, 'Unpaid', 'Jane Smith', '0901234568'),
(3, 'T03', 0, 28.99, 'Unpaid', 'Mike Johnson', '0901234569');

-- Thêm dữ liệu mẫu cho OrderDetails (chỉ thêm nếu chưa có)
IF NOT EXISTS (SELECT * FROM OrderDetails WHERE OrderDetailID = 1)
INSERT INTO OrderDetails (OrderID, ProductID, Quantity, UnitPrice, TotalPrice, SpecialInstructions) VALUES
(1, 1, 1, 15.99, 15.99, 'Extra cheese'),
(1, 2, 1, 18.99, 18.99, 'Well done'),
(1, 6, 2, 3.99, 7.98, 'No ice'),
(1, 8, 1, 5.99, 5.99, 'Extra crispy'),
(2, 3, 1, 21.99, 21.99, 'Light sauce'),
(2, 7, 1, 3.99, 3.99, ''),
(2, 9, 1, 4.99, 4.99, 'Extra garlic'),
(3, 4, 1, 17.99, 17.99, 'No mushrooms'),
(3, 5, 1, 24.99, 24.99, 'Extra pepperoni'),
(3, 10, 1, 8.99, 8.99, 'Dressing on side');

-- Tạo indexes để tối ưu performance (chỉ tạo nếu chưa tồn tại)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Orders_StaffID')
CREATE INDEX IX_Orders_StaffID ON Orders(StaffID);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Orders_OrderDate')
CREATE INDEX IX_Orders_OrderDate ON Orders(OrderDate);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Orders_Status')
CREATE INDEX IX_Orders_Status ON Orders(Status);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_OrderDetails_OrderID')
CREATE INDEX IX_OrderDetails_OrderID ON OrderDetails(OrderID);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_OrderDetails_ProductID')
CREATE INDEX IX_OrderDetails_ProductID ON OrderDetails(ProductID);

-- Tạo view để dễ dàng query thông tin đơn hàng (chỉ tạo nếu chưa tồn tại)
IF NOT EXISTS (SELECT * FROM sys.views WHERE name = 'OrderSummary')
CREATE VIEW OrderSummary AS
SELECT 
    o.OrderID,
    o.TableNumber,
    o.OrderDate,
    o.Status,
    o.TotalMoney,
    o.PaymentStatus,
    o.CustomerName,
    o.CustomerPhone,
    u.Username AS StaffName,
    CASE o.Status
        WHEN 0 THEN 'Pending'
        WHEN 1 THEN 'Processing'
        WHEN 2 THEN 'Completed'
        WHEN 3 THEN 'Cancelled'
        ELSE 'Unknown'
    END AS StatusText
FROM Orders o
LEFT JOIN [User] u ON o.StaffID = u.UserID;

PRINT 'Pizza Orders database setup completed successfully!';
