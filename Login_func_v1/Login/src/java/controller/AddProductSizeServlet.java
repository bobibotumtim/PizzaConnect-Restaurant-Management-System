package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import models.ProductIngredient;
import models.ProductSize;
import services.ProductService;
import services.ValidationService;
import services.ValidationService.ValidationResult;

@WebServlet(name = "AddProductSizeServlet", urlPatterns = {"/AddProductSizeServlet"})
public class AddProductSizeServlet extends HttpServlet {

    private ProductService productService;
    private ValidationService validationService;

    @Override
    public void init() throws ServletException {
        productService = new ProductService();
        validationService = new ValidationService();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();

        try {
            // 1. Lấy thông tin Size
            int productId = Integer.parseInt(request.getParameter("productId"));
            String sizeCode = request.getParameter("sizeCode");
            double price = Double.parseDouble(request.getParameter("price"));

            // 2. Validate dữ liệu
            ValidationResult validationResult = validationService.validateAddProductSize(productId, sizeCode, price);
            
            if (!validationResult.isValid()) {
                session.setAttribute("message", validationResult.getErrorMessage());
                session.setAttribute("messageType", "error");
                response.sendRedirect(request.getContextPath() + "/manageproduct");
                return;
            }

            // 3. Tạo đối tượng ProductSize
            ProductSize newSize = new ProductSize(productId, sizeCode, price);

            // 4. Lấy danh sách Nguyên liệu (Tái sử dụng logic cũ)
            List<ProductIngredient> ingredients = parseIngredients(request);
            
            // 4.1. Validate từng ingredient và kiểm tra duplicate trong form
            java.util.Set<Integer> usedIngredients = new java.util.HashSet<>();
            
            for (ProductIngredient ingredient : ingredients) {
                // Kiểm tra duplicate trong cùng form
                if (usedIngredients.contains(ingredient.getInventoryId())) {
                    session.setAttribute("message", "Duplicate ingredient in the same form. Each ingredient can only be added once.");
                    session.setAttribute("messageType", "error");
                    response.sendRedirect(request.getContextPath() + "/manageproduct");
                    return;
                }
                usedIngredients.add(ingredient.getInventoryId());
                
                // Validate ingredient cơ bản
                ValidationResult ingredientValidation = validationService.validateIngredientForNewProductSize(
                    ingredient.getInventoryId(), ingredient.getQuantityNeeded());
                
                if (!ingredientValidation.isValid()) {
                    session.setAttribute("message", ingredientValidation.getErrorMessage());
                    session.setAttribute("messageType", "error");
                    response.sendRedirect(request.getContextPath() + "/manageproduct");
                    return;
                }
            }

            // 5. Gọi Service (để thực hiện Transaction)
            System.out.println("DEBUG: About to add size with " + ingredients.size() + " ingredients");
            for (ProductIngredient ing : ingredients) {
                System.out.println("DEBUG: Ingredient ID=" + ing.getInventoryId() + ", Qty=" + ing.getQuantityNeeded());
            }
            
            boolean result = productService.addSizeWithIngredients(newSize, ingredients);

            if (result) {
                session.setAttribute("message", "New size added successfully!");
                session.setAttribute("messageType", "success");
            } else {
                session.setAttribute("message", "Error adding new size.");
                session.setAttribute("messageType", "error");
            }

        } catch (NumberFormatException e) {
            e.printStackTrace();
            session.setAttribute("message", "Error: Invalid input format.");
            session.setAttribute("messageType", "error");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("message", "An error occurred: " + e.getMessage());
            session.setAttribute("messageType", "error");
        }

        // 5. Quay lại trang quản lý chính
        response.sendRedirect(request.getContextPath() + "/manageproduct");
    }

    /**
     * Hàm helper để đọc mảng nguyên liệu từ form
     * (Tái sử dụng logic từ EditProductFullServlet cũ)
     */
    private List<ProductIngredient> parseIngredients(HttpServletRequest request) {
        List<ProductIngredient> list = new ArrayList<>();
        String[] inventoryIds = request.getParameterValues("ingredientId[]");
        String[] quantities = request.getParameterValues("ingredientQty[]");
        String[] units = request.getParameterValues("ingredientUnit[]");

        if (inventoryIds == null || quantities == null || units == null) {
            return list; // Không có nguyên liệu nào được thêm
        }

        for (int i = 0; i < inventoryIds.length; i++) {
            try {
                int invId = Integer.parseInt(inventoryIds[i]);
                double qty = Double.parseDouble(quantities[i]);
                String unit = units[i];

                if (qty > 0) {
                    // productSizeId sẽ được set bên trong Service
                    ProductIngredient pi = new ProductIngredient(0, invId, qty, unit);
                    list.add(pi);
                }
            } catch (NumberFormatException e) {
                System.err.println("Bỏ qua nguyên liệu không hợp lệ: " + e.getMessage());
            }
        }
        return list;
    }
}