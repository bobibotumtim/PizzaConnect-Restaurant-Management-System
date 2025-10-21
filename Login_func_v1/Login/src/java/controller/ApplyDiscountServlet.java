package controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import dao.DiscountDAO;
import models.User;

public class ApplyDiscountServlet extends HttpServlet {
   
    private static final long serialVersionUID = 1L;
    private DiscountDAO discountDAO = new DiscountDAO();

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /** 
     * Handles the HTTP <code>GET</code> method.
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("Login");
            return;
        }

        User user = (User) session.getAttribute("user");
        request.setAttribute("user", user);
        request.getRequestDispatcher("/discount.jsp").forward(request, response);

    } 

    /** 
     * Handles the HTTP <code>POST</code> method.
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        HttpSession session = request.getSession();
        Integer customerId = (Integer) session.getAttribute("customerId");
        Integer orderId = Integer.parseInt(request.getParameter("orderId"));
        Integer discountId = Integer.parseInt(request.getParameter("discountId"));
        Integer pointsUsed = request.getParameter("pointsUsed") != null ? Integer.parseInt(request.getParameter("pointsUsed")) : 0;
        double totalPrice = Double.parseDouble(request.getParameter("totalPrice"));

        if (customerId != null && discountDAO.applyDiscount(orderId, discountId, totalPrice, customerId, pointsUsed)) {
            request.setAttribute("message", "Discount applied successfully!");
        } else {
            request.setAttribute("message", "Failed to apply discount.");
        }

        request.getRequestDispatcher("/discount.jsp").forward(request, response);
    }

    /** 
     * Returns a short description of the servlet.
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
