package controller;

import models.Product;
import services.ProductService;
import services.ValidationService;
import services.ValidationService.ValidationResult;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;

@WebServlet(name = "AddProductServlet", urlPatterns = {"/AddProductServlet"})
public class AddProductServlet extends HttpServlet {

    private ProductService productService = new ProductService();
    private ValidationService validationService = new ValidationService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Lấy dữ liệu từ form
        String productName = request.getParameter("productName");
        String description = request.getParameter("description");
        String categoryName = request.getParameter("categoryName");
        String imageUrl = request.getParameter("imageUrl");
        boolean isAvailable = true;

        HttpSession session = request.getSession();
        
        // 2. Validate dữ liệu (giả sử giá mặc định là 0 cho validation)
        ValidationResult validationResult = validationService.validateAddProduct(productName, categoryName, 0.0);
        
        if (!validationResult.isValid()) {
            session.setAttribute("message", validationResult.getErrorMessage());
            session.setAttribute("messageType", "error");
            response.sendRedirect(request.getContextPath() + "/manageproduct");
            return;
        }

        // 3. Tạo đối tượng Product
        Product product = new Product();
        product.setProductName(productName);
        product.setDescription(description);
        product.setCategoryName(categoryName); // Service sẽ tự tìm ID
        product.setImageUrl(imageUrl);
        product.setAvailable(isAvailable);

        // 4. Gọi Service
        boolean result = productService.addProductWithSizes(product);
        
        // 5. Đặt thông báo và Redirect
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