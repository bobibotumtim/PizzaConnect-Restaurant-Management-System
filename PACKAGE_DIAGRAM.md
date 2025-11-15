# Package Diagram - Pizza Restaurant Management System

## System Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         PRESENTATION LAYER                              │
│                              (web/)                                     │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌──────────────────┐         ┌──────────────────┐                    │
│  │   view/*.jsp     │         │  partials/*.jsp  │                    │
│  │                  │         │                  │                    │
│  │ - Login.jsp      │         │ - NavBar.jsp     │                    │
│  │ - Home.jsp       │         │ - Sidebar.jsp    │                    │
│  │ - Dashboard.jsp  │         │ - CustomerFeedback│                   │
│  │ - pos.jsp        │         │                  │                    │
│  │ - ChefMonitor.jsp│         │                  │                    │
│  │ - ManageProduct  │         │                  │                    │
│  │ - ManageOrders   │         │                  │                    │
│  │ - Payment.jsp    │         │                  │                    │
│  │ - Feedback.jsp   │         │                  │                    │
│  └────────┬─────────┘         └──────────────────┘                    │
│           │                                                            │
└───────────┼────────────────────────────────────────────────────────────┘
            │ HTTP Request/Response
            ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                         CONTROLLER LAYER                                │
│                        (src/java/controller)                            │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │  Authentication & User Management                               │  │
│  │  - LoginServlet, LogoutServlet, SignupServlet                   │  │
│  │  - ForgotPasswordServlet, VerifyCodeServlet                     │  │
│  │  - UserProfileServlet, ManagerUserManagementServlet             │  │
│  │  - AddUserServlet, EditUserServlet                              │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │  Product Management                                             │  │
│  │  - ManageProductServlet, AddProductServlet, EditProductServlet  │  │
│  │  - DeleteProductServlet, ViewProductSizesServlet                │  │
│  │  - AddProductSizeServlet, EditProductSizeServlet                │  │
│  │  - DeleteProductSizeServlet, LoadAddSizeFormServlet             │  │
│  │  - ManageCategoryServlet                                        │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │  Order Management                                               │  │
│  │  - POSServlet, SimplePOSServlet                                 │  │
│  │  - OrderController, ManageOrderServlet                          │  │
│  │  - OrderDetailServlet, OrderHistoryServlet                      │  │
│  │  - AssignTableServlet                                           │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │  Kitchen & Chef Management                                      │  │
│  │  - ChefMonitorServlet                                           │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │  Payment & Billing                                              │  │
│  │  - PaymentServlet, BillServlet                                  │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │  Feedback Management                                            │  │
│  │  - CustomerFeedbackServlet, SimpleFeedbackServlet               │  │
│  │  - FeedbackFormServlet, FeedbackPromptServlet                   │  │
│  │  - FeedbackConfirmationServlet, PostPaymentFeedbackServlet      │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │  Inventory Management                                           │  │
│  │  - InventoryServlet, InventoryServletSimple                     │  │
│  │  - InventoryMonitorServlet, SimpleInventoryMonitorServlet       │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │  Table Management                                               │  │
│  │  - TableServlet, TableLockServlet                               │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │  Discount Management                                            │  │
│  │  - DiscountServlet, DiscountImportServlet                       │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │  Dashboard & Reports                                            │  │
│  │  - DashboardController, ManagerDashboardServlet                 │  │
│  │  - WaiterDashboardServlet, WaiterMonitorServlet                 │  │
│  │  - SalesReportServlet                                           │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │  Customer Features                                              │  │
│  │  - CustomerMenuServlet, HomeServlet                             │  │
│  │  - ChatBotServlet                                               │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│                                                                         │
└───────────────────────────┬─────────────────────────────────────────────┘
                            │ Calls DAO methods
                            ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                         FILTER LAYER                                    │
│                        (src/java/filter)                                │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │  Security & Authorization                                       │  │
│  │  - RoleFilter (Role-based access control)                       │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                         DATA ACCESS LAYER (DAO)                         │
│                          (src/java/dao)                                 │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │  Database Connection                                            │  │
│  │  - DBContext (Database connection management)                   │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │  User & Authentication DAOs                                     │  │
│  │  - UserDAO, EmployeeDAO, CustomerDAO                            │  │
│  │  - TokenDAO (Password reset tokens)                             │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │  Product Management DAOs                                        │  │
│  │  - ProductDAO, ProductSizeDAO, CategoryDAO                      │  │
│  │  - ToppingDAO                                                   │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │  Order Management DAOs                                          │  │
│  │  - OrderDAO, OrderDetailDAO                                     │  │
│  │  - OrderDetailToppingDAO, OrderDiscountDAO                      │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │  Inventory Management DAOs                                      │  │
│  │  - InventoryDAO, InventoryMonitorDAO                            │  │
│  │  - ProductIngredientDAO                                         │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │  Payment & Billing DAOs                                         │  │
│  │  - PaymentDAO                                                   │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │  Feedback DAOs                                                  │  │
│  │  - FeedbackDAO, CustomerFeedbackDAO                             │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │  Table Management DAOs                                          │  │
│  │  - TableDAO                                                     │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │  Discount DAOs                                                  │  │
│  │  - DiscountDAO                                                  │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │  Reporting DAOs                                                 │  │
│  │  - SalesReportDAO                                               │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│                                                                         │
└───────────────────────────┬─────────────────────────────────────────────┘
                            │ Uses Models
                            ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                         MODEL LAYER (Domain Objects)                    │
│                          (src/java/models)                              │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │  User Models                                                    │  │
│  │  - User, Employee, Customer                                     │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │  Product Models                                                 │  │
│  │  - Product, ProductSize, Category                               │  │
│  │  - Topping                                                      │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │  Order Models                                                   │  │
│  │  - Order, OrderDetail, OrderDetailTopping                       │  │
│  │  - CartItemWithToppings                                         │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │  Inventory Models                                               │  │
│  │  - Inventory, InventoryMonitorItem                              │  │
│  │  - ProductIngredient                                            │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │  Payment & Discount Models                                      │  │
│  │  - Payment, Discount, OrderDiscount                             │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │  Feedback Models                                                │  │
│  │  - Feedback, CustomerFeedback, FeedbackStats                    │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │  Table Model                                                    │  │
│  │  - Table                                                        │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │  Reporting Models                                               │  │
│  │  - SalesReportData, DailyRevenue, TopProduct                    │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│                         UTILITY LAYER                                   │
│                    (src/java/util & src/java/utils)                     │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │  Configuration & External APIs                                  │  │
│  │  - Config (Application configuration)                           │  │
│  │  - GeminiAPI (AI Chatbot integration)                           │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │  Communication Utilities                                        │  │
│  │  - EmailUtil (Email sending for password reset)                 │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │  Export Utilities                                               │  │
│  │  - ExcelExportUtil (Export to Excel)                            │  │
│  │  - PDFExportUtil (Export to PDF)                                │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │  Helper Utilities                                               │  │
│  │  - URLUtils (URL manipulation)                                  │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│                         TEST LAYER                                      │
│                          (src/java/test)                                │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │  Unit & Integration Tests                                       │  │
│  │  - TestDatabaseSchema, TestDataExists                           │  │
│  │  - TestProductSize, TestOrderDates                              │  │
│  │  - TestSalesReport, TestInventoryEnhancements                   │  │
│  │  - TestExport, TestExportServlet                                │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│                         DATABASE LAYER                                  │
│                    (SQL Server Database)                                │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  Database: pizza_demo_DB_FinalModel_Combined                           │
│                                                                         │
│  Tables: User, Employee, Customer, Category, Product, ProductSize,     │
│          Inventory, ProductIngredient, Table, Order, OrderDetail,      │
│          OrderDetailTopping, Discount, OrderDiscount, Payment,         │
│          Feedback, PasswordTokens, DeletionQueue                       │
│                                                                         │
│  Views: v_ProductSizeAvailable, v_InventoryMonitor                     │
│                                                                         │
│  Stored Procedures: ScheduleDeletion, ProcessDeletionQueue             │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Package Dependencies

```
┌──────────────┐
│     View     │ (JSP Pages)
└──────┬───────┘
       │ HTTP Request
       ▼
┌──────────────┐
│   Filter     │ (RoleFilter)
└──────┬───────┘
       │ Intercept & Authorize
       ▼
┌──────────────┐
│  Controller  │ (Servlets)
└──────┬───────┘
       │ Business Logic
       ├─────────────────┐
       │                 │
       ▼                 ▼
┌──────────────┐   ┌──────────────┐
│     DAO      │   │    Util      │
└──────┬───────┘   └──────────────┘
       │                 │
       │                 │ (EmailUtil, ExcelExport, etc.)
       ▼                 │
┌──────────────┐         │
│    Model     │◄────────┘
└──────┬───────┘
       │
       ▼
┌──────────────┐
│   Database   │ (SQL Server)
└──────────────┘
```

---

## Detailed Package Structure

### 1. **Presentation Layer** (`web/`)
- **Purpose**: User interface and view rendering
- **Technology**: JSP, HTML, CSS, JavaScript
- **Components**:
  - Main views (Login, Dashboard, POS, etc.)
  - Partial views (NavBar, Sidebar, reusable components)
  - Static resources (images, CSS, JS)

### 2. **Controller Layer** (`src/java/controller/`)
- **Purpose**: Handle HTTP requests, business logic orchestration
- **Technology**: Java Servlets
- **Responsibilities**:
  - Request validation
  - Session management
  - Call DAO methods
  - Prepare data for views
  - Response rendering
- **Key Modules**:
  - **Authentication**: Login, Logout, Signup, Password Reset
  - **Product Management**: CRUD operations for products, sizes, categories
  - **Order Management**: POS, order creation, order tracking
  - **Kitchen**: Chef monitor, order status updates
  - **Payment**: Payment processing, bill generation
  - **Feedback**: Customer feedback collection and display
  - **Inventory**: Stock management and monitoring
  - **Table**: Table assignment and locking
  - **Discount**: Discount management and application
  - **Dashboard**: Role-based dashboards (Manager, Waiter, Chef)
  - **Reports**: Sales reports, analytics

### 3. **Filter Layer** (`src/java/filter/`)
- **Purpose**: Request interception and security
- **Components**:
  - **RoleFilter**: Role-based access control (RBAC)
    - Checks user authentication
    - Validates user roles (Admin, Employee, Customer)
    - Redirects unauthorized access

### 4. **Data Access Layer** (`src/java/dao/`)
- **Purpose**: Database operations and data persistence
- **Pattern**: Data Access Object (DAO) pattern
- **Responsibilities**:
  - CRUD operations
  - Complex queries
  - Transaction management
  - Data mapping (ResultSet to Model)
- **Key Components**:
  - **DBContext**: Database connection management (Connection pooling)
  - **Entity DAOs**: One DAO per entity (UserDAO, ProductDAO, OrderDAO, etc.)
  - **Specialized DAOs**: 
    - SalesReportDAO (Complex reporting queries)
    - InventoryMonitorDAO (Stock level monitoring)
    - OrderDetailToppingDAO (Topping management)

### 5. **Model Layer** (`src/java/models/`)
- **Purpose**: Domain objects and data structures
- **Pattern**: Plain Old Java Objects (POJOs)
- **Characteristics**:
  - Properties with getters/setters
  - No business logic
  - Represent database entities
  - Used for data transfer between layers
- **Categories**:
  - **Core Entities**: User, Product, Order, etc.
  - **Relationship Entities**: OrderDetail, ProductIngredient, etc.
  - **View Models**: CartItemWithToppings, SalesReportData, etc.
  - **Statistics Models**: FeedbackStats, TopProduct, DailyRevenue

### 6. **Utility Layer** (`src/java/util/` & `src/java/utils/`)
- **Purpose**: Reusable helper functions and external integrations
- **Components**:
  - **Config**: Application configuration management
  - **GeminiAPI**: AI chatbot integration (Google Gemini)
  - **EmailUtil**: Email sending (password reset, notifications)
  - **ExcelExportUtil**: Export data to Excel format
  - **PDFExportUtil**: Export data to PDF format
  - **URLUtils**: URL manipulation and validation

### 7. **Test Layer** (`src/java/test/`)
- **Purpose**: Testing and quality assurance
- **Components**:
  - Database schema tests
  - Data integrity tests
  - Feature tests (ProductSize, OrderDates, SalesReport)
  - Export functionality tests
  - Inventory enhancement tests

### 8. **Database Layer**
- **DBMS**: Microsoft SQL Server
- **Database**: `pizza_demo_DB_FinalModel_Combined`
- **Components**:
  - **Tables**: 18 tables (User, Product, Order, etc.)
  - **Views**: 2 views (v_ProductSizeAvailable, v_InventoryMonitor)
  - **Stored Procedures**: 2 procedures (ScheduleDeletion, ProcessDeletionQueue)
  - **SQL Agent Jobs**: Automated deletion queue processing

---

## Communication Flow

### Example: Customer Places an Order

```
1. Customer → pos.jsp (View)
   ↓
2. HTTP POST → POSServlet (Controller)
   ↓
3. POSServlet validates session (Filter: RoleFilter)
   ↓
4. POSServlet calls:
   - ProductDAO.getAvailableProducts()
   - OrderDAO.createOrder(order)
   - OrderDetailDAO.addOrderDetail(detail)
   - OrderDetailToppingDAO.addTopping(topping)
   - InventoryDAO.updateStock(items)
   ↓
5. DAOs execute SQL queries → Database
   ↓
6. Database returns results → DAOs
   ↓
7. DAOs map ResultSet → Model objects
   ↓
8. POSServlet prepares response data
   ↓
9. Forward to OrderDetail.jsp (View)
   ↓
10. Customer sees order confirmation
```

### Example: Chef Updates Order Status

```
1. Chef → ChefMonitor.jsp (View)
   ↓
2. HTTP POST → ChefMonitorServlet (Controller)
   ↓
3. ChefMonitorServlet calls:
   - OrderDetailDAO.updateStatus(orderDetailId, "Done")
   - OrderDetailDAO.setEndTime(orderDetailId, now)
   ↓
4. OrderDetailDAO executes UPDATE query → Database
   ↓
5. Database updates OrderDetail table
   ↓
6. ChefMonitorServlet refreshes order list
   ↓
7. Forward to ChefMonitor.jsp (View)
   ↓
8. Chef sees updated order status
```

---

## Design Patterns Used

### 1. **MVC (Model-View-Controller)**
- **Model**: `src/java/models/`
- **View**: `web/view/*.jsp`
- **Controller**: `src/java/controller/*Servlet.java`

### 2. **DAO (Data Access Object)**
- Separates data access logic from business logic
- Each entity has its own DAO class
- Centralized database operations

### 3. **Singleton (DBContext)**
- Single database connection instance
- Connection pooling management

### 4. **Filter Chain (RoleFilter)**
- Intercepts requests before reaching servlets
- Implements security and authorization

### 5. **Front Controller (Servlet Mapping)**
- All requests go through servlet mapping
- Centralized request handling

### 6. **Transfer Object (Models)**
- POJOs for data transfer between layers
- Encapsulates data without business logic

---

## Technology Stack

### Backend
- **Language**: Java (JDK 8+)
- **Web Framework**: Java Servlets, JSP
- **Database**: Microsoft SQL Server
- **JDBC**: SQL Server JDBC Driver
- **Password Hashing**: BCrypt

### Frontend
- **View Engine**: JSP (JavaServer Pages)
- **HTML/CSS**: Bootstrap, custom CSS
- **JavaScript**: jQuery, vanilla JS

### External Services
- **Email**: JavaMail API (Gmail SMTP)
- **AI Chatbot**: Google Gemini API
- **Export**: Apache POI (Excel), iText (PDF)

### Development Tools
- **IDE**: NetBeans, IntelliJ IDEA, Eclipse
- **Build Tool**: Ant, Maven
- **Server**: Apache Tomcat
- **Version Control**: Git

---

## Key Features by Package

### Authentication & Security
- **Packages**: controller (Login, Signup), dao (UserDAO, TokenDAO), filter (RoleFilter)
- **Features**: Login, Logout, Signup, Password Reset (Email OTP), Role-based access

### Product Management
- **Packages**: controller (ManageProduct, AddProduct, EditProduct), dao (ProductDAO, ProductSizeDAO, CategoryDAO)
- **Features**: CRUD products, manage sizes, categories, topping system

### Order Management
- **Packages**: controller (POS, OrderController, ManageOrder), dao (OrderDAO, OrderDetailDAO, OrderDetailToppingDAO)
- **Features**: POS system, order creation, order tracking, topping selection, order history

### Kitchen Management
- **Packages**: controller (ChefMonitor), dao (OrderDetailDAO)
- **Features**: Real-time order monitoring, status updates, cooking time tracking

### Inventory Management
- **Packages**: controller (Inventory, InventoryMonitor), dao (InventoryDAO, InventoryMonitorDAO, ProductIngredientDAO)
- **Features**: Stock management, low stock alerts, ingredient tracking, auto-calculation of available quantities

### Payment & Billing
- **Packages**: controller (Payment, Bill), dao (PaymentDAO, OrderDAO)
- **Features**: Payment processing, bill generation, QR code payment

### Feedback System
- **Packages**: controller (CustomerFeedback, SimpleFeedback), dao (FeedbackDAO, CustomerFeedbackDAO)
- **Features**: Customer feedback collection, rating system, feedback analytics

### Table Management
- **Packages**: controller (Table, TableLock, AssignTable), dao (TableDAO)
- **Features**: Table assignment, table locking, capacity management

### Discount System
- **Packages**: controller (Discount, DiscountImport), dao (DiscountDAO, OrderDiscountDAO)
- **Features**: Discount creation, discount application, loyalty points

### Dashboard & Reports
- **Packages**: controller (Dashboard, ManagerDashboard, WaiterDashboard, SalesReport), dao (SalesReportDAO)
- **Features**: Role-based dashboards, sales analytics, revenue reports, top products, export to Excel/PDF

### Customer Features
- **Packages**: controller (CustomerMenu, Home, ChatBot), dao (ProductDAO, FeedbackDAO)
- **Features**: Menu browsing, AI chatbot support, order history, feedback submission

---

## Security Considerations

1. **Authentication**: Session-based authentication with BCrypt password hashing
2. **Authorization**: RoleFilter checks user roles before accessing resources
3. **SQL Injection Prevention**: Prepared statements in all DAO methods
4. **XSS Prevention**: Input validation and output encoding in JSP
5. **CSRF Protection**: Session tokens for form submissions
6. **Password Reset**: Time-limited OTP tokens (5 minutes expiry)
7. **Session Management**: Secure session handling, logout functionality

---

## Scalability & Maintainability

### Advantages of Current Architecture
1. **Separation of Concerns**: Clear layer separation (MVC + DAO)
2. **Modularity**: Each feature has its own servlet and DAO
3. **Reusability**: Utility classes for common operations
4. **Testability**: Test layer for unit and integration tests
5. **Extensibility**: Easy to add new features without affecting existing code

### Potential Improvements
1. **Service Layer**: Add a service layer between Controller and DAO for complex business logic
2. **Dependency Injection**: Use Spring Framework for DI and IoC
3. **RESTful API**: Separate backend API from frontend for better scalability
4. **Caching**: Implement caching for frequently accessed data (Redis, Memcached)
5. **Logging**: Add comprehensive logging (Log4j, SLF4J)
6. **Exception Handling**: Centralized exception handling mechanism
7. **API Documentation**: Swagger/OpenAPI for API documentation

---

## Conclusion

This package diagram represents a well-structured **3-tier web application** with clear separation of concerns:

- **Presentation Layer**: JSP views for user interface
- **Business Logic Layer**: Servlets for request handling and business logic
- **Data Access Layer**: DAOs for database operations

The architecture follows **MVC pattern** with additional layers (Filter, Util, Test) for enhanced functionality, security, and maintainability. The system is designed for a **Pizza Restaurant Management** with comprehensive features for order management, inventory tracking, payment processing, and customer feedback.
