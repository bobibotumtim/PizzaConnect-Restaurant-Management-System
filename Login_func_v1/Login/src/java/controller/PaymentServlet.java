package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.IOException;
import java.sql.Connection;
import java.text.SimpleDateFormat;
import java.util.*;
import models.*;
import dao.*;

@WebServlet(name = "PaymentServlet", urlPatterns = { "/payment" })
public class PaymentServlet extends HttpServlet {

    private OrderDAO orderDAO;
    private UserDAO userDAO;
    private CustomerDAO customerDAO;
    private DiscountDAO discountDAO;
    private OrderDiscountDAO orderDiscountDAO;
    private PaymentDAO paymentDAO;

    @Override
    public void init() throws ServletException {
        orderDAO = new OrderDAO();
        userDAO = new UserDAO();
        customerDAO = new CustomerDAO();
        discountDAO = new DiscountDAO();
        orderDiscountDAO = new OrderDiscountDAO();
        paymentDAO = new PaymentDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/Login");
            return;
        }

        String orderIdParam = request.getParameter("orderId");
        if (orderIdParam == null || orderIdParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/manage-orders");
            return;
        }

        try {
            int orderId = Integer.parseInt(orderIdParam);

            // Get order details
            Order order = orderDAO.getOrderWithDetails(orderId);
            if (order == null) {
                session.setAttribute("error", "Order not found");
                response.sendRedirect(request.getContextPath() + "/manage-orders");
                return;
            }

            // Calculate current discount of order
            double currentDiscount = orderDiscountDAO.getTotalDiscountAmount(orderId);

            // Set discount amount for display in JSP
            request.setAttribute("currentDiscount", currentDiscount);

            // Get all active discounts (excluding loyalty) and filter by min order total
            List<Discount> availableDiscounts = discountDAO.getDiscountsByStatus(true, 1, null, null, null, null);
            List<Discount> applicableDiscounts = new ArrayList<>();

            for (Discount discount : availableDiscounts) {
                if (!"Loyalty".equals(discount.getDiscountType())) {
                    // Check min order total condition - only get discount that has min order total
                    // <= order total
                    if (discount.getMinOrderTotal() <= order.getTotalPrice()) {
                        applicableDiscounts.add(discount);
                    }
                }
            }

            // Get loyalty discount for conversion rate
            Discount loyaltyDiscount = null;
            for (Discount discount : availableDiscounts) {
                if ("Loyalty".equals(discount.getDiscountType())) {
                    loyaltyDiscount = discount;
                    break;
                }
            }

            // Get search results if any
            String searchPhone = request.getParameter("searchPhone");
            List<User> searchResults = new ArrayList<>();
            List<Customer> customerSearchResults = new ArrayList<>();

            if (searchPhone != null && !searchPhone.trim().isEmpty()) {
                searchResults = userDAO.searchCustomersByPhone(searchPhone, 5);

                // Create customer search results with full customer information
                for (User user : searchResults) {
                    Customer customer = customerDAO.getCustomerByUserID(user.getUserID());
                    if (customer != null) {
                        customerSearchResults.add(customer);
                    }
                }
                request.setAttribute("customerSearchResults", customerSearchResults);
            }

            request.setAttribute("order", order);
            request.setAttribute("discounts", applicableDiscounts);
            request.setAttribute("loyaltyDiscount", loyaltyDiscount);
            request.setAttribute("conversionRate", loyaltyDiscount != null ? (int) loyaltyDiscount.getValue() : 100);
            request.setAttribute("searchResults", searchResults);
            request.setAttribute("searchPhone", searchPhone);

            request.getRequestDispatcher("/view/Payment.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            session.setAttribute("error", "Invalid order ID");
            response.sendRedirect(request.getContextPath() + "/manage-orders");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("error", "Error loading payment page: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/manage-orders");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/Login");
            return;
        }

        String action = request.getParameter("action");

        if ("searchCustomer".equals(action)) {
            handleSearchCustomer(request, response);
        } else if ("confirmPayment".equals(action)) {
            handleConfirmPayment(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/manage-orders");
        }
    }

    private void handleSearchCustomer(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String orderId = request.getParameter("orderId");
        String searchPhone = request.getParameter("searchPhone");

        try {
            // Redirect back to payment page with search parameters
            String redirectUrl = request.getContextPath() + "/payment?orderId=" + orderId;
            if (searchPhone != null && !searchPhone.trim().isEmpty()) {
                redirectUrl += "&searchPhone=" + java.net.URLEncoder.encode(searchPhone, "UTF-8");
            }

            response.sendRedirect(redirectUrl);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/payment?orderId=" + orderId);
        }
    }

    private void handleConfirmPayment(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();

        try {
            int orderId = Integer.parseInt(request.getParameter("orderId"));
            int customerId = 0; // Default 0 if there's no customer
            int loyaltyPointsUsed = 0;
            int discountId = 0;
            double finalAmount = Double.parseDouble(request.getParameter("finalAmount"));
            String customerName = "Khách vãng lai";

            // Check if a customer selected
            String customerIdParam = request.getParameter("customerId");
            if (customerIdParam != null && !customerIdParam.trim().isEmpty()) {
                customerId = Integer.parseInt(customerIdParam);
                customerName = request.getParameter("customerName");
                if (customerName == null || customerName.trim().isEmpty()) {
                    customerName = "Khách vãng lai";
                }

                // Check loyalty points if there's a customer
                String loyaltyPointsParam = request.getParameter("loyaltyPointsUsed");
                if (loyaltyPointsParam != null && !loyaltyPointsParam.trim().isEmpty()) {
                    loyaltyPointsUsed = Integer.parseInt(loyaltyPointsParam);
                }
            }

            // Check discount
            String discountIdParam = request.getParameter("discountId");
            if (discountIdParam != null && !discountIdParam.trim().isEmpty() && !"0".equals(discountIdParam)) {
                discountId = Integer.parseInt(discountIdParam);
            }

            Connection conn = null;
            try {
                // Start transaction
                conn = new DBContext().getConnection();
                conn.setAutoCommit(false);

                // Get original order total
                Order originalOrder = orderDAO.getOrderById(orderId);
                double originalTotal = originalOrder.getTotalPrice();

                // Update order with customer ID (even 0) and final amount
                Order order = orderDAO.getOrderById(orderId);
                order.setCustomerID(customerId);
                order.setTotalPrice(finalAmount);
                orderDAO.update(order);

                // Calculate discount amounts
                double loyaltyDiscountAmount = 0;
                double regularDiscountAmount = 0;

                // Apply loyalty discount if there's a customer and pts are used
                if (customerId > 0 && loyaltyPointsUsed > 0) {
                    Discount loyaltyDiscount = getLoyaltyDiscount();
                    if (loyaltyDiscount != null) {
                        // Calculate loyalty discount amount
                        loyaltyDiscountAmount = (loyaltyPointsUsed / loyaltyDiscount.getValue()) * 1000;

                        OrderDiscount loyaltyOrderDiscount = new OrderDiscount();
                        loyaltyOrderDiscount.setOrderId(orderId);
                        loyaltyOrderDiscount.setDiscountId(loyaltyDiscount.getDiscountId());
                        loyaltyOrderDiscount.setAmount(loyaltyDiscountAmount);
                        loyaltyOrderDiscount
                                .setAppliedDate(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date()));

                        // Insert OrderDiscount
                        boolean loyaltyInserted = orderDiscountDAO.addDiscountToOrder(loyaltyOrderDiscount);
                        System.out.println(
                                "Loyalty discount inserted: " + loyaltyInserted + ", Amount: " + loyaltyDiscountAmount);

                        // Deduct loyalty points from customer
                        Customer customer = userDAO.getCustomerByCustomerId(customerId);
                        if (customer != null) {
                            int currentPoints = customer.getLoyaltyPoint();
                            // Validate pts not negative
                            int newPoints = Math.max(0, currentPoints - loyaltyPointsUsed);
                            userDAO.updateCustomerLoyaltyPoints(customerId, newPoints);
                            System.out.println("Loyalty points updated: " + currentPoints + " -> " + newPoints
                                    + " (used: " + loyaltyPointsUsed + ")");
                        }
                    }
                }

                // Apply regular discount
                if (discountId > 0) {
                    Discount discount = discountDAO.getDiscountById(discountId);
                    if (discount != null) {
                        regularDiscountAmount = calculateDiscountAmount(discount, originalTotal);

                        // Check max discount
                        if (discount.getMaxDiscount() != null && regularDiscountAmount > discount.getMaxDiscount()) {
                            regularDiscountAmount = discount.getMaxDiscount();
                        }

                        OrderDiscount orderDiscount = new OrderDiscount();
                        orderDiscount.setOrderId(orderId);
                        orderDiscount.setDiscountId(discountId);
                        orderDiscount.setAmount(regularDiscountAmount);
                        orderDiscount.setAppliedDate(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date()));

                        // Insert OrderDiscount
                        boolean regularInserted = orderDiscountDAO.addDiscountToOrder(orderDiscount);
                        System.out.println(
                                "Regular discount inserted: " + regularInserted + ", Amount: " + regularDiscountAmount
                                        + " (Discount ID: " + discountId + ")");
                    }
                }

                // Calculate earned loyalty points (1000 VND = 1 point) if there's a customer
                if (customerId > 0) {
                    int earnedPoints = (int) (finalAmount / 1000);
                    if (earnedPoints > 0) {
                        Customer customer = userDAO.getCustomerByCustomerId(customerId);
                        if (customer != null) {
                            int currentPoints = customer.getLoyaltyPoint();
                            int totalPoints = currentPoints + earnedPoints; // only plus pts because it had been
                                                                            // subtract before
                            userDAO.updateCustomerLoyaltyPoints(customerId, totalPoints);
                            System.out
                                    .println(
                                            "Earned loyalty points: " + earnedPoints + " (total: " + totalPoints + ")");
                        }
                    }
                }

                // Update order status and payment status
                orderDAO.updateOrderStatusAndPayment(orderId, 3, "Paid");

                // Update payment record
                Payment payment = paymentDAO.getPaymentByOrderId(orderId);
                if (payment != null) {
                    payment.setAmount(finalAmount);
                    payment.setPaymentStatus("Completed");
                    paymentDAO.updatePayment(payment);
                } else {
                    // Create new payment record if not exists
                    payment = new Payment();
                    payment.setOrderID(orderId);
                    payment.setAmount(finalAmount);
                    payment.setPaymentStatus("Completed");
                    payment.setPaymentDate(new java.util.Date());
                    paymentDAO.createPayment(payment);
                }

                // Commit transaction
                conn.commit();

                System.out.println("Payment processed successfully!");
                System.out.println("   Order ID: " + orderId);
                System.out.println("   Customer ID: " + customerId);
                System.out.println("   Customer Name: " + customerName);
                System.out.println("   Loyalty Points Used: " + loyaltyPointsUsed);
                System.out.println("   Discount ID: " + discountId);
                System.out.println("   Final Amount: " + finalAmount);
                System.out.println("   Loyalty Discount Amount: " + loyaltyDiscountAmount);
                System.out.println("   Regular Discount Amount: " + regularDiscountAmount);

                session.setAttribute("message", "Payment processed successfully!");
                response.sendRedirect(request.getContextPath() + "/manage-orders");

            } catch (Exception e) {
                if (conn != null) {
                    try {
                        conn.rollback();
                        System.err.println("Transaction rolled back due to error: " + e.getMessage());
                    } catch (Exception ex) {
                        ex.printStackTrace();
                    }
                }
                throw e;
            } finally {
                if (conn != null) {
                    try {
                        conn.setAutoCommit(true);
                        conn.close();
                    } catch (Exception ex) {
                        ex.printStackTrace();
                    }
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("error", "Error processing payment: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/payment?orderId=" + request.getParameter("orderId"));
        }
    }

    private Discount getLoyaltyDiscount() {
        List<Discount> discounts = discountDAO.getDiscountsByStatus(true, 1, null, null, null, null);
        for (Discount discount : discounts) {
            if ("Loyalty".equals(discount.getDiscountType())) {
                return discount;
            }
        }
        return null;
    }

    private double calculateDiscountAmount(Discount discount, double orderAmount) {
        if ("Percentage".equals(discount.getDiscountType())) {
            double discountAmount = orderAmount * (discount.getValue() / 100);
            if (discount.getMaxDiscount() != null && discountAmount > discount.getMaxDiscount()) {
                return discount.getMaxDiscount();
            }
            return discountAmount;
        } else if ("Fixed".equals(discount.getDiscountType())) {
            return Math.min(discount.getValue(), orderAmount); // Not exeed max discount value
        }
        return 0;
    }
}