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
    Gender NVARCHAR(10) CHECK (Gender IN ('Male', 'Female', 'Other')),
    IsActive BIT DEFAULT 1
);
GO

-- Table: Employee - specific information for employees
CREATE TABLE Employee (
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL UNIQUE FOREIGN KEY REFERENCES [User](UserID),
    Role NVARCHAR(50) NOT NULL CHECK (Role IN ('Manager', 'Cashier', 'Waiter', 'Chef'))
);
GO

-- Table: Customer - specific information for customers
CREATE TABLE Customer (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL UNIQUE FOREIGN KEY REFERENCES [User](UserID),
    LoyaltyPoint INT DEFAULT 0,
    LastEarnedDate DATETIME NULL
);
GO

-- Table: Product
CREATE TABLE Product (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    ProductName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(255),
    Price DECIMAL(10,2) NOT NULL,
    Category NVARCHAR(50),
    ImageURL NVARCHAR(255),
    IsAvailable BIT DEFAULT 1
);
GO

-- Table: Inventory
CREATE TABLE Inventory (
    InventoryID INT IDENTITY(1,1) PRIMARY KEY,
    ItemName NVARCHAR(100) NOT NULL,
    Quantity DECIMAL(10,2) DEFAULT 0,
    Unit NVARCHAR(50),
    LastUpdated DATETIME DEFAULT GETDATE()
);
GO

-- Table: ProductIngredients
CREATE TABLE ProductIngredients (
    ProductID INT FOREIGN KEY REFERENCES Product(ProductID),
    InventoryID INT FOREIGN KEY REFERENCES Inventory(InventoryID),
    QuantityNeeded DECIMAL(10,2) NOT NULL,
    Unit NVARCHAR(50),
    PRIMARY KEY (ProductID, InventoryID)
);
GO

-- Table: [Table]
CREATE TABLE [Table] (
    TableID INT IDENTITY(1,1) PRIMARY KEY,
    TableNumber NVARCHAR(10) NOT NULL UNIQUE,
    Capacity INT NOT NULL CHECK (Capacity > 0),
    [Status] NVARCHAR(20) DEFAULT 'available' CHECK ([Status] IN ('available', 'unavailable')),
    IsActive BIT DEFAULT 1
);
GO

-- Table: [Order]
CREATE TABLE [Order] (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT FOREIGN KEY REFERENCES Customer(CustomerID),
    EmployeeID INT FOREIGN KEY REFERENCES Employee(EmployeeID),
    TableID INT NULL FOREIGN KEY REFERENCES [Table](TableID),
    OrderDate DATETIME DEFAULT GETDATE(),
    [Status] INT DEFAULT 0 CHECK ([Status] IN (0, 1, 2, 3, 4)), -- 0=Pending, 1=Preparing, 2=Served, 3=Completed, 4=Cancelled
    PaymentStatus NVARCHAR(50) DEFAULT 'Unpaid' CHECK (PaymentStatus IN ('Unpaid', 'Paid')),
    TotalPrice DECIMAL(10,2) DEFAULT 0,
    Note NVARCHAR(255)
);
GO

-- Table: OrderDetail
CREATE TABLE OrderDetail (
    OrderDetailID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT NOT NULL FOREIGN KEY REFERENCES [Order](OrderID),
    ProductID INT NOT NULL FOREIGN KEY REFERENCES Product(ProductID),
    Quantity INT NOT NULL,
    TotalPrice DECIMAL(10,2),
    SpecialInstructions NVARCHAR(255)
);
GO

-- Table: Discount
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

-- Table: OrderDiscount
CREATE TABLE OrderDiscount (
    OrderID INT FOREIGN KEY REFERENCES [Order](OrderID),
    DiscountID INT FOREIGN KEY REFERENCES Discount(DiscountID),
    Amount DECIMAL(10,2) NOT NULL,
    AppliedDate DATETIME DEFAULT GETDATE(),
    PRIMARY KEY (OrderID, DiscountID)
);
GO

