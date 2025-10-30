-- Fix Employee Foreign Key Constraint Issue
-- Run this to create Employee records for all users

PRINT '🔧 Fixing Employee constraint issue...';

-- Check if Employee table exists
IF EXISTS (SELECT * FROM sysobjects WHERE name='Employee' AND xtype='U')
BEGIN
    PRINT '✅ Employee table exists';
    
    -- Create Employee records for users who don't have one
    INSERT INTO Employee (UserID, Role)
    SELECT u.UserID, 
           CASE 
               WHEN u.Role = 1 THEN 'Admin'
               WHEN u.Role = 2 THEN 'Cashier'
               WHEN u.Role = 3 THEN 'Waiter'
               ELSE 'Staff'
           END as Role
    FROM [User] u
    WHERE u.UserID NOT IN (SELECT UserID FROM Employee WHERE UserID IS NOT NULL);
    
    DECLARE @InsertedCount INT = @@ROWCOUNT;
    PRINT '✅ Created ' + CAST(@InsertedCount AS VARCHAR(10)) + ' Employee records';
    
    -- Show all employees
    SELECT e.EmployeeID, u.UserID, u.Name, e.Role
    FROM Employee e
    JOIN [User] u ON e.UserID = u.UserID;
    
END
ELSE
BEGIN
    PRINT '❌ Employee table does not exist';
    PRINT 'Creating Employee table...';
    
    CREATE TABLE Employee (
        EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
        UserID INT NOT NULL,
        Role NVARCHAR(50),
        FOREIGN KEY (UserID) REFERENCES [User](UserID)
    );
    
    PRINT '✅ Employee table created';
    
    -- Insert employees for all users
    INSERT INTO Employee (UserID, Role)
    SELECT UserID, 
           CASE 
               WHEN Role = 1 THEN 'Admin'
               WHEN Role = 2 THEN 'Cashier'
               WHEN Role = 3 THEN 'Waiter'
               ELSE 'Staff'
           END
    FROM [User];
    
    PRINT '✅ Employees created for all users';
END

PRINT '';
PRINT '🎉 Employee constraint issue fixed!';
PRINT 'You can now create orders in POS system.';
