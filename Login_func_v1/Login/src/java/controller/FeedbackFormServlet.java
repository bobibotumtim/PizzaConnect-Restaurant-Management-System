package controller;

import dao.CustomerFeedbackDAO;
import dao.OrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import models.CustomerFeedback;
import java.io.IOException;
import java.util.Map;

/**
 * Servlet để hiển thị feedback form hoặc feedback đã submit
 * URL: /feedback-form
 */
@WebServlet(name = "FeedbackFormServlet", urlPatterns = {"/feedback-form"})
public class FeedbackFormServlet extends HttpServlet {

    private CustomerFeedbackDAO feedbackDAO;
    private OrderDAO orderDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        feedbackDAO = new CustomerFeedbackDAO();
        orderDAO = new OrderDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Lấy orderId từ parameter - không redirect nếu không có, để JSP xử lý
        String orderIdParam = request.getParameter("orderId");
        
        if (orderIdParam != null && !orderIdParam.trim().isEmpty()) {
            try {
                int orderId = Integer.parseInt(orderIdParam);
                
                // Set orderId vào request attribute
                request.setAttribute("orderId", orderId);
                
                // Kiểm tra xem order đã có feedback chưa
                boolean hasFeedback = feedbackDAO.hasFeedbackForOrder(orderId);
                
                if (hasFeedback) {
                    // Đã có feedback, lấy feedback để hiển thị
                    CustomerFeedback existingFeedback = feedbackDAO.getFeedbackByOrderId(orderId);
                    request.setAttribute("existingFeedback", existingFeedback);
                    request.setAttribute("viewMode", true);
                } else {
                    // Chưa có feedback, hiển thị form để submit
                    request.setAttribute("viewMode", false);
                }
                
                // Lấy thông tin order
                try {
                    Map<String, Object> orderDetails = orderDAO.getOrderDetailsForFeedback(orderId);
                    String itemsSummary = orderDAO.getOrderItemsSummary(orderId);
                    
                    request.setAttribute("orderDetails", orderDetails);
                    request.setAttribute("itemsSummary", itemsSummary);
                } catch (Exception e) {
                    System.err.println("⚠️ Could not load order details: " + e.getMessage());
                }
                
            } catch (NumberFormatException e) {
                System.err.println("⚠️ Invalid orderId format: " + orderIdParam);
            } catch (Exception e) {
                System.err.println("❌ Error in FeedbackFormServlet: " + e.getMessage());
                e.printStackTrace();
            }
        }
        
        // Always forward to JSP - let JSP handle missing orderId
        request.getRequestDispatcher("/view/FeedbackForm.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Feedback Form Servlet - Hiển thị form đánh giá";
    }
}
