# Design Document

## Overview

Màn hình hiển thị inventory mới sẽ được thiết kế để thay thế giao diện Bootstrap hiện tại bằng một giao diện hiện đại sử dụng Tailwind CSS, tương tự như màn hình ManageProduct.jsp. Thiết kế này sẽ tận dụng cấu trúc backend hiện có (InventoryServlet, InventoryDAO, Inventory model) nhưng nâng cấp hoàn toàn giao diện người dùng để đảm bảo tính nhất quán và trải nghiệm người dùng tốt hơn.

## Architecture

### Frontend Architecture

- **UI Framework**: Tailwind CSS cho styling hiện đại và responsive
- **Icons**: Lucide icons để đảm bảo tính nhất quán với ManageProduct
- **Layout**: Sidebar navigation + main content area
- **JavaScript**: Vanilla JavaScript cho tương tác client-side

### Backend Architecture (Existing)

- **Servlet**: InventoryServlet xử lý HTTP requests
- **DAO Layer**: InventoryDAO cho database operations
- **Model**: Inventory model cho data representation
- **Database**: SQL Server với bảng Inventory

### Integration Points

- Tận dụng endpoint `/manageinventory` hiện có
- Sử dụng pagination logic hiện có (page, pageSize)
- Kết nối với session management và role-based access control

## Components and Interfaces

### 1. Main Layout Components

#### Sidebar Navigation

```html
<div class="w-20 bg-gray-800 flex flex-col items-center py-6 justify-between">
  <!-- Logo và navigation icons -->
  <!-- Highlight inventory page với bg-orange-500 -->
</div>
```

**Features:**

- Consistent với ManageProduct sidebar
- Orange highlight cho inventory page
- Responsive navigation icons
- User profile và logout buttons

#### Header Section

```html
<div class="bg-white border-b px-6 py-4 flex justify-between items-center">
  <div>
    <h1 class="text-2xl font-bold text-gray-800">Manage Inventory</h1>
    <p class="text-sm text-gray-500">
      PizzaConnect Restaurant Management System
    </p>
  </div>
  <div class="text-gray-600">Welcome, <strong>Admin Name</strong></div>
</div>
```

### 2. Search and Filter Components

#### Search Bar

```html
<input
  type="text"
  name="searchName"
  placeholder="Search by item name..."
  class="px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-400"
/>
```

#### Status Filter Dropdown

```html
<select
  name="statusFilter"
  class="px-3 py-2 border border-gray-300 rounded-lg bg-white"
>
  <option value="all">All Status</option>
  <option value="active">Active</option>
  <option value="inactive">Inactive</option>
</select>
```

#### Action Buttons

```html
<div class="flex gap-2">
  <a
    href="manageinventory?action=add"
    class="bg-green-500 hover:bg-green-600 text-white px-4 py-2 rounded-lg"
  >
    Add New Inventory
  </a>
  <button
    type="submit"
    class="bg-blue-500 hover:bg-blue-600 text-white px-4 py-2 rounded-lg"
  >
    <i data-lucide="search" class="w-4 h-4"></i> Filter
  </button>
</div>
```

### 3. Data Display Components

#### Inventory Table

```html
<table class="min-w-full border-t">
  <thead class="bg-gray-100">
    <tr>
      <th class="px-4 py-2 text-left">ID</th>
      <th class="px-4 py-2 text-left">Item Name</th>
      <th class="px-4 py-2 text-left">Quantity</th>
      <th class="px-4 py-2 text-left">Unit</th>
      <th class="px-4 py-2 text-left">Last Updated</th>
      <th class="px-4 py-2 text-left">Status</th>
      <th class="px-4 py-2 text-left">Actions</th>
    </tr>
  </thead>
  <tbody class="divide-y">
    <!-- Dynamic rows -->
  </tbody>
</table>
```

#### Status Badges

```html
<!-- Active Status -->
<span
  class="px-3 py-1 text-white rounded-full text-xs font-semibold bg-green-500"
>
  Active
</span>

<!-- Inactive Status -->
<span
  class="px-3 py-1 text-white rounded-full text-xs font-semibold bg-red-500"
>
  Inactive
</span>
```

#### Action Buttons

```html
<div class="flex flex-wrap gap-2">
  <a
    href="manageinventory?action=edit&id=${inv.inventoryID}"
    class="bg-sky-500 hover:bg-sky-600 text-white px-3 py-1 rounded text-xs"
  >
    Edit
  </a>
  <a
    href="manageinventory?action=toggle&id=${inv.inventoryID}"
    onclick="return confirm('Are you sure?');"
    class="bg-yellow-500 hover:bg-yellow-600 text-white px-3 py-1 rounded text-xs"
  >
    ${inv.status == 'Active' ? 'Deactivate' : 'Activate'}
  </a>
</div>
```

