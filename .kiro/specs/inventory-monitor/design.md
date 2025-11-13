# Design Document - Inventory Monitor

## Overview

Inventory Monitor là tính năng cho phép Manager giám sát tình trạng tồn kho theo thời gian thực với hệ thống cảnh báo 4 mức. Tính năng này tập trung vào việc hiển thị và cảnh báo, không cho phép chỉnh sửa dữ liệu (read-only).

## Architecture

### System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         Browser (Client)                         │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              InventoryMonitor.jsp                         │  │
│  │  - Dashboard UI                                           │  │
│  │  - Filter Controls                                        │  │
│  │  - Search Box                                             │  │
│  │  - Statistics Cards                                       │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              ↕ HTTP
┌─────────────────────────────────────────────────────────────────┐
│                    Application Server (Servlet)                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │         InventoryMonitorServlet                           │  │
│  │  - Handle GET requests                                    │  │
│  │  - Process filters & search                               │  │
│  │  - Prepare view data                                      │  │
│  │  - Export CSV functionality                               │  │
│  └──────────────────────────────────────────────────────────┘  │
│                              ↕                                   │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │         InventoryMonitorDAO                               │  │
│  │  - getAllMonitorItems()                                   │  │
│  │  - getItemsByWarningLevel()                               │  │
│  │  - searchItems()                                          │  │
│  │  - getWarningLevelCounts()                                │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              ↕ JDBC
┌─────────────────────────────────────────────────────────────────┐
│                      Database (SQL Server)                       │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │         InventoryMonitor View                             │  │
│  │  - Calculates WarningLevel                                │  │
│  │  - Calculates StockPercentage                             │  │
│  │  - Calculates Priority                                    │  │
│  │  - Filters Active items only                              │  │
│  └──────────────────────────────────────────────────────────┘  │
│                              ↕                                   │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │         Inventory Table                                   │  │
│  │  - InventoryID (PK)                                       │  │
│  │  - ItemName                                               │  │
│  │  - Quantity                                               │  │
│  │  - Unit                                                   │  │
│  │  - Status                                                 │  │
│  │  - LastUpdated                                            │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

## Database Design

### InventoryMonitor View

```sql
CREATE VIEW InventoryMonitor AS
SELECT
    i.InventoryID,
    i.ItemName,
    i.Quantity,
    i.Unit,
    i.Status,
    i.LastUpdated,
    -- Calculate warning level based on quantity thresholds
    CASE
        WHEN i.Status = 'Inactive' THEN 'INACTIVE'
        WHEN i.Quantity <= 10 THEN 'CRITICAL'
        WHEN i.Quantity <= 50 THEN 'LOW'
        ELSE 'OK'
    END AS WarningLevel,
    -- Calculate percentage for progress bars
    CASE
        WHEN i.Quantity > 100 THEN 100.0
        ELSE CAST(i.Quantity AS FLOAT)
    END AS StockPercentage,
    -- Add priority for sorting (Critical = 1, Inactive = 4)
    CASE
        WHEN i.Status = 'Inactive' THEN 4
        WHEN i.Quantity <= 10 THEN 1
        WHEN i.Quantity <= 50 THEN 2
        ELSE 3
    END AS Priority
FROM Inventory i;
```

**Warning Level Thresholds:**

- **CRITICAL** (Red): Quantity ≤ 10 và Status = 'Active'
- **LOW** (Yellow): 11 ≤ Quantity ≤ 50 và Status = 'Active'
- **OK** (Green): Quantity > 50 và Status = 'Active'
- **INACTIVE** (Gray): Status = 'Inactive'

## Components and Interfaces

### 1. Model: InventoryMonitorItem

