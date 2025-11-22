package controller;

import dao.CategoryDAO;
import dao.ProductDAO;
import models.Product;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
@WebServlet(name = "AddProductServlet", urlPatterns = {"/AddProductServlet"})
public class AddProductServlet extends HttpServlet {

    private ProductDAO productDAO = new ProductDAO();
    private CategoryDAO categoryDAO = new CategoryDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String productName = request.getParameter("productName");
        String description = request.getParameter("description");
        String categoryName = request.getParameter("categoryName");
        String imageUrl = request.getParameter("imageUrl");

        HttpSession session = request.getSession();
        
        if (productDAO.isProductNameExists(productName, null)) {
            session.setAttribute("message", "Product name already exists");
            session.setAttribute("messageType", "error");
            response.sendRedirect(request.getContextPath() + "/manageproduct");
            return;
        }
        
        if (categoryDAO.getCategoryByName(categoryName) == null) {
            session.setAttribute("message", "Invalid category");
            session.setAttribute("messageType", "error");
            response.sendRedirect(request.getContextPath() + "/manageproduct");
            return;
        }

        Product product = new Product();
        product.setProductName(productName);
        product.setDescription(description);
        product.setCategoryName(categoryName);
        product.setImageUrl(imageUrl);
        product.setAvailable(true);

        boolean result = productDAO.addProduct(product);
        
        if (result) {
            session.setAttribute("message", "Product added successfully!");
            session.setAttribute("messageType", "success");
        } else {
            session.setAttribute("message", "Error adding product.");
            session.setAttribute("messageType", "error");
        }
        
        response.sendRedirect(request.getContextPath() + "/manageproduct");
    }
}