# 🧪 JUnit Testing trong VSCode - Hướng dẫn chi tiết

## 🚀 **Setup VSCode cho JUnit Testing**

### **1. Cài đặt Extensions:**
```
- Extension Pack for Java (Microsoft)
- Test Runner for Java (Microsoft) 
- JUnit 5 (nếu cần)
- Maven for Java (Microsoft)
```

### **2. Cấu trúc Project:**
```
PizzaConnect-Restaurant-Management-System/
├── pom.xml                           # Maven configuration
├── .vscode/
│   └── settings.json                 # VSCode settings
└── Login_func_v1/Login/src/
    ├── main/java/                    # Source code
    └── test/java/                    # Test code
        ├── dao/
        │   ├── OrderDAOTest.java
        │   └── ProductDAOTest.java
        └── models/
            ├── OrderTest.java
            └── OrderdetailTest.java
```

## 🎯 **Cách chạy Tests trong VSCode**

### **Method 1: Test Explorer**
1. **Mở Test Explorer**: `Ctrl+Shift+P` → "Test: Focus on Test Explorer View"
2. **Chạy tất cả tests**: Click "Run All Tests" button
3. **Chạy test cụ thể**: Click vào test class hoặc method

### **Method 2: Code Lens**
1. **Mở file test** (ví dụ: `OrderTest.java`)
2. **Click "Run Test"** hoặc "Debug Test" bên cạnh class/method
3. **Xem kết quả** trong Test Explorer

### **Method 3: Command Palette**
1. **Mở Command Palette**: `Ctrl+Shift+P`
2. **Gõ**: "Test: Run All Tests" hoặc "Test: Run Test in Current File"
3. **Enter** để chạy

## 📊 **Test Cases đã tạo**

### **1. OrderDAOTest.java**
```java
✅ testGetAllOrders() - Lấy tất cả đơn hàng
✅ testCountAllOrders() - Đếm số đơn hàng
✅ testGetOrdersByStatus() - Lấy đơn hàng theo trạng thái
✅ testUpdateOrderStatus() - Cập nhật trạng thái
✅ testUpdatePaymentStatus() - Cập nhật thanh toán
✅ testGetOrderDetailsByOrderId() - Lấy chi tiết đơn hàng
✅ testCreateOrder() - Tạo đơn hàng mới
```

### **2. ProductDAOTest.java**
```java
✅ testGetAllProducts() - Lấy tất cả sản phẩm
✅ testGetProductById() - Lấy sản phẩm theo ID
✅ testGetProductsByCategory() - Lấy sản phẩm theo danh mục
✅ testGetAllCategories() - Lấy tất cả danh mục
✅ testAddProduct() - Thêm sản phẩm mới
✅ testUpdateProduct() - Cập nhật sản phẩm
✅ testDeleteProduct() - Xóa sản phẩm
```

### **3. OrderTest.java**
```java
✅ testOrderCreationWithAllParameters() - Tạo order với đầy đủ tham số
✅ testOrderCreationWithMinimalParameters() - Tạo order với tham số tối thiểu
✅ testGetStatusText() - Kiểm tra text trạng thái
✅ testSettersAndGetters() - Test getter/setter
✅ testToString() - Test toString method
✅ testNullValues() - Test xử lý null values
```

### **4. OrderdetailTest.java**
```java
✅ testOrderdetailCreationWithAllParameters() - Tạo orderdetail đầy đủ
✅ testOrderdetailCreationWithMinimalParameters() - Tạo orderdetail tối thiểu
✅ testAutoCalculateTotalPriceOnQuantityChange() - Auto tính tổng tiền
✅ testAutoCalculateTotalPriceOnUnitPriceChange() - Auto tính tổng tiền
✅ testSettersAndGetters() - Test getter/setter
✅ testToString() - Test toString method
✅ testNullSpecialInstructions() - Test null instructions
✅ testZeroQuantity() - Test số lượng = 0
✅ testNegativeValues() - Test giá trị âm
```

## 🔧 **Debug Tests trong VSCode**

### **1. Debug Single Test:**
1. **Click "Debug Test"** bên cạnh test method
2. **Set breakpoints** trong code
3. **Step through** code để debug

### **2. Debug All Tests:**
1. **Mở Test Explorer**
2. **Right-click** vào test class
3. **Select "Debug Test"**

## 📈 **Test Results & Coverage**

### **Xem kết quả test:**
- **Test Explorer** hiển thị kết quả real-time
- **Green checkmark** = Pass
- **Red X** = Fail
- **Yellow circle** = Skipped

### **Test Coverage:**
```bash
# Chạy với coverage report
mvn test jacoco:report
```

## 🐛 **Troubleshooting**

### **Lỗi thường gặp:**

#### **1. "No tests found"**
```bash
# Kiểm tra cấu trúc thư mục
src/test/java/dao/OrderDAOTest.java
```

#### **2. "Class not found"**
```bash
# Rebuild project
Ctrl+Shift+P → "Java: Rebuild Workspace"
```

#### **3. "Database connection failed"**
```java
// Sử dụng mock hoặc test database
@Mock
private DBContext dbContext;
```

## 🎯 **Best Practices**

### **1. Test Naming:**
```java
@DisplayName("Should create order with valid data")
void testCreateOrderWithValidData() {
    // Given
    // When  
    // Then
}
```

### **2. Test Structure:**
```java
@Test
void testMethod() {
    // Given - Setup test data
    // When - Execute the method
    // Then - Assert the results
}
```

### **3. Assertions:**
```java
assertNotNull(result, "Result should not be null");
assertEquals(expected, actual, "Values should match");
assertTrue(condition, "Condition should be true");
```

## 🚀 **Chạy Tests ngay bây giờ:**

1. **Mở VSCode** trong thư mục project
2. **Mở Test Explorer** (`Ctrl+Shift+P` → "Test: Focus on Test Explorer View")
3. **Click "Run All Tests"**
4. **Xem kết quả** trong Test Explorer

## 📋 **Test Commands:**

```bash
# Chạy tất cả tests
mvn test

# Chạy test cụ thể
mvn test -Dtest=OrderTest

# Chạy với verbose output
mvn test -X

# Chạy với coverage
mvn test jacoco:report
```

**Bây giờ bạn có thể test JUnit trong VSCode một cách dễ dàng!** 🧪✨

