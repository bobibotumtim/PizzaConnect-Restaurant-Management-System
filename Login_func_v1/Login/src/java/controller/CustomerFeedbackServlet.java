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
            // Get filter parameters
            String searchTerm = request.getParameter("search");
            String ratingFilterStr = request.getParameter("rating");
            
            Integer ratingFilter = null;
            if (ratingFilterStr != null && !ratingFilterStr.isEmpty() && !"all".equals(ratingFilterStr)) {
                try {
                    ratingFilter = Integer.parseInt(ratingFilterStr);
                } catch (NumberFormatException e) {
                    // Invalid rating, ignore
                }
            }
            
            // Get feedback list with filters
            List<CustomerFeedback> feedbackList;
            if ((searchTerm != null && !searchTerm.trim().isEmpty()) || ratingFilter != null) {
                feedbackList = feedbackDAO.searchFeedback(searchTerm, ratingFilter, null);
            } else {
                feedbackList = feedbackDAO.getAllFeedback();
            }
            
            // Get stats
            FeedbackStats stats = feedbackDAO.getFeedbackStats();
            
            // Set attributes for JSP
            request.setAttribute("feedbackList", feedbackList);
            request.setAttribute("feedbackStats", stats);
            request.setAttribute("searchTerm", searchTerm);
            request.setAttribute("ratingFilter", ratingFilterStr);
            
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
        // Redirect to GET
        doGet(request, response);
    }
}

