# 1.2 Component Descriptions

| No | Component | Description |
|----|-----------|-------------|
| 01 | **Presentation Logic Layer (Servlet Controllers)** | Lớp điều khiển xử lý các HTTP requests từ client và điều phối luồng xử lý nghiệp vụ. Bao gồm 50+ servlets được phân chia theo chức năng: Authentication (LoginServlet, SignupServlet, LogoutServlet, ForgotPasswordServlet), Product Management (ManageProductServlet, AddProductServlet, EditProductServlet, DeleteProductServlet), Order & POS (POSServlet, ManageOrderServlet, OrderController, ChefMonitorServlet, WaiterDashboardServlet), Payment & Billing (PaymentServlet, BillServlet, DiscountServlet), Feedback (CustomerFeedbackServlet, FeedbackFormServlet, PostPaymentFeedbackServlet), Inventory (InventoryServlet, InventoryMonitorServlet), Reports & Analytics (SalesReportServlet, DashboardController, ManagerDashboardServlet), và các tính năng khác (ChatBotServlet, TableServlet, ManageCategoryServlet). Các servlet này kế thừa từ HttpServlet và xử lý các phương thức doGet(), doPost(), doPut(), doDelete(). |
| 02 | **User Interface (JSP Pages)** | Lớp giao diện người dùng được xây dựng bằng JSP (JavaServer Pages) và JSTL. Bao gồm các trang: pos.jsp (Point of Sale - giao diện bán hàng), ManageProduct.jsp (quản lý sản phẩm), ManageOrders.jsp (quản lý đơn hàng), ChefMonitor.jsp (màn hình bếp theo dõi món ăn), CustomerFeedback.jsp (đánh giá khách hàng), ManageCategory.jsp (quản lý danh mục), Dashboard.jsp (trang tổng quan), và nhiều trang khác. Các JSP sử dụng Bootstrap, jQuery, DataTables, Chart.js để tạo giao diện responsive và interactive. Hỗ trợ AJAX để cập nhật dữ liệu real-time không cần reload trang. |
| 03 | **Service Layer (Business Logic)** | Lớp xử lý logic nghiệp vụ được nhúng trực tiếp trong các Servlet và DAO classes. Xử lý các nghiệp vụ phức tạp như: tính toán giá đơn hàng (bao gồm discount, topping), kiểm tra tồn kho trước khi tạo order, cập nhật trạng thái order theo workflow (Waiting → Ready → Dining → Completed), quản lý loyalty points cho customer, xử lý payment và tạo QR code, phân công chef cho từng món ăn, kiểm tra và cảnh báo inventory (LOW/CRITICAL), áp dụng discount rules (percentage, fixed, loyalty), tính toán báo cáo doanh thu và thống kê. Logic validation, authorization, và business rules được thực thi tại đây. |
| 04 | **Model Classes (Java POJOs)** | Lớp đối tượng dữ liệu đại diện cho các entity trong database. Bao gồm 20+ model classes: Product (sản phẩm), Order (đơn hàng), OrderDetail (chi tiết đơn hàng), Customer (khách hàng), Employee (nhân viên), Category (danh mục), Inventory (kho nguyên liệu), Payment (thanh toán), Feedback (đánh giá), Discount (giảm giá), Table (bàn ăn), Topping (topping), User (người dùng), ProductSize (kích thước sản phẩm), OrderDetailTopping (topping cho món ăn), ProductIngredient (nguyên liệu sản phẩm), và các model khác. Mỗi class chứa các attributes tương ứng với columns trong database, getters/setters, và constructors. Sử dụng encapsulation để bảo vệ dữ liệu. |
| 05 | **Data Access Layer (JDBC DAOs)** | Lớp truy xuất dữ liệu sử dụng JDBC để kết nối và thao tác với SQL Server database. Bao gồm 20+ DAO classes: ProductDAO (CRUD sản phẩm, tìm kiếm, filter theo category), OrderDAO (tạo order, cập nhật status, lấy order history, thống kê), OrderDetailDAO (quản lý chi tiết order, cập nhật status món ăn), CustomerDAO (quản lý khách hàng, loyalty points), EmployeeDAO (quản lý nhân viên, phân quyền), CategoryDAO (CRUD danh mục), InventoryDAO (quản lý tồn kho, cập nhật quantity), PaymentDAO (xử lý thanh toán, lịch sử payment), FeedbackDAO (lưu và lấy đánh giá), DiscountDAO (quản lý discount, kiểm tra validity), TableDAO (quản lý bàn, lock/unlock), ToppingDAO (quản lý topping), UserDAO (authentication, authorization), và các DAO khác. Mỗi DAO implement các phương thức CRUD chuẩn và các query đặc thù. |
| 06 | **DBContext (Connection Manager)** | Class quản lý kết nối database sử dụng JDBC Driver (sqljdbc42.jar). Cung cấp phương thức getConnection() để tạo connection đến SQL Server database. Sử dụng connection string với server name, database name, username, password. Hỗ trợ connection pooling để tối ưu hiệu năng. Xử lý exception và đảm bảo đóng connection sau khi sử dụng. Cấu hình: Server=localhost, Database=pizza_demo_DB_FinalModel_Combined, IntegratedSecurity hoặc SQL Authentication. |
| 07 | **SQL Server Database** | Hệ quản trị cơ sở dữ liệu Microsoft SQL Server lưu trữ toàn bộ dữ liệu của hệ thống. Database name: pizza_demo_DB_FinalModel_Combined. Bao gồm 18+ tables: Users (người dùng), Employees (nhân viên), Customers (khách hàng), Categories (danh mục), Products (sản phẩm), ProductSizes (kích thước & giá), Inventory (kho nguyên liệu), ProductIngredients (nguyên liệu cho sản phẩm), Tables (bàn ăn), Orders (đơn hàng), OrderDetails (chi tiết đơn hàng), OrderDetailToppings (topping cho món), Discounts (giảm giá), OrderDiscounts (giảm giá áp dụng), Payments (thanh toán), Feedbacks (đánh giá), PasswordTokens (token đổi mật khẩu), DeletionQueue (hàng đợi xóa). Sử dụng Views (v_ProductSizeAvailable, v_InventoryMonitor), Stored Procedures (ScheduleDeletion, ProcessDeletionQueue), và SQL Agent Jobs để tự động hóa. |
| 08 | **Common Utilities (Java Utils)** | Lớp tiện ích cung cấp các chức năng hỗ trợ chung cho toàn hệ thống. EmailUtil: gửi email thông báo, xác nhận, reset password sử dụng Jakarta Mail API và SMTP server. ExcelExportUtil: xuất báo cáo ra file Excel (.xlsx) sử dụng Apache POI library, hỗ trợ formatting, charts. PDFExportUtil: xuất hóa đơn, báo cáo ra file PDF với layout chuyên nghiệp. GeminiAPI: tích hợp AI chatbot Gemini để hỗ trợ khách hàng, trả lời câu hỏi về menu, đặt hàng. Config: quản lý cấu hình hệ thống (database connection, API keys, email settings). URLUtils: xử lý và format URLs, tạo QR code cho payment. |
| 09 | **Security Layer (RoleFilter)** | Lớp bảo mật kiểm soát truy cập dựa trên vai trò người dùng. RoleFilter là một Servlet Filter chặn tất cả HTTP requests trước khi đến Servlet. Kiểm tra session authentication (user đã login chưa), authorization (user có quyền truy cập resource không), role-based access control (Admin, Manager, Waiter, Chef, Customer có quyền khác nhau). Redirect đến login page nếu chưa authenticate. Trả về 403 Forbidden nếu không có quyền. Sử dụng BCrypt để hash và verify password. Quản lý session timeout và remember me functionality. |
| 10 | **External Libraries** | Các thư viện bên ngoài được sử dụng trong project (thư mục lib/): sqljdbc42.jar (SQL Server JDBC Driver để kết nối database), jakarta.servlet-api-5.0.0/6.0.0 (Servlet API cho web application), jakarta.mail-2.0.1 (gửi email), jbcrypt-0.4 (mã hóa password), json-20231013 (xử lý JSON data), poi-4.1.2, poi-ooxml-4.1.2 (Apache POI để xuất Excel), log4j-2.20.0 (logging và debugging), commons-collections4-4.3, commons-compress-1.18, commons-math3-3.6.1 (Apache Commons utilities), jakarta.servlet.jsp.jstl-2.0.0 (JSTL cho JSP), brevo-1.1.0 (email service integration). |

