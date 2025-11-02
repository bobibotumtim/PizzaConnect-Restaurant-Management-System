package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;
import models.*;
import dao.*;

@WebServlet("/ChefMonitor")
public class ChefMonitorServlet extends HttpServlet {

    private OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Lấy danh sách món theo trạng thái
        List<Orderdetail> pendingList = orderDAO.getOrderDetailsByStatus("Pending");
        List<Orderdetail> cookingList = orderDAO.getOrderDetailsByStatus("Cooking");

        req.setAttribute("pendingList", pendingList);
        req.setAttribute("cookingList", cookingList);

        req.getRequestDispatcher("view/ChefMonitor.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        int orderDetailId = Integer.parseInt(req.getParameter("orderDetailId"));

        HttpSession session = req.getSession();
        Employee chef = (Employee) session.getAttribute("employee");

        if (chef == null) {
            resp.sendRedirect("view/Login.jsp");
            return;
        }

        boolean updated = false;

        if ("start".equals(action)) {
            updated = orderDAO.updateOrderDetailStatus(orderDetailId, "Cooking", chef.getEmployeeID());
        } else if ("done".equals(action)) {
            updated = orderDAO.updateOrderDetailStatus(orderDetailId, "Done", chef.getEmployeeID());
            // TODO: Trừ nguyên liệu tại đây
        } else if ("cancel".equals(action)) {
            updated = orderDAO.updateOrderDetailStatus(orderDetailId, "Cancelled", chef.getEmployeeID());
        }

        if (updated) {
            resp.sendRedirect("ChefServlet");
        } else {
            req.setAttribute("error", "Không thể cập nhật trạng thái món ăn!");
            doGet(req, resp);
        }
    }
}
