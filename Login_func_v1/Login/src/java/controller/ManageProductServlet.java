package controllers;

import dao.ProductDAO;
import models.Product;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "ManageProductServlet", urlPatterns = {"/manageproduct"})
public class ManageProductServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        ProductDAO dao = new ProductDAO();

        List<Product> products = dao.getAllProducts();

        request.setAttribute("products", products);

        RequestDispatcher dispatcher = request.getRequestDispatcher("/view/ManageProduct.jsp");
        dispatcher.forward(request, response);
        
    }
}
