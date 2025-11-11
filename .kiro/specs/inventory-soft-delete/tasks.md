# Implementation Plan

- [x] 1. Fix InventoryDAO getTotalInventoryCount method to support status filtering

  - Modify the `getTotalInventoryCount(String searchName, String statusFilter)` method in InventoryDAO.java
  - Add SQL WHERE clause condition for status filtering based on statusFilter parameter
  - Handle three cases: "active" (Status = 'Active'), "inactive" (Status = 'Inactive'), and "all" (no status filter)
  - Use case-insensitive comparison for statusFilter values
  - Maintain existing parameterized query pattern for SQL injection prevention
  - _Requirements: 1.5, 6.1, 6.2, 6.3_

- [x] 2. Fix InventoryDAO getInventoriesByPage method to include Status column and filtering

  - [x] 2.1 Add Status column to SELECT statement

    - Modify the SQL query in `getInventoriesByPage(int page, int pageSize, String searchName, String statusFilter)` method
    - Add "Status" to the SELECT clause: "SELECT InventoryID, ItemName, Quantity, Unit, LastUpdated, Status"
    - Add `inv.setStatus(rs.getString("Status"))` when building Inventory objects from ResultSet
    - _Requirements: 3.1, 3.2, 3.3, 6.5_

  - [x] 2.2 Add status filtering logic to WHERE clause

    - Add SQL WHERE clause condition for status filtering based on statusFilter parameter
    - Handle three cases: "active", "inactive", and "all" (same logic as getTotalInventoryCount)
    - Ensure proper parameter indexing when both searchName and statusFilter are present
    - Use PreparedStatement.setString() for status parameter
    - _Requirements: 1.1, 1.2, 1.3, 6.1, 6.2, 6.3_

- [ ] 3. Verify database Status column exists

  - Review the add_status_column_to_inventory.sql script to ensure it's correct
  - Verify the script checks for column existence before adding
  - Confirm default value is 'Active' and column is NOT NULL
  - Document that this script should be run before testing the feature
  - _Requirements: 8.1, 8.2, 8.3, 8.4_

- [ ]\* 4. Test status filtering functionality

  - [ ]\* 4.1 Test DAO methods with different status filter values

    - Test getTotalInventoryCount with statusFilter="active", "inactive", "all", and null
    - Test getInventoriesByPage with statusFilter="active", "inactive", "all", and null
    - Verify Status field is populated in returned Inventory objects
    - Test combined search + status filter scenarios
    - _Requirements: 1.1, 1.2, 1.3, 6.1, 6.2, 6.3, 6.5_

  - [ ]\* 4.2 Test servlet integration with status filter

    - Test GET /manageinventory?statusFilter=active displays only active items
    - Test GET /manageinventory?statusFilter=inactive displays only inactive items
    - Test GET /manageinventory?statusFilter=all displays all items
    - Verify item count updates correctly based on filter
    - Verify pagination works correctly with status filter applied
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5_

  - [ ]\* 4.3 Test status filter persistence
    - Test status filter is preserved when toggling item status
    - Test status filter is preserved when editing and saving an item
    - Test status filter is preserved when changing pages
    - Test status filter is preserved when changing page size
    - Verify URL parameters include statusFilter correctly
    - _Requirements: 1.4, 5.1, 5.2, 5.3, 5.4, 5.5_

- [ ]\* 5. Verify UI displays status correctly
  - Verify status badges display correctly (green "Active", gray "Inactive")
  - Verify Activate/Deactivate buttons show based on current status
  - Verify confirmation dialogs appear when clicking Activate/Deactivate
  - Verify success messages show correct item name and new status after toggle
  - Test status filter dropdown maintains selection after operations
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 4.1, 4.2, 4.3, 4.4, 4.5_
