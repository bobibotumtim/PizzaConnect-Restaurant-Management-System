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

    private OrderDetailDAO orderDetailDAO = new OrderDetailDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Lấy danh sách món theo trạng thái từ database mới
        List<OrderDetail> waitingList = orderDetailDAO.getOrderDetailsByStatus("Waiting");
        List<OrderDetail> inProgressList = orderDetailDAO.getOrderDetailsByStatus("In Progress");
        List<OrderDetail> doneList = orderDetailDAO.getOrderDetailsByStatus("Done");

        req.setAttribute("waitingList", waitingList);
        req.setAttribute("inProgressList", inProgressList);
        req.setAttribute("doneList", doneList);

        req.getRequestDispatcher("view/ChefMonitor.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        String orderDetailIdStr = req.getParameter("orderDetailId");
        
        if (orderDetailIdStr == null || orderDetailIdStr.isEmpty()) {
            req.setAttribute("error", "Không tìm thấy ID món ăn!");
            doGet(req, resp);
            return;
        }
        
        int orderDetailId = Integer.parseInt(orderDetailIdStr);

        HttpSession session = req.getSession();
        Employee chef = (Employee) session.getAttribute("employee");

        if (chef == null) {
            resp.sendRedirect("view/Login.jsp");
            return;
        }

        boolean updated = false;

        if ("start".equals(action)) {
            updated = orderDetailDAO.updateOrderDetailStatus(orderDetailId, "In Progress", chef.getEmployeeID());
        } else if ("done".equals(action)) {
            updated = orderDetailDAO.updateOrderDetailStatus(orderDetailId, "Done", chef.getEmployeeID());
            // TODO: Trừ nguyên liệu tại đây nếu cần
        } else if ("cancel".equals(action)) {
            updated = orderDetailDAO.updateOrderDetailStatus(orderDetailId, "Cancelled", chef.getEmployeeID());
        }

        if (updated) {
            resp.sendRedirect("ChefMonitor");
        } else {
            req.setAttribute("error", "Không thể cập nhật trạng thái món ăn!");
            doGet(req, resp);
        }
    }
}
