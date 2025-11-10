-- ===============================
-- 🔄 CẬP NHẬT TRẠNG THÁI BÀN
-- ===============================

USE pizza_demo_DB_FinalModel;
GO

-- ===============================
-- 1. Chuyển Table 1 thành Available
-- ===============================
UPDATE [Table]
SET [Status] = 'available'
WHERE TableID = 1;
GO

PRINT '✅ Table 1 đã được chuyển thành Available';
GO

-- ===============================
-- 2. Kiểm tra kết quả
-- ===============================
SELECT 
    TableID,
    TableNumber,
    Capacity,
    [Status],
    IsActive
FROM [Table]
WHERE TableID = 1;
GO

-- ===============================
-- 3. CÁC QUERY HỮU ÍCH KHÁC
-- ===============================

-- Chuyển tất cả bàn thành Available
-- UPDATE [Table] SET [Status] = 'available' WHERE IsActive = 1;

-- Chuyển bàn theo TableNumber
-- UPDATE [Table] SET [Status] = 'available' WHERE TableNumber = 'T01';

-- Chuyển nhiều bàn cùng lúc
-- UPDATE [Table] SET [Status] = 'available' WHERE TableID IN (1, 2, 3, 4, 5);

-- Chuyển bàn thành Occupied (đang dùng)
-- UPDATE [Table] SET [Status] = 'occupied' WHERE TableID = 1;

-- Chuyển bàn thành Unavailable (không khả dụng)
-- UPDATE [Table] SET [Status] = 'unavailable' WHERE TableID = 1;

-- ===============================
-- 4. XEM TRẠNG THÁI TẤT CẢ BÀN
-- ===============================
SELECT 
    TableID,
    TableNumber,
    Capacity,
    [Status],
    IsActive,
    CASE 
        WHEN [Status] = 'available' THEN '🟢 Trống'
        WHEN [Status] = 'occupied' THEN '🟡 Đang Dùng'
        WHEN [Status] = 'unavailable' THEN '🔴 Không KD'
        ELSE '❓ Không xác định'
    END AS StatusText
FROM [Table]
ORDER BY TableNumber;
GO

-- ===============================
-- 5. THỐNG KÊ TRẠNG THÁI BÀN
-- ===============================
SELECT 
    [Status],
    COUNT(*) AS TotalTables,
    CASE 
        WHEN [Status] = 'available' THEN '🟢 Trống'
        WHEN [Status] = 'occupied' THEN '🟡 Đang Dùng'
        WHEN [Status] = 'unavailable' THEN '🔴 Không KD'
        ELSE '❓ Không xác định'
    END AS StatusText
FROM [Table]
WHERE IsActive = 1
GROUP BY [Status]
ORDER BY [Status];
GO

-- ===============================
-- 6. TÌM BÀN ĐANG CÓ ĐỚN HÀNG
-- ===============================
SELECT 
    t.TableID,
    t.TableNumber,
    t.[Status],
    COUNT(o.OrderID) AS ActiveOrders
FROM [Table] t
LEFT JOIN [Order] o ON t.TableID = o.TableID AND o.[Status] < 4
GROUP BY t.TableID, t.TableNumber, t.[Status]
HAVING COUNT(o.OrderID) > 0
ORDER BY t.TableNumber;
GO

-- ===============================
-- 7. TỰ ĐỘNG CẬP NHẬT TRẠNG THÁI BÀN
-- (Chuyển bàn thành Available nếu không còn đơn hàng active)
-- ===============================
UPDATE [Table]
SET [Status] = 'available'
WHERE TableID IN (
    SELECT t.TableID
    FROM [Table] t
    LEFT JOIN [Order] o ON t.TableID = o.TableID AND o.[Status] < 4
    WHERE t.[Status] = 'occupied'
    GROUP BY t.TableID
    HAVING COUNT(o.OrderID) = 0
);
GO

PRINT '✅ Đã tự động cập nhật trạng thái các bàn không còn đơn hàng';
GO

-- ===============================
-- 8. CHUYỂN BÀN THÀNH OCCUPIED KHI CÓ ĐỚN HÀNG MỚI
-- ===============================
UPDATE [Table]
SET [Status] = 'occupied'
WHERE TableID IN (
    SELECT DISTINCT o.TableID
    FROM [Order] o
    WHERE o.[Status] < 4  -- Chưa hoàn thành
    AND o.TableID IS NOT NULL
);
GO

PRINT '✅ Đã cập nhật trạng thái bàn có đơn hàng active';
GO
