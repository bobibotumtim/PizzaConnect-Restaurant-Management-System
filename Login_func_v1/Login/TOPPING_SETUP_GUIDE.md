# 🍕 Hướng dẫn thiết lập Topping cho POS

## Vấn đề đã sửa
Khi bấm vào pizza trong POS, không hiển thị topping để chọn.

## Nguyên nhân
- Frontend không gọi API để load toppings từ database
- ToppingDAO đang tìm kiếm sai cấu trúc bảng

## Đã sửa
✅ Thêm API call `loadSampleToppings()` trong pos.jsp để load toppings từ server
✅ Cập nhật ToppingDAO để query từ bảng Product với Category = 'Topping'

## Cấu trúc Database
Database của bạn sử dụng cấu trúc:
- **Product**: Chứa tất cả sản phẩm (Pizza, Drink, Topping, Side Dishes, Dessert)
- **Category**: Phân loại sản phẩm
- **ProductSize**: Kích thước và giá của từng sản phẩm
- **OrderDetailTopping**: Lưu toppings được chọn cho mỗi order detail (sử dụng ProductSizeID)

Toppings là các Product có `CategoryName = 'Topping'` với `SizeCode = 'F'` (Fixed size).

## Cách kiểm tra

### Bước 1: Kiểm tra Category 'Topping' tồn tại
```sql
SELECT * FROM Category WHERE CategoryName = 'Topping';
```

Nếu không có, tạo category:
```sql
INSERT INTO Category (CategoryName, IsDeleted) VALUES ('Topping', 0);
```

### Bước 2: Kiểm tra dữ liệu topping
```sql
SELECT p.ProductID, p.ProductName, ps.ProductSizeID, ps.Price, p.IsAvailable
FROM Product p
INNER JOIN ProductSize ps ON p.ProductID = ps.ProductID
INNER JOIN Category c ON p.CategoryID = c.CategoryID
WHERE c.CategoryName = 'Topping' AND ps.SizeCode = 'F';
```

### Bước 3: Thêm toppings mẫu (nếu chưa có)
```sql
-- Lấy CategoryID của Topping
DECLARE @ToppingCategoryID INT;
SELECT @ToppingCategoryID = CategoryID FROM Category WHERE CategoryName = 'Topping';

-- Thêm toppings
INSERT INTO Product (ProductName, Description, CategoryID, ImageURL, IsAvailable) VALUES
('Extra Cheese', 'Topping - Extra Cheese', @ToppingCategoryID, 'extra_cheese.jpg', 1),
('Mushrooms', 'Topping - Mushrooms', @ToppingCategoryID, 'mushrooms.jpg', 1),
('Pepperoni', 'Topping - Pepperoni', @ToppingCategoryID, 'pepperoni.jpg', 1),
('Sausage', 'Topping - Sausage', @ToppingCategoryID, 'sausage.jpg', 1),
('Bacon', 'Topping - Bacon', @ToppingCategoryID, 'bacon.jpg', 1);

-- Thêm ProductSize cho mỗi topping (Fixed size)
INSERT INTO ProductSize (ProductID, SizeCode, SizeName, Price, IsDeleted)
SELECT ProductID, 'F', 'Fixed', 
    CASE ProductName
        WHEN 'Extra Cheese' THEN 15000
        WHEN 'Mushrooms' THEN 10000
        WHEN 'Pepperoni' THEN 20000
        WHEN 'Sausage' THEN 20000
        WHEN 'Bacon' THEN 25000
    END,
    0
FROM Product p
INNER JOIN Category c ON p.CategoryID = c.CategoryID
WHERE c.CategoryName = 'Topping' 
AND NOT EXISTS (SELECT 1 FROM ProductSize WHERE ProductID = p.ProductID);
```

### Bước 4: Restart server và test
1. Restart Tomcat server
2. Mở POS: http://localhost:8080/Login/pos
3. Chọn một bàn
4. Click vào một pizza (ví dụ: Hawaiian Pizza)
5. Modal sẽ hiển thị:
   - Chọn size (Small/Medium/Large)
   - Chọn toppings (tối đa 3 toppings)

### Bước 5: Kiểm tra console
Mở Developer Tools (F12) và xem Console:
```
🔄 Loading toppings from database...
✅ Toppings loaded: [array of toppings]
```

## Cấu trúc API

### GET /pos?action=getToppings
Trả về danh sách toppings có sẵn (ProductSizeID của các Product có Category = 'Topping'):
```json
{
  "success": true,
  "toppings": [
    {
      "toppingID": 6,
      "toppingName": "Extra Cheese",
      "price": 15000
    },
    {
      "toppingID": 7,
      "toppingName": "Sausage",
      "price": 20000
    }
  ]
}
```

**Lưu ý**: `toppingID` thực chất là `ProductSizeID` trong database.

## Troubleshooting

### Không thấy toppings trong modal
1. Kiểm tra console có lỗi không (F12)
2. Kiểm tra Category 'Topping' có tồn tại không
3. Kiểm tra dữ liệu toppings:
```sql
SELECT p.ProductName, ps.ProductSizeID, ps.Price
FROM Product p
INNER JOIN ProductSize ps ON p.ProductID = ps.ProductID
INNER JOIN Category c ON p.CategoryID = c.CategoryID
WHERE c.CategoryName = 'Topping' AND p.IsAvailable = 1;
```

### Lỗi "No toppings found"
Thêm toppings vào database bằng SQL script ở Bước 3.

### Toppings không lưu vào order
Kiểm tra bảng `OrderDetailTopping` có tồn tại không:
```sql
SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'OrderDetailTopping';
```

Nếu chưa có, tạo bảng:
```sql
CREATE TABLE OrderDetailTopping (
    OrderDetailToppingID INT IDENTITY(1,1) PRIMARY KEY,
    OrderDetailID INT NOT NULL,
    ProductSizeID INT NOT NULL,
    ProductPrice DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (OrderDetailID) REFERENCES OrderDetail(OrderDetailID) ON DELETE CASCADE,
    FOREIGN KEY (ProductSizeID) REFERENCES ProductSize(ProductSizeID)
);
```
