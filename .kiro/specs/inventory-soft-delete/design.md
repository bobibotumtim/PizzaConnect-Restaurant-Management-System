# Design Document

## Overview

This design restores the status filtering functionality in the Inventory Management system. The system already has all UI components and database schema in place, but the InventoryDAO has disabled status filtering logic. This design focuses on re-enabling the filtering in InventoryDAO methods while maintaining compatibility with existing servlet and JSP code.

## Architecture

### Current Architecture (Existing)

```
[ManageInventory.jsp]
    ↓ (HTTP GET/POST)
[InventoryServlet] (/manageinventory)
    ↓ (method calls)
[InventoryDAO]
    ↓ (SQL queries)
[SQL Server Database - Inventory Table]
```

### Components Involved

1. **Database Layer**: Inventory table with Status column (NVARCHAR(20), NOT NULL, DEFAULT 'Active')
2. **DAO Layer**: InventoryDAO.java - needs status filter restoration
3. **Controller Layer**: InventoryServlet.java - already handles status parameters correctly
4. **Utility Layer**: URLUtils.java - already handles status parameter preservation
5. **View Layer**: ManageInventory.jsp - already has status filter UI

## Components and Interfaces

### 1. InventoryDAO Modifications

#### Methods to Modify

**getTotalInventoryCount(String searchName, String statusFilter)**

- Currently ignores statusFilter parameter
- Need to add SQL condition based on statusFilter value
- Return count of items matching both search and status criteria

**getInventoriesByPage(int page, int pageSize, String searchName, String statusFilter)**

- Currently ignores statusFilter parameter and doesn't SELECT Status column
- Need to add Status to SELECT clause
- Need to add SQL condition based on statusFilter value
- Need to set status on Inventory objects from ResultSet

#### Status Filter Logic

```java
// Pseudo-code for status filtering
if (statusFilter != null && !statusFilter.equals("all")) {
    if (statusFilter.equalsIgnoreCase("active")) {
        sql.append(" AND Status = 'Active'");
    } else if (statusFilter.equalsIgnoreCase("inactive")) {
        sql.append(" AND Status = 'Inactive'");
    }
}
```

#### SQL Query Structure

**Count Query:**

```sql
SELECT COUNT(*)
FROM Inventory
WHERE 1=1
  [AND ItemName LIKE ?]
  [AND Status = ?]
```

**Paginated Query:**

```sql
SELECT InventoryID, ItemName, Quantity, Unit, LastUpdated, Status
FROM Inventory
WHERE 1=1
  [AND ItemName LIKE ?]
  [AND Status = ?]
ORDER BY InventoryID
OFFSET ? ROWS FETCH NEXT ? ROWS ONLY
```

### 2. Existing Components (No Changes Needed)

#### InventoryServlet

- Already calls `dao.getTotalInventoryCount(searchName, statusFilter)`
- Already calls `dao.getInventoriesByPage(page, pageSize, searchName, statusFilter)`
- Already uses `URLUtils.normalizeStatusFilter()` to default to "all"
- Already preserves statusFilter in edit/toggle redirects

#### URLUtils

- Already has `normalizeStatusFilter()` method
- Already includes statusFilter in `buildInventoryUrl()` method
- Already handles "all" as default value

#### ManageInventory.jsp

- Already has status filter dropdown with options: all, active, inactive
- Already displays status badges (green for Active, gray for Inactive)
- Already shows appropriate Activate/Deactivate buttons
- Already preserves statusFilter in pagination and action URLs

#### Inventory Model

- Already has `status` field with getter/setter
- No changes needed

## Data Models

### Inventory Table Schema

```sql
CREATE TABLE Inventory (
    InventoryID INT PRIMARY KEY IDENTITY(1,1),
    ItemName NVARCHAR(100) NOT NULL,
    Quantity FLOAT NOT NULL,
    Unit NVARCHAR(50) NOT NULL,
    LastUpdated DATETIME NOT NULL DEFAULT GETDATE(),
    Status NVARCHAR(20) NOT NULL DEFAULT 'Active'
)
```

### Inventory Java Model

```java
public class Inventory {
    private int inventoryID;
    private String itemName;
    private double quantity;
    private String unit;
    private Timestamp lastUpdated;
    private String status; // "Active" or "Inactive"

    // getters and setters
}
```

