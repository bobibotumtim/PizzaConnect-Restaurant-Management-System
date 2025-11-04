package controllers;

import dao.ProductSizeDAO;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet(name = "DeleteProductSizeServlet", urlPatterns = {"/DeleteProductSize"})
public class DeleteProductSizeServlet extends HttpServlet {

    private final ProductSizeDAO dao = new ProductSizeDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String sizeIdStr = request.getParameter("sizeId");
        String productIdStr = request.getParameter("productId");

        String message;
        String messageType = "error"; // mặc định là lỗi

        try {
            if (sizeIdStr == null || sizeIdStr.isEmpty() || productIdStr == null || productIdStr.isEmpty()) {
                message = "Missing size or product ID.";
            } else {
                int sizeId = Integer.parseInt(sizeIdStr);

                boolean deleted = dao.deleteProductSizeByProductId(sizeId);

                if (deleted) {
                    message = "Product size deleted successfully!";
                    messageType = "success";
                } else {
                    message = "Product size not found or could not be deleted.";
                }
            }
        } catch (NumberFormatException e) {
            message = "Invalid parameter format.";
        } catch (Exception e) {
            e.printStackTrace();
            message = "Error deleting product size: " + e.getMessage();
        }

        // Gửi thông báo qua session (để hiển thị sau redirect)
        session.setAttribute("message", message);
        session.setAttribute("messageType", messageType);

        // Điều hướng về trang manageproduct
        response.sendRedirect(request.getContextPath() + "/manageproduct");
    }
}
