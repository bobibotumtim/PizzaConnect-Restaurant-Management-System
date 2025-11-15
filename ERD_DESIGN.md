# Entity Relationship Diagram (ERD) - Pizza Restaurant Management System

## Visual ERD Diagram

```
                    ┌──────────────┐
                    │   Category   │
                    ├──────────────┤
                    │ CategoryID   │──────┐
                    │ CategoryName │      │
                    │ Description  │      │
                    │ IsDeleted    │      │
                    └──────────────┘      │
                                          │ 1:N
                    ┌──────────────┐      │
                    │ ProductSize  │      │
                    ├──────────────┤      │
                    │ProductSizeID │◄──┐  │
                    │ ProductID    │───┼──┤
                    │ SizeCode     │   │  │
                    │ SizeName     │   │  │
                    │ Price        │   │  │
                    │ IsDeleted    │   │  │
                    └──────┬───────┘   │  │
                           │           │  │
                           │ N:1       │  │
                           │           │  │
                    ┌──────▼───────┐   │  │
                    │   Product    │   │  │
                    ├──────────────┤   │  │
                    │  ProductID   │───┘  │
                    │ ProductName  │◄─────┘
                    │ Description  │
                    │ CategoryID   │
                    │  ImageURL    │
                    │ IsAvailable  │
                    └──────┬───────┘
                           │
                           │ N:M (via ProductIngredient)
                           │
                    ┌──────▼───────┐
                    │  Inventory   │
                    ├──────────────┤
                    │ InventoryID  │
                    │  ItemName    │
                    │  Quantity    │
                    │    Unit      │
                    │   Status     │
                    │LowThreshold  │
                    │CriticalThres │
                    │ LastUpdated  │
                    └──────────────┘


┌──────────────┐                    ┌──────────────┐
│   Discount   │                    │    User      │
├──────────────┤                    ├──────────────┤
│ DiscountID   │◄──┐                │   UserID     │◄────────┐
│ Description  │   │                │    Name      │         │
│DiscountType │   │                │  Password    │         │
│    Value     │   │                │    Role      │         │
│ MaxDiscount  │   │                │   Email      │         │
│MinOrderTotal │   │                │   Phone      │         │
│  StartDate   │   │                │ DateOfBirth  │         │
│   EndDate    │   │                │   Gender     │         │
│  IsActive    │   │                │  IsActive    │         │
└──────────────┘   │                └──────┬───────┘         │
                   │                       │                 │
                   │                       │ 1:1             │
                   │                       │                 │
                   │                ┌──────▼───────┐         │
                   │                │  Employee    │         │
                   │                ├──────────────┤         │
                   │                │ EmployeeID   │         │
                   │                │   UserID     │         │
                   │                │    Role      │         │
                   │                └──────┬───────┘         │
                   │                       │                 │
                   │                       │ 1:N             │
                   │                       │                 │
                   │                ┌──────▼───────┐         │
                   │                │  Customer    │         │
                   │                ├──────────────┤         │
                   │                │ CustomerID   │         │
                   │                │   UserID     │─────────┘
                   │                │ LoyaltyPoint │
                   │                │LastEarnedDate│
                   │                └──────┬───────┘
                   │                       │
                   │                       │ 1:N
                   │                       │
                   │ N:M          ┌────────▼─────────┐
                   │ (via         │     Order        │
                   │ OrderDiscount│──────────────────┤
                   └──────────────┤    OrderID       │
                                  │  CustomerID      │
                                  │  EmployeeID      │◄────────┐
                                  │   TableID        │◄──┐     │
                                  │  OrderDate       │   │     │
                                  │   Status         │   │     │
                                  │ PaymentStatus    │   │     │
                                  │  TotalPrice      │   │     │
                                  │     Note         │   │     │
                                  └────────┬─────────┘   │     │
                                           │             │     │
                                           │ 1:N         │     │
                                           │             │     │
                                  ┌────────▼─────────┐   │     │
                                  │  OrderDetail     │   │     │
                                  ├──────────────────┤   │     │
                                  │ OrderDetailID    │   │     │
                                  │    OrderID       │   │     │
                                  │ ProductSizeID    │   │     │
                                  │   Quantity       │   │     │
                                  │  TotalPrice      │   │     │
                                  │SpecialInstruc    │   │     │
                                  │  EmployeeID      │───┘     │
                                  │    Status        │         │
                                  │  StartTime       │         │
                                  │   EndTime        │         │
                                  └────────┬─────────┘         │
                                           │                   │
                                           │ 1:N               │
                                           │                   │
                                  ┌────────▼─────────┐         │
                                  │OrderDetailTopping│         │
                                  ├──────────────────┤         │
                                  │OrderDetailToppingID        │
                                  │ OrderDetailID    │         │
                                  │ ProductSizeID    │         │
                                  │ ProductPrice     │         │
                                  └──────────────────┘         │
                                                               │
                                                               │
┌──────────────┐                                              │
│    Table     │                                              │
├──────────────┤                                              │
│   TableID    │──────────────────────────────────────────────┘
│ TableNumber  │
│  Capacity    │
│   Status     │
│  IsActive    │
│  IsLocked    │
│ LockedReason │
│  LockedBy    │
│  LockedAt    │
└──────────────┘


┌──────────────┐              ┌──────────────┐
│   Payment    │              │  Feedback    │
├──────────────┤              ├──────────────┤
│  PaymentID   │              │ FeedbackID   │
│   OrderID    │◄─────┐       │ CustomerID   │
│   Amount     │      │       │  OrderID     │
│PaymentStatus │      │       │  ProductID   │
│ PaymentDate  │      │       │   Rating     │
│  QRCodeURL   │      │       │FeedbackDate  │
└──────────────┘      │       └──────────────┘
                      │
                      │ 1:1
                      │
               ┌──────┴───────┐
               │    Order     │
               └──────────────┘


┌──────────────┐              ┌──────────────┐
│PasswordTokens│              │DeletionQueue │
├──────────────┤              ├──────────────┤
│    Token     │              │   QueueID    │
│   UserID     │              │ EntityType   │
│NewPasswordHash              │  EntityID    │
│  ExpiresAt   │              │ScheduledDel  │
│     Used     │              └──────────────┘
└──────────────┘
```

