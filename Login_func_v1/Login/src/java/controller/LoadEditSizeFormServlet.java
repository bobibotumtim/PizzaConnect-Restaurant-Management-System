package controller;

import models.ProductSize;
import models.ProductIngredient;
import services.ProductIngredientService;
// (Import DAO/Service cho ProductSize nếu cần)
import dao.ProductSizeDAO; // Tạm dùng DAO
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet(name = "LoadEditSizeFormServlet", urlPatterns = {"/LoadEditSizeFormServlet"})
public class LoadEditSizeFormServlet extends HttpServlet {

    private ProductIngredientService ingredientService = new ProductIngredientService();
    private ProductSizeDAO productSizeDAO = new ProductSizeDAO(); // Tạm dùng DAO

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        int productSizeId = Integer.parseInt(request.getParameter("productSizeId"));

        // 1. Lấy ProductSize
        ProductSize size = productSizeDAO.getSizeById(productSizeId); // (Bạn cần viết hàm này)
        
        // 2. Lấy công thức HIỆN TẠI của size đó
        List<ProductIngredient> currentIngredients = ingredientService.getIngredientsForSize(productSizeId);
        
        // 3. Lấy TẤT CẢ nguyên liệu (cho dropdown)
        List<Map<String, Object>> ingredientList = ingredientService.getAllInventories();

        request.setAttribute("size", size);
        request.setAttribute("currentIngredients", currentIngredients);
        request.setAttribute("ingredientList", ingredientList);

        // 4. Forward đến file JSP TÁI SỬ DỤNG
        request.getRequestDispatcher("/view/partials/EditProductSizeForm.jsp").forward(request, response);
    }
}