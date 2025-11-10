-- ===============================
-- FIX TABLE STATUS: Only 'available' and 'unavailable' allowed
-- ===============================

USE pizza_demo_DB_FinalModel;
GO

-- ===============================
-- IMPORTANT NOTE
-- ===============================
-- In the original schema, [Table] only has 2 statuses:
-- - 'available': Table is ready (may be empty or occupied)
-- - 'unavailable': Table is not available (maintenance, reserved)
--
-- There is NO 'occupied' status!
--
-- How to know if a table is occupied?
-- → Check [Order] table: If there's an Order with Status < 4, table is occupied
-- ===============================

-- ===============================
-- 1. Drop old triggers (if any)
-- ===============================
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_UpdateTableStatus_AfterOrderInsert')
    DROP TRIGGER trg_UpdateTableStatus_AfterOrderInsert;
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_UpdateTableStatus_AfterOrderUpdate')
    DROP TRIGGER trg_UpdateTableStatus_AfterOrderUpdate;
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_UpdateTableStatus_AfterOrderDelete')
    DROP TRIGGER trg_UpdateTableStatus_AfterOrderDelete;
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_UpdateTableStatus')
    DROP PROCEDURE sp_UpdateTableStatus;

PRINT 'Dropped old triggers/procedures (if any)';
GO

-- ===============================
-- 2. Fix all tables to valid status
-- ===============================
UPDATE [Table]
SET [Status] = 'available'
WHERE [Status] NOT IN ('available', 'unavailable');

PRINT 'Fixed all tables to valid status';
GO

-- ===============================
-- 3. Check current status
-- ===============================
PRINT '';
PRINT 'Current table status:';
PRINT '====================================';

SELECT 
    t.TableID,
    t.TableNumber,
    t.Capacity,
    t.[Status] AS TableStatus,
    t.IsActive,
    COUNT(o.OrderID) AS ActiveOrders,
    CASE 
        WHEN COUNT(o.OrderID) > 0 THEN 'Occupied (has customers)'
        WHEN t.[Status] = 'available' THEN 'Empty'
        WHEN t.[Status] = 'unavailable' THEN 'Not Available'
        ELSE 'Unknown'
    END AS ActualStatus
FROM [Table] t
LEFT JOIN [Order] o ON t.TableID = o.TableID AND o.[Status] < 4
WHERE t.IsActive = 1
GROUP BY t.TableID, t.TableNumber, t.Capacity, t.[Status], t.IsActive
ORDER BY t.TableNumber;
GO

-- ===============================
-- 4. EXPLAIN THE CORRECT LOGIC
-- ===============================
PRINT '';
PRINT 'CORRECT LOGIC:';
PRINT '==============';
PRINT '';
PRINT '   [Table] has only 2 statuses:';
PRINT '   - available: Table is ready (can be empty or occupied)';
PRINT '   - unavailable: Table not available (admin sets manually)';
PRINT '';
PRINT '   To know if table has customers:';
PRINT '   -> Check [Order] table';
PRINT '   -> If has Order with Status < 4 -> Table is occupied';
PRINT '   -> If no active Order -> Table is empty';
PRINT '';
PRINT '   EXAMPLE:';
PRINT '   - Table T01: Status = available, has 1 active Order -> Occupied';
PRINT '   - Table T02: Status = available, no Order -> Empty';
PRINT '   - Table T03: Status = unavailable -> Not Available';
PRINT '';
GO

-- ===============================
-- 5. Create VIEW for easy status checking
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

PRINT 'Created VIEW: v_TableWithOrderStatus';
PRINT '   Usage: SELECT * FROM v_TableWithOrderStatus';
GO

-- ===============================
-- 6. Test VIEW
-- ===============================
PRINT '';
PRINT 'Results from VIEW (actual status):';
PRINT '=========================================';