## Entities và Attributes

### 1. **User** (Người dùng)
- `UserID` (PK) - INT IDENTITY(1,1)
- `Name` - NVARCHAR(100), NOT NULL
- `Password` - NVARCHAR(60), NOT NULL
- `Role` - INT, NOT NULL CHECK (1=Admin, 2=Employee, 3=Customer)
- `Email` - NVARCHAR(100), UNIQUE
- `Phone` - NVARCHAR(20), UNIQUE
- `DateOfBirth` - DATE
- `Gender` - NVARCHAR(10) CHECK (Male, Female, Other)
- `IsActive` - BIT, DEFAULT 1

### 2. **Employee** (Nhân viên)
- `EmployeeID` (PK) - INT IDENTITY(1,1)
- `UserID` (FK) - INT, NOT NULL, UNIQUE
- `Role` - NVARCHAR(50), NOT NULL CHECK (Manager, Waiter, Chef)

### 3. **Customer** (Khách hàng)
- `CustomerID` (PK) - INT IDENTITY(1,1)
- `UserID` (FK) - INT, NOT NULL, UNIQUE
- `LoyaltyPoint` - INT, DEFAULT 0
- `LastEarnedDate` - DATETIME

### 4. **Category** (Danh mục sản phẩm)
- `CategoryID` (PK) - INT IDENTITY(1,1)
- `CategoryName` - NVARCHAR(100), NOT NULL
- `Description` - NVARCHAR(255)
- `IsDeleted` - BIT, DEFAULT 0

### 5. **Product** (Sản phẩm)
- `ProductID` (PK) - INT IDENTITY(1,1)
- `ProductName` - NVARCHAR(100), NOT NULL
- `Description` - NVARCHAR(255)
- `CategoryID` (FK) - INT, NOT NULL
- `ImageURL` - NVARCHAR(255)
- `IsAvailable` - BIT, DEFAULT 1

