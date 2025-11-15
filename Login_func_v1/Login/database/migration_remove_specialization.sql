-- Migration: Remove Specialization column from Employee table
-- Reason: Không còn sử dụng specialization, chỉ có 1 chef duy nhất

USE [pizza_demo_DB_FinalModel_CombinedDuong];
GO

-- Bước 1: Kiểm tra dữ liệu hiện tại
SELECT 
    e.EmployeeID,
    u.Name,
    e.Role,
    e.Specialization
FROM Employee e
JOIN [User] u ON e.UserID = u.UserID;
GO

-- Bước 2: Xóa constraint CHECK nếu có (liên quan đến Specialization)
IF EXISTS (
    SELECT * FROM sys.check_constraints 
    WHERE parent_object_id = OBJECT_ID('dbo.Employee') 
    AND definition LIKE '%Specialization%'
)
BEGIN
    DECLARE @ConstraintName NVARCHAR(200);
    SELECT @ConstraintName = name 
    FROM sys.check_constraints 
    WHERE parent_object_id = OBJECT_ID('dbo.Employee') 
    AND definition LIKE '%Specialization%';
    
    DECLARE @SQL NVARCHAR(MAX) = 'ALTER TABLE [dbo].[Employee] DROP CONSTRAINT ' + @ConstraintName;
    EXEC sp_executesql @SQL;
    PRINT 'Đã xóa constraint: ' + @ConstraintName;
END
GO

-- Bước 3: Xóa column Specialization
IF EXISTS (
    SELECT * FROM sys.columns 
    WHERE object_id = OBJECT_ID('dbo.Employee') 
    AND name = 'Specialization'
)
BEGIN
    ALTER TABLE [dbo].[Employee] DROP COLUMN [Specialization];
    PRINT 'Đã xóa column Specialization';
END
ELSE
BEGIN
    PRINT 'Column Specialization không tồn tại';
END
GO

-- Bước 4: Kiểm tra lại cấu trúc bảng
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Employee'
ORDER BY ORDINAL_POSITION;
GO

-- Bước 5: Kiểm tra dữ liệu sau khi xóa
SELECT 
    e.EmployeeID,
    u.Name,
    e.Role
FROM Employee e
JOIN [User] u ON e.UserID = u.UserID;
GO

PRINT 'Migration hoàn tất!';
