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

        HttpSession session = req.getSession();
        Employee chef = (Employee) session.getAttribute("employee");
        
        if (chef == null) {
            resp.sendRedirect("view/Login.jsp");
            return;
        }

        // Lấy specialization của chef
        String specialization = chef.getSpecialization();
        String categoryName = orderDetailDAO.mapSpecializationToCategory(specialization);
        
        List<OrderDetail> waitingList;
        List<OrderDetail> preparingList;
        List<OrderDetail> readyList;
        
        // Nếu chef có specialization, chỉ lấy món thuộc category đó
        if (categoryName != null) {
            waitingList = orderDetailDAO.getOrderDetailsByStatusAndCategory("Waiting", categoryName);
            preparingList = orderDetailDAO.getOrderDetailsByStatusAndCategory("Preparing", categoryName);
            readyList = orderDetailDAO.getOrderDetailsByStatusAndCategory("Ready", categoryName);
        } else {
            // Nếu không có specialization, lấy tất cả (fallback)
            waitingList = orderDetailDAO.getOrderDetailsByStatus("Waiting");
            preparingList = orderDetailDAO.getOrderDetailsByStatus("Preparing");
            readyList = orderDetailDAO.getOrderDetailsByStatus("Ready");
        }

        req.setAttribute("waitingList", waitingList);
        req.setAttribute("preparingList", preparingList);
        req.setAttribute("readyList", readyList);
        req.setAttribute("chefSpecialization", chef.getSpecializationDisplay());

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
            updated = orderDetailDAO.updateOrderDetailStatus(orderDetailId, "Preparing", chef.getEmployeeID());
        } else if ("ready".equals(action)) {
            updated = orderDetailDAO.updateOrderDetailStatus(orderDetailId, "Ready", chef.getEmployeeID());
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
