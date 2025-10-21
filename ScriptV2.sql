-- Create the database
CREATE DATABASE pizza_demo_DB2;
GO

USE pizza_demo_DB2;
GO

-- Table: User - general information for all users (Admin, Employee, Customer)
CREATE TABLE [User] (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Password NVARCHAR(60) NOT NULL,
    Role INT NOT NULL CHECK (Role IN (1, 2, 3)), -- 1=Admin, 2=Employee, 3=Customer
    Email NVARCHAR(100) UNIQUE,
    Phone NVARCHAR(20) UNIQUE,
    [DateOfBirth] DATE NULL,
    Gender NVARCHAR(10) CHECK (Gender IN ('Male', 'Female', 'Other')), -- 'Male', 'Female', 'Other'
    IsActive BIT DEFAULT 1
);

-- Table: Employee - specific information for employees
CREATE TABLE Employee (
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL UNIQUE,
    Role NVARCHAR(50) NOT NULL CHECK (Role IN ('Manager', 'Cashier', 'Waiter', 'Chef')), -- 'Manager', 'Cashier', 'Waiter', 'Chef'
    FOREIGN KEY (UserID) REFERENCES [User](UserID)
);

-- Table: Customer - specific information for customers
CREATE TABLE Customer (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL UNIQUE,
    LoyaltyPoint INT DEFAULT 0,
    LastEarnedDate DATETIME NULL,
    FOREIGN KEY (UserID) REFERENCES [User](UserID)
);

-- ===========================
-- SAMPLE DATA
-- ===========================

-- Admin
INSERT INTO [User] (Name, Password, Role, Email, Phone, [DateOfBirth], Gender, IsActive)
VALUES 
('Admin 01', '$2a$10$wA1.VHtxxp1i0a.SY2SFO.f45v.G/syMrruqnfJHGIEYCjiFTUSgW', 1, 'admin01@pizzastore.com', '0909000001', '1990-01-01', 'Male', 1);

-- Employee
INSERT INTO [User] (Name, Password, Role, Email, Phone, [DateOfBirth], Gender, IsActive)
VALUES
('Nguyen Van A', '$2a$10$bJskj.kelsRTuCHDBHkQJu2z0NQSUzivBArkjVNmiybd7ab4IxEC2', 2, 'employee01@pizzastore.com', '0909000002', '1995-03-15', 'Male', 1),
('Tran Thi B', '$2a$10$bxDhNBnj3nQoTq2vNVhBUeKXQovbEGigBGtNdm2LLZNSQ5VYMrdbG', 2, 'employee02@pizzastore.com', '0909000003', '1998-08-20', 'Female', 1);

-- Customer
INSERT INTO [User] (Name, Password, Role, Email, Phone, [DateOfBirth], Gender, IsActive)
VALUES
('Le Van C', '$2a$10$8T7NzU1acsG44ojiWCaMyuc1/hj690KUvnnBLLSHYRfrK5.dqw3MG', 3, 'customer01@gmail.com', '0909000004', '2000-02-02', 'Male', 1),
('Pham Thi D', '$2a$10$/a5l7E7hEMhx1Wm.I/GDxuySxSqz8Sud.ZcwMNBT02VJB9XNL5h7i', 3, 'customer02@gmail.com', '0909000005', '2001-05-12', 'Female', 1),
('Hoang Van E', '$2a$10$H/hz51dfW781VMlzSO4nROCjjvadpx4qHbi/GAnjKcvgUct4Mvc1q', 3, 'customer03@gmail.com', '0909000006', '1999-09-09', 'Male', 1);

-- Employee
INSERT INTO Employee (UserID, Role)
VALUES
(2, 'Cashier'),
(3, 'Waiter');

-- Customer
INSERT INTO Customer (UserID, LoyaltyPoint, LastEarnedDate)
VALUES
(4, 20, '2025-10-20 14:30:00'),
(5, 20, '2025-10-18 10:15:00'),
(6, 5, '2025-10-19 16:45:00');

-- Product table

CREATE TABLE Product (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    ProductName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(255),
    Price DECIMAL(10,2) NOT NULL,
    Category NVARCHAR(50),
    ImageURL NVARCHAR(255),
    IsAvailable BIT DEFAULT 1
);

-- Sample Product data
INSERT INTO Product (ProductName, Description, Price, Category, ImageURL)
VALUES 
(N'Iced Milk Coffee', N'Coffee brewed with condensed milk', 25000, N'Coffee', N'icedMilkCoffee.jpg'),
(N'Peach Orange Tea', N'Fresh peach tea with orange', 30000, N'Tea', N'peachOrangeTea.jpg'),
(N'Mango Smoothie', N'Fresh fruit smoothie', 35000, N'Smoothie', N'mangSmoothie.jpg');

-- Inventory table
CREATE TABLE Inventory (
    InventoryID INT IDENTITY(1,1) PRIMARY KEY,
    ItemName NVARCHAR(100) NOT NULL,
    Quantity DECIMAL(10,2) DEFAULT 0,
    Unit NVARCHAR(50),
    LastUpdated DATETIME DEFAULT GETDATE()
);

