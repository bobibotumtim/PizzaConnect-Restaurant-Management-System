package controller;

import dao.ProductDAO;
import dao.ProductSizeDAO;
import models.Product;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import models.ProductSize;

@WebServlet(name = "ViewProductSizesServlet", urlPatterns = {"/ViewProductSizesServlet"})
public class ViewProductSizesServlet extends HttpServlet {

    private ProductDAO productDAO = new ProductDAO();
    private ProductSizeDAO sizedao = new ProductSizeDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            int productId = Integer.parseInt(request.getParameter("productId"));
            List<ProductSize> sizelist = sizedao.getSizesByProductId(productId);
            
            // 1. Lấy chi tiết Product
            Product product = productDAO.getBaseProductById(productId);
            
            // 2. Lấy map số lượng có thể làm
            Map<Integer, Double> availabilityMap = productDAO.getProductSizeAvailabilityMap();

            request.setAttribute("product", product);
            request.setAttribute("availabilityMap", availabilityMap);
            request.setAttribute("sizelist", sizelist);
            
            // 3. Forward đến file JSP
            request.getRequestDispatcher("/view/partials/ProductSizesDetail.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("Lỗi: " + e.getMessage());
        }
    }
}