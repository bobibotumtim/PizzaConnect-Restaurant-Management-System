-- ===============================
-- 🛠️ CREATE AND USE DATABASE 
-- ===============================

CREATE DATABASE pizza_demo_DB;
GO

USE pizza_demo_DB;
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
    Role NVARCHAR(50) NOT NULL CHECK (Role IN ('Manager', 'Cashier', 'Waiter', 'Chef')),
    Specialization NVARCHAR(50) NULL CHECK (Specialization IN ('Pizza', 'Drinks', 'SideDishes', NULL)),
    FOREIGN KEY (UserID) REFERENCES [User](UserID)
);
GO

CREATE TABLE Customer (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL UNIQUE,
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
    Status NVARCHAR(20) NOT NULL DEFAULT 'Active',
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
    [Status] INT DEFAULT 0 CHECK ([Status] IN (0,1,2,3,4)),  -- 0=Waiting,1=Ready,2=Dining,3=Completed,4=Cancelled
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
    [Status] NVARCHAR(50) DEFAULT 'Waiting',-- Waiting, In Progress, Done
    StartTime DATETIME NULL,
    EndTime DATETIME NULL,
    FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID)
);
GO

-- OrderDetailTopping FIXED: ToppingPrice -> ProductPrice
CREATE TABLE OrderDetailTopping (
	OrderDetailToppingID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	OrderDetailID INT NOT NULL FOREIGN KEY REFERENCES OrderDetail(OrderDetailID) ON DELETE CASCADE,
	ProductPrice DECIMAL(10, 2) NOT NULL, -- RENAMED from ToppingPrice
	ProductSizeID INT NOT NULL, -- ProductSizeID of Topping (ProductSizeID of a Topping Product)
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
    DiscountType NVARCHAR(50) CHECK (DiscountType IN ('Percentage', 'Fixed', 'Loyalty')),
    Value DECIMAL(10,2),
    MaxDiscount DECIMAL(10,2),
    MinOrderTotal DECIMAL(10,2) DEFAULT 0,
    StartDate DATE,
    EndDate DATE,
    IsActive BIT DEFAULT 1
);
GO

