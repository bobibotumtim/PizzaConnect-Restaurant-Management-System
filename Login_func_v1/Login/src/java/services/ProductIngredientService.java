package services;

import dao.ProductIngredientDAO;
import models.ProductIngredient;
import dao.DBContext;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

public class ProductIngredientService extends DBContext {

    private ProductIngredientDAO ingredientDAO;

    public ProductIngredientService() {
        ingredientDAO = new ProductIngredientDAO();
    }

    // ==============================================================
    // NGHIỆP VỤ LẤY DỮ LIỆU
    // ==============================================================

    /**
     * Lấy danh sách nguyên liệu trong kho (cho dropdown)
     */
    public List<Map<String, Object>> getAllInventories() {
        return ingredientDAO.getAllInventories();
    }

    /**
     * Lấy công thức (thành phần) chi tiết cho 1 size
     */
    public List<ProductIngredient> getIngredientsForSize(int productSizeId) {
        return ingredientDAO.getIngredientsByProductSizeId(productSizeId);
    }

    // ==============================================================
    // NGHIỆP VỤ THAY ĐỔI DỮ LIỆU (TRANSACTION)
    // ==============================================================

    /**
     * Cập nhật TOÀN BỘ công thức cho 1 product size
     * (Xóa hết công thức cũ, thêm lại list công thức mới)
     * Đây là một TRANSACTION
     */
    public boolean updateAllIngredientsForSize(int productSizeId, List<ProductIngredient> newIngredients) {
        Connection con = null;
        try {
            con = getConnection(); // Lấy 1 connection
            con.setAutoCommit(false); // Bắt đầu Transaction

            // 1. Xóa tất cả công thức CŨ của size này
            ingredientDAO.deleteAllIngredientsByProductSizeId(productSizeId, con);

            // 2. Thêm lại các công thức MỚI
            for (ProductIngredient ingredient : newIngredients) {
                ingredient.setProductSizeId(productSizeId); // Đảm bảo đúng ID
                ingredientDAO.addIngredient(ingredient, con);
            }

            // 3. Nếu mọi thứ thành công
            con.commit();
            return true;

        } catch (SQLException e) {
            e.printStackTrace();
            // 4. Nếu có lỗi, rollback
            try {
                if (con != null) con.rollback();
            } catch (SQLException e2) {
                e2.printStackTrace();
            }
            return false;
        } finally {
            // 5. Luôn đóng connection
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