package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.Arrays;
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

        // Lấy category filter từ request (nếu có)
        String categoryFilter = req.getParameter("category");
        
        List<OrderDetail> waitingList;
        List<OrderDetail> preparingList;
        List<OrderDetail> readyList;
        
        // Nếu có filter category, lọc theo category đó
        if (categoryFilter != null && !categoryFilter.isEmpty() && !categoryFilter.equals("All")) {
            waitingList = orderDetailDAO.getOrderDetailsByStatusAndCategories("Waiting", Arrays.asList(categoryFilter));
            preparingList = orderDetailDAO.getOrderDetailsByStatusAndCategories("Preparing", Arrays.asList(categoryFilter));
            readyList = orderDetailDAO.getOrderDetailsByStatusAndCategories("Ready", Arrays.asList(categoryFilter));
        } else {
            // Lấy tất cả món (trừ Topping)
            waitingList = orderDetailDAO.getOrderDetailsByStatusExcludingCategory("Waiting", "Topping");
            preparingList = orderDetailDAO.getOrderDetailsByStatusExcludingCategory("Preparing", "Topping");
            readyList = orderDetailDAO.getOrderDetailsByStatusExcludingCategory("Ready", "Topping");
        }

        // Lấy danh sách categories để hiển thị filter (trừ Topping)
        CategoryDAO categoryDAO = new CategoryDAO();
        List<String> categories = categoryDAO.getAllCategoryNamesExcluding("Topping");
        
        req.setAttribute("waitingList", waitingList);
        req.setAttribute("preparingList", preparingList);
        req.setAttribute("readyList", readyList);
        req.setAttribute("categories", categories);
        req.setAttribute("selectedCategory", categoryFilter != null ? categoryFilter : "All");

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
            // Lấy thông tin OrderDetail trước khi cập nhật
            List<OrderDetail> waitingList = orderDetailDAO.getOrderDetailsByStatusExcludingCategory("Waiting", "Topping");
            
            OrderDetail targetOrderDetail = null;
            for (OrderDetail od : waitingList) {
                if (od.getOrderDetailID() == orderDetailId) {
                    targetOrderDetail = od;
                    break;
                }
            }
            
            updated = orderDetailDAO.updateOrderDetailStatus(orderDetailId, "Preparing", chef.getEmployeeID());
            
            // Tự động cập nhật Order status
            if (updated && targetOrderDetail != null) {
                OrderDAO orderDAO = new OrderDAO();
                orderDAO.autoUpdateOrderStatusBasedOnDetails(targetOrderDetail.getOrderID());
            }
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
                    
                    // 🆕 Tự động cập nhật Order status dựa trên OrderDetail
                    int orderId = targetOrderDetail.getOrderID();
                    OrderDAO orderDAO = new OrderDAO();
                    boolean orderStatusUpdated = orderDAO.autoUpdateOrderStatusBasedOnDetails(orderId);
                    
                    if (orderStatusUpdated) {
                        System.out.println("✅ Order #" + orderId + " status auto-updated after chef marked dish as Ready");
                    }
                }
            } else {
                req.setAttribute("error", "Không tìm thấy thông tin món ăn!");
                doGet(req, resp);
                return;
            }
        }

        if (updated) {
            // Giữ lại category filter khi redirect
            String categoryFilter = req.getParameter("category");
            if (categoryFilter != null && !categoryFilter.isEmpty() && !categoryFilter.equals("All")) {
                resp.sendRedirect("ChefMonitor?category=" + categoryFilter);
            } else {
                resp.sendRedirect("ChefMonitor");
            }
        } else {
            req.setAttribute("error", "Không thể cập nhật trạng thái món ăn!");
            doGet(req, resp);
        }
    }
}
