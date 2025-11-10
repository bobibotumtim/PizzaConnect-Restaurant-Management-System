package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;
import models.*;
import dao.*;
import service.InventoryDeductionService;

@WebServlet("/ChefMonitor")
public class ChefMonitorServlet extends HttpServlet {

    private OrderDetailDAO orderDetailDAO = new OrderDetailDAO();
    private InventoryDeductionService inventoryService = new InventoryDeductionService();

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
            // Lấy thông tin OrderDetail để trừ nguyên liệu
            List<OrderDetail> orderDetails = orderDetailDAO.getOrderDetailsByStatus("Preparing");
            OrderDetail targetOrderDetail = null;
            
            for (OrderDetail od : orderDetails) {
                if (od.getOrderDetailID() == orderDetailId) {
                    targetOrderDetail = od;
                    break;
                }
            }
            
            if (targetOrderDetail != null) {
                // Kiểm tra xem có đủ nguyên liệu không
                boolean hasEnoughIngredients = inventoryService.checkIngredientsAvailability(targetOrderDetail);
                
                if (!hasEnoughIngredients) {
                    req.setAttribute("error", "⚠️ Không đủ nguyên liệu để hoàn thành món này!");
                    doGet(req, resp);
                    return;
                }
                
                // Cập nhật trạng thái
                updated = orderDetailDAO.updateOrderDetailStatus(orderDetailId, "Ready", chef.getEmployeeID());
                
                if (updated) {
                    // Trừ nguyên liệu sau khi cập nhật trạng thái thành công
                    boolean ingredientsDeducted = inventoryService.deductIngredientsForOrderDetail(targetOrderDetail);
                    
                    if (!ingredientsDeducted) {
                        System.err.println("⚠️ Món đã được đánh dấu Ready nhưng có lỗi khi trừ nguyên liệu");
                        req.setAttribute("error", "⚠️ Món đã sẵn sàng nhưng có lỗi khi cập nhật kho!");
                    }
                }
            } else {
                req.setAttribute("error", "Không tìm thấy thông tin món ăn!");
                doGet(req, resp);
                return;
            }
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
