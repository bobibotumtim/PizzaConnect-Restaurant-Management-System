# Requirements Document

## Introduction

This feature fixes and completes the existing Inventory Management soft delete functionality. The system already has a Status column in the database and UI components for status management, but the InventoryDAO filtering logic was disabled with comments stating "Status filter removed - column doesn't exist". This feature will restore and complete the status filtering functionality to enable proper soft delete operations where items are marked as "Inactive" instead of being physically deleted from the database.

## Glossary

- **Inventory System**: The software module responsible for managing restaurant ingredient inventory in the PizzaConnect application
- **Soft Delete**: A data management pattern where records are marked as Inactive rather than physically removed from the database
- **Status Column**: A database field in the Inventory table storing the current state (Active or Inactive)
- **InventoryDAO**: Data Access Object class (dao.InventoryDAO) that handles all database operations for inventory items
- **InventoryServlet**: Controller servlet (controller.InventoryServlet) mapped to /manageinventory that handles HTTP requests
- **Status Filter**: A dropdown UI control with options: "All Status", "Active Only", "Inactive Only"
- **Toggle Action**: The servlet action (action=toggle) that switches an item's status between Active and Inactive
- **URLUtils**: Utility class (utils.URLUtils) that handles URL parameter construction and preservation

## Requirements

### Requirement 1: Status-Based Filtering

**User Story:** As a restaurant manager, I want to filter inventory items by their status (Active, Inactive, or All), so that I can view only the items relevant to my current task.

#### Acceptance Criteria

1. WHEN the manager selects "Active Only" from the status filter dropdown, THE Inventory System SHALL display only inventory items with Status = 'Active'
2. WHEN the manager selects "Inactive Only" from the status filter dropdown, THE Inventory System SHALL display only inventory items with Status = 'Inactive'
3. WHEN the manager selects "All Status" from the status filter dropdown, THE Inventory System SHALL display all inventory items regardless of their status
4. WHEN the manager applies a status filter, THE Inventory System SHALL preserve the filter selection across pagination navigation
5. WHEN the manager applies a status filter, THE Inventory System SHALL update the total item count to reflect only filtered items

### Requirement 2: Soft Delete Operation

**User Story:** As a restaurant manager, I want to deactivate inventory items instead of deleting them permanently, so that I can preserve historical data and reactivate items if needed.

#### Acceptance Criteria

1. WHEN the manager clicks the "Deactivate" button on an Active item, THE Inventory System SHALL change the item's Status to 'Inactive'
2. WHEN the manager clicks the "Activate" button on an Inactive item, THE Inventory System SHALL change the item's Status to 'Active'
3. WHEN the status is changed, THE Inventory System SHALL update the LastUpdated timestamp to the current date and time
4. WHEN the status change is successful, THE Inventory System SHALL display a success message showing the item name and new status
5. WHEN the status change fails, THE Inventory System SHALL display an error message and maintain the original status

### Requirement 3: Status Display and Visual Feedback

**User Story:** As a restaurant manager, I want to clearly see the status of each inventory item, so that I can quickly identify which items are active or inactive.

#### Acceptance Criteria

1. WHEN viewing the inventory list, THE Inventory System SHALL display a status badge for each item
2. WHEN an item has Status = 'Active', THE Inventory System SHALL display a green badge labeled "Active"
3. WHEN an item has Status = 'Inactive', THE Inventory System SHALL display a gray badge labeled "Inactive"
4. WHEN an item is Active, THE Inventory System SHALL show a red "Deactivate" button
5. WHEN an item is Inactive, THE Inventory System SHALL show a green "Activate" button

### Requirement 4: Confirmation Dialog for Status Changes

**User Story:** As a restaurant manager, I want to confirm before changing an item's status, so that I can prevent accidental status changes.

#### Acceptance Criteria

1. WHEN the manager clicks "Deactivate" on an Active item, THE Inventory System SHALL display a confirmation dialog asking "Are you sure you want to deactivate this item?"
2. WHEN the manager clicks "Activate" on an Inactive item, THE Inventory System SHALL display a confirmation dialog asking "Are you sure you want to activate this item?"
3. WHEN the manager confirms the action, THE Inventory System SHALL proceed with the status change
4. WHEN the manager cancels the action, THE Inventory System SHALL maintain the current status without changes
5. IF the manager cancels, THEN THE Inventory System SHALL not reload the page or lose the current view state

### Requirement 5: Status Filter Persistence

**User Story:** As a restaurant manager, I want my status filter selection to persist when I edit items or change pages, so that I don't lose my working context.

#### Acceptance Criteria

1. WHEN the manager applies a status filter and then edits an item, THE Inventory System SHALL preserve the status filter value
2. WHEN the manager saves an edited item, THE Inventory System SHALL return to the inventory list with the same status filter applied
3. WHEN the manager toggles an item's status, THE Inventory System SHALL maintain the current status filter selection
4. WHEN the manager navigates between pages, THE Inventory System SHALL preserve the status filter in the URL parameters
5. WHEN the manager changes the page size, THE Inventory System SHALL maintain the current status filter selection

### Requirement 6: Database Query Restoration

**User Story:** As a system administrator, I want the disabled status filtering in InventoryDAO to be restored, so that the status filter feature works correctly.

#### Acceptance Criteria

1. WHEN statusFilter parameter equals "active", THE InventoryDAO SHALL add "AND Status = 'Active'" to the SQL WHERE clause
2. WHEN statusFilter parameter equals "inactive", THE InventoryDAO SHALL add "AND Status = 'Inactive'" to the SQL WHERE clause
3. WHEN statusFilter parameter equals "all" or is null, THE InventoryDAO SHALL not add any status condition to the query
4. WHEN counting total items in getTotalInventoryCount(searchName, statusFilter), THE InventoryDAO SHALL apply the status filter condition
5. WHEN retrieving paginated items in getInventoriesByPage(page, pageSize, searchName, statusFilter), THE InventoryDAO SHALL include Status column in SELECT and apply status filter

### Requirement 7: New Item Default Status

**User Story:** As a restaurant manager, I want newly created inventory items to be Active by default, so that they are immediately available for use.

#### Acceptance Criteria

1. WHEN the manager creates a new inventory item, THE Inventory System SHALL set the Status to 'Active'
2. WHEN inserting a new item, THE Inventory System SHALL set the LastUpdated timestamp to the current date and time
3. WHEN the new item is saved successfully, THE Inventory System SHALL display it in the Active items list
4. WHEN viewing the newly created item, THE Inventory System SHALL show the Status as 'Active' with a green badge
5. WHEN the insert operation completes, THE Inventory System SHALL display a success message confirming the item was added

### Requirement 8: Status Column Verification

**User Story:** As a database administrator, I want to verify the Status column exists with proper configuration, so that the soft delete feature works reliably.

#### Acceptance Criteria

1. THE Inventory System SHALL use the existing add_status_column_to_inventory.sql script to add the Status column if it does not exist
2. THE Status column SHALL have data type NVARCHAR(20) NOT NULL with default value 'Active'
3. WHEN the SQL script runs, THE Inventory System SHALL check if the Status column exists before attempting to add it
4. WHEN the Status column is added, THE Inventory System SHALL update all existing records to Status = 'Active'
5. THE InventoryDAO methods SHALL consistently include the Status column in SELECT statements where item details are retrieved
