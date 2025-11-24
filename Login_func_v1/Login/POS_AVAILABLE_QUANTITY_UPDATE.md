tô# POS Available Quantity Display - Implementation

## Overview
Added available quantity display for each product size in the POS screen. The quantity is calculated from the `v_ProductSizeAvailable` view which checks inventory levels based on ingredients.

**⚠️ QUAN TRỌNG:** Nếu sản phẩm chưa có công thức nguyên liệu trong bảng `ProductIngredient`, hệ thống sẽ hiển thị "♾️ Không giới hạn" (999 món).

## Changes Made

### 1. ProductSize Model (`models/ProductSize.java`)
**Added:**
- `private double availableQuantity` field
- Getter and setter methods for availableQuantity
- Updated toString() method

### 2. POSServlet (`controller/POSServlet.java`)
**Updated `handleProductsAPI()` method:**
- Added `availableQuantity` to JSON response for each size
- The quantity comes from `ProductSizeDAO.getAvailableSizesByProductId()` which uses the `v_ProductSizeAvailable` view

### 3. POS Interface (`web/view/pos.jsp`)

#### Product Card Display:
- Shows total available quantity across all sizes
- Format: "✅ Còn X món" với màu sắc thay đổi theo số lượng:
  - Xanh lá (>10 món): Đủ hàng
  - Cam (1-10 món): Cảnh báo sắp hết
  - Đỏ (0 món): Hết hàng
- Displayed below the price range

#### Size Selection Modal:
- Shows available quantity for each individual size
- Format: "✅ Còn X món" với màu sắc thay đổi theo số lượng:
  - Xanh lá (>5 món): Đủ hàng
  - Cam (1-5 món): Cảnh báo sắp hết
  - Đỏ (0 món): Hết hàng
- Displayed below the price for each size option

## How It Works

1. **Database View**: `v_ProductSizeAvailable` calculates available quantity based on:
   - Inventory quantities
   - Product ingredients (ProductIngredient table)
   - Returns the limiting ingredient quantity (the one that runs out first)

2. **Backend**: 
   - `ProductSizeDAO.getAvailableSizesByProductId()` queries the view
   - Only returns sizes with `AvailableQuantity > 0`
   - POSServlet includes this data in JSON response

3. **Frontend**:
   - JavaScript receives availableQuantity for each size
   - Displays in both product cards and size selection modal
   - Uses color coding (green/red) for quick visual feedback

## Visual Examples

### Product Card:
```
Hawaiian Pizza
120,000đ - 200,000đ
3 sizes • ✅ Còn 25 món
```

Màu sắc hiển thị:
- ♾️ **Xanh dương**: Không giới hạn (chưa có công thức nguyên liệu)
- ✅ **Xanh lá**: Còn > 10 món
- ⚠️ **Cam**: Còn 1-10 món (cảnh báo sắp hết)
- ❌ **Đỏ**: Hết hàng (0 món)

### Size Selection Modal:
```
Small
120,000đ
♾️ Không giới hạn

Medium  
160,000đ
✅ Còn 10 món

Large
200,000đ
⚠️ Còn 3 món
```

Màu sắc hiển thị:
- ♾️ **Xanh dương**: Không giới hạn (chưa có công thức nguyên liệu)
- ✅ **Xanh lá**: Còn > 5 món
- ⚠️ **Cam**: Còn 1-5 món (cảnh báo sắp hết)
- ❌ **Đỏ**: Hết hàng (0 món)

## Testing

To test the feature:
1. Access POS screen: `http://localhost:8080/Login/pos`
2. Browse products - you'll see total available quantity on each card
3. Click a product - the modal shows available quantity per size
4. The quantities reflect real inventory levels from the database

## Notes

- Quantities are shown as whole numbers (no decimals) for better UX
- Số lượng hiển thị là số món có thể nấu được dựa trên nguyên liệu còn lại trong kho
- Hệ thống sử dụng màu sắc để cảnh báo khi sắp hết hàng:
  - Product card: Cảnh báo khi ≤10 món
  - Size modal: Cảnh báo khi ≤5 món
- Out of stock items (0 món) vẫn hiển thị nhưng được đánh dấu rõ ràng
- Quantities update based on the `v_ProductSizeAvailable` view calculation
- View tự động tính toán dựa trên nguyên liệu giới hạn nhất (ingredient runs out first)

## Xử Lý Trường Hợp Không Có Công Thức Nguyên Liệu

**Vấn đề:** Nếu bảng `ProductIngredient` không có dữ liệu cho một ProductSize, view sẽ trả về `AvailableQuantity = 0`.

**Giải pháp:** Hệ thống tự động kiểm tra:
- Nếu ProductSize **không có** công thức nguyên liệu → Hiển thị "♾️ Không giới hạn" (999 món)
- Nếu ProductSize **có** công thức nguyên liệu → Hiển thị số lượng thực tế dựa trên inventory

**Để thêm công thức nguyên liệu:**
1. Xem file `SAMPLE_PRODUCT_INGREDIENTS.sql` để biết cách thêm dữ liệu
2. Chạy các query SELECT để xem ProductSizeID và InventoryID
3. INSERT vào bảng `ProductIngredient` với `QuantityNeeded` (số lượng nguyên liệu cần cho 1 món)
4. View `v_ProductSizeAvailable` sẽ tự động tính toán số món có thể làm
