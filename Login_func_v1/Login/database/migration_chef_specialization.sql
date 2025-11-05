-- ===============================
-- MIGRATION: Chef Specialization System
-- Date: 2025-11-05
-- Description: Add specialization for chefs and Side Dishes category
-- ===============================

USE PizzaDB;
GO

-- 1. Thêm Category "Side Dishes"
IF NOT EXISTS (SELECT 1 FROM Category WHERE CategoryName = N'Side Dishes')
BEGIN
    INSERT INTO Category (CategoryName, Description, IsDeleted) 
    VALUES (N'Side Dishes', N'Side dishes and appetizers', 0);
    PRINT '✅ Added Category: Side Dishes';
END
ELSE
BEGIN
    PRINT '⚠️ Category Side Dishes already exists';
END
GO

-- 2. Thêm column Specialization vào Employee table
IF NOT EXISTS (SELECT 1 FROM sys.columns 
               WHERE object_id = OBJECT_ID('Employee') 
               AND name = 'Specialization')
BEGIN
    ALTER TABLE Employee 
    ADD Specialization NVARCHAR(50) NULL 
    CHECK (Specialization IN ('Pizza', 'Drinks', 'SideDishes', NULL));
    
    PRINT '✅ Added column: Employee.Specialization';
END
ELSE
BEGIN
    PRINT '⚠️ Column Specialization already exists';
END
GO

-- 3. Update existing Chef employees với default specialization
UPDATE Employee 
SET Specialization = 'Pizza' 
WHERE Role = 'Chef' AND Specialization IS NULL;

PRINT '✅ Updated existing Chefs with default specialization: Pizza';
GO

-- 4. Thêm sample products cho Side Dishes (optional)
DECLARE @SideDishCategoryID INT;
SELECT @SideDishCategoryID = CategoryID FROM Category WHERE CategoryName = N'Side Dishes';

IF @SideDishCategoryID IS NOT NULL
BEGIN
    -- Check if products already exist
    IF NOT EXISTS (SELECT 1 FROM Product WHERE CategoryID = @SideDishCategoryID)
    BEGIN
        INSERT INTO Product (ProductName, Description, CategoryID, ImageURL, IsAvailable)
        VALUES 
        (N'French Fries', N'Crispy golden french fries', @SideDishCategoryID, N'fries.jpg', 1),
        (N'Chicken Wings', N'Spicy buffalo chicken wings', @SideDishCategoryID, N'wings.jpg', 1),
        (N'Garlic Bread', N'Toasted bread with garlic butter', @SideDishCategoryID, N'garlic_bread.jpg', 1),
        (N'Caesar Salad', N'Fresh caesar salad', @SideDishCategoryID, N'caesar_salad.jpg', 1);
        
        PRINT '✅ Added sample Side Dishes products';
        
        -- Add ProductSize for Side Dishes (only Regular size)
        DECLARE @ProductID INT;
        DECLARE product_cursor CURSOR FOR 
            SELECT ProductID FROM Product WHERE CategoryID = @SideDishCategoryID;
        
        OPEN product_cursor;
        FETCH NEXT FROM product_cursor INTO @ProductID;
        
        WHILE @@FETCH_STATUS = 0
        BEGIN
            INSERT INTO ProductSize (ProductID, SizeName, SizeCode, Price)
            VALUES (@ProductID, N'Regular', N'R', 50000);
            
            FETCH NEXT FROM product_cursor INTO @ProductID;
        END
        
        CLOSE product_cursor;
        DEALLOCATE product_cursor;
        
        PRINT '✅ Added ProductSize for Side Dishes';
    END
    ELSE
    BEGIN
        PRINT '⚠️ Side Dishes products already exist';
    END
END
GO

-- 5. Verify changes
PRINT '';
PRINT '========== VERIFICATION ==========';

SELECT 'Categories' as Info;
SELECT CategoryID, CategoryName, Description 
FROM Category 
WHERE IsDeleted = 0
ORDER BY CategoryID;

SELECT 'Employee Specializations' as Info;
SELECT e.EmployeeID, u.Name, e.Role, e.Specialization
FROM Employee e
JOIN [User] u ON e.UserID = u.UserID
ORDER BY e.Role, e.Specialization;

SELECT 'Side Dishes Products' as Info;
SELECT p.ProductID, p.ProductName, c.CategoryName, ps.SizeName, ps.Price
FROM Product p
JOIN Category c ON p.CategoryID = c.CategoryID
LEFT JOIN ProductSize ps ON p.ProductID = ps.ProductID
WHERE c.CategoryName = N'Side Dishes';

PRINT '';
PRINT '✅ Migration completed successfully!';
PRINT 'Next steps:';
PRINT '1. Update Employee.java model';
PRINT '2. Update EmployeeDAO.java';
PRINT '3. Update OrderDetailDAO.java';
PRINT '4. Update ChefMonitorServlet.java';
PRINT '5. Update ChefMonitor.jsp';
GO
