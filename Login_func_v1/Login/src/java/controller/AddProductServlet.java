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
@WebServlet(name = "AddProductServlet", urlPatterns = {"/AddProductServlet"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, // 2MB
    maxFileSize = 1024 * 1024 * 10,      // 10MB
    maxRequestSize = 1024 * 1024 * 50    // 50MB
)
public class AddProductServlet extends HttpServlet {

    private ProductDAO productDAO = new ProductDAO();
    private CategoryDAO categoryDAO = new CategoryDAO();
    private DBContext dbContext = new DBContext();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Lấy dữ liệu từ form
        String productName = request.getParameter("productName");
        String description = request.getParameter("description");
        String categoryName = request.getParameter("categoryName");
        // String imageUrl = request.getParameter("imageUrl"); // BỎ DÒNG NÀY

        // ✅ THAY ĐỔI 2: Xử lý file tải lên
        Part filePart = request.getPart("productImage"); // Tên input: productImage
        String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
        String imageUrl = ""; // Mặc định là chuỗi rỗng
        
        if (filePart != null && filePart.getSize() > 0) {
            String uploadPath = getServletContext().getRealPath("") + "images/products"; // Ví dụ: Lưu vào /images/products/
            java.io.File uploadDir = new java.io.File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }
            
            // Đảm bảo tên file là duy nhất, ví dụ thêm timestamp
            String uniqueFileName = System.currentTimeMillis() + "_" + fileName;
            filePart.write(uploadPath + java.io.File.separator + uniqueFileName);
            
            // Lưu đường dẫn tương đối để hiển thị (ví dụ: /PizzaConnect/images/products/ten_file_duy_nhat.jpg)
            imageUrl = request.getContextPath() + "/images/products/" + uniqueFileName;
        }


        boolean isAvailable = true;

        HttpSession session = request.getSession();
        
        // 2. Validate - kiểm tra tên trùng
        try {
            if (productDAO.isProductNameExists(productName, null)) {
                session.setAttribute("message", "Product name already exists");
                session.setAttribute("messageType", "error");
                response.sendRedirect(request.getContextPath() + "/manageproduct");
                return;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        // Kiểm tra category tồn tại
        if (categoryDAO.getCategoryByName(categoryName) == null) {
            session.setAttribute("message", "Invalid category");
            session.setAttribute("messageType", "error");
            response.sendRedirect(request.getContextPath() + "/manageproduct");
            return;
        }

        // 3. Tạo đối tượng Product
        Product product = new Product();
        product.setProductName(productName);
        product.setDescription(description);
        product.setCategoryName(categoryName);
        product.setImageUrl(imageUrl); // Sử dụng URL mới
        product.setAvailable(isAvailable);

        // 4. Thêm Product với Transaction
        boolean result = addProductWithSizes(product);
        
        // 5. Đặt thông báo và Redirect
        if (result) {
            session.setAttribute("message", "Product added successfully!");
            session.setAttribute("messageType", "success");
        } else {
            session.setAttribute("message", "Error adding product.");
            session.setAttribute("messageType", "error");
        }
        
        response.sendRedirect(request.getContextPath() + "/manageproduct");
    }
    
    // ... Giữ nguyên method addProductWithSizes ...
    private boolean addProductWithSizes(Product product) {
        Connection con = null;
        try {
            con = dbContext.getConnection();
            con.setAutoCommit(false);

            int categoryId = categoryDAO.getCategoryIdByName(product.getCategoryName(), con);
            productDAO.addProduct(product, categoryId, con);

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