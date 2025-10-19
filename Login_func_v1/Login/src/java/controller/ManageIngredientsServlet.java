package controllers;

import dao.ProductIngredientDAO;
import models.ProductIngredient;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/manageingredients")
public class ManageIngredientsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String productIdParam = request.getParameter("productId");

        // ✅ Kiểm tra xem có truyền productId hợp lệ không
        if (productIdParam == null || productIdParam.trim().isEmpty()) {
            request.setAttribute("error", "Missing or invalid product ID.");
            RequestDispatcher dispatcher = request.getRequestDispatcher("/view/ManageIngredientsPopup.jsp");
            dispatcher.forward(request, response);
            return;
        }

        try {
            int productId = Integer.parseInt(productIdParam);
            ProductIngredientDAO dao = new ProductIngredientDAO();
            List<ProductIngredient> list = dao.getIngredientsByProduct(productId);

            request.setAttribute("ingredients", list);
            request.setAttribute("productId", productId);

        } catch (NumberFormatException e) {
            // ✅ Nếu productId không phải số
            request.setAttribute("error", "Invalid product ID format: " + productIdParam);
        } catch (Exception e) {
            // ✅ Nếu xảy ra lỗi khác (VD: lỗi DB)
            request.setAttribute("error", "Error while loading ingredients: " + e.getMessage());
        }

        // ✅ Dù có lỗi hay không vẫn forward để JSP xử lý thông báo
        RequestDispatcher dispatcher = request.getRequestDispatcher("/view/ManageIngredientsPopup.jsp");
        dispatcher.forward(request, response);
    }
}
