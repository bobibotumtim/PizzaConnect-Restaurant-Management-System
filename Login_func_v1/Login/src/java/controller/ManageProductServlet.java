package controller;

// ✅ THAY ĐỔI IMPORT
import services.ProductService; 
import models.Product;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "ManageProductServlet", urlPatterns = {"/manageproduct"})
public class ManageProductServlet extends HttpServlet {

    // ✅ Khởi tạo Service
    private ProductService productService;

    @Override
    public void init() throws ServletException {
        productService = new ProductService();
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

        // === 3. Gửi dữ liệu sang JSP ===
        request.setAttribute("products", products);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        
        // Gửi lại các tham số lọc để JSP "nhớ"
        request.setAttribute("searchName", searchName);
        request.setAttribute("statusFilter", statusFilter);
        
        // Lấy danh sách category (cho modal Add/Edit)
        // (Tạm thời bỏ qua, nếu bạn có CategoryService, hãy gọi nó ở đây)
        // List<Category> categories = categoryDAO.getAllCategories();
        // request.setAttribute("categories", categories);

        // Chuyển tiếp đến JSP
        RequestDispatcher dispatcher = request.getRequestDispatcher("/view/ManageProduct.jsp");
        dispatcher.forward(request, response);
    }
}