package controller;

import dao.*;
import models.Product;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.util.HashSet;
import java.util.Set;

@WebServlet("/AddProductServlet")
public class AddProductServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();

        try {
            // === Lấy thông tin sản phẩm ===
            String name = request.getParameter("productName");
            String desc = request.getParameter("description");
            String category = request.getParameter("category");
            String image = request.getParameter("imageUrl");
            boolean isAvailable = true;

            // --- Kiểm tra giá không âm ---
            double price;
            try {
                price = Double.parseDouble(request.getParameter("price"));
                if (price < 0) {
                    session.setAttribute("message", "⚠️ Price cannot be negative!");
                    session.setAttribute("messageType", "error");
                    response.sendRedirect("manageproduct");
                    return;
                }
            } catch (NumberFormatException ex) {
                session.setAttribute("message", "⚠️ Invalid price format!");
                session.setAttribute("messageType", "error");
                response.sendRedirect("manageproduct");
                return;
            }

            // === Lấy danh sách nguyên liệu từ form ===
            String[] ingIds = request.getParameterValues("ingredientId[]");
            String[] ingQty = request.getParameterValues("ingredientQty[]");
            String[] ingUnit = request.getParameterValues("ingredientUnit[]");

            // === Kiểm tra trùng nguyên liệu ===
            if (ingIds != null) {
                Set<String> uniqueCheck = new HashSet<>();
                for (String id : ingIds) {
                    if (id != null && !id.trim().isEmpty()) {
                        if (!uniqueCheck.add(id.trim())) {
                            session.setAttribute("message", "⚠️ Duplicate ingredients detected! Please remove duplicates.");
                            session.setAttribute("messageType", "error");
                            response.sendRedirect("manageproduct");
                            return;
                        }
                    }
                }
            }

            // === Thêm sản phẩm ===
            ProductDAO pdao = new ProductDAO();
            int productId = pdao.addProduct(new Product(name, desc, price, category, image, isAvailable));

            if (productId > 0) {
                // === Thêm nguyên liệu ===
                if (ingIds != null && ingQty != null && ingUnit != null) {
                    ProductIngredientDAO idao = new ProductIngredientDAO();

                    for (int i = 0; i < ingIds.length; i++) {
                        if (ingIds[i] != null && !ingIds[i].trim().isEmpty() &&
                            ingQty[i] != null && !ingQty[i].trim().isEmpty()) {

                            try {
                                int inventoryId = Integer.parseInt(ingIds[i]);
                                double qty = Double.parseDouble(ingQty[i]);

                                // --- Kiểm tra quantity không âm ---
                                if (qty < 0) {
                                    session.setAttribute("message", "⚠️ Quantity cannot be negative (ingredient index: " + (i + 1) + ")!");
                                    session.setAttribute("messageType", "error");
                                    response.sendRedirect("manageproduct");
                                    return;
                                }

                                String unit = (ingUnit[i] != null) ? ingUnit[i] : "";
                                idao.addIngredientToProduct(productId, inventoryId, qty, unit);

                            } catch (NumberFormatException ex) {
                                System.err.println("Invalid ingredient input at index " + i + ": " + ex.getMessage());
                                session.setAttribute("message", "⚠️ Invalid ingredient data at row " + (i + 1));
                                session.setAttribute("messageType", "error");
                                response.sendRedirect("manageproduct");
                                return;
                            }
                        }
                    }
                }

                session.setAttribute("message", "✅ Product added successfully!");
                session.setAttribute("messageType", "success");
            } else {
                session.setAttribute("message", "❌ Failed to add product!");
                session.setAttribute("messageType", "error");
            }

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("message", "❌ Error: " + e.getMessage());
            session.setAttribute("messageType", "error");
        }

        response.sendRedirect("manageproduct");
    }
}
