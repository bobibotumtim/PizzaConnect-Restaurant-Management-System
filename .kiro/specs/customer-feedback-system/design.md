# Tài Liệu Thiết Kế - Hệ Thống Phản Hồi Khách Hàng

## Tổng Quan

Hệ thống phản hồi khách hàng là một module mới được thêm vào ứng dụng PizzaConnect hiện tại. Module này sử dụng cùng kiến trúc và patterns với các module đã có trong dự án để đảm bảo tính nhất quán.

## Kiến Trúc Dự Án Hiện Tại

### Technology Stack

- **Backend**: Java với Jakarta EE
- **Frontend**: JSP + Tailwind CSS + JavaScript
- **Database**: SQL Server với JDBC
- **Server**: Tomcat/Jakarta EE compatible server
- **Build**: NetBeans project với Ant

### Patterns Được Sử Dụng

- **MVC Pattern**: Servlet (Controller) + JSP (View) + DAO (Model)
- **DAO Pattern**: Mỗi entity có DAO class riêng
- **DBContext**: Centralized database connection management
- **Session Management**: HttpSession cho authentication
- **Annotation-based Servlets**: `@WebServlet` thay vì web.xml

## Thành Phần Cần Tạo Mới

### 1. Database Schema

#### Bảng customer_feedback

```sql
CREATE TABLE customer_feedback (
    feedback_id INT PRIMARY KEY IDENTITY(1,1),
    customer_id VARCHAR(50) NOT NULL,
    customer_name NVARCHAR(100) NOT NULL,
    order_id INT NOT NULL,
    order_date DATE NOT NULL,
    order_time TIME NOT NULL,
    rating INT CHECK (rating >= 1 AND rating <= 5) NOT NULL,
    comment NVARCHAR(1000),
    feedback_date DATE NOT NULL,
    pizza_ordered NVARCHAR(200),
    response NVARCHAR(1000),
    has_response BIT DEFAULT 0,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),

    -- Foreign key constraint (nếu có bảng orders)
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- Index cho performance
CREATE INDEX IX_customer_feedback_customer_id ON customer_feedback(customer_id);
CREATE INDEX IX_customer_feedback_order_id ON customer_feedback(order_id);
CREATE INDEX IX_customer_feedback_rating ON customer_feedback(rating);
CREATE INDEX IX_customer_feedback_has_response ON customer_feedback(has_response);
```

### 2. Model Classes

#### CustomerFeedback.java

```java
package models;

import java.sql.Date;
import java.sql.Time;

public class CustomerFeedback {
    private int feedbackId;
    private String customerId;
    private String customerName;
    private int orderId;
    private Date orderDate;
    private Time orderTime;
    private int rating;
    private String comment;
    private Date feedbackDate;
    private String pizzaOrdered;
    private String response;
    private boolean hasResponse;

    // Constructors
    public CustomerFeedback() {}

    public CustomerFeedback(int feedbackId, String customerId, String customerName,
                           int orderId, Date orderDate, Time orderTime, int rating,
                           String comment, Date feedbackDate, String pizzaOrdered,
                           String response, boolean hasResponse) {
        // Constructor implementation
    }

    // Getters and Setters
    // toString method
}
```

#### FeedbackStats.java

```java
package models;

public class FeedbackStats {
    private int totalFeedback;
    private double averageRating;
    private int positiveRate;
    private int pendingResponse;

    // Constructors, getters, setters
}
```

### 3. DAO Layer

#### CustomerFeedbackDAO.java

