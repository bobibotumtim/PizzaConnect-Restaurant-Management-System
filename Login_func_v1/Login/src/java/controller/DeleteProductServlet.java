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
    public void init() throws ServletException {
        productDAO = new ProductDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String productIdStr = request.getParameter("productId");
        if (productIdStr != null && !productIdStr.isEmpty()) {
            try {
                int productId = Integer.parseInt(productIdStr);
                boolean deleted = productDAO.deleteProduct(productId);

                if (deleted) {
                    request.getSession().setAttribute("message", "Product deleted successfully!");
                } else {
                    request.getSession().setAttribute("message", "Product not found or could not be deleted.");
                }

            } catch (NumberFormatException e) {
                request.getSession().setAttribute("message", "Invalid product ID.");
            }
        }
        response.sendRedirect(request.getContextPath() + "/manageproduct");
    }

}