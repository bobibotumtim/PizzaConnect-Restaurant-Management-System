-- ===============================
-- 🛠️ TẠO VÀ SỬ DỤNG DATABASE (Phiên bản Kết hợp & Đã Tinh chỉnh)
-- ===============================

-- DROP DATABASE pizza_demo_DB_FinalModel_Combined;
-- GO

CREATE DATABASE pizza_demo_DB_FinalModel_Combined;
GO

USE pizza_demo_DB_FinalModel_Combined;
GO

-- ===============================
-- 👥 USER SYSTEM
-- ===============================

CREATE TABLE [User] (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Password NVARCHAR(60) NOT NULL,
    Role INT NOT NULL CHECK (Role IN (1, 2, 3)),  -- 1=Admin, 2=Employee, 3=Customer
    Email NVARCHAR(100) UNIQUE,
    Phone NVARCHAR(20) UNIQUE,
    [DateOfBirth] DATE NULL,
    Gender NVARCHAR(10) CHECK (Gender IN ('Male', 'Female', 'Other')),
    IsActive BIT DEFAULT 1
);
GO

CREATE TABLE Employee (
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL UNIQUE,
    -- Loại bỏ vai trò 'Cashier'
    Role NVARCHAR(50) NOT NULL CHECK (Role IN ('Manager', 'Waiter', 'Chef')),
    -- Thêm các Specialization mới cho Chef
    Specialization NVARCHAR(50) NULL CHECK (Specialization IN ('Pizza', 'Drinks', 'SideDishes', 'General', NULL)),
    FOREIGN KEY (UserID) REFERENCES [User](UserID)
);
GO

CREATE TABLE Customer (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL UNIQUE,
    LoyaltyPoint INT DEFAULT 0, 
    LastEarnedDate DATETIME NULL, 
    FOREIGN KEY (UserID) REFERENCES [User](UserID)
);
GO

-- ===============================
-- 🍕 CATEGORY + PRODUCT STRUCTURE
-- ===============================

CREATE TABLE Category (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(255),
    IsDeleted BIT NOT NULL DEFAULT 0
);
GO

CREATE TABLE Product (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    ProductName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(255),
    CategoryID INT NOT NULL,
    ImageURL NVARCHAR(255),
    IsAvailable BIT DEFAULT 1,
    FOREIGN KEY (CategoryID) REFERENCES Category(CategoryID)
);
GO

CREATE TABLE ProductSize (
    ProductSizeID INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT NOT NULL,
    SizeCode CHAR(1) CHECK (SizeCode IN ('S','M','L','F')),
    SizeName NVARCHAR(50),
    Price DECIMAL(10,2) NOT NULL,
	IsDeleted BIT NOT NULL DEFAULT 0,
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
);
GO

CREATE TABLE Inventory (
    InventoryID INT IDENTITY(1,1) PRIMARY KEY,
    ItemName NVARCHAR(100) NOT NULL,
    Quantity DECIMAL(10,2) DEFAULT 0,
    Unit NVARCHAR(50),
    Status NVARCHAR(20) NOT NULL DEFAULT 'Active' CHECK (Status IN ('Active', 'Inactive')), 
    LowThreshold DECIMAL(10,2) NULL DEFAULT 5, 
    CriticalThreshold DECIMAL(10,2) NULL DEFAULT 2, 
    LastUpdated DATETIME DEFAULT GETDATE()
);
GO

CREATE TABLE ProductIngredient (
    ProductSizeID INT NOT NULL,
    InventoryID INT NOT NULL,
    QuantityNeeded DECIMAL(10,2) NOT NULL,
    Unit NVARCHAR(50),
    PRIMARY KEY (ProductSizeID, InventoryID),
    FOREIGN KEY (ProductSizeID) REFERENCES ProductSize(ProductSizeID),
    FOREIGN KEY (InventoryID) REFERENCES Inventory(InventoryID)
);
GO

-- ===============================
-- 🍽️ TABLE SYSTEM
-- ===============================
CREATE TABLE [Table] (
    TableID INT IDENTITY(1,1) PRIMARY KEY,
    TableNumber NVARCHAR(10) NOT NULL UNIQUE,
    Capacity INT NOT NULL CHECK (Capacity > 0),
    [Status] NVARCHAR(20) DEFAULT 'available' CHECK ([Status] IN ('available', 'unavailable')),
    IsActive BIT DEFAULT 1
);
GO

-- ===============================
-- 🛒 ORDER SYSTEM
-- ===============================

CREATE TABLE [Order] (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT FOREIGN KEY REFERENCES Customer(CustomerID),
    EmployeeID INT FOREIGN KEY REFERENCES Employee(EmployeeID),
    TableID INT NULL FOREIGN KEY REFERENCES [Table](TableID),
    OrderDate DATETIME DEFAULT GETDATE(),
    -- 0=Waiting, 1=Ready, 2=Dining, 3=Completed, 4=Cancelled
    [Status] INT DEFAULT 0 CHECK ([Status] IN (0,1,2,3,4)), 
    PaymentStatus NVARCHAR(50) CHECK (PaymentStatus IN ('Unpaid', 'Paid')),
    TotalPrice DECIMAL(10,2) DEFAULT 0,
    Note NVARCHAR(255)
);
GO

