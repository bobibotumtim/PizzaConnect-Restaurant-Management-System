package controller;

import dao.*;
import models.Product;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;

@WebServlet("/AddProductServlet")
public class AddProductServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            // === Lấy thông tin sản phẩm ===
            String name = request.getParameter("productName");
            String desc = request.getParameter("description");
            double price = Double.parseDouble(request.getParameter("price"));
            String category = request.getParameter("category");
            String image = request.getParameter("imageUrl");
            boolean isAvailable = Boolean.parseBoolean(request.getParameter("isAvailable"));

            ProductDAO pdao = new ProductDAO();
            int productId = pdao.addProduct(new Product(name, desc, price, category, image, isAvailable));

            if (productId > 0) {

                // === Lấy danh sách nguyên liệu từ form ===
                String[] ingIds = request.getParameterValues("ingredientId[]");
                String[] ingQty = request.getParameterValues("ingredientQty[]");
                String[] ingUnit = request.getParameterValues("ingredientUnit[]");

                if (ingIds != null && ingQty != null && ingUnit != null) {
                    ProductIngredientDAO idao = new ProductIngredientDAO();

                    for (int i = 0; i < ingIds.length; i++) {
                        // ✅ Check tất cả trường trước khi parse
                        if (ingIds[i] != null && !ingIds[i].trim().isEmpty() &&
                            ingQty[i] != null && !ingQty[i].trim().isEmpty()) {

                            try {
                                int inventoryId = Integer.parseInt(ingIds[i]);
                                double qty = Double.parseDouble(ingQty[i]);
                                String unit = (ingUnit[i] != null) ? ingUnit[i] : "";

                                // Thêm nguyên liệu
                                idao.addIngredientToProduct(productId, inventoryId, qty, unit);

                            } catch (NumberFormatException ex) {
                                // Nếu parse thất bại, bỏ qua row này
                                System.err.println("Invalid ingredient input at index " + i + ": " + ex.getMessage());
                            }
                        }
                    }
                }

                request.getSession().setAttribute("message", "Product added successfully!");
            } else {
                request.getSession().setAttribute("message", "Failed to add product!");
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("message", "Error: " + e.getMessage());
        }

        response.sendRedirect("manageproduct");
    }
}