```java
package models;

import java.sql.Timestamp;

public class InventoryMonitorItem {
    private int inventoryID;
    private String itemName;
    private double quantity;
    private String unit;
    private String status;
    private Timestamp lastUpdated;
    private String warningLevel;
    private double stockPercentage;
    private int priority;

    // Constructors
    public InventoryMonitorItem() {}

    public InventoryMonitorItem(int inventoryID, String itemName,
                               double quantity, String unit, String status,
                               Timestamp lastUpdated, String warningLevel,
                               double stockPercentage, int priority) {
        this.inventoryID = inventoryID;
        this.itemName = itemName;
        this.quantity = quantity;
        this.unit = unit;
        this.status = status;
        this.lastUpdated = lastUpdated;
        this.warningLevel = warningLevel;
        this.stockPercentage = stockPercentage;
        this.priority = priority;
    }

    // Getters and Setters
    // ... (all fields)

    // Utility Methods
    public String getWarningLevelColor() {
        switch (warningLevel) {
            case "CRITICAL": return "#dc2626"; // Red
            case "LOW": return "#eab308";      // Yellow
            case "OK": return "#16a34a";       // Green
            case "INACTIVE": return "#6b7280"; // Gray
            default: return "#6b7280";
        }
    }

    public String getWarningLevelIcon() {
        switch (warningLevel) {
            case "CRITICAL": return "alert-circle";
            case "LOW": return "alert-triangle";
            case "OK": return "check-circle";
            case "INACTIVE": return "minus-circle";
            default: return "help-circle";
        }
    }

    public boolean needsAttention() {
        return "CRITICAL".equals(warningLevel) || "LOW".equals(warningLevel);
    }
}
```

### 2. DAO: InventoryMonitorDAO

```java
package dao;

import models.InventoryMonitorItem;
import java.sql.*;
import java.util.*;

public class InventoryMonitorDAO {

    private Connection getConn() throws Exception {
        return new DBContext().getConnection();
    }

    /**
     * Get all monitor items sorted by priority
     */
    public List<InventoryMonitorItem> getAllMonitorItems() {
        List<InventoryMonitorItem> list = new ArrayList<>();
        String sql = "SELECT * FROM InventoryMonitor ORDER BY Priority, ItemName";

        try (Connection conn = getConn();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapResultSetToItem(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Get items filtered by warning level
     */
    public List<InventoryMonitorItem> getItemsByWarningLevel(String level) {
        List<InventoryMonitorItem> list = new ArrayList<>();
        String sql = "SELECT * FROM InventoryMonitor WHERE WarningLevel = ? ORDER BY Priority, ItemName";

        try (Connection conn = getConn();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, level.toUpperCase());

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToItem(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Search items by name
     */
    public List<InventoryMonitorItem> searchItems(String searchTerm) {
        List<InventoryMonitorItem> list = new ArrayList<>();
        String sql = "SELECT * FROM InventoryMonitor WHERE ItemName LIKE ? ORDER BY Priority, ItemName";

        try (Connection conn = getConn();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, "%" + searchTerm + "%");

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToItem(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Search items with warning level filter
     */
    public List<InventoryMonitorItem> searchItemsWithFilter(String searchTerm, String warningLevel) {
        List<InventoryMonitorItem> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM InventoryMonitor WHERE 1=1");

        if (searchTerm != null && !searchTerm.trim().isEmpty()) {
            sql.append(" AND ItemName LIKE ?");
        }

        if (warningLevel != null && !warningLevel.equalsIgnoreCase("all")) {
            sql.append(" AND WarningLevel = ?");
        }

        sql.append(" ORDER BY Priority, ItemName");

        try (Connection conn = getConn();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            int paramIndex = 1;
            if (searchTerm != null && !searchTerm.trim().isEmpty()) {
                ps.setString(paramIndex++, "%" + searchTerm.trim() + "%");
            }
            if (warningLevel != null && !warningLevel.equalsIgnoreCase("all")) {
                ps.setString(paramIndex, warningLevel.toUpperCase());
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToItem(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Get count of items for each warning level
     */
    public Map<String, Integer> getWarningLevelCounts() {
        Map<String, Integer> counts = new LinkedHashMap<>();
        counts.put("CRITICAL", 0);
        counts.put("LOW", 0);
        counts.put("OK", 0);
        counts.put("INACTIVE", 0);

        String sql = "SELECT WarningLevel, COUNT(*) as Count FROM InventoryMonitor GROUP BY WarningLevel";

        try (Connection conn = getConn();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                String level = rs.getString("WarningLevel");
                int count = rs.getInt("Count");
                counts.put(level, count);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return counts;
    }

    /**
     * Helper method to map ResultSet to InventoryMonitorItem
     */
    private InventoryMonitorItem mapResultSetToItem(ResultSet rs) throws SQLException {
        InventoryMonitorItem item = new InventoryMonitorItem();
        item.setInventoryID(rs.getInt("InventoryID"));
        item.setItemName(rs.getString("ItemName"));
        item.setQuantity(rs.getDouble("Quantity"));
        item.setUnit(rs.getString("Unit"));
        item.setStatus(rs.getString("Status"));
        item.setLastUpdated(rs.getTimestamp("LastUpdated"));
        item.setWarningLevel(rs.getString("WarningLevel"));
        item.setStockPercentage(rs.getDouble("StockPercentage"));
        item.setPriority(rs.getInt("Priority"));
        return item;
    }
}
```

