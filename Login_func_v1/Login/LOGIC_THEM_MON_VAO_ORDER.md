# 📋 LOGIC THÊM MÓN VÀO ORDER ĐÃ CÓ

## ✅ ĐÃ ÁP DỤNG CHO NHÁNH: Thai-Duong.Test2

---

## 🎯 TỔNG QUAN

Logic cho phép thêm món mới vào order đã tồn tại thông qua POS, hỗ trợ cho các trường hợp:
- Khách gọi thêm món khi đang chờ (Waiting - Status 0)
- Khách gọi thêm món khi món đã sẵn sàng (Ready - Status 1)
- Khách gọi thêm món khi đang ăn (Dining - Status 2)

---

## 📁 CÁC FILE ĐÃ CHỈNH SỬA

### 1. **ManageOrders.jsp** ✅
- **Dòng 377-391**: Thêm nút "Add" cho orders có status 0, 1, 2
- Link đến: `pos?orderId={orderID}`

### 2. **pos.jsp** ✅
- **Dòng 250-270**: Logic khởi tạo và kiểm tra edit mode
- **Dòng 376-445**: Function `loadExistingOrder()` - Load order hiện có
- **Dòng 930-1036**: Function `completeOrder()` - Submit order (create hoặc edit)

### 3. **POSServlet.java** ✅
- **Dòng 55-67**: Xử lý parameter `orderId` trong doGet
- **Dòng 230-280**: API `handleGetOrderAPI()` - Trả về order details
- **Dòng 350-380**: Logic phân biệt CREATE vs EDIT mode trong doPost
- **Dòng 1470-1550**: Method `addItemsToExistingOrder()` - Thêm items mới
- **Dòng 1552-1600**: Method `parseCartItemsWithToppingsForEdit()` - Filter items mới
- **Dòng 1602-1625**: Method `saveToppingsForOrderDetail()` - Lưu toppings

### 4. **OrderDAO.java** ✅
- **Dòng 1300-1410**: Method `addItemsToOrder()` - Insert items mới vào DB

---

## 🔄 FLOW HOẠT ĐỘNG

### **BƯỚC 1: Nhấn nút "Add" trong ManageOrders**
```jsp
<a href="${pageContext.request.contextPath}/pos?orderId=<%= order.getOrderID() %>">
    Add
</a>
```

### **BƯỚC 2: POS mở ở chế độ EDIT**
```javascript
// pos.jsp - DOMContentLoaded
const orderIdParam = urlParams.get('orderId');
if (orderIdParam) {
    editOrderId = parseInt(orderIdParam);
    await loadExistingOrder(editOrderId);
}
```

### **BƯỚC 3: Load order hiện có**
```javascript
// pos.jsp - loadExistingOrder()
const response = await fetch('pos?action=getOrder&orderId=' + orderId);

// Ẩn panel chọn bàn
tablePanel.style.display = 'none';

// Ẩn nút Clear
clearBtn.style.display = 'none';

// Load items cũ vào cart (đánh dấu isExisting: true)
cart = existingOrder.items.map(item => ({
    ...item,
    uniqueId: 'existing-' + item.orderDetailID,
    isExisting: true
}));
```

### **BƯỚC 4: Thêm món mới vào cart**
- User chọn món mới từ menu
- Món mới được thêm vào cart (không có flag `isExisting`)

### **BƯỚC 5: Submit order**
```javascript
// pos.jsp - completeOrder()
const orderData = {
    items: cart,  // Bao gồm cả items cũ và mới
    subtotal: subtotal,
    total: total
};

if (editOrderId) {
    orderData.orderId = parseInt(editOrderId);  // ✅ Gửi orderId
} else {
    orderData.tableID = parseInt(selectedTable);  // ✅ Gửi tableID
}

await fetch('pos', {
    method: 'POST',
    body: JSON.stringify(orderData)
});
```

### **BƯỚC 6: Backend xử lý**
```java
// POSServlet.doPost()
int existingOrderId = extractJsonInt(jsonData, "orderId");

if (existingOrderId > 0) {
    // EDIT MODE
    boolean success = addItemsToExistingOrder(jsonData, user, existingOrderId);
} else {
    // CREATE MODE
    int orderId = processOrderSimple(jsonData, user, tableId);
}
```

### **BƯỚC 7: Filter items mới**
```java
// POSServlet.addItemsToExistingOrder()
List<CartItemWithToppings> allCartItems = parseCartItemsWithToppingsForEdit(jsonData);

// Chỉ lấy items KHÔNG có flag "isExisting":true
for (CartItemWithToppings item : allCartItems) {
    if (!item.isExisting()) {
        newItems.add(item);
    }
}
```