---

## Component Interaction Flow

```
1. Client Request Flow:
   Browser → RoleFilter (Security) → Servlet Controller → Service Logic → DAO → DBContext → Database

2. Response Flow:
   Database → DBContext → DAO → Model Objects → Servlet Controller → JSP View → Browser

3. Utility Usage:
   Servlet Controller → Utils (Email/Excel/PDF/AI) → External Services

4. Authentication Flow:
   LoginServlet → UserDAO → BCrypt Verification → Session Creation → RoleFilter Authorization
```

---

## Technology Stack Summary

| Layer | Technology |
|-------|------------|
| **Frontend** | JSP, JSTL, HTML5, CSS3, JavaScript, jQuery, Bootstrap, DataTables, Chart.js |
| **Backend** | Java Servlets, Jakarta EE (Servlet 5.0/6.0) |
| **Database** | Microsoft SQL Server |
| **ORM/Data Access** | JDBC (Manual SQL queries) |
| **Security** | BCrypt password hashing, Session-based authentication, Role-based authorization |
| **Build Tool** | Apache Ant (NetBeans project) |
| **Server** | Apache Tomcat / Jakarta EE compatible server |
| **Libraries** | Jakarta Mail, Apache POI, Log4j, JSON, Commons libraries |
| **External APIs** | Gemini AI (Chatbot), Email SMTP services |

---

## Key Design Patterns Used

1. **MVC Pattern**: Model (POJOs) - View (JSP) - Controller (Servlets)
2. **DAO Pattern**: Data Access Objects để tách biệt business logic và data access
3. **Singleton Pattern**: DBContext connection manager
4. **Filter Pattern**: RoleFilter cho security
5. **Factory Pattern**: Tạo objects từ database results
6. **Session Facade Pattern**: Servlets như facade cho business logic
