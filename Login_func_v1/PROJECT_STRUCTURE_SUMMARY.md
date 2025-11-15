# Project Structure Summary - PizzaConnect Restaurant Management System

## Overview

Java Web Application sử dụng JSP/Servlet cho quản lý nhà hàng pizza.

## Technology Stack

- **Backend**: Java Servlets, JSP
- **Frontend**: HTML, CSS (Tailwind CSS), JavaScript
- **Database**: SQL Server
- **Server**: Apache Tomcat
- **Build Tool**: Ant (NetBeans project)

## Directory Structure

```
Login_func_v1/
├── Login/                          # Main application folder
│   ├── src/java/                   # Java source code
│   │   ├── controller/             # Servlet controllers (55 files)
│   │   ├── dao/                    # Data Access Objects (22 files)
│   │   └── models/                 # Java models/entities (23 files)
│   ├── web/                        # Web resources
│   │   ├── view/                   # JSP pages (48 files)
│   │   ├── WEB-INF/               # Configuration
│   │   └── assets/                # Static resources
│   ├── build/                      # Compiled files
│   ├── dist/                       # Distribution files
│   └── database/                   # Database scripts
├── Documentation files (.md)
└── Test files (.html)
```

## Key Components

### 1. Controllers (Servlets) - 55 files

Main servlets for different features:

#### User Management

- `LoginServlet.java` - User authentication
- `SignupServlet.java` - User registration
- `UserProfileServlet.java` - Profile management
- `ForgotPasswordServlet.java` - Password recovery
- `LogoutServlet.java` - User logout

#### Dashboard & Monitoring

- `DashboardController.java` - Admin dashboard
- `ManagerDashboardServlet.java` - Manager dashboard
- `WaiterDashboardServlet.java` - Waiter dashboard
- `ChefMonitorServlet.java` - Kitchen monitor
- `WaiterMonitorServlet.java` - Waiter order monitor
- `InventoryMonitorServlet.java` - Inventory monitoring

#### Order Management

- `POSServlet.java` - Point of Sale
- `OrderController.java` - Order operations
- `OrderHistoryServlet.java` - Customer order history
- `ManageOrderServlet.java` - Order management
- `OrderDetailServlet.java` - Order details
- `PaymentServlet.java` - Payment processing
- `BillServlet.java` - Bill generation

#### Product & Inventory

- `ManageProductServlet.java` - Product management
- `CustomerMenuServlet.java` - Customer menu view
- `InventoryServlet.java` - Inventory management
- `ManageCategoryServlet.java` - Category management
- `AddProductServlet.java` - Add products
- `EditProductServlet.java` - Edit products
- `DeleteProductServlet.java` - Delete products

#### Feedback System

- `CustomerFeedbackServlet.java` - View feedback (Manager)
- `PostPaymentFeedbackServlet.java` - Submit feedback
- `FeedbackFormServlet.java` - Feedback form
- `FeedbackPromptServlet.java` - Feedback prompt
- `SimpleFeedbackServlet.java` - Simple feedback

#### Reports

- `SalesReportServlet.java` - Sales reports generation

#### Other Features

- `DiscountServlet.java` - Discount management
- `TableServlet.java` - Table management
- `ChatBotServlet.java` - AI chatbot
- `HomeServlet.java` - Home page

### 2. Data Access Objects (DAO) - 22 files

Database interaction layer:

- `UserDAO.java` - User operations
- `CustomerDAO.java` - Customer operations
- `EmployeeDAO.java` - Employee operations
- `OrderDAO.java` - Order operations
- `OrderDetailDAO.java` - Order detail operations
- `ProductDAO.java` - Product operations
- `ProductSizeDAO.java` - Product size operations
- `CategoryDAO.java` - Category operations
- `InventoryDAO.java` - Inventory operations
- `InventoryMonitorDAO.java` - Inventory monitoring
- `CustomerFeedbackDAO.java` - Feedback operations
- `FeedbackDAO.java` - Feedback operations
- `SalesReportDAO.java` - Sales report data
- `PaymentDAO.java` - Payment operations
- `DiscountDAO.java` - Discount operations
- `TableDAO.java` - Table operations
- `ToppingDAO.java` - Topping operations
- `OrderDetailToppingDAO.java` - Order topping operations
- `OrderDiscountDAO.java` - Order discount operations
- `ProductIngredientDAO.java` - Product ingredient operations
- `TokenDAO.java` - Token operations
- `DBContext.java` - Database connection

