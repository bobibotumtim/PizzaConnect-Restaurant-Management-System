-- ===============================
-- 🔍 KIỂM TRA TRIGGER VÀ LOGIC CẬP NHẬT BÀN
-- ===============================

USE pizza_demo_DB_FinalModel;
GO

-- ===============================
-- 1. Kiểm tra tất cả trigger liên quan đến Table
-- ===============================
PRINT '📋 Danh sách Trigger liên quan đến bảng [Table]:';
PRINT '================================================';

SELECT 
    t.name AS TriggerName,
    OBJECT_NAME(t.parent_id) AS TableName,
    t.type_desc AS TriggerType,
    t.is_disabled AS IsDisabled,
    t.create_date AS CreateDate
FROM sys.triggers t
WHERE OBJECT_NAME(t.parent_id) = 'Table'
   OR t.name LIKE '%Table%'
ORDER BY t.name;
GO

-- ===============================
-- 2. Kiểm tra trigger liên quan đến Order
-- ===============================
PRINT '';
PRINT '📋 Danh sách Trigger liên quan đến bảng [Order]:';
PRINT '================================================';

SELECT 
    t.name AS TriggerName,
    OBJECT_NAME(t.parent_id) AS TableName,
    t.type_desc AS TriggerType,
    t.is_disabled AS IsDisabled,
    t.create_date AS CreateDate
FROM sys.triggers t
WHERE OBJECT_NAME(t.parent_id) = 'Order'
   OR t.name LIKE '%Order%'
ORDER BY t.name;
GO

-- ===============================
-- 3. Xem nội dung trigger (nếu có)
-- ===============================
-- Uncomment để xem chi tiết trigger
/*
SELECT 
    t.name AS TriggerName,
    m.definition AS TriggerDefinition
FROM sys.triggers t
INNER JOIN sys.sql_modules m ON t.object_id = m.object_id
WHERE OBJECT_NAME(t.parent_id) IN ('Table', 'Order')
ORDER BY t.name;
GO
*/

-- ===============================
-- 4. Kiểm tra trạng thái hiện tại của bàn
-- ===============================
PRINT '';
PRINT '📊 Trạng thái hiện tại của các bàn:';
PRINT '====================================';

SELECT 
    t.TableID,
    t.TableNumber,
    t.[Status],
    t.IsActive,
    COUNT(o.OrderID) AS ActiveOrders,
    CASE 
        WHEN COUNT(o.OrderID) > 0 THEN 'Nên là: occupied'
        ELSE 'Nên là: available'
    END AS ExpectedStatus,
    CASE 
        WHEN t.[Status] = 'occupied' AND COUNT(o.OrderID) > 0 THEN '✅ Đúng'
        WHEN t.[Status] = 'available' AND COUNT(o.OrderID) = 0 THEN '✅ Đúng'
        ELSE '❌ SAI'
    END AS StatusCheck
FROM [Table] t
LEFT JOIN [Order] o ON t.TableID = o.TableID AND o.[Status] < 4
WHERE t.IsActive = 1
GROUP BY t.TableID, t.TableNumber, t.[Status], t.IsActive
ORDER BY t.TableNumber;
GO

-- ===============================
-- 5. Tìm bàn có trạng thái sai
-- ===============================
PRINT '';
PRINT '⚠️ Các bàn có trạng thái KHÔNG ĐÚNG:';
PRINT '====================================';

SELECT 
    t.TableID,
    t.TableNumber,
    t.[Status] AS CurrentStatus,
    COUNT(o.OrderID) AS ActiveOrders,
    CASE 
        WHEN COUNT(o.OrderID) > 0 THEN 'occupied'
        ELSE 'available'
    END AS CorrectStatus
FROM [Table] t
LEFT JOIN [Order] o ON t.TableID = o.TableID AND o.[Status] < 4
WHERE t.IsActive = 1
GROUP BY t.TableID, t.TableNumber, t.[Status]
HAVING 
    (t.[Status] = 'occupied' AND COUNT(o.OrderID) = 0) OR
    (t.[Status] = 'available' AND COUNT(o.OrderID) > 0) OR
    (t.[Status] = 'unavailable' AND COUNT(o.OrderID) > 0)
ORDER BY t.TableNumber;
GO

-- ===============================
-- 6. SỬA LỖI: Cập nhật trạng thái bàn cho đúng
-- ===============================
PRINT '';
PRINT '🔧 Đang sửa trạng thái bàn...';
PRINT '====================================';

-- Chuyển bàn có đơn hàng thành occupied
UPDATE t
SET t.[Status] = 'occupied'
FROM [Table] t
INNER JOIN (
    SELECT TableID, COUNT(*) AS OrderCount
    FROM [Order]
    WHERE [Status] < 4 AND TableID IS NOT NULL
    GROUP BY TableID
) o ON t.TableID = o.TableID
WHERE t.[Status] != 'occupied' AND t.IsActive = 1;

PRINT '✅ Đã cập nhật bàn có đơn hàng thành occupied';

-- Chuyển bàn không có đơn hàng thành available
UPDATE t
SET t.[Status] = 'available'
FROM [Table] t
LEFT JOIN (
    SELECT TableID, COUNT(*) AS OrderCount
    FROM [Order]
    WHERE [Status] < 4 AND TableID IS NOT NULL
    GROUP BY TableID
) o ON t.TableID = o.TableID
WHERE (o.OrderCount IS NULL OR o.OrderCount = 0) 
  AND t.[Status] = 'occupied' 
  AND t.IsActive = 1;

PRINT '✅ Đã cập nhật bàn không có đơn hàng thành available';
GO

-- ===============================
-- 7. Kiểm tra lại sau khi sửa
-- ===============================
PRINT '';
PRINT '📊 Trạng thái sau khi sửa:';
PRINT '====================================';

SELECT 
    t.TableID,
    t.TableNumber,
    t.[Status],
    COUNT(o.OrderID) AS ActiveOrders
FROM [Table] t
LEFT JOIN [Order] o ON t.TableID = o.TableID AND o.[Status] < 4
WHERE t.IsActive = 1
GROUP BY t.TableID, t.TableNumber, t.[Status]
ORDER BY t.TableNumber;
GO
