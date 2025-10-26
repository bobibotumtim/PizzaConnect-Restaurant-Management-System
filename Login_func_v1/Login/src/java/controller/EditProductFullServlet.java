package controller;

import dao.ProductDAO;
import dao.ProductIngredientDAO;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import models.Product;
import models.ProductIngredient;

@WebServlet("/EditProductFullServlet")
public class EditProductFullServlet extends HttpServlet {
    
     @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int productId = Integer.parseInt(request.getParameter("productId"));
        ProductDAO productDAO = new ProductDAO();
        ProductIngredientDAO piDAO = new ProductIngredientDAO();

        Product product = productDAO.getProductById(productId);
        List<ProductIngredient> ingredients = piDAO.getIngredientsByProduct(productId);
        List<Map<String, Object>> ingredientList = piDAO.getAllInventories();

        request.setAttribute("product", product);
        request.setAttribute("currentIngredients", ingredients);
        request.setAttribute("ingredientList", ingredientList);

        request.getRequestDispatcher("/view/EditProductFullContent.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();

        try {
            int productId = Integer.parseInt(request.getParameter("productId"));
            String name = request.getParameter("productName");
            String desc = request.getParameter("description");
            String category = request.getParameter("category");
            String image = request.getParameter("imageUrl");
            double price = Double.parseDouble(request.getParameter("price"));

            // Cập nhật product
            Product updated = new Product(productId, name, desc, price, category, image, true);
            ProductDAO pdao = new ProductDAO();
            pdao.updateProduct(updated);

            // Xử lý ingredient
            ProductIngredientDAO idao = new ProductIngredientDAO();
            List<ProductIngredient> oldList = idao.getIngredientsByProduct(productId);

            String[] inventoryIds = request.getParameterValues("inventoryId[]");
            String[] quantities = request.getParameterValues("quantity[]");
            String[] units = request.getParameterValues("unit[]");

            Set<Integer> sentIds = new HashSet<>();
            if (inventoryIds != null) {
                for (int i = 0; i < inventoryIds.length; i++) {
                    int invId = Integer.parseInt(inventoryIds[i]);
                    sentIds.add(invId);
                    double qty = Double.parseDouble(quantities[i]);
                    String unit = units[i];

                    // Nếu ingredient tồn tại -> update, nếu chưa -> add
                    boolean exists = oldList.stream().anyMatch(pi -> pi.getInventoryId() == invId);
                    if (exists) {
                        ProductIngredient pi = new ProductIngredient(productId, invId, qty, unit);
                        idao.updateIngredient(pi);
                    } else {
                        idao.addIngredientToProduct(productId, invId, qty, unit);
                    }
                }
            }

            // Xóa những ingredient cũ mà không còn trong sentIds
            for (ProductIngredient pi : oldList) {
                if (!sentIds.contains(pi.getInventoryId())) {
                    idao.deleteIngredientFromProduct(productId, pi.getInventoryId());
                }
            }

            session.setAttribute("message", "✅ Product & ingredients updated successfully!");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("message", "❌ Error: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/manageproduct");
    }

}
