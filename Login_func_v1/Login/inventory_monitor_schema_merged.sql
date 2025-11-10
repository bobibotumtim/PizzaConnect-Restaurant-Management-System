-- ===========================
-- INVENTORY MONITOR DASHBOARD SCHEMA FOR pizza_demo_DB_Merged
-- ===========================
-- This script creates the database schema for the inventory monitoring dashboard
-- Run this script on the pizza_demo_DB_Merged database

USE pizza_demo_DB_Merged;
GO

-- Table: InventoryThresholds - Stores threshold values for inventory alerts
CREATE TABLE InventoryThresholds (
    ThresholdID INT IDENTITY(1,1) PRIMARY KEY,
    InventoryID INT NOT NULL,
    LowStockThreshold DECIMAL(10,2) DEFAULT 10,
    CriticalThreshold DECIMAL(10,2) DEFAULT 5,
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (InventoryID) REFERENCES Inventory(InventoryID)
);
GO

-- Table: InventoryLog - Tracks inventory changes for trend analysis
CREATE TABLE InventoryLog (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    InventoryID INT NOT NULL,
    OldQuantity DECIMAL(10,2),
    NewQuantity DECIMAL(10,2),
    ChangeType VARCHAR(20), -- 'UPDATE', 'USAGE', 'RESTOCK'
    ChangeReason VARCHAR(100),
    LogDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (InventoryID) REFERENCES Inventory(InventoryID)
);
GO

-- Table: CriticalItems - Marks items as critical for pizza operations
CREATE TABLE CriticalItems (
    CriticalItemID INT IDENTITY(1,1) PRIMARY KEY,
    InventoryID INT NOT NULL,
    Priority INT DEFAULT 1, -- 1=High, 2=Medium, 3=Low
    Category VARCHAR(50), -- 'DOUGH', 'CHEESE', 'SAUCE', 'TOPPING'
    IsActive BIT DEFAULT 1,
    FOREIGN KEY (InventoryID) REFERENCES Inventory(InventoryID)
);
GO

-- ===========================
-- INDEXES FOR PERFORMANCE OPTIMIZATION
-- ===========================

-- Index on InventoryThresholds for quick threshold lookups
CREATE INDEX IX_InventoryThresholds_InventoryID ON InventoryThresholds(InventoryID);
CREATE INDEX IX_InventoryThresholds_Active ON InventoryThresholds(IsActive);

-- Index on InventoryLog for trend analysis queries
CREATE INDEX IX_InventoryLog_InventoryID_Date ON InventoryLog(InventoryID, LogDate DESC);
CREATE INDEX IX_InventoryLog_Date ON InventoryLog(LogDate DESC);
CREATE INDEX IX_InventoryLog_ChangeType ON InventoryLog(ChangeType);

-- Index on CriticalItems for quick critical item lookups
CREATE INDEX IX_CriticalItems_InventoryID ON CriticalItems(InventoryID);
CREATE INDEX IX_CriticalItems_Category ON CriticalItems(Category);
CREATE INDEX IX_CriticalItems_Priority ON CriticalItems(Priority);
CREATE INDEX IX_CriticalItems_Active ON CriticalItems(IsActive);

-- ===========================
-- DEFAULT THRESHOLD DATA FOR EXISTING INVENTORY ITEMS
-- ===========================

-- Insert default thresholds for all existing inventory items
INSERT INTO InventoryThresholds (InventoryID, LowStockThreshold, CriticalThreshold, IsActive)
SELECT 
    InventoryID,
    CASE 
        -- Higher thresholds for essential ingredients
        WHEN ItemName LIKE '%Dough%' OR ItemName LIKE '%Cheese%' THEN 20
        -- Medium thresholds for proteins and main ingredients
        WHEN ItemName LIKE '%Ham%' OR ItemName LIKE '%Coffee%' OR ItemName LIKE '%Milk%' THEN 15
        -- Lower thresholds for seasonings and extras
        ELSE 10
    END AS LowStockThreshold,
    CASE 
        -- Higher critical thresholds for essential ingredients
        WHEN ItemName LIKE '%Dough%' OR ItemName LIKE '%Cheese%' THEN 10
        -- Medium critical thresholds for proteins and main ingredients
        WHEN ItemName LIKE '%Ham%' OR ItemName LIKE '%Coffee%' OR ItemName LIKE '%Milk%' THEN 8
        -- Lower critical thresholds for seasonings and extras
        ELSE 5
    END AS CriticalThreshold,
    1 AS IsActive
FROM Inventory
WHERE NOT EXISTS (
    SELECT 1 FROM InventoryThresholds IT WHERE IT.InventoryID = Inventory.InventoryID
);
GO

