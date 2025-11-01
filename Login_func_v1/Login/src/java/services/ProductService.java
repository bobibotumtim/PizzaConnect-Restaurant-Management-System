package services; // Nên tạo package mới là 'services'

import dao.CategoryDAO;
import dao.ProductDAO;
import dao.ProductSizeDAO;
import models.Product;
import models.ProductSize;
import dao.DBContext; // Cần để lấy Connection
import dao.ProductIngredientDAO;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import models.ProductIngredient;

public class ProductService extends DBContext{

    // Service sẽ khởi tạo và quản lý các DAO
    private ProductDAO productDAO;
    private ProductSizeDAO productSizeDAO;
    private CategoryDAO categoryDAO;

    public ProductService() {
        productDAO = new ProductDAO();
        productSizeDAO = new ProductSizeDAO();
        categoryDAO = new CategoryDAO();
    }

    // ==============================================================
    // NGHIỆP VỤ LẤY DỮ LIỆU (LẮP RÁP)
    // ==============================================================

    /**
     * Lấy 1 Product, bao gồm cả List<ProductSize> của nó
     */
    public Product getProductDetails(int productId) {
        // 1. Lấy thông tin Product cơ bản
        Product product = productDAO.getBaseProductById(productId);

        if (product != null) {
            // 2. Lấy danh sách Size
            List<ProductSize> sizes = productSizeDAO.getSizesByProductId(productId);
            // 3. Lắp ráp lại
            product.setSizes(sizes);
        }
        return product;
    }

    /**
     * Lấy TẤT CẢ Product, bao gồm cả List<ProductSize> của chúng
     */
    public List<Product> getAllProductsWithSizes() {
        // 1. Lấy danh sách Product cơ bản
        List<Product> products = productDAO.getAllBaseProducts();
        
        // 2. Lặp qua và "lắp" Size vào cho từng Product
        for (Product p : products) {
            List<ProductSize> sizes = productSizeDAO.getSizesByProductId(p.getProductId());
            p.setSizes(sizes);
        }
        return products;
    }

    /**
     * Lấy map số lượng có thể làm của từng size
     */
    public Map<Integer, Double> getProductSizeAvailabilityMap() {
        return productDAO.getProductSizeAvailabilityMap();
    }

    // ==============================================================
    // NGHIỆP VỤ THAY ĐỔI DỮ LIỆU (TRANSACTION)
    // ==============================================================

