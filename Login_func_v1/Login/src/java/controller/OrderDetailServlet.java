package controller;

import dao.OrderDAO;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;
import models.Order;
import models.OrderDetail;

public class OrderDetailServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendRedirect("OrderListServlet");
            return;
        }

        int orderId = Integer.parseInt(idStr);
        OrderDAO dao = new OrderDAO();

        Order order = dao.getOrderById(orderId);
        List<OrderDetail> details = dao.getOrderDetailsByOrderId(orderId);

        request.setAttribute("order", order);
        request.setAttribute("details", details);
        request.getRequestDispatcher("/view/order-detail.jsp").forward(request, response);
    }
}
