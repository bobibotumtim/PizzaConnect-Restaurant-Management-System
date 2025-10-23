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
        String msgType = "error"; // mặc định là lỗi
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

                    // 🛑 Kiểm tra số lượng âm
                    if (addQuantity <= 0) {
                        msg = "⚠️ Quantity must be greater than 0!";
                        msgType = "error";
                        break;
                    }

                    boolean addSuccess = dao.addIngredientToProduct(productId, addInventoryId, addQuantity, addUnit);
                    if (addSuccess) {
                        msg = "✅ Ingredient added successfully!";
                        msgType = "success";
                    } else {
                        msg = "⚠️ Ingredient already exists!";
                        msgType = "error";
                    }
                    break;

                case "update":
                    String[] inventoryIds = request.getParameterValues("inventoryId[]");
                    String[] quantities = request.getParameterValues("quantity[]");
                    String[] units = request.getParameterValues("unit[]");
                    System.out.println("Check4");

                    if (inventoryIds != null) {
                        boolean hasInvalid = false;

                        for (int i = 0; i < inventoryIds.length; i++) {
                            int invId = Integer.parseInt(inventoryIds[i]);
                            double qty = Double.parseDouble(quantities[i]);
                            String unit = units[i];

                            // 🛑 Kiểm tra số lượng âm
                            if (qty <= 0) {
                                hasInvalid = true;
                                continue; // bỏ qua ingredient không hợp lệ
                            }

                            ProductIngredient pi = new ProductIngredient();
                            pi.setProductId(productId);
                            pi.setInventoryId(invId);
                            pi.setQuantityNeeded(qty);
                            pi.setUnit(unit);

                            dao.updateIngredient(pi);
                        }

                        if (hasInvalid) {
                            msg = "⚠️ Some ingredients were not updated because quantity must be > 0!";
                            msgType = "error";
                        } else {
                            msg = "✅ Ingredients updated successfully!";
                            msgType = "success";
                        }
                    }
                    break;

                case "delete":
                    int delInventoryId = Integer.parseInt(request.getParameter("inventoryId"));
                    boolean delSuccess = dao.deleteIngredientFromProduct(productId, delInventoryId);
                    if (delSuccess) {
                        msg = "🗑️ Ingredient deleted successfully!";
                        msgType = "success";
                    } else {
                        msg = "❌ Failed to delete ingredient!";
                        msgType = "error";
                    }
                    break;

                default:
                    msg = "⚠️ Invalid action!";
                    msgType = "error";
            }

        } catch (Exception e) {
            e.printStackTrace();
            msg = "❌ Error: " + e.getMessage();
            msgType = "error";
        }

        HttpSession session = request.getSession();
        session.setAttribute("message", msg);
        session.setAttribute("messageType", msgType);
        response.sendRedirect("manageproduct");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String productIdParam = request.getParameter("productId");
        HttpSession session = request.getSession();

        if (productIdParam == null || productIdParam.isBlank()) {
            session.setAttribute("message", "⚠️ Missing product ID!");
            session.setAttribute("messageType", "error");
            response.sendRedirect("manageproduct");
            return;
        }

        try {
            int productId = Integer.parseInt(productIdParam);
            ProductIngredientDAO dao = new ProductIngredientDAO();
            request.setAttribute("ingredients", dao.getIngredientsByProduct(productId));
            request.setAttribute("productId", productId);
        } catch (Exception e) {
            session.setAttribute("message", "❌ Error loading ingredients: " + e.getMessage());
            session.setAttribute("messageType", "error");
            response.sendRedirect("manageproduct");
            return;
        }

        RequestDispatcher dispatcher = request.getRequestDispatcher("/view/ManageIngredientsPopup.jsp");
        dispatcher.forward(request, response);
    }
}
