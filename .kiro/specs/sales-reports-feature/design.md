# Design Document

## Overview

Thiết kế tính năng báo cáo bán hàng cho hệ thống Java Web, tạo giao diện tương tự như React component đã cung cấp nhưng sử dụng JSP, Servlet và Bootstrap.

## Architecture

### MVC Pattern

- **Model**: SalesReport, ReportData classes
- **View**: GenerateSalesReports.jsp
- **Controller**: SalesReportServlet

### Database Integration

- Sử dụng các bảng hiện có: Orders, OrderDetails, Products, Customers
- Tạo stored procedures để tính toán thống kê
- Cache dữ liệu thống kê để tối ưu performance

## Components and Interfaces

### Backend Components

#### SalesReportServlet

```java
@WebServlet("/sales-reports")
public class SalesReportServlet extends HttpServlet {
    // Handle GET: Display report page
    // Handle POST: Generate and export reports
    // Parameters: reportType, dateFrom, dateTo, branch, format
}
```

#### SalesReportDAO

```java
public class SalesReportDAO {
    // getTotalRevenue(dateFrom, dateTo, branch)
    // getTotalOrders(dateFrom, dateTo, branch)
    // getTotalCustomers(dateFrom, dateTo, branch)
    // getTopProducts(dateFrom, dateTo, branch, limit)
    // getDailyRevenue(dateFrom, dateTo, branch)
    // getRevenueGrowth(dateFrom, dateTo, branch)
}
```

#### Model Classes

```java
public class SalesReportData {
    private double totalRevenue;
    private int totalOrders;
    private int totalCustomers;
    private double avgOrderValue;
    private double growthRate;
    private List<TopProduct> topProducts;
    private List<DailyRevenue> dailyRevenue;
}

public class TopProduct {
    private String productName;
    private int quantity;
    private double revenue;
}

public class DailyRevenue {
    private String date;
    private double revenue;
    private int orders;
}
```

### Frontend Components

#### JSP Structure

```jsp
<%-- GenerateSalesReports.jsp --%>
<div class="container-fluid">
    <!-- Header Section -->
    <!-- Report Configuration Form -->
    <!-- Summary Statistics Cards -->
    <!-- Charts and Tables -->
    <!-- Quick Reports Section -->
</div>
```

#### CSS Framework

- Bootstrap 5.3.2 (đã có sẵn)
- Custom CSS cho gradient backgrounds
- Responsive design cho mobile/tablet

#### JavaScript Libraries

- Chart.js cho biểu đồ
- jQuery cho AJAX calls
- Bootstrap JS cho interactions

## Data Models

### Database Queries

#### Revenue Statistics

```sql
-- Total Revenue
SELECT SUM(TotalAmount) as TotalRevenue
FROM Orders
WHERE OrderDate BETWEEN ? AND ?
AND (@branch = 'all' OR BranchID = @branch)

-- Top Products
SELECT p.ProductName, SUM(od.Quantity) as Quantity,
       SUM(od.Quantity * od.UnitPrice) as Revenue
FROM OrderDetails od
JOIN Products p ON od.ProductID = p.ProductID
JOIN Orders o ON od.OrderID = o.OrderID
WHERE o.OrderDate BETWEEN ? AND ?
GROUP BY p.ProductID, p.ProductName
ORDER BY Revenue DESC
LIMIT 5
```

#### Daily Revenue Chart

```sql
SELECT DATE(OrderDate) as OrderDate,
       SUM(TotalAmount) as DailyRevenue,
       COUNT(*) as OrderCount
FROM Orders
WHERE OrderDate BETWEEN ? AND ?
GROUP BY DATE(OrderDate)
ORDER BY OrderDate
```

### Report Export Data Structure

```java
public class ReportExportData {
    private String reportTitle;
    private String dateRange;
    private String branch;
    private SalesReportData summaryData;
    private List<DetailedSalesData> detailedData;
}
```

## Error Handling

### Validation Rules

- Date range không được vượt quá 1 năm
- Ngày bắt đầu không được lớn hơn ngày kết thúc
- Branch ID phải tồn tại trong database
- Report type phải thuộc danh sách cho phép

### Error Scenarios

1. **Database Connection Error**: Hiển thị thông báo lỗi, fallback về dữ liệu mẫu
2. **Invalid Date Range**: Validation message, reset về default range
3. **No Data Found**: Hiển thị empty state với hướng dẫn
4. **Export Error**: Thông báo lỗi, cho phép thử lại

## Testing Strategy

### Unit Testing

- Test DAO methods với mock database
- Test calculation logic trong service layer
- Test date range validation

### Integration Testing

- Test servlet request/response flow
- Test database queries với test data
- Test export functionality

### Manual Testing Scenarios

1. **Basic Report Generation**: Tạo báo cáo với các tham số khác nhau
2. **Date Range Filtering**: Test các khoảng thời gian khác nhau
3. **Branch Filtering**: Test lọc theo chi nhánh
4. **Export Functions**: Test xuất PDF và Excel
5. **Responsive Design**: Test trên mobile/tablet
6. **Performance**: Test với large dataset

## Implementation Notes

### Performance Optimization

- Sử dụng connection pooling
- Cache thống kê summary trong 15 phút
- Pagination cho detailed reports
- Lazy loading cho charts

### Security Considerations

- Validate tất cả input parameters
- Sanitize data trước khi export
- Check user permissions cho report access
- Prevent SQL injection trong dynamic queries

### UI/UX Design

- Consistent với existing application theme
- Loading states cho long-running operations
- Progressive disclosure cho advanced options
- Keyboard shortcuts cho power users

### File Export Features

- PDF: Sử dụng iText library
- Excel: Sử dụng Apache POI
- File naming: "SalesReport_YYYYMMDD_Branch.ext"
- Auto-download sau khi generate

### Chart Implementation

- Chart.js cho interactive charts
- Responsive charts cho mobile
- Color scheme consistent với brand
- Export chart as image option
