-- ============================================
-- MIGRATION: TOPPING MANAGEMENT SYSTEM
-- Date: 2025-11-06
-- Description: Add topping management for pizzas
-- ============================================

USE RestaurantDB;
GO

PRINT '🍕 Starting Topping System Migration...';
GO

-- ============================================
-- 1. CREATE TOPPING TABLE
-- ============================================
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Topping' AND xtype='U')
BEGIN
    CREATE TABLE Topping (
        ToppingID INT IDENTITY(1,1) PRIMARY KEY,
        ToppingName NVARCHAR(100) NOT NULL,
        Price DECIMAL(10,2) NOT NULL,
        IsAvailable BIT DEFAULT 1,
        CreatedDate DATETIME DEFAULT GETDATE()
    );
    PRINT '✅ Topping table created';
END
ELSE
BEGIN
    PRINT '⚠️ Topping table already exists';
END
GO

-- ============================================
-- 2. CREATE PRODUCT_TOPPING TABLE
-- ============================================
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='ProductTopping' AND xtype='U')
BEGIN
    CREATE TABLE ProductTopping (
        ProductToppingID INT IDENTITY(1,1) PRIMARY KEY,
        ProductID INT NOT NULL,
        ToppingID INT NOT NULL,
        FOREIGN KEY (ProductID) REFERENCES Product(ProductID) ON DELETE CASCADE,
        FOREIGN KEY (ToppingID) REFERENCES Topping(ToppingID) ON DELETE CASCADE,
        CONSTRAINT UQ_ProductTopping UNIQUE(ProductID, ToppingID)
    );
    PRINT '✅ ProductTopping table created';
END
ELSE
BEGIN
    PRINT '⚠️ ProductTopping table already exists';
END
GO

-- ============================================
-- 3. CREATE ORDER_DETAIL_TOPPING TABLE
-- ============================================
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='OrderDetailTopping' AND xtype='U')
BEGIN
    CREATE TABLE OrderDetailTopping (
        OrderDetailToppingID INT IDENTITY(1,1) PRIMARY KEY,
        OrderDetailID INT NOT NULL,
        ToppingID INT NOT NULL,
        ToppingPrice DECIMAL(10,2) NOT NULL,
        FOREIGN KEY (OrderDetailID) REFERENCES OrderDetail(OrderDetailID) ON DELETE CASCADE,
        FOREIGN KEY (ToppingID) REFERENCES Topping(ToppingID)
    );
    PRINT '✅ OrderDetailTopping table created';
END
ELSE
BEGIN
    PRINT '⚠️ OrderDetailTopping table already exists';
END
GO

-- ============================================
-- 4. INSERT SAMPLE TOPPINGS
-- ============================================
IF NOT EXISTS (SELECT * FROM Topping)
BEGIN
    INSERT INTO Topping (ToppingName, Price, IsAvailable) VALUES
    (N'Extra Cheese', 15000, 1),
    (N'Mushrooms', 10000, 1),
    (N'Black Olives', 10000, 1),
    (N'Green Peppers', 8000, 1),
    (N'Onions', 8000, 1),
    (N'Pepperoni', 20000, 1),
    (N'Italian Sausage', 20000, 1),
    (N'Bacon', 25000, 1),
    (N'Ham', 18000, 1),
    (N'Pineapple', 12000, 1),
    (N'Tomatoes', 8000, 1),
    (N'Jalapeños', 10000, 1),
    (N'Spinach', 10000, 1),
    (N'Garlic', 8000, 1),
    (N'Basil', 8000, 1);
    
    PRINT '✅ Sample toppings inserted (15 items)';
END
ELSE
BEGIN
    PRINT '⚠️ Toppings already exist';
END
GO

-- ============================================
-- 5. VERIFICATION
-- ============================================
PRINT '';
PRINT '📊 VERIFICATION:';
PRINT '================';

DECLARE @ToppingCount INT = (SELECT COUNT(*) FROM Topping);
PRINT '✅ Topping records: ' + CAST(@ToppingCount AS VARCHAR);

PRINT '';
PRINT '🎉 Topping System Migration Completed!';
PRINT '';
PRINT '📝 Next Steps:';
PRINT '1. Run this migration script';
PRINT '2. Verify tables created successfully';
PRINT '3. Test Admin Topping Management';
PRINT '4. Test POS Topping Selection';
GO
