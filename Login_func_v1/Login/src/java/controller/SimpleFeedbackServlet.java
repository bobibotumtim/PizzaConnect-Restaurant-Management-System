package controller;

import dao.CustomerFeedbackDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "SimpleFeedbackServlet", urlPatterns = {"/simple-feedback"})
public class SimpleFeedbackServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Force no-cache
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);
        
        // Get and validate orderId
        String orderIdParam = request.getParameter("orderId");
        int orderId = 0;
        boolean validOrderId = false;
        
        if (orderIdParam != null && !orderIdParam.trim().isEmpty()) {
            try {
                orderId = Integer.parseInt(orderIdParam);
                validOrderId = true;
            } catch (NumberFormatException e) {
                validOrderId = false;
            }
        }
        
        // Set attributes for JSP
        request.setAttribute("orderId", orderId);
        request.setAttribute("validOrderId", validOrderId);
        
        // Forward to JSP
        request.getRequestDispatcher("/view/GiveFeedback.jsp").forward(request, response);
    }
}
