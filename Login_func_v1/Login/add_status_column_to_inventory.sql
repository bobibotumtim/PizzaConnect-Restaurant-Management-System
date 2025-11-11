-- Add Status column to Inventory table
-- This fixes the "Invalid column name 'Status'" error

USE pizza_demo_DB_FinalModel;
GO

-- Check if Status column already exists
IF NOT EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'Inventory' 
    AND COLUMN_NAME = 'Status'
)
BEGIN
    -- Add Status column with default value 'Active'
    ALTER TABLE Inventory 
    ADD Status NVARCHAR(20) NOT NULL DEFAULT 'Active';
    
    PRINT 'Status column added successfully to Inventory table';
END
ELSE
BEGIN
    PRINT 'Status column already exists in Inventory table';
END
GO

-- Update all existing records to have 'Active' status
UPDATE Inventory 
SET Status = 'Active' 
WHERE Status IS NULL OR Status = '';
GO

-- Verify the change
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE,
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Inventory'
ORDER BY ORDINAL_POSITION;
GO

-- Show sample data with new Status column
SELECT TOP 5 
    InventoryID,
    ItemName,
    Quantity,
    Unit,
    Status,
    LastUpdated
FROM Inventory
ORDER BY InventoryID;
GO

PRINT 'Done! Status column has been added to Inventory table.';
PRINT 'All existing items are set to Active status.';