CREATE TABLE OrderDetail (
    OrderDetailID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT FOREIGN KEY REFERENCES [Order](OrderID),
    ProductSizeID INT FOREIGN KEY REFERENCES ProductSize(ProductSizeID),
    Quantity INT NOT NULL,
    TotalPrice DECIMAL(10,2),
    SpecialInstructions NVARCHAR(255),
    EmployeeID INT NULL,
    [Status] NVARCHAR(50) DEFAULT 'Waiting',
    StartTime DATETIME NULL,
    EndTime DATETIME NULL,
    FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID)
);
GO

-- Bảng OrderDetailTopping ĐÃ SỬA: ToppingPrice -> ProductPrice
CREATE TABLE OrderDetailTopping (
	OrderDetailToppingID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	OrderDetailID INT NOT NULL FOREIGN KEY REFERENCES OrderDetail(OrderDetailID) ON DELETE CASCADE,
	ProductPrice DECIMAL(10, 2) NOT NULL, -- ĐÃ ĐỔI TÊN TỪ ToppingPrice
	ProductSizeID INT NOT NULL, -- ProductSizeID của Topping (Tức là ProductSizeID của một Topping Product)
	CONSTRAINT FK_OrderDetailTopping_ProductSize_Topping FOREIGN KEY (ProductSizeID)
	REFERENCES ProductSize(ProductSizeID)
);
GO


-- ===============================
-- 🏷️ DISCOUNT SYSTEM
-- ===============================

CREATE TABLE Discount (
    DiscountID INT IDENTITY(1,1) PRIMARY KEY,
    Description NVARCHAR(255),
    DiscountType NVARCHAR(50),
    Value DECIMAL(10,2),
    MaxDiscount DECIMAL(10,2),
    MinOrderTotal DECIMAL(10,2) DEFAULT 0,
    StartDate DATE,
    EndDate DATE,
    IsActive BIT DEFAULT 1
);
GO

CREATE TABLE OrderDiscount (
    OrderID INT FOREIGN KEY REFERENCES [Order](OrderID),
    DiscountID INT FOREIGN KEY REFERENCES Discount(DiscountID),
    Amount DECIMAL(10,2) NOT NULL,
    AppliedDate DATETIME DEFAULT GETDATE(),
    PRIMARY KEY (OrderID, DiscountID)
);
GO

-- ===============================
-- 💳 PAYMENT SYSTEM 
-- ===============================

CREATE TABLE Payment (
    PaymentID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT NOT NULL,
    Amount DECIMAL(10,2) NOT NULL,
    PaymentStatus NVARCHAR(50) DEFAULT 'Pending' CHECK (PaymentStatus IN ('Pending', 'Completed', 'Failed')),
    PaymentDate DATETIME DEFAULT GETDATE(),
    QRCodeURL NVARCHAR(500) NULL,
    FOREIGN KEY (OrderID) REFERENCES [Order](OrderID) ON DELETE CASCADE
);
GO

-- ===============================
-- 📝 FEEDBACK SYSTEM 
-- ===============================

CREATE TABLE Feedback (
    FeedbackID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL FOREIGN KEY REFERENCES Customer(CustomerID),
    OrderID INT NOT NULL FOREIGN KEY REFERENCES [Order](OrderID),
    ProductID INT NOT NULL FOREIGN KEY REFERENCES Product(ProductID),
    Rating INT NOT NULL CHECK (Rating BETWEEN 1 AND 5),
    FeedbackDate DATETIME DEFAULT GETDATE()
);
GO

-- ===============================
-- 🔑 PASSWORD TOKENS
-- ===============================

CREATE TABLE PasswordTokens (
    Token NVARCHAR(20) PRIMARY KEY, 
    UserID INT NOT NULL,
    NewPasswordHash NVARCHAR(255) NOT NULL,
    ExpiresAt DATETIME2 NOT NULL DEFAULT DATEADD(MINUTE, 5, SYSDATETIME()),
    Used BIT NOT NULL DEFAULT 0,
    CONSTRAINT FK_PasswordTokens_User FOREIGN KEY (UserID)
        REFERENCES [User](UserID)
        ON DELETE CASCADE
);
GO

-- ===============================
-- ⏳ QUEUE TABLES
-- ===============================

CREATE TABLE DeletionQueue (
    QueueID INT IDENTITY(1,1) PRIMARY KEY,
    EntityType NVARCHAR(20) NOT NULL,
    EntityID INT NOT NULL,
    ScheduledDeletion DATETIME NOT NULL DEFAULT DATEADD(DAY, 1, CAST(GETDATE() AS DATE)),
    CONSTRAINT UK_DeletionQueue_Entity UNIQUE (EntityType, EntityID)
);
GO

-- ===============================
-- 💾 SAMPLE DATA
-- ===============================

