package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;
import models.*;
import dao.*;

@WebServlet("/WaiterMonitor")
public class WaiterMonitorServlet extends HttpServlet {

    private OrderDetailDAO orderDetailDAO = new OrderDetailDAO();
    private OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Lấy danh sách món Ready và Served - dùng getAllOrderDetailsByStatus để hiển thị TẤT CẢ món
        List<OrderDetail> readyList = orderDetailDAO.getAllOrderDetailsByStatus("Ready");
        List<OrderDetail> servedList = orderDetailDAO.getAllOrderDetailsByStatus("Served");

        req.setAttribute("readyList", readyList);
        req.setAttribute("servedList", servedList);

        req.getRequestDispatcher("view/WaiterMonitor.jsp").forward(req, resp);
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
        Employee waiter = (Employee) session.getAttribute("employee");

        if (waiter == null) {
            resp.sendRedirect("view/Login.jsp");
            return;
        }

        boolean updated = false;

        if ("served".equals(action)) {
            // Lấy OrderDetail để biết OrderID
            String orderIdStr = req.getParameter("orderId");
            
            if (orderIdStr != null && !orderIdStr.isEmpty()) {
                int orderId = Integer.parseInt(orderIdStr);
                
                // Cập nhật status thành Served
                updated = orderDetailDAO.updateOrderDetailStatus(orderDetailId, "Served", waiter.getEmployeeID());
                
                // Auto-update Order status nếu tất cả món đã served
                if (updated) {
                    orderDAO.autoUpdateOrderStatusIfAllServed(orderId);
                }
            }
        }

        if (updated) {
            resp.sendRedirect("WaiterMonitor");
        } else {
            req.setAttribute("error", "Không thể cập nhật trạng thái món ăn!");
            doGet(req, resp);
        }
    }
}
