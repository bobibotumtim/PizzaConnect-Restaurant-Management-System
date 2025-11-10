package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.*;
import dao.*;
import models.*;

public class CustomerMenuServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        try {
            ProductDAO productDAO = new ProductDAO();
            ProductSizeDAO productSizeDAO = new ProductSizeDAO();
            CategoryDAO categoryDAO = new CategoryDAO();
            
            // Get filter parameters
            String categoryFilter = req.getParameter("category");
            
            // Get all products
            List<Product> allProducts = productDAO.getAllBaseProducts();
            
            // Get all categories for filter
            List<Category> categories = categoryDAO.getAllCategories();
            
            // Create a map to store products with their sizes
            Map<Product, List<ProductSize>> productsWithSizes = new LinkedHashMap<>();
            
            for (Product product : allProducts) {
                // Filter by category if specified
                if (categoryFilter != null && !categoryFilter.isEmpty() && !categoryFilter.equals("all")) {
                    if (!product.getCategoryName().equals(categoryFilter)) {
                        continue;
                    }
                }
                
                // Get sizes for this product
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
            
            // Send to JSP
            req.setAttribute("productsByCategory", productsByCategory);
            req.setAttribute("productsWithSizes", productsWithSizes);
            req.setAttribute("categories", categories);
            req.setAttribute("selectedCategory", categoryFilter);
            
            req.getRequestDispatcher("/view/CustomerMenu.jsp").forward(req, resp);
            
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, 
                "Error loading menu: " + e.getMessage());
        }
    }
}