```java
package dao;

import models.CustomerFeedback;
import models.FeedbackStats;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CustomerFeedbackDAO {

    private DBContext dbContext;

    public CustomerFeedbackDAO() {
        this.dbContext = new DBContext();
    }

    // Lấy tất cả feedback
    public List<CustomerFeedback> getAllFeedback() throws SQLException {
        List<CustomerFeedback> feedbackList = new ArrayList<>();
        String sql = "SELECT * FROM customer_feedback ORDER BY feedback_date DESC";

        try (Connection conn = dbContext.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                feedbackList.add(mapResultSetToFeedback(rs));
            }
        }
        return feedbackList;
    }

    // Tìm kiếm và lọc feedback
    public List<CustomerFeedback> searchFeedback(String searchTerm, String filterRating, String filterStatus) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT * FROM customer_feedback WHERE 1=1");
        List<Object> parameters = new ArrayList<>();

        // Thêm điều kiện tìm kiếm
        if (searchTerm != null && !searchTerm.trim().isEmpty()) {
            sql.append(" AND (customer_name LIKE ? OR customer_id LIKE ? OR order_id = ? OR pizza_ordered LIKE ?)");
            String searchPattern = "%" + searchTerm.trim() + "%";
            parameters.add(searchPattern);
            parameters.add(searchPattern);
            try {
                parameters.add(Integer.parseInt(searchTerm.trim()));
            } catch (NumberFormatException e) {
                parameters.add(-1); // Invalid order ID
            }
            parameters.add(searchPattern);
        }

        // Thêm điều kiện lọc rating
        if (filterRating != null && !filterRating.equals("all")) {
            sql.append(" AND rating = ?");
            parameters.add(Integer.parseInt(filterRating));
        }

        // Thêm điều kiện lọc status
        if (filterStatus != null && !filterStatus.equals("all")) {
            if (filterStatus.equals("pending")) {
                sql.append(" AND has_response = 0");
            } else if (filterStatus.equals("resolved")) {
                sql.append(" AND has_response = 1");
            }
        }

        sql.append(" ORDER BY feedback_date DESC");

        List<CustomerFeedback> feedbackList = new ArrayList<>();
        try (Connection conn = dbContext.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {

            // Set parameters
            for (int i = 0; i < parameters.size(); i++) {
                stmt.setObject(i + 1, parameters.get(i));
            }

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    feedbackList.add(mapResultSetToFeedback(rs));
                }
            }
        }
        return feedbackList;
    }

    // Lấy feedback theo ID
    public CustomerFeedback getFeedbackById(int feedbackId) throws SQLException {
        String sql = "SELECT * FROM customer_feedback WHERE feedback_id = ?";

        try (Connection conn = dbContext.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, feedbackId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToFeedback(rs);
                }
            }
        }
        return null;
    }

    // Cập nhật phản hồi
    public boolean updateResponse(int feedbackId, String response) throws SQLException {
        String sql = "UPDATE customer_feedback SET response = ?, has_response = 1, updated_at = GETDATE() WHERE feedback_id = ?";

        try (Connection conn = dbContext.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, response);
            stmt.setInt(2, feedbackId);

            return stmt.executeUpdate() > 0;
        }
    }

    // Lấy thống kê
    public FeedbackStats getFeedbackStats() throws SQLException {
        String sql = """
            SELECT
                COUNT(*) as total_feedback,
                AVG(CAST(rating as FLOAT)) as avg_rating,
                COUNT(CASE WHEN rating >= 4 THEN 1 END) * 100.0 / COUNT(*) as positive_rate,
                COUNT(CASE WHEN has_response = 0 THEN 1 END) as pending_response
            FROM customer_feedback
        """;

        try (Connection conn = dbContext.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            if (rs.next()) {
                FeedbackStats stats = new FeedbackStats();
                stats.setTotalFeedback(rs.getInt("total_feedback"));
                stats.setAverageRating(rs.getDouble("avg_rating"));
                stats.setPositiveRate((int) rs.getDouble("positive_rate"));
                stats.setPendingResponse(rs.getInt("pending_response"));
                return stats;
            }
        }
        return new FeedbackStats(); // Return empty stats if no data
    }

    // Helper method để map ResultSet thành CustomerFeedback object
    private CustomerFeedback mapResultSetToFeedback(ResultSet rs) throws SQLException {
        CustomerFeedback feedback = new CustomerFeedback();
        feedback.setFeedbackId(rs.getInt("feedback_id"));
        feedback.setCustomerId(rs.getString("customer_id"));
        feedback.setCustomerName(rs.getString("customer_name"));
        feedback.setOrderId(rs.getInt("order_id"));
        feedback.setOrderDate(rs.getDate("order_date"));
        feedback.setOrderTime(rs.getTime("order_time"));
        feedback.setRating(rs.getInt("rating"));
        feedback.setComment(rs.getString("comment"));
        feedback.setFeedbackDate(rs.getDate("feedback_date"));
        feedback.setPizzaOrdered(rs.getString("pizza_ordered"));
        feedback.setResponse(rs.getString("response"));
        feedback.setHasResponse(rs.getBoolean("has_response"));
        return feedback;
    }
}
```

