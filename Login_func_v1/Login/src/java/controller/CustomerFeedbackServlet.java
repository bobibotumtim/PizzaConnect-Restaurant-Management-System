package controller;

import dao.CustomerFeedbackDAO;
import models.CustomerFeedback;
import models.FeedbackStats;
import models.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

public class CustomerFeedbackServlet extends HttpServlet {
    
    private final CustomerFeedbackDAO feedbackDAO = new CustomerFeedbackDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Check authentication - only admin and employees can access
        User currentUser = (User) request.getSession().getAttribute("user");
        if (currentUser == null || (currentUser.getRole() != 1 && currentUser.getRole() != 2)) {
            response.sendRedirect(request.getContextPath() + "/view/Home.jsp");
            return;
        }
        
        try {
            // Get feedback list and stats
            List<CustomerFeedback> feedbackList = feedbackDAO.getAllFeedback();
            FeedbackStats stats = feedbackDAO.getFeedbackStats();
            
            // Set attributes for JSP
            request.setAttribute("feedbackList", feedbackList);
            request.setAttribute("feedbackStats", stats);
            
            // Forward to JSP
            request.getRequestDispatcher("/view/CustomerFeedbackSimple.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error loading feedback data");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Check authentication
        User currentUser = (User) request.getSession().getAttribute("user");
        if (currentUser == null || (currentUser.getRole() != 1 && currentUser.getRole() != 2)) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }
        
        String action = request.getParameter("action");
        
        if ("respond".equals(action)) {
            handleRespondToFeedback(request, response);
        } else {
            // Default: redirect to GET
            doGet(request, response);
        }
    }
    
    private void handleRespondToFeedback(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            String idParam = request.getParameter("id");
            String responseText = request.getParameter("response");
            
            if (idParam != null && responseText != null && !responseText.trim().isEmpty()) {
                int feedbackId = Integer.parseInt(idParam);
                User currentUser = (User) request.getSession().getAttribute("user");
                
                boolean success = feedbackDAO.addResponse(feedbackId, responseText.trim(), currentUser.getUserID());
                
                if (success) {
                    request.setAttribute("message", "Phản hồi đã được thêm thành công!");
                } else {
                    request.setAttribute("error", "Không thể thêm phản hồi. Vui lòng thử lại.");
                }
            }
            
            // Redirect back to list
            doGet(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra khi xử lý phản hồi.");
            doGet(request, response);
        }
    }
}

