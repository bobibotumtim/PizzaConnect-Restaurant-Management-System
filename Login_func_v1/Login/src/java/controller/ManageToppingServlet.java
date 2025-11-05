package controller;

import dao.ToppingDAO;
import models.Topping;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

public class ManageToppingServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        ToppingDAO dao = new ToppingDAO();
        
        if ("delete".equals(action)) {
            // Delete topping
            int toppingID = Integer.parseInt(request.getParameter("id"));
            dao.deleteTopping(toppingID);
            response.sendRedirect("manage-topping");
            return;
        }
        
        if ("toggle".equals(action)) {
            // Toggle availability
            int toppingID = Integer.parseInt(request.getParameter("id"));
            dao.toggleAvailability(toppingID);
            response.sendRedirect("manage-topping");
            return;
        }
        
        // Get all toppings
        List<Topping> toppings = dao.getAllToppings();
        request.setAttribute("toppings", toppings);
        request.getRequestDispatcher("view/ManageTopping.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        ToppingDAO dao = new ToppingDAO();
        
        if ("add".equals(action)) {
            // Add new topping
            String toppingName = request.getParameter("toppingName");
            double price = Double.parseDouble(request.getParameter("price"));
            
            dao.addTopping(toppingName, price);
            response.sendRedirect("manage-topping");
            return;
        }
        
        if ("update".equals(action)) {
            // Update topping
            int toppingID = Integer.parseInt(request.getParameter("toppingID"));
            String toppingName = request.getParameter("toppingName");
            double price = Double.parseDouble(request.getParameter("price"));
            boolean isAvailable = "1".equals(request.getParameter("isAvailable"));
            
            dao.updateTopping(toppingID, toppingName, price, isAvailable);
            response.sendRedirect("manage-topping");
            return;
        }
        
        response.sendRedirect("manage-topping");
    }
}
