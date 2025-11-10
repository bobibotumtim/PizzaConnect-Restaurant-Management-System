-- Script để insert dữ liệu bàn test
USE pizza_demo_DB_FinalModel;
GO

-- Kiểm tra xem đã có bàn chưa
IF NOT EXISTS (SELECT 1 FROM [Table])
BEGIN
    PRINT '📝 Inserting test table data...';
    
    INSERT INTO [Table] (TableNumber, Capacity, [Status], IsActive) VALUES
    ('T01', 2, 'available', 1),
    ('T02', 2, 'available', 1),
    ('T03', 4, 'available', 1),
    ('T04', 4, 'occupied', 1),
    ('T05', 4, 'available', 1),
    ('T06', 6, 'available', 1),
    ('T07', 6, 'occupied', 1),
    ('T08', 6, 'available', 1),
    ('T09', 8, 'available', 1),
    ('T10', 8, 'available', 1),
    ('T11', 10, 'unavailable', 1),
    ('T12', 10, 'available', 1);
    
    PRINT '✅ Test tables inserted successfully!';
    PRINT '   Total tables: 12';
    PRINT '   Available: 9';
    PRINT '   Occupied: 2';
    PRINT '   Unavailable: 1';
END
ELSE
BEGIN
    PRINT '⚠️ Tables already exist. Skipping insert.';
    
    -- Hiển thị số lượng bàn hiện tại
    DECLARE @TotalTables INT = (SELECT COUNT(*) FROM [Table]);
    DECLARE @ActiveTables INT = (SELECT COUNT(*) FROM [Table] WHERE IsActive = 1);
    
    PRINT '   Total tables in database: ' + CAST(@TotalTables AS VARCHAR);
    PRINT '   Active tables: ' + CAST(@ActiveTables AS VARCHAR);
END
GO

-- Hiển thị danh sách bàn
SELECT 
    TableID,
    TableNumber,
    Capacity,
    [Status],
    IsActive
FROM [Table]
ORDER BY TableNumber;
GO