### 3. Servlet: InventoryMonitorServlet

```java
package controller;

import dao.InventoryMonitorDAO;
import models.InventoryMonitorItem;
import models.User;
import models.Employee;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.List;
import java.util.Map;

@WebServlet("/inventory-monitor")
public class InventoryMonitorServlet extends HttpServlet {

    private InventoryMonitorDAO dao = new InventoryMonitorDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Check authentication and authorization
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/view/Login.jsp");
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        Employee employee = (Employee) session.getAttribute("employee");

        if (currentUser == null || currentUser.getRole() != 2 ||
            employee == null || !"Manager".equalsIgnoreCase(employee.getJobRole())) {
            response.sendRedirect(request.getContextPath() + "/view/Login.jsp");
            return;
        }

        String action = request.getParameter("action");

        if ("export".equals(action)) {
            handleExport(request, response);
            return;
        }

        // Get filter and search parameters
        String warningLevel = request.getParameter("level");
        String searchTerm = request.getParameter("search");

        if (warningLevel == null) warningLevel = "all";
        if (searchTerm == null) searchTerm = "";

        // Get data based on filters
        List<InventoryMonitorItem> items;
        if (!searchTerm.trim().isEmpty() || !warningLevel.equalsIgnoreCase("all")) {
            items = dao.searchItemsWithFilter(searchTerm, warningLevel);
        } else {
            items = dao.getAllMonitorItems();
        }

        // Get warning level counts
        Map<String, Integer> counts = dao.getWarningLevelCounts();

        // Set attributes for JSP
        request.setAttribute("items", items);
        request.setAttribute("counts", counts);
        request.setAttribute("currentLevel", warningLevel);
        request.setAttribute("searchTerm", searchTerm);

        // Forward to JSP
        request.getRequestDispatcher("view/InventoryMonitor.jsp").forward(request, response);
    }

    /**
     * Handle CSV export
     */
    private void handleExport(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String warningLevel = request.getParameter("level");
        String searchTerm = request.getParameter("search");

        if (warningLevel == null) warningLevel = "all";
        if (searchTerm == null) searchTerm = "";

        // Get data
        List<InventoryMonitorItem> items;
        if (!searchTerm.trim().isEmpty() || !warningLevel.equalsIgnoreCase("all")) {
            items = dao.searchItemsWithFilter(searchTerm, warningLevel);
        } else {
            items = dao.getAllMonitorItems();
        }

        // Set response headers for CSV download
        response.setContentType("text/csv");
        response.setCharacterEncoding("UTF-8");

        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd_HHmmss");
        String timestamp = sdf.format(new java.util.Date());
        String filename = "inventory_monitor_" + timestamp + ".csv";

        response.setHeader("Content-Disposition", "attachment; filename=\"" + filename + "\"");

        // Write CSV
        PrintWriter writer = response.getWriter();
        writer.println("Item Name,Quantity,Unit,Warning Level,Status,Last Updated");

        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        for (InventoryMonitorItem item : items) {
            writer.printf("\"%s\",%.2f,\"%s\",\"%s\",\"%s\",\"%s\"%n",
                item.getItemName(),
                item.getQuantity(),
                item.getUnit(),
                item.getWarningLevel(),
                item.getStatus(),
                dateFormat.format(item.getLastUpdated())
            );
        }

        writer.flush();
    }
}
```

## Frontend Design

### Page Layout Structure

