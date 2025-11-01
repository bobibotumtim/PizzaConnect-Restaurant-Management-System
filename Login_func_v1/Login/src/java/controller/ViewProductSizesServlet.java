package controller;

import models.Product;
import services.ProductService;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.util.Map;

@WebServlet(name = "ViewProductSizesServlet", urlPatterns = {"/ViewProductSizesServlet"})
public class ViewProductSizesServlet extends HttpServlet {

    private ProductService productService = new ProductService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            int productId = Integer.parseInt(request.getParameter("productId"));

            // 1. Lấy chi tiết Product (đã bao gồm list sizes)
            Product product = productService.getProductDetails(productId);
            
            // 2. Lấy map số lượng có thể làm
            Map<Integer, Double> availabilityMap = productService.getProductSizeAvailabilityMap();

            request.setAttribute("product", product);
            request.setAttribute("availabilityMap", availabilityMap);
            
            // 3. Forward đến 1 file JSP MỚI (chỉ là 1 phần, không phải full page)
            request.getRequestDispatcher("/view/partials/ProductSizesDetail.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("Lỗi: " + e.getMessage());
        }
    }
}