-- Table: PasswordTokens
CREATE TABLE PasswordTokens (
    Token NVARCHAR(20) PRIMARY KEY,
    UserID INT NOT NULL FOREIGN KEY REFERENCES [User](UserID) ON DELETE CASCADE,
    NewPasswordHash NVARCHAR(255) NOT NULL,
    ExpiresAt DATETIME2 NOT NULL DEFAULT DATEADD(MINUTE, 5, SYSDATETIME()),
    Used BIT NOT NULL DEFAULT 0
);
GO

-- Table: DeletionQueue
CREATE TABLE DeletionQueue (
    QueueID INT IDENTITY(1,1) PRIMARY KEY,
    EntityType NVARCHAR(20) NOT NULL,  -- 'Table', 'Product', etc.
    EntityID INT NOT NULL,
    ScheduledDeletion DATETIME NOT NULL DEFAULT DATEADD(DAY, 1, CAST(GETDATE() AS DATE)),
    
    -- Unique constraint to prevent duplicate scheduling
    CONSTRAINT UK_DeletionQueue_Entity UNIQUE (EntityType, EntityID)
);
GO

-- ===========================
-- SAMPLE DATA
-- ===========================

-- Admin
INSERT INTO [User] (Name, Password, Role, Email, Phone, [DateOfBirth], Gender, IsActive)
VALUES 
('Admin 01', '$2a$10$wA1.VHtxxp1i0a.SY2SFO.f45v.G/syMrruqnfJHGIEYCjiFTUSgW', 1, 'admin01@pizzastore.com', '0909000001', '1990-01-01', 'Male', 1);
GO

-- Employee
INSERT INTO [User] (Name, Password, Role, Email, Phone, [DateOfBirth], Gender, IsActive)
VALUES
('Nguyen Van A', '$2a$10$bJskj.kelsRTuCHDBHkQJu2z0NQSUzivBArkjVNmiybd7ab4IxEC2', 2, 'employee01@pizzastore.com', '0909000002', '1995-03-15', 'Male', 1),
('Tran Thi B', '$2a$10$bxDhNBnj3nQoTq2vNVhBUeKXQovbEGigBGtNdm2LLZNSQ5VYMrdbG', 2, 'employee02@pizzastore.com', '0909000003', '1998-08-20', 'Female', 1);
GO

-- Customer
INSERT INTO [User] (Name, Password, Role, Email, Phone, [DateOfBirth], Gender, IsActive)
VALUES
('Le Van C', '$2a$10$8T7NzU1acsG44ojiWCaMyuc1/hj690KUvnnBLLSHYRfrK5.dqw3MG', 3, 'customer01@gmail.com', '0909000004', '2000-02-02', 'Male', 1),
('Pham Thi D', '$2a$10$/a5l7E7hEMhx1Wm.I/GDxuySxSqz8Sud.ZcwMNBT02VJB9XNL5h7i', 3, 'customer02@gmail.com', '0909000005', '2001-05-12', 'Female', 1),
('Hoang Van E', '$2a$10$H/hz51dfW781VMlzSO4nROCjjvadpx4qHbi/GAnjKcvgUct4Mvc1q', 3, 'customer03@gmail.com', '0909000006', '1999-09-09', 'Male', 1);
GO

-- Employee
INSERT INTO Employee (UserID, Role)
VALUES
(2, 'Cashier'),
(3, 'Waiter');
GO

-- Customer
INSERT INTO Customer (UserID, LoyaltyPoint, LastEarnedDate)
VALUES
(4, 20, '2025-10-20 14:30:00'),
(5, 20, '2025-10-18 10:15:00'),
(6, 5, '2025-10-19 16:45:00');
GO

