# 📋 TỔNG HỢP TẤT CẢ CÁC THAY ĐỔI - POS Available Quantity Display

## 🎯 Mục tiêu
Hiển thị số lượng món có thể nấu được (dựa trên nguyên liệu còn lại trong kho) cho từng size trong màn hình POS.

---

## 📁 CÁC FILE ĐÃ SỬA

### 1. **ProductSize.java** (Model)
**Đường dẫn:** `src/java/models/ProductSize.java`

**Thay đổi:**
- ✅ Thêm field `private double availableQuantity`
- ✅ Thêm getter/setter cho availableQuantity
- ✅ Cập nhật toString() method

```java
// THÊM MỚI
private double availableQuantity; // Available quantity from inventory

public double getAvailableQuantity() { return availableQuantity; }
public void setAvailableQuantity(double availableQuantity) { 
    this.availableQuantity = availableQuantity; 
}
```

---

### 2. **ProductSizeDAO.java** (Data Access Object)
**Đường dẫn:** `src/java/dao/ProductSizeDAO.java`

**Thay đổi:**
- ✅ Thêm imports: `HashMap`, `Map`
- ✅ Thêm method mới: `getAvailableSizesByProductId(int productId)`

**Logic mới:**
```java
/**
 * Lấy sizes có sẵn cho POS
 * 
 * Logic:
 * - Bước 1: Lấy TẤT CẢ sizes từ ProductSize table
 *   → Mặc định set availableQuantity = 999 (unlimited)
 * 
 * - Bước 2: Query view v_ProductSizeAvailable
 *   → Nếu size CÓ trong view (có ingredients) 
 *     → Cập nhật số lượng thực tế (kể cả 0)
 *   → Nếu size KHÔNG có trong view (không có ingredients)
 *     → Giữ nguyên 999 (unlimited)
 */
```

**Kết quả:**
- Size có ingredients + còn hàng → Hiển thị số lượng thực tế (vd: 4 món)
- Size có ingredients + hết hàng → Hiển thị 0 món
- Size không có ingredients → Hiển thị 999 (unlimited)

---

### 3. **ProductDAO.java** (Data Access Object)
**Đường dẫn:** `src/java/dao/ProductDAO.java`

**Thay đổi:**
- ✅ Sửa method `getAvailableProductsForPOS()`
- ✅ Bỏ filter `WHERE v.AvailableQuantity > 0`
- ✅ Hiển thị TẤT CẢ products (kể cả không có ingredients)

**Lý do:** Để hiển thị cả món "Không giới hạn" (chưa có công thức nguyên liệu)

---

### 4. **POSServlet.java** (Controller)
**Đường dẫn:** `src/java/controller/POSServlet.java`

**Thay đổi:**
- ✅ Cập nhật method `handleProductsAPI()`
- ✅ Thêm `availableQuantity` vào JSON response

```java
// THÊM MỚI trong JSON response
json.append("\"availableQuantity\": ").append(size.getAvailableQuantity());
```

**JSON Response mẫu:**
```json
{
  "sizeId": 1,
  "sizeCode": "S",
  "sizeName": "Small",
  "price": 120000,
  "availableQuantity": 4.0
}
```

---

### 5. **pos.jsp** (Frontend)
**Đường dẫn:** `web/view/pos.jsp`

**Thay đổi:**

#### A. Product Card Display (Danh sách sản phẩm)
```javascript
// Tính tổng số lượng available
const totalAvailable = product.sizes.reduce((sum, size) => 
    sum + (size.availableQuantity || 0), 0);
const totalInt = Math.floor(totalAvailable);

// Hiển thị với màu sắc
if (totalInt >= 999) {
    // Unlimited
    stockStatus = '<span class="text-blue-600">♾️ Không giới hạn</span>';
} else if (totalInt === 0) {
    // Hết hàng
    stockStatus = '<span class="text-red-600">❌ Hết hàng</span>';
} else if (totalInt <= 10) {
    // Sắp hết (cảnh báo)
    stockStatus = '<span class="text-orange-600">⚠️ Còn ' + totalInt + ' món</span>';
} else {
    // Còn nhiều
    stockStatus = '<span class="text-green-600">✅ Còn ' + totalInt + ' món</span>';
}
```

#### B. Size Selection Modal (Chọn size)
```javascript
const availQty = size.availableQuantity || 0;
const qtyInt = Math.floor(availQty);

if (qtyInt >= 999) {
    // Unlimited
    qtyDisplay = '<div class="text-xs text-blue-600 font-semibold mt-1">♾️ Không giới hạn</div>';
} else if (qtyInt === 0) {
    // Hết hàng
    qtyDisplay = '<div class="text-xs text-red-600 font-semibold mt-1">❌ Hết hàng (0 món)</div>';
} else if (qtyInt <= 5) {
    // Sắp hết (cảnh báo)
    qtyDisplay = '<div class="text-xs text-orange-600 font-semibold mt-1">⚠️ Còn ' + qtyInt + ' món</div>';
} else {
    // Còn nhiều
    qtyDisplay = '<div class="text-xs text-green-600 font-semibold mt-1">✅ Còn ' + qtyInt + ' món</div>';
}
```

---

## 🎨 MÀU SẮC HIỂN THỊ

### Product Card (Danh sách sản phẩm):
| Số lượng | Màu sắc | Icon | Text |
|----------|---------|------|------|
| ≥ 999 | Xanh dương | ♾️ | Không giới hạn |
| > 10 | Xanh lá | ✅ | Còn X món |
| 1-10 | Cam | ⚠️ | Còn X món |
| 0 | Đỏ | ❌ | Hết hàng |

