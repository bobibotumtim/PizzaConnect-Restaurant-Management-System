package controller;

import models.Product;
import services.ProductService;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;

@WebServlet(name = "AddProductServlet", urlPatterns = {"/AddProductServlet"})
public class AddProductServlet extends HttpServlet {

    private ProductService productService = new ProductService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Lấy dữ liệu từ form
        String productName = request.getParameter("productName");
        String description = request.getParameter("description");
        String categoryName = request.getParameter("categoryName");
        String imageUrl = request.getParameter("imageUrl");
        boolean isAvailable = true;

        // 2. Tạo đối tượng Product
        Product product = new Product();
        product.setProductName(productName);
        product.setDescription(description);
        product.setCategoryName(categoryName); // Service sẽ tự tìm ID
        product.setImageUrl(imageUrl);
        product.setAvailable(isAvailable);
        // product.setSizes(null) - Hoàn toàn OK

        // 3. Gọi Service
        boolean result = productService.addProductWithSizes(product); // Dùng hàm này là OK
        
        // 4. Đặt thông báo và Redirect
        HttpSession session = request.getSession();
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