package controller;

import dao.InventoryMonitorDAO;
import models.InventoryMonitorItem;
import models.User;
import models.Employee;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet(name = "InventoryMonitorServlet", urlPatterns = {"/inventorymonitor"})
public class InventoryMonitorServlet extends HttpServlet {
    
    private InventoryMonitorDAO inventoryMonitorDAO;
    
    @Override
    public void init() throws ServletException {
        super.init();
        inventoryMonitorDAO = new InventoryMonitorDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check if user is logged in
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/view/Login.jsp");
            return;
        }
        
        // Check if user is an Employee with Manager job role
        User currentUser = (User) session.getAttribute("user");
        Employee employee = (Employee) session.getAttribute("employee");
        
        // Must be role 2 (Employee) and have Manager job role
        if (currentUser.getRole() != 2 || employee == null || 
            !"Manager".equalsIgnoreCase(employee.getJobRole())) {
            // If not manager, redirect to login or appropriate dashboard
            if (currentUser.getRole() == 1) {
                response.sendRedirect(request.getContextPath() + "/dashboard");
            } else {
                response.sendRedirect(request.getContextPath() + "/view/Login.jsp");
            }
            return;
        }
        
        // Check if this is an export request
        String action = request.getParameter("action");
        if ("export".equals(action)) {
            handleExport(request, response);
            return;
        }
        
        // Get filter and search parameters
        String level = request.getParameter("level");
        String search = request.getParameter("search");
        
        List<InventoryMonitorItem> items;
        
        // Get items based on parameters
        if (search != null && !search.trim().isEmpty()) {
            if (level != null && !level.isEmpty() && !"ALL".equalsIgnoreCase(level)) {
                // Search with filter
                items = inventoryMonitorDAO.searchItemsWithFilter(search.trim(), level);
            } else {
                // Search only
                items = inventoryMonitorDAO.searchItems(search.trim());
            }
        } else if (level != null && !level.isEmpty() && !"ALL".equalsIgnoreCase(level)) {
            // Filter only
            items = inventoryMonitorDAO.getItemsByWarningLevel(level);
        } else {
            // Get all items
            items = inventoryMonitorDAO.getAllMonitorItems();
        }
        
        // Get warning level counts for statistics
        Map<String, Integer> counts = inventoryMonitorDAO.getWarningLevelCounts();
        
        // Set attributes for JSP
        request.setAttribute("items", items);
        request.setAttribute("counts", counts);
        request.setAttribute("currentLevel", level != null ? level : "ALL");
        request.setAttribute("searchTerm", search != null ? search : "");
        
        // Forward to JSP
        request.getRequestDispatcher("/view/InventoryMonitor.jsp").forward(request, response);
    }

    /**
     * Handle CSV export functionality
     */
    private void handleExport(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Get filter and search parameters
        String level = request.getParameter("level");
        String search = request.getParameter("search");
        
        List<InventoryMonitorItem> items;
        
        // Get items based on parameters (same logic as doGet)
        if (search != null && !search.trim().isEmpty()) {
            if (level != null && !level.isEmpty() && !"ALL".equalsIgnoreCase(level)) {
                items = inventoryMonitorDAO.searchItemsWithFilter(search.trim(), level);
            } else {
                items = inventoryMonitorDAO.searchItems(search.trim());
            }
        } else if (level != null && !level.isEmpty() && !"ALL".equalsIgnoreCase(level)) {
            items = inventoryMonitorDAO.getItemsByWarningLevel(level);
        } else {
            items = inventoryMonitorDAO.getAllMonitorItems();
        }
        
        // Set response headers for CSV download
        response.setContentType("text/csv");
        response.setCharacterEncoding("UTF-8");
        
        // Generate filename with timestamp
        String timestamp = new java.text.SimpleDateFormat("yyyyMMdd_HHmmss").format(new java.util.Date());
        String filename = "inventory_monitor_" + timestamp + ".csv";
        response.setHeader("Content-Disposition", "attachment; filename=\"" + filename + "\"");
        
        // Write CSV header
        response.getWriter().println("ItemName,Quantity,Unit,WarningLevel,Status,LastUpdated");
        
        // Write data rows
        for (InventoryMonitorItem item : items) {
            response.getWriter().printf("%s,%s,%s,%s,%s,%s%n",
                escapeCsv(item.getItemName()),
                item.getQuantity(),
                escapeCsv(item.getUnit()),
                item.getStockLevel(),
                escapeCsv(item.getStatus()),
                item.getLastUpdated()
            );
        }
        
        response.getWriter().flush();
    }
    
    /**
     * Escape CSV values to handle commas and quotes
     */
    private String escapeCsv(String value) {
        if (value == null) {
            return "";
        }
        if (value.contains(",") || value.contains("\"") || value.contains("\n")) {
            return "\"" + value.replace("\"", "\"\"") + "\"";
        }
        return value;
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
