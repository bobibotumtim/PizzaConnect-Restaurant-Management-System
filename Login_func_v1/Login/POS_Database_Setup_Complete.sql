-- Complete POS Database Setup
-- Run this script to ensure all tables exist for POS system

-- 0. Check and create Customer table (if not exists)
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Customer' AND xtype='U')
BEGIN
    CREATE TABLE Customer (
        CustomerID INT IDENTITY(1,1) PRIMARY KEY,
        UserID INT NOT NULL,
        LoyaltyPoint INT DEFAULT 0
    );
    PRINT '✅ Customer table created';
    
    -- Insert default customers (using existing UserIDs from User table)
    INSERT INTO Customer (UserID, LoyaltyPoint) VALUES 
    (4, 10),  -- Using existing UserID 4
    (5, 20),  -- Using existing UserID 5
    (6, 5);   -- Using existing UserID 6
    PRINT '✅ Default customers inserted';
END
ELSE
BEGIN
    PRINT '✅ Customer table already exists';
    
    -- Ensure we have at least some customers for POS
    IF (SELECT COUNT(*) FROM Customer) = 0
    BEGIN
        INSERT INTO Customer (UserID, LoyaltyPoint) VALUES 
        (4, 10),  -- Using existing UserID 4
        (5, 20),  -- Using existing UserID 5
        (6, 5);   -- Using existing UserID 6
        PRINT '✅ Default customers added to existing table';
    END
END

-- 1. Check and create Order table (if not exists)
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Order' AND xtype='U')
BEGIN
    CREATE TABLE [Order] (
        OrderID INT IDENTITY(1,1) PRIMARY KEY,
        CustomerID INT,
        EmployeeID INT,
        TableID INT,
        OrderDate DATETIME DEFAULT GETDATE(),
        Status INT DEFAULT 0, -- 0=Pending, 1=Processing, 2=Completed, 3=Cancelled
        PaymentStatus NVARCHAR(20) DEFAULT 'Unpaid',
        TotalPrice DECIMAL(10,2) DEFAULT 0,
        Note NVARCHAR(500)
    );
    PRINT '✅ Order table created';
END
ELSE
BEGIN
    PRINT '✅ Order table already exists';
END

-- 2. Check and create OrderDetail table (if not exists)
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='OrderDetail' AND xtype='U')
BEGIN
    CREATE TABLE [OrderDetail] (
        OrderDetailID INT IDENTITY(1,1) PRIMARY KEY,
        OrderID INT NOT NULL,
        ProductID INT NOT NULL,
        Quantity INT NOT NULL,
        TotalPrice DECIMAL(10,2) NOT NULL,
        SpecialInstructions NVARCHAR(200),
        FOREIGN KEY (OrderID) REFERENCES [Order](OrderID) ON DELETE CASCADE
    );
    PRINT '✅ OrderDetail table created';
END
ELSE
BEGIN
    PRINT '✅ OrderDetail table already exists';
END

-- 3. Check and create Product table (if not exists)
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Product' AND xtype='U')
BEGIN
    CREATE TABLE Product (
        ProductID INT IDENTITY(1,1) PRIMARY KEY,
        ProductName NVARCHAR(100) NOT NULL,
        Price DECIMAL(10,2) NOT NULL,
        Category NVARCHAR(50) NOT NULL,
        IsAvailable BIT DEFAULT 1
    );
    PRINT '✅ Product table created';
END
ELSE
BEGIN
    PRINT '✅ Product table already exists';
END

-- 4. Insert sample products (if table is empty)
IF NOT EXISTS (SELECT * FROM Product)
BEGIN
    -- Pizza products (IDs 1-8)
    INSERT INTO Product (ProductName, Price, Category, IsAvailable) VALUES
    ('Margherita Pizza', 120000, 'PIZZA', 1),
    ('Pepperoni Pizza', 150000, 'PIZZA', 1),
    ('Hawaiian Pizza', 180000, 'PIZZA', 1),
    ('BBQ Chicken Pizza', 160000, 'PIZZA', 1),
    ('Veggie Supreme', 145000, 'PIZZA', 1),
    ('Meat Lovers', 190000, 'PIZZA', 1),
    ('Four Cheese', 165000, 'PIZZA', 1),
    ('Seafood Special', 200000, 'PIZZA', 1);

    -- Beverages (IDs 9-14)
    INSERT INTO Product (ProductName, Price, Category, IsAvailable) VALUES
    ('Coca Cola', 15000, 'BEVERAGES', 1),
    ('Pepsi', 15000, 'BEVERAGES', 1),
    ('Sprite', 15000, 'BEVERAGES', 1),
    ('Orange Juice', 25000, 'BEVERAGES', 1),
    ('Iced Tea', 20000, 'BEVERAGES', 1),
    ('Coffee', 30000, 'BEVERAGES', 1);

    -- Sides (IDs 15-20)
    INSERT INTO Product (ProductName, Price, Category, IsAvailable) VALUES
    ('French Fries', 35000, 'SIDES', 1),
    ('Chicken Wings', 80000, 'SIDES', 1),
    ('Garlic Bread', 40000, 'SIDES', 1),
    ('Onion Rings', 30000, 'SIDES', 1),
    ('Caesar Salad', 45000, 'SIDES', 1),
    ('Mozzarella Sticks', 55000, 'SIDES', 1);

    -- Desserts (IDs 21-24)
    INSERT INTO Product (ProductName, Price, Category, IsAvailable) VALUES
    ('Tiramisu', 50000, 'DESSERTS', 1),
    ('Chocolate Cake', 45000, 'DESSERTS', 1),
    ('Vanilla Ice Cream', 35000, 'DESSERTS', 1),
    ('Chocolate Brownie', 40000, 'DESSERTS', 1);

    PRINT '✅ Sample products inserted';
END
ELSE
BEGIN
    PRINT '✅ Products already exist';
END

-- 5. Create indexes for better performance
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Order_Date')
BEGIN
    CREATE INDEX IX_Order_Date ON [Order](OrderDate);
    PRINT '✅ Order date index created';
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_OrderDetail_OrderID')
BEGIN
    CREATE INDEX IX_OrderDetail_OrderID ON [OrderDetail](OrderID);
    PRINT '✅ OrderDetail index created';
END

-- 6. Show summary
PRINT '';
PRINT '🎉 POS Database setup completed!';

DECLARE @OrderCount INT = (SELECT COUNT(*) FROM [Order]);
DECLARE @ProductCount INT = (SELECT COUNT(*) FROM Product WHERE IsAvailable = 1);
DECLARE @CustomerCount INT = (SELECT COUNT(*) FROM Customer);

PRINT 'Orders in system: ' + CAST(@OrderCount AS VARCHAR(10));
PRINT 'Products available: ' + CAST(@ProductCount AS VARCHAR(10));
PRINT 'Customers in system: ' + CAST(@CustomerCount AS VARCHAR(10));
PRINT '';
PRINT '✅ Ready for POS system integration!';