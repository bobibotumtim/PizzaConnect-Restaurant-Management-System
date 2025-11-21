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
@WebServlet(name = "AddProductServlet", urlPatterns = {"/AddProductServlet"})
public class AddProductServlet extends HttpServlet {

    private ProductDAO productDAO = new ProductDAO();
    private CategoryDAO categoryDAO = new CategoryDAO();
    private DBContext dbContext = new DBContext();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String productName = request.getParameter("productName");
        String description = request.getParameter("description");
        String categoryName = request.getParameter("categoryName");
        String imageUrl = request.getParameter("imageUrl");

        HttpSession session = request.getSession();
        
        try {
            if (productDAO.isProductNameExists(productName, null)) {
                session.setAttribute("message", "Product name already exists");
                session.setAttribute("messageType", "error");
                response.sendRedirect(request.getContextPath() + "/manageproduct");
                return;
            }
        } catch (Exception e) {
            e.printStackTrace();
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
        product.setImageUrl(imageUrl != null ? imageUrl.trim() : "");
        product.setAvailable(true);

        boolean result = addProductWithSizes(product);
        
        if (result) {
            session.setAttribute("message", "Product added successfully!");
            session.setAttribute("messageType", "success");
        } else {
            session.setAttribute("message", "Error adding product.");
            session.setAttribute("messageType", "error");
        }
        
        response.sendRedirect(request.getContextPath() + "/manageproduct");
    }
    
    private boolean addProductWithSizes(Product product) {
        Connection con = null;
        try {
            con = dbContext.getConnection();
            con.setAutoCommit(false);

            int categoryId = categoryDAO.getCategoryIdByName(product.getCategoryName(), con);
            productDAO.addProduct(product, categoryId, con);

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