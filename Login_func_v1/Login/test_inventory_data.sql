-- Test query to check Inventory table
SELECT COUNT(*) as TotalItems FROM Inventory;

SELECT TOP 10 * FROM Inventory ORDER BY InventoryID;

-- Check if table exists
SELECT TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_NAME = 'Inventory';
