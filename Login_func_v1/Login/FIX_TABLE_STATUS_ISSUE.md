# 🔧 Khắc Phục Lỗi Trạng Thái Bàn

## ❌ Vấn Đề

Khi tạo đơn hàng mới cho bàn, bàn bị chuyển thành `unavailable` thay vì `occupied`.

## 🔍 Nguyên Nhân

1. **Không có trigger tự động** cập nhật trạng thái bàn khi tạo/cập nhật đơn hàng
2. **Logic cập nhật thiếu** trong code Java
3. **Dữ liệu không đồng bộ** giữa bảng Order và Table

## ✅ Giải Pháp

### Bước 1: Kiểm tra trigger hiện tại

Chạy file `check_table_triggers.sql` để xem có trigger nào đang hoạt động không:

```sql
-- Mở SQL Server Management Studio
-- Chọn database: pizza_demo_DB_FinalModel
-- Chạy file: check_table_triggers.sql
```

Kết quả sẽ hiển thị:
- Danh sách trigger hiện có
- Trạng thái các bàn (đúng/sai)
- Tự động sửa các bàn có trạng thái sai

### Bước 2: Cài đặt trigger tự động

Chạy file `create_table_status_trigger.sql`:

```sql
-- File này sẽ tạo:
-- 1. Stored Procedure: sp_UpdateTableStatus
-- 2. Trigger: trg_UpdateTableStatus_AfterOrderInsert
-- 3. Trigger: trg_UpdateTableStatus_AfterOrderUpdate
-- 4. Trigger: trg_UpdateTableStatus_AfterOrderDelete
```

### Bước 3: Test trigger

Sau khi cài đặt trigger, test bằng cách:

1. **Tạo đơn hàng mới:**
   ```sql
   INSERT INTO [Order] (CustomerID, EmployeeID, TableID, [Status], PaymentStatus, TotalPrice)
   VALUES (1, 1, 2, 0, 'Unpaid', 100000);
   
   -- Kiểm tra bàn 2
   SELECT * FROM [Table] WHERE TableID = 2;
   -- Kết quả: Status = 'occupied' ✅
   ```

2. **Hoàn thành đơn hàng:**
   ```sql
   UPDATE [Order] SET [Status] = 4 WHERE TableID = 2;
   
   -- Kiểm tra bàn 2
   SELECT * FROM [Table] WHERE TableID = 2;
   -- Kết quả: Status = 'available' ✅
   ```

3. **Xóa đơn hàng:**
   ```sql
   DELETE FROM [Order] WHERE TableID = 2;
   
   -- Kiểm tra bàn 2
   SELECT * FROM [Table] WHERE TableID = 2;
   -- Kết quả: Status = 'available' ✅
   ```

## 📊 Logic Trạng Thái Bàn

```
┌─────────────────────────────────────────┐
│  Trạng Thái Bàn (Table Status)         │
├─────────────────────────────────────────┤
│                                         │
│  available   → Bàn trống, sẵn sàng     │
│  occupied    → Có đơn hàng đang xử lý   │
│  unavailable → Không khả dụng (thủ công)│
│                                         │
└─────────────────────────────────────────┘

Luồng tự động:
═══════════════

1. Tạo đơn hàng mới (Status < 4)
   └─> Bàn: available → occupied

2. Hoàn thành đơn hàng (Status = 4)
   └─> Bàn: occupied → available

3. Xóa đơn hàng
   └─> Bàn: occupied → available

Lưu ý:
- unavailable chỉ được set thủ công
- Trigger không tự động chuyển thành unavailable
```

## 🎯 Cách Hoạt Động Của Trigger

### 1. Stored Procedure: `sp_UpdateTableStatus`

```sql
-- Nhận TableID làm tham số
-- Đếm số đơn hàng active (Status < 4)
-- Nếu có đơn hàng -> occupied
-- Nếu không có đơn hàng -> available
-- Không động vào unavailable (do admin set)
```

### 2. Trigger: `trg_UpdateTableStatus_AfterOrderInsert`

```sql
-- Kích hoạt khi: INSERT vào bảng Order
-- Hành động: Gọi sp_UpdateTableStatus cho TableID mới
-- Kết quả: Bàn tự động chuyển thành occupied
```

### 3. Trigger: `trg_UpdateTableStatus_AfterOrderUpdate`

