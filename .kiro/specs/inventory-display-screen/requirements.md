# Requirements Document

## Introduction

Tính năng màn hình hiển thị inventory được thiết kế để cung cấp giao diện quản lý kho hàng hiện đại và thân thiện với người dùng, tương tự như màn hình manage products hiện có. Màn hình này sẽ cho phép quản trị viên xem, tìm kiếm, lọc và quản lý thông tin inventory một cách hiệu quả với giao diện responsive và trực quan.

## Glossary

- **Inventory_Display_System**: Hệ thống hiển thị và quản lý thông tin kho hàng
- **Admin_User**: Người dùng có quyền quản trị (role = 1) có thể truy cập màn hình inventory
- **Inventory_Item**: Một mục trong kho hàng bao gồm thông tin như ID, tên, số lượng, đơn vị, trạng thái
- **Search_Filter**: Bộ lọc tìm kiếm cho phép lọc inventory theo tên và trạng thái
- **Status_Badge**: Nhãn hiển thị trạng thái của inventory item (Active/Inactive)
- **Pagination_System**: Hệ thống phân trang để hiển thị danh sách inventory theo từng trang

## Requirements

### Requirement 1

**User Story:** As an admin user, I want to view a modern inventory display screen similar to the manage products interface, so that I can efficiently manage inventory items with a consistent user experience.

#### Acceptance Criteria

1. WHEN an Admin_User accesses the inventory display screen, THE Inventory_Display_System SHALL render a modern interface using Tailwind CSS styling consistent with the manage products screen
2. THE Inventory_Display_System SHALL display a sidebar navigation with the current inventory page highlighted in orange
3. THE Inventory_Display_System SHALL show a header with "Manage Inventory" title and welcome message displaying the current user's name
4. THE Inventory_Display_System SHALL present inventory data in a clean table format with columns for ID, Item Name, Quantity, Unit, Last Updated, Status, and Actions
5. THE Inventory_Display_System SHALL display status badges with green background for "Active" items and red background for "Inactive" items

### Requirement 2

**User Story:** As an admin user, I want to search and filter inventory items, so that I can quickly find specific items or view items by status.

#### Acceptance Criteria

1. THE Inventory_Display_System SHALL provide a search input field that filters inventory items by item name
2. THE Inventory_Display_System SHALL provide a status dropdown filter with options "All Status", "Active", and "Inactive"
3. WHEN an Admin_User enters text in the search field, THE Inventory_Display_System SHALL filter the displayed inventory items to show only those containing the search term in their name
4. WHEN an Admin_User selects a status filter, THE Inventory_Display_System SHALL display only inventory items matching the selected status
5. THE Inventory_Display_System SHALL maintain search and filter parameters when navigating between pages

### Requirement 3

**User Story:** As an admin user, I want to see inventory items displayed with pagination, so that I can navigate through large inventories efficiently without performance issues.

#### Acceptance Criteria

1. THE Inventory_Display_System SHALL display inventory items in paginated format with a maximum of 10 items per page
2. THE Inventory_Display_System SHALL show pagination controls at the bottom of the inventory table
3. WHEN there are multiple pages, THE Inventory_Display_System SHALL display Previous, Next, and numbered page buttons
4. THE Inventory_Display_System SHALL highlight the current page number with orange background
5. THE Inventory_Display_System SHALL preserve search and filter parameters when navigating between pages

### Requirement 4

**User Story:** As an admin user, I want to perform actions on inventory items, so that I can manage the inventory effectively.

#### Acceptance Criteria

1. THE Inventory_Display_System SHALL provide an "Edit" button for each inventory item that opens an edit form
2. THE Inventory_Display_System SHALL provide a toggle button that changes "Active" items to "Inactive" and vice versa
3. WHEN an Admin_User clicks the toggle button, THE Inventory_Display_System SHALL display a confirmation dialog before changing the status
4. THE Inventory_Display_System SHALL provide an "Add New Inventory" button that navigates to the inventory creation form
5. THE Inventory_Display_System SHALL display success or error messages after performing actions on inventory items

### Requirement 5

**User Story:** As an admin user, I want the inventory display to be responsive and accessible, so that I can use it effectively on different devices and screen sizes.

#### Acceptance Criteria

1. THE Inventory_Display_System SHALL use responsive design principles to adapt to different screen sizes
2. THE Inventory_Display_System SHALL maintain readability and functionality on mobile devices
3. THE Inventory_Display_System SHALL provide proper hover effects and visual feedback for interactive elements
4. THE Inventory_Display_System SHALL ensure sufficient color contrast for accessibility compliance
5. THE Inventory_Display_System SHALL load efficiently without blocking the user interface
