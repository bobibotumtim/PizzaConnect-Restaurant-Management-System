package controller;

import java.util.List;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import models.Discount;
import models.User;
import dao.DiscountDAO;
import java.sql.Date;
import java.util.logging.Logger;

@WebServlet(name = "DiscountServlet", urlPatterns = { "/discount" })
public class DiscountServlet extends HttpServlet {

    private static final String DISCOUNT_JSP_PATH = "/view/Discount.jsp";
    private static final Logger LOGGER = Logger.getLogger(DiscountServlet.class.getName());
    private DiscountDAO discountDAO = new DiscountDAO();

    @Override
    protected void doGet(jakarta.servlet.http.HttpServletRequest request,
            jakarta.servlet.http.HttpServletResponse response)
            throws jakarta.servlet.ServletException, java.io.IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("Login");
            return;
        }

        User user = (User) session.getAttribute("user");
        if (user.getRole() != 1) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied. Admin role required.");
            return;
        }

        try {
            List<Discount> discounts = discountDAO.getAllActiveDiscounts();
            request.setAttribute("discounts", discounts);
            request.setAttribute("user", user);
            request.getRequestDispatcher(DISCOUNT_JSP_PATH).forward(request, response);
        } catch (Exception e) {
            LOGGER.severe("Error fetching discounts: " + e.getMessage());
            request.setAttribute("error", "Failed to load discounts: " + e.getMessage());
            request.getRequestDispatcher(DISCOUNT_JSP_PATH).forward(request, response);
        }
    }

    @Override
    protected void doPost(jakarta.servlet.http.HttpServletRequest request,
            jakarta.servlet.http.HttpServletResponse response)
            throws jakarta.servlet.ServletException, java.io.IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("Login");
            return;
        }

        User user = (User) session.getAttribute("user");
        if (user.getRole() != 1) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied. Admin role required.");
            return;
        }

        String action = request.getParameter("action");
        try {
            if ("add".equals(action)) {
                // Validate inputs
                String description = request.getParameter("description");
                String discountType = request.getParameter("discountType");
                String valueStr = request.getParameter("value");
                String maxDiscountStr = request.getParameter("maxDiscount");
                String minOrderTotalStr = request.getParameter("minOrderTotal");
                String startDate = request.getParameter("startDate");
                String endDate = request.getParameter("endDate");

                if (description == null || description.trim().isEmpty() ||
                        discountType == null || !List.of("Percentage", "Fixed", "Loyalty").contains(discountType) ||
                        valueStr == null || startDate == null || minOrderTotalStr == null) {
                    throw new IllegalArgumentException("Required fields are missing or invalid.");
                }

                Discount discount = new Discount();
                discount.setDescription(description.trim());
                discount.setDiscountType(discountType);
                try {
                    discount.setValue(Double.parseDouble(valueStr));
                    discount.setMinOrderTotal(Double.parseDouble(minOrderTotalStr));
                } catch (NumberFormatException e) {
                    throw new IllegalArgumentException("Invalid numeric value for value or minOrderTotal.");
                }
                discount.setMaxDiscount(maxDiscountStr.isEmpty() ? null : Double.parseDouble(maxDiscountStr));
                discount.setStartDate(startDate);
                discount.setEndDate(endDate.isEmpty() ? null : endDate);
                discount.setActive(true);

                LOGGER.info("Attempting to add discount: " + discount.getDescription());
                discountDAO.addDiscount(discount);
                LOGGER.info("Discount added successfully: " + discount.getDescription());
            } else if ("edit".equals(action)) {
                String discountIdStr = request.getParameter("discountId");
                String description = request.getParameter("description");
                String discountType = request.getParameter("discountType");
                String valueStr = request.getParameter("value");
                String maxDiscountStr = request.getParameter("maxDiscount");
                String minOrderTotalStr = request.getParameter("minOrderTotal");
                String startDate = request.getParameter("startDate");
                String endDate = request.getParameter("endDate");

                if (discountIdStr == null || description == null || description.trim().isEmpty() ||
                        discountType == null || !List.of("Percentage", "Fixed", "Loyalty").contains(discountType) ||
                        valueStr == null || startDate == null || minOrderTotalStr == null) {
                    throw new IllegalArgumentException("Required fields are missing or invalid.");
                }

                Discount discount = new Discount();
                try {
                    discount.setDiscountId(Integer.parseInt(discountIdStr));
                    discount.setValue(Double.parseDouble(valueStr));
                    discount.setMinOrderTotal(Double.parseDouble(minOrderTotalStr));
                } catch (NumberFormatException e) {
                    throw new IllegalArgumentException(
                            "Invalid numeric value for discountId, value, or minOrderTotal.");
                }
                discount.setDescription(description.trim());
                discount.setDiscountType(discountType);
                discount.setMaxDiscount(maxDiscountStr.isEmpty() ? null : Double.parseDouble(maxDiscountStr));
                discount.setStartDate(startDate);
                discount.setEndDate(endDate.isEmpty() ? null : endDate);
                discount.setActive(true);

                LOGGER.info("Attempting to update discount ID: " + discount.getDiscountId());
                discountDAO.updateDiscount(discount);
                LOGGER.info("Discount updated successfully: ID " + discount.getDiscountId());
            } else if ("deactivate".equals(action)) {
                String discountIdStr = request.getParameter("discountId");
                if (discountIdStr == null || discountIdStr.trim().isEmpty()) {
                    throw new IllegalArgumentException("Discount ID is missing.");
                }
                int discountId;
                try {
                    discountId = Integer.parseInt(discountIdStr);
                } catch (NumberFormatException e) {
                    throw new IllegalArgumentException("Invalid discount ID format.");
                }
                if (discountId <= 0) {
                    throw new IllegalArgumentException("Invalid discount ID.");
                }
                LOGGER.info("Attempting to deactivate discount ID: " + discountId);
                discountDAO.deactivateDiscount(discountId);
                LOGGER.info("Discount deactivated successfully: ID " + discountId);
            }
            response.sendRedirect("discount");
        } catch (IllegalArgumentException e) {
            LOGGER.warning("Validation error: " + e.getMessage());
            request.setAttribute("error", e.getMessage());
            request.getRequestDispatcher(DISCOUNT_JSP_PATH).forward(request, response);
        } catch (Exception e) {
            LOGGER.severe("Operation failed: " + e.getMessage());
            request.setAttribute("error", "Operation failed: " + e.getMessage());
            request.getRequestDispatcher(DISCOUNT_JSP_PATH).forward(request, response);
        }
    }

    @Override
    public String getServletInfo() {
        return "Handles discount management operations for admins";
    }
}