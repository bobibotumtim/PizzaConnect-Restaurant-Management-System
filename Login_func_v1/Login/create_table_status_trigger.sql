-- ===============================
-- 🔧 TẠO TRIGGER TỰ ĐỘNG CẬP NHẬT TRẠNG THÁI BÀN
-- ===============================

USE pizza_demo_DB_FinalModel;
GO

-- ===============================
-- 1. Xóa trigger cũ nếu có
-- ===============================
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_UpdateTableStatus_AfterOrderInsert')
BEGIN
    DROP TRIGGER trg_UpdateTableStatus_AfterOrderInsert;
    PRINT '🗑️ Đã xóa trigger cũ: trg_UpdateTableStatus_AfterOrderInsert';
END
GO

IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_UpdateTableStatus_AfterOrderUpdate')
BEGIN
    DROP TRIGGER trg_UpdateTableStatus_AfterOrderUpdate;
    PRINT '🗑️ Đã xóa trigger cũ: trg_UpdateTableStatus_AfterOrderUpdate';
END
GO

IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_UpdateTableStatus_AfterOrderDelete')
BEGIN
    DROP TRIGGER trg_UpdateTableStatus_AfterOrderDelete;
    PRINT '🗑️ Đã xóa trigger cũ: trg_UpdateTableStatus_AfterOrderDelete';
END
GO

-- ===============================
-- 2. Tạo Stored Procedure để cập nhật trạng thái bàn
-- ===============================
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_UpdateTableStatus')
BEGIN
    DROP PROCEDURE sp_UpdateTableStatus;
    PRINT '🗑️ Đã xóa procedure cũ: sp_UpdateTableStatus';
END
GO

CREATE PROCEDURE sp_UpdateTableStatus
    @TableID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ActiveOrderCount INT;
    DECLARE @CurrentStatus NVARCHAR(20);
    
    -- Đếm số đơn hàng đang active của bàn này
    SELECT @ActiveOrderCount = COUNT(*)
    FROM [Order]
    WHERE TableID = @TableID 
      AND [Status] < 4;  -- Status < 4 nghĩa là chưa hoàn thành
    
    -- Lấy trạng thái hiện tại
    SELECT @CurrentStatus = [Status]
    FROM [Table]
    WHERE TableID = @TableID;
    
    -- Cập nhật trạng thái dựa trên số đơn hàng
    IF @ActiveOrderCount > 0
    BEGIN
        -- Có đơn hàng active -> Chuyển thành occupied
        IF @CurrentStatus != 'occupied' AND @CurrentStatus != 'unavailable'
        BEGIN
            UPDATE [Table]
            SET [Status] = 'occupied'
            WHERE TableID = @TableID;
            
            PRINT '✅ Bàn ' + CAST(@TableID AS VARCHAR) + ' -> occupied (có ' + CAST(@ActiveOrderCount AS VARCHAR) + ' đơn hàng)';
        END
    END
    ELSE
    BEGIN
        -- Không có đơn hàng active -> Chuyển thành available (nếu không phải unavailable)
        IF @CurrentStatus = 'occupied'
        BEGIN
            UPDATE [Table]
            SET [Status] = 'available'
            WHERE TableID = @TableID;
            
            PRINT '✅ Bàn ' + CAST(@TableID AS VARCHAR) + ' -> available (không còn đơn hàng)';
        END
    END
END
GO

PRINT '✅ Đã tạo procedure: sp_UpdateTableStatus';
GO

-- ===============================
-- 3. Tạo Trigger khi INSERT Order mới
-- ===============================
CREATE TRIGGER trg_UpdateTableStatus_AfterOrderInsert
ON [Order]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Cập nhật trạng thái cho các bàn có trong đơn hàng mới
    DECLARE @TableID INT;
    
    DECLARE table_cursor CURSOR FOR
    SELECT DISTINCT TableID 
    FROM inserted 
    WHERE TableID IS NOT NULL;
    
    OPEN table_cursor;
    FETCH NEXT FROM table_cursor INTO @TableID;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC sp_UpdateTableStatus @TableID;
        FETCH NEXT FROM table_cursor INTO @TableID;
    END
    
    CLOSE table_cursor;
    DEALLOCATE table_cursor;
END
GO

