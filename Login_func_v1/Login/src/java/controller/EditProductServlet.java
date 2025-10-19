package controller;

import dao.ProductDAO;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import models.Product;

@WebServlet("/EditProductServlet")
public class EditProductServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        try {
            int id = Integer.parseInt(request.getParameter("productId"));
            String name = request.getParameter("productName");
            String desc = request.getParameter("description");
            double price = Double.parseDouble(request.getParameter("price"));
            String category = request.getParameter("category");
            String image = request.getParameter("imageUrl");
            boolean isAvailable = Boolean.parseBoolean(request.getParameter("isAvailable"));

            Product updated = new Product(id, name, desc, price, category, image, isAvailable);

            ProductDAO dao = new ProductDAO();
            boolean success = dao.updateProduct(updated);

            HttpSession session = request.getSession();

            if (success) {
                // 🔥 Ghi thông báo thành công
                session.setAttribute("message", "✅ Product updated successfully!");
                response.sendRedirect(request.getContextPath() + "/manageproduct");
            } else {
                session.setAttribute("message", "❌ Failed to update product!");
                response.sendRedirect(request.getContextPath() + "/manageproduct");
            }

        } catch (Exception e) {
            e.printStackTrace();
            HttpSession session = request.getSession();
            session.setAttribute("message", "⚠️ Error: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/manageproduct");
        }
    }
}