-- Users
INSERT INTO [User] (Name, Password, Role, Email, Phone, [DateOfBirth], Gender, IsActive)
VALUES 
('Admin 01', '$2a$10$wA1.VHtxxp1i0a.SY2SFO.f45v.G/syMrruqnfJHGIEYCjiFTUSgW', 1, 'admin01@pizzastore.com', '0909000001', '1990-01-01', 'Male', 1), -- UserID 1
('Nguyen Van A', '$2a$10$bJskj.kelsRTuCHDBHkQJu2z0NQSUzivBArkjVNmiybd7ab4IxEC2', 2, 'employee01@pizzastore.com', '0909000002', '1995-03-15', 'Male', 1), -- UserID 2 (Waiter)
('Tran Thi B', '$2a$10$bxDhNBnj3nQoTq2vNVhBUeKXQovbEGigBGtNdm2LLZNSQ5VYMrdbG', 2, 'employee02@pizzastore.com', '0909000003', '1995-03-15', 'Female', 1), -- UserID 3 (Chef Pizza)
('Le Van C', '$2a$10$8T7NzU1acsG44ojiWCaMyuc1/hj690KUvnnBLLSHYRfrK5.dqw3MG', 3, 'customer01@gmail.com', '0909000004', '2000-02-02', 'Male', 1), -- UserID 4
('Pham Thi D', '$2a$10$/a5l7E7hEMhx1Wm.I/GDxuySxSqz8Sud.ZcwMNBT02VJB9XNL5h7i', 3, 'customer02@gmail.com', '0909000005', '2001-05-12', 'Female', 1), -- UserID 5
('Hoang Van E', '$2a$10$H/hz51dfW781VMlzSO4nROCjjvadpx4qHbi/GAnjKcvgUct4Mvc1q', 3, 'customer03@gmail.com', '0909000006', '1999-09-09', 'Male', 1), -- UserID 6
('Chef Nguyen', '$2a$10$wA1.VHtxxp1i0a.SY2SFO.f45v.G/syMrruqnfJHGIEYCjiFTUSgW', 2, 'chef01@pizzastore.com', '0909000007', '1992-07-20', 'Male', 1), -- UserID 7 (Chef Drinks)
('Chef Ly', '$2a$10$wA1.VHtxxp1i0a.SY2SFO.f45v.G/syMrruqnfJHGIEYCjiFTUSgW', 2, 'chef02@pizzastore.com', '0909000008', '1993-08-10', 'Female', 1), -- UserID 8 (Chef SideDishes)
('Manager Z', '$2a$10$wA1.VHtxxp1i0a.SY2SFO.f45v.G/syMrruqnfJHGIEYCjiFTUSgW', 2, 'manager01@pizzastore.com', '0909000009', '1985-04-25', 'Male', 1); -- UserID 9 (Manager)
GO

-- Employees (Loại bỏ Cashier, thêm các loại Chef và Manager)
INSERT INTO Employee (UserID, Role, Specialization)
VALUES 
(9, 'Manager', NULL), -- EmployeeID 1
(2, 'Waiter', NULL), -- EmployeeID 2
(3, 'Chef', 'Pizza'), -- EmployeeID 3
(7, 'Chef', 'Drinks'), -- EmployeeID 4
(8, 'Chef', 'SideDishes'); -- EmployeeID 5
GO

-- Customers
INSERT INTO Customer (UserID, LoyaltyPoint, LastEarnedDate)
VALUES 
(4, 20, '2025-10-20 14:30:00'), -- CustomerID 1
(5, 20, '2025-10-18 10:15:00'), -- CustomerID 2
(6, 5, '2025-10-19 16:45:00'); -- CustomerID 3
GO

-- Categories
INSERT INTO Category (CategoryName, Description)
VALUES 
(N'Pizza', N'All pizza products'), -- CategoryID 1
(N'Drink', N'All beverages'), -- CategoryID 2
(N'Topping', N'Extra toppings'), -- CategoryID 3
(N'SideDish', N'Side dishes'); -- CategoryID 4
GO

-- Products (Thêm SideDish và Topping là Product)
INSERT INTO Product (ProductName, Description, CategoryID, ImageURL, IsAvailable)
VALUES 
(N'Hawaiian Pizza', N'Pizza with ham and pineapple', 1, N'hawaiian.jpg', 1), -- ProductID 1
(N'Iced Milk Coffee', N'Coffee with condensed milk', 2, N'icedMilkCoffee.jpg', 1), -- ProductID 2
(N'Peach Orange Tea', N'Peach tea with orange flavor', 2, N'peachOrangeTea.jpg', 1), -- ProductID 3
(N'Extra Cheese Topping', N'Extra cheese for pizza', 3, N'extraCheese.jpg', 1), -- Topping ProductID 4
(N'Sausage Topping', N'Sausage topping', 3, N'sausage.jpg', 1), -- Topping ProductID 5
(N'Fried Chicken Wings', N'Crispy fried chicken wings', 4, N'chickenWings.jpg', 1); -- SideDish ProductID 6
GO

-- Product sizes & prices
INSERT INTO ProductSize (ProductID, SizeCode, SizeName, Price)
VALUES
(1, 'S', 'Small', 120000), -- Pizza S (ProductSizeID 1)
(1, 'M', 'Medium', 160000), -- Pizza M (ProductSizeID 2)
(1, 'L', 'Large', 200000), -- Pizza L (ProductSizeID 3)
(2, 'F', 'Fixed', 25000), -- Coffee F (ProductSizeID 4)
(3, 'F', 'Fixed', 30000), -- Tea F (ProductSizeID 5)
(4, 'F', 'Fixed', 15000), -- Topping Extra Cheese F (ProductSizeID 6) 
(5, 'F', 'Fixed', 20000), -- Topping Sausage F (ProductSizeID 7) 
(6, 'F', 'Fixed', 50000); -- Chicken Wings F (ProductSizeID 8)
GO

