-- Test Database Connection and Tables
-- Run this to check if your database is properly set up

PRINT '🔍 Testing database connection and tables...';
PRINT '';

-- Test 1: Check if database exists
SELECT DB_NAME() AS CurrentDatabase;
PRINT '✅ Connected to database: ' + DB_NAME();

-- Test 2: Check if tables exist
IF EXISTS (SELECT * FROM sysobjects WHERE name='Customer' AND xtype='U')
    PRINT '✅ Customer table exists'
ELSE
    PRINT '❌ Customer table missing - run POS_Database_Setup_Complete.sql';

IF EXISTS (SELECT * FROM sysobjects WHERE name='Order' AND xtype='U')
    PRINT '✅ Order table exists'
ELSE
    PRINT '❌ Order table missing - run POS_Database_Setup_Complete.sql';

IF EXISTS (SELECT * FROM sysobjects WHERE name='OrderDetail' AND xtype='U')
    PRINT '✅ OrderDetail table exists'
ELSE
    PRINT '❌ OrderDetail table missing - run POS_Database_Setup_Complete.sql';

IF EXISTS (SELECT * FROM sysobjects WHERE name='Product' AND xtype='U')
    PRINT '✅ Product table exists'
ELSE
    PRINT '❌ Product table missing - run POS_Database_Setup_Complete.sql';

-- Test 3: Check table contents
PRINT '';
PRINT '📊 Table contents:';

IF EXISTS (SELECT * FROM sysobjects WHERE name='Customer' AND xtype='U')
BEGIN
    DECLARE @CustomerCount INT = (SELECT COUNT(*) FROM Customer);
    PRINT 'Customers: ' + CAST(@CustomerCount AS VARCHAR(10));
END

IF EXISTS (SELECT * FROM sysobjects WHERE name='Product' AND xtype='U')
BEGIN
    DECLARE @ProductCount INT = (SELECT COUNT(*) FROM Product);
    DECLARE @AvailableProductCount INT = (SELECT COUNT(*) FROM Product WHERE IsAvailable = 1);
    PRINT 'Products: ' + CAST(@ProductCount AS VARCHAR(10)) + ' (Available: ' + CAST(@AvailableProductCount AS VARCHAR(10)) + ')';
END

IF EXISTS (SELECT * FROM sysobjects WHERE name='Order' AND xtype='U')
BEGIN
    DECLARE @OrderCount INT = (SELECT COUNT(*) FROM [Order]);
    PRINT 'Orders: ' + CAST(@OrderCount AS VARCHAR(10));
END

-- Test 4: Try to insert a test order
PRINT '';
PRINT '🧪 Testing order creation...';

IF EXISTS (SELECT * FROM sysobjects WHERE name='Customer' AND xtype='U') 
   AND EXISTS (SELECT * FROM sysobjects WHERE name='Order' AND xtype='U')
   AND EXISTS (SELECT * FROM sysobjects WHERE name='OrderDetail' AND xtype='U')
   AND EXISTS (SELECT * FROM sysobjects WHERE name='Product' AND xtype='U')
BEGIN
    BEGIN TRY
        -- Test insert
        DECLARE @TestOrderID INT;
        
        INSERT INTO [Order] (CustomerID, EmployeeID, TableID, Status, PaymentStatus, TotalPrice, Note)
        VALUES (1, 1, 1, 0, 'Unpaid', 150000, 'Test order from SQL script');
        
        SET @TestOrderID = SCOPE_IDENTITY();
        
        INSERT INTO OrderDetail (OrderID, ProductID, Quantity, TotalPrice, SpecialInstructions)
        VALUES (@TestOrderID, 1, 1, 150000, 'Test order detail');
        
        PRINT '✅ Test order created successfully with ID: ' + CAST(@TestOrderID AS VARCHAR(10));
        
        -- Clean up test data
        DELETE FROM OrderDetail WHERE OrderID = @TestOrderID;
        DELETE FROM [Order] WHERE OrderID = @TestOrderID;
        PRINT '✅ Test data cleaned up';
        
    END TRY
    BEGIN CATCH
        PRINT '❌ Test order creation failed: ' + ERROR_MESSAGE();
    END CATCH
END
ELSE
BEGIN
    PRINT '❌ Cannot test order creation - missing tables';
END

PRINT '';
PRINT '🎉 Database test completed!';