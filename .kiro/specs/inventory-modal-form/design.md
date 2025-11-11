# Design Document

## Overview

This design converts the existing separate inventory-form.jsp page into a Bootstrap modal dialog embedded within ManageInventory.jsp. The modal will handle both Add and Edit operations, maintaining all existing validation and business logic while improving the user experience by eliminating page navigation.

## Architecture

### Current Architecture (Before)

```
[ManageInventory.jsp]
    ↓ Click "Add" or "Edit"
[Navigate to inventory-form.jsp]
    ↓ Submit form
[POST to InventoryServlet]
    ↓ Redirect
[Back to ManageInventory.jsp]
```

### New Architecture (After)

```
[ManageInventory.jsp with embedded modal]
    ↓ Click "Add" or "Edit"
[Show modal dialog on same page]
    ↓ Submit form
[POST to InventoryServlet]
    ↓ Redirect back
[ManageInventory.jsp refreshes with preserved context]
```

## Components and Interfaces

### 1. Modal HTML Structure

The modal will be added to ManageInventory.jsp using Bootstrap 5 modal component:

```html
<!-- Add/Edit Inventory Modal -->
<div
  class="modal fade"
  id="inventoryModal"
  tabindex="-1"
  aria-labelledby="inventoryModalLabel"
  aria-hidden="true"
>
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="inventoryModalLabel">Add New Inventory</h5>
        <button
          type="button"
          class="btn-close"
          data-bs-dismiss="modal"
          aria-label="Close"
        ></button>
      </div>
      <form id="inventoryForm" method="POST" action="manageinventory">
        <div class="modal-body">
          <input type="hidden" id="inventoryId" name="id" value="" />
          <input type="hidden" name="returnSearchName" value="${searchName}" />
          <input
            type="hidden"
            name="returnStatusFilter"
            value="${statusFilter}"
          />
          <input type="hidden" name="returnPage" value="${currentPage}" />

          <!-- Error message display -->
          <div id="modalErrorMessage" class="alert alert-danger d-none"></div>

          <!-- Item Name -->
          <div class="mb-3">
            <label for="itemName" class="form-label"
              >Item Name <span class="text-danger">*</span></label
            >
            <input
              type="text"
              class="form-control"
              id="itemName"
              name="itemName"
              required
            />
          </div>

          <!-- Quantity -->
          <div class="mb-3">
            <label for="quantity" class="form-label"
              >Quantity <span class="text-danger">*</span></label
            >
            <input
              type="number"
              step="0.01"
              class="form-control"
              id="quantity"
              name="quantity"
              required
              min="0"
            />
          </div>

          <!-- Unit -->
          <div class="mb-3">
            <label for="unit" class="form-label"
              >Unit <span class="text-danger">*</span></label
            >
            <input
              type="text"
              class="form-control"
              id="unit"
              name="unit"
              required
              placeholder="e.g., kg, liters, pieces"
            />
          </div>
        </div>
        <div class="modal-footer">
          <button
            type="button"
            class="btn btn-secondary"
            data-bs-dismiss="modal"
          >
            Cancel
          </button>
          <button type="submit" class="btn btn-success">Save Inventory</button>
        </div>
      </form>
    </div>
  </div>
</div>
```

### 2. JavaScript Functions

#### Open Modal for Add

```javascript
function openAddModal() {
  // Reset form
  document.getElementById("inventoryForm").reset();
  document.getElementById("inventoryId").value = "";
  document.getElementById("modalErrorMessage").classList.add("d-none");

  // Set title
  document.getElementById("inventoryModalLabel").textContent =
    "Add New Inventory";

  // Show modal
  const modal = new bootstrap.Modal(document.getElementById("inventoryModal"));
  modal.show();

  // Focus first field
  setTimeout(() => {
    document.getElementById("itemName").focus();
  }, 500);
}
```

#### Open Modal for Edit