```sql
-- Kích hoạt khi: UPDATE bảng Order
-- Hành động: Gọi sp_UpdateTableStatus cho TableID cũ và mới
-- Kết quả: Cập nhật trạng thái bàn theo đơn hàng
```

### 4. Trigger: `trg_UpdateTableStatus_AfterOrderDelete`

```sql
-- Kích hoạt khi: DELETE từ bảng Order
-- Hành động: Gọi sp_UpdateTableStatus cho TableID bị xóa
-- Kết quả: Bàn tự động chuyển về available
```

## 🧪 Test Cases

### Test 1: Tạo đơn hàng mới

```sql
-- Before
SELECT * FROM [Table] WHERE TableID = 5;
-- Status: available

-- Action
INSERT INTO [Order] (CustomerID, EmployeeID, TableID, [Status], PaymentStatus, TotalPrice)
VALUES (1, 1, 5, 0, 'Unpaid', 150000);

-- After
SELECT * FROM [Table] WHERE TableID = 5;
-- Status: occupied ✅
```

### Test 2: Hoàn thành đơn hàng

```sql
-- Before
SELECT * FROM [Table] WHERE TableID = 5;
-- Status: occupied

-- Action
UPDATE [Order] SET [Status] = 4 WHERE TableID = 5;

-- After
SELECT * FROM [Table] WHERE TableID = 5;
-- Status: available ✅
```

### Test 3: Nhiều đơn hàng cùng bàn

```sql
-- Tạo 2 đơn hàng cho bàn 5
INSERT INTO [Order] (CustomerID, EmployeeID, TableID, [Status], PaymentStatus, TotalPrice)
VALUES (1, 1, 5, 0, 'Unpaid', 100000);

INSERT INTO [Order] (CustomerID, EmployeeID, TableID, [Status], PaymentStatus, TotalPrice)
VALUES (1, 1, 5, 0, 'Unpaid', 200000);

-- Bàn vẫn occupied
SELECT * FROM [Table] WHERE TableID = 5;
-- Status: occupied ✅

-- Hoàn thành đơn 1
UPDATE [Order] SET [Status] = 4 WHERE OrderID = (SELECT TOP 1 OrderID FROM [Order] WHERE TableID = 5);

-- Bàn vẫn occupied (vì còn đơn 2)
SELECT * FROM [Table] WHERE TableID = 5;
-- Status: occupied ✅

-- Hoàn thành đơn 2
UPDATE [Order] SET [Status] = 4 WHERE TableID = 5;

-- Bàn chuyển về available
SELECT * FROM [Table] WHERE TableID = 5;
-- Status: available ✅
```

## 🔄 Cập Nhật Trạng Thái Thủ Công

Nếu cần cập nhật trạng thái thủ công:

```sql
-- Chuyển bàn thành unavailable (bảo trì, đặt trước, v.v.)
UPDATE [Table] SET [Status] = 'unavailable' WHERE TableID = 5;

-- Chuyển bàn về available
UPDATE [Table] SET [Status] = 'available' WHERE TableID = 5;

-- Hoặc dùng procedure
EXEC sp_UpdateTableStatus @TableID = 5;
```

## 📝 Lưu Ý

1. **Trigger chỉ hoạt động trong database**
   - Không cần sửa code Java
   - Tự động cập nhật khi có thay đổi Order

2. **Status = 4 nghĩa là hoàn thành**
   - 0: Pending
   - 1: In Progress
   - 2: Ready
   - 3: Served
   - 4: Completed

3. **unavailable không tự động**
   - Chỉ admin mới set được
   - Trigger không động vào trạng thái này

4. **Refresh trang để thấy thay đổi**
   - Trang `/assign-table` auto-refresh mỗi 30s
   - Hoặc nhấn F5 để refresh thủ công

## 🎉 Kết Quả

Sau khi cài đặt trigger:
- ✅ Tạo đơn hàng → Bàn tự động chuyển thành `occupied`
- ✅ Hoàn thành đơn hàng → Bàn tự động chuyển thành `available`
- ✅ Xóa đơn hàng → Bàn tự động cập nhật trạng thái
- ✅ Không còn bị chuyển thành `unavailable` nữa!

---

**Tác giả:** Pizza Store Development Team  
**Ngày cập nhật:** 2025-01-09
