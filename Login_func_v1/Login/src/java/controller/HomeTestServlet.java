package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;

public class HomeTestServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        resp.setContentType("text/html;charset=UTF-8");
        PrintWriter out = resp.getWriter();
        
        try {
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head><title>Test</title></head>");
            out.println("<body>");
            out.println("<h1>Server is working!</h1>");
            out.println("<p>If you see this, the servlet mapping is correct.</p>");
            
            // Test database connection
            try {
                dao.ProductDAO productDAO = new dao.ProductDAO();
                java.util.List<models.Product> products = productDAO.getAllBaseProducts();
                out.println("<p>Products found: " + products.size() + "</p>");
                
                for (models.Product p : products) {
                    out.println("<p>- " + p.getProductName() + " (" + p.getCategoryName() + ")</p>");
                }
            } catch (Exception e) {
                out.println("<p style='color:red'>Error loading products: " + e.getMessage() + "</p>");
                e.printStackTrace(out);
            }
            
            out.println("</body>");
            out.println("</html>");
        } finally {
            out.close();
        }
    }
}