-- Inventory (Thêm LowThreshold và CriticalThreshold)
INSERT INTO Inventory (ItemName, Quantity, Unit, Status, LowThreshold, CriticalThreshold)
VALUES 
(N'Dough', 10, N'kg', 'Active', 5, 2), -- InventoryID 1
(N'Cheese', 5, N'kg', 'Active', 3, 1), -- InventoryID 2
(N'Ham', 3, N'kg', 'Active', 1.5, 0.5), -- InventoryID 3
(N'Pineapple', 2, N'kg', 'Active', 1, 0.5), -- InventoryID 4
(N'Ground Coffee', 10, N'kg', 'Active', 5, 2), -- InventoryID 5
(N'Condensed Milk', 5, N'liter', 'Active', 3, 1), -- InventoryID 6
(N'Sliced Peach', 2, N'kg', 'Active', 1, 0.5), -- InventoryID 7
(N'Dried Tea', 3, N'kg', 'Active', 1.5, 0.5), -- InventoryID 8
(N'Topping Cheese Stock', 5, N'kg', 'Active', 3, 1), -- InventoryID 9
(N'Topping Sausage Stock', 4, N'kg', 'Active', 2, 0.5), -- InventoryID 10
(N'Chicken', 8, N'kg', 'Active', 4, 1); -- InventoryID 11
GO

-- Ingredients by size 
INSERT INTO ProductIngredient (ProductSizeID, InventoryID, QuantityNeeded, Unit)
VALUES
(1, 1, 0.25, 'kg'), (1, 2, 0.10, 'kg'), (1, 3, 0.08, 'kg'), (1, 4, 0.05, 'kg'), -- Pizza S
(4, 5, 0.05, 'kg'), (4, 6, 0.02, 'liter'), -- Coffee F
(5, 7, 0.05, 'kg'), (5, 8, 0.02, 'kg'), -- Tea F
(6, 9, 0.05, 'kg'), -- Topping Cheese F
(7, 10, 0.05, 'kg'), -- Topping Sausage F
(8, 11, 0.3, 'kg'); -- Chicken Wings F
GO

-- Table data
INSERT INTO [Table] (TableNumber, Capacity) VALUES
('T01', 2), ('T02', 2), ('T03', 4), ('T04', 4),
('T05', 4), ('T06', 6), ('T07', 6), ('T08', 6),
('T09', 8), ('T10', 8), ('T11', 10), ('T12', 10);
GO

-- Orders 
INSERT INTO [Order] (CustomerID, EmployeeID, TableID, [Status], PaymentStatus, TotalPrice, Note)
VALUES 
(1, 2, 5, 0, 'Unpaid', 120000, N'Order 1: Pizza S - Waiting'), -- OrderID 1
(1, 2, 3, 1, 'Unpaid', 105000, N'Order 2: Coffee + Tea + Wings - Ready'), -- OrderID 2: TotalPrice ước tính
(2, 2, 2, 3, 'Paid', 135000, N'Order 3: Pizza S + Extra Cheese Topping - Completed'); -- OrderID 3
GO

-- Order details (Món chính)
INSERT INTO OrderDetail (OrderID, ProductSizeID, Quantity, TotalPrice, SpecialInstructions, EmployeeID, [Status], StartTime, EndTime)
VALUES
(1, 1, 1, 120000, NULL, 3, 'In Progress', GETDATE(), NULL), -- OrderDetailID 1: Pizza S (Order 1) - Chef Pizza
(2, 4, 1, 25000, N'Less ice', 4, 'Done', GETDATE(), GETDATE()), -- OrderDetailID 2: Coffee F (Order 2) - Chef Drinks
(2, 5, 1, 30000, N'No sugar', 4, 'Done', GETDATE(), GETDATE()), -- OrderDetailID 3: Tea F (Order 2) - Chef Drinks
(2, 8, 1, 50000, NULL, 5, 'Done', GETDATE(), GETDATE()), -- OrderDetailID 4: Wings F (Order 2) - Chef SideDishes
(3, 1, 1, 120000, NULL, 3, 'Done', DATEADD(MINUTE, -30, GETDATE()), GETDATE()); -- OrderDetailID 5: Pizza S (Order 3) - Chef Pizza
GO

-- OrderDetailTopping (Gắn Topping Product với món chính OrderDetail)
-- OrderDetail 5 (Pizza S) có thêm Topping Extra Cheese (ProductSizeID 6)
INSERT INTO OrderDetailTopping (OrderDetailID, ProductSizeID, ProductPrice)
VALUES
(5, 6, 15000); -- OrderDetailToppingID 1: Gắn Topping Cheese (ID 6) vào Pizza (OrderDetail ID 5). ProductPrice là giá cố định của ProductSizeID 6.
GO

-- Discounts
INSERT INTO Discount (Description, DiscountType, Value, MaxDiscount, MinOrderTotal, StartDate, EndDate, IsActive)
VALUES
(N'10% off drinks', 'Percentage', 10, NULL, 0, '2025-10-01', '2025-10-31', 1), -- DiscountID 1
(N'Fixed 20K off over 200K', 'Fixed', 20000, NULL, 200000, '2025-10-15', '2025-11-15', 1), -- DiscountID 2
(N'Loyalty points', 'Loyalty', 100, NULL, 0, '2025-10-01', NULL, 1); -- DiscountID 3
GO

