package controller;

import dao.CustomerFeedbackDAO;
import dao.OrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Map;

/**
 * Servlet xử lý submit feedback sau thanh toán
 * URL: /submit-feedback
 */
@WebServlet(name = "PostPaymentFeedbackServlet", urlPatterns = {"/submit-feedback"})
public class PostPaymentFeedbackServlet extends HttpServlet {

    private CustomerFeedbackDAO feedbackDAO;
    private OrderDAO orderDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        feedbackDAO = new CustomerFeedbackDAO();
        orderDAO = new OrderDAO();
    }

    /**
     * Xử lý POST request - Submit feedback
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Set request encoding FIRST
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        StringBuilder jsonResponse = new StringBuilder();
        
        try {
            // Debug: Log all parameters
            System.out.println("DEBUG PostPaymentFeedbackServlet - Request Content-Type: " + request.getContentType());
            System.out.println("DEBUG PostPaymentFeedbackServlet - Request Method: " + request.getMethod());
            System.out.println("DEBUG PostPaymentFeedbackServlet - All parameter names:");
            request.getParameterMap().forEach((key, values) -> {
                System.out.println("  - " + key + " = " + java.util.Arrays.toString(values));
            });
            
            // Lấy parameters
            String orderIdParam = request.getParameter("orderId");
            String ratingParam = request.getParameter("rating");
            String comment = request.getParameter("comment");
            String productIdParam = request.getParameter("productId");
            
            // Debug log
            System.out.println("DEBUG PostPaymentFeedbackServlet - orderIdParam: '" + orderIdParam + "' (isNull: " + (orderIdParam == null) + ", isEmpty: " + (orderIdParam != null ? orderIdParam.trim().isEmpty() : "N/A") + ")");
            System.out.println("DEBUG PostPaymentFeedbackServlet - ratingParam: '" + ratingParam + "'");
            System.out.println("DEBUG PostPaymentFeedbackServlet - comment: '" + comment + "'");
            System.out.println("DEBUG PostPaymentFeedbackServlet - productIdParam: '" + productIdParam + "'");
            
            // Validate orderId
            if (orderIdParam == null || orderIdParam.trim().isEmpty()) {
                System.out.println("DEBUG PostPaymentFeedbackServlet - orderId validation FAILED");
                sendJsonError(response, "Order ID không được để trống");
                return;
            }
            
            // Validate rating
            if (ratingParam == null || ratingParam.trim().isEmpty()) {
                sendJsonError(response, "Vui lòng chọn đánh giá");
                return;
            }
            
            int orderId;
            int rating;
            int productId = 1; // Default product ID
            
            try {
                orderId = Integer.parseInt(orderIdParam);
                rating = Integer.parseInt(ratingParam);
                
                if (productIdParam != null && !productIdParam.trim().isEmpty()) {
                    productId = Integer.parseInt(productIdParam);
                }
            } catch (NumberFormatException e) {
                sendJsonError(response, "Dữ liệu không hợp lệ");
                return;
            }
            
            // Validate rating range (1-5)
            if (rating < 1 || rating > 5) {
                sendJsonError(response, "Đánh giá phải từ 1 đến 5 sao");
                return;
            }
            
            // Validate comment length (max 500 characters)
            if (comment != null && comment.length() > 500) {
                sendJsonError(response, "Nhận xét không được vượt quá 500 ký tự");
                return;
            }
            
            // Kiểm tra xem order đã có feedback chưa
            if (feedbackDAO.hasFeedbackForOrder(orderId)) {
                sendJsonError(response, "Bạn đã gửi feedback cho đơn hàng này rồi");
                return;
            }
            
            // Lấy thông tin customer từ order
            Map<String, Object> customerInfo = orderDAO.getCustomerInfoFromOrder(orderId);
            
            if (customerInfo == null) {
                sendJsonError(response, "Không tìm thấy thông tin đơn hàng");
                return;
            }
            
            // Lấy customerId (hỗ trợ cả guest customer)
            String customerId = (String) customerInfo.get("customerId");
            
            // Insert feedback vào database với comment
            boolean success = feedbackDAO.insertPostPaymentFeedbackWithComment(
                customerId, 
                orderId, 
                productId, 
                rating,
                comment
            );
            
            if (success) {
                jsonResponse.append("{");
                jsonResponse.append("\"success\": true,");
                jsonResponse.append("\"message\": \"Cảm ơn bạn đã gửi feedback!\",");
                jsonResponse.append("\"rating\": ").append(rating);
                
                // Thêm thông báo đặc biệt cho rating thấp
                if (rating <= 2) {
                    jsonResponse.append(",\"lowRatingMessage\": \"Chúng tôi rất tiếc vì trải nghiệm của bạn chưa tốt. Feedback của bạn sẽ được xem xét ưu tiên.\"");
                }
                
                jsonResponse.append("}");
                
                System.out.println("✅ Feedback submitted successfully for Order #" + orderId + " - Rating: " + rating);
                
                PrintWriter out = response.getWriter();
                out.print(jsonResponse.toString());
                out.flush();
            } else {
                sendJsonError(response, "Không thể lưu feedback. Vui lòng thử lại.");
            }
            
        } catch (Exception e) {
            System.err.println("❌ Error in PostPaymentFeedbackServlet: " + e.getMessage());
            e.printStackTrace();
            
            sendJsonError(response, "Có lỗi xảy ra. Vui lòng thử lại sau.");
        }
    }

    /**
     * Xử lý GET request - Redirect về POST
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/home");
    }

    /**
     * Helper method để gửi JSON error response
     */
    private void sendJsonError(HttpServletResponse response, String message) throws IOException {
        PrintWriter out = response.getWriter();
        out.print("{\"success\": false, \"message\": \"" + escapeJson(message) + "\"}");
        out.flush();
    }
    
    /**
     * Escape JSON string
     */
    private String escapeJson(String input) {
        if (input == null) {
            return "";
        }
        return input.replace("\\", "\\\\")
                   .replace("\"", "\\\"")
                   .replace("\n", "\\n")
                   .replace("\r", "\\r")
                   .replace("\t", "\\t");
    }

    /**
     * Sanitize input để tránh XSS
     */
    private String sanitizeInput(String input) {
        if (input == null) {
            return null;
        }
        
        // Loại bỏ các ký tự đặc biệt có thể gây XSS
        return input.replaceAll("<", "&lt;")
                   .replaceAll(">", "&gt;")
                   .replaceAll("\"", "&quot;")
                   .replaceAll("'", "&#x27;")
                   .replaceAll("/", "&#x2F;");
    }

    @Override
    public String getServletInfo() {
        return "Post Payment Feedback Servlet - Xử lý submit feedback sau thanh toán";
    }
}
