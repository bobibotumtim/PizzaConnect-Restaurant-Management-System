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

        HttpSession session = request.getSession();

        try {
            int id = Integer.parseInt(request.getParameter("productId"));
            String name = request.getParameter("productName");
            String desc = request.getParameter("description");
            String category = request.getParameter("category");
            String image = request.getParameter("imageUrl");
            boolean isAvailable = true;

            // === Kiểm tra giá không âm hoặc sai định dạng ===
            double price;
            try {
                price = Double.parseDouble(request.getParameter("price"));
                if (price < 0) {
                    session.setAttribute("message", "⚠️ Price cannot be negative!");
                    session.setAttribute("messageType", "error");
                    response.sendRedirect(request.getContextPath() + "/manageproduct");
                    return;
                }
            } catch (NumberFormatException ex) {
                session.setAttribute("message", "⚠️ Invalid price format!");
                session.setAttribute("messageType", "error");
                response.sendRedirect(request.getContextPath() + "/manageproduct");
                return;
            }

            Product updated = new Product(id, name, desc, price, category, image, isAvailable);

            ProductDAO dao = new ProductDAO();
            boolean success = dao.updateProduct(updated);

            if (success) {
                session.setAttribute("message", "✅ Product updated successfully!");
                session.setAttribute("messageType", "success");
            } else {
                session.setAttribute("message", "❌ Failed to update product!");
                session.setAttribute("messageType", "error");
            }

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("message", "❌ Error: " + e.getMessage());
            session.setAttribute("messageType", "error");
        }

        response.sendRedirect(request.getContextPath() + "/manageproduct");
    }
}
