package controller;

import dao.CategoryDAO;
import dao.ProductDAO;
import dao.ProductSizeDAO;
import models.Product;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import models.Category;
import models.ProductSize;

@WebServlet(name = "ManageProductServlet", urlPatterns = {"/manageproduct"})
public class ManageProductServlet extends HttpServlet {

    private ProductDAO productDAO;
    private CategoryDAO categoryDAO;
    private ProductSizeDAO sizeDAO;

    @Override
    public void init() throws ServletException {
        productDAO = new ProductDAO();
        categoryDAO = new CategoryDAO();
        sizeDAO = new ProductSizeDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // === 1. Đọc tham số lọc và phân trang ===
        String searchName = request.getParameter("searchName");
        String statusFilter = request.getParameter("statusFilter");
        int pageSize = 10; // Cố định số lượng item mỗi trang

        // === 2. Lấy TẤT CẢ sản phẩm phù hợp với searchName (chưa phân trang) ===
        List<Product> allProducts = null;
        try {
            // Lấy tất cả sản phẩm (với limit lớn để lấy hết)
            allProducts = productDAO.getBaseProductsPaginated(searchName, 1, 10000);
        } catch (SQLException e) {
            e.printStackTrace();
            allProducts = new ArrayList<>();
        }
        
        // Lấy map số lượng của TẤT CẢ size (ProductSizeID -> Qty)
        Map<Integer, Double> sizeAvailabilityMap = productDAO.getProductSizeAvailabilityMap();
        
        // === 3. Tính availability cho từng product và filter theo statusFilter ===
        List<Product> filteredProducts = new ArrayList<>();
        Map<Integer, Boolean> productAvailabilityStatus = new HashMap<>();

        for (Product p : allProducts) {
            boolean isProductAvailable = false; 
            List<ProductSize> sizelist = sizeDAO.getSizesByProductId(p.getProductId());
            if (sizelist != null) {
                // Lặp qua các size của sản phẩm này
                for (ProductSize size : sizelist) {
                    // Lấy số lượng có thể làm của size này từ map
                    double qty = sizeAvailabilityMap.getOrDefault(size.getProductSizeId(), 0.0);
                    if (qty > 0) {
                        isProductAvailable = true; // Chỉ cần 1 size > 0
                        break; // Thoát vòng lặp size
                    }
                }
            }
            productAvailabilityStatus.put(p.getProductId(), isProductAvailable);
            
            // Filter theo statusFilter
            if (statusFilter == null || statusFilter.isEmpty() || "all".equals(statusFilter)) {
                filteredProducts.add(p);
            } else if ("available".equals(statusFilter) && isProductAvailable) {
                filteredProducts.add(p);
            } else if ("unavailable".equals(statusFilter) && !isProductAvailable) {
                filteredProducts.add(p);
            }
        }

        // === 4. Phân trang sau khi filter ===
        int totalProducts = filteredProducts.size();
        int totalPages = (int) Math.ceil((double) totalProducts / pageSize);
        if (totalPages == 0) totalPages = 1;
        
        int currentPage = 1;
        String pageParam = request.getParameter("page");
        if (pageParam != null) {
            try {
                currentPage = Integer.parseInt(pageParam);
            } catch (NumberFormatException e) {
                currentPage = 1;
            }
        }
        if (currentPage > totalPages) currentPage = totalPages;
        if (currentPage < 1) currentPage = 1;
        
        // Lấy products cho trang hiện tại
        int startIndex = (currentPage - 1) * pageSize;
        int endIndex = Math.min(startIndex + pageSize, totalProducts);
        List<Product> productsForPage = filteredProducts.subList(startIndex, endIndex);

        // === 5. Gửi dữ liệu sang JSP ===
        request.setAttribute("products", productsForPage);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        
        // Gửi lại các tham số lọc để JSP "nhớ"
        request.setAttribute("searchName", searchName);
        request.setAttribute("statusFilter", statusFilter);
        
        List<Category> categoryList = categoryDAO.getAllCategories();
        request.setAttribute("categoryList", categoryList);
        
        request.setAttribute("productAvailabilityStatus", productAvailabilityStatus);

        // Chuyển tiếp đến JSP
        RequestDispatcher dispatcher = request.getRequestDispatcher("/view/ManageProduct.jsp");
        dispatcher.forward(request, response);
    }
}