```javascript
function openEditModal(id, itemName, quantity, unit) {
  // Populate form
  document.getElementById("inventoryId").value = id;
  document.getElementById("itemName").value = itemName;
  document.getElementById("quantity").value = quantity;
  document.getElementById("unit").value = unit;
  document.getElementById("modalErrorMessage").classList.add("d-none");

  // Set title
  document.getElementById("inventoryModalLabel").textContent =
    "Edit Inventory Item";

  // Show modal
  const modal = new bootstrap.Modal(document.getElementById("inventoryModal"));
  modal.show();

  // Focus first field
  setTimeout(() => {
    document.getElementById("itemName").focus();
  }, 500);
}
```

#### Form Validation

```javascript
document
  .getElementById("inventoryForm")
  .addEventListener("submit", function (e) {
    const itemName = document.getElementById("itemName").value.trim();
    const quantity = document.getElementById("quantity").value;
    const unit = document.getElementById("unit").value.trim();

    let errors = [];

    if (!itemName) {
      errors.push("Item name cannot be empty");
    }

    if (!unit) {
      errors.push("Unit cannot be empty");
    }

    if (!quantity || parseFloat(quantity) < 0) {
      errors.push("Quantity must be a non-negative number");
    }

    if (errors.length > 0) {
      e.preventDefault();
      const errorDiv = document.getElementById("modalErrorMessage");
      errorDiv.textContent = errors.join(". ");
      errorDiv.classList.remove("d-none");
      return false;
    }
  });
```

### 3. Button Modifications

#### Add Button

Change from:

```html
<a href="manageinventory?action=add" class="btn btn-success"
  >+ Add New Inventory</a
>
```

To:

```html
<button type="button" class="btn btn-success" onclick="openAddModal()">
  + Add New Inventory
</button>
```

#### Edit Button

Change from:

```html
<a class="btn btn-sm btn-warning" href="${editUrl}">Edit</a>
```

To:

```html
<button
  type="button"
  class="btn btn-sm btn-warning"
  onclick="openEditModal(${inv.inventoryID}, '${inv.itemName}', ${inv.quantity}, '${inv.unit}')"
>
  Edit
</button>
```

### 4. Servlet Modifications

**InventoryServlet.java** - No major changes needed, but we'll remove the "add" and "edit" GET actions since they won't be used anymore:

- Keep the doPost() method as-is (handles form submission)
- Keep the "list" action in doGet() (default view)
- Keep the "toggle" action in doGet() (status changes)
- Remove or deprecate the "add" and "edit" GET actions

The servlet already redirects back to manageinventory with preserved parameters, so it will work seamlessly with the modal approach.

### 5. Error Handling in Modal

When server-side validation fails, we have two options:

**Option A: Show errors in modal (Recommended)**

- After POST, if there are errors, redirect back with error parameter
- Use JavaScript to detect error parameter and re-open modal with error message
- Requires URL parameter parsing in JavaScript

**Option B: Show errors on page**

- Keep existing error handling (show alert on page)
- Modal closes, error appears above the table
- Simpler implementation, less JavaScript

We'll use **Option B** for simplicity and consistency with existing error handling.

## Data Models

No changes to existing data models. The Inventory model remains the same:

```java
public class Inventory {
    private int inventoryID;
    private String itemName;
    private double quantity;
    private String unit;
    private Timestamp lastUpdated;
    private String status;
    // getters and setters
}
```

## UI/UX Flow

### Add Flow

1. User clicks "+ Add New Inventory" button
2. Modal opens with empty form
3. User fills in Item Name, Quantity, Unit
4. User clicks "Save Inventory"
5. Form submits via POST to servlet
6. Servlet validates and saves
7. Servlet redirects back to manageinventory with success message
8. Page reloads with success alert and updated list
9. User sees new item in the list (if it matches current filters)

### Edit Flow

1. User clicks "Edit" button on an item
2. Modal opens with form pre-filled with item data
3. User modifies fields
4. User clicks "Save Inventory"
5. Form submits via POST to servlet with item ID
6. Servlet validates and updates
7. Servlet redirects back to manageinventory with success message
8. Page reloads with success alert and updated list
9. User sees updated item in the list

### Cancel Flow

