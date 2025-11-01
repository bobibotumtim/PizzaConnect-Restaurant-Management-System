package controller;

import models.Product;
import services.ProductService;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;

@WebServlet(name = "EditProductServlet", urlPatterns = {"/EditProductServlet"})
public class EditProductServlet extends HttpServlet {

    private ProductService productService = new ProductService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Lấy dữ liệu từ form
        int productId = Integer.parseInt(request.getParameter("productId"));
        String productName = request.getParameter("productName");
        String description = request.getParameter("description");
        String categoryName = request.getParameter("categoryName");
        String imageUrl = request.getParameter("imageUrl");
        boolean isAvailable = Boolean.parseBoolean(request.getParameter("isAvailable"));

        // 2. Tạo đối tượng Product
        Product product = new Product();
        product.setProductId(productId); // ID rất quan trọng
        product.setProductName(productName);
        product.setDescription(description);
        product.setCategoryName(categoryName);
        product.setImageUrl(imageUrl);
        product.setAvailable(isAvailable);

        // 3. Gọi Service (Dùng hàm mới: updateBaseProduct)
        boolean result = productService.updateBaseProduct(product);
        
        // 4. Đặt thông báo và Redirect
        HttpSession session = request.getSession();
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