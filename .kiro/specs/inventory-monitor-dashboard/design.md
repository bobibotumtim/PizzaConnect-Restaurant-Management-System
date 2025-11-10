# Design Document

## Overview

Inventory Monitor Dashboard là một tính năng giám sát kho hàng theo thời gian thực cho hệ thống quản lý cửa hàng pizza. Khác với màn hình Manage Inventory hiện tại (tập trung vào CRUD operations), dashboard này cung cấp giao diện tổng quan để theo dõi tình trạng kho, cảnh báo, và xu hướng sử dụng nguyên liệu.

## Architecture

### System Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Browser       │    │   Web Server     │    │   Database      │
│                 │    │                  │    │                 │
│ - Dashboard UI  │◄──►│ - MonitorServlet │◄──►│ - Inventory     │
│ - Auto Refresh  │    │ - MonitorDAO     │    │ - InventoryLog  │
│ - Charts/Alerts │    │ - JSON Response  │    │ - Thresholds    │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

### Technology Stack

- **Frontend**: JSP, Bootstrap 5, Chart.js, JavaScript (Auto-refresh)
- **Backend**: Java Servlet, JDBC
- **Database**: SQL Server (existing tables + new monitoring tables)
- **Styling**: Tailwind CSS (consistent với existing UI)

## Components and Interfaces

### 1. Database Schema Extensions

#### New Tables

```sql
-- Bảng lưu ngưỡng cảnh báo cho từng item
CREATE TABLE InventoryThresholds (
    ThresholdID INT IDENTITY(1,1) PRIMARY KEY,
    InventoryID INT NOT NULL,
    LowStockThreshold DECIMAL(10,2) DEFAULT 10,
    CriticalThreshold DECIMAL(10,2) DEFAULT 5,
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (InventoryID) REFERENCES Inventory(InventoryID)
);

-- Bảng log lịch sử thay đổi inventory (để tính trend)
CREATE TABLE InventoryLog (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    InventoryID INT NOT NULL,
    OldQuantity DECIMAL(10,2),
    NewQuantity DECIMAL(10,2),
    ChangeType VARCHAR(20), -- 'UPDATE', 'USAGE', 'RESTOCK'
    ChangeReason VARCHAR(100),
    LogDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (InventoryID) REFERENCES Inventory(InventoryID)
);

-- Bảng đánh dấu items quan trọng
CREATE TABLE CriticalItems (
    CriticalItemID INT IDENTITY(1,1) PRIMARY KEY,
    InventoryID INT NOT NULL,
    Priority INT DEFAULT 1, -- 1=High, 2=Medium, 3=Low
    Category VARCHAR(50), -- 'DOUGH', 'CHEESE', 'SAUCE', 'TOPPING'
    IsActive BIT DEFAULT 1,
    FOREIGN KEY (InventoryID) REFERENCES Inventory(InventoryID)
);
```

### 2. Backend Components

#### MonitorDAO Class

```java
public class MonitorDAO {
    // Dashboard metrics
    public DashboardMetrics getDashboardMetrics();
    public List<AlertItem> getLowStockAlerts();
    public List<AlertItem> getOutOfStockAlerts();

    // Trend analysis
    public List<InventoryTrend> getInventoryTrends(int days);
    public List<UsagePattern> getUsagePatterns();

    // Critical items monitoring
    public List<CriticalItemStatus> getCriticalItemsStatus();

    // Threshold management
    public void updateThreshold(int inventoryId, double lowStock, double critical);
    public InventoryThreshold getThreshold(int inventoryId);
}
```

#### MonitorServlet Class

```java
@WebServlet("/inventory-monitor")
public class MonitorServlet extends HttpServlet {
    // Main dashboard view
    protected void doGet() // action=dashboard (default)

    // AJAX endpoints for real-time updates
    protected void doPost() // action=refresh-metrics, refresh-alerts, etc.
}
```

#### Data Models

