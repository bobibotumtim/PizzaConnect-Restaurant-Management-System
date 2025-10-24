package controller;

import dao.InventoryDAO;
import models.Inventory;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/manageinventory")
public class InventoryServlet extends HttpServlet {
    InventoryDAO dao = new InventoryDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) action = "list";

        switch (action) {
            case "add":
                request.getRequestDispatcher("view/inventory-form.jsp").forward(request, response);
                break;
            case "edit":
                int id = Integer.parseInt(request.getParameter("id"));
                Inventory editItem = dao.getAll().stream()
                        .filter(i -> i.getInventoryID() == id)
                        .findFirst().orElse(null);
                request.setAttribute("inventory", editItem);
                request.getRequestDispatcher("view/inventory-form.jsp").forward(request, response);
                break;
            case "toggle":
                dao.toggleStatus(Integer.parseInt(request.getParameter("id")));
                response.sendRedirect("manageinventory");
                break;
            default:
                List<Inventory> list = dao.getAll();
                request.setAttribute("inventoryList", list);
                request.getRequestDispatcher("view/inventory-list.jsp").forward(request, response);
                break;
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String id = request.getParameter("id");
        String name = request.getParameter("itemName");
        double qty = Double.parseDouble(request.getParameter("quantity"));
        String unit = request.getParameter("unit");

        Inventory i = new Inventory();
        i.setItemName(name);
        i.setQuantity(qty);
        i.setUnit(unit);

        if (id == null || id.isEmpty()) {
            dao.insert(i);
        } else {
            i.setInventoryID(Integer.parseInt(id));
            dao.update(i);
        }
        response.sendRedirect("manageinventory");
    }
}

