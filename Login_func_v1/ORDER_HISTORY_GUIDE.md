# 📋 Hướng Dẫn Test Order History

## ✅ Đã Hoàn Thành

### 1. Database
- ✅ Thêm 20+ orders mẫu vào database
- ✅ Orders cho 3 customers với đa dạng trạng thái
- ✅ Bao gồm OrderDetails, Payments, Feedback

### 2. Backend
- ✅ `OrderDAO.getOrdersByCustomerId()` - Lấy orders theo customer ID
- ✅ `OrderHistoryServlet` - Xử lý request và phân quyền
- ✅ Tích hợp với CustomerDAO để lấy CustomerID từ UserID

### 3. Frontend
- ✅ `OrderHistory.jsp` - Giao diện hiển thị orders
- ✅ Card-based layout với thông tin chi tiết
- ✅ Hiển thị items, status, payment, notes
- ✅ Statistics cards (Total Orders, Completed, Total Spent)

### 4. Navigation
- ✅ Link trong Sidebar cho Customer
- ✅ Title trong NavBar

## 🧪 Cách Test

### Bước 1: Chạy lại Database
```sql
-- Chạy file FinalDatabase.sql để tạo database mới với dữ liệu mẫu
-- Hoặc chỉ chạy phần INSERT orders mới (từ dòng 420 trở đi)
```

### Bước 2: Login với Customer Account
Sử dụng một trong các tài khoản sau:

**Customer 1 - Le Van C:**
- Email: `customer01@gmail.com`
- Password: `123` (hoặc check trong database)
- Có 8 orders đã hoàn thành + 1 đang dining

**Customer 2 - Pham Thi D:**
- Email: `customer02@gmail.com`
- Password: `123`
- Có 5 orders đã hoàn thành + 1 ready

**Customer 3 - Hoang Van E:**
- Email: `customer03@gmail.com`
- Password: `123`
- Có 5 orders đã hoàn thành

### Bước 3: Truy Cập Order History
1. Login với customer account
2. Click vào "Order History" trong sidebar (icon 🛍️)
3. Hoặc truy cập: `http://localhost:8080/Login/order-history`

## 📊 Dữ Liệu Test

### Customer 1 (Le Van C):
- Total Orders: 9
- Completed: 8
- Total Spent: ~1,865,000đ
- Orders từ 05/10/2025 đến 13/11/2025

### Customer 2 (Pham Thi D):
- Total Orders: 6
- Completed: 5
- Total Spent: ~1,175,000đ

### Customer 3 (Hoang Van E):
- Total Orders: 5
- Completed: 5
- Total Spent: ~785,000đ

## 🎨 Tính Năng Hiển Thị

### Order Card bao gồm:
- ✅ Order ID và Status badge (với icon)
- ✅ Ngày giờ đặt hàng (format dd/MM/yyyy HH:mm)
- ✅ Số bàn (nếu có)
- ✅ Tổng tiền (format với dấu phẩy)
- ✅ Payment status (Paid/Unpaid)
- ✅ Danh sách món ăn với số lượng
- ✅ Special instructions cho từng món
- ✅ Order note (nếu có)

### Phân Trang:
- ✅ Hiển thị 5 orders mỗi trang
- ✅ Nút Previous/Next
- ✅ Số trang với ellipsis (...)
- ✅ Hiển thị "Showing X to Y of Z orders"
- ✅ Trang hiện tại được highlight màu cam

### Status Colors:
- 🟠 Waiting (Orange) - Chờ chef làm
- 🔵 Ready (Blue) - Chef làm xong
- 🟣 Dining (Purple) - Khách đang ăn
- 🟢 Completed (Green) - Đã thanh toán
- 🔴 Cancelled (Red) - Đã hủy

## 🔒 Phân Quyền
- ✅ Chỉ Customer (Role = 3) mới truy cập được
- ✅ Admin/Employee sẽ bị chặn với lỗi 403

## 📝 Notes
- Orders được sắp xếp theo ngày mới nhất
- Hiển thị cả orders đang xử lý và đã hoàn thành
- Total Spent chỉ tính orders đã completed (status = 3)
