# Requirements Document

## Introduction

This feature enhances the Inventory Management UI by replacing the separate add/edit form page with a modal dialog that appears directly on the ManageInventory page. This provides a better user experience by keeping users on the same page, maintaining their context (filters, pagination), and reducing page navigation.

## Glossary

- **Modal Dialog**: A popup window that appears on top of the current page with a semi-transparent backdrop
- **Bootstrap Modal**: A Bootstrap 5 component for creating modal dialogs
- **ManageInventory Page**: The main inventory list page at /manageinventory
- **Form Validation**: Client-side and server-side checks to ensure data integrity
- **AJAX**: Asynchronous JavaScript technique for submitting forms without page reload
- **Backdrop**: The semi-transparent overlay behind the modal that blocks interaction with the page

## Requirements

### Requirement 1: Add Inventory Modal

**User Story:** As a restaurant manager, I want to add new inventory items using a modal dialog, so that I can stay on the inventory list page without losing my current view.

#### Acceptance Criteria

1. WHEN the manager clicks the "Add New Inventory" button, THE Inventory System SHALL display a modal dialog with an empty form
2. WHEN the modal opens, THE Inventory System SHALL display a backdrop that prevents interaction with the page behind
3. WHEN the modal opens, THE Inventory System SHALL focus on the first input field (Item Name)
4. WHEN the manager clicks the X button or clicks outside the modal, THE Inventory System SHALL close the modal without saving
5. WHEN the modal closes, THE Inventory System SHALL clear all form fields for the next use

### Requirement 2: Edit Inventory Modal

**User Story:** As a restaurant manager, I want to edit inventory items using a modal dialog, so that I can quickly update item details without navigating away from the list.

#### Acceptance Criteria

1. WHEN the manager clicks the "Edit" button on an item, THE Inventory System SHALL display a modal dialog with the form pre-filled with the item's current data
2. WHEN the edit modal opens, THE Inventory System SHALL populate Item Name, Quantity, and Unit fields with existing values
3. WHEN the edit modal opens, THE Inventory System SHALL display "Edit Inventory Item" as the modal title
4. WHEN the manager clicks Cancel, THE Inventory System SHALL close the modal without saving changes
5. WHEN the modal closes after editing, THE Inventory System SHALL reset the form to add mode

### Requirement 3: Modal Form Validation

**User Story:** As a restaurant manager, I want the modal form to validate my input, so that I can correct errors before submitting.

#### Acceptance Criteria

1. WHEN the manager submits the form with an empty Item Name, THE Inventory System SHALL display an error message "Item name cannot be empty"
2. WHEN the manager submits the form with an empty Unit, THE Inventory System SHALL display an error message "Unit cannot be empty"
3. WHEN the manager enters a negative or non-numeric Quantity, THE Inventory System SHALL display an error message "Quantity must be a non-negative number"
4. WHEN the manager enters a duplicate Item Name, THE Inventory System SHALL display an error message "Item name already exists"
5. WHEN validation fails, THE Inventory System SHALL keep the modal open and highlight the invalid field

### Requirement 4: Modal Form Submission

**User Story:** As a restaurant manager, I want the modal form to submit without reloading the page, so that I can maintain my current filters and pagination.

#### Acceptance Criteria

1. WHEN the manager submits a valid add form, THE Inventory System SHALL save the new item to the database
2. WHEN the save is successful, THE Inventory System SHALL close the modal and refresh the inventory list
3. WHEN the save is successful, THE Inventory System SHALL display a success message with the item name
4. WHEN the save fails, THE Inventory System SHALL keep the modal open and display an error message
5. WHEN the list refreshes, THE Inventory System SHALL maintain the current page, search filter, and status filter

### Requirement 5: Modal UI Design

**User Story:** As a restaurant manager, I want the modal to have a clean and professional design, so that it's easy to use and matches the application style.

#### Acceptance Criteria

1. THE Inventory System SHALL use Bootstrap 5 modal component for consistent styling
2. THE modal SHALL have a white background with rounded corners and shadow
3. THE modal SHALL display a header with title and close (X) button
4. THE modal SHALL display form fields with proper labels and spacing
5. THE modal SHALL display action buttons (Save/Cancel) at the bottom with appropriate colors

### Requirement 6: Modal Responsiveness

**User Story:** As a restaurant manager, I want the modal to work well on different screen sizes, so that I can manage inventory from any device.

#### Acceptance Criteria

1. WHEN viewed on desktop, THE modal SHALL be centered and have a fixed width (500-600px)
2. WHEN viewed on tablet, THE modal SHALL adjust width to fit the screen with margins
3. WHEN viewed on mobile, THE modal SHALL take up most of the screen width
4. WHEN the modal content is long, THE modal body SHALL be scrollable
5. THE modal SHALL remain usable and readable on all screen sizes

### Requirement 7: Context Preservation

**User Story:** As a restaurant manager, I want my search filters and pagination to remain unchanged after adding or editing items, so that I don't lose my place in the list.

#### Acceptance Criteria

1. WHEN the manager adds an item while on page 2, THE Inventory System SHALL keep the user on page 2 after save
2. WHEN the manager has a search filter applied, THE Inventory System SHALL maintain the search filter after save
3. WHEN the manager has a status filter applied, THE Inventory System SHALL maintain the status filter after save
4. WHEN the manager has a specific page size selected, THE Inventory System SHALL maintain the page size after save
5. WHEN the list refreshes, THE Inventory System SHALL update the item count and pagination if needed

### Requirement 8: Keyboard Accessibility

**User Story:** As a restaurant manager, I want to use keyboard shortcuts in the modal, so that I can work more efficiently.

#### Acceptance Criteria

1. WHEN the modal is open and the manager presses ESC key, THE Inventory System SHALL close the modal without saving
2. WHEN the manager presses TAB key, THE Inventory System SHALL move focus between form fields in logical order
3. WHEN the manager presses ENTER in a text field, THE Inventory System SHALL move to the next field (not submit)
4. WHEN the manager presses ENTER on the Save button, THE Inventory System SHALL submit the form
5. WHEN the modal opens, THE Inventory System SHALL trap focus within the modal (prevent tabbing to background)
