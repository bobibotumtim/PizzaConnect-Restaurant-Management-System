package dao;

import models.Feedback;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

public class FeedbackDAO extends DBContext {
    private static final Logger LOGGER = Logger.getLogger(FeedbackDAO.class.getName());

    // Add new feedback
    public boolean addFeedback(Feedback feedback) {
        String sql = "INSERT INTO Feedback (CustomerID, OrderID, ProductID, Rating, FeedbackDate) VALUES (?, ?, ?, ?, GETDATE())";

        try (Connection connection = getConnection();
                PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setInt(1, feedback.getCustomerId());
            ps.setInt(2, feedback.getOrderId());
            ps.setInt(3, feedback.getProductId());
            ps.setInt(4, feedback.getRating());

            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;

        } catch (SQLException e) {
            LOGGER.severe("Error adding feedback: " + e.getMessage());
            return false;
        }
    }

    // Get feedback by order ID
    public List<Feedback> getFeedbackByOrderId(int orderId) {
        List<Feedback> feedbackList = new ArrayList<>();
        String sql = "SELECT * FROM Feedback WHERE OrderID = ? ORDER BY FeedbackDate DESC";

        try (Connection connection = getConnection();
                PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    feedbackList.add(mapFeedback(rs));
                }
            }

        } catch (SQLException e) {
            LOGGER.severe("Error getting feedback by order ID: " + e.getMessage());
        }
        return feedbackList;
    }

    // Get feedback by customer ID
    public List<Feedback> getFeedbackByCustomerId(int customerId) {
        List<Feedback> feedbackList = new ArrayList<>();
        String sql = "SELECT * FROM Feedback WHERE CustomerID = ? ORDER BY FeedbackDate DESC";

        try (Connection connection = getConnection();
                PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    feedbackList.add(mapFeedback(rs));
                }
            }

        } catch (SQLException e) {
            LOGGER.severe("Error getting feedback by customer ID: " + e.getMessage());
        }
        return feedbackList;
    }

    // Check if customer has already given feedback for a product in an order
    public boolean hasGivenFeedback(int customerId, int orderId, int productId) {
        String sql = "SELECT COUNT(*) FROM Feedback WHERE CustomerID = ? AND OrderID = ? AND ProductID = ?";

        try (Connection connection = getConnection();
                PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setInt(1, customerId);
            ps.setInt(2, orderId);
            ps.setInt(3, productId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }

        } catch (SQLException e) {
            LOGGER.severe("Error checking existing feedback: " + e.getMessage());
            return false;
        }
    }

    // Get average rating for a product
    public double getAverageRatingForProduct(int productId) {
        String sql = "SELECT AVG(CAST(Rating AS FLOAT)) FROM Feedback WHERE ProductID = ?";

        try (Connection connection = getConnection();
                PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble(1);
                }
            }

        } catch (SQLException e) {
            LOGGER.severe("Error getting average rating: " + e.getMessage());
        }
        return 0.0;
    }

    // Map ResultSet to Feedback object
    private Feedback mapFeedback(ResultSet rs) throws SQLException {
        Feedback feedback = new Feedback();
        feedback.setFeedbackId(rs.getInt("FeedbackID"));
        feedback.setCustomerId(rs.getInt("CustomerID"));
        feedback.setOrderId(rs.getInt("OrderID"));
        feedback.setProductId(rs.getInt("ProductID"));
        feedback.setRating(rs.getInt("Rating"));
        feedback.setFeedbackDate(rs.getTimestamp("FeedbackDate"));
        return feedback;
    }
}