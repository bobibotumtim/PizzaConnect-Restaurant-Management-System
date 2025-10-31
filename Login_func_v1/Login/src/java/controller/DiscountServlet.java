package controller;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import models.Discount;
import models.User;
import dao.DiscountDAO;
import java.util.List;
import java.util.logging.Logger;

@WebServlet(name = "DiscountServlet", urlPatterns = { "/discount" })
public class DiscountServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(DiscountServlet.class.getName());
    private DiscountDAO discountDAO = new DiscountDAO();

    // Constants
    private static final String DISCOUNT_JSP_PATH = "/view/Discount.jsp";
    private static final int PAGE_SIZE = 10;

    // Parameter names
    private static final String PARAM_FILTER = "filter";
    private static final String PARAM_PAGE = "page";
    private static final String PARAM_ACTION = "action";
    private static final String PARAM_CURRENT_FILTER = "currentFilter";
    private static final String PARAM_CURRENT_PAGE = "currentPage";

    // Action names
    private static final String ACTION_ADD = "add";
    private static final String ACTION_EDIT = "edit";
    private static final String ACTION_DEACTIVATE = "deactivate";

    // Discount types
    private static final String TYPE_PERCENTAGE = "Percentage";
    private static final String TYPE_FIXED = "Fixed";
    private static final String TYPE_LOYALTY = "Loyalty";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) {
        try {
            if (!isAdminAuthenticated(request, response))
                return;

            String filter = getValidatedFilter(request.getParameter(PARAM_FILTER));
            int page = getValidatedPage(request.getParameter(PARAM_PAGE));

            LOGGER.info(String.format("Loading discounts - Filter: %s, Page: %d", filter, page));
            loadDiscountsData(request, filter, page);
            request.getRequestDispatcher(DISCOUNT_JSP_PATH).forward(request, response);

        } catch (Exception e) {
            LOGGER.severe("Error fetching discounts: " + e.getMessage());
            handleError(request, response, "Failed to load discounts: " + e.getMessage());
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) {
        try {
            if (!isAdminAuthenticated(request, response))
                return;

            String action = request.getParameter(PARAM_ACTION);
            String currentFilter = getValidatedFilter(request.getParameter(PARAM_CURRENT_FILTER));
            int currentPage = getValidatedPage(request.getParameter(PARAM_CURRENT_PAGE));

            LOGGER.info(String.format("POST Action: %s, Filter: %s, Page: %d", action, currentFilter, currentPage));
            processAction(request, action);
            redirectToDiscountList(response, currentFilter, currentPage);

        } catch (IllegalArgumentException e) {
            LOGGER.warning("Validation error: " + e.getMessage());
            handleError(request, response, e.getMessage());
        } catch (Exception e) {
            LOGGER.severe("Operation failed: " + e.getMessage());
            handleError(request, response, "Operation failed: " + e.getMessage());
        }
    }

    private void loadDiscountsData(HttpServletRequest request, String filter, int page) {
        boolean isActive = !"inactive".equals(filter);

        int totalItems = discountDAO.getDiscountsCountByStatus(isActive);
        int totalPages = calculateTotalPages(totalItems);
        page = adjustPageNumber(page, totalPages);

        List<Discount> discounts = discountDAO.getDiscountsByStatus(isActive, page);

        LOGGER.info(String.format("%s - Total: %d, Page: %d, Found: %d",
                isActive ? "ACTIVE" : "INACTIVE", totalItems, page, discounts.size()));

        setRequestAttributes(request, discounts, totalItems, page, totalPages, filter);
    }

    private void setRequestAttributes(HttpServletRequest request, List<Discount> discounts,
            int totalItems, int page, int totalPages, String filter) {
        request.setAttribute("discounts", discounts);
        request.setAttribute("totalItems", totalItems);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);

        int activeCount = discountDAO.getDiscountsCountByStatus(true);
        int inactiveCount = discountDAO.getDiscountsCountByStatus(false);

        request.setAttribute("totalDiscounts", activeCount + inactiveCount);
        request.setAttribute("activeDiscounts", activeCount);
        request.setAttribute("inactiveDiscounts", inactiveCount);
    }

    private void processAction(HttpServletRequest request, String action) {
        switch (action) {
            case ACTION_ADD:
                handleAddDiscount(request);
                break;
            case ACTION_EDIT:
                handleEditDiscount(request);
                break;
            case ACTION_DEACTIVATE:
                handleDeactivateDiscount(request);
                break;
            default:
                throw new IllegalArgumentException("Invalid action: " + action);
        }
    }

    private void handleAddDiscount(HttpServletRequest request) {
        Discount discount = extractDiscountFromRequest(request);
        validateDiscountForAdd(discount);

        LOGGER.info("Attempting to add discount: " + discount.getDescription());
        if (!discountDAO.addDiscount(discount)) {
            throw new IllegalArgumentException("Failed to add discount. Please check the input values.");
        }
        LOGGER.info("Discount added successfully: " + discount.getDescription());
    }

    private void handleEditDiscount(HttpServletRequest request) {
        Discount discount = extractDiscountFromRequest(request);
        discount.setDiscountId(getValidatedDiscountId(request.getParameter("discountId")));
        validateDiscountForEdit(discount);

        LOGGER.info("Attempting to update discount ID: " + discount.getDiscountId());
        if (!discountDAO.updateDiscount(discount)) {
            throw new IllegalArgumentException("Failed to update discount. Please check the input values.");
        }
        LOGGER.info("Discount updated successfully: ID " + discount.getDiscountId());
    }

    private void handleDeactivateDiscount(HttpServletRequest request) {
        int discountId = getValidatedDiscountId(request.getParameter("discountId"));

        LOGGER.info("Attempting to deactivate discount ID: " + discountId);
        if (!discountDAO.deactivateDiscount(discountId)) {
            throw new IllegalArgumentException("Failed to deactivate discount.");
        }
        LOGGER.info("Discount deactivated successfully: ID " + discountId);
    }

    private Discount extractDiscountFromRequest(HttpServletRequest request) {
        Discount discount = new Discount();
        discount.setDescription(getRequiredParameter(request, "description"));
        discount.setDiscountType(getRequiredParameter(request, "discountType"));
        discount.setValue(getValidatedDoubleParameter(request, "value"));
        discount.setMaxDiscount(getOptionalDoubleParameter(request, "maxDiscount"));
        discount.setMinOrderTotal(getValidatedDoubleParameter(request, "minOrderTotal"));
        discount.setStartDate(getRequiredParameter(request, "startDate"));
        discount.setEndDate(getOptionalParameter(request, "endDate"));
        return discount;
    }

    // Validation methods
    private void validateDiscountForAdd(Discount discount) {
        validateDiscountValues(discount.getDiscountType(), discount.getValue(),
                discount.getMaxDiscount(), discount.getMinOrderTotal(), ACTION_ADD);
    }

    private void validateDiscountForEdit(Discount discount) {
        validateDiscountValuesForEdit(discount.getDiscountType(), discount.getValue(),
                discount.getMaxDiscount(), discount.getMinOrderTotal(), discount.getDiscountId());
    }

    private void validateDiscountValues(String discountType, double value, Double maxDiscount,
            double minOrderTotal, String action) {
        validateValueByType(discountType, value);

        if (TYPE_LOYALTY.equals(discountType)) {
            if (ACTION_ADD.equals(action) && discountDAO.hasActiveLoyaltyDiscount()) {
                throw new IllegalArgumentException("There can only be one active loyalty discount at a time.");
            }
            if (minOrderTotal != 0) {
                throw new IllegalArgumentException("Loyalty discounts should have minimum order total of 0.");
            }
        }

        validateMaxDiscount(maxDiscount, discountType);
        validateMinOrderTotal(minOrderTotal);
    }

    private void validateDiscountValuesForEdit(String discountType, double value, Double maxDiscount,
            double minOrderTotal, int discountId) {
        validateValueByType(discountType, value);

        if (TYPE_LOYALTY.equals(discountType)) {
            if (discountDAO.hasActiveLoyaltyDiscountExcluding(discountId)) {
                throw new IllegalArgumentException("There can only be one active loyalty discount at a time.");
            }
            if (minOrderTotal != 0) {
                throw new IllegalArgumentException("Loyalty discounts should have minimum order total of 0.");
            }
        }

        validateMaxDiscount(maxDiscount, discountType);
        validateMinOrderTotal(minOrderTotal);
    }

    private void validateValueByType(String discountType, double value) {
        switch (discountType) {
            case TYPE_PERCENTAGE:
                if (value < 1 || value > 100) {
                    throw new IllegalArgumentException("Percentage value must be between 1% and 100%.");
                }
                break;
            case TYPE_FIXED:
                if (value < 1000) {
                    throw new IllegalArgumentException("Fixed discount value must be at least 1,000 VND.");
                }
                break;
            case TYPE_LOYALTY:
                if (value < 1) {
                    throw new IllegalArgumentException("Loyalty point value must be at least 1 point.");
                }
                break;
        }
    }

    private void validateMaxDiscount(Double maxDiscount, String discountType) {
        if (maxDiscount != null) {
            if (maxDiscount <= 0) {
                throw new IllegalArgumentException("Max discount must be greater than 0 if provided.");
            }
            if (TYPE_PERCENTAGE.equals(discountType) && maxDiscount < 1000) {
                throw new IllegalArgumentException(
                        "Max discount for percentage discounts should be at least 1,000 VND.");
            }
        }
    }

    private void validateMinOrderTotal(double minOrderTotal) {
        if (minOrderTotal < 0) {
            throw new IllegalArgumentException("Minimum order total cannot be negative.");
        }
    }

    // Utility methods
    private boolean isAdminAuthenticated(HttpServletRequest request, HttpServletResponse response) {
        try {
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("user") == null) {
                response.sendRedirect("Login");
                return false;
            }

            User user = (User) session.getAttribute("user");
            if (user.getRole() != 1) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied. Admin role required.");
                return false;
            }
            return true;
        } catch (Exception e) {
            LOGGER.severe("Authentication error: " + e.getMessage());
            return false;
        }
    }

    private String getRequiredParameter(HttpServletRequest request, String paramName) {
        String value = request.getParameter(paramName);
        if (value == null || value.trim().isEmpty()) {
            throw new IllegalArgumentException(paramName + " is required.");
        }
        return value.trim();
    }

    private String getOptionalParameter(HttpServletRequest request, String paramName) {
        String value = request.getParameter(paramName);
        return (value == null || value.trim().isEmpty()) ? null : value.trim();
    }

    private double getValidatedDoubleParameter(HttpServletRequest request, String paramName) {
        String value = getRequiredParameter(request, paramName);
        try {
            return Double.parseDouble(value);
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException(paramName + " must be a valid number.");
        }
    }

    private Double getOptionalDoubleParameter(HttpServletRequest request, String paramName) {
        String value = getOptionalParameter(request, paramName);
        if (value == null)
            return null;
        try {
            return Double.parseDouble(value);
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException(paramName + " must be a valid number.");
        }
    }

    private int getValidatedDiscountId(String discountIdStr) {
        if (discountIdStr == null || discountIdStr.trim().isEmpty()) {
            throw new IllegalArgumentException("Discount ID is required.");
        }
        try {
            int discountId = Integer.parseInt(discountIdStr);
            if (discountId <= 0) {
                throw new IllegalArgumentException("Invalid discount ID.");
            }
            return discountId;
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("Invalid discount ID format.");
        }
    }

    private String getValidatedFilter(String filter) {
        return ("inactive".equals(filter)) ? "inactive" : "active";
    }

    private int getValidatedPage(String pageStr) {
        if (pageStr == null || pageStr.trim().isEmpty()) {
            return 1;
        }
        try {
            return Math.max(1, Integer.parseInt(pageStr));
        } catch (NumberFormatException e) {
            return 1;
        }
    }

    private int calculateTotalPages(int totalItems) {
        return (int) Math.ceil((double) totalItems / PAGE_SIZE);
    }

    private int adjustPageNumber(int page, int totalPages) {
        return Math.min(page, Math.max(1, totalPages));
    }

    private void redirectToDiscountList(HttpServletResponse response, String filter, int page) {
        try {
            String redirectUrl = "discount?page=" + page;
            if ("inactive".equals(filter)) {
                redirectUrl += "&filter=inactive";
            }
            response.sendRedirect(redirectUrl);
        } catch (Exception e) {
            LOGGER.severe("Error redirecting: " + e.getMessage());
        }
    }

    private void handleError(HttpServletRequest request, HttpServletResponse response, String errorMessage) {
        try {
            request.setAttribute("error", errorMessage);
            doGet(request, response);
        } catch (Exception e) {
            LOGGER.severe("Error handling error: " + e.getMessage());
        }
    }
}