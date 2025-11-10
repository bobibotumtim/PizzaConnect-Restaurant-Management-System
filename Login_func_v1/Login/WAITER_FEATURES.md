# 🍕 Chức Năng Waiter - Pizza Store Management System

## 📋 Tổng Quan

Hệ thống đã được cập nhật với đầy đủ chức năng cho Waiter (Nhân viên phục vụ). Khi đăng nhập với tài khoản Waiter, bạn sẽ có quyền truy cập các chức năng sau:

## 🔐 Đăng Nhập

**Thông tin đăng nhập mẫu:**
- **Phone:** 0909000002 hoặc 0909000003
- **Password:** 123 (mật khẩu mặc định đã được hash trong database)
- **Role:** Employee (Role = 2) với Role = 'Waiter'

## 🎯 Các Chức Năng Chính

### 1. 📊 Waiter Dashboard (`/waiter-dashboard`)
- Trang chủ dành riêng cho Waiter
- Hiển thị menu nhanh với các chức năng chính
- Thống kê ca làm việc
- Truy cập nhanh đến các module

**Đường dẫn:** `http://localhost:8080/Login/waiter-dashboard`

### 2. 🛒 Điểm Bán Hàng - POS (`/pos`)
- Tạo đơn hàng mới cho khách
- Chọn bàn cho đơn hàng
- Thêm món ăn và topping
- Xử lý thanh toán
- Áp dụng mã giảm giá

**Đường dẫn:** `http://localhost:8080/Login/pos`

**Chức năng:**
- Chọn sản phẩm từ menu
- Chọn size (S/M/L/F)
- Thêm topping cho pizza
- Nhập ghi chú đặc biệt
- Tính tổng tiền tự động
- Thanh toán và in hóa đơn

### 3. 🪑 Quản Lý Bàn (`/assign-table`)
- Xem tất cả các bàn trong nhà hàng
- Kiểm tra trạng thái bàn (Trống/Đang dùng/Không khả dụng)
- Xem chi tiết đơn hàng của từng bàn
- Thống kê số bàn trống/đang phục vụ

**Đường dẫn:** `http://localhost:8080/Login/assign-table`

**Tính năng:**
- **Bộ lọc:** Lọc bàn theo trạng thái (Tất cả/Trống/Đang dùng/Không KD)
- **Thống kê:** Hiển thị số lượng bàn theo từng trạng thái
- **Chi tiết bàn:** Click vào bàn để xem thông tin đơn hàng
- **Tạo đơn mới:** Click vào bàn trống để tạo đơn hàng mới
- **Auto-refresh:** Tự động làm mới mỗi 30 giây

**Màu sắc trạng thái:**
- 🟢 **Xanh lá:** Bàn trống (Available)
- 🟡 **Vàng:** Bàn đang phục vụ (Occupied)
- 🔴 **Đỏ:** Bàn không khả dụng (Unavailable)

### 4. 🔔 Theo Dõi Món Ăn (`/WaiterMonitor`)
- Theo dõi món ăn sẵn sàng từ bếp
- Đánh dấu món đã phục vụ cho khách
- Xem lịch sử món đã phục vụ
- Tự động cập nhật trạng thái đơn hàng

**Đường dẫn:** `http://localhost:8080/Login/WaiterMonitor`

**Luồng xử lý:**
1. Chef hoàn thành món → Status = "Ready"
2. Waiter thấy món trong danh sách "Ready"
3. Waiter mang món ra phục vụ
4. Waiter nhấn nút "Served"
5. System cập nhật status → "Served"
6. Nếu tất cả món đã Served → Order status = 1 (Hoàn thành)

**Tính năng:**
- Auto-refresh mỗi 10 giây
- Hiển thị thời gian hoàn thành món
- Ghi nhận EmployeeID của Waiter phục vụ
- Thông báo khi có món mới Ready

### 5. 📝 Quản Lý Đơn Hàng (`/manage-orders`)
- Xem danh sách tất cả đơn hàng
- Lọc đơn hàng theo trạng thái
- Xem chi tiết đơn hàng
- Cập nhật trạng thái đơn hàng
- Xử lý thanh toán

**Đường dẫn:** `http://localhost:8080/Login/manage-orders`

### 6. 👤 Hồ Sơ Cá Nhân (`/profile`)
- Xem thông tin cá nhân
- Cập nhật thông tin
- Đổi mật khẩu

**Đường dẫn:** `http://localhost:8080/Login/profile`

## 🔄 Luồng Làm Việc Của Waiter