-- ===========================
-- CRITICAL ITEMS SETUP FOR PIZZA INGREDIENTS
-- ===========================

-- Mark essential pizza ingredients as critical items
INSERT INTO CriticalItems (InventoryID, Priority, Category, IsActive)
SELECT 
    I.InventoryID,
    CASE 
        WHEN I.ItemName LIKE '%Dough%' THEN 1  -- High priority for dough base
        WHEN I.ItemName LIKE '%Cheese%' THEN 1  -- High priority for cheese
        WHEN I.ItemName LIKE '%Ham%' OR I.ItemName LIKE '%Pineapple%' THEN 2  -- Medium priority for toppings
        WHEN I.ItemName LIKE '%Coffee%' OR I.ItemName LIKE '%Tea%' OR I.ItemName LIKE '%Milk%' THEN 2  -- Medium priority for beverages
        ELSE 3  -- Low priority for other items
    END AS Priority,
    CASE 
        WHEN I.ItemName LIKE '%Dough%' THEN 'DOUGH'
        WHEN I.ItemName LIKE '%Cheese%' THEN 'CHEESE'
        WHEN I.ItemName LIKE '%Ham%' OR I.ItemName LIKE '%Pineapple%' THEN 'TOPPING'
        WHEN I.ItemName LIKE '%Coffee%' OR I.ItemName LIKE '%Tea%' OR I.ItemName LIKE '%Milk%' THEN 'BEVERAGE'
        ELSE 'OTHER'
    END AS Category,
    1 AS IsActive
FROM Inventory I
WHERE NOT EXISTS (
    SELECT 1 FROM CriticalItems CI WHERE CI.InventoryID = I.InventoryID
);
GO

-- ===========================
-- SAMPLE INVENTORY LOG DATA FOR TESTING
-- ===========================

-- Insert sample log entries for the past 7 days to enable trend analysis
DECLARE @StartDate DATETIME = DATEADD(DAY, -7, GETDATE());
DECLARE @CurrentDate DATETIME = @StartDate;
DECLARE @InventoryID INT;
DECLARE @CurrentQuantity DECIMAL(10,2);
DECLARE @NewQuantity DECIMAL(10,2);

-- Create sample usage patterns for critical items over the past week
WHILE @CurrentDate <= GETDATE()
BEGIN
    -- Simulate daily usage for dough (InventoryID = 1)
    SELECT @CurrentQuantity = Quantity FROM Inventory WHERE InventoryID = 1;
    SET @NewQuantity = @CurrentQuantity - (RAND() * 5 + 2); -- Random usage between 2-7 kg per day
    
    INSERT INTO InventoryLog (InventoryID, OldQuantity, NewQuantity, ChangeType, ChangeReason, LogDate)
    VALUES (1, @CurrentQuantity, @NewQuantity, 'USAGE', 'Daily pizza production', @CurrentDate);
    
    -- Simulate daily usage for cheese (InventoryID = 2)
    SELECT @CurrentQuantity = Quantity FROM Inventory WHERE InventoryID = 2;
    SET @NewQuantity = @CurrentQuantity - (RAND() * 3 + 1); -- Random usage between 1-4 kg per day
    
    INSERT INTO InventoryLog (InventoryID, OldQuantity, NewQuantity, ChangeType, ChangeReason, LogDate)
    VALUES (2, @CurrentQuantity, @NewQuantity, 'USAGE', 'Daily pizza production', @CurrentDate);
    
    -- Simulate daily usage for ham (InventoryID = 3)
    SELECT @CurrentQuantity = Quantity FROM Inventory WHERE InventoryID = 3;
    SET @NewQuantity = @CurrentQuantity - (RAND() * 2 + 0.5); -- Random usage between 0.5-2.5 kg per day
    
    INSERT INTO InventoryLog (InventoryID, OldQuantity, NewQuantity, ChangeType, ChangeReason, LogDate)
    VALUES (3, @CurrentQuantity, @NewQuantity, 'USAGE', 'Daily pizza production', @CurrentDate);
    
    SET @CurrentDate = DATEADD(DAY, 1, @CurrentDate);
END
GO

PRINT 'Inventory Monitor Dashboard schema created successfully for pizza_demo_DB_Merged!';
PRINT 'Tables created: InventoryThresholds, InventoryLog, CriticalItems';
PRINT 'Indexes created for performance optimization';
PRINT 'Default threshold data inserted for existing inventory items';
PRINT 'Critical items marked for pizza ingredients';
PRINT 'Sample log data created for trend analysis testing';
GO