### 4. Pagination Component

```html
<div class="flex justify-center items-center mt-6 space-x-2">
  <!-- Previous Button -->
  <c:if test="${currentPage > 1}">
    <c:url var="prevUrl" value="/manageinventory">
      <c:param name="page" value="${currentPage - 1}" />
      <c:param name="searchName" value="${searchName}" />
      <c:param name="statusFilter" value="${statusFilter}" />
    </c:url>
    <a href="${prevUrl}" class="px-3 py-1 bg-gray-200 hover:bg-gray-300 rounded"
      >Previous</a
    >
  </c:if>

  <!-- Page Numbers -->
  <c:forEach var="i" begin="1" end="${totalPages}">
    <c:url var="pageUrl" value="/manageinventory">
      <c:param name="page" value="${i}" />
      <c:param name="searchName" value="${searchName}" />
      <c:param name="statusFilter" value="${statusFilter}" />
    </c:url>
    <a
      href="${pageUrl}"
      class="px-3 py-1 rounded ${i == currentPage ? 'bg-orange-500 text-white' : 'bg-gray-200 hover:bg-gray-300'}"
    >
      ${i}
    </a>
  </c:forEach>

  <!-- Next Button -->
  <c:if test="${currentPage < totalPages}">
    <c:url var="nextUrl" value="/manageinventory">
      <c:param name="page" value="${currentPage + 1}" />
      <c:param name="searchName" value="${searchName}" />
      <c:param name="statusFilter" value="${statusFilter}" />
    </c:url>
    <a href="${nextUrl}" class="px-3 py-1 bg-gray-200 hover:bg-gray-300 rounded"
      >Next</a
    >
  </c:if>
</div>
```

## Data Models

### Inventory Model (Existing)

```java
public class Inventory {
    private int inventoryID;
    private String itemName;
    private double quantity;
    private String unit;
    private Timestamp lastUpdated;
    private String status; // "Active" or "Inactive"

    // Getters and setters
}
```

### Request/Response Data Flow

#### GET Request Parameters

- `page`: Current page number (default: 1)
- `searchName`: Search term for item name filtering
- `statusFilter`: Status filter ("all", "active", "inactive")
- `action`: Action type ("list", "add", "edit", "toggle")
- `id`: Inventory ID for edit/toggle actions

#### Response Attributes

- `inventoryList`: List<Inventory> - Paginated inventory items
- `currentPage`: Integer - Current page number
- `totalPages`: Integer - Total number of pages
- `searchName`: String - Current search term
- `statusFilter`: String - Current status filter

## Error Handling

### Client-Side Validation

- Form validation for required fields
- Number validation for quantity inputs
- Confirmation dialogs for destructive actions

### Server-Side Error Handling

- Invalid parameter handling (non-numeric page, id)
- Database connection error handling
- Session validation and role checking
- Graceful fallback to default values

### User Feedback

- Success messages after successful operations
- Error messages for failed operations
- Loading states during async operations
- Confirmation dialogs for status changes

## Testing Strategy

### Frontend Testing

- Cross-browser compatibility testing
- Responsive design testing on different screen sizes
- JavaScript functionality testing
- Accessibility testing (keyboard navigation, screen readers)

### Integration Testing

- End-to-end user workflows
- Search and filter functionality
- Pagination with preserved parameters
- CRUD operations through the UI

### Performance Testing

- Page load time optimization
- Large dataset handling
- Memory usage monitoring
- Database query performance

## Implementation Considerations

### Backend Enhancements Required

#### Enhanced InventoryServlet

- Add search functionality by item name
- Add status filtering capability
- Improve pagination with search/filter parameter preservation
- Add proper error handling and user feedback

#### Enhanced InventoryDAO

- Add search methods with LIKE queries
- Add status filtering methods
- Optimize pagination queries
- Add proper exception handling

### Frontend Implementation

#### CSS Framework Integration

- Include Tailwind CSS CDN
- Implement responsive grid system
- Use consistent color scheme with ManageProduct

#### JavaScript Enhancements

- Lucide icons initialization
- Form validation
- Confirmation dialogs
- Search form handling

#### JSP Template Structure

- Consistent header and navigation
- Reusable components
- Proper JSTL usage for dynamic content
- Error message display system

### Security Considerations

- Role-based access control (Admin only)
- CSRF protection for form submissions
- Input sanitization and validation
- SQL injection prevention

### Performance Optimizations

- Efficient pagination queries
- Minimal JavaScript footprint
- Optimized CSS delivery
- Database connection pooling
