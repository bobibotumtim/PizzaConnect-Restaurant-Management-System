-- =============================================
-- Create InventoryMonitor View
-- Purpose: Monitor inventory levels with warning levels
-- =============================================

-- Drop view if exists
IF OBJECT_ID('dbo.InventoryMonitor', 'V') IS NOT NULL
    DROP VIEW dbo.InventoryMonitor;
GO

-- Create InventoryMonitor View
CREATE VIEW dbo.InventoryMonitor AS
SELECT
    i.InventoryID,
    i.ItemName,
    i.Quantity,
    i.Unit,
    i.Status,
    i.LastUpdated,
    -- Calculate warning level based on quantity thresholds
    CASE
        WHEN i.Status = 'Inactive' THEN 'INACTIVE'
        WHEN i.Quantity <= 10 THEN 'CRITICAL'
        WHEN i.Quantity <= 50 THEN 'LOW'
        ELSE 'OK'
    END AS WarningLevel,
    -- Calculate percentage for progress bars
    CASE
        WHEN i.Quantity > 100 THEN 100.0
        ELSE CAST(i.Quantity AS FLOAT)
    END AS StockPercentage,
    -- Add priority for sorting (Critical = 1, Inactive = 4)
    CASE
        WHEN i.Status = 'Inactive' THEN 4
        WHEN i.Quantity <= 10 THEN 1
        WHEN i.Quantity <= 50 THEN 2
        ELSE 3
    END AS Priority
FROM Inventory i;
GO

-- Test the view with sample queries
PRINT '✅ InventoryMonitor view created successfully';
PRINT '';
PRINT '--- Testing view with all records ---';
SELECT * FROM dbo.InventoryMonitor ORDER BY Priority, ItemName;
PRINT '';

PRINT '--- Testing CRITICAL items (Quantity <= 10) ---';
SELECT * FROM dbo.InventoryMonitor WHERE WarningLevel = 'CRITICAL' ORDER BY ItemName;
PRINT '';

PRINT '--- Testing LOW items (11 <= Quantity <= 50) ---';
SELECT * FROM dbo.InventoryMonitor WHERE WarningLevel = 'LOW' ORDER BY ItemName;
PRINT '';

PRINT '--- Testing OK items (Quantity > 50) ---';
SELECT * FROM dbo.InventoryMonitor WHERE WarningLevel = 'OK' ORDER BY ItemName;
PRINT '';

PRINT '--- Testing INACTIVE items ---';
SELECT * FROM dbo.InventoryMonitor WHERE WarningLevel = 'INACTIVE' ORDER BY ItemName;
PRINT '';

PRINT '--- Warning Level Counts ---';
SELECT 
    WarningLevel, 
    COUNT(*) as Count 
FROM dbo.InventoryMonitor 
GROUP BY WarningLevel 
ORDER BY 
    CASE WarningLevel
        WHEN 'CRITICAL' THEN 1
        WHEN 'LOW' THEN 2
        WHEN 'OK' THEN 3
        WHEN 'INACTIVE' THEN 4
    END;
GO