CREATE TABLE CustomerDiscount (
    CustomerDiscountID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL FOREIGN KEY REFERENCES Customer(CustomerID),
    DiscountID INT NOT NULL FOREIGN KEY REFERENCES Discount(DiscountID),
    Quantity INT DEFAULT 0,
    ExpiryDate DATE,
    IsUsed BIT DEFAULT 0,
    LastEarnedDate DATETIME NULL,
    UsedDate DATETIME NULL,
    CONSTRAINT UK_CustomerDiscount UNIQUE (CustomerID, DiscountID)
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
-- PAYMENT SYSTEM 
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
-- Feedback System
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
('Admin 01', '$2a$10$wA1.VHtxxp1i0a.SY2SFO.f45v.G/syMrruqnfJHGIEYCjiFTUSgW', 1, 'admin01@pizzastore.com', '0909000001', '1990-01-01', 'Male', 1),
('Nguyen Van A', '$2a$10$bJskj.kelsRTuCHDBHkQJu2z0NQSUzivBArkjVNmiybd7ab4IxEC2', 2, 'employee01@pizzastore.com', '0909000002', '1995-03-15', 'Male', 1),
('Tran Thi B', '$2a$10$bxDhNBnj3nQoTq2vNVhBUeKXQovbEGigBGtNdm2LLZNSQ5VYMrdbG', 2, 'employee02@pizzastore.com', '0909000003', '1995-03-15', 'Female', 1),
('Le Van C', '$2a$10$8T7NzU1acsG44ojiWCaMyuc1/hj690KUvnnBLLSHYRfrK5.dqw3MG', 3, 'customer01@gmail.com', '0909000004', '2000-02-02', 'Male', 1),
('Pham Thi D', '$2a$10$/a5l7E7hEMhx1Wm.I/GDxuySxSqz8Sud.ZcwMNBT02VJB9XNL5h7i', 3, 'customer02@gmail.com', '0909000005', '2001-05-12', 'Female', 1),
('Hoang Van E', '$2a$10$H/hz51dfW781VMlzSO4nROCjjvadpx4qHbi/GAnjKcvgUct4Mvc1q', 3, 'customer03@gmail.com', '0909000006', '1999-09-09', 'Male', 1),
('Chef Nguyen', '$2a$10$wA1.VHtxxp1i0a.SY2SFO.f45v.G/syMrruqnfJHGIEYCjiFTUSgW', 2, 'chef01@pizzastore.com', '0909000007', '1992-07-20', 'Male', 1);
GO

-- Employees
INSERT INTO Employee (UserID, Role, Specialization)
VALUES 
(2, 'Cashier', NULL),
(3, 'Waiter', NULL),
(7, 'Chef', 'Pizza');
GO

INSERT INTO Customer (UserID)
VALUES 
(4),
(5),
(6);
GO

-- Categories
INSERT INTO Category (CategoryName, Description)
VALUES 
('Pizza', 'All pizza products'),
('Drink', 'All beverages'),
('Topping', 'Extra toppings');
GO

-- Products (Topping as Product)
INSERT INTO Product (ProductName, Description, CategoryID, ImageURL, IsAvailable)
VALUES 
('Hawaiian Pizza', 'Pizza with ham and pineapple', 1, 'hawaiian.jpg', 1), -- ProductID 1
('Iced Milk Coffee', 'Coffee with condensed milk', 2, 'icedMilkCoffee.jpg', 1), -- ProductID 2
('Peach Orange Tea', 'Peach tea with orange flavor', 2, 'peachOrangeTea.jpg', 1), -- ProductID 3
('Extra Cheese Topping', 'Extra cheese for pizza', 3, 'extraCheese.jpg', 1), -- Topping ProductID 4
('Sausage Topping', 'Sausage topping', 3, 'sausage.jpg', 1); -- Topping ProductID 5
GO

-- Product sizes & prices
INSERT INTO ProductSize (ProductID, SizeCode, SizeName, Price)
VALUES
(1, 'S', 'Small', 120000), -- Pizza S (ProductSizeID 1)
(1, 'M', 'Medium', 160000), -- Pizza M (ProductSizeID 2)
(1, 'L', 'Large', 200000), -- Pizza L (ProductSizeID 3)
(2, 'F', 'Fixed', 25000), -- Coffee F (ProductSizeID 4)
(3, 'F', 'Fixed', 30000), -- Tea F (ProductSizeID 5)
(4, 'F', 'Fixed', 15000), -- Topping Extra Cheese F (ProductSizeID 6) -> ProductPrice
(5, 'F', 'Fixed', 20000); -- Topping Sausage F (ProductSizeID 7) -> ProductPrice
GO

-- Inventory
INSERT INTO Inventory (ItemName, Quantity, Unit, Status)
VALUES 
('Dough', 10, 'kg', 'Active'), ('Cheese', 5, 'kg', 'Active'), ('Ham', 3, 'kg', 'Active'), ('Pineapple', 2, 'kg', 'Active'),
('Ground Coffee', 10, 'kg', 'Active'), ('Condensed Milk', 5, 'liter', 'Active'), ('Sliced Peach', 2, 'kg', 'Active'), ('Dried Tea', 3, 'kg', 'Active'),
('Topping Cheese Stock', 5, 'kg', 'Active'), ('Topping Sausage Stock', 4, 'kg', 'Active');
GO

-- Ingredients by size
INSERT INTO ProductIngredient (ProductSizeID, InventoryID, QuantityNeeded, Unit)
VALUES
(1, 1, 0.25, 'kg'), (1, 2, 0.10, 'kg'), (1, 3, 0.08, 'kg'), (1, 4, 0.05, 'kg'),
(4, 5, 0.05, 'kg'), (4, 6, 0.02, 'liter'),
(5, 7, 0.05, 'kg'), (5, 8, 0.02, 'kg'),
(6, 9, 0.05, 'kg'),
(7, 10, 0.05, 'kg');
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
(1, 1, 5, 0, 'Unpaid', 120000, 'Order 1: Pizza S'), -- OrderID 1
(1, 2, 3, 1, 'Unpaid', 55000, 'Order 2: Coffee + Tea'), -- OrderID 2
(2, 2, 2, 3, 'Paid', 135000, 'Order 3: Pizza S + Extra Cheese Topping'); -- OrderID 3
GO

-- Order details (Main items)
INSERT INTO OrderDetail (OrderID, ProductSizeID, Quantity, TotalPrice, SpecialInstructions, EmployeeID, [Status], StartTime, EndTime)
VALUES
(1, 1, 1, 120000, NULL, 3, 'In Progress', GETDATE(), NULL), -- OrderDetailID 1: Pizza S (Order 1)
(2, 4, 1, 25000, 'Less ice', NULL, 'Waiting', NULL, NULL), -- OrderDetailID 2: Coffee F (Order 2)
(2, 5, 1, 30000, 'No sugar', NULL, 'Waiting', NULL, NULL), -- OrderDetailID 3: Tea F (Order 2)
(3, 1, 1, 120000, NULL, 3, 'Done', DATEADD(MINUTE, -30, GETDATE()), GETDATE()); -- OrderDetailID 4: Pizza S (Order 3)
GO

-- OrderDetailTopping (Attach Topping Product to main OrderDetail)
-- OrderDetail 4 (Pizza S) has Extra Cheese Topping (ProductSizeID 6)
INSERT INTO OrderDetailTopping (OrderDetailID, ProductSizeID, ProductPrice)
VALUES
(4, 6, 15000); -- OrderDetailToppingID 1: Attach Cheese Topping (ID 6) to Pizza (OrderDetail ID 4). ProductPrice is fixed price of ProductSizeID 6.
GO

-- Discounts
INSERT INTO Discount (Description, DiscountType, Value, MaxDiscount, MinOrderTotal, StartDate, EndDate, IsActive)
VALUES
('10% off drinks', 'Percentage', 10, NULL, 0, '2025-10-01', '2025-10-31', 1),
('Fixed 20K off over 200K', 'Fixed', 20000, NULL, 200000, '2025-10-15', '2025-11-15', 1),
('Loyalty points', 'Loyalty', 100, NULL, 0, '2025-10-01', NULL, 1);
GO

-- ===============================
-- 📊 VIEW (No changes)
-- ===============================

CREATE VIEW v_ProductSizeAvailable
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

-- ===========================
-- ⚙️ PROCEDURES (Updated with new DB name)
-- ===========================
CREATE PROCEDURE ScheduleDeletion
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
CREATE PROCEDURE ProcessDeletionQueue
AS
BEGIN
    SET NOCOUNT ON;
    
    IF DB_NAME() != 'pizza_demo_DB'
    BEGIN
        PRINT 'This procedure is designed for pizza_demo_DB only. Current database: ' + DB_NAME();
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
-- SQL Server Agent Jobs
-- ===========================

USE msdb;
GO

-- Create job for deletion queue
EXEC dbo.sp_add_job
    @job_name = N'ProcessDeletionQueue_pizza_demo_DB',
    @enabled = 1,
    @description = N'Process scheduled deletions daily at 00:00 - pizza_demo_DB only';

-- Add job step for deletion queue
EXEC sp_add_jobstep
    @job_name = N'ProcessDeletionQueue_pizza_demo_DB',
    @step_name = N'ProcessDeletionQueue',
    @subsystem = N'TSQL',
    @command = N'EXEC ProcessDeletionQueue',
    @database_name = N'pizza_demo_DB';

-- Add schedule (run daily at 00:01)
EXEC sp_add_schedule
    @schedule_name = N'DailyMidnight',
    @freq_type = 4, -- Daily
    @freq_interval = 1,
    @active_start_time = 000100; -- 00:01

-- Attach schedule to the job
EXEC sp_attach_schedule
    @job_name = N'ProcessDeletionQueue_pizza_demo_DB',
    @schedule_name = N'DailyMidnight';

-- Add job to SQL Server Agent
EXEC sp_add_jobserver
    @job_name = N'ProcessDeletionQueue_pizza_demo_DB';
GO