### 3. Models (Entities) - 23 files

Java classes representing database entities:

- `User.java` - User entity
- `Customer.java` - Customer entity
- `Employee.java` - Employee entity
- `Order.java` - Order entity
- `OrderDetail.java` - Order detail entity
- `Product.java` - Product entity
- `ProductSize.java` - Product size entity
- `Category.java` - Category entity
- `Inventory.java` - Inventory entity
- `InventoryMonitorItem.java` - Inventory monitor item
- `CustomerFeedback.java` - Customer feedback entity
- `Feedback.java` - Feedback entity
- `FeedbackStats.java` - Feedback statistics
- `Payment.java` - Payment entity
- `Discount.java` - Discount entity
- `Table.java` - Table entity
- `Topping.java` - Topping entity
- `OrderDetailTopping.java` - Order topping entity
- `OrderDiscount.java` - Order discount entity
- `ProductIngredient.java` - Product ingredient entity
- `SalesReportData.java` - Sales report data
- `TopProduct.java` - Top product data
- `DailyRevenue.java` - Daily revenue data
- `CartItemWithToppings.java` - Cart item with toppings

### 4. Views (JSP) - 48 files

User interface pages:

#### Authentication

- `Login.jsp` - Login page
- `Signup.jsp` - Registration page
- `ForgotPassword.jsp` - Password recovery
- `VerifyCode.jsp` - OTP verification

#### Dashboards

- `Dashboard.jsp` - Admin dashboard
- `ManagerDashboard.jsp` - Manager dashboard
- `WaiterDashboard.jsp` - Waiter dashboard

#### Monitoring

- `ChefMonitor.jsp` - Kitchen monitor
- `WaiterMonitor.jsp` - Waiter monitor
- `InventoryMonitor.jsp` - Inventory monitor

#### Order Management

- `pos.jsp` - Point of Sale
- `ManageOrders.jsp` - Order management
- `OrderHistory.jsp` - Order history
- `OrderDetail.jsp` - Order details
- `AddOrder.jsp` - Add order
- `Payment.jsp` - Payment page
- `Bill.jsp` - Bill page

#### Product Management

- `ManageProduct.jsp` - Product management
- `CustomerMenu.jsp` - Customer menu
- `Detail.jsp` - Product details

#### Inventory

- `ManageInventory.jsp` - Inventory management
- `ManageInventory_new.jsp` - New inventory UI
- `inventory-form.jsp` - Inventory form

#### Feedback

- `CustomerFeedbackSimple.jsp` - Feedback view (Manager)
- `FeedbackForm.jsp` - Feedback form
- `FeedbackFormSimple.jsp` - Simple feedback form
- `SimpleFeedbackForm.jsp` - Simple feedback
- `SimpleFeedbackFormV2.jsp` - Feedback V2
- `SimpleFeedbackView.jsp` - Feedback view
- `FeedbackPrompt.jsp` - Feedback prompt
- `FeedbackConfirmation.jsp` - Feedback confirmation
- `GiveFeedback.jsp` - Give feedback
- `RateFeedback.jsp` - Rate feedback

#### Reports

- `GenerateSalesReports.jsp` - Sales reports

#### User Management

- `Admin.jsp` - Admin panel
- `AddUser.jsp` - Add user
- `EditUser.jsp` - Edit user
- `UserProfile.jsp` - User profile

#### Other

- `Home.jsp` - Home page
- `Table.jsp` - Table management
- `AssignTable.jsp` - Assign table
- `Discount.jsp` - Discount management
- `ManageCategory.jsp` - Category management
- `ChatBot.jsp` - Chatbot page
- `ChatBotWidget.jsp` - Chatbot widget
- `Sidebar.jsp` - Sidebar component
- `NavBar.jsp` - Navigation bar
- `NotFound.jsp` - 404 page
- `Test.jsp` - Test page

## Recent Updates (Current Session)

### 1. Customer Feedback Filter & Search

