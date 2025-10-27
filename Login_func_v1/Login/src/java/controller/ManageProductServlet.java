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

@WebServlet(name = "ManageProductServlet", urlPatterns = {"/manageproduct"})
public class ManageProductServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        ProductDAO dao = new ProductDAO();
        Map<Integer, Double> availabilityMap = dao.getProductAvailability();

        // === Phân trang ===
        int pageSize = 10; // số sản phẩm mỗi trang
        int currentPage = 1;

        String pageParam = request.getParameter("page");
        if (pageParam != null) {
            try {
                currentPage = Integer.parseInt(pageParam);
            } catch (NumberFormatException e) {
                currentPage = 1;
            }
        }
        
        // Lấy toàn bộ danh sách (hoặc bạn có thể viết hàm lấy theo trang)
        ProductDAO dao1 = new ProductDAO();
        List<Product> allProducts = dao1.getAllProducts();
        int totalProducts = allProducts.size();
        int totalPages = (int) Math.ceil((double) totalProducts / pageSize);

        // Cắt danh sách theo trang hiện tại
        int start = (currentPage - 1) * pageSize;
        int end = Math.min(start + pageSize, totalProducts);
        List<Product> products = allProducts.subList(start, end);

        // Gửi dữ liệu sang JSP
        request.setAttribute("products", products);
        request.setAttribute("availabilityMap", availabilityMap);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);

        // === Lấy danh sách nguyên liệu để hiển thị trong popup ===
        ProductIngredientDAO piDAO = new ProductIngredientDAO();
        List<Map<String, Object>> ingredientList = piDAO.getAllInventories();
        request.getSession().setAttribute("ingredientList", ingredientList);

        // Chuyển tiếp đến JSP
        RequestDispatcher dispatcher = request.getRequestDispatcher("/view/ManageProduct.jsp");
        dispatcher.forward(request, response);
    }
}
