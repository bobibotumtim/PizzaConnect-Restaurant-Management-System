package controllers;

import dao.ProductIngredientDAO;
import models.ProductIngredient;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;

@WebServlet("/manageingredients")
public class ManageIngredientsServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        String productIdParam = request.getParameter("productId");
        String msg = "";
        System.out.println("Check1");
        try {
            int productId = Integer.parseInt(productIdParam);
            ProductIngredientDAO dao = new ProductIngredientDAO();
            System.out.println("Check2");
            switch (action) {
                case "add":
                    int addInventoryId = Integer.parseInt(request.getParameter("inventoryId"));
                    double addQuantity = Double.parseDouble(request.getParameter("quantity"));
                    String addUnit = request.getParameter("unit");
                    boolean addSuccess = dao.addIngredientToProduct(productId, addInventoryId, addQuantity, addUnit);
                    msg = addSuccess ? "Ingredient added successfully!" : "Ingredient already exists!";
                    break;

                case "update":
                    String[] inventoryIds = request.getParameterValues("inventoryId[]");
                    String[] quantities = request.getParameterValues("quantity[]");
                    String[] units = request.getParameterValues("unit[]");
                    System.out.println("Check4");
                    if (inventoryIds != null) {
                        for (int i = 0; i < inventoryIds.length; i++) {
                            int invId = Integer.parseInt(inventoryIds[i]);
                            double qty = Double.parseDouble(quantities[i]);
                            String unit = units[i];

                            ProductIngredient pi = new ProductIngredient();
                            pi.setProductId(productId);
                            pi.setInventoryId(invId);
                            pi.setQuantityNeeded(qty);
                            pi.setUnit(unit);

                            dao.updateIngredient(pi);
                        }
                    }
                    msg = "Ingredients updated successfully!";
                    break;

                case "delete":
                    int delInventoryId = Integer.parseInt(request.getParameter("inventoryId"));
                    System.out.println(productId);
                    System.out.println(delInventoryId);
                    boolean delSuccess = dao.deleteIngredientFromProduct(productId, delInventoryId);
                    msg = delSuccess ? "Ingredient deleted successfully!" : "Failed to delete ingredient!";
                    break;

                default:
                    msg = "Invalid action!";
            }

        } catch (Exception e) {
            e.printStackTrace();
            msg = "Error: " + e.getMessage();
        }

        request.getSession().setAttribute("message", msg);
        response.sendRedirect("manageproduct");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String productIdParam = request.getParameter("productId");
        if (productIdParam == null || productIdParam.isBlank()) {
            request.getSession().setAttribute("error", "Missing product ID");
            response.sendRedirect("manageproduct");
            return;
        }

        try {
            int productId = Integer.parseInt(productIdParam);
            ProductIngredientDAO dao = new ProductIngredientDAO();
            request.setAttribute("ingredients", dao.getIngredientsByProduct(productId));
            request.setAttribute("productId", productId);
        } catch (Exception e) {
            request.getSession().setAttribute("error", "Error loading ingredients: " + e.getMessage());
        }

        RequestDispatcher dispatcher = request.getRequestDispatcher("/view/ManageIngredientsPopup.jsp");
        dispatcher.forward(request, response);
    }
}

