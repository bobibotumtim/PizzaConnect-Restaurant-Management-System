package controller;

import dao.OrderDAO;
import dao.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import models.Order;
import models.Orderdetail;
import models.Product;
import models.User;

public class AddOrderServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Kiểm tra session và quyền admin/employee
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("Login");
            return;
        }
        
        User user = (User) session.getAttribute("user");
        if (user.getRole() != 1 && user.getRole() != 2) { // 1=admin, 2=employee
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied. Admin or Employee role required.");
            return;
        }
        
        // Lấy danh sách sản phẩm để hiển thị trong form
        ProductDAO productDAO = new ProductDAO();
        //List<Product> products = productDAO.getAllProducts();------------------------------------------------------------------------------------------------
        List<Product> products = null;
        
        request.setAttribute("products", products);
        request.setAttribute("currentUser", user);
        request.getRequestDispatcher("view/AddOrder.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Kiểm tra session và quyền admin/employee
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("Login");
            return;
        }
        
        User user = (User) session.getAttribute("user");
        if (user.getRole() != 1 && user.getRole() != 2) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied. Admin or Employee role required.");
            return;
        }
        
        try {
            // Lấy thông tin đơn hàng
            String tableNumber = request.getParameter("tableNumber");
            String customerName = request.getParameter("customerName");
            String customerPhone = request.getParameter("customerPhone");
            String notes = request.getParameter("notes");
            
            // Lấy danh sách sản phẩm đã chọn
            List<Orderdetail> orderDetails = new ArrayList<>();
            ProductDAO productDAO = new ProductDAO();
            
            // Lấy tất cả sản phẩm để lấy giá
            //List<Product> allProducts = productDAO.getAllProducts();------------------------------------------------------------------------------------------------
            List<Product> allProducts = null;
            
            for (Product product : allProducts) {
                String quantityParam = request.getParameter("quantity_" + product.getProductId());
                String specialInstructions = request.getParameter("instructions_" + product.getProductId());
                
                if (quantityParam != null && !quantityParam.trim().isEmpty()) {
                    try {
                        int quantity = Integer.parseInt(quantityParam);
                        if (quantity > 0) {
                            //double unitPrice = product.getPrice();------------------------------------------------------------------------------------------------
                            double unitPrice = 0;
                            double totalPrice = quantity * unitPrice;
                            
                            Orderdetail detail = new Orderdetail(
                                0, // OrderDetailID
                                0, // OrderID sẽ được set sau
                                product.getProductId(),
                                product.getProductName(),
                                quantity,
                                unitPrice,
                                totalPrice,
                                specialInstructions != null ? specialInstructions : "",
                                0,
                                "Pending",
                                null,
                                null
                            );
                            orderDetails.add(detail);
                        }
                    } catch (NumberFormatException e) {
                        // Bỏ qua nếu quantity không hợp lệ
                    }
                }
            }
            
            if (orderDetails.isEmpty()) {
                request.setAttribute("error", "Please select at least one item!");
                doGet(request, response);
                return;
            }
            
            // Tạo đơn hàng mới
            OrderDAO orderDAO = new OrderDAO();
            int orderId = orderDAO.createOrder(
                user.getUserID(), // StaffID
                tableNumber,
                customerName,
                customerPhone,
                notes,
                orderDetails
            );
            
            if (orderId > 0) {
                request.setAttribute("message", "Order created successfully! Order ID: " + orderId);
                response.sendRedirect("manage-orders?message=Order created successfully! Order ID: " + orderId);
            } else {
                request.setAttribute("error", "Failed to create order!");
                doGet(request, response);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "An error occurred while creating the order: " + e.getMessage());
            doGet(request, response);
        }
    }
}