-- Product data
INSERT INTO Product (ProductName, Description, Price, Category)
VALUES 
('Margherita Pizza', 'Classic pizza with tomato and mozzarella', 259000, 'Pizza'),
('Pepperoni Pizza', 'Pizza with pepperoni and cheese', 299000, 'Pizza'),
('Caesar Salad', 'Fresh salad with caesar dressing', 179000, 'Salad'),
('Grilled Salmon', 'Fresh salmon with vegetables', 459000, 'Main Course'),
('Pasta Carbonara', 'Creamy pasta with bacon', 319000, 'Pasta'),
('Tiramisu', 'Classic Italian dessert', 139000, 'Dessert'),
('Red Wine', 'House red wine glass', 159000, 'Drinks'),
('Coca Cola', 'Soft drink', 59000, 'Drinks'),
('Hawaiian Pizza', 'Pizza with ham and pineapple', 279000, 'Pizza'),
('Seafood Pizza', 'Pizza with mixed seafood', 329000, 'Pizza'),
('Four Cheese Pizza', 'Pizza with four types of cheese', 289000, 'Pizza'),
('Greek Salad', 'Salad with feta cheese and olives', 189000, 'Salad'),
('Caprese Salad', 'Tomato and mozzarella salad', 169000, 'Salad'),
('Grilled Chicken', 'Grilled chicken with herbs', 239000, 'Main Course'),
('Beef Steak', 'Premium beef steak', 589000, 'Main Course'),
('Lasagna', 'Classic Italian lasagna', 269000, 'Pasta'),
('Spaghetti Bolognese', 'Spaghetti with meat sauce', 219000, 'Pasta'),
('Chocolate Cake', 'Rich chocolate cake', 119000, 'Dessert'),
('Cheesecake', 'New York style cheesecake', 129000, 'Dessert'),
('Ice Cream', 'Vanilla ice cream', 79000, 'Dessert'),
('Orange Juice', 'Fresh orange juice', 69000, 'Drinks'),
('Lemonade', 'Homemade lemonade', 49000, 'Drinks'),
('Coffee', 'Vietnamese coffee', 39000, 'Drinks'),
('Green Tea', 'Japanese green tea', 29000, 'Drinks');
GO

-- Inventory data
INSERT INTO Inventory (ItemName, Quantity, Unit)
VALUES 
('Flour', 50, 'kg'),
('Tomato Sauce', 20, 'liter'),
('Mozzarella Cheese', 15, 'kg'),
('Pepperoni', 10, 'kg'),
('Salmon', 8, 'kg'),
('Pasta', 25, 'kg'),
('Lettuce', 5, 'kg'),
('Wine', 30, 'bottle'),
('Pineapple', 15, 'kg'),
('Ham', 12, 'kg'),
('Mixed Seafood', 8, 'kg'),
('Feta Cheese', 6, 'kg'),
('Olives', 4, 'kg'),
('Chicken Breast', 20, 'kg'),
('Beef', 10, 'kg'),
('Lasagna Sheets', 8, 'kg'),
('Chocolate', 5, 'kg'),
('Cream Cheese', 7, 'kg'),
('Vanilla', 2, 'kg'),
('Oranges', 25, 'kg'),
('Lemons', 15, 'kg'),
('Coffee Beans', 12, 'kg'),
('Green Tea Leaves', 3, 'kg'),
( 'Cheese Powder', 2, 'kg'),
( 'Coffee Beans', 10, 'kg'),
( 'Chocolate Syrup', 8, 'liters'),
( 'Whipping Cream', 6, 'liters'),
( 'Matcha Powder', 3, 'kg'),
( 'Strawberry Sauce', 7, 'liters'),
( 'Blueberry Sauce', 5, 'liters'),
( 'Green Tea Leaves', 4, 'kg');
GO       

