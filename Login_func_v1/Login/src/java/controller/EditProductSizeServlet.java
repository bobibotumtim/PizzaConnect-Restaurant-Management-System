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

@WebServlet(name = "EditProductSizeServlet", urlPatterns = {"/EditProductSizeServlet"})
public class EditProductSizeServlet extends HttpServlet {

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
            int productSizeId = Integer.parseInt(request.getParameter("productSizeId"));
            String sizeCode = request.getParameter("sizeCode");
            double price = Double.parseDouble(request.getParameter("price"));
            
            // Lấy productId để validate (có thể từ hidden field hoặc query từ DB)
            String productIdStr = request.getParameter("productId");
            int productId = 0;
            if (productIdStr != null && !productIdStr.isEmpty()) {
                productId = Integer.parseInt(productIdStr);
            }

            // 2. Validate dữ liệu
            ValidationResult validationResult = validationService.validateEditProductSize(productSizeId, productId, sizeCode, price);
            
            if (!validationResult.isValid()) {
                session.setAttribute("message", validationResult.getErrorMessage());
                session.setAttribute("messageType", "error");
                response.sendRedirect(request.getContextPath() + "/manageproduct");
                return;
            }

            // 3. Tạo đối tượng ProductSize
            ProductSize sizeToUpdate = new ProductSize();
            sizeToUpdate.setProductSizeId(productSizeId);
            sizeToUpdate.setSizeCode(sizeCode);
            sizeToUpdate.setPrice(price);

            // 4. Lấy danh sách Nguyên liệu MỚI (Tái sử dụng logic cũ)
            List<ProductIngredient> newIngredients = parseIngredients(request);
            
            // 4.1. Validate từng ingredient mới
            for (ProductIngredient ingredient : newIngredients) {
                ValidationResult ingredientValidation = validationService.validateAddProductIngredient(
                    productSizeId, ingredient.getInventoryId(), ingredient.getQuantityNeeded());
                
                if (!ingredientValidation.isValid()) {
                    session.setAttribute("message", ingredientValidation.getErrorMessage());
                    session.setAttribute("messageType", "error");
                    response.sendRedirect(request.getContextPath() + "/manageproduct");
                    return;
                }
            }

            // 5. Gọi Service (để thực hiện Transaction Add/Update/Delete)
            boolean result = productService.updateSizeWithIngredients(sizeToUpdate, newIngredients);

            if (result) {
                session.setAttribute("message", "Size updated successfully!");
                session.setAttribute("messageType", "success");
            } else {
                session.setAttribute("message", "Error updating size.");
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
        
        // Form Edit dùng tên: "inventoryId[]", "quantity[]", "unit[]"
        String[] inventoryIds = request.getParameterValues("inventoryId[]");
        String[] quantities = request.getParameterValues("quantity[]");
        String[] units = request.getParameterValues("unit[]");

        if (inventoryIds == null || quantities == null || units == null) {
            return list; // Không có nguyên liệu nào được gửi
        }

        for (int i = 0; i < inventoryIds.length; i++) {
            try {
                int invId = Integer.parseInt(inventoryIds[i]);
                double qty = Double.parseDouble(quantities[i]);
                String unit = units[i];

                if (qty > 0) {
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