-- Payments (Thêm dữ liệu mẫu Payment)
INSERT INTO Payment (OrderID, Amount, PaymentStatus)
VALUES
(3, 135000, 'Completed'), -- PaymentID 1 cho Order 3
(2, 105000, 'Pending'); -- PaymentID 2 cho Order 2 
GO

-- Feedback
INSERT INTO Feedback (CustomerID, OrderID, ProductID, Rating)
VALUES
(2, 3, 1, 5); -- FeedbackID 1: Customer 2 đánh giá Hawaiian Pizza 5 sao cho Order 3
GO

-- ===============================
-- 📦 THÊM NHIỀU ORDER MẪU CHO ORDER HISTORY
-- ===============================

-- Thêm Orders cho Customer 1 (Le Van C - CustomerID 1)
INSERT INTO [Order] (CustomerID, EmployeeID, TableID, [Status], PaymentStatus, TotalPrice, Note, OrderDate)
VALUES 
-- Orders đã hoàn thành (tháng 10/2025)
(1, 2, 1, 3, 'Paid', 145000, N'Order 4: Pizza M - Completed', '2025-10-05 12:30:00'),
(1, 2, 3, 3, 'Paid', 280000, N'Order 5: 2 Pizza S + Coffee - Completed', '2025-10-08 18:45:00'),
(1, 2, 5, 3, 'Paid', 55000, N'Order 6: Coffee + Tea - Completed', '2025-10-12 14:20:00'),
(1, 2, 2, 3, 'Paid', 320000, N'Order 7: Pizza L + Wings - Completed', '2025-10-15 19:30:00'),
(1, 2, 4, 3, 'Paid', 160000, N'Order 8: Pizza M - Completed', '2025-10-20 13:15:00'),

-- Orders đã hoàn thành (tháng 11/2025)
(1, 2, 6, 3, 'Paid', 240000, N'Order 9: 2 Pizza S - Completed', '2025-11-01 12:00:00'),
(1, 2, 7, 3, 'Paid', 105000, N'Order 10: Coffee + Tea + Wings - Completed', '2025-11-05 15:30:00'),
(1, 2, 8, 3, 'Paid', 200000, N'Order 11: Pizza L - Completed', '2025-11-08 18:00:00'),

-- Thêm Orders cho Customer 2 (Pham Thi D - CustomerID 2)
(2, 2, 9, 3, 'Paid', 360000, N'Order 12: Pizza M + Pizza S + Coffee - Completed', '2025-10-10 12:45:00'),
(2, 2, 10, 3, 'Paid', 170000, N'Order 13: Pizza M + Tea - Completed', '2025-10-18 19:15:00'),
(2, 2, 11, 3, 'Paid', 75000, N'Order 14: Coffee + Wings - Completed', '2025-10-25 14:30:00'),
(2, 2, 12, 3, 'Paid', 320000, N'Order 15: 2 Pizza M - Completed', '2025-11-02 13:00:00'),
(2, 2, 1, 3, 'Paid', 250000, N'Order 16: Pizza L + Wings - Completed', '2025-11-07 17:45:00'),

-- Thêm Orders cho Customer 3 (Hoang Van E - CustomerID 3)
(3, 2, 2, 3, 'Paid', 120000, N'Order 17: Pizza S - Completed', '2025-10-07 11:30:00'),
(3, 2, 3, 3, 'Paid', 80000, N'Order 18: Coffee + Tea + Wings - Completed', '2025-10-14 16:00:00'),
(3, 2, 4, 3, 'Paid', 200000, N'Order 19: Pizza L - Completed', '2025-10-22 19:30:00'),
(3, 2, 5, 3, 'Paid', 145000, N'Order 20: Pizza M + Coffee - Completed', '2025-11-03 12:15:00'),
(3, 2, 6, 3, 'Paid', 240000, N'Order 21: 2 Pizza S - Completed', '2025-11-09 18:30:00'),

-- Orders đang xử lý (cho test)
(1, 2, 7, 2, 'Unpaid', 160000, N'Order 22: Pizza M - Dining', '2025-11-13 12:00:00'),
(2, 2, 8, 1, 'Unpaid', 105000, N'Order 23: Coffee + Tea + Wings - Ready', '2025-11-13 12:30:00');
GO

-- Order Details cho các orders mới (OrderID 4-23)
INSERT INTO OrderDetail (OrderID, ProductSizeID, Quantity, TotalPrice, SpecialInstructions, EmployeeID, [Status], StartTime, EndTime)
VALUES
-- Order 4: Pizza M
(4, 2, 1, 145000, NULL, 3, 'Done', '2025-10-05 12:35:00', '2025-10-05 12:50:00'),

-- Order 5: 2 Pizza S + Coffee
(5, 1, 2, 240000, NULL, 3, 'Done', '2025-10-08 18:50:00', '2025-10-08 19:10:00'),
(5, 4, 1, 25000, N'Less ice', 4, 'Done', '2025-10-08 18:50:00', '2025-10-08 19:00:00'),

-- Order 6: Coffee + Tea
(6, 4, 1, 25000, NULL, 4, 'Done', '2025-10-12 14:25:00', '2025-10-12 14:30:00'),
(6, 5, 1, 30000, NULL, 4, 'Done', '2025-10-12 14:25:00', '2025-10-12 14:30:00'),