```
1. Đăng nhập → Waiter Dashboard
2. Kiểm tra bàn trống → Assign Table
3. Tạo đơn hàng mới → POS
4. Theo dõi món từ bếp → Waiter Monitor
5. Phục vụ món cho khách → Đánh dấu "Served"
6. Xử lý thanh toán → Manage Orders
7. Đăng xuất
```

## 📊 Trạng Thái Đơn Hàng

| Status | Tên | Mô tả |
|--------|-----|-------|
| 0 | Pending | Đơn hàng mới tạo, chờ xử lý |
| 1 | In Progress | Đang được bếp chuẩn bị |
| 2 | Ready | Món đã sẵn sàng, chờ phục vụ |
| 3 | Served | Đã phục vụ cho khách |
| 4 | Completed | Hoàn thành và thanh toán |

## 📊 Trạng Thái OrderDetail

| Status | Mô tả |
|--------|-------|
| Waiting | Chờ bếp xử lý |
| In Progress | Đang được làm |
| Done | Bếp đã hoàn thành |
| Ready | Sẵn sàng phục vụ |
| Served | Đã phục vụ cho khách |

## 🎨 Giao Diện

### Sidebar Navigation
- Tự động thu gọn khi không hover
- Hiển thị đầy đủ khi hover
- Icon rõ ràng cho từng chức năng
- Highlight trang hiện tại

### Responsive Design
- Tương thích với màn hình desktop
- Grid layout linh hoạt
- Card design hiện đại
- Gradient màu sắc đẹp mắt

## 🔒 Phân Quyền

**Waiter có quyền truy cập:**
- ✅ `/waiter-dashboard` - Dashboard
- ✅ `/pos` - Điểm bán hàng
- ✅ `/assign-table` - Quản lý bàn
- ✅ `/WaiterMonitor` - Theo dõi món ăn
- ✅ `/manage-orders` - Quản lý đơn hàng
- ✅ `/profile` - Hồ sơ cá nhân

**Waiter KHÔNG có quyền:**
- ❌ `/admin` - Quản lý người dùng
- ❌ `/manageproduct` - Quản lý sản phẩm
- ❌ `/inventory` - Quản lý kho
- ❌ `/dashboard` - Dashboard admin
- ❌ `/discount` - Quản lý giảm giá
- ❌ `/sales-reports` - Báo cáo doanh thu

## 🗄️ Database Schema

### Bảng liên quan:
- **Employee:** Lưu thông tin nhân viên
- **Order:** Lưu đơn hàng
- **OrderDetail:** Lưu chi tiết món trong đơn
- **Table:** Lưu thông tin bàn
- **OrderDetailTopping:** Lưu topping của món

### Quan hệ:
```
Employee (1) → (N) Order
Order (1) → (N) OrderDetail
Table (1) → (N) Order
OrderDetail (1) → (N) OrderDetailTopping
```

## 🚀 Cách Sử Dụng

### Bước 1: Đăng nhập
```
URL: http://localhost:8080/Login/view/Login.jsp
Phone: 0909000002
Password: 123
```

### Bước 2: Chọn chức năng từ Dashboard
- Click vào card tương ứng với chức năng cần sử dụng

### Bước 3: Xử lý công việc
- Tạo đơn hàng mới qua POS
- Theo dõi món qua Waiter Monitor
- Quản lý bàn qua Assign Table

### Bước 4: Đăng xuất
- Click "Logout" ở cuối sidebar

## 🐛 Xử Lý Lỗi

### Lỗi phổ biến:

1. **Không thể truy cập trang**
   - Kiểm tra đã đăng nhập chưa
   - Kiểm tra role có đúng là Waiter không

2. **Không thấy món Ready**
   - Kiểm tra Chef đã đánh dấu món Done chưa
   - Refresh trang (F5)

3. **Không cập nhật được status**
   - Kiểm tra kết nối database
   - Kiểm tra EmployeeID trong session

## 📞 Hỗ Trợ

Nếu gặp vấn đề, vui lòng liên hệ:
- Admin hệ thống
- Kiểm tra console log trong browser (F12)
- Kiểm tra server log

## 🎉 Tính Năng Nổi Bật

✨ **Auto-refresh:** Tự động cập nhật dữ liệu
✨ **Real-time:** Cập nhật trạng thái ngay lập tức
✨ **User-friendly:** Giao diện thân thiện, dễ sử dụng
✨ **Responsive:** Tương thích nhiều thiết bị
✨ **Secure:** Phân quyền chặt chẽ, bảo mật cao

---

**Phiên bản:** 1.0
**Ngày cập nhật:** 2025-01-09
**Người phát triển:** Pizza Store Development Team
