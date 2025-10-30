-- Check Database Structure for POS System
-- Run this to understand your current database schema

PRINT '🔍 Checking database structure...';
PRINT '';

-- 1. Check User table
PRINT '1️⃣ USER TABLE:';
IF EXISTS (SELECT * FROM sysobjects WHERE name='User' AND xtype='U')
BEGIN
    SELECT TOP 5 UserID, Name, Role, Email FROM [User];
    DECLARE @UserCount INT = (SELECT COUNT(*) FROM [User]);
    PRINT 'Total users: ' + CAST(@UserCount AS VARCHAR(10));
END
ELSE
    PRINT '❌ User table does not exist';

PRINT '';

-- 2. Check Employee table
PRINT '2️⃣ EMPLOYEE TABLE:';
IF EXISTS (SELECT * FROM sysobjects WHERE name='Employee' AND xtype='U')
BEGIN
    -- Show structure
    SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'Employee';
    
    PRINT '';
    PRINT 'Employee records:';
    SELECT e.EmployeeID, e.UserID, u.Name, e.Role
    FROM Employee e
    LEFT JOIN [User] u ON e.UserID = u.UserID;
    
    DECLARE @EmpCount INT = (SELECT COUNT(*) FROM Employee);
    PRINT 'Total employees: ' + CAST(@EmpCount AS VARCHAR(10));
END
ELSE
    PRINT '❌ Employee table does not exist';

PRINT '';

-- 3. Check Order table structure
PRINT '3️⃣ ORDER TABLE STRUCTURE:';
IF EXISTS (SELECT * FROM sysobjects WHERE name='Order' AND xtype='U')
BEGIN
    SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'Order';
END
ELSE
    PRINT '❌ Order table does not exist';

PRINT '';

-- 4. Check Foreign Keys on Order table
PRINT '4️⃣ FOREIGN KEYS ON ORDER TABLE:';
SELECT 
    fk.name AS ForeignKeyName,
    OBJECT_NAME(fk.parent_object_id) AS TableName,
    COL_NAME(fc.parent_object_id, fc.parent_column_id) AS ColumnName,
    OBJECT_NAME(fk.referenced_object_id) AS ReferencedTable,
    COL_NAME(fc.referenced_object_id, fc.referenced_column_id) AS ReferencedColumn
FROM sys.foreign_keys AS fk
INNER JOIN sys.foreign_key_columns AS fc 
    ON fk.object_id = fc.constraint_object_id
WHERE OBJECT_NAME(fk.parent_object_id) = 'Order';

PRINT '';

-- 5. Check which users don't have Employee records
PRINT '5️⃣ USERS WITHOUT EMPLOYEE RECORDS:';
IF EXISTS (SELECT * FROM sysobjects WHERE name='Employee' AND xtype='U')
BEGIN
    SELECT u.UserID, u.Name, u.Role, u.Email
    FROM [User] u
    WHERE u.UserID NOT IN (SELECT UserID FROM Employee WHERE UserID IS NOT NULL);
    
    DECLARE @MissingCount INT = (SELECT COUNT(*) FROM [User] u WHERE u.UserID NOT IN (SELECT UserID FROM Employee WHERE UserID IS NOT NULL));
    PRINT 'Users without Employee record: ' + CAST(@MissingCount AS VARCHAR(10));
END

PRINT '';
PRINT '✅ Database structure check completed!';
