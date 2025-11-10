# 📊 Giải Thích Logic Trạng Thái Bàn

## ⚠️ Vấn Đề Ban Đầu

Bạn thấy bàn bị chuyển thành `unavailable` khi tạo đơn hàng. Nhưng thực ra...

## 🔍 Sự Thật Về Database Schema

Trong file `ScriptForHieuV5.sql`, bảng `[Table]` được định nghĩa như sau:

```sql
CREATE TABLE [Table] (
    TableID INT IDENTITY(1,1) PRIMARY KEY,
    TableNumber NVARCHAR(10) NOT NULL UNIQUE,
    Capacity INT NOT NULL CHECK (Capacity > 0),
    [Status] NVARCHAR(20) DEFAULT 'available' 
        CHECK ([Status] IN ('available', 'unavailable')),
    IsActive BIT DEFAULT 1
);
```

### 🎯 Điểm Quan Trọng

**Bảng [Table] CHỈ có 2 trạng thái:**
- ✅ `'available'` - Bàn sẵn sàng
- ❌ `'unavailable'` - Bàn không khả dụng

**KHÔNG CÓ `'occupied'`!**

## 🤔 Vậy Làm Sao Biết Bàn Đang Có Khách?

### Câu Trả Lời: Kiểm tra bảng `[Order]`

```sql
-- Bàn đang có khách = Có Order với Status < 4
SELECT t.*, COUNT(o.OrderID) AS ActiveOrders
FROM [Table] t
LEFT JOIN [Order] o ON t.TableID = o.TableID AND o.[Status] < 4
GROUP BY t.TableID, t.TableNumber, t.Capacity, t.[Status], t.IsActive
```

### Logic Đúng:

```
┌─────────────────────────────────────────────────┐
│  Trạng Thái Thực Tế Của Bàn                    │
├─────────────────────────────────────────────────┤
│                                                 │
│  Database Status  │  Active Orders  │  Display  │
│  ────────────────┼─────────────────┼──────────  │
│  available       │  0              │  🟢 Trống  │
│  available       │  > 0            │  🟡 Đang Dùng │
│  unavailable     │  any            │  🔴 Không KD │
│                                                 │
└─────────────────────────────────────────────────┘
```

## 🔧 Giải Pháp

### Bước 1: Chạy Script Sửa Lỗi

```sql
-- File: fix_table_status_correct.sql
-- Chạy trong SQL Server Management Studio
```

Script này sẽ:
1. ✅ Xóa trigger cũ (nếu có)
2. ✅ Sửa tất cả bàn về trạng thái hợp lệ
3. ✅ Tạo VIEW `v_TableWithOrderStatus`
4. ✅ Hiển thị trạng thái thực tế

### Bước 2: Code Java Đã Được Cập Nhật

File `TableDAO.java` đã được sửa để:

```java
// Query mới - tính toán trạng thái thực tế
String sql = """
    SELECT 
        t.TableID,
        t.TableNumber,
        t.Capacity,
        t.[Status] AS TableStatus,
        COUNT(o.OrderID) AS ActiveOrderCount,
        CASE 
            WHEN t.[Status] = 'unavailable' THEN 'unavailable'
            WHEN COUNT(o.OrderID) > 0 THEN 'occupied'
            ELSE 'available'
        END AS ActualStatus
    FROM [Table] t
    LEFT JOIN [Order] o ON t.TableID = o.TableID AND o.[Status] < 4
    WHERE t.IsActive = 1
    GROUP BY t.TableID, t.TableNumber, t.Capacity, t.[Status], t.IsActive
    ORDER BY t.TableNumber
""";

// Sử dụng ActualStatus để hiển thị
table.setStatus(rs.getString("ActualStatus"));
```

## 📊 Ví Dụ Thực Tế

### Trường Hợp 1: Bàn Trống

```sql
-- Database
Table: T01, Status = 'available'
Order: Không có order nào với TableID = 1 và Status < 4

-- Hiển thị
Status: 'available' 🟢 Trống
```