- **File**: `CustomerFeedbackSimple.jsp`
- **Features**:
  - Filter by rating (1-5 stars)
  - Search by customer name
  - Active filter display
  - Clear filters button

### 2. Feedback Modal Popup

- **File**: `OrderHistory.jsp`
- **Features**:
  - Modal popup instead of separate page
  - Star rating with hover effects
  - Form validation
  - AJAX submission
  - Auto reload after success
  - All text in English

### 3. Color Scheme Update

- **Files Updated**:
  - `ManagerDashboard.jsp`
  - `InventoryMonitor.jsp`
  - `UserProfile.jsp`
  - `CustomerFeedbackSimple.jsp`
  - `GenerateSalesReports.jsp`
- **Changes**: Unified gradient background
  - Gradient: `#fed7aa → #ffffff → #fee2e2`
  - Text: Gray-800 for headings
  - Professional pastel theme

## User Roles

1. **Admin (Role 1)**

   - Full system access
   - User management
   - All reports and monitoring

2. **Manager (Role 2)**

   - Dashboard access
   - Sales reports
   - Inventory monitoring
   - Customer feedback view
   - User management (limited)

3. **Employee (Role 2 with JobRole)**

   - **Chef**: Kitchen monitor
   - **Waiter**: Order monitor, table management
   - **Cashier**: POS, payment

4. **Customer (Role 3)**
   - Menu browsing
   - Order placement
   - Order history
   - Feedback submission
   - Profile management

## Database Tables (Main)

- Users
- Customers
- Employees
- Products
- ProductSizes
- Categories
- Orders
- OrderDetails
- Inventory
- Feedback
- Payments
- Discounts
- Tables
- Toppings
- And more...

## Key Features

1. ✅ User Authentication & Authorization
2. ✅ Role-based Access Control
3. ✅ Point of Sale (POS) System
4. ✅ Order Management
5. ✅ Inventory Management & Monitoring
6. ✅ Customer Feedback System
7. ✅ Sales Reports & Analytics
8. ✅ Table Management
9. ✅ Discount Management
10. ✅ Kitchen Monitor (Chef)
11. ✅ Waiter Monitor
12. ✅ Payment Processing
13. ✅ Bill Generation
14. ✅ Customer Menu
15. ✅ AI Chatbot Integration

## API Endpoints (Servlet Mappings)

Main URL patterns:

- `/Login` - Login
- `/logout` - Logout
- `/home` - Home page
- `/admin` - Admin panel
- `/manager-dashboard` - Manager dashboard
- `/pos` - Point of Sale
- `/customer-menu` - Customer menu
- `/order-history` - Order history
- `/customer-feedback` - Feedback view
- `/submit-feedback` - Submit feedback
- `/sales-reports` - Sales reports
- `/inventory-monitor` - Inventory monitor
- `/manage-orders` - Order management
- `/profile` - User profile
- And more...

## Configuration Files

- `web.xml` - Servlet mappings and configuration
- `build.xml` - Ant build configuration
- `FinalDatabase.sql` - Database schema
- `CHECK_DATABASE.sql` - Database verification

## Documentation Files

- `ORDER_HISTORY_GUIDE.md` - Order history guide
- `FEEDBACK_MODAL_ENGLISH_UPDATE.md` - Feedback modal update
- `MANAGER_DASHBOARD_COLOR_UPDATE.md` - Color scheme update
- `CUSTOMER_FEEDBACK_FILTER_GUIDE.md` - Feedback filter guide
- `FEEDBACK_MODAL_GUIDE.md` - Modal guide
- `DEBUG_FEEDBACK_MODAL.md` - Debug guide

## Test Files

- `test_feedback_modal.html` - Modal demo
- `test_feedback_filter.html` - Filter demo

## Notes

- Project uses NetBeans IDE
- Database: SQL Server
- Server: Apache Tomcat
- Frontend: Tailwind CSS + Lucide Icons
- All recent features use English language
- Unified color scheme across all pages
- Responsive design
- Modern UI/UX

## Status

✅ **Production Ready**

- All core features implemented
- User authentication working
- Order management functional
- Feedback system complete
- Reports generation working
- UI/UX polished and consistent
