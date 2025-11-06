package controller;

import models.Product;
import services.ProductService;
import services.ValidationService;
import services.ValidationService.ValidationResult;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;

@WebServlet(name = "EditProductServlet", urlPatterns = {"/EditProductServlet"})
public class EditProductServlet extends HttpServlet {

    private ProductService productService = new ProductService();
    private ValidationService validationService = new ValidationService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Lấy dữ liệu từ form
        int productId = Integer.parseInt(request.getParameter("productId"));
        String productName = request.getParameter("productName");
        String description = request.getParameter("description");
        String categoryName = request.getParameter("categoryName");
        String imageUrl = request.getParameter("imageUrl");
        boolean isAvailable = true;

        HttpSession session = request.getSession();
        
        // 2. Validate dữ liệu (giả sử giá mặc định là 0 cho validation)
        ValidationResult validationResult = validationService.validateEditProduct(productId, productName, categoryName, 0.0);
        
        if (!validationResult.isValid()) {
            session.setAttribute("message", validationResult.getErrorMessage());
            session.setAttribute("messageType", "error");
            response.sendRedirect(request.getContextPath() + "/manageproduct");
            return;
        }

        // 3. Tạo đối tượng Product
        Product product = new Product();
        product.setProductId(productId); // ID rất quan trọng
        product.setProductName(productName);
        product.setDescription(description);
        product.setCategoryName(categoryName);
        product.setImageUrl(imageUrl);
        product.setAvailable(isAvailable);

        // 4. Gọi Service (Dùng hàm mới: updateBaseProduct)
        boolean result = productService.updateBaseProduct(product);
        
        // 5. Đặt thông báo và Redirect
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