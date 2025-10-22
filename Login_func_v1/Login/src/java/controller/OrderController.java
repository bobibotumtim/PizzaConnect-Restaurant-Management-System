package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.*;
import dao.OrderDAO;
import dao.OrderDetailDAO;
import models.*;

public class OrderController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        if (action == null) action = "list";

        switch (action) {
            case "detail":
                int id = Integer.parseInt(req.getParameter("id"));
                OrderDetailDAO detailDAO = new OrderDetailDAO();
                List<OrderDetail> details = detailDAO.getByOrderID(id);
                req.setAttribute("details", details);
                req.getRequestDispatcher("order-detail.jsp").forward(req, resp);
                break;
            default:
                OrderDAO dao = new OrderDAO();
                List<Order> orders = dao.getAll();
                req.setAttribute("orders", orders);
                req.getRequestDispatcher("order-list.jsp").forward(req, resp);
        }
    }
}