PRINT '✅ Đã tạo trigger: trg_UpdateTableStatus_AfterOrderInsert';
GO

-- ===============================
-- 4. Tạo Trigger khi UPDATE Order
-- ===============================
CREATE TRIGGER trg_UpdateTableStatus_AfterOrderUpdate
ON [Order]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Cập nhật trạng thái cho các bàn bị ảnh hưởng
    DECLARE @TableID INT;
    
    -- Cursor cho bàn cũ (deleted)
    DECLARE table_cursor CURSOR FOR
    SELECT DISTINCT TableID 
    FROM deleted 
    WHERE TableID IS NOT NULL
    UNION
    SELECT DISTINCT TableID 
    FROM inserted 
    WHERE TableID IS NOT NULL;
    
    OPEN table_cursor;
    FETCH NEXT FROM table_cursor INTO @TableID;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC sp_UpdateTableStatus @TableID;
        FETCH NEXT FROM table_cursor INTO @TableID;
    END
    
    CLOSE table_cursor;
    DEALLOCATE table_cursor;
END
GO

PRINT '✅ Đã tạo trigger: trg_UpdateTableStatus_AfterOrderUpdate';
GO

-- ===============================
-- 5. Tạo Trigger khi DELETE Order
-- ===============================
CREATE TRIGGER trg_UpdateTableStatus_AfterOrderDelete
ON [Order]
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Cập nhật trạng thái cho các bàn có trong đơn hàng bị xóa
    DECLARE @TableID INT;
    
    DECLARE table_cursor CURSOR FOR
    SELECT DISTINCT TableID 
    FROM deleted 
    WHERE TableID IS NOT NULL;
    
    OPEN table_cursor;
    FETCH NEXT FROM table_cursor INTO @TableID;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC sp_UpdateTableStatus @TableID;
        FETCH NEXT FROM table_cursor INTO @TableID;
    END
    
    CLOSE table_cursor;
    DEALLOCATE table_cursor;
END
GO

PRINT '✅ Đã tạo trigger: trg_UpdateTableStatus_AfterOrderDelete';
GO

-- ===============================
-- 6. Test: Cập nhật trạng thái tất cả bàn hiện tại
-- ===============================
PRINT '';
PRINT '🔄 Đang cập nhật trạng thái tất cả bàn...';
PRINT '==========================================';

DECLARE @TestTableID INT;

DECLARE test_cursor CURSOR FOR
SELECT TableID FROM [Table] WHERE IsActive = 1;

OPEN test_cursor;
FETCH NEXT FROM test_cursor INTO @TestTableID;

WHILE @@FETCH_STATUS = 0
BEGIN
    EXEC sp_UpdateTableStatus @TestTableID;
    FETCH NEXT FROM test_cursor INTO @TestTableID;
END

CLOSE test_cursor;
DEALLOCATE test_cursor;

PRINT '';
PRINT '✅ Hoàn thành! Trigger đã được cài đặt.';
PRINT '';
PRINT '📋 Cách hoạt động:';
PRINT '   - Khi tạo đơn hàng mới -> Bàn tự động chuyển thành OCCUPIED';
PRINT '   - Khi cập nhật đơn hàng (Status = 4) -> Bàn tự động chuyển thành AVAILABLE';
PRINT '   - Khi xóa đơn hàng -> Bàn tự động cập nhật trạng thái';
PRINT '';
GO

-- ===============================
-- 7. Hiển thị kết quả
-- ===============================
SELECT 
    t.TableID,
    t.TableNumber,
    t.[Status],
    COUNT(o.OrderID) AS ActiveOrders,
    CASE 
        WHEN COUNT(o.OrderID) > 0 THEN '✅ Đúng (có đơn hàng)'
        WHEN COUNT(o.OrderID) = 0 AND t.[Status] = 'available' THEN '✅ Đúng (không có đơn)'
        WHEN COUNT(o.OrderID) = 0 AND t.[Status] = 'unavailable' THEN '⚠️ Unavailable (thủ công)'
        ELSE '❌ Sai'
    END AS StatusCheck
FROM [Table] t
LEFT JOIN [Order] o ON t.TableID = o.TableID AND o.[Status] < 4
WHERE t.IsActive = 1
GROUP BY t.TableID, t.TableNumber, t.[Status]
ORDER BY t.TableNumber;
GO