### 6. **ProductSize** (Kích thước & Giá sản phẩm)
- `ProductSizeID` (PK) - INT IDENTITY(1,1)
- `ProductID` (FK) - INT, NOT NULL
- `SizeCode` - CHAR(1) CHECK (S, M, L, F)
- `SizeName` - NVARCHAR(50)
- `Price` - DECIMAL(10,2), NOT NULL
- `IsDeleted` - BIT, DEFAULT 0

### 7. **Inventory** (Kho nguyên liệu)
- `InventoryID` (PK) - INT IDENTITY(1,1)
- `ItemName` - NVARCHAR(100), NOT NULL
- `Quantity` - DECIMAL(10,2), DEFAULT 0
- `Unit` - NVARCHAR(50)
- `Status` - NVARCHAR(20), DEFAULT 'Active' CHECK (Active, Inactive)
- `LowThreshold` - DECIMAL(10,2), DEFAULT 5
- `CriticalThreshold` - DECIMAL(10,2), DEFAULT 2
- `LastUpdated` - DATETIME, DEFAULT GETDATE()

### 8. **ProductIngredient** (Nguyên liệu cho sản phẩm)
- `ProductSizeID` (PK, FK) - INT, NOT NULL
- `InventoryID` (PK, FK) - INT, NOT NULL
- `QuantityNeeded` - DECIMAL(10,2), NOT NULL
- `Unit` - NVARCHAR(50)

### 9. **Table** (Bàn ăn)
- `TableID` (PK) - INT IDENTITY(1,1)
- `TableNumber` - NVARCHAR(10), NOT NULL, UNIQUE
- `Capacity` - INT, NOT NULL CHECK (> 0)
- `Status` - NVARCHAR(20), DEFAULT 'available' CHECK (available, unavailable)
- `IsActive` - BIT, DEFAULT 1
- `IsLocked` - BIT, DEFAULT 0
- `LockedReason` - NVARCHAR(255)
- `LockedBy` (FK) - INT (Employee)
- `LockedAt` - DATETIME

### 10. **Order** (Đơn hàng)
- `OrderID` (PK) - INT IDENTITY(1,1)
- `CustomerID` (FK) - INT
- `EmployeeID` (FK) - INT
- `TableID` (FK) - INT
- `OrderDate` - DATETIME, DEFAULT GETDATE()
- `Status` - INT, DEFAULT 0 CHECK (0=Waiting, 1=Ready, 2=Dining, 3=Completed, 4=Cancelled)
- `PaymentStatus` - NVARCHAR(50) CHECK (Unpaid, Paid)
- `TotalPrice` - DECIMAL(10,2), DEFAULT 0
- `Note` - NVARCHAR(255)

### 11. **OrderDetail** (Chi tiết đơn hàng)
- `OrderDetailID` (PK) - INT IDENTITY(1,1)
- `OrderID` (FK) - INT, NOT NULL
- `ProductSizeID` (FK) - INT, NOT NULL
- `Quantity` - INT, NOT NULL
- `TotalPrice` - DECIMAL(10,2)
- `SpecialInstructions` - NVARCHAR(255)
- `EmployeeID` (FK) - INT (Chef)
- `Status` - NVARCHAR(50), DEFAULT 'Waiting'
- `StartTime` - DATETIME
- `EndTime` - DATETIME

### 12. **OrderDetailTopping** (Topping cho món ăn)
- `OrderDetailToppingID` (PK) - INT IDENTITY(1,1)
- `OrderDetailID` (FK) - INT, NOT NULL
- `ProductSizeID` (FK) - INT, NOT NULL (Topping Product)
- `ProductPrice` - DECIMAL(10,2), NOT NULL

### 13. **Discount** (Giảm giá)
- `DiscountID` (PK) - INT IDENTITY(1,1)
- `Description` - NVARCHAR(255)
- `DiscountType` - NVARCHAR(50)
- `Value` - DECIMAL(10,2)
- `MaxDiscount` - DECIMAL(10,2)
- `MinOrderTotal` - DECIMAL(10,2), DEFAULT 0
- `StartDate` - DATE
- `EndDate` - DATE
- `IsActive` - BIT, DEFAULT 1