-- ProductIngredients data
INSERT INTO ProductIngredients (ProductID, InventoryID, QuantityNeeded, Unit)
VALUES 
(1, 1, 0.3, 'kg'),      -- Margherita Pizza uses Flour
(1, 2, 0.1, 'liter'),   -- Margherita Pizza uses Tomato Sauce
(1, 3, 0.2, 'kg'),      -- Margherita Pizza uses Mozzarella
(2, 1, 0.3, 'kg'),      -- Pepperoni Pizza uses Flour
(2, 2, 0.1, 'liter'),   -- Pepperoni Pizza uses Tomato Sauce
(2, 4, 0.15, 'kg'),     -- Pepperoni Pizza uses Pepperoni
(5, 6, 0.2, 'kg'),      -- Pasta Carbonara uses Pasta
(9, 1, 0.3, 'kg'),      -- Hawaiian Pizza uses Flour
(9, 2, 0.1, 'liter'),   -- Hawaiian Pizza uses Tomato Sauce
(9, 17, 0.15, 'kg'),    -- Hawaiian Pizza uses Pineapple
(9, 18, 0.12, 'kg'),    -- Hawaiian Pizza uses Ham
(10, 1, 0.3, 'kg'),     -- Seafood Pizza uses Flour
(10, 2, 0.1, 'liter'),  -- Seafood Pizza uses Tomato Sauce
(10, 19, 0.2, 'kg'),    -- Seafood Pizza uses Mixed Seafood
(11, 1, 0.3, 'kg'),     -- Four Cheese Pizza uses Flour
(11, 2, 0.1, 'liter'),  -- Four Cheese Pizza uses Tomato Sauce
(11, 3, 0.25, 'kg'),    -- Four Cheese Pizza uses more Cheese
(12, 20, 0.15, 'kg'),   -- Greek Salad uses Feta Cheese
(12, 21, 0.05, 'kg'),   -- Greek Salad uses Olives
(13, 3, 0.1, 'kg'),     -- Caprese Salad uses Mozzarella
(14, 22, 0.25, 'kg'),   -- Grilled Chicken uses Chicken Breast
(15, 23, 0.3, 'kg'),    -- Beef Steak uses Beef
(16, 1, 0.1, 'kg'),     -- Lasagna uses Flour
(16, 24, 0.15, 'kg'),   -- Lasagna uses Lasagna Sheets
(17, 6, 0.2, 'kg'),     -- Spaghetti Bolognese uses Pasta
(18, 25, 0.15, 'kg'),   -- Chocolate Cake uses Chocolate
(19, 26, 0.2, 'kg'),    -- Cheesecake uses Cream Cheese
(20, 27, 0.08, 'kg'),   -- Ice Cream uses Vanilla
(21, 28, 0.4, 'kg'),    -- Orange Juice uses Oranges
(22, 29, 0.1, 'kg'),    -- Lemonade uses Lemons
(23, 30, 0.02, 'kg'),   -- Coffee uses Coffee Beans
(24, 31, 0.01, 'kg');   -- Green Tea uses Green Tea Leaves
GO

-- Table data
INSERT INTO [Table] (TableNumber, Capacity) VALUES
('T01', 2),
('T02', 2),
('T03', 4),
('T04', 4),
('T05', 4),
('T06', 6),
('T07', 6),
('T08', 6),
('T09', 8),
('T10', 8),
('T11', 10),
('T12', 10);
GO

-- Order data
INSERT INTO [Order] (CustomerID, EmployeeID, TableID, [Status], PaymentStatus, TotalPrice, Note)
VALUES 
(1, 1, 5, 1, 'Unpaid', 919000, 'Extra cheese please'),
(1, 2, 3, 2, 'Paid', 579000, 'Regular customer'),
(2, 2, 2, 3, 'Paid', 1319000, 'Birthday celebration'),
(1, 1, 7, 0, 'Unpaid', 847000, 'Family dinner'),
(2, 2, 4, 1, 'Unpaid', 1235000, 'Business meeting'),
(3, 1, 9, 2, 'Paid', 658000, 'Quick lunch'),
(1, 2, NULL, 3, 'Paid', 389000, 'Takeaway order'),
(2, 1, 11, 0, 'Unpaid', 2147000, 'Big group celebration'),
(3, 2, 2, 1, 'Unpaid', 729000, 'Date night'),
(1, 1, 5, 2, 'Paid', 947000, 'Regular customer'),
(2, 2, 8, 3, 'Paid', 538000, 'Finished'),
(3, 1, 3, 0, 'Unpaid', 1123000, 'Waiting for friends'),
(3, 2, 2, 0, 'Unpaid', 329000, 'Customer ordered a large pizza and drink');
GO