-- Order 7: Pizza L + Wings
(7, 3, 1, 200000, NULL, 3, 'Done', '2025-10-15 19:35:00', '2025-10-15 19:55:00'),
(7, 8, 1, 50000, N'Extra crispy', 5, 'Done', '2025-10-15 19:35:00', '2025-10-15 19:50:00'),

-- Order 8: Pizza M
(8, 2, 1, 160000, NULL, 3, 'Done', '2025-10-20 13:20:00', '2025-10-20 13:40:00'),

-- Order 9: 2 Pizza S
(9, 1, 2, 240000, NULL, 3, 'Done', '2025-11-01 12:05:00', '2025-11-01 12:25:00'),

-- Order 10: Coffee + Tea + Wings
(10, 4, 1, 25000, NULL, 4, 'Done', '2025-11-05 15:35:00', '2025-11-05 15:40:00'),
(10, 5, 1, 30000, NULL, 4, 'Done', '2025-11-05 15:35:00', '2025-11-05 15:40:00'),
(10, 8, 1, 50000, NULL, 5, 'Done', '2025-11-05 15:35:00', '2025-11-05 15:50:00'),

-- Order 11: Pizza L
(11, 3, 1, 200000, NULL, 3, 'Done', '2025-11-08 18:05:00', '2025-11-08 18:25:00'),

-- Order 12: Pizza M + Pizza S + Coffee
(12, 2, 1, 160000, NULL, 3, 'Done', '2025-10-10 12:50:00', '2025-10-10 13:10:00'),
(12, 1, 1, 120000, NULL, 3, 'Done', '2025-10-10 12:50:00', '2025-10-10 13:10:00'),
(12, 4, 1, 25000, NULL, 4, 'Done', '2025-10-10 12:50:00', '2025-10-10 13:00:00'),

-- Order 13: Pizza M + Tea
(13, 2, 1, 160000, NULL, 3, 'Done', '2025-10-18 19:20:00', '2025-10-18 19:40:00'),
(13, 5, 1, 30000, NULL, 4, 'Done', '2025-10-18 19:20:00', '2025-10-18 19:30:00'),

-- Order 14: Coffee + Wings
(14, 4, 1, 25000, NULL, 4, 'Done', '2025-10-25 14:35:00', '2025-10-25 14:40:00'),
(14, 8, 1, 50000, NULL, 5, 'Done', '2025-10-25 14:35:00', '2025-10-25 14:50:00'),

-- Order 15: 2 Pizza M
(15, 2, 2, 320000, NULL, 3, 'Done', '2025-11-02 13:05:00', '2025-11-02 13:25:00'),

-- Order 16: Pizza L + Wings
(16, 3, 1, 200000, NULL, 3, 'Done', '2025-11-07 17:50:00', '2025-11-07 18:10:00'),
(16, 8, 1, 50000, NULL, 5, 'Done', '2025-11-07 17:50:00', '2025-11-07 18:05:00'),

-- Order 17: Pizza S
(17, 1, 1, 120000, NULL, 3, 'Done', '2025-10-07 11:35:00', '2025-10-07 11:50:00'),

-- Order 18: Coffee + Tea + Wings
(18, 4, 1, 25000, NULL, 4, 'Done', '2025-10-14 16:05:00', '2025-10-14 16:10:00'),
(18, 5, 1, 30000, NULL, 4, 'Done', '2025-10-14 16:05:00', '2025-10-14 16:10:00'),
(18, 8, 1, 50000, NULL, 5, 'Done', '2025-10-14 16:05:00', '2025-10-14 16:20:00'),

-- Order 19: Pizza L
(19, 3, 1, 200000, NULL, 3, 'Done', '2025-10-22 19:35:00', '2025-10-22 19:55:00'),

-- Order 20: Pizza M + Coffee
(20, 2, 1, 160000, NULL, 3, 'Done', '2025-11-03 12:20:00', '2025-11-03 12:40:00'),
(20, 4, 1, 25000, NULL, 4, 'Done', '2025-11-03 12:20:00', '2025-11-03 12:30:00'),

-- Order 21: 2 Pizza S
(21, 1, 2, 240000, NULL, 3, 'Done', '2025-11-09 18:35:00', '2025-11-09 18:55:00'),

-- Order 22: Pizza M (Đang dining)
(22, 2, 1, 160000, NULL, 3, 'Done', '2025-11-13 12:05:00', '2025-11-13 12:25:00'),

-- Order 23: Coffee + Tea + Wings (Ready)
(23, 4, 1, 25000, NULL, 4, 'Done', '2025-11-13 12:35:00', '2025-11-13 12:40:00'),
(23, 5, 1, 30000, NULL, 4, 'Done', '2025-11-13 12:35:00', '2025-11-13 12:40:00'),
(23, 8, 1, 50000, NULL, 5, 'Done', '2025-11-13 12:35:00', '2025-11-13 12:50:00');
GO

-- Thêm một số OrderDetailTopping cho các order có topping
INSERT INTO OrderDetailTopping (OrderDetailID, ProductSizeID, ProductPrice)
VALUES
-- Order 4 có thêm Sausage topping
(6, 7, 20000),
-- Order 8 có thêm Extra Cheese topping
(13, 6, 15000);
GO

