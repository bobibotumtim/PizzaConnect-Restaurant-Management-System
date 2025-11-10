package controller;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import models.Discount;
import models.User;
import dao.DiscountDAO;

import java.util.Arrays;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.logging.Logger;

/**
 * Servlet for handling discount management operations
 * Provides CRUD operations and filtering for discounts
 */
@WebServlet(name = "DiscountServlet", urlPatterns = { "/discount" })
public class DiscountServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(DiscountServlet.class.getName());
    private DiscountDAO discountDAO = new DiscountDAO();

    // Constants
    private static final String DISCOUNT_JSP_PATH = "/view/Discount.jsp";
    private static final String NOT_FOUND_PATH = "/view/NotFound.jsp";
    private static final String LOGIN_PATH = "Login";
    private static final int PAGE_SIZE = 10;

    // Parameter names
    private static final String PARAM_FILTER = "filter";
    private static final String PARAM_PAGE = "page";
    private static final String PARAM_ACTION = "action";
    private static final String PARAM_CURRENT_FILTER = "currentFilter";
    private static final String PARAM_CURRENT_PAGE = "currentPage";
    private static final String PARAM_TYPE = "type";
    private static final String PARAM_START_DATE = "startDate";
    private static final String PARAM_END_DATE = "endDate";
    private static final String PARAM_SEARCH = "search";

    // Action names
    private static final String ACTION_ADD = "add";
    private static final String ACTION_EDIT = "edit";
    private static final String ACTION_DEACTIVATE = "deactivate";

    // Discount types
    private static final String TYPE_PERCENTAGE = "Percentage";
    private static final String TYPE_FIXED = "Fixed";
    private static final String TYPE_LOYALTY = "Loyalty";

    // Valid discount types
    private static final Set<String> VALID_DISCOUNT_TYPES = Collections.unmodifiableSet(new HashSet<>(Arrays.asList(
            TYPE_PERCENTAGE,
            TYPE_FIXED,
            TYPE_LOYALTY)));

    /**
     * Handles GET requests for discount management page
     * Loads discounts with filtering and pagination
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) {
        try {
            if (!isAdminAuthenticated(request, response))
                return;

            // Validate URL parameters before processing
            if (!validateUrlParameters(request)) {
                forwardToNotFound(request, response, "Invalid URL parameters");
                return;
            }

            String filter = getValidatedFilter(request.getParameter(PARAM_FILTER));
            int page = getValidatedPage(request.getParameter(PARAM_PAGE));
            String type = request.getParameter(PARAM_TYPE);
            String startDate = request.getParameter(PARAM_START_DATE);
            String endDate = request.getParameter(PARAM_END_DATE);
            String search = request.getParameter(PARAM_SEARCH);

            // Validate page range
            if (!validatePageRange(page)) {
                forwardToNotFound(request, response, "Invalid page number");
                return;
            }

            LOGGER.info(String.format(
                    "Loading discounts - Filter: %s, Page: %d, Type: %s, StartDate: %s, EndDate: %s, Search: %s",
                    filter, page, type, startDate, endDate, search));

            loadDiscountsData(request, filter, page, type, startDate, endDate, search);
            request.getRequestDispatcher(DISCOUNT_JSP_PATH).forward(request, response);

        } catch (Exception e) {
            LOGGER.severe("Error fetching discounts: " + e.getMessage());
            forwardToNotFound(request, response, "Failed to load discounts: " + e.getMessage());
        }
    }

    /**
     * Handles POST requests for discount operations (add, edit, delete)
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) {
        try {
            if (!isAdminAuthenticated(request, response))
                return;

            // Validate URL parameters before processing
            if (!validateUrlParameters(request)) {
                forwardToNotFound(request, response, "Invalid URL parameters");
                return;
            }

            String action = request.getParameter(PARAM_ACTION);
            String currentFilter = getValidatedFilter(request.getParameter(PARAM_CURRENT_FILTER));
            int currentPage = getValidatedPage(request.getParameter(PARAM_CURRENT_PAGE));

            // Validate action parameter
            if (!validateActionParameter(action)) {
                forwardToNotFound(request, response, "Invalid action parameter");
                return;
            }

            LOGGER.info(String.format("POST Action: %s, Filter: %s, Page: %d", action, currentFilter, currentPage));
            processAction(request, action);
            redirectToDiscountList(response, currentFilter, currentPage);

        } catch (IllegalArgumentException e) {
            LOGGER.warning("Validation error: " + e.getMessage());
            handleError(request, response, e.getMessage());
        } catch (Exception e) {
            LOGGER.severe("Operation failed: " + e.getMessage());
            forwardToNotFound(request, response, "Operation failed: " + e.getMessage());
        }
    }

    // ==================== DATA LOADING METHODS ====================

    /**
     * Loads discounts data with pagination and filtering
     */
    private void loadDiscountsData(HttpServletRequest request, String filter, int page, String type,
            String startDate, String endDate, String search) {
        boolean isActive = !"inactive".equals(filter);

        int totalItems = discountDAO.getDiscountsCountByStatus(isActive, type, startDate, endDate, search);
        int totalPages = calculateTotalPages(totalItems);

        // Adjust page number if it's beyond total pages
        if (page > totalPages && totalPages > 0) {
            page = totalPages;
        }

        page = adjustPageNumber(page, totalPages);

        List<Discount> discounts = discountDAO.getDiscountsByStatus(isActive, page, type, startDate, endDate, search);

        // Add canEdit flag to each discount for UI control
        for (Discount discount : discounts) {
            boolean canEdit = discountDAO.canEditDiscount(discount.getDiscountId());
            request.setAttribute("canEdit_" + discount.getDiscountId(), canEdit);
        }

        LOGGER.info(String.format("%s - Total: %d, Page: %d, Found: %d",
                isActive ? "ACTIVE" : "INACTIVE", totalItems, page, discounts.size()));

        setRequestAttributes(request, discounts, totalItems, page, totalPages, filter, type, startDate, endDate,
                search);
    }

    /**
     * Sets request attributes for JSP page
     */
    private void setRequestAttributes(HttpServletRequest request, List<Discount> discounts,
            int totalItems, int page, int totalPages, String filter, String type, String startDate, String endDate,
            String search) {
        request.setAttribute("discounts", discounts);
        request.setAttribute("totalItems", totalItems);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);

        int activeCount = discountDAO.getDiscountsCountByStatus(true, null, null, null, null);
        int inactiveCount = discountDAO.getDiscountsCountByStatus(false, null, null, null, null);

        request.setAttribute("totalDiscounts", activeCount + inactiveCount);
        request.setAttribute("activeDiscounts", activeCount);
        request.setAttribute("inactiveDiscounts", inactiveCount);

        // Set filter attributes for form persistence
        if (type != null)
            request.setAttribute("type", type);
        if (startDate != null)
            request.setAttribute("startDate", startDate);
        if (endDate != null)
            request.setAttribute("endDate", endDate);
        if (search != null)
            request.setAttribute("search", search);
    }

    // ==================== ACTION PROCESSING METHODS ====================

    /**
     * Processes different actions (add, edit, deactivate)
     */
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

    /**
     * Handles adding new discount
     */
    private void handleAddDiscount(HttpServletRequest request) {
        Discount discount = extractDiscountFromRequest(request);
        validateDiscountForAdd(discount);

        // Check for duplicate description
        if (discountDAO.discountDescriptionExists(discount.getDescription())) {
            throw new IllegalArgumentException("A discount with this description already exists.");
        }

        LOGGER.info("Attempting to add discount: " + discount.getDescription());
        if (!discountDAO.addDiscount(discount)) {
            throw new IllegalArgumentException("Failed to add discount. Please check the input values.");
        }
        LOGGER.info("Discount added successfully: " + discount.getDescription());

        request.getSession().setAttribute("success", "Discount added successfully!");
    }

    /**
     * Handles editing existing discount - only if start date > today
     */
    private void handleEditDiscount(HttpServletRequest request) {
        Discount discount = extractDiscountFromRequest(request);
        discount.setDiscountId(getValidatedDiscountId(request.getParameter("discountId")));
        validateDiscountForEdit(discount);

        // Check for duplicate description excluding current discount
        if (discountDAO.discountDescriptionExists(discount.getDescription(), discount.getDiscountId())) {
            throw new IllegalArgumentException("A discount with this description already exists.");
        }

        LOGGER.info("Attempting to update discount ID: " + discount.getDiscountId());

        // Check if discount can be edited (start date > today)
        if (!discountDAO.canEditDiscount(discount.getDiscountId())) {
            throw new IllegalArgumentException("Cannot edit discount that has already started.");
        }

        if (!discountDAO.updateDiscount(discount)) {
            throw new IllegalArgumentException("Failed to update discount. Please check the input values.");
        }

        request.getSession().setAttribute("success", "Discount updated successfully!");
        LOGGER.info("Discount updated immediately: ID " + discount.getDiscountId());
    }

    /**
     * Handles deactivating discount using smart delete
     */
    private void handleDeactivateDiscount(HttpServletRequest request) {
        int discountId = getValidatedDiscountId(request.getParameter("discountId"));

        // Validate discount exists
        Discount existingDiscount = discountDAO.getDiscountById(discountId);
        if (existingDiscount == null) {
            throw new IllegalArgumentException("Discount not found with ID: " + discountId);
        }

        LOGGER.info("Attempting to delete discount ID: " + discountId);

        // Use smart delete which decides between hard delete or scheduled deletion
        if (!discountDAO.smartDeleteDiscount(discountId)) {
            throw new IllegalArgumentException("Failed to delete discount.");
        }

        boolean isFutureDiscount = discountDAO.isStartDateInFuture(discountId);

        if (isFutureDiscount) {
            LOGGER.info("Discount hard deleted: ID " + discountId);
            request.getSession().setAttribute("success",
                    "Discount '" + existingDiscount.getDescription() + "' has been permanently deleted.");
        } else {
            LOGGER.info("Discount deletion scheduled: ID " + discountId);
            request.getSession().setAttribute("success",
                    "Discount deletion scheduled. It will be deactivated at the end of the day.");
        }

        LOGGER.info("Discount processed successfully: ID " + discountId);
    }

    // ==================== VALIDATION METHODS ====================

    /**
     * Validates discount for add operation
     */
    private void validateDiscountForAdd(Discount discount) {
        validateDiscountValues(discount.getDiscountType(), discount.getValue(),
                discount.getMaxDiscount(), discount.getMinOrderTotal(), ACTION_ADD);
    }

    /**
     * Validates discount for edit operation
     */
    private void validateDiscountForEdit(Discount discount) {
        validateDiscountValuesForEdit(discount.getDiscountType(), discount.getValue(),
                discount.getMaxDiscount(), discount.getMinOrderTotal(), discount.getDiscountId());
    }

    /**
     * Validates discount values based on type and operation
     */
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

    /**
     * Validates discount values for edit operation
     */
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

    /**
     * Validates discount value based on discount type
     */
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

    /**
     * Validates maximum discount value
     */
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

    /**
     * Validates minimum order total
     */
    private void validateMinOrderTotal(double minOrderTotal) {
        if (minOrderTotal < 0) {
            throw new IllegalArgumentException("Minimum order total cannot be negative.");
        }
    }

    // ==================== UTILITY METHODS ====================

    /**
     * Checks if user is authenticated as admin
     */
    private boolean isAdminAuthenticated(HttpServletRequest request, HttpServletResponse response) {
        try {
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("user") == null) {
                response.sendRedirect(LOGIN_PATH);
                return false;
            }

            User user = (User) session.getAttribute("user");
            if (user.getRole() != 1) {
                // Forward to not-found page for non-admin users
                forwardToNotFound(request, response, "User is not admin");
                return false;
            }
            return true;
        } catch (Exception e) {
            LOGGER.severe("Authentication error: " + e.getMessage());
            forwardToNotFound(request, response, "Authentication error");
            return false;
        }
    }

    /**
     * Extracts discount object from HTTP request parameters
     */
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

    /**
     * Gets required parameter from request
     */
    private String getRequiredParameter(HttpServletRequest request, String paramName) {
        String value = request.getParameter(paramName);
        if (value == null || value.trim().isEmpty()) {
            throw new IllegalArgumentException(paramName + " is required.");
        }
        return value.trim();
    }

    /**
     * Gets optional parameter from request
     */
    private String getOptionalParameter(HttpServletRequest request, String paramName) {
        String value = request.getParameter(paramName);
        return (value == null || value.trim().isEmpty()) ? null : value.trim();
    }

    /**
     * Gets and validates double parameter from request
     */
    private double getValidatedDoubleParameter(HttpServletRequest request, String paramName) {
        String value = getRequiredParameter(request, paramName);
        try {
            return Double.parseDouble(value);
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException(paramName + " must be a valid number.");
        }
    }

    /**
     * Gets and validates optional double parameter from request
     */
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

    /**
     * Gets and validates discount ID from request
     */
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

    /**
     * Validates and gets filter parameter
     */
    private String getValidatedFilter(String filter) {
        return ("inactive".equals(filter)) ? "inactive" : "active";
    }

    /**
     * Validates and gets page parameter
     */
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

    /**
     * Calculates total pages based on total items
     */
    private int calculateTotalPages(int totalItems) {
        return (int) Math.ceil((double) totalItems / PAGE_SIZE);
    }

    /**
     * Adjusts page number to valid range
     */
    private int adjustPageNumber(int page, int totalPages) {
        return Math.min(page, Math.max(1, totalPages));
    }

    /**
     * Redirects to discount list page
     */
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

    /**
     * Handles errors and forwards to appropriate page
     */
    private void handleError(HttpServletRequest request, HttpServletResponse response, String errorMessage) {
        try {
            request.setAttribute("error", errorMessage);

            // Preserve filter parameters when showing error
            String filter = getValidatedFilter(request.getParameter("currentFilter"));
            int page = getValidatedPage(request.getParameter("currentPage"));
            String type = request.getParameter("currentType");
            String startDate = request.getParameter("currentStartDate");
            String endDate = request.getParameter("currentEndDate");
            String search = request.getParameter("currentSearch");
            LOGGER.info(String.format("Error handling - Filter: %s, Page: %d, Type: %s",
                    filter, page, type));
 
            loadDiscountsData(request, filter, page, type, startDate, endDate, search);
            request.getRequestDispatcher(DISCOUNT_JSP_PATH).forward(request, response);
        } catch (Exception e) {
            LOGGER.severe("Error handling error: " + e.getMessage());
            forwardToNotFound(request, response, "Error handling error");
        }
    }

    // ==================== URL PARAMETER VALIDATION ====================

    /**
     * Validates all URL parameters for security and correctness
     */
    private boolean validateUrlParameters(HttpServletRequest request) {
        try {
            // Validate filter parameter
            String filter = request.getParameter(PARAM_FILTER);
            if (filter != null && !filter.isEmpty() && !filter.matches("^(active|inactive)$")) {
                LOGGER.warning("Invalid filter parameter: " + filter);
                return false;
            }

            // Validate page parameter
            String pageStr = request.getParameter(PARAM_PAGE);
            if (pageStr != null && !pageStr.isEmpty()) {
                try {
                    int page = Integer.parseInt(pageStr);
                    if (page < 1 || page > 1000) { // Reasonable upper limit
                        LOGGER.warning("Invalid page parameter: " + page);
                        return false;
                    }
                } catch (NumberFormatException e) {
                    LOGGER.warning("Invalid page number format: " + pageStr);
                    return false;
                }
            }

            // Validate type parameter
            String type = request.getParameter(PARAM_TYPE);
            if (type != null && !type.isEmpty() && !VALID_DISCOUNT_TYPES.contains(type)) {
                LOGGER.warning("Invalid discount type parameter: " + type);
                return false;
            }

            // Validate date parameters format
            if (!validateDateParameter(request.getParameter(PARAM_START_DATE)) ||
                    !validateDateParameter(request.getParameter(PARAM_END_DATE))) {
                return false;
            }

            // Validate search parameter length
            String search = request.getParameter(PARAM_SEARCH);
            if (search != null && search.length() > 100) {
                LOGGER.warning("Search parameter too long: " + search.length());
                return false;
            }

            return true;
        } catch (Exception e) {
            LOGGER.severe("Error validating URL parameters: " + e.getMessage());
            return false;
        }
    }

    /**
     * Validates date parameter format (YYYY-MM-DD)
     */
    private boolean validateDateParameter(String date) {
        if (date == null || date.isEmpty()) {
            return true; // Optional parameter
        }

        if (!date.matches("^\\d{4}-\\d{2}-\\d{2}$")) {
            LOGGER.warning("Invalid date format: " + date);
            return false;
        }

        try {
            java.time.LocalDate.parse(date);
            return true;
        } catch (Exception e) {
            LOGGER.warning("Invalid date value: " + date);
            return false;
        }
    }

    /**
     * Validates action parameter
     */
    private boolean validateActionParameter(String action) {
        if (action == null) {
            return false;
        }

        return action.matches("^(add|edit|deactivate)$");
    }

    /**
     * Validates page range
     */
    private boolean validatePageRange(int page) {
        return page >= 1 && page <= 1000; // Reasonable upper limit
    }

    /**
     * Forwards to not found page with logging
     */
    private void forwardToNotFound(HttpServletRequest request, HttpServletResponse response, String reason) {
        try {
            LOGGER.warning("Forwarding to not found page. Reason: " + reason);
            request.getRequestDispatcher(NOT_FOUND_PATH).forward(request, response);
        } catch (Exception e) {
            LOGGER.severe("Error forwarding to not found page: " + e.getMessage());
            try {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
            } catch (Exception ex) {
                LOGGER.severe("Error sending 404: " + ex.getMessage());
            }
        }
    }
}