-- OrderDetail data
INSERT INTO OrderDetail (OrderID, ProductID, Quantity, TotalPrice, SpecialInstructions)
VALUES
(1, 1, 1, 259000, 'Extra cheese'), (1, 7, 2, 318000, NULL), (1, 8, 3, 177000, 'No ice'),
(2, 2, 1, 299000, NULL), (2, 3, 1, 179000, 'Dressing on side'),
(3, 4, 2, 918000, 'Well done'), (3, 6, 2, 278000, NULL), (3, 7, 1, 159000, NULL),
(4, 9, 1, 279000, 'Extra pineapple'), (4, 21, 2, 138000, 'Fresh squeezed'), (4, 8, 2, 118000, NULL), (4, 20, 1, 79000, 'Extra scoop'), (4, 24, 1, 29000, 'Hot'), (4, 16, 1, 269000, 'Extra cheese'),
(5, 15, 2, 1178000, 'Medium rare'), (5, 7, 1, 159000, 'Best wine'), (5, 19, 2, 258000, NULL),
(6, 17, 2, 438000, 'Al dente'), (6, 3, 1, 179000, 'Extra dressing'), (6, 22, 2, 98000, 'Less sugar'),
(7, 8, 1, 59000, 'Takeaway'), (7, 16, 1, 269000, 'Takeaway'), (7, 18, 1, 119000, 'Takeaway'),
(8, 10, 2, 658000, 'Extra seafood'), (8, 15, 1, 589000, 'Well done'), (8, 11, 1, 289000, NULL), (8, 7, 3, 477000, NULL), (8, 13, 2, 138000, NULL),
(9, 2, 1, 299000, 'Extra pepperoni'), (9, 3, 1, 179000, NULL), (9, 7, 2, 318000, NULL), (9, 18, 1, 119000, NULL), (9, 21, 2, 138000, NULL),
(10, 1, 1, 259000, 'Classic'), (10, 8, 2, 118000, NULL), (10, 12, 1, 189000, NULL), (10, 19, 1, 129000, NULL), (10, 23, 2, 78000, 'Strong'),
(11, 4, 1, 459000, 'With rice'), (11, 14, 1, 239000, 'Grilled well'), (11, 21, 2, 138000, NULL), (11, 8, 1, 59000, NULL),
(12, 5, 2, 638000, 'Extra creamy'), (12, 6, 1, 139000, NULL), (12, 7, 1, 159000, NULL), (12, 22, 2, 98000, NULL),
(13, 10, 1, 329000, 'Large size'), (13, 11, 1, 289000, NULL), (13, 15, 1, 589000, 'Rare'), (13, 7, 2, 318000, NULL), (13, 18, 2, 238000, NULL);
GO

-- Discount data
INSERT INTO Discount (Description, DiscountType, Value, MaxDiscount, MinOrderTotal, StartDate, EndDate, IsActive)
VALUES
('10% off all orders', 'Percentage', 10, NULL, 0, '2025-01-01', '2025-12-31', 1),
('50.000 VND off orders over 1.000.000 VND', 'Fixed', 50000, 50000, 1000000, '2025-01-01', '2025-12-31', 1),
('Loyalty discount', 'Loyalty', 100, NULL, 0, '2025-01-01', NULL, 1),
('Weekend Special 15%', 'Percentage', 15, 200000, 600000, '2025-01-01', '2025-12-31', 1),
('Happy Hour 20%', 'Percentage', 20, 100000, 300000, '2025-01-01', '2025-12-31', 1),
('Student Discount 15%', 'Percentage', 15, 150000, 200000, '2025-01-01', '2025-12-31', 1),
('Family Meal 25%', 'Percentage', 25, 250000, 800000, '2025-01-01', '2025-12-31', 1),
('Birthday Special 30%', 'Percentage', 30, 300000, 500000, '2025-01-01', '2025-12-31', 1),
('Early Bird 10%', 'Percentage', 10, 100000, 150000, '2025-01-01', '2025-12-31', 1),
('Free Dessert', 'Fixed', 139000, 139000, 500000, '2025-01-01', '2025-12-31', 1),
('Combo Pizza + Drink', 'Fixed', 50000, 50000, 300000, '2025-01-01', '2025-12-31', 1);
GO

