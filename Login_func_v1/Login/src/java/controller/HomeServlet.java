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
            
            // Create a map to store products with their sizes
            Map<Product, List<ProductSize>> productsWithSizes = new LinkedHashMap<>();
            
            for (Product product : allProducts) {
                List<ProductSize> sizes = productSizeDAO.getSizesByProductId(product.getProductId());
                if (!sizes.isEmpty()) {
                    productsWithSizes.put(product, sizes);
                }
            }
            
            // Group products by category
            Map<String, Map<Product, List<ProductSize>>> productsByCategory = new LinkedHashMap<>();
            
            for (Map.Entry<Product, List<ProductSize>> entry : productsWithSizes.entrySet()) {
                Product product = entry.getKey();
                List<ProductSize> sizes = entry.getValue();
                String category = product.getCategoryName();
                
                if (!productsByCategory.containsKey(category)) {
                    productsByCategory.put(category, new LinkedHashMap<>());
                }
                productsByCategory.get(category).put(product, sizes);
            }
            
            // Get featured products (first 6)
            List<Map.Entry<Product, List<ProductSize>>> featuredList = new ArrayList<>(productsWithSizes.entrySet());
            Map<Product, List<ProductSize>> featuredProducts = new LinkedHashMap<>();
            int limit = Math.min(6, featuredList.size());
            for (int i = 0; i < limit; i++) {
                Map.Entry<Product, List<ProductSize>> entry = featuredList.get(i);
                featuredProducts.put(entry.getKey(), entry.getValue());
            }
            
            // Send to JSP
            req.setAttribute("productsByCategory", productsByCategory);
            req.setAttribute("featuredProducts", featuredProducts);
            req.setAttribute("productsWithSizes", productsWithSizes);
            
            req.getRequestDispatcher("/view/Home.jsp").forward(req, resp);
            
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, 
                "Error loading home page: " + e.getMessage());
        }
    }
}
