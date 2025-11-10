package controller;

import dao.ProductSizeDAO;
import dao.ProductIngredientDAO;
import models.ProductSize;
import models.ProductIngredient;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet(name = "LoadEditSizeFormServlet", urlPatterns = {"/LoadEditSizeFormServlet"})
public class LoadEditSizeFormServlet extends HttpServlet {

    private ProductIngredientDAO ingredientDAO = new ProductIngredientDAO();
    private ProductSizeDAO productSizeDAO = new ProductSizeDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        int productSizeId = Integer.parseInt(request.getParameter("productSizeId"));

        // 1. Lấy ProductSize
        ProductSize size = productSizeDAO.getProductSizeById(productSizeId);
        
        // 2. Lấy công thức HIỆN TẠI của size đó
        List<ProductIngredient> currentIngredients = ingredientDAO.getIngredientsByProductSizeId(productSizeId);
        
        // 3. Lấy TẤT CẢ nguyên liệu (cho dropdown)
        List<Map<String, Object>> ingredientList = ingredientDAO.getAllInventories();

        request.setAttribute("size", size);
        request.setAttribute("currentIngredients", currentIngredients);
        request.setAttribute("ingredientList", ingredientList);

        // 4. Forward đến file JSP
        request.getRequestDispatcher("/view/partials/EditProductSizeForm.jsp").forward(request, response);
    }
}