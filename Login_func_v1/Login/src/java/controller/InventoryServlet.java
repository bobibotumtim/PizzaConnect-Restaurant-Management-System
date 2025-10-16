package controller;

import dao.InventoryDAO;
import models.Inventory;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/inventory")
public class InventoryServlet extends HttpServlet {
    private InventoryDAO dao = new InventoryDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) action = "list";

        switch (action) {
            case "new":
                request.getRequestDispatcher("inventory-form.jsp").forward(request, response);
                break;
            case "edit":
                int id = Integer.parseInt(request.getParameter("id"));
                Inventory inv = dao.getById(id);
                request.setAttribute("inventory", inv);
                request.getRequestDispatcher("inventory-form.jsp").forward(request, response);
                break;
            case "delete":
                dao.delete(Integer.parseInt(request.getParameter("id")));
                response.sendRedirect("inventory");
                break;
            default:
                List<Inventory> list = dao.getAll();
                request.setAttribute("list", list);
                request.getRequestDispatcher("inventory-list.jsp").forward(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String idStr = request.getParameter("id");
        String name = request.getParameter("name");
        double qty = Double.parseDouble(request.getParameter("quantity"));
        String unit = request.getParameter("unit");

        if (idStr == null || idStr.isEmpty()) {
            dao.insert(name, qty, unit);
        } else {
            dao.update(Integer.parseInt(idStr), name, qty, unit);
        }

        response.sendRedirect("inventory");
    }
}

