package controller;

import dao.CategoryDAO;
import dao.ProductDAO;
import dao.DBContext;
import models.Product;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
@WebServlet(name = "EditProductServlet", urlPatterns = {"/EditProductServlet"})
public class EditProductServlet extends HttpServlet {

    private ProductDAO productDAO = new ProductDAO();
    private CategoryDAO categoryDAO = new CategoryDAO();
    private DBContext dbContext = new DBContext();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        int productId = Integer.parseInt(request.getParameter("productId"));
        String productName = request.getParameter("productName");
        String description = request.getParameter("description");
        String categoryName = request.getParameter("categoryName");
        String existingImageUrl = request.getParameter("existingImageUrl");
        String newImageUrl = request.getParameter("imageUrl");
        
        String imageUrl = (newImageUrl != null && !newImageUrl.trim().isEmpty()) 
                          ? newImageUrl.trim() 
                          : existingImageUrl;

        HttpSession session = request.getSession();
        
        Product existing = productDAO.getProductById(productId);
        if (existing == null) {
            session.setAttribute("message", "Product not found");
            session.setAttribute("messageType", "error");
            response.sendRedirect(request.getContextPath() + "/manageproduct");
            return;
        }
        
        try {
            if (productDAO.isProductNameExists(productName, productId)) {
                session.setAttribute("message", "Product name already exists");
                session.setAttribute("messageType", "error");
                response.sendRedirect(request.getContextPath() + "/manageproduct");
                return;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        Product product = new Product();
        product.setProductId(productId);
        product.setProductName(productName);
        product.setDescription(description);
        product.setCategoryName(categoryName);
        product.setImageUrl(imageUrl);
        product.setAvailable(true);

        boolean result = updateBaseProduct(product);
        
        if (result) {
            session.setAttribute("message", "Product updated successfully!");
            session.setAttribute("messageType", "success");
        } else {
            session.setAttribute("message", "Error updating product.");
            session.setAttribute("messageType", "error");
        }
        
        response.sendRedirect(request.getContextPath() + "/manageproduct");
    }
    
    private boolean updateBaseProduct(Product product) {
        Connection con = null;
        try {
            con = dbContext.getConnection();
            con.setAutoCommit(false);

            int categoryId = categoryDAO.getCategoryIdByName(product.getCategoryName(), con);
            productDAO.updateBaseProduct(product, categoryId, con);
            
            con.commit();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            try {
                if (con != null) con.rollback();
            } catch (SQLException e2) {
                e2.printStackTrace();
            }
            return false;
        } finally {
            try {
                if (con != null) {
                    con.setAutoCommit(true);
                    con.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}