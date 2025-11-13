# Implementation Plan - Inventory Monitor

- [x] 1. Create Database View

  - Create InventoryMonitor view in SQL Server with warning level calculation logic
  - Test view with sample data to verify warning levels are calculated correctly
  - Verify view returns correct data for all 4 warning levels (CRITICAL, LOW, OK, INACTIVE)
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5_

- [x] 2. Create Model Class

  - [x] 2.1 Create InventoryMonitorItem.java model class

    - Define all properties: inventoryID, itemName, quantity, unit, status, lastUpdated, warningLevel, stockPercentage, priority
    - Implement constructors (default and full)
    - Implement all getters and setters
    - _Requirements: 1.3_

  - [x] 2.2 Add utility methods to model

    - Implement getWarningLevelColor() method to return color hex code
    - Implement getWarningLevelIcon() method to return Lucide icon name
    - Implement needsAttention() method to check if item needs attention
    - _Requirements: 1.2, 4.5_

- [ ] 3. Create DAO Class

  - [ ] 3.1 Create InventoryMonitorDAO.java class

    - Implement getConn() method using existing DBContext
    - Implement mapResultSetToItem() helper method
    - _Requirements: 1.5_

  - [ ] 3.2 Implement data retrieval methods

    - Implement getAllMonitorItems() to get all items sorted by priority
    - Implement getItemsByWarningLevel() to filter by specific warning level
    - Implement searchItems() to search by item name
    - Implement searchItemsWithFilter() to combine search and filter
    - _Requirements: 1.1, 2.1, 2.2, 2.3, 3.1, 3.2, 3.3, 3.5_

  - [ ] 3.3 Implement statistics method
    - Implement getWarningLevelCounts() to get count for each warning level
    - Return Map with counts for CRITICAL, LOW, OK, INACTIVE
    - _Requirements: 4.1, 4.2, 4.3_

- [ ] 4. Create Servlet

  - [ ] 4.1 Create InventoryMonitorServlet.java with @WebServlet annotation

    - Set servlet mapping to "/inventory-monitor"
    - Initialize InventoryMonitorDAO instance
    - _Requirements: 5.1, 5.2_

  - [ ] 4.2 Implement authentication and authorization

    - Check session exists and user is logged in
    - Verify user has Manager role (role = 2)
    - Verify employee has JobRole = "Manager"
    - Redirect to login if unauthorized
    - _Requirements: 5.1, 5.2, 5.3, 5.4_

  - [ ] 4.3 Implement doGet() method for main page

    - Get filter parameter (level) and search parameter (search)
    - Call appropriate DAO methods based on parameters
    - Get warning level counts from DAO
    - Set attributes for JSP (items, counts, currentLevel, searchTerm)
    - Forward to InventoryMonitor.jsp
    - _Requirements: 1.1, 2.1, 2.2, 2.3, 2.4, 3.1, 3.2, 3.3, 3.4, 3.5, 4.1, 4.2, 4.3_

  - [ ] 4.4 Implement CSV export functionality
    - Create handleExport() method
    - Set response headers for CSV download
    - Generate filename with timestamp: inventory_monitor_YYYYMMDD_HHMMSS.csv
    - Write CSV header and data rows
    - Include columns: ItemName, Quantity, Unit, WarningLevel, Status, LastUpdated
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_

