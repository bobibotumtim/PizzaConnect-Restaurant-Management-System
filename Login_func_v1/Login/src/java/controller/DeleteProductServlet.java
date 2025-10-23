package controller;

import dao.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet(name = "DeleteProductServlet", urlPatterns = {"/DeleteProduct"})
public class DeleteProductServlet extends HttpServlet {

    private ProductDAO productDAO;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        productDAO = new ProductDAO();
        HttpSession session = request.getSession();
        String productIdStr = request.getParameter("productId");

        String msg = "";
        String msgType = "error"; // mặc định là lỗi

        try {
            if (productIdStr == null || productIdStr.isEmpty()) {
                msg = "Missing product ID.";
            } else {
                int productId = Integer.parseInt(productIdStr);
                boolean deleted = productDAO.deleteProduct(productId);
                if (deleted) {
                    msg = "Product deleted successfully!";
                    msgType = "success";
                } else {
                    msg = "Product not found or could not be deleted.";
                }
            }
        } catch (NumberFormatException e) {
            msg = "Invalid product ID format.";
        } catch (Exception e) {
            e.printStackTrace();
            msg = "Error deleting product: " + e.getMessage();
        }

        session.setAttribute("message", msg);
        session.setAttribute("messageType", msgType);
        response.sendRedirect(request.getContextPath() + "/manageproduct");
    }
}