-- ===========================
-- PROCEDURE FOR SCHEDULED DELETION (Generic for multiple tables)
-- ===========================
CREATE PROCEDURE ScheduleDeletion
    @EntityType NVARCHAR(20),
    @EntityID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ScheduledTime DATETIME = DATEADD(DAY, 1, CAST(GETDATE() AS DATE)); -- 00:00 tomorrow
    
    -- Check if entity already exists in queue
    IF NOT EXISTS (SELECT 1 FROM DeletionQueue WHERE EntityType = @EntityType AND EntityID = @EntityID)
    BEGIN
        INSERT INTO DeletionQueue (EntityType, EntityID, ScheduledDeletion)
        VALUES (@EntityType, @EntityID, @ScheduledTime);
    END
END
GO

-- ===========================
-- PROCEDURE FOR SCHEDULED DISCOUNT UPDATE (Specific for Discount table)
-- ===========================
CREATE PROCEDURE ScheduleDiscountUpdate
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
    
    DECLARE @ScheduledTime DATETIME = DATEADD(DAY, 1, CAST(GETDATE() AS DATE)); -- 00:00 tomorrow
    
    -- Create DiscountUpdateQueue table if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'DiscountUpdateQueue')
    BEGIN
        CREATE TABLE DiscountUpdateQueue (
            QueueID INT IDENTITY(1,1) PRIMARY KEY,
            DiscountID INT NOT NULL,
            Description NVARCHAR(255),
            DiscountType NVARCHAR(50),
            Value DECIMAL(10,2),
            MaxDiscount DECIMAL(10,2),
            MinOrderTotal DECIMAL(10,2),
            StartDate DATE,
            EndDate DATE,
            ScheduledUpdate DATETIME NOT NULL DEFAULT DATEADD(DAY, 1, CAST(GETDATE() AS DATE)),
            CONSTRAINT UK_DiscountUpdateQueue UNIQUE (DiscountID)
        );
    END
    
    -- Insert or update the scheduled update
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
-- PROCEDURE TO PROCESS DELETION QUEUE (Generic for multiple tables)
-- ===========================
CREATE PROCEDURE ProcessDeletionQueue
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Safety check - only run on this database
    IF DB_NAME() != 'pizza_demo_DB2'
    BEGIN
        PRINT 'This procedure is designed for pizza_demo_DB2 only. Current database: ' + DB_NAME();
        RETURN;
    END
    
    DECLARE @QueueID INT, @EntityType NVARCHAR(20), @EntityID INT;
    DECLARE @ProcessedCount INT = 0;
    
    WHILE (1 = 1)
    BEGIN
        -- Get the first item from queue
        SELECT TOP 1 @QueueID = QueueID, @EntityType = EntityType, @EntityID = EntityID
        FROM DeletionQueue
        WHERE ScheduledDeletion <= GETDATE()
        ORDER BY ScheduledDeletion;
        
        -- Break if no more items
        IF @QueueID IS NULL
            BREAK;
        
        BEGIN TRY
            BEGIN TRANSACTION;
            
            -- Process based on entity type
            IF @EntityType = 'Table'
            BEGIN
                UPDATE [Table] SET IsActive = 0 WHERE TableID = @EntityID;
            END
            ELSE IF @EntityType = 'Discount'
            BEGIN
                UPDATE Discount SET IsActive = 0 WHERE DiscountID = @EntityID;
            END
            -- Add more entity types here as needed
            
            -- Remove from queue after successful processing
            DELETE FROM DeletionQueue WHERE QueueID = @QueueID;
            
            SET @ProcessedCount = @ProcessedCount + 1;
            
            COMMIT TRANSACTION;
        END TRY
        BEGIN CATCH
            ROLLBACK TRANSACTION;
            -- Log error and continue with next item
            PRINT 'Error processing QueueID ' + CAST(@QueueID AS NVARCHAR) + ': ' + ERROR_MESSAGE();
            
            -- Break on error to avoid infinite loop
            BREAK;
        END CATCH
        
        -- Reset variables for next iteration
        SET @QueueID = NULL;
        SET @EntityType = NULL;
        SET @EntityID = NULL;
    END
    
    PRINT 'Processed ' + CAST(@ProcessedCount AS NVARCHAR) + ' items from deletion queue.';
