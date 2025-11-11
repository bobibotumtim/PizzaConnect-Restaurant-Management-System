# Inventory Status Column Setup Guide

## Overview

This guide explains how to add the Status column to the Inventory table to enable soft delete functionality.

## Prerequisites

- SQL Server Management Studio (SSMS) or any SQL Server client
- Access to the `pizza_demo_DB_FinalModel` database
- Appropriate permissions to ALTER TABLE

## Setup Instructions

### Step 1: Run the SQL Script

1. Open SQL Server Management Studio
2. Connect to your SQL Server instance
3. Open the file: `add_status_column_to_inventory.sql`
4. Execute the script (F5 or click Execute button)

### Step 2: Verify the Changes

The script will automatically:

- Check if the Status column already exists
- Add the Status column if it doesn't exist (NVARCHAR(20) NOT NULL DEFAULT 'Active')
- Update all existing records to have Status = 'Active'
- Display the table structure to verify the change
- Show sample data with the new Status column

### Expected Output

You should see messages like:

```
Status column added successfully to Inventory table
Done! Status column has been added to Inventory table.
All existing items are set to Active status.
```

And a table showing the Inventory table structure including the new Status column.

## What the Script Does

1. **Checks for Existing Column**: Uses INFORMATION_SCHEMA.COLUMNS to check if Status column exists
2. **Adds Column Safely**: Only adds the column if it doesn't exist (prevents errors on re-run)
3. **Sets Default Value**: All new items will automatically have Status = 'Active'
4. **Updates Existing Data**: Sets Status = 'Active' for all existing inventory items
5. **Verifies Changes**: Shows table structure and sample data to confirm success

## Database Schema After Setup

```sql
CREATE TABLE Inventory (
    InventoryID INT PRIMARY KEY IDENTITY(1,1),
    ItemName NVARCHAR(100) NOT NULL,
    Quantity FLOAT NOT NULL,
    Unit NVARCHAR(50) NOT NULL,
    LastUpdated DATETIME NOT NULL DEFAULT GETDATE(),
    Status NVARCHAR(20) NOT NULL DEFAULT 'Active'  -- NEW COLUMN
)
```

## Status Values

- **Active**: Item is available for use (default for new items)
- **Inactive**: Item has been soft-deleted (hidden from normal operations)

## Testing the Setup

After running the script, you can test by:

1. **Check all items are Active**:

   ```sql
   SELECT InventoryID, ItemName, Status FROM Inventory;
   ```

   All items should show Status = 'Active'

2. **Test toggle functionality**:

   - Go to the Manage Inventory page: http://localhost:8080/Login/manageinventory
   - Click "Deactivate" on any item
   - Verify the status changes to "Inactive"
   - Click "Activate" to change it back to "Active"

3. **Test status filtering**:
   - Use the "Status Filter" dropdown on the Manage Inventory page
   - Select "Active Only" - should show only active items
   - Select "Inactive Only" - should show only inactive items
   - Select "All Status" - should show all items

## Troubleshooting

### Error: "Invalid column name 'Status'"

This means the script hasn't been run yet. Run `add_status_column_to_inventory.sql` to fix this.

### Error: "Column names in each table must be unique"

This means the Status column already exists. The script is safe to re-run - it will detect the existing column and skip the ALTER TABLE statement.

### Items not showing correct status

Run this query to check the data:

```sql
SELECT InventoryID, ItemName, Status FROM Inventory;
```

If Status is NULL or empty, run:

```sql
UPDATE Inventory SET Status = 'Active' WHERE Status IS NULL OR Status = '';
```

## Rollback (if needed)

If you need to remove the Status column:

```sql
USE pizza_demo_DB_FinalModel;
GO

ALTER TABLE Inventory DROP COLUMN Status;
GO
```

**Warning**: This will permanently delete the Status column and all status data. Only do this if you're sure you want to remove the soft delete functionality.

## Next Steps

After successfully running the script:

1. Restart your application server (if running)
2. Test the Manage Inventory page
3. Verify status filtering works correctly
4. Test the Activate/Deactivate buttons

## Support

If you encounter any issues:

1. Check the SQL Server error messages
2. Verify you have the correct database selected
3. Ensure you have ALTER TABLE permissions
4. Check that the database name matches: `pizza_demo_DB_FinalModel`