### 4. Servlet Controller

#### CustomerFeedbackServlet.java

```java
package controller;

import dao.CustomerFeedbackDAO;
import models.CustomerFeedback;
import models.FeedbackStats;
import models.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet(name = "CustomerFeedbackServlet", urlPatterns = {"/customer-feedback"})
public class CustomerFeedbackServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(CustomerFeedbackServlet.class.getName());

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Kiểm tra authentication (theo pattern của dự án)
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/Login");
            return;
        }

        User user = (User) session.getAttribute("user");
        request.setAttribute("currentUser", user);

        String action = request.getParameter("action");

        // Xử lý AJAX request cho modal detail
        if ("detail".equals(action)) {
            handleGetFeedbackDetail(request, response);
            return;
        }

        // Load dữ liệu mặc định
        loadFeedbackData(request, response, null, null, null);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Kiểm tra authentication
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/Login");
            return;
        }

        String action = request.getParameter("action");

        if ("search".equals(action)) {
            handleSearch(request, response);
        } else if ("respond".equals(action)) {
            handleResponse(request, response);
        } else {
            // Default search behavior
            handleSearch(request, response);
        }
    }

    private void loadFeedbackData(HttpServletRequest request, HttpServletResponse response,
                                 String searchTerm, String filterRating, String filterStatus)
            throws ServletException, IOException {

        CustomerFeedbackDAO feedbackDAO = new CustomerFeedbackDAO();

        try {
            List<CustomerFeedback> feedbackList;

            // Nếu có filter parameters, thực hiện search
            if (searchTerm != null || filterRating != null || filterStatus != null) {
                feedbackList = feedbackDAO.searchFeedback(searchTerm, filterRating, filterStatus);
            } else {
                feedbackList = feedbackDAO.getAllFeedback();
            }

            // Lấy thống kê
            FeedbackStats stats = feedbackDAO.getFeedbackStats();

            // Set attributes cho JSP
            request.setAttribute("feedbackList", feedbackList);
            request.setAttribute("feedbackStats", stats);
            request.setAttribute("searchTerm", searchTerm);
            request.setAttribute("filterRating", filterRating);
            request.setAttribute("filterStatus", filterStatus);

            // Forward đến JSP
            request.getRequestDispatcher("/view/CustomerFeedback.jsp").forward(request, response);

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error while loading feedback data", e);
            request.setAttribute("errorMessage", "Lỗi hệ thống. Vui lòng thử lại sau.");
            request.getRequestDispatcher("/view/CustomerFeedback.jsp").forward(request, response);
        }
    }

    private void handleSearch(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String searchTerm = request.getParameter("searchTerm");
        String filterRating = request.getParameter("filterRating");
        String filterStatus = request.getParameter("filterStatus");

        loadFeedbackData(request, response, searchTerm, filterRating, filterStatus);
    }

    private void handleResponse(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            int feedbackId = Integer.parseInt(request.getParameter("feedbackId"));
            String responseText = request.getParameter("response");

            if (responseText == null || responseText.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Nội dung phản hồi không được để trống.");
                loadFeedbackData(request, response, null, null, null);
                return;
            }

            CustomerFeedbackDAO feedbackDAO = new CustomerFeedbackDAO();
            boolean success = feedbackDAO.updateResponse(feedbackId, responseText.trim());

            if (success) {
                request.setAttribute("successMessage", "Phản hồi đã được gửi thành công.");
            } else {
                request.setAttribute("errorMessage", "Không thể gửi phản hồi. Vui lòng thử lại.");
            }

            // Reload data
            loadFeedbackData(request, response, null, null, null);

        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "ID phản hồi không hợp lệ.");
            loadFeedbackData(request, response, null, null, null);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error while updating response", e);
            request.setAttribute("errorMessage", "Lỗi hệ thống. Vui lòng thử lại sau.");
            loadFeedbackData(request, response, null, null, null);
        }
    }

    private void handleGetFeedbackDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            int feedbackId = Integer.parseInt(request.getParameter("id"));
            CustomerFeedbackDAO feedbackDAO = new CustomerFeedbackDAO();
            CustomerFeedback feedback = feedbackDAO.getFeedbackById(feedbackId);

            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");

            if (feedback != null) {
                // Tạo JSON response (có thể sử dụng thư viện JSON hoặc tự tạo)
                String jsonResponse = createJsonResponse(feedback);
                response.getWriter().write(jsonResponse);
            } else {
                response.getWriter().write("{\"error\": \"Không tìm thấy phản hồi\"}");
            }

        } catch (NumberFormatException e) {
            response.setContentType("application/json");
            response.getWriter().write("{\"error\": \"ID không hợp lệ\"}");
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error while getting feedback detail", e);
            response.setContentType("application/json");
            response.getWriter().write("{\"error\": \"Lỗi hệ thống\"}");
        }
    }

    private String createJsonResponse(CustomerFeedback feedback) {
        // Simple JSON creation (trong thực tế nên dùng thư viện JSON)
        return String.format("""
            {
                "feedbackId": %d,
                "customerId": "%s",
                "customerName": "%s",
                "orderId": %d,
                "orderDate": "%s",
                "orderTime": "%s",
                "rating": %d,
                "comment": "%s",
                "feedbackDate": "%s",
                "pizzaOrdered": "%s",
                "response": "%s",
                "hasResponse": %b
            }
            """,
            feedback.getFeedbackId(),
            escapeJson(feedback.getCustomerId()),
            escapeJson(feedback.getCustomerName()),
            feedback.getOrderId(),
            feedback.getOrderDate().toString(),
            feedback.getOrderTime().toString(),
            feedback.getRating(),
            escapeJson(feedback.getComment()),
            feedback.getFeedbackDate().toString(),
            escapeJson(feedback.getPizzaOrdered()),
            escapeJson(feedback.getResponse()),
            feedback.isHasResponse()
        );
    }

    private String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
    }
}
```

