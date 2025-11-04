-- Create separate table to track inventory status
CREATE TABLE InventoryStatus (
    InventoryID INT PRIMARY KEY,
    Status NVARCHAR(20) DEFAULT 'Active' NOT NULL,
    LastStatusChange DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (InventoryID) REFERENCES Inventory(InventoryID) ON DELETE CASCADE,
    CONSTRAINT CK_InventoryStatus_Status CHECK (Status IN ('Active', 'Inactive'))
);

-- Insert default Active status for all existing inventory items
INSERT INTO InventoryStatus (InventoryID, Status)
SELECT InventoryID, 'Active' 
FROM Inventory 
WHERE InventoryID NOT IN (SELECT InventoryID FROM InventoryStatus);