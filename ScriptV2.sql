create database pizza_demo_DB2

use pizza_demo_DB2

-- B?ng User: thông tin chung c?a t?t c? ng??i dùng (Admin, Employee, Customer)
CREATE TABLE [User] (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Password NVARCHAR(255) NOT NULL,
    Role INT NOT NULL, -- 1=Admin, 2=Employee, 3=Customer
    Email NVARCHAR(100) UNIQUE,
    Phone NVARCHAR(20) UNIQUE,
    [DateOfBirth] DATE NULL,
    Gender NVARCHAR(10) CHECK (Gender IN ('Male', 'Female', 'Other')),
    IsActive BIT DEFAULT 1
);

-- B?ng Employee: l?u thông tin riêng c?a nhân viên
CREATE TABLE Employee (
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL UNIQUE,
    Role NVARCHAR(50) NOT NULL, -- vai trò công vi?c (VD: Cashier, Waiter)
    FOREIGN KEY (UserID) REFERENCES [User](UserID)
);

-- B?ng Customer: l?u thông tin riêng c?a khách hàng
CREATE TABLE Customer (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL UNIQUE,
    LoyaltyPoint INT DEFAULT 0,
    FOREIGN KEY (UserID) REFERENCES [User](UserID)
);

-- ==========================
-- D? LI?U M?U
-- ==========================

-- Admin
INSERT INTO [User] (Name, Password, Role, Email, Phone, [DateOfBirth], Gender, IsActive)
VALUES 
('Admin 01', 'admin123', 1, 'admin01@pizzastore.com', '0909000001', '1990-01-01', 'Male', 1);

-- Employee
INSERT INTO [User] (Name, Password, Role, Email, Phone, [DateOfBirth], Gender, IsActive)
VALUES
('Nguyen Van A', 'emp123', 2, 'employee01@pizzastore.com', '0909000002', '1995-03-15', 'Male', 1),
('Tran Thi B', 'emp456', 2, 'employee02@pizzastore.com', '0909000003', '1998-08-20', 'Female', 1);

-- Customer
INSERT INTO [User] (Name, Password, Role, Email, Phone, [DateOfBirth], Gender, IsActive)
VALUES
('Le Van C', 'cust123', 3, 'customer01@gmail.com', '0909000004', '2000-02-02', 'Male', 1),
('Pham Thi D', 'cust456', 3, 'customer02@gmail.com', '0909000005', '2001-05-12', 'Female', 1),
('Hoang Van E', 'cust789', 3, 'customer03@gmail.com', '0909000006', '1999-09-09', 'Male', 1);

-- Thêm d? li?u Employee
INSERT INTO Employee (UserID, Role)
VALUES
(2, 'Cashier'),
(3, 'Waiter');

-- Thêm d? li?u Customer
INSERT INTO Customer (UserID, LoyaltyPoint)
VALUES
(4, 10),
(5, 20),
(6, 5);

CREATE TABLE Product (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    ProductName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(255),
    Price DECIMAL(10,2) NOT NULL,
    Category NVARCHAR(50),
    ImageURL NVARCHAR(255),
    IsAvailable BIT DEFAULT 1
);

-- D? LI?U M?U
INSERT INTO Product (ProductName, Description, Price, Category, ImageURL)
VALUES 
(N'Cà phê s?a ?á', N'Cà phê pha v?i s?a ??c', 25000, N'Cà phê', N'coffee_suada.jpg'),
(N'Trà ?ào cam s?', N'Trà ?ào t??i th?m mát', 30000, N'Trà', N'tradao.jpg'),
(N'Sinh t? xoài', N'Sinh t? trái cây t??i', 35000, N'Sinh t?', N'sinhtoxoi.jpg');

-- =====================
-- B?NG INVENTORY
-- =====================
CREATE TABLE Inventory (
    InventoryID INT IDENTITY(1,1) PRIMARY KEY,
    ItemName NVARCHAR(100) NOT NULL,
    Quantity DECIMAL(10,2) DEFAULT 0,
    Unit NVARCHAR(50),
    LastUpdated DATETIME DEFAULT GETDATE()
);

-- D? LI?U M?U
INSERT INTO Inventory (ItemName, Quantity, Unit)
VALUES 
(N'Cà phê b?t', 10, N'kg'),
(N'S?a ??c', 5, N'lít'),
(N'?ào lát', 2, N'kg'),
(N'Trà khô', 3, N'kg'),
(N'Xoài t??i', 8, N'kg');

-- =====================
-- B?NG PRODUCT INGREDIENTS
-- =====================
CREATE TABLE ProductIngredients (
    ProductID INT FOREIGN KEY REFERENCES Product(ProductID),
    InventoryID INT FOREIGN KEY REFERENCES Inventory(InventoryID),
    QuantityNeeded DECIMAL(10,2) NOT NULL,
    Unit NVARCHAR(50),
    PRIMARY KEY (ProductID, InventoryID)
);

-- D? LI?U M?U
INSERT INTO ProductIngredients (ProductID, InventoryID, QuantityNeeded, Unit)
VALUES 
(1, 1, 0.05, N'kg'),  -- Cà phê s?a ?á dùng cà phê b?t
(1, 2, 0.02, N'lít'), -- và s?a ??c
(2, 3, 0.05, N'kg'),  -- Trà ?ào cam s? dùng ?ào lát
(2, 4, 0.02, N'kg'),  -- và trà khô
(3, 5, 0.15, N'kg');  -- Sinh t? xoài dùng xoài t??i

-- =====================
-- B?NG ORDER
-- =====================
CREATE TABLE [Order] (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT FOREIGN KEY REFERENCES Customer(CustomerID),
    EmployeeID INT FOREIGN KEY REFERENCES Employee(EmployeeID),
    TableID INT NULL,
    OrderDate DATETIME DEFAULT GETDATE(),
    [Status] INT DEFAULT 0,              -- 0 = Pending, 1 = Preparing, 2 = Served, 3 = Completed, 4 = Cancelled
    PaymentStatus NVARCHAR(50),
    TotalPrice DECIMAL(10,2) DEFAULT 0,
    Note NVARCHAR(255)
);

-- D? LI?U M?U
INSERT INTO [Order] (CustomerID, EmployeeID, TableID, [Status], PaymentStatus, TotalPrice, Note)
VALUES 
(1, 1, 5, 0, N'Unpaid', 55000, N'Khách mu?n ít ???ng'),
(1, 2, 3, 1, N'Paid', 35000, N'Khách quen'),
(2, 2, 2, 3, N'Paid', 60000, N'?ã giao xong');

-- =====================
-- B?NG ORDER DETAIL
-- =====================
CREATE TABLE OrderDetail (
    OrderDetailID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT FOREIGN KEY REFERENCES [Order](OrderID),
    ProductID INT FOREIGN KEY REFERENCES Product(ProductID),
    Quantity INT NOT NULL,
    TotalPrice DECIMAL(10,2),
    SpecialInstructions NVARCHAR(255)
);

-- D? LI?U M?U
INSERT INTO OrderDetail (OrderID, ProductID, Quantity, TotalPrice, SpecialInstructions)
VALUES
(1, 1, 1, 25000, N'Ít ?á'),
(1, 2, 1, 30000, N'Không s?'),
(2, 3, 1, 35000, NULL),
(3, 1, 2, 50000, NULL),
(3, 2, 1, 10000, N'Gi?m giá combo');