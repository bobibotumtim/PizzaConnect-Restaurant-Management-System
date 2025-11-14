package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import models.*;
import dao.*;

public class BillServlet extends HttpServlet {

    private static final String BILL_JSP_PATH = "/view/Bill.jsp";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String orderIdParam = req.getParameter("orderId");
        if (orderIdParam == null || orderIdParam.trim().isEmpty()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Order ID is required");
            return;
        }

        try {
            int orderId = Integer.parseInt(orderIdParam);

            // Lấy thông tin order
            OrderDAO orderDAO = new OrderDAO();
            Order order = orderDAO.getOrderWithDetails(orderId);

            if (order == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Order not found");
                return;
            }

            // Lấy thông tin payment
            PaymentDAO paymentDAO = new PaymentDAO();
            Payment payment = paymentDAO.getPaymentByOrderId(orderId);

            // Nếu chưa có payment, tạo mới
            if (payment == null) {
                payment = new Payment();
                payment.setOrderID(orderId);
                payment.setPaymentMethod("Cash");
                payment.setAmount(order.getTotalPrice());
                payment.setPaymentStatus("Pending");
                payment.setPaymentDate(new Date());

                // Tạo QR code URL động
                String qrUrl = generateQRCodeURL(order.getTotalPrice(), orderId);
                payment.setQrCodeURL(qrUrl);

                paymentDAO.createPayment(payment);
            }

            // Tính thuế 10%
            double tax = order.getTotalPrice() * 0.1;
            double subtotal = order.getTotalPrice();
            order.setTotalPrice(subtotal + tax);

            // Set attributes cho JSP
            req.setAttribute("order", order);
            req.setAttribute("payment", payment);
            req.setAttribute("subtotal", subtotal);
            req.setAttribute("tax", tax);
            req.setAttribute("currentDate", new SimpleDateFormat("dd-MM-yyyy HH:mm:ss").format(new Date()));

            // Thêm QR code URL như một attribute riêng để sử dụng trong JavaScript
            String qrCodeUrl = generateQRCodeURL(order.getTotalPrice(), orderId);
            req.setAttribute("qrCodeUrl", qrCodeUrl);

            // Forward đến bill page
            req.getRequestDispatcher(BILL_JSP_PATH).forward(req, resp);

        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid order ID");
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error generating bill");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        String orderIdParam = req.getParameter("orderId");

        if (orderIdParam == null || orderIdParam.trim().isEmpty()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Order ID is required");
            return;
        }

        try {
            int orderId = Integer.parseInt(orderIdParam);

            if ("updatePayment".equals(action)) {
                updatePaymentMethod(req, resp, orderId);
            } else if ("processPayment".equals(action)) {
                processPayment(req, resp, orderId);
            } else if ("getQRCode".equals(action)) {
                // API endpoint để lấy QR code URL
                getQRCodeURL(req, resp, orderId);
            } else {
                resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action");
            }

        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid order ID");
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error processing payment");
        }
    }

    private void updatePaymentMethod(HttpServletRequest req, HttpServletResponse resp, int orderId)
            throws ServletException, IOException {

        String paymentMethod = req.getParameter("paymentMethod");

        if (paymentMethod == null || paymentMethod.trim().isEmpty()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Payment method is required");
            return;
        }

        try {
            PaymentDAO paymentDAO = new PaymentDAO();
            Payment payment = paymentDAO.getPaymentByOrderId(orderId);

            if (payment == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Payment not found");
                return;
            }

            payment.setPaymentMethod(paymentMethod);

            if ("QR Code".equals(paymentMethod)) {
                OrderDAO orderDAO = new OrderDAO();
                Order order = orderDAO.getOrderWithDetails(orderId);
                if (order != null) {
                    double tax = order.getTotalPrice() * 0.1;
                    double subtotal = order.getTotalPrice() - tax;
                    String qrUrl = generateQRCodeURL(order.getTotalPrice(), orderId);
                    payment.setQrCodeURL(qrUrl);
                }
            }

            boolean updated = paymentDAO.updatePayment(payment);

            if (updated) {
                resp.sendRedirect(req.getContextPath() + "/bill?orderId=" + orderId);
            } else {
                resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Failed to update payment method");
            }

        } catch (Exception e) {
            e.printStackTrace();
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error updating payment method");
        }
    }

    private void processPayment(HttpServletRequest req, HttpServletResponse resp, int orderId)
            throws ServletException, IOException {

        try {
            PaymentDAO paymentDAO = new PaymentDAO();
            Payment payment = paymentDAO.getPaymentByOrderId(orderId);

            if (payment == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Payment not found");
                return;
            }

            payment.setPaymentStatus("Completed");
            payment.setPaymentDate(new Date());

            boolean updated = paymentDAO.updatePayment(payment);

            if (updated) {
                // Update order payment status
                OrderDAO orderDAO = new OrderDAO();
                orderDAO.updatePaymentStatus(orderId, "Paid");
                orderDAO.autoUpdateOrderStatusIfAllServed(orderId);

                // Kiểm tra xem có nên hiển thị feedback prompt không
                if (shouldShowFeedbackPrompt(orderId)) {
                    // Redirect đến feedback prompt thay vì bill page
                    resp.sendRedirect(req.getContextPath() + "/feedback-prompt?orderId=" + orderId);
                } else {
                    // Nếu đã có feedback, redirect về home
                    resp.sendRedirect(req.getContextPath() + "/home?message=Payment processed successfully");
                }
            } else {
                resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Failed to process payment");
            }

        } catch (Exception e) {
            e.printStackTrace();
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error processing payment");
        }
    }

    /**
     * Kiểm tra xem có nên hiển thị feedback prompt không
     * @param orderId ID của order
     * @return true nếu chưa có feedback, false nếu đã có
     */
    private boolean shouldShowFeedbackPrompt(int orderId) {
        try {
            CustomerFeedbackDAO feedbackDAO = new CustomerFeedbackDAO();
            return !feedbackDAO.hasFeedbackForOrder(orderId);
        } catch (Exception e) {
            System.err.println("Error checking feedback for order " + orderId + ": " + e.getMessage());
            // Nếu có lỗi, vẫn cho hiển thị feedback prompt
            return true;
        }
    }

    private void getQRCodeURL(HttpServletRequest req, HttpServletResponse resp, int orderId)
            throws ServletException, IOException {

        try {
            OrderDAO orderDAO = new OrderDAO();
            Order order = orderDAO.getOrderWithDetails(orderId);

            if (order == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Order not found");
                return;
            }

            String qrUrl = generateQRCodeURL(order.getTotalPrice(), orderId);

            // Trả về JSON response
            resp.setContentType("application/json");
            resp.setCharacterEncoding("UTF-8");
            resp.getWriter().write("{\"qrCodeUrl\": \"" + qrUrl + "\"}");

        } catch (Exception e) {
            e.printStackTrace();
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error generating QR code");
        }
    }

    private String generateQRCodeURL(double amount, int orderId) {
        // Tạo QR code URL với thông tin động
        String baseUrl = "https://img.vietqr.io/image/vietinbank-113366668888-compact2.jpg";
        String amountStr = String.format("%.0f", amount);
        String addInfo = "Thanh toan order" + orderId;

        return baseUrl + "?amount=" + amountStr +
                "&addInfo=" + addInfo +
                "&accountName=Pizza Store";
    }
}