### 14. **OrderDiscount** (Giảm giá áp dụng cho đơn hàng)
- `OrderID` (PK, FK) - INT
- `DiscountID` (PK, FK) - INT
- `Amount` - DECIMAL(10,2), NOT NULL
- `AppliedDate` - DATETIME, DEFAULT GETDATE()

### 15. **Payment** (Thanh toán)
- `PaymentID` (PK) - INT IDENTITY(1,1)
- `OrderID` (FK) - INT, NOT NULL
- `Amount` - DECIMAL(10,2), NOT NULL
- `PaymentStatus` - NVARCHAR(50), DEFAULT 'Pending' CHECK (Pending, Completed, Failed)
- `PaymentDate` - DATETIME, DEFAULT GETDATE()
- `QRCodeURL` - NVARCHAR(500)

### 16. **Feedback** (Đánh giá)
- `FeedbackID` (PK) - INT IDENTITY(1,1)
- `CustomerID` (FK) - INT, NOT NULL
- `OrderID` (FK) - INT, NOT NULL
- `ProductID` (FK) - INT, NOT NULL
- `Rating` - INT, NOT NULL CHECK (1-5)
- `FeedbackDate` - DATETIME, DEFAULT GETDATE()

### 17. **PasswordTokens** (Token đổi mật khẩu)
- `Token` (PK) - NVARCHAR(20)
- `UserID` (FK) - INT, NOT NULL
- `NewPasswordHash` - NVARCHAR(255), NOT NULL
- `ExpiresAt` - DATETIME2, DEFAULT DATEADD(MINUTE, 5, SYSDATETIME())
- `Used` - BIT, DEFAULT 0

### 18. **DeletionQueue** (Hàng đợi xóa)
- `QueueID` (PK) - INT IDENTITY(1,1)
- `EntityType` - NVARCHAR(20), NOT NULL
- `EntityID` - INT, NOT NULL
- `ScheduledDeletion` - DATETIME, DEFAULT DATEADD(DAY, 1, CAST(GETDATE() AS DATE))

---

## Relationships (Quan hệ)

### 1. **User → Employee** (1:1)
- Một User có thể là một Employee
- Một Employee tương ứng với một User

### 2. **User → Customer** (1:1)
- Một User có thể là một Customer
- Một Customer tương ứng với một User

### 3. **Category → Product** (1:N)
- Một Category có nhiều Product
- Một Product thuộc một Category

### 4. **Product → ProductSize** (1:N)
- Một Product có nhiều ProductSize (S, M, L, F)
- Một ProductSize thuộc một Product

### 5. **ProductSize ↔ Inventory** (N:M via ProductIngredient)
- Một ProductSize cần nhiều Inventory items
- Một Inventory item được dùng cho nhiều ProductSize

### 6. **Customer → Order** (1:N)
- Một Customer có nhiều Order
- Một Order thuộc một Customer

### 7. **Employee → Order** (1:N)
- Một Employee (Waiter) xử lý nhiều Order
- Một Order được xử lý bởi một Employee

### 8. **Table → Order** (1:N)
- Một Table có nhiều Order
- Một Order có thể gắn với một Table (optional)

### 9. **Employee → Table** (1:N - Lock)
- Một Employee có thể lock nhiều Table
- Một Table được lock bởi một Employee (optional)

### 10. **Order → OrderDetail** (1:N)
- Một Order có nhiều OrderDetail
- Một OrderDetail thuộc một Order

### 11. **ProductSize → OrderDetail** (1:N)
- Một ProductSize có thể có trong nhiều OrderDetail
- Một OrderDetail chứa một ProductSize

### 12. **Employee → OrderDetail** (1:N)
- Một Employee (Chef) chuẩn bị nhiều OrderDetail
- Một OrderDetail được chuẩn bị bởi một Employee (Chef)

