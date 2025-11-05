-- ===============================
-- MIGRATION: Update Order and OrderDetail Status
-- Date: 2025-11-05
-- Description: Update status values to match new workflow
-- ===============================

USE PizzaDB;
GO

-- 1. Update OrderDetail Status values
-- Old: "In Progress" -> New: "Preparing"
-- Old: "Done" -> New: "Ready"
UPDATE OrderDetail 
SET Status = 'Preparing' 
WHERE Status = 'In Progress';

UPDATE OrderDetail 
SET Status = 'Ready' 
WHERE Status = 'Done';

-- 2. Update Order Status meanings (no data change needed, just documentation)
-- Status values remain 0,1,2,3 but meanings changed:
-- 0 = Đang dùng bữa (Dining) - was "Pending"
-- 1 = Đã phục vụ xong (Served) - was "Processing"  
-- 2 = Hoàn thành (Completed) - same
-- 3 = Đã hủy (Cancelled) - same

-- 3. Verify changes
SELECT 'OrderDetail Status Distribution' as Info;
SELECT Status, COUNT(*) as Count 
FROM OrderDetail 
GROUP BY Status;

SELECT 'Order Status Distribution' as Info;
SELECT Status, COUNT(*) as Count 
FROM [Order] 
GROUP BY Status;

PRINT 'Migration completed successfully!';
GO
