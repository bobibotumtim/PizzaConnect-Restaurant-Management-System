package dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import models.CustomerFeedback;
import models.FeedbackStats;

public class CustomerFeedbackDAO extends DBContext {
    
    private static final Logger LOGGER = Logger.getLogger(CustomerFeedbackDAO.class.getName());

    /**
     * Lấy tất cả feedback từ database
     */
    public List<CustomerFeedback> getAllFeedback() {
        List<CustomerFeedback> feedbackList = new ArrayList<>();
        String sql = "SELECT * FROM customer_feedback ORDER BY feedback_date DESC, created_at DESC";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                CustomerFeedback feedback = mapResultSetToFeedback(rs);
                feedbackList.add(feedback);
            }
            
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting all feedback", e);
        }
        
        return feedbackList;
    }

    /**
     * Lấy tất cả feedback với pagination
     */
    public List<CustomerFeedback> getAllFeedback(int page, int limit) {
        List<CustomerFeedback> feedbackList = new ArrayList<>();
        int offset = (page - 1) * limit;
        String sql = "SELECT * FROM customer_feedback ORDER BY feedback_date DESC, created_at DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, offset);
            ps.setInt(2, limit);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CustomerFeedback feedback = mapResultSetToFeedback(rs);
                    feedbackList.add(feedback);
                }
            }
            
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting feedback with pagination", e);
        }
        
        return feedbackList;
    }

    /**
     * Tìm kiếm feedback với các filter parameters và pagination
     */
    public List<CustomerFeedback> searchFeedback(String searchTerm, Integer ratingFilter, String statusFilter, int page, int limit) {
        List<CustomerFeedback> feedbackList = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM customer_feedback WHERE 1=1");
        List<Object> parameters = new ArrayList<>();
        
        // Add search term filter
        if (searchTerm != null && !searchTerm.trim().isEmpty()) {
            sql.append(" AND (customer_name LIKE ? OR comment LIKE ? OR product_feedbacked LIKE ?)");
            String searchPattern = "%" + searchTerm.trim() + "%";
            parameters.add(searchPattern);
            parameters.add(searchPattern);
            parameters.add(searchPattern);
        }
        
        // Add rating filter
        if (ratingFilter != null && ratingFilter > 0) {
            sql.append(" AND rating = ?");
            parameters.add(ratingFilter);
        }
        
        // Add status filter
        if (statusFilter != null && !statusFilter.isEmpty()) {
            if ("responded".equals(statusFilter)) {
                sql.append(" AND has_response = 1");
            } else if ("pending".equals(statusFilter)) {
                sql.append(" AND has_response = 0");
            }
        }
        
        sql.append(" ORDER BY feedback_date DESC, created_at DESC");
        
        // Add pagination
        int offset = (page - 1) * limit;
        sql.append(" OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        parameters.add(offset);
        parameters.add(limit);
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            // Set parameters
            for (int i = 0; i < parameters.size(); i++) {
                ps.setObject(i + 1, parameters.get(i));
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CustomerFeedback feedback = mapResultSetToFeedback(rs);
                    feedbackList.add(feedback);
                }
            }
            
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error searching feedback", e);
        }
        
        return feedbackList;
    }

    /**
     * Tìm kiếm feedback với các filter parameters (method cũ)
     */
    public List<CustomerFeedback> searchFeedback(String searchTerm, Integer ratingFilter, Boolean hasResponseFilter) {
        List<CustomerFeedback> feedbackList = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM customer_feedback WHERE 1=1");
        List<Object> parameters = new ArrayList<>();
        
        // Add search term filter
        if (searchTerm != null && !searchTerm.trim().isEmpty()) {
            sql.append(" AND (customer_name LIKE ? OR comment LIKE ? OR product_feedbacked LIKE ?)");
            String searchPattern = "%" + searchTerm.trim() + "%";
            parameters.add(searchPattern);
            parameters.add(searchPattern);
            parameters.add(searchPattern);
        }
        
        // Add rating filter
        if (ratingFilter != null && ratingFilter > 0) {
            sql.append(" AND rating = ?");
            parameters.add(ratingFilter);
        }
        
        // Add response status filter
        if (hasResponseFilter != null) {
            sql.append(" AND has_response = ?");
            parameters.add(hasResponseFilter);
        }
        
        sql.append(" ORDER BY feedback_date DESC, created_at DESC");
        
        try (Connection conn = getConnection();
PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            // Set parameters
            for (int i = 0; i < parameters.size(); i++) {
                ps.setObject(i + 1, parameters.get(i));
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CustomerFeedback feedback = mapResultSetToFeedback(rs);
                    feedbackList.add(feedback);
                }
            }
            
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error searching feedback", e);
        }
        
        return feedbackList;
    }

    /**
     * Lấy feedback theo ID
     */
    public CustomerFeedback getFeedbackById(int feedbackId) {
        String sql = "SELECT * FROM customer_feedback WHERE feedback_id = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, feedbackId);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToFeedback(rs);
                }
            }
            
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting feedback by ID: " + feedbackId, e);
        }
        
        return null;
    }

    /**
     * Lấy feedback chưa được phản hồi
     */
    public List<CustomerFeedback> getPendingFeedback() {
        List<CustomerFeedback> feedbackList = new ArrayList<>();
        String sql = "SELECT * FROM customer_feedback ORDER BY rating ASC, feedback_date ASC";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                CustomerFeedback feedback = mapResultSetToFeedback(rs);
                feedbackList.add(feedback);
            }
            
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting pending feedback", e);
        }
        
        return feedbackList;
    }

    /**
     * Lấy feedback cần xử lý gấp (rating thấp)
     */
    public List<CustomerFeedback> getUrgentFeedback() {
        List<CustomerFeedback> feedbackList = new ArrayList<>();
        String sql = "SELECT * FROM customer_feedback WHERE rating <= 2 ORDER BY feedback_date ASC";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                CustomerFeedback feedback = mapResultSetToFeedback(rs);
                feedbackList.add(feedback);
            }
            
        } catch (SQLException e) {
LOGGER.log(Level.SEVERE, "Error getting urgent feedback", e);
        }
        
        return feedbackList;
    }

    /**
     * Thêm feedback mới
     */
    public boolean insertFeedback(CustomerFeedback feedback) {
        String sql = "INSERT INTO customer_feedback (customer_id, customer_name, order_id, order_date, " +
                    "order_time, rating, comment, feedback_date, pizza_ordered, has_response) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, feedback.getCustomerId());
            ps.setString(2, feedback.getCustomerName());
            ps.setInt(3, feedback.getOrderId());
            ps.setDate(4, feedback.getOrderDate());
            ps.setTime(5, feedback.getOrderTime());
            ps.setInt(6, feedback.getRating());
            ps.setString(7, feedback.getComment());
            ps.setDate(8, feedback.getFeedbackDate());
            ps.setString(9, feedback.getPizzaOrdered());
            ps.setBoolean(10, feedback.isHasResponse());
            
            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
            
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error inserting feedback", e);
            return false;
        }
    }

    /**
     * Thêm phản hồi cho feedback (disabled - response column not available)
     */
    public boolean addResponse(int feedbackId, String response, int userId) {
        // Response functionality disabled - column not available in VIEW
        LOGGER.log(Level.WARNING, "Response functionality is disabled - column not available in VIEW");
        return false;
    }

    // ===== RESPONSE MANAGEMENT METHODS =====

    /**
     * Cập nhật phản hồi cho feedback (disabled - response column not available)
     */
    public boolean updateResponse(int feedbackId, String response) {
        // Response functionality disabled - column not available in VIEW
        LOGGER.log(Level.WARNING, "Response functionality is disabled - column not available in VIEW");
        return false;
    }

    /**
     * Validate response text
     */
    public boolean isValidResponse(String response) {
        if (response == null || response.trim().isEmpty()) {
            return false;
        }
        
        // Check minimum length
        if (response.trim().length() < 10) {
            return false;
        }
        
        // Check maximum length
        if (response.trim().length() > 1000) {
            return false;
        }
        
        return true;
    }

    /**
     * Cập nhật phản hồi với validation
     */
    public boolean updateResponseWithValidation(int feedbackId, String response) {
        // Validate response
        if (!isValidResponse(response)) {
            LOGGER.log(Level.WARNING, "Invalid response text for feedback ID: " + feedbackId);
            return false;
        }
        
        // Check if feedback exists
        if (getFeedbackById(feedbackId) == null) {
            LOGGER.log(Level.WARNING, "Feedback not found with ID: " + feedbackId);
            return false;
        }
        
        return updateResponse(feedbackId, response);
    }

    // ===== STATISTICS CALCULATION METHODS =====

    /**
     * Lấy tất cả thống kê feedback
     */
    public FeedbackStats getFeedbackStats() {
        String sql = "SELECT " +
                    "COUNT(*) as total_feedback, " +
                    "AVG(CAST(rating AS FLOAT)) as avg_rating, " +
                    "COUNT(CASE WHEN rating >= 4 THEN 1 END) as positive_feedback, " +
                    "COUNT(CASE WHEN rating = 5 THEN 1 END) as rating_5_count, " +
                    "COUNT(CASE WHEN rating = 4 THEN 1 END) as rating_4_count, " +
                    "COUNT(CASE WHEN rating = 3 THEN 1 END) as rating_3_count, " +
                    "COUNT(CASE WHEN rating = 2 THEN 1 END) as rating_2_count, " +
                    "COUNT(CASE WHEN rating = 1 THEN 1 END) as rating_1_count " +
                    "FROM customer_feedback";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            if (rs.next()) {
                return new FeedbackStats(
                    rs.getInt("total_feedback"),
                    rs.getDouble("avg_rating"),
                    rs.getInt("positive_feedback"),
                    rs.getInt("rating_5_count"),
                    rs.getInt("rating_4_count"),
                    rs.getInt("rating_3_count"),
                    rs.getInt("rating_2_count"),
                    rs.getInt("rating_1_count")
                );
            }
            
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting feedback statistics", e);
        }
        
        // Return empty stats if error
        return new FeedbackStats(0, 0.0, 0, 0, 0, 0, 0, 0);
    }

    /**
     * Lấy số feedback chờ phản hồi
     */
    public int getPendingResponseCount() {
        String sql = "SELECT COUNT(*) as pending_count FROM customer_feedback";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            if (rs.next()) {
                return rs.getInt("pending_count");
            }
            
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting pending response count", e);
        }
        
        return 0;
    }

    /**
     * Kiểm tra có feedback cần xử lý gấp không
     */
    public boolean hasUrgentFeedback() {
        String sql = "SELECT COUNT(*) as urgent_count FROM customer_feedback WHERE rating <= 2";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            if (rs.next()) {
                return rs.getInt("urgent_count") > 0;
            }
            
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error checking urgent feedback", e);
        }
        
        return false;
    }

    /**
     * Map ResultSet to CustomerFeedback object
     */
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
        feedback.setPizzaOrdered(rs.getString("product_feedbacked")); // Column name in VIEW
        // feedback.setResponse(rs.getString("response")); // Not available in VIEW
        // feedback.setHasResponse(rs.getBoolean("has_response")); // Not available in VIEW
        feedback.setCreatedAt(rs.getTimestamp("created_at"));
        feedback.setUpdatedAt(rs.getTimestamp("updated_at"));
        
        return feedback;
    }

    /**
     * Lấy số feedback cần xử lý gấp
     */
    public int getUrgentFeedbackCount() {
        String sql = "SELECT COUNT(*) as urgent_count FROM customer_feedback WHERE rating <= 2";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            if (rs.next()) {
                return rs.getInt("urgent_count");
            }
            
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting urgent feedback count", e);
        }
        
        return 0;
    }

    // ===== POST-PAYMENT FEEDBACK SUPPORT METHODS =====

    /**
     * Kiểm tra xem đã có feedback cho order này chưa
     * @param orderId ID của order cần kiểm tra
     * @return true nếu đã có feedback, false nếu chưa
     */
    public boolean hasFeedbackForOrder(int orderId) {
        String sql = "SELECT COUNT(*) as feedback_count FROM Feedback WHERE OrderID = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, orderId);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("feedback_count") > 0;
                }
            }
            
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error checking feedback for order ID: " + orderId, e);
        }
        
        return false;
    }

    /**
     * Lấy feedback theo order ID
     * @param orderId ID của order
     * @return CustomerFeedback object hoặc null nếu không tìm thấy
     */
    public CustomerFeedback getFeedbackByOrderId(int orderId) {
        String sql = "SELECT * FROM Feedback WHERE OrderID = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, orderId);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    CustomerFeedback feedback = new CustomerFeedback();
                    feedback.setFeedbackId(rs.getInt("FeedbackID"));
                    feedback.setCustomerId(rs.getString("CustomerID"));
                    feedback.setOrderId(rs.getInt("OrderID"));
                    feedback.setRating(rs.getInt("Rating"));
                    feedback.setFeedbackDate(rs.getDate("FeedbackDate"));
                    
                    // Lấy Comment nếu có
                    try {
                        String comment = rs.getString("Comment");
                        feedback.setComment(comment);
                    } catch (SQLException e) {
                        // Cột Comment có thể chưa tồn tại
                        feedback.setComment("");
                    }
                    
                    return feedback;
                }
            }
            
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting feedback by order ID: " + orderId, e);
        }
        
        return null;
    }

    /**
     * Thêm feedback sau thanh toán
     * @param customerId ID của khách hàng
     * @param orderId ID của order
     * @param productId ID của sản phẩm
     * @param rating Đánh giá (1-5 sao)
     * @return true nếu thành công, false nếu thất bại
     */
    public boolean insertPostPaymentFeedback(String customerId, int orderId, int productId, int rating) {
        // Validate rating
        if (rating < 1 || rating > 5) {
            LOGGER.log(Level.WARNING, "Invalid rating value: " + rating + ". Must be between 1 and 5.");
            return false;
        }
        
        // Insert vào bảng Feedback
        String sql = "INSERT INTO Feedback (CustomerID, OrderID, ProductID, Rating, FeedbackDate) " +
                    "VALUES (?, ?, ?, ?, GETDATE())";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, customerId);
            ps.setInt(2, orderId);
            ps.setInt(3, productId);
            ps.setInt(4, rating);
            
            int rowsAffected = ps.executeUpdate();
            if (rowsAffected > 0) {
                LOGGER.log(Level.INFO, "Post-payment feedback inserted successfully for order ID: " + orderId);
                return true;
            }
            
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error inserting post-payment feedback for order ID: " + orderId, e);
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Thêm feedback sau thanh toán với comment
     * @param customerId ID của khách hàng
     * @param orderId ID của order
     * @param productId ID của sản phẩm
     * @param rating Đánh giá (1-5 sao)
     * @param comment Nội dung feedback (có thể null hoặc empty)
     * @return true nếu thành công, false nếu thất bại
     */
    public boolean insertPostPaymentFeedbackWithComment(String customerId, int orderId, int productId, int rating, String comment) {
        // Validate rating
        if (rating < 1 || rating > 5) {
            LOGGER.log(Level.WARNING, "Invalid rating value: " + rating + ". Must be between 1 and 5.");
            return false;
        }
        
        // Insert vào bảng Feedback với Comment
        String sql = "INSERT INTO Feedback (CustomerID, OrderID, ProductID, Rating, Comment, FeedbackDate) " +
                    "VALUES (?, ?, ?, ?, ?, GETDATE())";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, customerId);
            ps.setInt(2, orderId);
            ps.setInt(3, productId);
            ps.setInt(4, rating);
            ps.setString(5, comment != null ? comment : "");
            
            int rowsAffected = ps.executeUpdate();
            if (rowsAffected > 0) {
                LOGGER.log(Level.INFO, "Post-payment feedback with comment inserted successfully for order ID: " + orderId);
                return true;
            }
            
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error inserting post-payment feedback with comment for order ID: " + orderId, e);
            e.printStackTrace();
        }
        
        return false;
    }

    /**
     * Kiểm tra xem feedback có thể được cập nhật không (trong vòng 24 giờ)
     * @param feedbackId ID của feedback
     * @param submittedAt Thời gian submit feedback
     * @return true nếu có thể cập nhật (trong vòng 24 giờ), false nếu không
     */
    public boolean canUpdateFeedback(int feedbackId, Timestamp submittedAt) {
        if (submittedAt == null) {
            LOGGER.log(Level.WARNING, "Submitted timestamp is null for feedback ID: " + feedbackId);
            return false;
        }
        
        // Tính thời gian hiện tại
        Timestamp currentTime = new Timestamp(System.currentTimeMillis());
        
        // Tính khoảng thời gian giữa hiện tại và thời gian submit (tính bằng milliseconds)
        long timeDifference = currentTime.getTime() - submittedAt.getTime();
        
        // Chuyển đổi sang giờ (1 giờ = 3600000 milliseconds)
        long hoursDifference = timeDifference / (1000 * 60 * 60);
        
        // Cho phép cập nhật trong vòng 24 giờ
        boolean canUpdate = hoursDifference < 24;
        
        if (!canUpdate) {
            LOGGER.log(Level.INFO, "Feedback ID " + feedbackId + " cannot be updated. Submitted " + hoursDifference + " hours ago.");
        }
        
        return canUpdate;
    }
}