SELECT 
    TableID,
    TableNumber,
    Capacity,
    TableStatus AS DatabaseStatus,
    ActualStatus AS DisplayStatus,
    ActiveOrderCount,
    CASE ActualStatus
        WHEN 'available' THEN 'Empty'
        WHEN 'occupied' THEN 'Occupied (has customers)'
        WHEN 'unavailable' THEN 'Not Available'
    END AS StatusDescription
FROM v_TableWithOrderStatus
ORDER BY TableNumber;
GO

-- ===============================
-- 7. Usage Instructions
-- ===============================
PRINT '';
PRINT 'USAGE INSTRUCTIONS:';
PRINT '=====================';
PRINT '';
PRINT '1. In Java DAO, use VIEW instead of direct table query:';
PRINT '   SELECT * FROM v_TableWithOrderStatus';
PRINT '';
PRINT '2. To set table as unavailable (maintenance):';
PRINT '   UPDATE [Table] SET [Status] = ''unavailable'' WHERE TableID = 1';
PRINT '';
PRINT '3. To set table back to available:';
PRINT '   UPDATE [Table] SET [Status] = ''available'' WHERE TableID = 1';
PRINT '';
PRINT '4. No triggers needed! Logic is handled in VIEW';
PRINT '';
GO

-- ===============================
-- 8. Additional Helper Queries
-- ===============================

-- Query 1: Find all occupied tables
PRINT '';
PRINT 'Query 1: All occupied tables';
PRINT '============================';
SELECT * FROM v_TableWithOrderStatus WHERE ActualStatus = 'occupied';
GO

-- Query 2: Find all empty tables
PRINT '';
PRINT 'Query 2: All empty tables';
PRINT '=========================';
SELECT * FROM v_TableWithOrderStatus WHERE ActualStatus = 'available';
GO

-- Query 3: Find all unavailable tables
PRINT '';
PRINT 'Query 3: All unavailable tables';
PRINT '================================';
SELECT * FROM v_TableWithOrderStatus WHERE ActualStatus = 'unavailable';
GO

-- Query 4: Table statistics
PRINT '';
PRINT 'Query 4: Table statistics';
PRINT '=========================';
SELECT 
    ActualStatus,
    COUNT(*) AS TableCount,
    CASE ActualStatus
        WHEN 'available' THEN 'Empty tables'
        WHEN 'occupied' THEN 'Occupied tables'
        WHEN 'unavailable' THEN 'Unavailable tables'
    END AS Description
FROM v_TableWithOrderStatus
GROUP BY ActualStatus
ORDER BY ActualStatus;
GO

-- ===============================
-- 9. Test Scenarios
-- ===============================
PRINT '';
PRINT 'TEST SCENARIOS:';
PRINT '===============';
PRINT '';
PRINT 'Scenario 1: Create new order for table 2';
PRINT '   Before: Table 2 status = available, no orders -> Display: Empty';
PRINT '   Action: INSERT INTO [Order] (..., TableID = 2, Status = 0, ...)';
PRINT '   After: Table 2 status = available, 1 order -> Display: Occupied';
PRINT '';
PRINT 'Scenario 2: Complete order';
PRINT '   Before: Table 2 has 1 active order -> Display: Occupied';
PRINT '   Action: UPDATE [Order] SET Status = 4 WHERE TableID = 2';
PRINT '   After: Table 2 has 0 active orders -> Display: Empty';
PRINT '';
PRINT 'Scenario 3: Set table unavailable';
PRINT '   Action: UPDATE [Table] SET Status = ''unavailable'' WHERE TableID = 2';
PRINT '   Result: Table 2 -> Display: Not Available (regardless of orders)';
PRINT '';
GO

PRINT '';
PRINT '===========================================';
PRINT 'FIX COMPLETED SUCCESSFULLY!';
PRINT '===========================================';
PRINT '';
PRINT 'Next steps:';
PRINT '1. Restart your application server';
PRINT '2. Access /assign-table page';
PRINT '3. Create a new order for a table';
PRINT '4. Refresh page -> Table should show as "Occupied"';
PRINT '5. Complete the order (Status = 4)';
PRINT '6. Refresh page -> Table should show as "Empty"';
PRINT '';
GO
