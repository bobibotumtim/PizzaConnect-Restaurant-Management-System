package controller;

import dao.DBContext;
import dao.ProductSizeDAO;
import dao.ProductIngredientDAO;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import models.ProductIngredient;
import models.ProductSize;

@WebServlet(name = "EditProductSizeServlet", urlPatterns = {"/EditProductSizeServlet"})
public class EditProductSizeServlet extends HttpServlet {

    private ProductSizeDAO productSizeDAO;
    private ProductIngredientDAO ingredientDAO;
    private DBContext dbContext;

    @Override
    public void init() throws ServletException {
        productSizeDAO = new ProductSizeDAO();
        ingredientDAO = new ProductIngredientDAO();
        dbContext = new DBContext();
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

            // 2. Validate - kiểm tra size tồn tại
            ProductSize existing = productSizeDAO.getProductSizeById(productSizeId);
            if (existing == null) {
                session.setAttribute("message", "Size not found");
                session.setAttribute("messageType", "error");
                response.sendRedirect(request.getContextPath() + "/manageproduct");
                return;
            }
            
            // Lấy productId từ ProductSize hiện tại
            int productId = existing.getProductId();
            
            // Kiểm tra size trùng (trừ chính nó) - chỉ kiểm tra nếu sizeCode thay đổi
            if (!sizeCode.equals(existing.getSizeCode())) {
                if (productSizeDAO.isSizeExistsForProduct(productId, sizeCode, productSizeId)) {
                    session.setAttribute("message", "Size '" + sizeCode + "' is already exit in the product");
                    session.setAttribute("messageType", "error");
                    response.sendRedirect(request.getContextPath() + "/manageproduct");
                    return;
                }
            }
            
            if (price < 0) {
                session.setAttribute("message", "Size price cannot be negative");
                session.setAttribute("messageType", "error");
                response.sendRedirect(request.getContextPath() + "/manageproduct");
                return;
            }

            // 3. Tạo đối tượng ProductSize
            ProductSize sizeToUpdate = new ProductSize();
            sizeToUpdate.setProductSizeId(productSizeId);
            sizeToUpdate.setSizeCode(sizeCode);
            sizeToUpdate.setPrice(price);

            // 4. Lấy danh sách Nguyên liệu MỚI
            List<ProductIngredient> newIngredients = parseIngredients(request);
            
            // 4.1. Validate từng ingredient mới và kiểm tra duplicate trong form
            java.util.Set<Integer> usedIngredients = new java.util.HashSet<>();
            
            for (ProductIngredient ingredient : newIngredients) {
                // Kiểm tra duplicate trong cùng form
                if (usedIngredients.contains(ingredient.getInventoryId())) {
                    session.setAttribute("message", "Duplicate ingredient in the same form. Each ingredient can only be added once.");
                    session.setAttribute("messageType", "error");
                    response.sendRedirect(request.getContextPath() + "/manageproduct");
                    return;
                }
                usedIngredients.add(ingredient.getInventoryId());
                
                if (!ingredientDAO.isInventoryExists(ingredient.getInventoryId())) {
                    session.setAttribute("message", "Ingredient not found");
                    session.setAttribute("messageType", "error");
                    response.sendRedirect(request.getContextPath() + "/manageproduct");
                    return;
                }
                
                if (ingredient.getQuantityNeeded() <= 0) {
                    session.setAttribute("message", "Ingredient quantity must be greater than 0");
                    session.setAttribute("messageType", "error");
                    response.sendRedirect(request.getContextPath() + "/manageproduct");
                    return;
                }
            }

            // 5. Thực hiện Transaction
            boolean result = updateSizeWithIngredients(sizeToUpdate, newIngredients);

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
    
    private boolean updateSizeWithIngredients(ProductSize size, List<ProductIngredient> newIngredients) {
        Connection con = null;
        try {
            con = dbContext.getConnection();
            con.setAutoCommit(false);

            // 1. Cập nhật thông tin ProductSize
            productSizeDAO.updateProductSize(size, con);

            // 2. Xử lý công thức
            int productSizeId = size.getProductSizeId();
            List<ProductIngredient> oldIngredients = ingredientDAO.getIngredientsByProductSizeId(productSizeId);
            Set<Integer> newInventoryIds = new HashSet<>();

            if (newIngredients != null) {
                for (ProductIngredient pi : newIngredients) {
                    newInventoryIds.add(pi.getInventoryId());
                    pi.setProductSizeId(productSizeId);

                    boolean exists = oldIngredients.stream()
                                    .anyMatch(old -> old.getInventoryId() == pi.getInventoryId());
                    
                    if (exists) {
                        ingredientDAO.updateIngredient(pi, con);
                    } else {
                        ingredientDAO.addIngredient(pi, con);
                    }
                }
            }
            
            // 3. Xóa các công thức cũ không còn trong list mới
            for (ProductIngredient oldPi : oldIngredients) {
                if (!newInventoryIds.contains(oldPi.getInventoryId())) {
                    ingredientDAO.deleteIngredient(productSizeId, oldPi.getInventoryId(), con);
                }
            }

            con.commit();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            try {
                if (con != null) con.rollback();
            } catch (SQLException e2) {
                e2.printStackTrace();
            }
            return false;
        } finally {
            try {
                if (con != null) {
                    con.setAutoCommit(true);
                    con.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}