    /**
     * Thêm 1 Product MỚI bao gồm các Size của nó (Quản lý Transaction)
     */
    public boolean addProductWithSizes(Product product) {
        Connection con = null;
        try {
            // Lấy 1 Connection duy nhất
            con = getConnection();
            // Bắt đầu Transaction
            con.setAutoCommit(false);

            // 1. Lấy CategoryID
            int categoryId = categoryDAO.getCategoryIdByName(product.getCategoryName(), con);

            // 2. Thêm Product vào CSDL
            int newProductId = productDAO.addProduct(product, categoryId, con);

            // 3. Thêm các ProductSize
            if (product.getSizes() != null) {
                for (ProductSize size : product.getSizes()) {
                    size.setProductId(newProductId); // Gán ID mới
                    productSizeDAO.addProductSize(size, con);
                }
            }

            // Nếu mọi thứ thành công
            con.commit();
            return true;

        } catch (SQLException e) {
            e.printStackTrace();
            // Nếu có lỗi, rollback
            try {
                if (con != null) con.rollback();
            } catch (SQLException e2) {
                e2.printStackTrace();
            }
            return false;
        } finally {
            // Luôn đóng Connection và bật lại AutoCommit
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

    /**
     * Cập nhật 1 Product bao gồm các Size (Quản lý Transaction)
     */
    public boolean updateProductWithSizes(Product product) {
        Connection con = null;
        try {
            con = getConnection();
            con.setAutoCommit(false);

            // 1. Lấy CategoryID
            int categoryId = categoryDAO.getCategoryIdByName(product.getCategoryName(), con);

            // 2. Cập nhật thông tin Product
            productDAO.updateProduct(product, categoryId, con);

            // 3. Xóa tất cả Size cũ
            productSizeDAO.deleteSizesByProductId(product.getProductId(), con);

            // 4. Thêm lại các Size mới
            if (product.getSizes() != null) {
                for (ProductSize size : product.getSizes()) {
                    size.setProductId(product.getProductId());
                    productSizeDAO.addProductSize(size, con);
                }
            }
            
            con.commit();
            return true;

        } catch (SQLException e) {
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
    
    /**
     * Xóa (soft delete) một sản phẩm.
     * (Vì đây là 1 lệnh đơn giản, nó có thể gọi thẳng DAO)
     */
     public boolean deleteProduct(int productId) {
         return productDAO.deleteProduct(productId);
     }
     
     public boolean updateBaseProduct(Product product) {
        Connection con = null;
        try {
            con = getConnection();
            con.setAutoCommit(false);

            // 1. Lấy CategoryID
            int categoryId = categoryDAO.getCategoryIdByName(product.getCategoryName(), con);

            // 2. Cập nhật chỉ bảng Product
            productDAO.updateBaseProduct(product, categoryId, con);
            
            con.commit();
            return true;

        } catch (SQLException e) {
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
    
    /**
     * MỚI: Lấy tổng số sản phẩm (đã lọc)
     */
    public int getProductCount(String searchName, String statusFilter) {
        try {
            return productDAO.getBaseProductCount(searchName, statusFilter);
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }
    
    /**
     * MỚI: Lấy sản phẩm (đã lọc và phân trang)
     */
    public List<Product> getProductsPaginated(String searchName, String statusFilter, int page, int pageSize) {
        try {
            return productDAO.getBaseProductsPaginated(searchName, statusFilter, page, pageSize);
        } catch (SQLException e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }
    
    public boolean addSizeWithIngredients(ProductSize size, List<ProductIngredient> ingredients) {
        Connection con = null;
        try {
            con = getConnection();
            con.setAutoCommit(false);

            // 1. Thêm ProductSize và lấy newProductSizeId
            // (Giả sử addProductSize trong DAO trả về ID)
            int newProductSizeId = productSizeDAO.addProductSize(size, con);
            if (newProductSizeId == -1) {
                throw new SQLException("Không thể tạo ProductSize, không lấy được ID.");
            }

            // 2. Thêm các Ingredients
            if (ingredients != null) {
                // Chúng ta cần ProductIngredientDAO ở đây
                ProductIngredientDAO ingredientDAO = new ProductIngredientDAO();
                for (ProductIngredient pi : ingredients) {
                    pi.setProductSizeId(newProductSizeId); // Gán ID mới
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
            closeConnection(con); // Viết một hàm helper để đóng connection
        }
    }

    // ✅ HÀM MỚI 2: Cập nhật một Size (kèm công thức) - Đây là Transaction
    // Tái sử dụng logic so sánh Add/Update/Delete từ EditProductFullServlet cũ
    public boolean updateSizeWithIngredients(ProductSize size, List<ProductIngredient> newIngredients) {
        Connection con = null;
        try {
            con = getConnection();
            con.setAutoCommit(false);
            
            ProductIngredientDAO ingredientDAO = new ProductIngredientDAO();

            // 1. Cập nhật thông tin của ProductSize (Code, Price)
            // (Bạn cần viết hàm updateProductSize trong ProductSizeDAO)
            productSizeDAO.updateProductSize(size, con); // Ví dụ: updateProductSize(size, con)

            // 2. Xử lý công thức (y hệt logic cũ của bạn)
            int productSizeId = size.getProductSizeId();
            List<ProductIngredient> oldIngredients = ingredientDAO.getIngredientsByProductSizeId(productSizeId);
            Set<Integer> newInventoryIds = new HashSet<>();

            if (newIngredients != null) {
                for (ProductIngredient pi : newIngredients) {
                    newInventoryIds.add(pi.getInventoryId());
                    pi.setProductSizeId(productSizeId); // Đảm bảo đúng ID

                    // Kiểm tra xem là Add hay Update
                    boolean exists = oldIngredients.stream()
                                    .anyMatch(old -> old.getInventoryId() == pi.getInventoryId());
                    
                    if (exists) {
                        ingredientDAO.updateIngredient(pi, con); // (Cần hàm updateIngredient(pi, con))
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
            closeConnection(con);
        }
    }

}