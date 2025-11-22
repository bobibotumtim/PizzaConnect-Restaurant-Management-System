package controller;

import dao.CategoryDAO;
import dao.ProductDAO;
import models.Product;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;

@WebServlet(name = "EditProductServlet", urlPatterns = {"/EditProductServlet"})
public class EditProductServlet extends HttpServlet {

    private ProductDAO productDAO = new ProductDAO();
    private CategoryDAO categoryDAO = new CategoryDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        int productId = Integer.parseInt(request.getParameter("productId"));
        String productName = request.getParameter("productName");
        String description = request.getParameter("description");
        String categoryName = request.getParameter("categoryName");
        String imageUrl = request.getParameter("imageUrl");

        HttpSession session = request.getSession();
        
        Product existing = productDAO.getProductById(productId);
        if (existing == null) {
            session.setAttribute("message", "Product not found");
            session.setAttribute("messageType", "error");
            response.sendRedirect(request.getContextPath() + "/manageproduct");
            return;
        }
        
        if (productDAO.isProductNameExists(productName, productId)) {
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
        product.setProductId(productId);
        product.setProductName(productName);
        product.setDescription(description);
        product.setCategoryName(categoryName);
        product.setImageUrl(imageUrl);
        product.setAvailable(true);

        boolean result = productDAO.updateProduct(product);
        
        if (result) {
            session.setAttribute("message", "Product updated successfully!");
            session.setAttribute("messageType", "success");
        } else {
            session.setAttribute("message", "Error updating product.");
            session.setAttribute("messageType", "error");
        }
        
        response.sendRedirect(request.getContextPath() + "/manageproduct");
    }
}