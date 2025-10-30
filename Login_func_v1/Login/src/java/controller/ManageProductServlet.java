package controller;

import dao.ProductDAO;
import dao.ProductIngredientDAO;
import models.Product;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.util.List;
import java.util.Map;
// ✅ Thêm 2 import này
import java.util.stream.Collectors;
import java.util.stream.Stream;

@WebServlet(name = "ManageProductServlet", urlPatterns = {"/manageproduct"})
public class ManageProductServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        ProductDAO dao = new ProductDAO();
        Map<Integer, Double> availabilityMap = dao.getProductAvailability();

        // === ✅ Đọc tham số tìm kiếm và lọc ===
        String searchName = request.getParameter("searchName");
        String statusFilter = request.getParameter("statusFilter");

        // === Lấy danh sách nguyên liệu (để dùng cho popup, giữ nguyên) ===
        ProductIngredientDAO piDAO = new ProductIngredientDAO();
        List<Map<String, Object>> ingredientList = piDAO.getAllInventories();
        request.getSession().setAttribute("ingredientList", ingredientList);

        // === Lấy TẤT CẢ sản phẩm ===
        ProductDAO dao1 = new ProductDAO();
        List<Product> allProducts = dao1.getAllProducts();

        // === ✅ Áp dụng lọc và tìm kiếm (TRƯỚC KHI PHÂN TRANG) ===
        Stream<Product> productStream = allProducts.stream();

        // 1. Lọc theo tên
        if (searchName != null && !searchName.trim().isEmpty()) {
            String searchLower = searchName.trim().toLowerCase();
            productStream = productStream.filter(p -> p.getProductName().toLowerCase().contains(searchLower));
            request.setAttribute("searchName", searchName); // Gửi lại để JSP "nhớ"
        }

        // 2. Lọc theo status
        if (statusFilter != null && !statusFilter.isEmpty() && !"all".equals(statusFilter)) {
            boolean wantAvailable = "available".equals(statusFilter);
            productStream = productStream.filter(p -> {
                // Lấy số lượng có thể làm từ map
                double availableQty = availabilityMap.getOrDefault(p.getProductId(), 0.0);
                boolean isAvailable = availableQty > 0;
                // So sánh trạng thái thực tế với trạng thái muốn lọc
                return isAvailable == wantAvailable;
            });
            request.setAttribute("statusFilter", statusFilter); // Gửi lại để JSP "nhớ"
        }

        // Lấy danh sách cuối cùng sau khi đã lọc
        List<Product> filteredProducts = productStream.collect(Collectors.toList());

        // === Phân trang (trên danh sách ĐÃ LỌC) ===
        int pageSize = 10;
        int currentPage = 1;

        String pageParam = request.getParameter("page");
        if (pageParam != null) {
            try {
                currentPage = Integer.parseInt(pageParam);
            } catch (NumberFormatException e) {
                currentPage = 1;
            }
        }

        // ✅ Cập nhật: dùng 'filteredProducts' thay vì 'allProducts'
        int totalProducts = filteredProducts.size();
        int totalPages = (int) Math.ceil((double) totalProducts / pageSize);
        
        // ✅ Thêm 2 dòng này để tránh lỗi
        if (totalPages == 0) {
            totalPages = 1; // Đảm bảo luôn có ít nhất 1 trang (kể cả trang rỗng)
        }
        if (currentPage > totalPages) {
            currentPage = totalPages; // Nếu trang hiện tại vượt quá tổng số trang (do lọc), quay về trang cuối
        }

        // Cắt danh sách theo trang hiện tại
        int start = (currentPage - 1) * pageSize;
        int end = Math.min(start + pageSize, totalProducts);
        
        // ✅ Cập nhật: dùng 'filteredProducts'
        List<Product> products = filteredProducts.subList(start, end);

        // Gửi dữ liệu sang JSP
        request.setAttribute("products", products);
        request.setAttribute("availabilityMap", availabilityMap);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);

        // Chuyển tiếp đến JSP
        RequestDispatcher dispatcher = request.getRequestDispatcher("/view/ManageProduct.jsp");
        dispatcher.forward(request, response);
    }
}