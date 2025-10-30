-- Simple Database Setup for POS System
-- Fixed version without subquery errors

PRINT '🔧 Starting POS Database Setup...';

-- 1. Create Customer table
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Customer' AND xtype='U')
BEGIN
    CREATE TABLE Customer (
        CustomerID INT IDENTITY(1,1) PRIMARY KEY,
        UserID INT NOT NULL,
        LoyaltyPoint INT DEFAULT 0
    );
    PRINT '✅ Customer table created';
    
    -- Add default customers
    INSERT INTO Customer (UserID, LoyaltyPoint) VALUES (4, 10), (5, 20), (6, 5);
    PRINT '✅ Default customers added';
END
ELSE
    PRINT '✅ Customer table already exists';

-- 2. Create Order table
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Order' AND xtype='U')
BEGIN
    CREATE TABLE [Order] (
        OrderID INT IDENTITY(1,1) PRIMARY KEY,
        CustomerID INT,
        EmployeeID INT,
        TableID INT,
        OrderDate DATETIME DEFAULT GETDATE(),
        Status INT DEFAULT 0,
        PaymentStatus NVARCHAR(20) DEFAULT 'Unpaid',
        TotalPrice DECIMAL(10,2) DEFAULT 0,
        Note NVARCHAR(500)
    );
    PRINT '✅ Order table created';
END
ELSE
    PRINT '✅ Order table already exists';

-- 3. Create OrderDetail table
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='OrderDetail' AND xtype='U')
BEGIN
    CREATE TABLE [OrderDetail] (
        OrderDetailID INT IDENTITY(1,1) PRIMARY KEY,
        OrderID INT NOT NULL,
        ProductID INT NOT NULL,
        Quantity INT NOT NULL,
        TotalPrice DECIMAL(10,2) NOT NULL,
        SpecialInstructions NVARCHAR(200)
    );
    PRINT '✅ OrderDetail table created';
END
ELSE
    PRINT '✅ OrderDetail table already exists';

-- 4. Create Product table
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
    PRINT '✅ Product table already exists';

-- 5. Add sample products if table is empty
IF NOT EXISTS (SELECT * FROM Product)
BEGIN
    -- Pizza products
    INSERT INTO Product (ProductName, Price, Category, IsAvailable) VALUES
    ('Margherita Pizza', 120000, 'PIZZA', 1),
    ('Pepperoni Pizza', 150000, 'PIZZA', 1),
    ('Hawaiian Pizza', 180000, 'PIZZA', 1),
    ('BBQ Chicken Pizza', 160000, 'PIZZA', 1),
    ('Veggie Supreme', 145000, 'PIZZA', 1),
    ('Meat Lovers', 190000, 'PIZZA', 1),
    ('Four Cheese', 165000, 'PIZZA', 1),
    ('Seafood Special', 200000, 'PIZZA', 1);

    -- Beverages
    INSERT INTO Product (ProductName, Price, Category, IsAvailable) VALUES
    ('Coca Cola', 15000, 'BEVERAGES', 1),
    ('Pepsi', 15000, 'BEVERAGES', 1),
    ('Sprite', 15000, 'BEVERAGES', 1),
    ('Orange Juice', 25000, 'BEVERAGES', 1),
    ('Iced Tea', 20000, 'BEVERAGES', 1),
    ('Coffee', 30000, 'BEVERAGES', 1);

    -- Sides
    INSERT INTO Product (ProductName, Price, Category, IsAvailable) VALUES
    ('French Fries', 35000, 'SIDES', 1),
    ('Chicken Wings', 80000, 'SIDES', 1),
    ('Garlic Bread', 40000, 'SIDES', 1),
    ('Onion Rings', 30000, 'SIDES', 1),
    ('Caesar Salad', 45000, 'SIDES', 1),
    ('Mozzarella Sticks', 55000, 'SIDES', 1);

    -- Desserts
    INSERT INTO Product (ProductName, Price, Category, IsAvailable) VALUES
    ('Tiramisu', 50000, 'DESSERTS', 1),
    ('Chocolate Cake', 45000, 'DESSERTS', 1),
    ('Vanilla Ice Cream', 35000, 'DESSERTS', 1),
    ('Chocolate Brownie', 40000, 'DESSERTS', 1);

    PRINT '✅ Sample products added';
END
ELSE
    PRINT '✅ Products already exist';

-- 6. Show results
PRINT '';
PRINT '🎉 Database setup completed!';

-- Count records safely
DECLARE @OrderCount INT, @ProductCount INT, @CustomerCount INT;

SELECT @OrderCount = COUNT(*) FROM [Order];
SELECT @ProductCount = COUNT(*) FROM Product WHERE IsAvailable = 1;
SELECT @CustomerCount = COUNT(*) FROM Customer;

PRINT 'Orders: ' + CAST(@OrderCount AS VARCHAR(10));
PRINT 'Products: ' + CAST(@ProductCount AS VARCHAR(10));
PRINT 'Customers: ' + CAST(@CustomerCount AS VARCHAR(10));
PRINT '';
PRINT '✅ Ready for POS system!';