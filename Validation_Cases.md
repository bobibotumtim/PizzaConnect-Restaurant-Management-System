# Các Trường Hợp Không Hợp Lệ - Validation Cases

## 1. MANAGE CATEGORY

### Add Category
**Trường hợp không hợp lệ:**
- **Tên category trùng lặp:** Tên category đã tồn tại trong hệ thống
- **Tên category chứa ký tự đặc biệt:** Chứa các ký tự không được phép như @, #, $, %, etc.

### Edit Category
**Trường hợp không hợp lệ:**
- **Category không tồn tại:** ID category không có trong hệ thống
- **Tên category trùng lặp:** Tên category mới trùng với category khác (trừ chính nó)

---

## 2. MANAGE PRODUCT

### Add Product
**Trường hợp không hợp lệ:**
- **Tên product trùng lặp:** Tên sản phẩm đã tồn tại trong hệ thống
- **Category không hợp lệ:** Category ID không tồn tại hoặc đã bị xóa
- **Giá sản phẩm không hợp lệ:** 
  - Giá âm (< 0)
  - Giá bằng 0 (nếu không cho phép)
  - Giá quá lớn (vượt giới hạn hệ thống)

### Edit Product
**Trường hợp không hợp lệ:**
- **Product không tồn tại:** ID sản phẩm không có trong hệ thống
- **Tên product trùng lặp:** Tên sản phẩm mới trùng với sản phẩm khác (trừ chính nó)
- **Category không hợp lệ:** Category ID không tồn tại
- **Giá sản phẩm không hợp lệ:** Giá âm hoặc không hợp lệ

---

## 3. PRODUCT SIZE MANAGEMENT

### Add Product Size
**Trường hợp không hợp lệ:**
- **Product không tồn tại:** Product ID không có trong hệ thống
- **Size trùng lặp:** Size đã tồn tại cho sản phẩm này
- **Giá size không hợp lệ:**
  - Giá âm (< 0)
  - Giá bằng 0 (nếu không cho phép)
  - Giá quá lớn

### Edit Product Size
**Trường hợp không hợp lệ:**
- **Size không tồn tại:** Size ID không có trong hệ thống
- **Size trùng lặp:** Size mới trùng với size khác của cùng sản phẩm (trừ chính nó)
- **Giá size không hợp lệ:** Giá âm hoặc không hợp lệ
- **Size đang được sử dụng:** Không thể xóa size đang có trong đơn hàng

---

## 4. PRODUCT-INGREDIENT RELATIONSHIP (Quản lý nguyên liệu sản phẩm)

### Add Ingredient to Product Size
**Trường hợp không hợp lệ:**
- **Product Size không tồn tại:** Product Size ID không hợp lệ
- **Inventory không tồn tại:** Inventory ID không hợp lệ hoặc hết hàng
- **Nguyên liệu đã tồn tại:** Nguyên liệu đã được thêm vào size sản phẩm này
- **Số lượng không hợp lệ:** Số lượng nguyên liệu âm hoặc bằng 0

### Edit Ingredient in Product Size
**Trường hợp không hợp lệ:**
- **Product Size không tồn tại:** Product Size ID không hợp lệ
- **Inventory không tồn tại:** Inventory ID không hợp lệ hoặc hết hàng
- **Nguyên liệu đã tồn tại:** Nguyên liệu mới trùng với nguyên liệu khác trong cùng size (trừ chính nó)
- **Số lượng không hợp lệ:** Số lượng nguyên liệu âm hoặc bằng 0

---

## 6. VALIDATION MESSAGES (Thông báo lỗi)

```javascript
const VALIDATION_MESSAGES = {
  // Category
  CATEGORY_NAME_DUPLICATE: "Category name already exists",
  CATEGORY_NOT_FOUND: "Category not found",
  
  // Product
  PRODUCT_NAME_DUPLICATE: "Product name already exists",
  PRODUCT_PRICE_INVALID: "Product price cannot be negative",
  PRODUCT_CATEGORY_INVALID: "Invalid category",
  PRODUCT_NOT_FOUND: "Product not found",
  
  // Product Size
  SIZE_DUPLICATE: "Size already exists for this product",
  SIZE_PRICE_INVALID: "Size price cannot be negative",
  SIZE_NOT_FOUND: "Size not found",
  SIZE_IN_USE: "Cannot delete size that is being used",
  
  // Product Ingredient
  INGREDIENT_DUPLICATE: "Ingredient already added to this product",
  INGREDIENT_QUANTITY_INVALID: "Ingredient quantity must be greater than 0",
  INGREDIENT_NOT_FOUND: "Ingredient not found",
  PRODUCT_INGREDIENT_INVALID: "Invalid ingredient information"
};
```