### 5. JSP View

#### CustomerFeedback.jsp

Trang JSP sẽ được tạo theo pattern của dự án hiện tại, sử dụng:

- Tailwind CSS cho styling
- JSTL tags cho logic
- JavaScript cho modal và interactions
- Responsive design
- Session management

### 6. Web.xml Configuration

Cần thêm servlet mapping vào web.xml:

```xml
<servlet>
    <servlet-name>CustomerFeedbackServlet</servlet-name>
    <servlet-class>controller.CustomerFeedbackServlet</servlet-class>
</servlet>
<servlet-mapping>
    <servlet-name>CustomerFeedbackServlet</servlet-name>
    <url-pattern>/customer-feedback</url-pattern>
</servlet-mapping>
```

## Tích Hợp Với Hệ Thống Hiện Tại

### Navigation Integration

- Thêm link vào NavBar.jsp
- Thêm menu item trong Admin.jsp (nếu cần)
- Cập nhật Dashboard.jsp với thống kê feedback

### Database Integration

- Tạo bảng customer_feedback trong database hiện tại
- Có thể liên kết với bảng orders nếu có
- Sử dụng cùng DBContext với các module khác

### Security Integration

- Sử dụng cùng session management
- Áp dụng cùng authentication pattern
- Role-based access nếu cần

## Chiến Lược Triển Khai

### Phase 1: Core Infrastructure

1. Tạo database schema
2. Tạo model classes
3. Tạo DAO layer
4. Test database connectivity

### Phase 2: Backend Logic

1. Tạo servlet controller
2. Implement business logic
3. Test API endpoints
4. Error handling

### Phase 3: Frontend Interface

1. Tạo JSP view
2. Implement responsive design
3. Add JavaScript functionality
4. Modal implementation

### Phase 4: Integration & Testing

1. Integrate với navigation
2. End-to-end testing
3. Performance optimization
4. Security validation
