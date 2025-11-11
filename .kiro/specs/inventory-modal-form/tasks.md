# Implementation Plan

- [x] 1. Add Bootstrap modal HTML structure to ManageInventory.jsp

  - Add modal container div with id="inventoryModal" before closing body tag
  - Include modal-dialog, modal-content, modal-header, modal-body, modal-footer structure
  - Add form with id="inventoryForm" inside modal-body with POST method to manageinventory
  - Add hidden fields for id, returnSearchName, returnStatusFilter, returnPage
  - Add input fields for itemName, quantity, unit with proper labels and validation attributes
  - Add error message div with id="modalErrorMessage" for displaying validation errors
  - Add Cancel and Save buttons in modal-footer
  - _Requirements: 1.1, 1.2, 2.1, 2.2, 2.3, 5.1, 5.2, 5.3, 5.4, 5.5_

- [x] 2. Add JavaScript functions for modal operations

  - [x] 2.1 Create openAddModal() function

    - Reset form fields to empty values
    - Clear inventoryId hidden field
    - Hide error message div
    - Set modal title to "Add New Inventory"
    - Show modal using Bootstrap modal API
    - Focus on itemName field after modal opens
    - _Requirements: 1.1, 1.3, 1.5_

  - [x] 2.2 Create openEditModal(id, itemName, quantity, unit) function

    - Populate form fields with passed parameters
    - Set inventoryId hidden field with id value
    - Hide error message div
    - Set modal title to "Edit Inventory Item"
    - Show modal using Bootstrap modal API
    - Focus on itemName field after modal opens
    - _Requirements: 2.1, 2.2, 2.3, 2.5_

  - [x] 2.3 Add client-side form validation

    - Add submit event listener to inventoryForm
    - Validate itemName is not empty
    - Validate unit is not empty
    - Validate quantity is non-negative number
    - Display validation errors in modalErrorMessage div
    - Prevent form submission if validation fails
    - _Requirements: 3.1, 3.2, 3.3, 3.5_

- [ ] 3. Modify Add New Inventory button

  - Change from anchor tag to button element
  - Remove href attribute
  - Add onclick="openAddModal()" event handler
  - Keep existing btn btn-success classes
  - _Requirements: 1.1_

- [ ] 4. Modify Edit buttons in inventory table

  - Change Edit button from anchor tag to button element
  - Remove href attribute with editUrl
  - Add onclick event handler calling openEditModal with item data
  - Pass inventoryID, itemName, quantity, unit as parameters
  - Use JSTL c:out to escape special characters in JavaScript strings
  - Keep existing btn btn-sm btn-warning classes
  - _Requirements: 2.1, 2.2_

- [ ] 5. Add custom CSS styling for modal

  - Add styles for modal-content border-radius and box-shadow
  - Style modal-header with background color and border
  - Style modal-title with color and font-weight
  - Style modal-footer border
  - Add responsive styles for different screen sizes
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 6.1, 6.2, 6.3, 6.4, 6.5_

- [ ] 6. Add keyboard accessibility features

  - Add tabindex attributes to ensure proper tab order
  - Add aria-label attributes for screen readers
  - Ensure ESC key closes modal (Bootstrap default behavior)
  - Ensure focus trap within modal when open
  - Test keyboard navigation through all form fields
  - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_

- [ ]\* 7. Test modal functionality

  - [ ]\* 7.1 Test Add functionality

    - Test opening modal with Add button
    - Test form validation with empty fields
    - Test form validation with invalid quantity
    - Test successful item creation
    - Verify filters and pagination preserved after add
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 3.1, 3.2, 3.3, 4.1, 4.2, 4.3, 7.1, 7.2, 7.3, 7.4, 7.5_

  - [ ]\* 7.2 Test Edit functionality

    - Test opening modal with Edit button
    - Verify form pre-populated with correct data
    - Test modifying fields and saving
    - Test validation errors in edit mode
    - Verify filters and pagination preserved after edit
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 4.1, 4.2, 4.3, 4.4, 4.5, 7.1, 7.2, 7.3, 7.4, 7.5_

  - [ ]\* 7.3 Test modal behavior

    - Test closing modal with X button
    - Test closing modal by clicking backdrop
    - Test closing modal with ESC key
    - Test Cancel button closes modal
    - Verify form resets after closing
    - _Requirements: 1.4, 1.5, 2.4, 2.5, 8.1_

  - [ ]\* 7.4 Test responsive design
    - Test modal on desktop screen (>768px)
    - Test modal on tablet screen (768px)
    - Test modal on mobile screen (<576px)
    - Verify modal is usable on all screen sizes
    - Test scrolling when modal content is long
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_
