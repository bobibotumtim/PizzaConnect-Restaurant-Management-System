-- ===============================
-- 🔧 KHẮC PHỤC ĐÚNG: Table chỉ có 'available' và 'unavailable'
-- ===============================

USE pizza_demo_DB_FinalModel;
GO

-- ===============================
-- ⚠️ LƯU Ý QUAN TRỌNG
-- ===============================
-- Trong schema gốc, bảng [Table] chỉ có 2 trạng thái:
-- - 'available': Bàn trống, sẵn sàng
-- - 'unavailable': Bàn không khả dụng (bảo trì, đặt trước)
--
-- KHÔNG CÓ 'occupied'!
--
-- Vậy làm sao biết bàn nào đang có khách?
-- → Kiểm tra bảng [Order]: Nếu có Order với Status < 4 thì bàn đang được dùng
-- ===============================

-- ===============================
-- 1. Xóa tất cả trigger cũ (nếu có)
-- ===============================
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_UpdateTableStatus_AfterOrderInsert')
    DROP TRIGGER trg_UpdateTableStatus_AfterOrderInsert;
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_UpdateTableStatus_AfterOrderUpdate')
    DROP TRIGGER trg_UpdateTableStatus_AfterOrderUpdate;
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_UpdateTableStatus_AfterOrderDelete')
    DROP TRIGGER trg_UpdateTableStatus_AfterOrderDelete;
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_UpdateTableStatus')
    DROP PROCEDURE sp_UpdateTableStatus;

PRINT '🗑️ Đã xóa trigger/procedure cũ (nếu có)';
GO

-- ===============================
-- 2. Sửa lại tất cả bàn về 'available'
-- ===============================
UPDATE [Table]
SET [Status] = 'available'
WHERE [Status] NOT IN ('available', 'unavailable');

PRINT '✅ Đã sửa tất cả bàn về trạng thái hợp lệ';
GO

-- ===============================
-- 3. Kiểm tra trạng thái hiện tại
-- ===============================
PRINT '';
PRINT '📊 Trạng thái hiện tại của các bàn:';
PRINT '====================================';

SELECT 
    t.TableID,
    t.TableNumber,
    t.Capacity,
    t.[Status] AS TableStatus,
    t.IsActive,
    COUNT(o.OrderID) AS ActiveOrders,
    CASE 
        WHEN COUNT(o.OrderID) > 0 THEN '🟡 Đang có khách'
        WHEN t.[Status] = 'available' THEN '🟢 Trống'
        WHEN t.[Status] = 'unavailable' THEN '🔴 Không KD'
        ELSE '❓ Không xác định'
    END AS ActualStatus
FROM [Table] t
LEFT JOIN [Order] o ON t.TableID = o.TableID AND o.[Status] < 4
WHERE t.IsActive = 1
GROUP BY t.TableID, t.TableNumber, t.Capacity, t.[Status], t.IsActive
ORDER BY t.TableNumber;
GO

-- ===============================
-- 4. GIẢI THÍCH LOGIC MỚI
-- ===============================
PRINT '';
PRINT '💡 LOGIC ĐÚNG:';
PRINT '==============';
PRINT '';
PRINT '   Bảng [Table] chỉ có 2 trạng thái:';
PRINT '   - available: Bàn sẵn sàng (có thể trống hoặc đang có khách)';
PRINT '   - unavailable: Bàn không khả dụng (admin set thủ công)';
PRINT '';
PRINT '   Để biết bàn có khách hay không:';
PRINT '   → Kiểm tra bảng [Order]';
PRINT '   → Nếu có Order với Status < 4 → Bàn đang có khách';
PRINT '   → Nếu không có Order active → Bàn trống';
PRINT '';
PRINT '   VÍ DỤ:';
PRINT '   - Bàn T01: Status = available, có 1 Order active → Đang có khách';
PRINT '   - Bàn T02: Status = available, không có Order → Trống';
PRINT '   - Bàn T03: Status = unavailable → Không khả dụng';
PRINT '';
GO

-- ===============================
-- 5. Tạo VIEW để dễ dàng xem trạng thái thực tế
-- ===============================
IF EXISTS (SELECT * FROM sys.views WHERE name = 'v_TableWithOrderStatus')
    DROP VIEW v_TableWithOrderStatus;
GO

CREATE VIEW v_TableWithOrderStatus
AS
SELECT 
    t.TableID,
    t.TableNumber,
    t.Capacity,
    t.[Status] AS TableStatus,
    t.IsActive,
    COUNT(o.OrderID) AS ActiveOrderCount,
    CASE 
        WHEN t.[Status] = 'unavailable' THEN 'unavailable'
        WHEN COUNT(o.OrderID) > 0 THEN 'occupied'
        ELSE 'available'
    END AS ActualStatus
FROM [Table] t
LEFT JOIN [Order] o ON t.TableID = o.TableID AND o.[Status] < 4
WHERE t.IsActive = 1
GROUP BY t.TableID, t.TableNumber, t.Capacity, t.[Status], t.IsActive;
GO

PRINT '✅ Đã tạo VIEW: v_TableWithOrderStatus';
PRINT '   Sử dụng: SELECT * FROM v_TableWithOrderStatus';
GO

-- ===============================
-- 6. Test VIEW
-- ===============================
PRINT '';
PRINT '📊 Kết quả từ VIEW (trạng thái thực tế):';
PRINT '=========================================';

SELECT 
    TableID,
    TableNumber,
    Capacity,
    TableStatus AS DatabaseStatus,
    ActualStatus AS DisplayStatus,
    ActiveOrderCount,
    CASE ActualStatus
        WHEN 'available' THEN '🟢 Trống'
        WHEN 'occupied' THEN '🟡 Đang có khách'
        WHEN 'unavailable' THEN '🔴 Không KD'
    END AS StatusIcon
FROM v_TableWithOrderStatus
ORDER BY TableNumber;
GO

-- ===============================
-- 7. Hướng dẫn sử dụng
-- ===============================
PRINT '';
PRINT '📝 HƯỚNG DẪN SỬ DỤNG:';
PRINT '=====================';
PRINT '';
PRINT '1. Trong Java DAO, sử dụng VIEW thay vì bảng trực tiếp:';
PRINT '   SELECT * FROM v_TableWithOrderStatus';
PRINT '';
PRINT '2. Để set bàn không khả dụng (bảo trì):';
PRINT '   UPDATE [Table] SET [Status] = ''unavailable'' WHERE TableID = 1';
PRINT '';
PRINT '3. Để set bàn về sẵn sàng:';
PRINT '   UPDATE [Table] SET [Status] = ''available'' WHERE TableID = 1';
PRINT '';
PRINT '4. Không cần trigger! Logic được xử lý trong VIEW';
PRINT '';
GO