### 13. **OrderDetail → OrderDetailTopping** (1:N)
- Một OrderDetail có nhiều Topping
- Một Topping thuộc một OrderDetail

### 14. **ProductSize → OrderDetailTopping** (1:N)
- Một ProductSize (Topping) có thể được dùng cho nhiều OrderDetailTopping
- Một OrderDetailTopping chứa một ProductSize (Topping)

### 15. **Order ↔ Discount** (N:M via OrderDiscount)
- Một Order có thể áp dụng nhiều Discount
- Một Discount có thể được áp dụng cho nhiều Order

### 16. **Order → Payment** (1:1)
- Một Order có một Payment
- Một Payment thuộc một Order

### 17. **Customer → Feedback** (1:N)
- Một Customer có nhiều Feedback
- Một Feedback thuộc một Customer

### 18. **Order → Feedback** (1:N)
- Một Order có nhiều Feedback
- Một Feedback thuộc một Order

### 19. **Product → Feedback** (1:N)
- Một Product có nhiều Feedback
- Một Feedback đánh giá một Product

### 20. **User → PasswordTokens** (1:N)
- Một User có nhiều PasswordTokens
- Một PasswordToken thuộc một User

---

## Detailed Relationships Flow

```
USER SYSTEM:
User (1) ──→ (1) Employee
User (1) ──→ (1) Customer
User (1) ──→ (N) PasswordTokens

PRODUCT SYSTEM:
Category (1) ──→ (N) Product
Product (1) ──→ (N) ProductSize
ProductSize (N) ←→ (M) Inventory [via ProductIngredient]

ORDER SYSTEM:
Customer (1) ──→ (N) Order
Employee (1) ──→ (N) Order [as Waiter]
Table (1) ──→ (N) Order
Order (1) ──→ (N) OrderDetail
Order (1) ──→ (1) Payment
Order (N) ←→ (M) Discount [via OrderDiscount]

ORDER DETAIL SYSTEM:
ProductSize (1) ──→ (N) OrderDetail
Employee (1) ──→ (N) OrderDetail [as Chef]
OrderDetail (1) ──→ (N) OrderDetailTopping
ProductSize (1) ──→ (N) OrderDetailTopping [as Topping]

FEEDBACK SYSTEM:
Customer (1) ──→ (N) Feedback
Order (1) ──→ (N) Feedback
Product (1) ──→ (N) Feedback

TABLE LOCK SYSTEM:
Employee (1) ──→ (N) Table [LockedBy]
```

---

## Business Rules

1. **User & Authentication**
   - User có 3 loại Role: 1=Admin, 2=Employee, 3=Customer
   - Employee có 3 vai trò: Manager, Waiter, Chef
   - Password được hash bằng BCrypt
   - PasswordTokens hết hạn sau 5 phút

2. **Product Management**
   - Mỗi Product phải thuộc một Category
   - Product có nhiều ProductSize với giá khác nhau (S, M, L, F)
   - Category có 4 loại: Pizza, Drink, Topping, SideDish
   - Topping và SideDish cũng là Product
   - Soft delete: IsDeleted = 1 (không xóa thật)

3. **Inventory Management**
   - Mỗi ProductSize cần nhiều Inventory items (via ProductIngredient)
   - Inventory có 3 trạng thái: OK, LOW, CRITICAL, INACTIVE
   - LowThreshold mặc định = 5, CriticalThreshold = 2
   - View v_InventoryMonitor giám sát tồn kho

4. **Order Processing**
   - Order có 5 trạng thái: 0=Waiting, 1=Ready, 2=Dining, 3=Completed, 4=Cancelled
   - PaymentStatus: Unpaid, Paid
   - Order phải có ít nhất một OrderDetail
   - OrderDetail có thể có nhiều OrderDetailTopping
   - Chef được gán cho từng OrderDetail để nấu

5. **Table Management**
   - Table có 2 trạng thái: available, unavailable
   - Table có thể bị lock bởi Employee (IsLocked, LockedBy, LockedReason)
   - Soft delete: IsActive = 0

