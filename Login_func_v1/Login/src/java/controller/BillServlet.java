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

        System.out.println("BillServlet: Processing GET request");

        String orderIdParam = req.getParameter("orderId");
        String embedded = req.getParameter("embedded");

        System.out.println("Order ID: " + orderIdParam);
        System.out.println("Embedded: " + embedded);

        if (orderIdParam == null || orderIdParam.trim().isEmpty()) {
            if ("true".equals(embedded)) {
                resp.setContentType("text/html;charset=UTF-8");
                resp.getWriter().write("<div class='text-center py-8 text-red-600'>Order ID is required</div>");
                return;
            } else {
                resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Order ID is required");
                return;
            }
        }

        try {
            int orderId = Integer.parseInt(orderIdParam);

            // Get order information
            OrderDAO orderDAO = new OrderDAO();
            Order order = orderDAO.getOrderWithDetails(orderId);

            if (order == null) {
                if ("true".equals(embedded)) {
                    resp.setContentType("text/html;charset=UTF-8");
                    resp.getWriter().write("<div class='text-center py-8 text-red-600'>Order not found</div>");
                    return;
                } else {
                    resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Order not found");
                    return;
                }
            }

            // Get payment information
            PaymentDAO paymentDAO = new PaymentDAO();
            Payment payment = paymentDAO.getPaymentByOrderId(orderId);

            // If no payment exists, create new one with QR Code as default
            if (payment == null) {
                payment = new Payment();
                payment.setOrderID(orderId);
                payment.setAmount(order.getTotalPrice());
                payment.setPaymentStatus("Pending");
                payment.setPaymentDate(new Date());

                // Generate dynamic QR code URL
                String qrUrl = generateQRCodeURL(order.getTotalPrice(), orderId);
                payment.setQrCodeURL(qrUrl);

                paymentDAO.createPayment(payment);
            } else {
                String qrUrl = generateQRCodeURL(order.getTotalPrice(), orderId);
                payment.setQrCodeURL(qrUrl);
                paymentDAO.updatePayment(payment);
            }

            // Calculate tax 10%
            double tax = order.getTotalPrice() * 0.1;
            double subtotal = order.getTotalPrice();
            order.setTotalPrice(subtotal + tax);

            // Set attributes for JSP
            req.setAttribute("order", order);
            req.setAttribute("payment", payment);
            req.setAttribute("subtotal", subtotal);
            req.setAttribute("tax", tax);
            req.setAttribute("currentDate", new SimpleDateFormat("dd-MM-yyyy HH:mm:ss").format(new Date()));
            req.setAttribute("embedded", "true".equals(embedded));

            // Add QR code URL as separate attribute for JavaScript
            String qrCodeUrl = generateQRCodeURL(order.getTotalPrice(), orderId);
            req.setAttribute("qrCodeUrl", qrCodeUrl);

            System.out.println("Forwarding to Bill.jsp");

            // Forward to bill page
            RequestDispatcher dispatcher = req.getRequestDispatcher(BILL_JSP_PATH);
            if (dispatcher != null) {
                dispatcher.forward(req, resp);
            } else {
                System.err.println("Bill.jsp not found");
                resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Bill template not found");
            }

        } catch (NumberFormatException e) {
            e.printStackTrace();
            if ("true".equals(embedded)) {
                resp.setContentType("text/html;charset=UTF-8");
                resp.getWriter().write("<div class='text-center py-8 text-red-600'>Invalid order ID</div>");
            } else {
                resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid order ID");
            }
        } catch (Exception e) {
            e.printStackTrace();
            if ("true".equals(embedded)) {
                resp.setContentType("text/html;charset=UTF-8");
                resp.getWriter().write("<div class='text-center py-8 text-red-600'>Error generating bill: "
                        + e.getMessage() + "</div>");
            } else {
                resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                        "Error generating bill: " + e.getMessage());
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        System.out.println("BillServlet: Processing POST request");

        String action = req.getParameter("action");
        String orderIdParam = req.getParameter("orderId");
        String embedded = req.getParameter("embedded");

        System.out.println("Action: " + action);
        System.out.println("Order ID: " + orderIdParam);

        if (orderIdParam == null || orderIdParam.trim().isEmpty()) {
            if ("true".equals(embedded)) {
                resp.setContentType("text/html;charset=UTF-8");
                resp.getWriter().write("error:Order ID is required");
                return;
            } else {
                resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Order ID is required");
                return;
            }
        }

        try {
            int orderId = Integer.parseInt(orderIdParam);

            if ("processPayment".equals(action)) {
                processPayment(req, resp, orderId);
            } else if ("getQRCode".equals(action)) {
                // API endpoint to get QR code URL
                getQRCodeURL(req, resp, orderId);
            } else {
                if ("true".equals(embedded)) {
                    resp.setContentType("text/html;charset=UTF-8");
                    resp.getWriter().write("error:Invalid action");
                } else {
                    resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action");
                }
            }

        } catch (NumberFormatException e) {
            e.printStackTrace();
            if ("true".equals(embedded)) {
                resp.setContentType("text/html;charset=UTF-8");
                resp.getWriter().write("error:Invalid order ID");
            } else {
                resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid order ID");
            }
        } catch (Exception e) {
            e.printStackTrace();
            if ("true".equals(embedded)) {
                resp.setContentType("text/html;charset=UTF-8");
                resp.getWriter().write("error:Error processing payment: " + e.getMessage());
            } else {
                resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                        "Error processing payment: " + e.getMessage());
            }
        }
    }

    private void processPayment(HttpServletRequest req, HttpServletResponse resp, int orderId)
            throws ServletException, IOException {

        String embedded = req.getParameter("embedded");

        System.out.println("Processing payment for order: " + orderId);

        try {
            PaymentDAO paymentDAO = new PaymentDAO();
            Payment payment = paymentDAO.getPaymentByOrderId(orderId);

            if (payment == null) {
                if ("true".equals(embedded)) {
                    resp.setContentType("text/html;charset=UTF-8");
                    resp.getWriter().write("error:Payment not found");
                    return;
                } else {
                    resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Payment not found");
                    return;
                }
            }

            // Update payment status to Completed
            payment.setPaymentStatus("Completed");
            payment.setPaymentDate(new Date());

            boolean paymentUpdated = paymentDAO.updatePayment(payment);

            if (paymentUpdated) {
                System.out.println("✅ Payment updated successfully for order: " + orderId);

                // Update order payment status and set order to Completed
                OrderDAO orderDAO = new OrderDAO();
                boolean orderUpdated = orderDAO.updateOrderStatusAndPayment(orderId, 3, "Paid");

                if (orderUpdated) {
                    System.out.println("✅ Order status and payment updated successfully for order: " + orderId);

                    // Set table to Available if order has table
                    Order order = orderDAO.getOrderById(orderId);
                    if (order != null && order.getTableID() > 0) {
                        dao.TableDAO tableDAO = new dao.TableDAO();
                        boolean tableUpdated = tableDAO.updateTableStatus(order.getTableID(), "available");

                        if (tableUpdated) {
                            System.out.println("✅ Table #" + order.getTableID() + " set to available (Order #" + orderId
                                    + " Paid & Completed)");
                        } else {
                            System.err.println("⚠️ Failed to update table status for Table #" + order.getTableID());
                        }
                    }

                    if ("true".equals(embedded)) {
                        resp.setContentType("text/html;charset=UTF-8");
                        resp.getWriter().write("success:Payment processed successfully");
                    } else {
                        resp.sendRedirect(
                                req.getContextPath() + "/bill?orderId=" + orderId
                                        + "&message=Payment processed successfully");
                    }
                } else {
                    System.err.println("❌ Failed to update order status for order: " + orderId);
                    if ("true".equals(embedded)) {
                        resp.setContentType("text/html;charset=UTF-8");
                        resp.getWriter().write("error:Failed to update order status");
                    } else {
                        resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Failed to update order status");
                    }
                }
            } else {
                System.err.println("❌ Failed to update payment for order: " + orderId);
                if ("true".equals(embedded)) {
                    resp.setContentType("text/html;charset=UTF-8");
                    resp.getWriter().write("error:Failed to process payment");
                } else {
                    resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Failed to process payment");
                }
            }

        } catch (Exception e) {
            System.err.println("❌ Exception processing payment for order " + orderId + ": " + e.getMessage());
            e.printStackTrace();
            if ("true".equals(embedded)) {
                resp.setContentType("text/html;charset=UTF-8");
                resp.getWriter().write("error:Error processing payment: " + e.getMessage());
            } else {
                resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                        "Error processing payment: " + e.getMessage());
            }
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

            // Return JSON response
            resp.setContentType("application/json");
            resp.setCharacterEncoding("UTF-8");
            resp.getWriter().write("{\"qrCodeUrl\": \"" + qrUrl + "\"}");

        } catch (Exception e) {
            e.printStackTrace();
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error generating QR code");
        }
    }

    private String generateQRCodeURL(double amount, int orderId) {
        // Generate QR code URL with dynamic information
        String baseUrl = "https://img.vietqr.io/image/vietinbank-113366668888-compact2.jpg";
        String amountStr = String.format("%.0f", amount);
        String addInfo = "Thanh toan order" + orderId;

        return baseUrl + "?amount=" + amountStr +
                "&addInfo=" + addInfo +
                "&accountName=Pizza Store";
    }
}