### **BƯỚC 8: Insert vào database**
```java
// OrderDAO.addItemsToOrder()
// 1. Insert new items vào OrderDetail
INSERT INTO [OrderDetail] (OrderID, ProductSizeID, Quantity, TotalPrice, ...)
VALUES (?, ?, ?, ?, ...)

// 2. Update Order's TotalPrice
UPDATE [Order] SET TotalPrice = TotalPrice + ?

// 3. Update Order status back to Waiting (nếu đang Ready)
UPDATE [Order] SET Status = 0 WHERE OrderID = ? AND Status = 1
```

---

## 🎨 UI/UX CHANGES

### **Khi ở chế độ EDIT:**
1. ✅ Panel chọn bàn bị ẩn (order đã có bàn)
2. ✅ Nút "Clear" bị ẩn (không cho xóa items cũ)
3. ✅ Header hiển thị: "Order #123 - Table 5"
4. ✅ Items cũ hiển thị trong cart (màu xanh dương)
5. ✅ Items cũ KHÔNG có nút "Remove" (chỉ items mới mới có)
6. ✅ Có thể thay đổi quantity của items cũ

---

## 🔑 ĐIỂM QUAN TRỌNG

### **1. Phân biệt items cũ và mới**
```javascript
// Items cũ
{
    uniqueId: 'existing-123',
    isExisting: true  // ✅ Flag này
}

// Items mới
{
    uniqueId: '456-789-1234567890',
    // Không có flag isExisting
}
```

### **2. Backend filter items**
```java
// Kiểm tra flag "isExisting" trong JSON
if (json.contains("\"isExisting\":true")) {
    // Skip item này
} else {
    // Thêm item này vào newItems
}
```

### **3. Update Order status**
- Nếu order đang **Ready (1)** → Chuyển về **Waiting (0)**
- Lý do: Chef cần làm món mới

### **4. Update TotalPrice**
- Cộng thêm giá trị của items mới vào TotalPrice hiện tại
- Không tính lại toàn bộ (vì items cũ đã có giá)

---

## 🧪 TEST CASES

### **Test 1: Thêm món vào order Waiting**
1. Tạo order mới với 1 món
2. Nhấn "Add" trong ManageOrders
3. Thêm 1 món mới
4. Nhấn "Order"
5. ✅ Kiểm tra: Order có 2 items, TotalPrice tăng

### **Test 2: Thêm món vào order Ready**
1. Tạo order và đợi chef làm xong (Status = 1)
2. Nhấn "Add"
3. Thêm món mới
4. ✅ Kiểm tra: Order status chuyển về Waiting (0)

### **Test 3: Thêm món vào order Dining**
1. Tạo order, chef làm xong, waiter serve (Status = 2)
2. Nhấn "Add"
3. Thêm món mới
4. ✅ Kiểm tra: Order có thêm món, status vẫn là Dining

### **Test 4: Không thể thêm món vào order Completed**
1. Tạo order và thanh toán (Status = 3)
2. ✅ Kiểm tra: Không có nút "Add"

---

## 📊 DATABASE CHANGES

### **OrderDetail table**
```sql
-- Mỗi lần thêm món, insert thêm rows mới
INSERT INTO [OrderDetail] 
(OrderID, ProductSizeID, Quantity, TotalPrice, SpecialInstructions, Status)
VALUES (123, 5, 2, 150000, 'Hawaiian Pizza (Medium)', 'Waiting')
```

### **Order table**
```sql
-- Update TotalPrice
UPDATE [Order] 
SET TotalPrice = TotalPrice + 150000
WHERE OrderID = 123

-- Update Status (nếu cần)
UPDATE [Order] 
SET Status = 0
WHERE OrderID = 123 AND Status = 1
```

---

## 🐛 TROUBLESHOOTING

### **Lỗi: Items cũ bị insert lại**
- **Nguyên nhân**: Logic filter items không hoạt động
- **Giải pháp**: Kiểm tra flag `isExisting` trong JSON

### **Lỗi: TotalPrice không đúng**
- **Nguyên nhân**: Tính toán sai hoặc không cộng tax
- **Giải pháp**: Kiểm tra logic tính toán trong `completeOrder()`

### **Lỗi: Order status không update**
- **Nguyên nhân**: SQL không chạy hoặc điều kiện sai
- **Giải pháp**: Kiểm tra log trong `OrderDAO.addItemsToOrder()`

---

## 📝 NOTES

- Logic này tương thích với hệ thống toppings
- Hỗ trợ cả món có và không có toppings
- Tự động tính tax (10%) khi submit
- Không ảnh hưởng đến logic tạo order mới

---

**Ngày áp dụng**: 2025-01-14  
**Nhánh**: Thai-Duong.Test2  
**Trạng thái**: ✅ Hoàn thành