```java
public class DashboardMetrics {
    private int totalItems;
    private int lowStockItems;
    private int outOfStockItems;
    private int criticalAlerts;
    private double totalInventoryValue;
    private Timestamp lastUpdated;
}

public class AlertItem {
    private int inventoryId;
    private String itemName;
    private double currentQuantity;
    private double threshold;
    private String alertType; // LOW_STOCK, OUT_OF_STOCK
    private int daysSinceAlert;
    private boolean acknowledged;
}

public class InventoryTrend {
    private int inventoryId;
    private String itemName;
    private List<TrendPoint> trendPoints;
    private double consumptionRate;
    private int estimatedDaysLeft;
}

public class CriticalItemStatus {
    private int inventoryId;
    private String itemName;
    private String category;
    private double currentQuantity;
    private double threshold;
    private String status; // OK, LOW, CRITICAL, OUT
    private int estimatedDaysLeft;
}
```

### 3. Frontend Components

#### Main Dashboard Layout

```
┌─────────────────────────────────────────────────────────┐
│                    Header & Navigation                   │
├─────────────────────────────────────────────────────────┤
│  📊 Key Metrics Cards                                   │
│  [Total Items] [Low Stock] [Out of Stock] [Alerts]     │
├─────────────────────────────────────────────────────────┤
│  🚨 Alerts Section                    📈 Trends Chart   │
│  - Low Stock Items                    - 7-day trends    │
│  - Out of Stock Items                 - Usage patterns  │
│  - Critical Alerts                                      │
├─────────────────────────────────────────────────────────┤
│  🍕 Critical Pizza Ingredients Status                   │
│  [Dough] [Cheese] [Sauce] [Popular Toppings]          │
├─────────────────────────────────────────────────────────┤
│  📋 Recent Activity & Quick Actions                     │
└─────────────────────────────────────────────────────────┘
```

#### Auto-Refresh Mechanism

```javascript
// Auto-refresh every 5 minutes
setInterval(function () {
  refreshDashboardData();
}, 300000);

function refreshDashboardData() {
  // AJAX calls to update metrics, alerts, trends
  fetch("/inventory-monitor?action=refresh-metrics")
    .then((response) => response.json())
    .then((data) => updateMetricsCards(data));
}
```

## Data Models

### Core Data Flow

1. **Real-time Metrics**: Query current inventory status and calculate metrics
2. **Alert Generation**: Compare current quantities with thresholds
3. **Trend Analysis**: Analyze InventoryLog data for usage patterns
4. **Critical Items**: Monitor pizza-specific ingredients separately

### Data Relationships

```
Inventory (1) ←→ (1) InventoryThresholds
Inventory (1) ←→ (N) InventoryLog
Inventory (1) ←→ (0..1) CriticalItems
```

## Error Handling

### Database Connection Issues

- Display offline indicator
- Cache last known data
- Retry mechanism with exponential backoff

### Data Validation

- Validate threshold values (must be positive)
- Handle missing or corrupted inventory data
- Graceful degradation when charts can't load

### User Experience

- Loading indicators during data refresh
- Error messages with retry options
- Fallback to basic view if advanced features fail

## Testing Strategy

### Unit Tests

- MonitorDAO methods for data retrieval
- Calculation logic for metrics and trends
- Threshold validation and alert generation

### Integration Tests

- Database connectivity and query performance
- Servlet response handling
- AJAX endpoint functionality

### UI Tests

- Dashboard layout responsiveness
- Auto-refresh functionality
- Chart rendering and data updates

## Performance Considerations

### Database Optimization

- Index on InventoryLog.LogDate for trend queries
- Materialized views for complex metrics calculations
- Query optimization for real-time data

### Caching Strategy

- Cache dashboard metrics for 1 minute
- Cache trend data for 5 minutes
- Browser-side caching for static resources

### Scalability

- Pagination for large alert lists
- Lazy loading for trend charts
- Configurable refresh intervals

## Security Considerations

### Access Control

- Reuse existing admin authentication (role = 1)
- Session validation for all requests
- CSRF protection for AJAX calls

### Data Protection

- Input validation for threshold updates
- SQL injection prevention
- XSS protection in dashboard displays

## Integration Points

### Existing System Integration

- Reuse current authentication system
- Integrate with existing sidebar navigation
- Maintain consistent UI styling with current pages
- Use existing database connection utilities

### Future Enhancements

- Integration with order system for demand forecasting
- Email/SMS alerts for critical situations
- Mobile-responsive design for tablet access
- Export functionality for reports
