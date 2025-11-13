package controller;

import dao.OrderDAO;
import dao.ProductDAO;
import models.Order;
import models.OrderDetail;
import models.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "ManageOrderServlet", urlPatterns = {"/manage-orders"})
public class ManageOrderServlet extends HttpServlet {

    private static final int PAGE_SIZE = 10; // Số đơn hàng mỗi trang

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/Login");
            return;
        }

        User user = (User) session.getAttribute("user");
        request.setAttribute("currentUser", user);
        
        // Block Chef access to ManageOrders
        models.Employee employee = (models.Employee) session.getAttribute("employee");
        if (employee != null && employee.isChef()) {
            System.out.println("🚫 Chef blocked from accessing ManageOrders");
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Chefs cannot access Order Management. Please use Chef Monitor.");
            return;
        }

        String action = request.getParameter("action");
        
        if ("getOrder".equals(action)) {
            handleGetOrder(request, response);
            return;
        }

        OrderDAO orderDAO = new OrderDAO();
        
        // Lấy trang hiện tại từ parameter, mặc định là trang 1
        int currentPage = 1;
        String pageParam = request.getParameter("page");
        if (pageParam != null && !pageParam.isEmpty()) {
            try {
                currentPage = Integer.parseInt(pageParam);
                if (currentPage < 1) currentPage = 1;
            } catch (NumberFormatException e) {
                currentPage = 1;
            }
        }

        List<Order> orders;
        int totalOrders;
        Integer selectedStatus = null;

        // Xử lý filter theo status
        if ("filter".equals(action)) {
            String statusParam = request.getParameter("status");
            if (statusParam != null && !statusParam.isEmpty()) {
                try {
                    selectedStatus = Integer.parseInt(statusParam);
                    orders = orderDAO.getOrdersByStatusWithPagination(selectedStatus, currentPage, PAGE_SIZE);
                    totalOrders = orderDAO.countOrdersByStatus(selectedStatus);
                } catch (NumberFormatException e) {
                    orders = orderDAO.getOrdersWithPagination(currentPage, PAGE_SIZE);
                    totalOrders = orderDAO.countAllOrders();
                }
            } else {
                orders = orderDAO.getOrdersWithPagination(currentPage, PAGE_SIZE);
                totalOrders = orderDAO.countAllOrders();
            }
        } else {
            orders = orderDAO.getOrdersWithPagination(currentPage, PAGE_SIZE);
            totalOrders = orderDAO.countAllOrders();
        }

        // Tính tổng số trang
        int totalPages = (int) Math.ceil((double) totalOrders / PAGE_SIZE);

        // Set attributes
        request.setAttribute("orders", orders);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalOrders", totalOrders);
        request.setAttribute("selectedStatus", selectedStatus);

        request.getRequestDispatcher("/view/ManageOrders.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        System.out.println("╔════════════════════════════════════════╗");
        System.out.println("║   ManageOrderServlet.doPost() CALLED  ║");
        System.out.println("╚════════════════════════════════════════╝");
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            System.out.println("❌ User not logged in - redirecting to Login");
            response.sendRedirect(request.getContextPath() + "/Login");
            return;
        }

        String action = request.getParameter("action");
        System.out.println("📋 Action received: " + action);
        
        OrderDAO orderDAO = new OrderDAO();

        try {
            switch (action != null ? action : "") {
                case "updateStatus":
                    System.out.println("➡️ Routing to handleUpdateStatus");
                    handleUpdateStatus(request, response, orderDAO);
                    break;
                case "updatePayment":
                    System.out.println("➡️ Routing to handleUpdatePayment");
                    handleUpdatePayment(request, response, orderDAO);
                    break;
                // ❌ DELETE DISABLED - Orders cannot be deleted, only cancelled
                // case "delete":
                //     System.out.println("➡️ Routing to handleDelete");
                //     handleDelete(request, response, orderDAO);
                //     break;
                default:
                    System.out.println("⚠️ Unknown action: " + action + " - redirecting to manage-orders");
                    response.sendRedirect(request.getContextPath() + "/manage-orders");
                    break;
            }
        } catch (Exception e) {
            System.out.println("❌ Exception in doPost: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
            doGet(request, response);
        }
    }

    private void handleGetOrder(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try {
            int orderId = Integer.parseInt(request.getParameter("id"));
            OrderDAO orderDAO = new OrderDAO();
            dao.ProductSizeDAO productSizeDAO = new dao.ProductSizeDAO();
            dao.OrderDetailToppingDAO toppingDAO = new dao.OrderDetailToppingDAO();
            ProductDAO productDAO = new ProductDAO();
            
            Order order = orderDAO.getOrderById(orderId);
            if (order == null) {
                response.getWriter().write("{\"success\": false, \"message\": \"Order not found\"}");
                return;
            }

            List<OrderDetail> details = orderDAO.getOrderDetailsByOrderId(orderId);
            
            // Build JSON response
            StringBuilder json = new StringBuilder();
            json.append("{\"success\": true, \"order\": {");
            json.append("\"orderID\": ").append(order.getOrderID()).append(",");
            json.append("\"customerID\": ").append(order.getCustomerID()).append(",");
            json.append("\"tableID\": ").append(order.getTableID()).append(",");
            json.append("\"status\": ").append(order.getStatus()).append(",");
            json.append("\"paymentStatus\": \"").append(escapeJson(order.getPaymentStatus())).append("\",");
            json.append("\"totalPrice\": ").append(order.getTotalPrice()).append(",");
            json.append("\"note\": \"").append(escapeJson(order.getNote())).append("\"");
            json.append("}, \"details\": [");
            
            for (int i = 0; i < details.size(); i++) {
                OrderDetail detail = details.get(i);
                
                // Get product name and size from ProductSize
                String productName = "Unknown";
                String sizeName = "";
                double basePrice = 0;
                
                if (detail.getProductSizeID() > 0) {
                    models.ProductSize productSize = productSizeDAO.getProductSizeById(detail.getProductSizeID());
                    if (productSize != null) {
                        basePrice = productSize.getPrice();
                        
                        // Get size name from size code
                        String sizeCode = productSize.getSizeCode();
                        switch (sizeCode) {
                            case "S": sizeName = "Small"; break;
                            case "M": sizeName = "Medium"; break;
                            case "L": sizeName = "Large"; break;
                            case "F": sizeName = "Fixed"; break;
                            default: sizeName = sizeCode; break;
                        }
                        
                        // Get product name from Product table
                        models.Product product = productDAO.getProductById(productSize.getProductId());
                        if (product != null) {
                            productName = product.getProductName();
                        }
                    }
                }
                
                // Get toppings for this order detail
                List<models.OrderDetailTopping> toppings = toppingDAO.getToppingsByOrderDetailID(detail.getOrderDetailID());
                
                if (i > 0) json.append(",");
                json.append("{");
                json.append("\"orderDetailID\": ").append(detail.getOrderDetailID()).append(",");
                json.append("\"productName\": \"").append(escapeJson(productName)).append("\",");
                json.append("\"sizeName\": \"").append(escapeJson(sizeName)).append("\",");
                json.append("\"basePrice\": ").append(basePrice).append(",");
                json.append("\"quantity\": ").append(detail.getQuantity()).append(",");
                json.append("\"totalPrice\": ").append(detail.getTotalPrice()).append(",");
                
                // Add toppings array
                json.append("\"toppings\": [");
                for (int j = 0; j < toppings.size(); j++) {
                    models.OrderDetailTopping topping = toppings.get(j);
                    if (j > 0) json.append(",");
                    json.append("{");
                    json.append("\"toppingName\": \"").append(escapeJson(topping.getToppingName())).append("\",");
                    json.append("\"price\": ").append(topping.getToppingPrice());
                    json.append("}");
                }
                json.append("]");
                
                json.append("}");
            }
            
            json.append("]}");
            response.getWriter().write(json.toString());
            
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"success\": false, \"message\": \"" + escapeJson(e.getMessage()) + "\"}");
        }
    }
    
    private String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\")
                 .replace("\"", "\\\"")
                 .replace("\n", "\\n")
                 .replace("\r", "\\r")
                 .replace("\t", "\\t");
    }

    private void handleUpdateStatus(HttpServletRequest request, HttpServletResponse response, OrderDAO orderDAO)
            throws IOException {
        try {
            int orderId = Integer.parseInt(request.getParameter("orderId"));
            int status = Integer.parseInt(request.getParameter("status"));
            
            System.out.println("🔄 Updating order status - OrderID: " + orderId + ", New Status: " + status);
            
            boolean success = orderDAO.updateOrderStatus(orderId, status);
            
            if (success) {
                System.out.println("✅ Order status updated successfully");
                
                // Nếu Cancelled (4) → Set payment về Unpaid, cancel tất cả OrderDetail, và trả bàn
                if (status == 4) {
                    // Update tất cả OrderDetail thành Cancelled
                    dao.OrderDetailDAO orderDetailDAO = new dao.OrderDetailDAO();
                    List<OrderDetail> details = orderDAO.getOrderDetailsByOrderId(orderId);
                    int cancelledCount = 0;
                    for (OrderDetail detail : details) {
                        boolean detailCancelled = orderDetailDAO.updateOrderDetailStatus(
                            detail.getOrderDetailID(), 
                            "Cancelled", 
                            0  // No employee ID for system cancellation
                        );
                        if (detailCancelled) cancelledCount++;
                    }
                    System.out.println("✅ Cancelled " + cancelledCount + "/" + details.size() + " OrderDetails for Order #" + orderId);
                    
                    boolean paymentUpdated = orderDAO.updatePaymentStatus(orderId, "Unpaid");
                    if (paymentUpdated) {
                        System.out.println("✅ Payment status set to Unpaid (Order #" + orderId + " Cancelled)");
                    } else {
                        System.err.println("⚠️ Failed to update payment status for Order #" + orderId);
                    }
                    
                    // Trả bàn
                    Order order = orderDAO.getOrderById(orderId);
                    if (order != null && order.getTableID() > 0) {
                        dao.TableDAO tableDAO = new dao.TableDAO();
                        boolean tableUpdated = tableDAO.updateTableStatus(order.getTableID(), "available");
                        
                        if (tableUpdated) {
                            System.out.println("✅ Table #" + order.getTableID() + " set to available (Order #" + orderId + " Cancelled)");
                        } else {
                            System.err.println("⚠️ Failed to update table status for Table #" + order.getTableID());
                        }
                    }
                }
                
                // Nếu Completed (3) → Trả bàn (payment đã được set ở handleUpdatePayment)
                if (status == 3) {
                    Order order = orderDAO.getOrderById(orderId);
                    if (order != null && order.getTableID() > 0) {
                        dao.TableDAO tableDAO = new dao.TableDAO();
                        boolean tableUpdated = tableDAO.updateTableStatus(order.getTableID(), "available");
                        
                        if (tableUpdated) {
                            System.out.println("✅ Table #" + order.getTableID() + " set to available (Order #" + orderId + " Completed)");
                        } else {
                            System.err.println("⚠️ Failed to update table status for Table #" + order.getTableID());
                        }
                    }
                }
                
                request.getSession().setAttribute("message", "Cập nhật trạng thái đơn hàng thành công!");
            } else {
                System.out.println("❌ Failed to update order status");
                request.getSession().setAttribute("error", "Không thể cập nhật trạng thái đơn hàng.");
            }
        } catch (Exception e) {
            System.out.println("❌ Exception in handleUpdateStatus: " + e.getMessage());
            e.printStackTrace();
            request.getSession().setAttribute("error", "Lỗi: " + e.getMessage());
        }
        
        response.sendRedirect(request.getContextPath() + "/manage-orders");
    }

    private void handleUpdatePayment(HttpServletRequest request, HttpServletResponse response, OrderDAO orderDAO)
            throws IOException {
        try {
            int orderId = Integer.parseInt(request.getParameter("orderId"));
            String paymentStatus = request.getParameter("paymentStatus");
            
            System.out.println("💰 Updating payment status - OrderID: " + orderId + ", New Payment: " + paymentStatus);
            
            boolean success = orderDAO.updatePaymentStatus(orderId, paymentStatus);
            
            if (success) {
                System.out.println("✅ Payment status updated successfully");
                
                // If payment is "Paid" → Set order to Completed (status = 3) and table to Available
                if ("Paid".equalsIgnoreCase(paymentStatus)) {
                    // Update order status to Completed (3)
                    boolean statusUpdated = orderDAO.updateOrderStatus(orderId, 3);
                    
                    if (statusUpdated) {
                        System.out.println("✅ Order #" + orderId + " set to Completed (Paid)");
                        
                        // Set table to Available
                        Order order = orderDAO.getOrderById(orderId);
                        if (order != null && order.getTableID() > 0) {
                            dao.TableDAO tableDAO = new dao.TableDAO();
                            boolean tableUpdated = tableDAO.updateTableStatus(order.getTableID(), "available");
                            
                            if (tableUpdated) {
                                System.out.println("✅ Table #" + order.getTableID() + " set to available (Order #" + orderId + " Paid & Completed)");
                            } else {
                                System.err.println("⚠️ Failed to update table status for Table #" + order.getTableID());
                            }
                        }
                    } else {
                        System.err.println("⚠️ Failed to update order status to Completed");
                    }
                }
                
                request.getSession().setAttribute("message", "Cập nhật trạng thái thanh toán thành công!");
            } else {
                System.out.println("❌ Failed to update payment status");
                request.getSession().setAttribute("error", "Không thể cập nhật trạng thái thanh toán.");
            }
        } catch (Exception e) {
            System.out.println("❌ Exception in handleUpdatePayment: " + e.getMessage());
            e.printStackTrace();
            request.getSession().setAttribute("error", "Lỗi: " + e.getMessage());
        }
        
        response.sendRedirect(request.getContextPath() + "/manage-orders");
    }

    private void handleDelete(HttpServletRequest request, HttpServletResponse response, OrderDAO orderDAO)
            throws IOException {
        try {
            int orderId = Integer.parseInt(request.getParameter("orderId"));
            
            System.out.println("🗑️ Deleting order - OrderID: " + orderId);
            
            boolean success = orderDAO.deleteOrder(orderId);
            
            if (success) {
                System.out.println("✅ Order deleted successfully");
                request.getSession().setAttribute("message", "Xóa đơn hàng thành công!");
            } else {
                System.out.println("❌ Failed to delete order");
                request.getSession().setAttribute("error", "Không thể xóa đơn hàng.");
            }
        } catch (Exception e) {
            System.out.println("❌ Exception in handleDelete: " + e.getMessage());
            e.printStackTrace();
            request.getSession().setAttribute("error", "Lỗi: " + e.getMessage());
        }
        
        response.sendRedirect(request.getContextPath() + "/manage-orders");
    }
}