## Error Handling

### Database Errors

- SQLException in DAO methods: Print stack trace and return empty list/0 count
- Maintain existing error handling pattern (try-catch with printStackTrace)

### Invalid Status Values

- URLUtils.normalizeStatusFilter() ensures only valid values: "all", "active", "inactive"
- Case-insensitive comparison in DAO (use equalsIgnoreCase)
- Invalid values default to "all" (show all items)

### Null Parameter Handling

- searchName: null or empty treated as no search filter
- statusFilter: null defaults to "all" via URLUtils.normalizeStatusFilter()
- Existing null checks in DAO methods are sufficient

## Testing Strategy

### Unit Testing Approach

**DAO Method Tests:**

1. Test `getTotalInventoryCount()` with statusFilter="active" - should count only Active items
2. Test `getTotalInventoryCount()` with statusFilter="inactive" - should count only Inactive items
3. Test `getTotalInventoryCount()` with statusFilter="all" - should count all items
4. Test `getInventoriesByPage()` with statusFilter="active" - should return only Active items with Status field populated
5. Test `getInventoriesByPage()` with statusFilter="inactive" - should return only Inactive items with Status field populated
6. Test combined search + status filter - should apply both conditions

### Integration Testing Approach

**Servlet Integration Tests:**

1. Test GET /manageinventory?statusFilter=active - should display only active items
2. Test GET /manageinventory?statusFilter=inactive - should display only inactive items
3. Test GET /manageinventory?statusFilter=all - should display all items
4. Test status filter persistence after toggle action
5. Test status filter persistence after edit and save
6. Test pagination with status filter applied

### Manual Testing Checklist

1. Run add_status_column_to_inventory.sql to ensure Status column exists
2. Verify existing items have Status = 'Active'
3. Test status filter dropdown changes update the list correctly
4. Test toggle action changes status and preserves filter
5. Test search + status filter combination
6. Test pagination maintains status filter
7. Test page size change maintains status filter
8. Verify status badges display correctly (green/gray)
9. Verify Activate/Deactivate buttons show correctly based on status

## Implementation Notes

### Key Changes Summary

1. **InventoryDAO.getTotalInventoryCount(String, String)**

   - Add status filter SQL condition
   - No changes to method signature or return type

2. **InventoryDAO.getInventoriesByPage(int, int, String, String)**
   - Add Status to SELECT clause
   - Add status filter SQL condition
   - Add `inv.setStatus(rs.getString("Status"))` when building Inventory objects

### Backward Compatibility

- All changes are internal to InventoryDAO
- Method signatures remain unchanged
- Servlet and JSP code require no modifications
- Existing functionality (search, pagination, toggle) continues to work
- Default behavior (statusFilter="all") shows all items as before

### Performance Considerations

- Status column should be indexed if table grows large
- Existing OFFSET/FETCH pagination is efficient
- Status filter adds minimal overhead to WHERE clause
- No N+1 query issues - single query per page load

## Database Migration

### Migration Script

The existing `add_status_column_to_inventory.sql` script handles:

- Checking if Status column exists
- Adding Status column with proper constraints
- Setting default value 'Active'
- Updating existing records to 'Active'

No additional migration scripts needed.

### Rollback Plan

If issues occur:

1. Status filtering can be disabled by passing statusFilter="all"
2. No database changes are required (Status column already exists)
3. Revert InventoryDAO changes to previous version
4. System will continue to work without filtering

## Security Considerations

### SQL Injection Prevention

- Use parameterized PreparedStatement for all queries
- Status filter values validated by URLUtils.normalizeStatusFilter()
- Only allow: "all", "active", "inactive" (case-insensitive)
- Search parameter already uses LIKE with ? placeholder

### Access Control

- Existing servlet security applies (no changes)
- Status toggle requires same permissions as edit
- No new security vulnerabilities introduced

## Future Enhancements

1. Add index on Status column for better performance
2. Add audit log for status changes (who changed, when, old/new value)
3. Add bulk status change operations (activate/deactivate multiple items)
4. Add "Recently Deactivated" quick filter
5. Add status change history view per item
