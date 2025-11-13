-- =============================================
-- Test InventoryMonitor View
-- Purpose: Verify warning levels are calculated correctly
-- =============================================

PRINT '========================================';
PRINT 'Testing v_InventoryMonitor View';
PRINT '========================================';
PRINT '';

-- Test 1: Check if view exists and show structure
PRINT '--- Test 1: View Structure ---';
SELECT TOP 1 * FROM dbo.v_InventoryMonitor;
PRINT '';

-- Test 2: Show all records with warning levels
PRINT '--- Test 2: All Inventory Items with Warning Levels ---';
SELECT 
    InventoryID,
    ItemName,
    Quantity,
    Unit,
    Status,
    LowThreshold,
    CriticalThreshold,
    StockLevel,
    PercentOfLowLevel,
    LastUpdated
FROM dbo.v_InventoryMonitor
ORDER BY 
    CASE StockLevel
        WHEN 'CRITICAL' THEN 1
        WHEN 'LOW' THEN 2
        WHEN 'OK' THEN 3
        WHEN 'INACTIVE' THEN 4
        ELSE 5
    END,
    ItemName;
PRINT '';

-- Test 3: Count items by warning level
PRINT '--- Test 3: Warning Level Distribution ---';
SELECT 
    StockLevel,
    COUNT(*) as ItemCount,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() AS DECIMAL(5,2)) as Percentage
FROM dbo.v_InventoryMonitor
GROUP BY StockLevel
ORDER BY 
    CASE StockLevel
        WHEN 'CRITICAL' THEN 1
        WHEN 'LOW' THEN 2
        WHEN 'OK' THEN 3
        WHEN 'INACTIVE' THEN 4
    END;
PRINT '';

-- Test 4: Verify CRITICAL items (Quantity <= CriticalThreshold and Status = 'Active')
PRINT '--- Test 4: CRITICAL Items ---';
SELECT 
    InventoryID,
    ItemName,
    Quantity,
    CriticalThreshold,
    Status,
    StockLevel
FROM dbo.v_InventoryMonitor
WHERE StockLevel = 'CRITICAL'
ORDER BY Quantity, ItemName;
PRINT '';

-- Test 5: Verify LOW items (CriticalThreshold < Quantity <= LowThreshold and Status = 'Active')
PRINT '--- Test 5: LOW Items ---';
SELECT 
    InventoryID,
    ItemName,
    Quantity,
    CriticalThreshold,
    LowThreshold,
    Status,
    StockLevel
FROM dbo.v_InventoryMonitor
WHERE StockLevel = 'LOW'
ORDER BY Quantity, ItemName;
PRINT '';

-- Test 6: Verify OK items (Quantity > LowThreshold and Status = 'Active')
PRINT '--- Test 6: OK Items ---';
SELECT 
    InventoryID,
    ItemName,
    Quantity,
    LowThreshold,
    Status,
    StockLevel
FROM dbo.v_InventoryMonitor
WHERE StockLevel = 'OK'
ORDER BY Quantity DESC, ItemName;
PRINT '';

-- Test 7: Verify INACTIVE items (Status = 'Inactive')
PRINT '--- Test 7: INACTIVE Items (Status = Inactive) ---';
SELECT 
    InventoryID,
    ItemName,
    Quantity,
    Status,
    StockLevel
FROM dbo.v_InventoryMonitor
WHERE StockLevel = 'INACTIVE'
ORDER BY ItemName;
PRINT '';

-- Test 8: Verify warning level logic is correct
PRINT '--- Test 8: Logic Verification ---';
PRINT 'Checking for any items with incorrect warning levels...';
SELECT 
    InventoryID,
    ItemName,
    Quantity,
    CriticalThreshold,
    LowThreshold,
    Status,
    StockLevel,
    CASE
        WHEN Status = 'Inactive' AND StockLevel != 'INACTIVE' THEN 'ERROR: Should be INACTIVE'
        WHEN Status = 'Active' AND Quantity <= CriticalThreshold AND StockLevel != 'CRITICAL' THEN 'ERROR: Should be CRITICAL'
        WHEN Status = 'Active' AND Quantity > CriticalThreshold AND Quantity <= LowThreshold AND StockLevel != 'LOW' THEN 'ERROR: Should be LOW'
        WHEN Status = 'Active' AND Quantity > LowThreshold AND StockLevel != 'OK' THEN 'ERROR: Should be OK'
        ELSE 'CORRECT'
    END AS ValidationResult
FROM dbo.v_InventoryMonitor
WHERE 
    (Status = 'Inactive' AND StockLevel != 'INACTIVE')
    OR (Status = 'Active' AND Quantity <= CriticalThreshold AND StockLevel != 'CRITICAL')
    OR (Status = 'Active' AND Quantity > CriticalThreshold AND Quantity <= LowThreshold AND StockLevel != 'LOW')
    OR (Status = 'Active' AND Quantity > LowThreshold AND StockLevel != 'OK');

IF @@ROWCOUNT = 0
    PRINT '✅ All warning levels are calculated correctly!';
ELSE
    PRINT '❌ Found items with incorrect warning levels!';
PRINT '';

PRINT '========================================';
PRINT 'Test Complete';
PRINT '========================================';
