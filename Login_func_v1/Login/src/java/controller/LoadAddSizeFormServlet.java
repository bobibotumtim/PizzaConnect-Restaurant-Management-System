package controller;

import services.ProductIngredientService;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet(name = "LoadAddSizeFormServlet", urlPatterns = {"/LoadAddSizeFormServlet"})
public class LoadAddSizeFormServlet extends HttpServlet {
    
    private ProductIngredientService ingredientService = new ProductIngredientService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Lấy ProductID để truyền vào form
        request.setAttribute("productId", request.getParameter("productId"));
        
        // 2. Lấy danh sách nguyên liệu (giống hệt logic cũ)
        List<Map<String, Object>> ingredientList = ingredientService.getAllInventories();
        request.setAttribute("ingredientList", ingredientList);

        // 3. Forward đến file JSP TÁI SỬ DỤNG
        request.getRequestDispatcher("/view/partials/AddProductSizeForm.jsp").forward(request, response);
    }
}