-- Thêm Payments cho các orders đã hoàn thành
INSERT INTO Payment (OrderID, Amount, PaymentStatus, PaymentDate)
VALUES
(4, 145000, 'Completed', '2025-10-05 13:00:00'),
(5, 280000, 'Completed', '2025-10-08 19:20:00'),
(6, 55000, 'Completed', '2025-10-12 14:45:00'),
(7, 320000, 'Completed', '2025-10-15 20:00:00'),
(8, 160000, 'Completed', '2025-10-20 13:50:00'),
(9, 240000, 'Completed', '2025-11-01 12:35:00'),
(10, 105000, 'Completed', '2025-11-05 16:00:00'),
(11, 200000, 'Completed', '2025-11-08 18:35:00'),
(12, 360000, 'Completed', '2025-10-10 13:20:00'),
(13, 170000, 'Completed', '2025-10-18 19:50:00'),
(14, 75000, 'Completed', '2025-10-25 15:00:00'),
(15, 320000, 'Completed', '2025-11-02 13:35:00'),
(16, 250000, 'Completed', '2025-11-07 18:20:00'),
(17, 120000, 'Completed', '2025-10-07 12:00:00'),
(18, 80000, 'Completed', '2025-10-14 16:30:00'),
(19, 200000, 'Completed', '2025-10-22 20:05:00'),
(20, 145000, 'Completed', '2025-11-03 12:50:00'),
(21, 240000, 'Completed', '2025-11-09 19:05:00');
GO

-- Thêm một số Feedback
INSERT INTO Feedback (CustomerID, OrderID, ProductID, Rating, FeedbackDate)
VALUES
(1, 4, 1, 5, '2025-10-05 13:10:00'),
(1, 5, 1, 4, '2025-10-08 19:30:00'),
(1, 7, 1, 5, '2025-10-15 20:10:00'),
(2, 12, 1, 5, '2025-10-10 13:30:00'),
(2, 13, 1, 4, '2025-10-18 20:00:00'),
(3, 17, 1, 5, '2025-10-07 12:10:00'),
(3, 19, 1, 5, '2025-10-22 20:15:00');
GO

-- ===============================
-- 📊 VIEW (Đã thêm v_InventoryMonitor)
-- ===============================

-- View tồn kho có sẵn (Không đổi)
CREATE OR ALTER VIEW v_ProductSizeAvailable
AS
WITH SizeAvailability AS (
    SELECT
        pi.ProductSizeID,
        MIN(i.Quantity / NULLIF(pi.QuantityNeeded, 0)) AS CalculatedQuantity
    FROM 
        ProductIngredient pi
    JOIN 
        Inventory i ON pi.InventoryID = i.InventoryID
    WHERE
        pi.QuantityNeeded > 0
    GROUP BY
        pi.ProductSizeID
)
SELECT
    p.ProductID,
    ps.ProductSizeID,
    p.ProductName,
    ps.SizeCode,
    ps.SizeName,
    ps.Price,
    c.CategoryName,
    p.ImageURL,
    p.IsAvailable,
    CAST(COALESCE(sa.CalculatedQuantity, 0) AS DECIMAL(10,2)) AS AvailableQuantity
FROM
    ProductSize ps
JOIN
    Product p ON ps.ProductID = p.ProductID
JOIN
    Category c ON p.CategoryID = c.CategoryID
LEFT JOIN
    SizeAvailability sa ON ps.ProductSizeID = sa.ProductSizeID
WHERE
    p.IsAvailable = 1
    AND ps.IsDeleted = 0
    AND c.IsDeleted = 0;
GO 

-- View Giám sát Tồn kho (Mới)
CREATE OR ALTER VIEW v_InventoryMonitor
AS
SELECT 
    InventoryID,
    ItemName,
    Quantity,
    Unit,
    Status,
    LowThreshold,
    CriticalThreshold,
    LastUpdated,
    CASE
        WHEN Status = 'Inactive' THEN 'INACTIVE'
        WHEN Quantity <= ISNULL(CriticalThreshold, 2) THEN 'CRITICAL'
        WHEN Quantity <= ISNULL(LowThreshold, 5) THEN 'LOW'
        ELSE 'OK'
    END AS StockLevel,
    -- Phần trăm tồn kho so với ngưỡng thấp
    CAST(
        CASE 
            WHEN LowThreshold IS NULL OR LowThreshold = 0 THEN NULL
            ELSE (Quantity / LowThreshold) * 100
        END AS DECIMAL(5,2)
    ) AS PercentOfLowLevel
FROM Inventory;
GO

-- ===========================
-- ⚙️ PROCEDURES (Cập nhật tên DB mới)
-- ===========================
CREATE OR ALTER PROCEDURE ScheduleDeletion
    @EntityType NVARCHAR(20),
    @EntityID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ScheduledTime DATETIME = DATEADD(DAY, 1, CAST(GETDATE() AS DATE));
    
    IF NOT EXISTS (SELECT 1 FROM DeletionQueue WHERE EntityType = @EntityType AND EntityID = @EntityID)
    BEGIN
        INSERT INTO DeletionQueue (EntityType, EntityID, ScheduledDeletion)
        VALUES (@EntityType, @EntityID, @ScheduledTime);
    END
END
GO

