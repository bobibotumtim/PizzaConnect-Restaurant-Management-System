package controller;

import dao.CustomerFeedbackDAO;
import dao.OrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Map;

/**
 * Servlet xử lý hiển thị trang feedback prompt sau khi thanh toán
 * URL: /feedback-prompt
 */
@WebServlet(name = "FeedbackPromptServlet", urlPatterns = {"/feedback-prompt"})
public class FeedbackPromptServlet extends HttpServlet {

    private CustomerFeedbackDAO feedbackDAO;
    private OrderDAO orderDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        feedbackDAO = new CustomerFeedbackDAO();
        orderDAO = new OrderDAO();
    }

    /**
     * Xử lý GET request - Hiển thị trang feedback prompt
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Lấy orderId từ parameter
        String orderIdParam = request.getParameter("orderId");
        
        if (orderIdParam == null || orderIdParam.trim().isEmpty()) {
            // Không có orderId, redirect về home
            request.setAttribute("error", "Order ID không hợp lệ");
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }
        
        try {
            int orderId = Integer.parseInt(orderIdParam);
            
            // Kiểm tra xem order đã có feedback chưa
            if (feedbackDAO.hasFeedbackForOrder(orderId)) {
                // Đã có feedback rồi, redirect về home với thông báo
                request.getSession().setAttribute("message", "Bạn đã gửi feedback cho đơn hàng này rồi!");
                response.sendRedirect(request.getContextPath() + "/home");
                return;
            }
            
            // Lấy thông tin order
            Map<String, Object> orderDetails = orderDAO.getOrderDetailsForFeedback(orderId);
            
            if (orderDetails == null) {
                // Order không tồn tại
                request.setAttribute("error", "Không tìm thấy đơn hàng");
                response.sendRedirect(request.getContextPath() + "/home");
                return;
            }
            
            // Lấy danh sách món ăn
            String itemsSummary = orderDAO.getOrderItemsSummary(orderId);
            
            // Set attributes để hiển thị trong JSP
            request.setAttribute("orderId", orderId);
            request.setAttribute("orderDetails", orderDetails);
            request.setAttribute("itemsSummary", itemsSummary);
            request.setAttribute("orderDate", orderDetails.get("orderDate"));
            request.setAttribute("totalPrice", orderDetails.get("totalPrice"));
            request.setAttribute("customerName", orderDetails.get("customerName"));
            
            // Forward đến trang FeedbackPrompt.jsp
            request.getRequestDispatcher("/view/FeedbackPrompt.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            // OrderId không phải số hợp lệ
            request.setAttribute("error", "Order ID không hợp lệ");
            response.sendRedirect(request.getContextPath() + "/home");
        } catch (Exception e) {
            // Lỗi khác
            System.err.println("❌ Error in FeedbackPromptServlet: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra. Vui lòng thử lại sau.");
            response.sendRedirect(request.getContextPath() + "/home");
        }
    }

    /**
     * Xử lý POST request - Redirect về GET
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Feedback Prompt Servlet - Hiển thị trang feedback sau thanh toán";
    }
}