- [ ] 5. Create JSP Page

  - [ ] 5.1 Create InventoryMonitor.jsp structure

    - Add HTML structure with proper DOCTYPE and meta tags
    - Include Tailwind CSS and Lucide icons
    - Add authentication check at top of page
    - _Requirements: 5.1, 5.2, 6.1_

  - [ ] 5.2 Implement sidebar navigation

    - Copy sidebar structure from ManagerDashboard.jsp
    - Add "Inventory Monitor" menu item with active state
    - Ensure sidebar is expandable on hover
    - Include all manager menu items (Dashboard, Monitor, Inventory, Reports, Users, Feedback)
    - _Requirements: 6.2_

  - [ ] 5.3 Create statistics cards section

    - Create 4 cards for each warning level (CRITICAL, LOW, OK, INACTIVE)
    - Display count for each level from counts map
    - Apply appropriate colors for each card
    - Make cards clickable to filter by that level
    - Highlight CRITICAL card if count > 0
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5_

  - [ ] 5.4 Create filter and search controls

    - Create filter buttons: All, Critical, Low, OK, Inactive
    - Highlight active filter button
    - Create search input box with icon
    - Implement client-side search with debounce
    - Add Refresh button to reload data
    - Add Export button to download CSV
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 3.1, 3.2, 3.3, 3.4, 7.2, 7.3, 8.1_

  - [ ] 5.5 Create items list display

    - Display items in card layout for mobile, table for desktop
    - Show item icon with warning level color
    - Display ItemName, Quantity, Unit, WarningLevel
    - Show LastUpdated as relative time (e.g., "2 hours ago")
    - Sort items by priority (CRITICAL first)
    - Show "No items found" message when list is empty
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 7.1_

  - [ ] 5.6 Implement responsive design

    - Use Tailwind responsive classes for different screen sizes
    - Collapsible sidebar for tablet and mobile
    - Card layout for mobile, table for desktop
    - Ensure touch-friendly button sizes (min 44x44px)
    - Test on desktop (≥1024px), tablet (768-1023px), mobile (<768px)
    - _Requirements: 6.1, 6.2, 6.3, 6.4_

  - [ ] 5.7 Add loading and error states
    - Show loading spinner while fetching data
    - Display error message if data fetch fails
    - Show empty state message when no items match filter
    - Add success toast for export completion
    - _Requirements: 7.4, 7.5_

- [ ] 6. Add Servlet Mapping

  - [ ] 6.1 Update web.xml with servlet mapping
    - Add servlet definition for InventoryMonitorServlet
    - Add servlet mapping for /inventory-monitor URL pattern
    - Verify mapping doesn't conflict with existing servlets
    - _Requirements: 5.1_

- [ ] 7. Integrate with Manager Dashboard

  - [ ] 7.1 Add Inventory Monitor card to ManagerDashboard.jsp

    - Create new dashboard card with icon and description
    - Link to /inventory-monitor servlet
    - Use consistent styling with other dashboard cards
    - _Requirements: 1.1_

  - [ ] 7.2 Update sidebar navigation in all Manager pages
    - Add "Inventory Monitor" menu item to sidebar
    - Ensure consistent navigation across all Manager pages
    - _Requirements: 6.2_

- [ ] 8. Testing and Validation

  - [ ] 8.1 Test warning level calculations

    - Test CRITICAL level (quantity ≤ 10)
    - Test LOW level (11 ≤ quantity ≤ 50)
    - Test OK level (quantity > 50)
    - Test INACTIVE level (status = 'Inactive')
    - _Requirements: 1.2, 1.4_

  - [ ] 8.2 Test filtering functionality

    - Test "All" filter shows all items
    - Test each warning level filter shows correct items
    - Test filter preserves search term
    - Test statistics cards update correctly
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_

  - [ ] 8.3 Test search functionality

    - Test search by item name (case insensitive)
    - Test search with filter combination
    - Test search with no results
    - Test real-time search updates
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

  - [ ] 8.4 Test authentication and authorization

    - Test access with Manager role succeeds
    - Test access without login redirects to login page
    - Test access with non-Manager role is denied
    - Test session timeout handling
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

  - [ ] 8.5 Test responsive design

    - Test on desktop browser (≥1024px width)
    - Test on tablet size (768-1023px width)
    - Test on mobile size (<768px width)
    - Test sidebar expand/collapse behavior
    - Test touch interactions on mobile
    - _Requirements: 6.1, 6.2, 6.3, 6.4_

  - [ ] 8.6 Test CSV export

    - Test export with all items
    - Test export with filtered items
    - Test export with search results
    - Verify CSV format and content
    - Verify filename format with timestamp
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_

  - [ ] 8.7 Test performance
    - Test page load time with 100+ items
    - Test search performance with large dataset
    - Test filter switching speed
    - Verify page loads in under 2 seconds
    - _Requirements: 6.5_

- [ ]\* 9. Documentation

  - [ ]\* 9.1 Create user guide

    - Document how to access Inventory Monitor
    - Explain warning level meanings and thresholds
    - Document filter and search usage
    - Document export functionality
    - _Requirements: All_

  - [ ]\* 9.2 Create technical documentation
    - Document database view structure
    - Document API endpoints and parameters
    - Document servlet configuration
    - Document troubleshooting steps
    - _Requirements: All_