-- ===========================
CREATE OR ALTER PROCEDURE ScheduleDiscountUpdate
    @DiscountID INT,
    @Description NVARCHAR(255),
    @DiscountType NVARCHAR(50),
    @Value DECIMAL(10,2),
    @MaxDiscount DECIMAL(10,2),
    @MinOrderTotal DECIMAL(10,2),
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ScheduledTime DATETIME = DATEADD(DAY, 1, CAST(GETDATE() AS DATE));
    
    IF EXISTS (SELECT 1 FROM DiscountUpdateQueue WHERE DiscountID = @DiscountID)
    BEGIN
        UPDATE DiscountUpdateQueue 
        SET Description = @Description,
            DiscountType = @DiscountType,
            Value = @Value,
            MaxDiscount = @MaxDiscount,
            MinOrderTotal = @MinOrderTotal,
            StartDate = @StartDate,
            EndDate = @EndDate,
            ScheduledUpdate = @ScheduledTime
        WHERE DiscountID = @DiscountID;
    END
    ELSE
    BEGIN
        INSERT INTO DiscountUpdateQueue (DiscountID, Description, DiscountType, Value, MaxDiscount, MinOrderTotal, StartDate, EndDate, ScheduledUpdate)
        VALUES (@DiscountID, @Description, @DiscountType, @Value, @MaxDiscount, @MinOrderTotal, @StartDate, @EndDate, @ScheduledTime);
    END
END
GO

-- ===========================
CREATE OR ALTER PROCEDURE ProcessDeletionQueue
AS
BEGIN
    SET NOCOUNT ON;
    
    IF DB_NAME() != 'pizza_demo_DB_FinalModel_Combined'
    BEGIN
        PRINT 'This procedure is designed for pizza_demo_DB_FinalModel_Combined only. Current database: ' + DB_NAME();
        RETURN;
    END
    
    DECLARE @QueueID INT, @EntityType NVARCHAR(20), @EntityID INT;
    DECLARE @ProcessedCount INT = 0;
    
    WHILE (1 = 1)
    BEGIN
        SELECT TOP 1 @QueueID = QueueID, @EntityType = EntityType, @EntityID = EntityID
        FROM DeletionQueue
        WHERE ScheduledDeletion <= GETDATE()
        ORDER BY ScheduledDeletion;
        
        IF @QueueID IS NULL
            BREAK;
        
        BEGIN TRY
            BEGIN TRANSACTION;
            
            IF @EntityType = 'Table'
            BEGIN
                UPDATE [Table] SET IsActive = 0 WHERE TableID = @EntityID;
            END
            ELSE IF @EntityType = 'Discount'
            BEGIN
                UPDATE Discount SET IsActive = 0 WHERE DiscountID = @EntityID;
            END
            
            DELETE FROM DeletionQueue WHERE QueueID = @QueueID;
            SET @ProcessedCount = @ProcessedCount + 1;
            
            COMMIT TRANSACTION;
        END TRY
        BEGIN CATCH
            ROLLBACK TRANSACTION;
            PRINT 'Error processing QueueID ' + CAST(@QueueID AS NVARCHAR) + ': ' + ERROR_MESSAGE();
            BREAK;
        END CATCH
        
        SET @QueueID = NULL;
        SET @EntityType = NULL;
        SET @EntityID = NULL;
    END
    
    PRINT 'Processed ' + CAST(@ProcessedCount AS NVARCHAR) + ' items from deletion queue.';
END
GO

-- ===========================
-- SQL Server Agent Jobs (Cập nhật tên DB mới)
-- ===========================
USE msdb;
GO

-- Xóa Job cũ nếu có
IF EXISTS (SELECT job_id FROM msdb.dbo.sysjobs WHERE name = N'ProcessDeletionQueue_pizza_demo_DB_FinalModel_Combined')
EXEC dbo.sp_delete_job @job_name = N'ProcessDeletionQueue_pizza_demo_DB_FinalModel_Combined', @delete_unused_schedule=1

-- Create job for deletion queue
EXEC dbo.sp_add_job
    @job_name = N'ProcessDeletionQueue_pizza_demo_DB_FinalModel_Combined',
    @enabled = 1,
    @description = N'Process scheduled deletions daily at 00:01 - pizza_demo_DB_FinalModel_Combined only';

-- Add job step for deletion queue
EXEC sp_add_jobstep
    @job_name = N'ProcessDeletionQueue_pizza_demo_DB_FinalModel_Combined',
    @step_name = N'ProcessDeletionQueue',
    @subsystem = N'TSQL',
    @command = N'EXEC ProcessDeletionQueue',
    @database_name = N'pizza_demo_DB_FinalModel_Combined';

-- Add schedule (run daily at 00:01)
-- Check if schedule 'DailyMidnight' exists before creating
IF NOT EXISTS (SELECT name FROM msdb.dbo.sysschedules WHERE name = N'DailyMidnight')
BEGIN
    EXEC sp_add_schedule
        @schedule_name = N'DailyMidnight',
        @freq_type = 4, -- Daily
        @freq_interval = 1,
        @active_start_time = 000100; -- 00:01
END

-- Attach schedule to the job
EXEC sp_attach_schedule
    @job_name = N'ProcessDeletionQueue_pizza_demo_DB_FinalModel_Combined',
    @schedule_name = N'DailyMidnight';

-- Add job to SQL Server Agent
EXEC sp_add_jobserver
    @job_name = N'ProcessDeletionQueue_pizza_demo_DB_FinalModel_Combined';
GO
