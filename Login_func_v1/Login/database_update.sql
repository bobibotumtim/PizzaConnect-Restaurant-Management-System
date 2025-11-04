-- Add Status column to Inventory table
ALTER TABLE Inventory 
ADD Status NVARCHAR(20) DEFAULT 'Active' NOT NULL;

-- Update existing records to have Active status
UPDATE Inventory SET Status = 'Active' WHERE Status IS NULL;

-- Add check constraint to ensure only valid status values
ALTER TABLE Inventory 
ADD CONSTRAINT CK_Inventory_Status CHECK (Status IN ('Active', 'Inactive'));