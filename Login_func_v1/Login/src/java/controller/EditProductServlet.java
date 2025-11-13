package controller;

import dao.CategoryDAO;
import dao.ProductDAO;
import dao.DBContext;
import models.Product;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import java.nio.file.Paths; // Cần import này

// ✅ THAY ĐỔI 1: Thêm annotation @MultipartConfig
@WebServlet(name = "EditProductServlet", urlPatterns = {"/EditProductServlet"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, // 2MB
    maxFileSize = 1024 * 1024 * 10,      // 10MB
    maxRequestSize = 1024 * 1024 * 50    // 50MB
)
public class EditProductServlet extends HttpServlet {

    private ProductDAO productDAO = new ProductDAO();
    private CategoryDAO categoryDAO = new CategoryDAO();
    private DBContext dbContext = new DBContext();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Lấy dữ liệu từ form
        int productId = Integer.parseInt(request.getParameter("productId"));
        String productName = request.getParameter("productName");
        String description = request.getParameter("description");
        String categoryName = request.getParameter("categoryName");
        String existingImageUrl = request.getParameter("existingImageUrl"); // Lấy URL ảnh cũ
        
        String imageUrl = existingImageUrl; // Mặc định giữ URL ảnh cũ

        // ✅ THAY ĐỔI 2: Xử lý file tải lên mới
        Part filePart = request.getPart("newProductImage"); // Tên input: newProductImage
        
        if (filePart != null && filePart.getSize() > 0) {
            String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
            String uploadPath = getServletContext().getRealPath("") + "images/products"; // Ví dụ: Lưu vào /images/products/
            java.io.File uploadDir = new java.io.File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }
            
            // Đảm bảo tên file là duy nhất, ví dụ thêm timestamp
            String uniqueFileName = System.currentTimeMillis() + "_" + fileName;
            filePart.write(uploadPath + java.io.File.separator + uniqueFileName);
            
            // Cập nhật imageUrl với đường dẫn tương đối mới
            imageUrl = request.getContextPath() + "/images/products/" + uniqueFileName;
        }
        // Nếu filePart.getSize() == 0, imageUrl vẫn giữ giá trị existingImageUrl.


        boolean isAvailable = true;

        HttpSession session = request.getSession();
        
        // 2. Validate - kiểm tra product tồn tại
        Product existing = productDAO.getProductById(productId);
        if (existing == null) {
            session.setAttribute("message", "Product not found");
            session.setAttribute("messageType", "error");
            response.sendRedirect(request.getContextPath() + "/manageproduct");
            return;
        }
        
        // Kiểm tra tên trùng (trừ chính nó)
        try {
            if (productDAO.isProductNameExists(productName, productId)) {
                session.setAttribute("message", "Product name already exists");
                session.setAttribute("messageType", "error");
                response.sendRedirect(request.getContextPath() + "/manageproduct");
                return;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        // 3. Tạo đối tượng Product
        Product product = new Product();
        product.setProductId(productId);
        product.setProductName(productName);
        product.setDescription(description);
        product.setCategoryName(categoryName);
        product.setImageUrl(imageUrl); // Sử dụng URL mới/cũ
        product.setAvailable(isAvailable);

        // 4. Cập nhật Product với Transaction
        boolean result = updateBaseProduct(product);
        
        // 5. Đặt thông báo và Redirect
        if (result) {
            session.setAttribute("message", "Product updated successfully!");
            session.setAttribute("messageType", "success");
        } else {
            session.setAttribute("message", "Error updating product.");
            session.setAttribute("messageType", "error");
        }
        
        response.sendRedirect(request.getContextPath() + "/manageproduct");
    }
    
    // ... Giữ nguyên method updateBaseProduct ...
    private boolean updateBaseProduct(Product product) {
        Connection con = null;
        try {
            con = dbContext.getConnection();
            con.setAutoCommit(false);

            int categoryId = categoryDAO.getCategoryIdByName(product.getCategoryName(), con);
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
}