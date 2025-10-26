//package controller;
//
//import dao.OrderDAO;
//import jakarta.servlet.*;
//import jakarta.servlet.http.*;
//import jakarta.servlet.annotation.*;
//import java.io.IOException;
//import java.util.List;
//import models.Order;
//import models.OrderDetail;
//
//@WebServlet(name = "OrderServlet", urlPatterns = {"/manage-orders"})
//public class OrderServlet extends HttpServlet {
//
//    private final OrderDAO orderDAO = new OrderDAO();
//
//    @Override
//    protected void doGet(HttpServletRequest request, HttpServletResponse response)
//            throws ServletException, IOException {
//
//        String action = request.getParameter("action");
//
//        if ("edit".equals(action)) {
//            int id = Integer.parseInt(request.getParameter("id"));
//            Order order = orderDAO.getOrderById(id);
//            List<OrderDetail> details = orderDAO.getOrderDetailsByOrderId(id);
//
//            if (order == null) {
//                request.setAttribute("error", "Order not found!");
//                response.sendRedirect("manage-orders");
//                return;
//            }
//
//            request.setAttribute("order", order);
//            request.setAttribute("details", details);
//            request.setAttribute("modalTitle", "Edit Order #" + id);
//            request.setAttribute("actionType", "edit");
//            request.getRequestDispatcher("view/manageorder.jsp").forward(request, response);
//            return;
//        }
//
//        // ✅ Mặc định: load danh sách đơn hàng
//        List<Order> orders = orderDAO.getAll();
//        request.setAttribute("orders", orders);
//        request.getRequestDispatcher("view/manageorder.jsp").forward(request, response);
//    }
//
//    @Override
//    protected void doPost(HttpServletRequest request, HttpServletResponse response)
//            throws ServletException, IOException {
//
//        String action = request.getParameter("action");
//
//        if ("update".equals(action)) {
//            try {
//                int orderId = Integer.parseInt(request.getParameter("orderID"));
//                int status = Integer.parseInt(request.getParameter("status"));
//                String paymentStatus = request.getParameter("paymentStatus");
//                String note = request.getParameter("note");
//                double totalPrice = Double.parseDouble(request.getParameter("totalPrice"));
//
//                Order o = orderDAO.getOrderById(orderId);
//                if (o == null) {
//                    request.setAttribute("error", "Order not found!");
//                } else {
//                    o.setStatus(status);
//                    o.setPaymentStatus(paymentStatus);
//                    o.setNote(note);
//                    o.setTotalPrice(totalPrice);
//
//                    boolean success = orderDAO.update(o);
//
//                    if (success) {
//                        request.setAttribute("success", "Order updated successfully!");
//                    } else {
//                        request.setAttribute("error", "Failed to update order!");
//                    }
//                }
//
//                // Load lại danh sách
//                List<Order> orders = orderDAO.getAll();
//                request.setAttribute("orders", orders);
//                request.getRequestDispatcher("view/manageorder.jsp").forward(request, response);
//
//            } catch (Exception e) {
//                e.printStackTrace();
//                request.setAttribute("error", "Error updating order: " + e.getMessage());
//                List<Order> orders = orderDAO.getAll();
//                request.setAttribute("orders", orders);
//                request.getRequestDispatcher("view/manageorder.jsp").forward(request, response);
//            }
//        }
//    }
//}
