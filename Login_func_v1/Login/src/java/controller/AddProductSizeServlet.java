package controller;

import dao.DBContext;
import dao.ProductDAO;
import dao.ProductSizeDAO;
import dao.ProductIngredientDAO;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import models.Product;
import models.ProductIngredient;
import models.ProductSize;

@WebServlet(name = "AddProductSizeServlet", urlPatterns = {"/AddProductSizeServlet"})
public class AddProductSizeServlet extends HttpServlet {

    private ProductDAO productDAO;
    private ProductSizeDAO productSizeDAO;
    private ProductIngredientDAO ingredientDAO;
    private DBContext dbContext;

    @Override
    public void init() throws ServletException {
        productDAO = new ProductDAO();
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
            int productId = Integer.parseInt(request.getParameter("productId"));
            String sizeCode = request.getParameter("sizeCode");
            double price = Double.parseDouble(request.getParameter("price"));

            // 2. Validate - kiểm tra product tồn tại
            Product product = productDAO.getProductById(productId);
            if (product == null) {
                session.setAttribute("message", "Product not found");
                session.setAttribute("messageType", "error");
                response.sendRedirect(request.getContextPath() + "/manageproduct");
                return;
            }
            
            // Kiểm tra size trùng
            if (productSizeDAO.isSizeExistsForProduct(productId, sizeCode, null)) {
                session.setAttribute("message", "Size '" + sizeCode + "' is already exit in the product");
                session.setAttribute("messageType", "error");
                response.sendRedirect(request.getContextPath() + "/manageproduct");
                return;
            }
            
            if (price < 0) {
                session.setAttribute("message", "Size price cannot be negative");
                session.setAttribute("messageType", "error");
                response.sendRedirect(request.getContextPath() + "/manageproduct");
                return;
            }

            // 3. Tạo đối tượng ProductSize
            ProductSize newSize = new ProductSize(productId, sizeCode, price);

            // 4. Lấy danh sách Nguyên liệu
            List<ProductIngredient> ingredients = parseIngredients(request);
            
            // 4.1. Validate từng ingredient
            java.util.Set<Integer> usedIngredients = new java.util.HashSet<>();
            
            for (ProductIngredient ingredient : ingredients) {
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
            boolean result = addSizeWithIngredients(newSize, ingredients);

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
    
    private boolean addSizeWithIngredients(ProductSize size, List<ProductIngredient> ingredients) {
        Connection con = null;
        try {
            con = dbContext.getConnection();
            con.setAutoCommit(false);

            int newProductSizeId = productSizeDAO.addProductSize(size, con);
            if (newProductSizeId == -1) {
                throw new SQLException("Không thể tạo ProductSize, không lấy được ID.");
            }

            if (ingredients != null) {
                for (ProductIngredient pi : ingredients) {
                    pi.setProductSizeId(newProductSizeId);
                    ingredientDAO.addIngredient(pi, con);
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