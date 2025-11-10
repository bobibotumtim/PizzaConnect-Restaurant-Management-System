# 🍕 Tóm tắt: Sửa lỗi Topping không hiển thị trong POS

## Vấn đề
Khi bấm vào pizza trong POS, không hiển thị topping để chọn.

## Nguyên nhân
1. Frontend không gọi API để load toppings
2. ToppingDAO query sai cấu trúc database

## Đã sửa
✅ **pos.jsp**: Thêm API call `loadSampleToppings()` để load toppings từ server
✅ **ToppingDAO.java**: Cập nhật tất cả methods để query từ bảng Product với Category = 'Topping'

## Cách test

### 1. Chạy SQL script để thêm toppings
```bash
# Chạy file này trong SQL Server Management Studio
Login/Add_Toppings_To_Database.sql
```

Script này sẽ:
- Tạo Category 'Topping' (nếu chưa có)
- Thêm 15 toppings vào bảng Product
- Thêm ProductSize (Fixed) cho mỗi topping

### 2. Restart server
Restart Tomcat server để load code mới.

### 3. Test trong POS
1. Mở: http://localhost:8080/Login/pos
2. Chọn một bàn
3. Click vào một pizza
4. Modal sẽ hiển thị:
   - Chọn size (S/M/L)
   - **Chọn toppings** (tối đa 3 toppings)

### 4. Kiểm tra console (F12)
```
🔄 Loading toppings from database...
✅ Toppings loaded: [array of toppings]
```

## Toppings có sẵn (sau khi chạy script)
- Extra Cheese (15,000đ)
- Mushrooms (10,000đ)
- Black Olives (10,000đ)
- Green Peppers (8,000đ)
- Onions (8,000đ)
- Pepperoni (20,000đ)
- Italian Sausage (20,000đ)
- Bacon (25,000đ)
- Ham (18,000đ)
- Pineapple (12,000đ)
- Tomatoes (8,000đ)
- Jalapeños (10,000đ)
- Spinach (10,000đ)
- Garlic (8,000đ)
- Basil (8,000đ)

## Nếu vẫn không thấy toppings

### Kiểm tra database
```sql
-- Kiểm tra Category Topping
SELECT * FROM Category WHERE CategoryName = 'Topping';

-- Kiểm tra toppings
SELECT p.ProductName, ps.ProductSizeID, ps.Price
FROM Product p
INNER JOIN ProductSize ps ON p.ProductID = ps.ProductID
INNER JOIN Category c ON p.CategoryID = c.CategoryID
WHERE c.CategoryName = 'Topping' AND p.IsAvailable = 1;
```

### Kiểm tra API
Mở browser console và gọi:
```javascript
fetch('pos?action=getToppings')
  .then(r => r.json())
  .then(d => console.log(d));
```

Kết quả mong đợi:
```json
{
  "success": true,
  "toppings": [
    {"toppingID": 6, "toppingName": "Extra Cheese", "price": 15000},
    ...
  ]
}
```

## Files đã thay đổi
- ✅ `Login/web/view/pos.jsp` - Thêm API call load toppings
- ✅ `Login/src/java/dao/ToppingDAO.java` - Sửa query để dùng Product + Category
- ✅ `Login/Add_Toppings_To_Database.sql` - Script thêm toppings vào DB
- ✅ `Login/TOPPING_SETUP_GUIDE.md` - Hướng dẫn chi tiết
