package controller;

// ✅ THAY ĐỔI IMPORT
import dao.CategoryDAO;
import dao.ProductSizeDAO;
import services.ProductService; 
import models.Product;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import models.Category;
import models.ProductSize;

@WebServlet(name = "ManageProductServlet", urlPatterns = {"/manageproduct"})
public class ManageProductServlet extends HttpServlet {

    // ✅ Khởi tạo Service
    private ProductService productService;
    private CategoryDAO categoryDAO;
    private ProductSizeDAO sizeDAO;

    @Override
    public void init() throws ServletException {
        productService = new ProductService();
        categoryDAO = new CategoryDAO();
        sizeDAO = new ProductSizeDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // === 1. Đọc tham số lọc và phân trang ===
        String searchName = request.getParameter("searchName");
        String statusFilter = request.getParameter("statusFilter");
        int currentPage = 1;
        int pageSize = 10; // Cố định số lượng item mỗi trang

        String pageParam = request.getParameter("page");
        if (pageParam != null) {
            try {
                currentPage = Integer.parseInt(pageParam);
            } catch (NumberFormatException e) {
                currentPage = 1;
            }
        }

        // === 2. Lấy dữ liệu từ Service (Đã lọc và phân trang) ===
        
        // Lấy tổng số sản phẩm (để tính tổng số trang)
        int totalProducts = productService.getProductCount(searchName, statusFilter);
        int totalPages = (int) Math.ceil((double) totalProducts / pageSize);
        if (totalPages == 0) totalPages = 1;
        if (currentPage > totalPages) currentPage = totalPages;
        
        // Lấy danh sách sản phẩm cho trang hiện tại
        List<Product> products = productService.getProductsPaginated(searchName, statusFilter, currentPage, pageSize);
        
        // Lấy map số lượng của TẤT CẢ size (ProductID -> Qty)
        Map<Integer, Double> sizeAvailabilityMap = productService.getProductSizeAvailabilityMap();
        
        // Tạo map mới (ProductID -> Boolean) để JSP sử dụng
        Map<Integer, Boolean> productAvailabilityStatus = new HashMap<>();

        for (Product p : products) {
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
        }

        // === 3. Gửi dữ liệu sang JSP ===
        request.setAttribute("products", products);
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