```
┌─────────────────────────────────────────────────────────────────┐
│ [Sidebar]  │ Inventory Monitor                    [Refresh] [Export] │
│            │                                                          │
│ 🏠 Dashboard│ ┌─ Statistics Cards ─────────────────────────────┐    │
│ 📊 Monitor  │ │ 🔴 CRITICAL: 5  🟡 LOW: 12  🟢 OK: 25  ⚫ INACTIVE: 3│    │
│ 📋 Inventory│ └─────────────────────────────────────────────────┘    │
│ 📈 Reports  │                                                          │
│ 👥 Users    │ ┌─ Filter & Search ──────────────────────────────┐    │
│ 📝 Feedback │ │ [All] [Critical] [Low] [OK] [Inactive]         │    │
│             │ │ 🔍 Search items...                              │    │
│             │ └─────────────────────────────────────────────────┘    │
│             │                                                          │
│             │ ┌─ Items List ───────────────────────────────────┐    │
│             │ │ 🔴 Tomatoes          5 kg      CRITICAL         │    │
│             │ │    Last updated: 2 hours ago                    │    │
│             │ │ ─────────────────────────────────────────────── │    │
│             │ │ 🟡 Cheese           35 kg      LOW              │    │
│             │ │    Last updated: 1 hour ago                     │    │
│             │ │ ─────────────────────────────────────────────── │    │
│             │ │ 🟢 Flour            85 kg      OK               │    │
│             │ │    Last updated: 30 minutes ago                 │    │
│             │ └─────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
```

### Color Scheme

```css
/* Warning Level Colors */
.critical {
  color: #dc2626; /* Red */
  background: #fee2e2; /* Light red background */
}

.low {
  color: #eab308; /* Yellow */
  background: #fef9c3; /* Light yellow background */
}

.ok {
  color: #16a34a; /* Green */
  background: #dcfce7; /* Light green background */
}

.inactive {
  color: #6b7280; /* Gray */
  background: #f3f4f6; /* Light gray background */
}
```

### Responsive Breakpoints

- **Desktop**: ≥ 1024px - Full sidebar + main content
- **Tablet**: 768px - 1023px - Collapsible sidebar
- **Mobile**: < 768px - Bottom navigation, card layout

## Data Models

### InventoryMonitorItem Properties

| Property        | Type      | Description                         |
| --------------- | --------- | ----------------------------------- |
| inventoryID     | int       | Primary key                         |
| itemName        | String    | Name of inventory item              |
| quantity        | double    | Current stock quantity              |
| unit            | String    | Unit of measurement (kg, pcs, etc.) |
| status          | String    | Active or Inactive                  |
| lastUpdated     | Timestamp | Last update time                    |
| warningLevel    | String    | CRITICAL, LOW, OK, or INACTIVE      |
| stockPercentage | double    | Percentage for progress bar (0-100) |
| priority        | int       | Sort priority (1=highest)           |

## Error Handling

### Authentication Errors

- **No session**: Redirect to login page
- **Wrong role**: Redirect to login page with error message
- **Session timeout**: Redirect to login with timeout message

### Data Errors

- **Database connection failure**: Show error message, log error
- **Empty result set**: Show "No items found" message
- **Invalid filter parameter**: Default to "all"

### Export Errors

- **Export failure**: Show error toast, log error
- **No data to export**: Show warning message

## Testing Strategy

### Unit Tests

- Test DAO methods with mock database
- Test warning level calculation logic
- Test search and filter logic

### Integration Tests

- Test servlet with mock request/response
- Test database view queries
- Test CSV export functionality

### UI Tests

- Test responsive design on different screen sizes
- Test filter and search interactions
- Test export button functionality

### Performance Tests

- Test with 1000+ inventory items
- Test concurrent user access
- Measure page load time

## Security Considerations

1. **Authentication**: Verify Manager role on every request
2. **Authorization**: Check JobRole = "Manager" in session
3. **SQL Injection**: Use PreparedStatement for all queries
4. **XSS Prevention**: Escape all user input in JSP
5. **Session Management**: Implement timeout and secure cookies
6. **Logging**: Log all access attempts and errors

## Performance Optimization

1. **Database View**: Pre-calculate warning levels in view
2. **Indexing**: Add index on Status and Quantity columns
3. **Caching**: Consider caching counts for 1 minute
4. **Pagination**: Implement if items > 100
5. **Lazy Loading**: Load items on scroll for mobile

## Future Enhancements

1. **Real-time Updates**: WebSocket for live data
2. **Email Alerts**: Send alerts for critical items
3. **Historical Trends**: Chart showing stock trends
4. **Predictive Analytics**: Predict when items will run out
5. **Mobile App**: Native mobile application
6. **Barcode Scanning**: Quick item lookup
