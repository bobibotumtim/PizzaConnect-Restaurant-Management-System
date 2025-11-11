package controller;

import dao.InventoryDAO;
import models.Inventory;
import utils.URLUtils;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

public class InventoryServlet extends HttpServlet {
    private InventoryDAO dao = new InventoryDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) action = "list";

        switch (action) {
            case "add":
                request.getRequestDispatcher("view/inventory-form.jsp").forward(request, response);
                break;

            case "edit":
                try {
                    int id = Integer.parseInt(request.getParameter("id"));
                    Inventory inv = dao.getById(id);
                    if (inv != null) {
                        request.setAttribute("inventory", inv);
                        
                        // Preserve search and filter parameters for return navigation
                        String editSearchName = request.getParameter("searchName");
                        String editStatusFilter = request.getParameter("statusFilter");
                        String editPage = request.getParameter("page");
                        String editPageSize = request.getParameter("pageSize");
                        
                        request.setAttribute("returnSearchName", editSearchName);
                        request.setAttribute("returnStatusFilter", editStatusFilter);
                        request.setAttribute("returnPage", editPage);
                        request.setAttribute("returnPageSize", editPageSize);
                        
                        request.getRequestDispatcher("view/inventory-form.jsp").forward(request, response);
                    } else {
                        HttpSession session = request.getSession();
                        session.setAttribute("errorMessage", "Item not found.");
                        response.sendRedirect("manageinventory");
                    }
                } catch (NumberFormatException e) {
                    HttpSession session = request.getSession();
                    session.setAttribute("errorMessage", "Invalid item ID.");
                    response.sendRedirect("manageinventory");
                } catch (Exception e) {
                    e.printStackTrace();
                    HttpSession session = request.getSession();
                    session.setAttribute("errorMessage", "An error occurred while loading item data.");
                    response.sendRedirect("manageinventory");
                }
                break;

            case "toggle":
                try {
                    int id = Integer.parseInt(request.getParameter("id"));
                    
                    // Get current status before toggle for success message
                    Inventory currentItem = dao.getById(id);
                    if (currentItem != null) {
                        dao.toggleStatus(id);
                        
                        HttpSession session = request.getSession();
                        String newStatus = currentItem.getStatus().equals("Active") ? "Inactive" : "Active";
                        session.setAttribute("successMessage", 
                            "Item '" + currentItem.getItemName() + "' status changed to " + newStatus + " successfully.");
                    } else {
                        HttpSession session = request.getSession();
                        session.setAttribute("errorMessage", "Item not found.");
                    }
                } catch (NumberFormatException e) {
                    HttpSession session = request.getSession();
                    session.setAttribute("errorMessage", "Invalid item ID.");
                } catch (Exception e) { 
                    e.printStackTrace();
                    HttpSession session = request.getSession();
                    session.setAttribute("errorMessage", "An error occurred while updating item status.");
                }
                
                // Preserve search and filter parameters in redirect
                String toggleSearchName = request.getParameter("searchName");
                String toggleStatusFilter = request.getParameter("statusFilter");
                String togglePage = request.getParameter("page");
                String togglePageSize = request.getParameter("pageSize");
                
                String redirectUrl = URLUtils.buildInventoryUrl("manageinventory", 
                    toggleSearchName, toggleStatusFilter, togglePage, togglePageSize);
                
                response.sendRedirect(redirectUrl);
                break;

            default: // list with pagination, search and filter
                try {
                    // Get pagination parameters
                    int page = 1;
                    int pageSize = 10; // Default page size
                    
                    // Parse page parameter
                    if (request.getParameter("page") != null) {
                        try {
                            page = Integer.parseInt(request.getParameter("page"));
                            if (page < 1) page = 1;
                        } catch (NumberFormatException e) {
                            page = 1;
                        }
                    }
                    
                    // Parse pageSize parameter
                    if (request.getParameter("pageSize") != null) {
                        try {
                            pageSize = Integer.parseInt(request.getParameter("pageSize"));
                            if (pageSize < 5) pageSize = 5;
                            if (pageSize > 100) pageSize = 100;
                        } catch (NumberFormatException e) {
                            pageSize = 10;
                        }
                    }
                    
                    // Get and normalize search and filter parameters
                    String searchName = URLUtils.normalizeSearchParam(request.getParameter("searchName"));
                    String statusFilter = URLUtils.normalizeStatusFilter(request.getParameter("statusFilter"));
                    
                    // Get total count with filters
                    int totalItems = dao.getTotalInventoryCount(searchName, statusFilter);
                    int totalPages = (int) Math.ceil((double) totalItems / pageSize);
                    if (totalPages == 0) totalPages = 1;
                    
                    // Validate page parameter
                    page = URLUtils.parsePageParam(request.getParameter("page"), totalPages);

                    // Get filtered and paginated results
                    List<Inventory> list = dao.getInventoriesByPage(page, pageSize, searchName, statusFilter);
                    
                    // Calculate pagination info
                    int startItem = (page - 1) * pageSize + 1;
                    int endItem = Math.min(page * pageSize, totalItems);
                    
                    // Set attributes for JSP
                    request.setAttribute("inventoryList", list);
                    request.setAttribute("currentPage", page);
                    request.setAttribute("totalPages", totalPages);
                    request.setAttribute("pageSize", pageSize);
                    request.setAttribute("searchName", searchName != null ? searchName : "");
                    request.setAttribute("statusFilter", statusFilter);
                    request.setAttribute("totalItems", totalItems);
                    request.setAttribute("startItem", startItem);
                    request.setAttribute("endItem", endItem);
                    
                    // Check for success/error messages from session
                    HttpSession session = request.getSession();
                    String successMessage = (String) session.getAttribute("successMessage");
                    String errorMessage = (String) session.getAttribute("errorMessage");
                    
                    if (successMessage != null) {
                        request.setAttribute("successMessage", successMessage);
                        session.removeAttribute("successMessage");
                    }
                    if (errorMessage != null) {
                        request.setAttribute("errorMessage", errorMessage);
                        session.removeAttribute("errorMessage");
                    }
                    
                    request.getRequestDispatcher("view/ManageInventory.jsp").forward(request, response);
                } catch (Exception e) {
                    e.printStackTrace();
                    HttpSession session = request.getSession();
                    session.setAttribute("errorMessage", "An error occurred while loading inventory data. Please try again.");
                    response.sendRedirect("manageinventory");
                }
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Handle save (add/update)
        request.setCharacterEncoding("UTF-8");
        String id = request.getParameter("id");
        String name = request.getParameter("itemName");
        String qtyStr = request.getParameter("quantity");
        String unit = request.getParameter("unit");

        Inventory inv = new Inventory();
        inv.setItemName(name);
        inv.setUnit(unit);

        // Get return navigation parameters
        String returnSearchName = request.getParameter("returnSearchName");
        String returnStatusFilter = request.getParameter("returnStatusFilter");
        String returnPage = request.getParameter("returnPage");
        String returnPageSize = request.getParameter("returnPageSize");
        
        // Basic validation
        if (name == null || name.trim().isEmpty()) {
            request.setAttribute("error", "Item name cannot be empty");
            request.setAttribute("inventory", inv);
            request.setAttribute("returnSearchName", returnSearchName);
            request.setAttribute("returnStatusFilter", returnStatusFilter);
            request.setAttribute("returnPage", returnPage);
            request.setAttribute("returnPageSize", returnPageSize);
            request.getRequestDispatcher("view/inventory-form.jsp").forward(request, response);
            return;
        }
        
        if (unit == null || unit.trim().isEmpty()) {
            request.setAttribute("error", "Unit cannot be empty");
            request.setAttribute("inventory", inv);
            request.setAttribute("returnSearchName", returnSearchName);
            request.setAttribute("returnStatusFilter", returnStatusFilter);
            request.setAttribute("returnPage", returnPage);
            request.setAttribute("returnPageSize", returnPageSize);
            request.getRequestDispatcher("view/inventory-form.jsp").forward(request, response);
            return;
        }
        
        double qty = 0;
        try {
            qty = Double.parseDouble(qtyStr);
            if (qty < 0) throw new NumberFormatException();
            inv.setQuantity(qty);
        } catch (NumberFormatException ex) {
            request.setAttribute("error", "Quantity must be a non-negative number");
            request.setAttribute("inventory", inv);
            request.setAttribute("returnSearchName", returnSearchName);
            request.setAttribute("returnStatusFilter", returnStatusFilter);
            request.setAttribute("returnPage", returnPage);
            request.setAttribute("returnPageSize", returnPageSize);
            request.getRequestDispatcher("view/inventory-form.jsp").forward(request, response);
            return;
        }

        // Check for duplicate name (case insensitive)
        try {
            Integer excludeId = (id != null && !id.isEmpty()) ? Integer.parseInt(id) : null;
            boolean nameExists = dao.isNameExists(name.trim(), excludeId);

            if (nameExists) {
                request.setAttribute("error", "Item name already exists!");
                request.setAttribute("inventory", inv);
                request.setAttribute("returnSearchName", returnSearchName);
                request.setAttribute("returnStatusFilter", returnStatusFilter);
                request.setAttribute("returnPage", returnPage);
                request.setAttribute("returnPageSize", returnPageSize);
                request.getRequestDispatcher("view/inventory-form.jsp").forward(request, response);
                return;
            }
        } catch (Exception e) { 
            e.printStackTrace();
            request.setAttribute("error", "Error checking item name uniqueness");
            request.setAttribute("inventory", inv);
            request.setAttribute("returnSearchName", returnSearchName);
            request.setAttribute("returnStatusFilter", returnStatusFilter);
            request.setAttribute("returnPage", returnPage);
            request.setAttribute("returnPageSize", returnPageSize);
            request.getRequestDispatcher("view/inventory-form.jsp").forward(request, response);
            return;
        }

        try {
            HttpSession session = request.getSession();
            if (id == null || id.isEmpty()) {
                dao.insert(inv);
                session.setAttribute("successMessage", "Item '" + inv.getItemName() + "' added successfully.");
            } else {
                inv.setInventoryID(Integer.parseInt(id));
                dao.update(inv);
                session.setAttribute("successMessage", "Item '" + inv.getItemName() + "' updated successfully.");
            }
            
            // Build redirect URL with preserved parameters
            String redirectUrl = URLUtils.buildInventoryUrl("manageinventory", 
                returnSearchName, returnStatusFilter, returnPage, returnPageSize);
            
            response.sendRedirect(redirectUrl);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "An error occurred while saving the item. Please try again.");
            request.setAttribute("inventory", inv);
            request.setAttribute("returnSearchName", returnSearchName);
            request.setAttribute("returnStatusFilter", returnStatusFilter);
            request.setAttribute("returnPage", returnPage);
            request.setAttribute("returnPageSize", returnPageSize);
            request.getRequestDispatcher("view/inventory-form.jsp").forward(request, response);
        }
    }
}