6. **Discount System**
   - Discount có nhiều loại: Percentage, Fixed, Loyalty
   - Một Order có thể áp dụng nhiều Discount (via OrderDiscount)
   - Discount có StartDate, EndDate, IsActive

7. **Payment & Feedback**
   - Mỗi Order có một Payment
   - PaymentStatus: Pending, Completed, Failed
   - Customer có thể Feedback cho Product trong Order
   - Rating từ 1-5 sao

8. **Loyalty Points**
   - Customer có LoyaltyPoint tích lũy
   - LastEarnedDate ghi nhận lần cuối tích điểm

9. **Deletion Queue**
   - Soft delete được schedule qua DeletionQueue
   - Xóa thật sau 1 ngày (via SQL Agent Job)
   - EntityType: Table, Discount

---

## Key Features

1. **View: v_ProductSizeAvailable**
   - Tính toán số lượng sản phẩm có thể làm dựa trên Inventory
   - Join: ProductSize → ProductIngredient → Inventory
   - Hiển thị AvailableQuantity cho mỗi ProductSize

2. **View: v_InventoryMonitor**
   - Giám sát tồn kho theo ngưỡng
   - StockLevel: OK, LOW, CRITICAL, INACTIVE
   - PercentOfLowLevel: % so với LowThreshold

3. **Stored Procedures**
   - `ScheduleDeletion`: Đưa entity vào hàng đợi xóa
   - `ProcessDeletionQueue`: Xử lý xóa theo lịch (chạy daily 00:01)

4. **SQL Agent Job**
   - Job: ProcessDeletionQueue_pizza_demo_DB_FinalModel_Combined
   - Schedule: Daily at 00:01
   - Soft delete → Hard delete sau 1 ngày

5. **Topping System**
   - Topping là Product thuộc Category "Topping"
   - OrderDetailTopping gắn Topping vào OrderDetail
   - ProductPrice lưu giá của Topping tại thời điểm order

6. **Chef Assignment**
   - Mỗi OrderDetail được gán cho một Chef (EmployeeID)
   - Chef theo dõi Status: Waiting → In Progress → Done
   - StartTime, EndTime ghi nhận thời gian nấu

---

## Database Information

- **Database Name**: `pizza_demo_DB_FinalModel_Combined`
- **DBMS**: Microsoft SQL Server
- **Character Set**: NVARCHAR (Unicode support)
- **Identity**: IDENTITY(1,1) cho Primary Keys
- **Constraints**: CHECK constraints cho enums và validation
- **Cascade**: ON DELETE CASCADE cho Payment, OrderDetailTopping
- **Soft Delete**: IsDeleted, IsActive flags

---

## Sample Data Summary

- **Users**: 9 users (1 Admin, 3 Employees, 3 Customers)
- **Employees**: 3 (1 Manager, 1 Waiter, 1 Chef)
- **Customers**: 3 with LoyaltyPoints
- **Categories**: 4 (Pizza, Drink, Topping, SideDish)
- **Products**: 6 (1 Pizza, 2 Drinks, 2 Toppings, 1 SideDish)
- **ProductSizes**: 8 sizes với giá khác nhau
- **Inventory**: 11 items với thresholds
- **Tables**: 12 tables (T01-T12)
- **Orders**: 23 orders (nhiều completed, một số active)
- **Discounts**: 3 types (Percentage, Fixed, Loyalty)
- **Payments**: Nhiều payments cho completed orders
- **Feedbacks**: Nhiều feedbacks từ customers

---

## Notes

- Sử dụng `BIT` cho boolean (IsActive, IsDeleted, IsLocked, Used)
- Sử dụng `DECIMAL(10,2)` cho tiền tệ
- Sử dụng `NVARCHAR` cho Unicode (tiếng Việt)
- CHECK constraints cho validation (Role, Status, Gender, etc.)
- UNIQUE constraints cho Email, Phone, TableNumber, Token
- DEFAULT values cho timestamps, status, quantities
- Foreign keys với proper naming (FK_TableName_ColumnName)