### Size Modal (Chọn size):
| Số lượng | Màu sắc | Icon | Text |
|----------|---------|------|------|
| ≥ 999 | Xanh dương | ♾️ | Không giới hạn |
| > 5 | Xanh lá | ✅ | Còn X món |
| 1-5 | Cam | ⚠️ | Còn X món |
| 0 | Đỏ | ❌ | Hết hàng (0 món) |

---

## 🔧 CÁCH HOẠT ĐỘNG

### 1. Database View
```sql
-- View v_ProductSizeAvailable tính toán số lượng có thể làm
-- Dựa trên nguyên liệu giới hạn nhất (runs out first)

WITH SizeAvailability AS (
    SELECT
        pi.ProductSizeID,
        MIN(i.Quantity / NULLIF(pi.QuantityNeeded, 0)) AS CalculatedQuantity
    FROM ProductIngredient pi
    JOIN Inventory i ON pi.InventoryID = i.InventoryID
    WHERE pi.QuantityNeeded > 0
    GROUP BY pi.ProductSizeID
)
```

### 2. Backend Flow
```
ProductSizeDAO.getAvailableSizesByProductId()
    ↓
1. Query ProductSize table → Lấy TẤT CẢ sizes
    ↓
2. Set default availableQuantity = 999
    ↓
3. Query v_ProductSizeAvailable → Lấy số lượng thực tế
    ↓
4. Nếu size có trong view → Cập nhật số lượng thực tế
    ↓
5. Return list với availableQuantity đã set
```

### 3. Frontend Flow
```
POSServlet → JSON Response
    ↓
JavaScript nhận data
    ↓
Hiển thị trên UI với màu sắc phù hợp
```

---

## 📝 FILE HỖ TRỢ ĐÃ TẠO

### 1. **SAMPLE_PRODUCT_INGREDIENTS.sql**
- Hướng dẫn thêm công thức nguyên liệu vào ProductIngredient
- Có ví dụ mẫu cho Pizza và Drink

### 2. **DEBUG_CHECK_INGREDIENTS.sql**
- Các query để kiểm tra dữ liệu
- Debug xem size nào có/không có ingredients
- Xem số lượng có thể làm từ view

### 3. **POS_AVAILABLE_QUANTITY_UPDATE.md**
- Tài liệu chi tiết về feature
- Hướng dẫn sử dụng và testing

---

## ✅ KẾT QUẢ

### Trước khi sửa:
- ❌ Không hiển thị số lượng available
- ❌ Không biết món nào sắp hết
- ❌ Không biết món nào có/không có công thức

### Sau khi sửa:
- ✅ Hiển thị số lượng món có thể nấu
- ✅ Cảnh báo màu sắc khi sắp hết hàng
- ✅ Phân biệt rõ: Có ingredients vs Không có ingredients
- ✅ Hiển thị "Không giới hạn" cho món chưa có công thức

---

## 🐛 VẤN ĐỀ ĐÃ SỬA

### Vấn đề 1: Size M, L hiển thị "Không giới hạn" dù có ingredients
**Nguyên nhân:** Logic cũ kiểm tra `HasIngredients` bằng subquery không chính xác

**Giải pháp:** 
- Lấy TẤT CẢ sizes trước
- Query view riêng để lấy số lượng
- Nếu size CÓ trong view → Có ingredients → Dùng số lượng thực tế

### Vấn đề 2: Không hiển thị món khi AvailableQuantity = 0
**Nguyên nhân:** Filter `WHERE v.AvailableQuantity > 0`

**Giải pháp:**
- Bỏ filter trong ProductDAO
- Hiển thị TẤT CẢ products
- Frontend xử lý hiển thị "Hết hàng" cho món có qty = 0

---

## 🚀 CÁCH SỬ DỤNG

1. **Restart server** để load code mới
2. **Truy cập POS:** `http://localhost:8080/Login/pos`
3. **Xem số lượng:**
   - Trên product card: Tổng số món của tất cả sizes
   - Trong modal: Số món của từng size riêng
4. **Thêm công thức nguyên liệu** (nếu cần):
   - Chạy queries trong `SAMPLE_PRODUCT_INGREDIENTS.sql`
   - Số lượng sẽ tự động cập nhật

---

## 📊 TESTING

### Test Case 1: Món có ingredients + còn hàng
- **Expected:** Hiển thị số lượng thực tế với màu xanh lá
- **Example:** "✅ Còn 4 món"

### Test Case 2: Món có ingredients + hết hàng
- **Expected:** Hiển thị "Hết hàng" với màu đỏ
- **Example:** "❌ Hết hàng (0 món)"

### Test Case 3: Món không có ingredients
- **Expected:** Hiển thị "Không giới hạn" với màu xanh dương
- **Example:** "♾️ Không giới hạn"

### Test Case 4: Món sắp hết hàng
- **Expected:** Hiển thị cảnh báo với màu cam
- **Example:** "⚠️ Còn 3 món"

---

## 🔗 LIÊN QUAN

- Database View: `v_ProductSizeAvailable` (trong FinalDatabase.sql)
- Bảng liên quan: `ProductSize`, `ProductIngredient`, `Inventory`
- Frontend: pos.jsp
- Backend: ProductSizeDAO, ProductDAO, POSServlet
- Model: ProductSize

---

**Ngày cập nhật:** 2025-11-24
**Người thực hiện:** Kiro AI Assistant