1. User opens modal (Add or Edit)
2. User clicks "Cancel" button or X or clicks backdrop
3. Modal closes without submitting
4. Form is reset for next use
5. Page remains unchanged

## Error Handling

### Client-Side Validation Errors

- Display in red alert div inside modal
- Keep modal open
- Highlight invalid field
- Prevent form submission

### Server-Side Validation Errors

- Servlet redirects back with error message in session
- Page reloads and shows error alert above table
- Modal is closed
- User can click Add/Edit again to retry

### Duplicate Name Error

- Handled by servlet (existing logic)
- Error message shown on page after reload
- User can click Edit again to modify the name

## Styling

### Modal Styling

```css
.modal-content {
  border-radius: 8px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.modal-header {
  background-color: #f8f9fa;
  border-bottom: 1px solid #dee2e6;
}

.modal-title {
  color: #0d6efd;
  font-weight: 600;
}

.modal-footer {
  border-top: 1px solid #dee2e6;
}

#modalErrorMessage {
  margin-bottom: 1rem;
}
```

### Responsive Design

- Desktop (>768px): Modal width 500px, centered
- Tablet (768px): Modal width 90%, centered
- Mobile (<576px): Modal width 95%, full height if needed

Bootstrap 5 modal handles this automatically with `modal-dialog-centered` class.

## Testing Strategy

### Manual Testing Checklist

1. **Add Functionality**

   - Click Add button → modal opens
   - Submit empty form → validation errors show
   - Submit valid form → item added, success message shows
   - Verify filters/pagination preserved after add

2. **Edit Functionality**

   - Click Edit button → modal opens with data
   - Modify fields → submit → item updated
   - Verify filters/pagination preserved after edit

3. **Modal Behavior**

   - Click X button → modal closes
   - Click backdrop → modal closes
   - Press ESC key → modal closes
   - Tab through fields → focus order correct

4. **Error Handling**

   - Submit duplicate name → error shows
   - Submit negative quantity → error shows
   - Submit empty required field → error shows

5. **Responsive Design**
   - Test on desktop → modal centered, proper width
   - Test on tablet → modal responsive
   - Test on mobile → modal usable

## Implementation Notes

### Files to Modify

1. **ManageInventory.jsp**

   - Add modal HTML structure
   - Add JavaScript functions
   - Modify Add button to call openAddModal()
   - Modify Edit buttons to call openEditModal()
   - Add custom CSS for modal styling

2. **InventoryServlet.java** (Optional)
   - Remove or comment out "add" and "edit" GET actions
   - Keep all POST logic unchanged
   - Keep "toggle" action unchanged

### Files to Keep

- **inventory-form.jsp**: Can be kept for backward compatibility or removed
- **InventoryDAO.java**: No changes needed
- **Inventory.java**: No changes needed
- **URLUtils.java**: No changes needed

### Backward Compatibility

If we keep inventory-form.jsp, direct URL access will still work:

- `/manageinventory?action=add` → still shows form page
- `/manageinventory?action=edit&id=1` → still shows form page

But UI buttons will use modal instead.

## Security Considerations

### XSS Prevention

When passing data to JavaScript functions, escape special characters:

```jsp
<button onclick="openEditModal(${inv.inventoryID},
    '<c:out value="${inv.itemName}"/>',
    ${inv.quantity},
    '<c:out value="${inv.unit}"/>')">
```

Use JSTL `<c:out>` to escape HTML/JavaScript special characters.

### CSRF Protection

- Form submission uses POST method
- Existing servlet validation applies
- Session-based authentication remains unchanged

## Performance Considerations

- Modal HTML is loaded once with page (minimal overhead)
- No additional HTTP requests for opening modal
- Form submission still requires page reload (existing behavior)
- Could be enhanced with AJAX in future for no-reload experience

## Future Enhancements

1. **AJAX Form Submission**: Submit form without page reload
2. **Real-time Validation**: Check duplicate names while typing
3. **Auto-save Draft**: Save form data to localStorage
4. **Bulk Add**: Add multiple items at once
5. **Import CSV**: Upload CSV file to add multiple items