### Trường Hợp 2: Bàn Đang Có Khách

```sql
-- Database
Table: T02, Status = 'available'
Order: Có 1 order với TableID = 2 và Status = 0 (Pending)

-- Hiển thị
Status: 'occupied' 🟡 Đang Dùng
```

### Trường Hợp 3: Bàn Không Khả Dụng

```sql
-- Database
Table: T03, Status = 'unavailable'
Order: Có thể có hoặc không có order

-- Hiển thị
Status: 'unavailable' 🔴 Không KD
```

## 🎯 Luồng Hoạt Động

### Khi Tạo Đơn Hàng Mới:

```
1. Waiter tạo đơn hàng mới
   ↓
2. INSERT vào bảng [Order]
   TableID = 2, Status = 0
   ↓
3. Bảng [Table] KHÔNG THAY ĐỔI
   (vẫn là 'available')
   ↓
4. Khi load trang /assign-table
   ↓
5. TableDAO query với JOIN
   ↓
6. Phát hiện có Order active
   ↓
7. Trả về ActualStatus = 'occupied'
   ↓
8. Hiển thị: 🟡 Đang Dùng
```

### Khi Hoàn Thành Đơn Hàng:

```
1. Cập nhật Order Status = 4
   ↓
2. Bảng [Table] KHÔNG THAY ĐỔI
   ↓
3. Khi load trang /assign-table
   ↓
4. TableDAO query với JOIN
   ↓
5. Không còn Order active (Status < 4)
   ↓
6. Trả về ActualStatus = 'available'
   ↓
7. Hiển thị: 🟢 Trống
```

## 🚫 Không Cần Trigger!

**Lý do:**
- Bảng `[Table]` không lưu trạng thái `'occupied'`
- Trạng thái được tính toán động từ bảng `[Order]`
- Không cần cập nhật database khi tạo/hoàn thành đơn

**Ưu điểm:**
- ✅ Đơn giản hơn
- ✅ Không có race condition
- ✅ Luôn chính xác (real-time)
- ✅ Không cần maintain trigger

## 🔄 Cách Set Bàn Không Khả Dụng

### Thủ Công (Admin):

```sql
-- Set bàn không khả dụng (bảo trì, đặt trước)
UPDATE [Table] 
SET [Status] = 'unavailable' 
WHERE TableID = 5;

-- Set bàn về sẵn sàng
UPDATE [Table] 
SET [Status] = 'available' 
WHERE TableID = 5;
```

### Lưu Ý:
- Chỉ admin mới được set `'unavailable'`
- Waiter không thể thay đổi trạng thái này
- Khi bàn là `'unavailable'`, nó sẽ hiển thị 🔴 dù có order hay không

## 📝 Tóm Tắt

| Điều | Giải Thích |
|------|------------|
| **Database Status** | Chỉ có `'available'` và `'unavailable'` |
| **Display Status** | Có `'available'`, `'occupied'`, `'unavailable'` |
| **Cách tính** | JOIN với bảng `[Order]` để đếm active orders |
| **Trigger** | KHÔNG CẦN! |
| **Update** | Chỉ update khi admin set `'unavailable'` |

## ✅ Kết Luận

Vấn đề ban đầu (bàn bị chuyển thành `unavailable`) có thể do:
1. ❌ Code cũ cố gắng set `'occupied'` (không hợp lệ)
2. ❌ Trigger cũ set sai trạng thái
3. ❌ Dữ liệu test bị sai

**Sau khi sửa:**
- ✅ Code Java query đúng (JOIN với Order)
- ✅ Hiển thị đúng trạng thái thực tế
- ✅ Không còn lỗi `'occupied'` không hợp lệ
- ✅ Bàn sẽ hiển thị đúng: Trống/Đang Dùng/Không KD

---

**Tác giả:** Pizza Store Development Team  
**Ngày cập nhật:** 2025-01-09  
**Version:** 2.0 (Corrected)
