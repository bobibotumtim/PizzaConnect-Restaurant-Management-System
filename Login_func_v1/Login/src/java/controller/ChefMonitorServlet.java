package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.*;
import models.*;
import dao.*;

@WebServlet("/ChefMonitor")
public class ChefMonitorServlet extends HttpServlet {

    private OrderDetailDAO orderDetailDAO = new OrderDetailDAO();
    private InventoryDAO inventoryDAO = new InventoryDAO();
    private ProductIngredientDAO productIngredientDAO = new ProductIngredientDAO();
    private OrderDetailToppingDAO orderDetailToppingDAO = new OrderDetailToppingDAO();

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
            req.setAttribute("error", "Dish ID not found!");
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
        int affectedOrderId = 0;

        if ("cancel".equals(action)) {
            // Lấy thông tin OrderDetail trước khi hủy để biết OrderID
            List<OrderDetail> waitingList = orderDetailDAO.getOrderDetailsByStatusExcludingCategory("Waiting", "Topping");
            List<OrderDetail> preparingList = orderDetailDAO.getOrderDetailsByStatusExcludingCategory("Preparing", "Topping");
            
            OrderDetail targetOrderDetail = null;
            for (OrderDetail od : waitingList) {
                if (od.getOrderDetailID() == orderDetailId) {
                    targetOrderDetail = od;
                    break;
                }
            }
            if (targetOrderDetail == null) {
                for (OrderDetail od : preparingList) {
                    if (od.getOrderDetailID() == orderDetailId) {
                        targetOrderDetail = od;
                        break;
                    }
                }
            }
            
            if (targetOrderDetail != null) {
                affectedOrderId = targetOrderDetail.getOrderID();
                // Hủy món - cập nhật status thành Cancelled
                updated = orderDetailDAO.updateOrderDetailStatus(orderDetailId, "Cancelled", chef.getEmployeeID());
                
                if (updated) {
                    OrderDAO orderDAO = new OrderDAO();
                    
                    // 🆕 Tự động tính lại tổng tiền (trừ món bị cancel)
                    orderDAO.recalculateOrderTotalPrice(affectedOrderId);
                    //boolean priceRecalculated = orderDAO.recalculateOrderTotalPrice(affectedOrderId);
                    //if (priceRecalculated) {
                    //    System.out.println("✅ Order #" + affectedOrderId + " total price recalculated after cancellation");
                    //}
                    
                    // Tự động cập nhật Order status
                    orderDAO.autoUpdateOrderStatusBasedOnDetails(affectedOrderId);
                }
            }
        } else if ("start".equals(action)) {
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
                boolean hasEnoughIngredients = checkIngredientsAvailability(targetOrderDetail);
                
                if (!hasEnoughIngredients) {
                    req.setAttribute("error", "Not enough ingredients to complete this dish!");
                    doGet(req, resp);
                    return;
                }
                
                // Cập nhật trạng thái
                updated = orderDetailDAO.updateOrderDetailStatus(orderDetailId, "Ready", chef.getEmployeeID());
                
                if (updated) {
                    // Trừ nguyên liệu sau khi cập nhật trạng thái thành công
                    boolean ingredientsDeducted = deductIngredientsForOrderDetail(targetOrderDetail);
                    
                    if (!ingredientsDeducted) {
                        System.err.println("Dish marked as Ready but error occurred while deducting ingredients");
                        req.setAttribute("error", "Dish is ready but error occurred while updating inventory!");
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
                req.setAttribute("error", "Dish information not found!");
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
            req.setAttribute("error", "Unable to update dish status!");
            doGet(req, resp);
        }
    }

    /**
     * Trừ nguyên liệu cho một OrderDetail khi chef hoàn thành món
     */
    private boolean deductIngredientsForOrderDetail(OrderDetail orderDetail) {
        try {
            // 1. Trừ nguyên liệu cho sản phẩm chính
            boolean productDeducted = deductProductIngredients(
                orderDetail.getProductSizeID(), 
                orderDetail.getQuantity()
            );
            
            if (!productDeducted) {
                System.err.println("❌ Unable to deduct ingredients for product: " + orderDetail.getProductName());
                return false;
            }
            
            // 2. Trừ nguyên liệu cho toppings (nếu có)
            List<OrderDetailTopping> toppings = orderDetailToppingDAO.getToppingsByOrderDetailID(
                orderDetail.getOrderDetailID()
            );
            
            if (toppings != null && !toppings.isEmpty()) {
                for (OrderDetailTopping topping : toppings) {
                    boolean toppingDeducted = deductProductIngredients(
                        topping.getToppingID(),
                        orderDetail.getQuantity()
                    );
                    
                    if (!toppingDeducted) {
                        System.err.println("Unable to deduct ingredients for topping: " + topping.getToppingName());
                    }
                }
            }
            
            return true;
            
        } catch (Exception e) {
            System.err.println("Error while deducting ingredients: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Trừ nguyên liệu cho một ProductSize
     */
    private boolean deductProductIngredients(int productSizeId, int quantity) {
        // Lấy danh sách nguyên liệu cần trừ
        Map<Integer, Double> ingredientsToDeduct = productIngredientDAO.getIngredientsToDeduct(
            productSizeId, 
            quantity
        );
        
        if (ingredientsToDeduct.isEmpty()) {
            return true; // Không có nguyên liệu thì coi như thành công
        }
        
        // Kiểm tra xem có đủ nguyên liệu không
        for (Map.Entry<Integer, Double> entry : ingredientsToDeduct.entrySet()) {
            int inventoryId = entry.getKey();
            double quantityNeeded = entry.getValue();
            
            if (!inventoryDAO.hasEnoughInventory(inventoryId, quantityNeeded)) {
                String itemName = inventoryDAO.getItemNameById(inventoryId);
                System.err.println("Not enough ingredients: " + itemName + " (needed: " + quantityNeeded + ")");
                return false;
            }
        }
        
        // Trừ nguyên liệu
        for (Map.Entry<Integer, Double> entry : ingredientsToDeduct.entrySet()) {
            int inventoryId = entry.getKey();
            double quantityNeeded = entry.getValue();
            
            boolean deducted = inventoryDAO.deductInventory(inventoryId, quantityNeeded);
            if (!deducted) {
                String itemName = inventoryDAO.getItemNameById(inventoryId);
                System.err.println("Unable to deduct ingredient: " + itemName);
                return false;
            }
        }
        
        return true;
    }
    
    /**
     * Kiểm tra xem có đủ nguyên liệu để làm món không
     */
    private boolean checkIngredientsAvailability(OrderDetail orderDetail) {
        try {
            // 1. Kiểm tra nguyên liệu cho sản phẩm chính
            Map<Integer, Double> productIngredients = productIngredientDAO.getIngredientsToDeduct(
                orderDetail.getProductSizeID(), 
                orderDetail.getQuantity()
            );
            
            for (Map.Entry<Integer, Double> entry : productIngredients.entrySet()) {
                if (!inventoryDAO.hasEnoughInventory(entry.getKey(), entry.getValue())) {
                    return false;
                }
            }
            
            // 2. Kiểm tra nguyên liệu cho toppings
            List<OrderDetailTopping> toppings = orderDetailToppingDAO.getToppingsByOrderDetailID(
                orderDetail.getOrderDetailID()
            );
            
            if (toppings != null && !toppings.isEmpty()) {
                for (OrderDetailTopping topping : toppings) {
                    Map<Integer, Double> toppingIngredients = productIngredientDAO.getIngredientsToDeduct(
                        topping.getToppingID(), 
                        orderDetail.getQuantity()
                    );
                    
                    for (Map.Entry<Integer, Double> entry : toppingIngredients.entrySet()) {
                        if (!inventoryDAO.hasEnoughInventory(entry.getKey(), entry.getValue())) {
                            return false;
                        }
                    }
                }
            }
            
            return true;
            
        } catch (Exception e) {
            System.err.println("Error while checking ingredients: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
}