-- Sample Inventory data
INSERT INTO Inventory (ItemName, Quantity, Unit)
VALUES 
(N'Ground Coffee', 10, N'kg'),
(N'Condensed Milk', 5, N'liter'),
(N'Sliced Peach', 2, N'kg'),
(N'Dried Tea', 3, N'kg'),
(N'Fresh Mango', 8, N'kg');

-- ProductIngredients table
CREATE TABLE ProductIngredients (
    ProductID INT FOREIGN KEY REFERENCES Product(ProductID),
    InventoryID INT FOREIGN KEY REFERENCES Inventory(InventoryID),
    QuantityNeeded DECIMAL(10,2) NOT NULL,
    Unit NVARCHAR(50),
    PRIMARY KEY (ProductID, InventoryID)
);

-- Sample ProductIngredients data
INSERT INTO ProductIngredients (ProductID, InventoryID, QuantityNeeded, Unit)
VALUES 
(1, 1, 0.05, N'kg'),      -- Iced Milk Coffee uses Ground Coffee
(1, 2, 0.02, N'liter'),   -- Condensed Milk
(2, 3, 0.05, N'kg'),      -- Peach Orange Tea uses Sliced Peach
(2, 4, 0.02, N'kg'),      -- Dried Tea
(3, 5, 0.15, N'kg');      -- Mango Smoothie uses Fresh Mango

-- Order table
CREATE TABLE [Order] (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT FOREIGN KEY REFERENCES Customer(CustomerID),
    EmployeeID INT FOREIGN KEY REFERENCES Employee(EmployeeID),
    TableID INT NULL,
    OrderDate DATETIME DEFAULT GETDATE(),
    [Status] INT DEFAULT 0,         -- 0 = Pending, 1 = Preparing, 2 = Served, 3 = Completed, 4 = Cancelled
    PaymentStatus NVARCHAR(50) CHECK (PaymentStatus IN ('Unpaid', 'Paid')),     -- 'Unpaid', 'Paid'
    TotalPrice DECIMAL(10,2) DEFAULT 0,
    Note NVARCHAR(255)
);
ALTER TABLE [Order]
ADD CONSTRAINT CHK_Status CHECK ([Status] IN (0, 1, 2, 3, 4));

-- Sample Order data
INSERT INTO [Order] (CustomerID, EmployeeID, TableID, [Status], PaymentStatus, TotalPrice, Note)
VALUES 
(1, 1, 5, 0, N'Unpaid', 55000, N'Customer wants less sugar'),
(1, 2, 3, 1, N'Paid', 35000, N'Regular customer'),
(2, 2, 2, 3, N'Paid', 60000, N'Delivery completed');

-- OrderDetail table
CREATE TABLE OrderDetail (
    OrderDetailID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT FOREIGN KEY REFERENCES [Order](OrderID),
    ProductID INT FOREIGN KEY REFERENCES Product(ProductID),
    Quantity INT NOT NULL,
    TotalPrice DECIMAL(10,2),
    SpecialInstructions NVARCHAR(255)
);

-- Sample OrderDetail data
INSERT INTO OrderDetail (OrderID, ProductID, Quantity, TotalPrice, SpecialInstructions)
VALUES
(1, 1, 1, 25000, N'Less ice'),
(1, 2, 1, 30000, N'No sugar'),
(2, 3, 1, 35000, NULL),
(3, 1, 2, 50000, NULL),
(3, 2, 1, 10000, N'Combo discount');

-- Discount table
CREATE TABLE Discount (
    DiscountID INT IDENTITY(1,1) PRIMARY KEY,   
    Description NVARCHAR(255),
    DiscountType NVARCHAR(50) CHECK (DiscountType IN ('Percentage', 'Fixed', 'Loyalty')), -- 'Percentage', 'Fixed', 'Loyalty'
    Value DECIMAL(10,2),
    MaxDiscount DECIMAL(10,2),
    MinOrderTotal DECIMAL(10,2) DEFAULT 0,
    StartDate DATE,
    EndDate DATE,
    IsActive BIT DEFAULT 1
);

-- Sample Discount data
INSERT INTO Discount (Description, DiscountType, Value, MaxDiscount, MinOrderTotal, StartDate, EndDate, IsActive)
VALUES
(N'Loyalty point redemption', 'Loyalty', 100, NULL, 0, '2025-10-01', NULL, 1),
(N'10% off all drinks', 'Percentage', 10, NULL, 0, '2025-10-01', '2025-10-31', 1),
(N'20.000VND off for orders over 200.000VND', 'Fixed', 20000, NULL, 200000, '2025-10-15', '2025-11-15', 1),
(N'15% off for orders over 150.000VND', 'Percentage', 15, 30000, 150000, '2025-10-10', '2025-10-25', 1);

-- OrderDiscount table
CREATE TABLE OrderDiscount (
    OrderID INT FOREIGN KEY REFERENCES [Order](OrderID),
    DiscountID INT FOREIGN KEY REFERENCES Discount(DiscountID),
    Amount DECIMAL(10,2) NOT NULL,
    AppliedDate DATETIME DEFAULT GETDATE(),
    PRIMARY KEY (OrderID, DiscountID)
);
