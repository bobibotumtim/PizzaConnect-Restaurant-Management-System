package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.*;
import dao.*;
import models.*;

public class HomeServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        try {
            ProductDAO productDAO = new ProductDAO();
            ProductSizeDAO productSizeDAO = new ProductSizeDAO();
            
            // Get all products
            List<Product> allProducts = productDAO.getAllBaseProducts();
            
            // Group products by category
            Map<String, List<Product>> productsByCategory = new LinkedHashMap<>();
            
            for (Product product : allProducts) {
                String category = product.getCategoryName();
                if (!productsByCategory.containsKey(category)) {
                    productsByCategory.put(category, new ArrayList<>());
                }
                productsByCategory.get(category).add(product);
            }
            
            // Get featured products (first 6)
            List<Product> featuredProducts = allProducts.size() > 6 
                ? allProducts.subList(0, 6) 
                : allProducts;
            
            // Send to JSP
            req.setAttribute("productsByCategory", productsByCategory);
            req.setAttribute("featuredProducts", featuredProducts);
            req.setAttribute("allProducts", allProducts);
            
            req.getRequestDispatcher("/view/Home.jsp").forward(req, resp);
            
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, 
                "Error loading home page: " + e.getMessage());
        }
    }
}
