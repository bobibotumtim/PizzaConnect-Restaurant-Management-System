# 📋 Hướng Dẫn Cập Nhật ChefMonitor

## 🎯 Mục Đích
Cập nhật ChefMonitor để hiển thị đầy đủ thông tin món ăn theo database mới `pizza_demo_DB_FinalModel`:
- Tên món ăn + Size
- Số lượng
- Topping (từ bảng OrderDetailTopping với ProductSizeID)
- Special Instructions
- Số đơn hàng (OrderID)

## 📦 Các File Đã Cập Nhật

### 1. **Insert_Sample_Orders_With_Toppings.sql**
- Tạo 6 orders mẫu với các trạng thái khác nhau
- Bao gồm Pizza với topping (Extra Cheese, Sausage)
- Có special instructions để test hiển thị

**Cách chạy:**
```sql
-- Trong SQL Server Management Studio
USE pizza_demo_DB_FinalModel;
GO
-- Copy và chạy toàn bộ nội dung file
```

### 2. **OrderDetailToppingDAO.java**
**Thay đổi chính:**
- Schema mới: `ProductSizeID` + `ProductPrice` (thay vì ToppingID + ToppingPrice)
- JOIN với `ProductSize` và `Product` để lấy tên topping
- Thêm connection management pattern giống các DAO khác

**Các method:**
```java
// Thêm topping vào order detail
addToppingToOrderDetail(int orderDetailID, int productSizeID, double productPrice)

// Lấy danh sách topping của một order detail
getToppingsByOrderDetailID(int orderDetailID)

// Tính tổng giá topping
getTotalToppingPrice(int orderDetailID)
```

### 3. **OrderDetailTopping.java (Model)**
**Thay đổi:**
- `toppingID` → `productSizeID`
- `toppingPrice` → `productPrice`
- Thêm field `sizeName` để hiển thị
- Giữ backward compatibility với @Deprecated methods

### 4. **OrderDetailDAO.java**
**Thay đổi:**
- Tự động load toppings khi query OrderDetail
- Áp dụng cho cả `getOrderDetailsByStatus()` và `getOrderDetailsByStatusAndCategory()`

```java
// Load toppings cho mỗi order detail
OrderDetailToppingDAO toppingDAO = new OrderDetailToppingDAO();
d.setToppings(toppingDAO.getToppingsByOrderDetailID(d.getOrderDetailID()));
```

### 5. **ChefMonitor.jsp**
**Cải tiến giao diện:**
- Tăng kích thước card: 150px → 200px width, 100px → 120px min-height
- Hiển thị topping với icon 🧀 và màu nổi bật
- Hiển thị special instructions với icon 📝 và font italic
- Số lượng có prefix "x" (x1, x2, x3...)
- Responsive layout với gap spacing

**Cấu trúc hiển thị:**
```
┌─────────────────────┐
│ #3              x1  │  ← Order ID + Quantity
│ Hawaiian Pizza (S)  │  ← Product Name + Size
│ 🧀 Extra Cheese     │  ← Toppings (nếu có)
│ 📝 Nướng giòn      │  ← Special Instructions (nếu có)
└─────────────────────┘
```

## 🧪 Test Data Overview

| Order | Product | Size | Qty | Toppings | Instructions | Status |
|-------|---------|------|-----|----------|--------------|--------|
| #1 | Hawaiian Pizza | S | 1 | - | - | Waiting |
| #2 | Coffee | F | 1 | - | Ít đá | Waiting |
| #2 | Tea | F | 1 | - | Không đường | Waiting |
| #3 | Hawaiian Pizza | S | 1 | Extra Cheese | Nướng giòn | Preparing |
| #4 | Hawaiian Pizza | M | 1 | Extra Cheese, Sausage | Thêm nhiều phô mai | Waiting |
| #5 | Hawaiian Pizza | L | 2 | Sausage | Cắt thành 8 miếng | Waiting |
| #6 | Hawaiian Pizza | S | 1 | Extra Cheese | Không hành | Ready |

## 🚀 Cách Deploy

### Bước 1: Cập nhật Database
```sql
-- Chạy file SQL để tạo sample data
USE pizza_demo_DB_FinalModel;
GO
-- Execute: Insert_Sample_Orders_With_Toppings.sql
```

### Bước 2: Build Project
```bash
# Trong NetBeans hoặc command line
cd Login
ant clean
ant build
```

### Bước 3: Deploy
- Deploy project lên Tomcat
- Hoặc Run trong NetBeans (F6)

### Bước 4: Test
1. Login với tài khoản Chef:
   - Email: `chef01@pizzastore.com`
   - Password: `123` (hoặc password đã set)

2. Truy cập ChefMonitor:
   ```
   http://localhost:8080/Login/ChefMonitor
   ```

3. Kiểm tra hiển thị:
   - ✅ Waiting section: 4 món (Pizza S, Coffee, Tea, Pizza M, 2x Pizza L)
   - ✅ Preparing section: 1 món (Pizza S + Extra Cheese)
   - ✅ Ready section: 1 món (Pizza S + Extra Cheese)

## 🎨 Màu Sắc Topping

- **Waiting**: Vàng gold (#FFD700) - nổi bật trên nền xanh
- **Preparing**: Nâu (#8B4513) - dễ đọc trên nền vàng
- **Ready**: Xanh lá đậm (#228B22) - hài hòa với nền xanh lá

## 📝 Notes

1. **Database Schema**: Topping giờ là Product với CategoryID = 3 (Topping)
2. **ProductSizeID**: Mỗi topping có ProductSizeID riêng (thường là Fixed size)
3. **ProductPrice**: Giá topping được lưu trong OrderDetailTopping.ProductPrice
4. **Backward Compatibility**: Các deprecated methods vẫn hoạt động để không break code cũ

## 🐛 Troubleshooting

### Lỗi: Không hiển thị topping
- Kiểm tra OrderDetailTopping có data không
- Verify ProductSizeID trong OrderDetailTopping tồn tại trong ProductSize
- Check console log cho SQL errors

### Lỗi: Connection timeout
- Kiểm tra DBContext connection string
- Verify database name: `pizza_demo_DB_FinalModel`

### Lỗi: JSP không compile
- Clean và rebuild project
- Restart Tomcat server
- Check JSTL library có trong lib folder

## ✅ Checklist

- [ ] Database updated với sample orders
- [ ] OrderDetailToppingDAO updated
- [ ] OrderDetailTopping model updated
- [ ] OrderDetailDAO loads toppings
- [ ] ChefMonitor.jsp hiển thị topping
- [ ] CSS responsive và đẹp
- [ ] Test với Chef account
- [ ] Verify tất cả 3 sections (Waiting, Preparing, Ready)

---

**Version**: 1.0  
**Date**: 2025-11-09  
**Database**: pizza_demo_DB_FinalModel
