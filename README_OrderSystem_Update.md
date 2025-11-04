# Cập Nhật Hệ Thống Order - Hỗ Trợ ProductSize

## Tổng Quan
Đã cập nhật hệ thống Order để hỗ trợ cấu trúc database mới với Product-Category-ProductSize, thay vì cấu trúc cũ chỉ có Product đơn giản.

## Các Thay Đổi Chính

### 1. Model Updates
- **OrderDetail.java**: 
  - Thay đổi từ `productID` sang `productSizeID`
  - Thêm các field: `employeeID`, `status`, `startTime`, `endTime`
  - Thêm thông tin hiển thị: `productName`, `sizeName`, `sizeCode`

### 2. DAO Updates
- **OrderDetailDAO.java**: 
  - Cập nhật queries để join với ProductSize và Product
  - Thêm method `getOrderDetailsByStatus()` cho ChefMonitor
  - Thêm method `updateOrderDetailStatus()` để cập nhật trạng thái

- **OrderDAO.java**:
  - Cập nhật `createOrder()` để sử dụng ProductSizeID
  - Cập nhật `getOrderDetailsByOrderId()` để lấy thông tin đầy đủ

- **ProductSizeDAO.java**:
  - Thêm method `getSizeWithProductInfo()` để lấy thông tin chi tiết

### 3. Controller Updates
- **ChefMonitorServlet.java**:
  - Sử dụng OrderDetailDAO thay vì OrderDAO
  - Hỗ trợ 3 trạng thái: Waiting, In Progress, Done
  - Cập nhật logic xử lý actions

### 4. View Updates
- **ChefMonitor.jsp**:
  - Hiển thị thông tin ProductSize (tên size)
  - Thêm section "Done dishes"
  - Cập nhật form actions

## Cách Sử Dụng

### 1. Chạy Migration Script
```sql
-- Chạy file JobProcessUpdateAndDelete.sql để cập nhật database
USE pizza_demo_DB_Merged;
-- Thực hiện migration từ ProductID sang ProductSizeID
```

### 2. Tạo View Hỗ Trợ
```sql
-- Chạy file ChefMonitorView.sql để tạo view hỗ trợ
-- View này giúp hiển thị thông tin đầy đủ cho Chef Monitor
```

### 3. Test Hệ Thống
```sql
-- Chạy file TestNewOrderSystem.sql để test
-- Script này sẽ tạo dữ liệu test và kiểm tra các queries
```

## Workflow Mới

### Tạo Order
1. Chọn Product từ danh sách
2. Chọn Size (S/M/L/F) với giá tương ứng
3. Tạo OrderDetail với ProductSizeID
4. Tính tổng tiền dựa trên ProductSize.Price

### Chef Monitor
1. **Waiting**: Món vừa được order, chờ chef bắt đầu
2. **In Progress**: Chef đã bắt đầu làm món
3. **Done**: Món đã hoàn thành, sẵn sàng phục vụ

### Database Schema
```
Order (OrderID, CustomerID, EmployeeID, TableID, ...)
  └── OrderDetail (OrderDetailID, OrderID, ProductSizeID, Status, ...)
        └── ProductSize (ProductSizeID, ProductID, SizeCode, Price, ...)
              └── Product (ProductID, ProductName, CategoryID, ...)
                    └── Category (CategoryID, CategoryName, ...)
```

## Lưu Ý Quan Trọng

1. **Backward Compatibility**: Model OrderDetail vẫn có method `getProductID()` để tương thích ngược
2. **Migration**: Dữ liệu cũ sẽ được map với ProductSize đầu tiên của mỗi Product
3. **Status Flow**: Waiting → In Progress → Done
4. **Employee Assignment**: Chef được assign khi bắt đầu làm món

## Troubleshooting

### Lỗi ProductSizeID NULL
- Chạy lại migration script
- Kiểm tra ProductSize có tồn tại cho Product không

### ChefMonitor không hiển thị món
- Kiểm tra OrderDetail.Status = 'Waiting'
- Kiểm tra ProductSize.IsDeleted = 0
- Kiểm tra Product.IsAvailable = 1

### Giá không đúng
- Kiểm tra ProductSize.Price
- Chạy lại script cập nhật TotalPrice

## Files Đã Thay Đổi
- `models/OrderDetail.java`
- `dao/OrderDetailDAO.java` 
- `dao/OrderDAO.java`
- `dao/ProductSizeDAO.java`
- `controller/ChefMonitorServlet.java`
- `view/ChefMonitor.jsp`

## Files Mới
- `JobProcessUpdateAndDelete.sql` - Migration script
- `ChefMonitorView.sql` - View hỗ trợ
- `TestNewOrderSystem.sql` - Test script
- `README_OrderSystem_Update.md` - Tài liệu này