package controller;

import dao.ProductIngredientDAO;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet(name = "LoadAddSizeFormServlet", urlPatterns = {"/LoadAddSizeFormServlet"})
public class LoadAddSizeFormServlet extends HttpServlet {
    
    private ProductIngredientDAO ingredientDAO = new ProductIngredientDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Lấy ProductID để truyền vào form
        request.setAttribute("productId", request.getParameter("productId"));
        
        // 2. Lấy danh sách nguyên liệu
        List<Map<String, Object>> ingredientList = ingredientDAO.getAllInventories();
        request.setAttribute("ingredientList", ingredientList);

        // 3. Forward đến file JSP
        request.getRequestDispatcher("/view/partials/AddProductSizeForm.jsp").forward(request, response);
    }
}