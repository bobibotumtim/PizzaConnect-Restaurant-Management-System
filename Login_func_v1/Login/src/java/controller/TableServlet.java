package controller;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import models.Table;
import models.User;
import dao.TableDAO;
import java.util.List;
import java.util.Arrays;
import java.util.Collections;
import java.util.Set;
import java.util.HashSet;
import java.util.logging.Logger;

@WebServlet(name = "TableServlet", urlPatterns = { "/table" })
public class TableServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(TableServlet.class.getName());
    private TableDAO tableDAO = new TableDAO();

    // Constants
    private static final String TABLE_JSP_PATH = "/view/Table.jsp";
    private static final String NOT_FOUND_PATH = "/view/NotFound.jsp";
    private static final String LOGIN_PATH = "Login";

    // Parameter names
    private static final String PARAM_FILTER = "filter";
    private static final String PARAM_ACTION = "action";
    private static final String PARAM_CURRENT_FILTER = "currentFilter";

    // Action names
    private static final String ACTION_INSERT = "insert";
    private static final String ACTION_UPDATE = "update";
    private static final String ACTION_DELETE = "delete";
    private static final String ACTION_RESTORE = "restore";

    // Filter values
    private static final String FILTER_ACTIVE = "active";
    private static final String FILTER_INACTIVE = "inactive";

    // Valid parameters sets
    private static final Set<String> VALID_ACTIONS = Collections.unmodifiableSet(new HashSet<>(Arrays.asList(
            ACTION_INSERT,
            ACTION_UPDATE,
            ACTION_DELETE,
            ACTION_RESTORE)));

    private static final Set<String> VALID_FILTERS = Collections.unmodifiableSet(new HashSet<>(Arrays.asList(
            FILTER_ACTIVE,
            FILTER_INACTIVE)));

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) {
        try {
            if (!isAuthenticated(request, response))
                return;

            // Validate URL parameters before processing
            if (!validateGetParameters(request)) {
                forwardToNotFound(request, response, "Invalid URL parameters in GET request");
                return;
            }

            String filter = getValidatedFilter(request.getParameter(PARAM_FILTER));

            LOGGER.info(String.format("Loading tables - Filter: %s", filter));
            loadTablesData(request, filter);
            request.getRequestDispatcher(TABLE_JSP_PATH).forward(request, response);

        } catch (Exception e) {
            LOGGER.severe("Error fetching tables: " + e.getMessage());
            forwardToNotFound(request, response, "Failed to load tables: " + e.getMessage());
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) {
        try {
            if (!isAuthenticated(request, response))
                return;

            // Validate URL parameters before processing
            if (!validatePostParameters(request)) {
                forwardToNotFound(request, response, "Invalid URL parameters in POST request");
                return;
            }

            String action = request.getParameter(PARAM_ACTION);
            String currentFilter = getValidatedFilter(request.getParameter(PARAM_CURRENT_FILTER));

            LOGGER.info(String.format("POST Action: %s, Filter: %s", action, currentFilter));
            processAction(request, action);

            // Redirect based on action result
            if (ACTION_RESTORE.equals(action)) {
                // After restore, redirect to active tables
                response.sendRedirect("table?filter=active");
            } else {
                redirectToTableList(response, currentFilter);
            }

        } catch (IllegalArgumentException e) {
            LOGGER.warning("Validation error: " + e.getMessage());
            handleError(request, response, e.getMessage());
        } catch (Exception e) {
            LOGGER.severe("Operation failed: " + e.getMessage());
            forwardToNotFound(request, response, "Operation failed: " + e.getMessage());
        }
    }

    /**
     * Validate GET request parameters
     */
    private boolean validateGetParameters(HttpServletRequest request) {
        try {
            // Validate filter parameter
            String filter = request.getParameter(PARAM_FILTER);
            if (filter != null && !filter.isEmpty() && !VALID_FILTERS.contains(filter)) {
                LOGGER.warning("Invalid filter parameter: " + filter);
                return false;
            }

            // Check for unexpected parameters in GET request
            return validateNoUnexpectedParameters(request, Arrays.asList(PARAM_FILTER));

        } catch (Exception e) {
            LOGGER.severe("Error validating GET parameters: " + e.getMessage());
            return false;
        }
    }

    /**
     * Validate POST request parameters
     */
    private boolean validatePostParameters(HttpServletRequest request) {
        try {
            // Validate action parameter
            String action = request.getParameter(PARAM_ACTION);
            if (action == null || !VALID_ACTIONS.contains(action)) {
                LOGGER.warning("Invalid action parameter: " + action);
                return false;
            }

            // Validate filter parameter
            String filter = request.getParameter(PARAM_CURRENT_FILTER);
            if (filter != null && !filter.isEmpty() && !VALID_FILTERS.contains(filter)) {
                LOGGER.warning("Invalid current filter parameter: " + filter);
                return false;
            }

            // Validate table ID parameters based on action
            if (!validateTableIdParameters(request, action)) {
                return false;
            }

            // Check for unexpected parameters in POST request
            return validateNoUnexpectedParameters(request,
                    Arrays.asList(PARAM_ACTION, PARAM_CURRENT_FILTER, "tableID", "id", "tableNumber", "capacity"));

        } catch (Exception e) {
            LOGGER.severe("Error validating POST parameters: " + e.getMessage());
            return false;
        }
    }

    /**
     * Validate table ID parameters based on action
     */
    private boolean validateTableIdParameters(HttpServletRequest request, String action) {
        try {
            switch (action) {
                case ACTION_UPDATE:
                case ACTION_RESTORE:
                    String tableId = request.getParameter("tableID");
                    if (tableId == null || tableId.trim().isEmpty()) {
                        LOGGER.warning("Table ID is required for action: " + action);
                        return false;
                    }
                    if (!tableId.matches("^\\d+$")) {
                        LOGGER.warning("Invalid table ID format: " + tableId);
                        return false;
                    }
                    break;

                case ACTION_DELETE:
                    String deleteId = request.getParameter("id");
                    if (deleteId == null || deleteId.trim().isEmpty()) {
                        LOGGER.warning("Table ID is required for delete action");
                        return false;
                    }
                    if (!deleteId.matches("^\\d+$")) {
                        LOGGER.warning("Invalid table ID format for delete: " + deleteId);
                        return false;
                    }
                    break;

                case ACTION_INSERT:
                    // No table ID required for insert
                    break;

                default:
                    LOGGER.warning("Unknown action: " + action);
                    return false;
            }
            return true;
        } catch (Exception e) {
            LOGGER.severe("Error validating table ID parameters: " + e.getMessage());
            return false;
        }
    }

    /**
     * Check for unexpected parameters in request
     */
    private boolean validateNoUnexpectedParameters(HttpServletRequest request, List<String> expectedParams) {
        try {
            java.util.Enumeration<String> paramNames = request.getParameterNames();
            while (paramNames.hasMoreElements()) {
                String paramName = paramNames.nextElement();
                if (!expectedParams.contains(paramName)) {
                    // Check if it's a potential attack parameter
                    if (isPotentialAttackParameter(paramName, request.getParameter(paramName))) {
                        LOGGER.warning("Potential attack parameter detected: " + paramName);
                        return false;
                    }
                }
            }
            return true;
        } catch (Exception e) {
            LOGGER.severe("Error checking unexpected parameters: " + e.getMessage());
            return false;
        }
    }

    /**
     * Check for potential attack parameters
     */
    private boolean isPotentialAttackParameter(String paramName, String paramValue) {
        if (paramName == null || paramValue == null) {
            return false;
        }

        // Check for SQL injection patterns
        if (paramValue.matches(".*([';]+|(--)+).*")) {
            LOGGER.warning("SQL injection pattern detected in parameter: " + paramName);
            return true;
        }

        // Check for XSS patterns
        if (paramValue.matches(".*[<>].*")) {
            LOGGER.warning("XSS pattern detected in parameter: " + paramName);
            return true;
        }

        // Check for path traversal patterns
        if (paramValue.matches(".*(\\.\\./|\\.\\\\.*).*")) {
            LOGGER.warning("Path traversal pattern detected in parameter: " + paramName);
            return true;
        }

        // Check parameter name for suspicious patterns
        if (paramName.matches(".*(script|iframe|object|embed|form).*")) {
            LOGGER.warning("Suspicious parameter name detected: " + paramName);
            return true;
        }

        return false;
    }

    /**
     * Forward to not found page with logging
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

    private void loadTablesData(HttpServletRequest request, String filter) {
        List<Table> tables = getTablesByFilter(filter);
        List<Table> allTables = tableDAO.getAllTables();

        // Calculate statistics
        long activeTables = allTables.stream()
                .filter(Table::isActive)
                .count();
        long inactiveTables = allTables.size() - activeTables;

        LOGGER.info(String.format("Filter: %s - Active: %d, Inactive: %d, Filtered: %d",
                filter, activeTables, inactiveTables, tables.size()));

        setRequestAttributes(request, tables, activeTables, inactiveTables, filter);
    }

    private List<Table> getTablesByFilter(String filter) {
        switch (filter) {
            case FILTER_ACTIVE:
                return tableDAO.getActiveTables();
            case FILTER_INACTIVE:
                return tableDAO.getInactiveTables();
            default:
                return tableDAO.getActiveTables(); // Default to active
        }
    }

    private void setRequestAttributes(HttpServletRequest request, List<Table> tables,
            long activeTables, long inactiveTables, String filter) {
        request.setAttribute("tables", tables);
        request.setAttribute("activeTables", activeTables);
        request.setAttribute("inactiveTables", inactiveTables);
    }

    private void processAction(HttpServletRequest request, String action) {
        switch (action) {
            case ACTION_INSERT:
                handleInsertTable(request);
                break;
            case ACTION_UPDATE:
                handleUpdateTable(request);
                break;
            case ACTION_DELETE:
                handleDeleteTable(request); // Updated to use scheduled deletion
                break;
            case ACTION_RESTORE:
                handleRestoreTable(request);
                break;
            default:
                throw new IllegalArgumentException("Invalid action: " + action);
        }
    }

    private void handleInsertTable(HttpServletRequest request) {
        Table table = extractTableFromRequest(request);
        validateTableForInsert(table);

        LOGGER.info("Attempting to add table: " + table.getTableNumber());
        if (!tableDAO.addTable(table)) {
            throw new IllegalArgumentException("Failed to add table. Please check the input values.");
        }
        LOGGER.info("Table added successfully: " + table.getTableNumber());
    }

    private void handleUpdateTable(HttpServletRequest request) {
        Table table = extractTableFromRequest(request);
        table.setTableID(getValidatedTableId(request.getParameter("tableID")));
        validateTableForUpdate(table);

        LOGGER.info("Attempting to update table ID: " + table.getTableID());
        if (!tableDAO.updateTable(table)) {
            throw new IllegalArgumentException("Failed to update table. Please check the input values.");
        }
        LOGGER.info("Table updated successfully: ID " + table.getTableID());
    }

    private void handleDeleteTable(HttpServletRequest request) {
        int tableId = getValidatedTableId(request.getParameter("id"));

        LOGGER.info("Attempting to schedule deletion for table ID: " + tableId);

        // Check if table already has scheduled deletion
        if (tableDAO.isScheduledForDeletion(tableId)) {
            throw new IllegalArgumentException("Table is already scheduled for deletion.");
        }

        // Use scheduled deletion instead of immediate delete
        if (!tableDAO.scheduleTableDeletion(tableId)) {
            throw new IllegalArgumentException("Failed to schedule table deletion.");
        }

        LOGGER.info("Table deletion scheduled successfully: ID " + tableId);

        // Set success message
        request.getSession().setAttribute("message",
                "Table deletion scheduled. It will be deactivated at the end of the day.");
    }

    private void handleRestoreTable(HttpServletRequest request) {
        int tableId = getValidatedTableId(request.getParameter("tableID"));

        LOGGER.info("Attempting to restore table ID: " + tableId);
        Table table = tableDAO.getTableById(tableId);
        if (table == null) {
            throw new IllegalArgumentException("Table not found.");
        }

        // Set table to active
        table.setActive(true);
        if (!tableDAO.updateTable(table)) {
            throw new IllegalArgumentException("Failed to restore table.");
        }
        LOGGER.info("Table restored successfully: ID " + tableId);
    }

    private Table extractTableFromRequest(HttpServletRequest request) {
        Table table = new Table();

        // For insert, tableID is not provided
        String tableIdParam = request.getParameter("tableID");
        if (tableIdParam != null && !tableIdParam.trim().isEmpty()) {
            table.setTableID(Integer.parseInt(tableIdParam));
        }

        table.setTableNumber(getRequiredParameter(request, "tableNumber"));
        table.setCapacity(getValidatedIntegerParameter(request, "capacity"));

        // For insert and restore, set active to true
        String action = request.getParameter(PARAM_ACTION);
        if (ACTION_INSERT.equals(action) || ACTION_RESTORE.equals(action)) {
            table.setActive(true);
        } else if (ACTION_UPDATE.equals(action)) {
            // For update, keep the current active status
            Table existingTable = tableDAO.getTableById(table.getTableID());
            if (existingTable != null) {
                table.setActive(existingTable.isActive());
            }
        }

        return table;
    }

    // Validation methods
    private void validateTableForInsert(Table table) {
        validateTableValues(table);

        // Check if table number already exists
        if (tableDAO.getTableByNumber(table.getTableNumber()) != null) {
            throw new IllegalArgumentException("Table number '" + table.getTableNumber() + "' already exists.");
        }
    }

    private void validateTableForUpdate(Table table) {
        validateTableValues(table);

        // Check if table number already exists (excluding current table)
        Table existingTable = tableDAO.getTableByNumber(table.getTableNumber());
        if (existingTable != null && existingTable.getTableID() != table.getTableID()) {
            throw new IllegalArgumentException("Table number '" + table.getTableNumber() + "' already exists.");
        }
    }

    private void validateTableValues(Table table) {
        validateTableNumber(table.getTableNumber());
        validateCapacity(table.getCapacity());
    }

    private void validateTableNumber(String tableNumber) {
        if (tableNumber == null || tableNumber.trim().isEmpty()) {
            throw new IllegalArgumentException("Table number is required.");
        }
        if (!tableNumber.matches("^[A-Za-z0-9\\-]+$")) {
            throw new IllegalArgumentException("Table number can only contain letters, numbers, and hyphens.");
        }
        if (tableNumber.length() > 10) {
            throw new IllegalArgumentException("Table number cannot exceed 10 characters.");
        }
    }

    private void validateCapacity(int capacity) {
        if (capacity < 2) {
            throw new IllegalArgumentException("Capacity must be at least 2.");
        }
        if (capacity > 12) {
            throw new IllegalArgumentException("Capacity cannot exceed 12.");
        }
    }

    // Utility methods
    private boolean isAuthenticated(HttpServletRequest request, HttpServletResponse response) {
        try {
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("user") == null) {
                response.sendRedirect(LOGIN_PATH);
                return false;
            }

            User user = (User) session.getAttribute("user");
            // Allow both admin and employee to access table management
            if (user.getRole() != 1 && user.getRole() != 2) {
                // Forward to not-found page for non-authorized users
                forwardToNotFound(request, response, "User is not authorized for table management");
                return false;
            }
            return true;
        } catch (Exception e) {
            LOGGER.severe("Authentication error: " + e.getMessage());
            forwardToNotFound(request, response, "Authentication error");
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

    private int getValidatedIntegerParameter(HttpServletRequest request, String paramName) {
        String value = getRequiredParameter(request, paramName);
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException(paramName + " must be a valid number.");
        }
    }

    private int getValidatedTableId(String tableIdStr) {
        if (tableIdStr == null || tableIdStr.trim().isEmpty()) {
            throw new IllegalArgumentException("Table ID is required.");
        }
        try {
            int tableId = Integer.parseInt(tableIdStr);
            if (tableId <= 0) {
                throw new IllegalArgumentException("Invalid table ID.");
            }
            return tableId;
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("Invalid table ID format.");
        }
    }

    private String getValidatedFilter(String filter) {
        if (FILTER_INACTIVE.equals(filter)) {
            return FILTER_INACTIVE;
        } else {
            return FILTER_ACTIVE;
        }
    }

    private void redirectToTableList(HttpServletResponse response, String filter) {
        try {
            String redirectUrl = "table";
            if (filter != null && !filter.isEmpty()) {
                redirectUrl += "?filter=" + filter;
            }
            response.sendRedirect(redirectUrl);
        } catch (Exception e) {
            LOGGER.severe("Error redirecting: " + e.getMessage());
        }
    }

    private void handleError(HttpServletRequest request, HttpServletResponse response, String errorMessage) {
        try {
            request.getSession().setAttribute("error", errorMessage);

            // Reload table data for the current filter
            String filter = getValidatedFilter(request.getParameter(PARAM_CURRENT_FILTER));
            loadTablesData(request, filter);
            request.getRequestDispatcher(TABLE_JSP_PATH).forward(request, response);
        } catch (Exception e) {
            LOGGER.severe("Error handling error: " + e.getMessage());
            forwardToNotFound(request, response, "Error handling error");
        }
    }
}