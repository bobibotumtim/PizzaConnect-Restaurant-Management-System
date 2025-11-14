package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Servlet để hiển thị trang confirmation sau khi submit feedback
 * URL: /feedback-confirmation
 */
@WebServlet(name = "FeedbackConfirmationServlet", urlPatterns = {"/feedback-confirmation"})
public class FeedbackConfirmationServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Lấy parameters
        String orderId = request.getParameter("orderId");
        String rating = request.getParameter("rating");
        
        if (orderId == null || orderId.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }
        
        // Forward đến FeedbackConfirmation.jsp
        request.getRequestDispatcher("/view/FeedbackConfirmation.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Feedback Confirmation Servlet - Hiển thị trang cảm ơn";
    }
}
