# 🍕 Pizza Orders Management System - Setup Guide

## 📋 Tổng quan
Hệ thống quản lý đơn hàng pizza đã được chuyển đổi từ hệ thống giày sang pizza với đầy đủ các tính năng quản lý đơn hàng.

## 🗄️ Database Setup

### 1. Chạy Script SQL
```sql
-- Chạy file: pizza_orders_script.sql
-- Script này sẽ thêm vào database pizza_demo_DB hiện có:
-- - Bảng Products (menu pizza) - chỉ tạo nếu chưa tồn tại
-- - Bảng Orders (đơn hàng) - chỉ tạo nếu chưa tồn tại  
-- - Bảng OrderDetails (chi tiết đơn hàng) - chỉ tạo nếu chưa tồn tại
-- - Dữ liệu mẫu - chỉ thêm nếu chưa có
-- - Indexes và Views tối ưu
```

### 2. Cấu trúc Database
- **Products**: Lưu trữ menu pizza, đồ uống, món phụ
- **Orders**: Thông tin đơn hàng (bàn, khách hàng, trạng thái, thanh toán)
- **OrderDetails**: Chi tiết từng món trong đơn hàng

## 🔧 Các File Đã Được Cập Nhật

### Models
- ✅ `Order.java` - Model đơn hàng với các thuộc tính pizza
- ✅ `Orderdetail.java` - Model chi tiết đơn hàng
- ✅ `Product.java` - Model sản phẩm pizza (mới)

### DAO
- ✅ `OrderDAO.java` - Xử lý database cho đơn hàng pizza

### Controllers
- ✅ `ManageOrderServlet.java` - Servlet quản lý đơn hàng (mới)

### Views
- ✅ `ManageOrders.jsp` - Giao diện quản lý đơn hàng
- ✅ `OrderDetail.jsp` - Giao diện chi tiết đơn hàng

### Configuration
- ✅ `web.xml` - Thêm servlet mapping cho ManageOrderServlet

## 🚀 Cách Sử Dụng

### 1. Truy cập Quản lý Đơn hàng
```
URL: http://localhost:8080/Login/manage-orders
```

### 2. Các Tính Năng Chính

#### Xem Danh Sách Đơn Hàng
- Hiển thị tất cả đơn hàng
- Lọc theo trạng thái (Pending, Processing, Completed, Cancelled)
- Thông tin: ID, Bàn, Khách hàng, Ngày, Tổng tiền, Trạng thái, Thanh toán

#### Quản Lý Trạng Thái Đơn Hàng
- **Pending** → **Processing**: Đơn hàng đang được xử lý
- **Processing** → **Completed**: Hoàn thành đơn hàng
- **Cancel**: Hủy đơn hàng

#### Quản Lý Thanh Toán
- **Unpaid** → **Paid**: Đánh dấu đã thanh toán

#### Xem Chi Tiết Đơn Hàng
- Thông tin đầy đủ về đơn hàng
- Danh sách món đã đặt
- Ghi chú đặc biệt
- Tổng tiền chi tiết

#### Xóa Đơn Hàng
- Chỉ xóa được đơn hàng Pending hoặc Cancelled

### 3. Phân Quyền
- **Admin (Role = 1)**: Toàn quyền quản lý
- **Employee (Role = 2)**: Có thể quản lý đơn hàng
- **Customer (Role = 3)**: Không có quyền truy cập

## 🎯 Các Trạng Thái Đơn Hàng

| Status | Code | Mô tả |
|--------|------|-------|
| Pending | 0 | Đơn hàng mới, chờ xử lý |
| Processing | 1 | Đang chuẩn bị |
| Completed | 2 | Hoàn thành |
| Cancelled | 3 | Đã hủy |

## 💰 Trạng Thái Thanh Toán

| Status | Mô tả |
|--------|-------|
| Unpaid | Chưa thanh toán |
| Paid | Đã thanh toán |
| Refunded | Đã hoàn tiền |

## 🔗 Navigation

### Từ Admin Panel
```
Admin Panel → Manage Orders
```

### Từ Login
```
Login → Admin → Manage Orders
```

## 📱 Responsive Design
- Giao diện responsive cho mobile và desktop
- Bootstrap 4 styling
- Modern UI với gradient backgrounds
- Interactive buttons và status badges

## 🛠️ Technical Details

### Database Connection
- Sử dụng `DBContext.java` với SQL Server
- Connection string: `jdbc:sqlserver://localhost:1433;databaseName=pizza_demo_DB`

### Error Handling
- Try-catch blocks cho database operations
- User-friendly error messages
- Session validation

### Security
- Session-based authentication
- Role-based access control
- SQL injection prevention với PreparedStatement

## 🎉 Kết Luận

Hệ thống quản lý đơn hàng pizza đã được hoàn thiện với:
- ✅ Database schema phù hợp với pizza business
- ✅ Full CRUD operations cho orders
- ✅ Modern, responsive UI
- ✅ Role-based access control
- ✅ Comprehensive order management features

Bây giờ bạn có thể sử dụng hệ thống để quản lý đơn hàng pizza một cách hiệu quả!
