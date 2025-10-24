package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;
import dao.OrderDAO;
import models.Order;

public class OrderListServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        OrderDAO orderDAO = new OrderDAO();
        List<Order> orders = orderDAO.getAll();

        request.setAttribute("orderList", orders);

        RequestDispatcher rd = request.getRequestDispatcher("/view/order.jsp");
        rd.forward(request, response);
    }
}