END
GO

-- ===========================
-- PROCEDURE TO PROCESS DISCOUNT UPDATE QUEUE (Specific for Discount table)
-- ===========================
CREATE PROCEDURE ProcessDiscountUpdateQueue
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Safety check - only run on this database
    IF DB_NAME() != 'pizza_demo_DB2'
    BEGIN
        PRINT 'This procedure is designed for pizza_demo_DB2 only. Current database: ' + DB_NAME();
        RETURN;
    END
    
    DECLARE @QueueID INT, @DiscountID INT, @Description NVARCHAR(255), @DiscountType NVARCHAR(50);
    DECLARE @Value DECIMAL(10,2), @MaxDiscount DECIMAL(10,2), @MinOrderTotal DECIMAL(10,2);
    DECLARE @StartDate DATE, @EndDate DATE;
    DECLARE @ProcessedCount INT = 0;
    
    WHILE (1 = 1)
    BEGIN
        -- Get the first item from update queue
        SELECT TOP 1 
            @QueueID = QueueID,
            @DiscountID = DiscountID,
            @Description = Description,
            @DiscountType = DiscountType,
            @Value = Value,
            @MaxDiscount = MaxDiscount,
            @MinOrderTotal = MinOrderTotal,
            @StartDate = StartDate,
            @EndDate = EndDate
        FROM DiscountUpdateQueue
        WHERE ScheduledUpdate <= GETDATE()
        ORDER BY ScheduledUpdate;
        
        -- Break if no more items
        IF @QueueID IS NULL
            BREAK;
        
        BEGIN TRY
            BEGIN TRANSACTION;
            
            -- Update the discount directly
            UPDATE Discount 
            SET Description = @Description,
                DiscountType = @DiscountType,
                Value = @Value,
                MaxDiscount = @MaxDiscount,
                MinOrderTotal = @MinOrderTotal,
                StartDate = @StartDate,
                EndDate = @EndDate
            WHERE DiscountID = @DiscountID;
            
            -- Remove from queue after successful processing
            DELETE FROM DiscountUpdateQueue WHERE QueueID = @QueueID;
            
            SET @ProcessedCount = @ProcessedCount + 1;
            
            COMMIT TRANSACTION;
        END TRY
        BEGIN CATCH
            ROLLBACK TRANSACTION;
            -- Log error and continue with next item
            PRINT 'Error processing Update QueueID ' + CAST(@QueueID AS NVARCHAR) + ': ' + ERROR_MESSAGE();
            
            -- Break on error to avoid infinite loop
            BREAK;
        END CATCH
        
        -- Reset variables for next iteration
        SET @QueueID = NULL;
        SET @DiscountID = NULL;
    END
    
    PRINT 'Processed ' + CAST(@ProcessedCount AS NVARCHAR) + ' items from discount update queue.';
END
GO