# POS System với Size Selection

## Tổng Quan
Đã cập nhật hệ thống POS để hỗ trợ chọn size cho sản phẩm, thay vì giá cố định như trước.

## Các Thay Đổi Chính

### 1. Backend Changes

#### ProductAPIServlet.java (MỚI)
- **Endpoint**: `/api/products`
- **Chức năng**: Trả về danh sách sản phẩm với các size và giá tương ứng
- **Response format**: JSON với cấu trúc categories -> products -> sizes

#### POSServlet.java (CẬP NHẬT)
- **parseCartItems()**: Cập nhật để xử lý `ProductSizeID` thay vì `ProductID`
- **Helper methods**: Thêm `extractItemSizeId()` và `extractItemSizeName()`
- **Order creation**: Sử dụng `ProductSizeID` trong OrderDetail

### 2. Frontend Changes

#### pos.jsp (CẬP NHẬT)
- **Product loading**: Lấy từ database thay vì hardcode
- **Size selection modal**: Thay thế topping modal
- **Category mapping**: Map UI categories với database categories
- **Cart display**: Hiển thị size name trong cart items

## Workflow Mới

### 1. Load Products
```javascript
// Gọi API để lấy products từ database
fetch('api/products') -> {
  "success": true,
  "categories": {
    "Pizza": [
      {
        "id": 1,
        "name": "Hawaiian Pizza",
        "sizes": [
          {"sizeId": 1, "sizeCode": "S", "sizeName": "Small", "price": 120000},
          {"sizeId": 2, "sizeCode": "M", "sizeName": "Medium", "price": 160000},
          {"sizeId": 3, "sizeCode": "L", "sizeName": "Large", "price": 200000}
        ]
      }
    ]
  }
}
```

### 2. Product Selection
1. User click vào product
2. Hiển thị modal với các size options
3. User chọn size (required)
4. User chọn toppings (optional, chỉ cho Pizza)
5. Add to cart với ProductSizeID

### 3. Order Creation
```javascript
// JSON gửi đến server
{
  "customerName": "Customer Name",
  "items": [
    {
      "id": 1,                    // ProductID
      "sizeId": 2,               // ProductSizeID (MỚI)
      "name": "Hawaiian Pizza",
      "sizeName": "Medium",      // Size name (MỚI)
      "price": 160000,           // Price từ ProductSize
      "quantity": 1,
      "toppings": ["Extra Cheese"]
    }
  ],
  "total": 160000
}
```

### 4. Database Storage
```sql
-- OrderDetail sử dụng ProductSizeID
INSERT INTO OrderDetail (OrderID, ProductSizeID, Quantity, TotalPrice, SpecialInstructions, Status)
VALUES (1, 2, 1, 160000, 'Hawaiian Pizza (Medium) + Extra Cheese', 'Waiting');
```

## Category Mapping

| UI Category | Database Category | Description |
|-------------|------------------|-------------|
| PIZZA       | Pizza           | Các loại pizza với nhiều size |
| BEVERAGES   | Drink           | Đồ uống thường có fixed size |
| SIDES       | Topping         | Topping và sides |

## Size Codes

| Code | Name   | Description |
|------|--------|-------------|
| S    | Small  | Size nhỏ |
| M    | Medium | Size vừa |
| L    | Large  | Size lớn |
| F    | Fixed  | Size cố định (đồ uống, topping) |

## UI/UX Improvements

### Product Display
- Hiển thị price range nếu có nhiều size
- Hiển thị số lượng size available
- Responsive grid layout

### Size Selection Modal
- Clear size options với giá
- Toppings section chỉ hiện với Pizza
- Confirm button disabled until size selected

### Cart Display
- Hiển thị size name trong cart
- Updated item description format
- Proper price calculation per size

## Testing

### 1. Chạy Migration
```sql
-- Chạy JobProcessUpdateAndDelete.sql để cập nhật database
```

### 2. Test API
```bash
# Test ProductAPI
curl http://localhost:8080/Login/api/products
```

### 3. Test POS
```sql
-- Chạy TestPOSWithSizes.sql để test end-to-end
```

## Troubleshooting

### Products không load
- Kiểm tra ProductAPIServlet mapping
- Kiểm tra database connection
- Kiểm tra ProductSize data

### Size selection không hoạt động
- Kiểm tra JavaScript console errors
- Kiểm tra modal HTML structure
- Kiểm tra event handlers

### Order creation failed
- Kiểm tra POSServlet parsing logic
- Kiểm tra ProductSizeID trong JSON
- Kiểm tra OrderDetail table structure

## Files Changed

### Backend
- `controller/ProductAPIServlet.java` (NEW)
- `controller/POSServlet.java` (UPDATED)

### Frontend  
- `view/pos.jsp` (UPDATED)

### Database
- `JobProcessUpdateAndDelete.sql` (Migration)
- `TestPOSWithSizes.sql` (Testing)

## Next Steps

1. **Inventory Integration**: Kiểm tra available quantity per size
2. **Price Management**: Admin interface để quản lý giá theo size
3. **Promotions**: Discount theo size hoặc combo
4. **Analytics**: Report theo size popularity

## Notes

- Backward compatibility được maintain thông qua deprecated methods
- Fallback data nếu API call fails
- Error handling cho invalid ProductSizeID
- Responsive design cho mobile devices