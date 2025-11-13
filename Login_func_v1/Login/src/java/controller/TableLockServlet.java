package controller;

import dao.TableDAO;
import models.Employee;
import models.User;
import models.Table;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "TableLockServlet", urlPatterns = {"/table-lock"})
public class TableLockServlet extends HttpServlet {

    private TableDAO tableDAO = new TableDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect("view/Login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");
        Employee employee = (Employee) session.getAttribute("employee");

        // Only waiter can lock/unlock tables
        if (user == null || user.getRole() != 2 || employee == null) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Only waiters can lock/unlock tables");
            return;
        }

        String action = request.getParameter("action");
        String tableIdStr = request.getParameter("tableId");

        if (tableIdStr == null || tableIdStr.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Table ID is required");
            return;
        }

        int tableId = Integer.parseInt(tableIdStr);
        boolean success = false;
        String message = "";

        try {
            if ("lock".equals(action)) {
                // Lock table
                String reason = request.getParameter("reason");
                if (reason == null || reason.trim().isEmpty()) {
                    reason = "Table temporarily locked";
                }

                success = tableDAO.lockTable(tableId, reason, employee.getEmployeeID());
                
                if (success) {
                    message = "✅ Table locked successfully!";
                    System.out.println("🔒 Table " + tableId + " locked by " + user.getName() + " - Reason: " + reason);
                } else {
                    message = "❌ Failed to lock table!";
                }

            } else if ("unlock".equals(action)) {
                // Unlock table
                success = tableDAO.unlockTable(tableId);
                
                if (success) {
                    message = "✅ Table unlocked successfully!";
                    System.out.println("🔓 Table " + tableId + " unlocked by " + user.getName());
                } else {
                    message = "❌ Failed to unlock table!";
                }

            } else {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action");
                return;
            }

            // Set message and redirect back
            session.setAttribute("lockMessage", message);
            session.setAttribute("lockSuccess", success);
            
            // Redirect back to assign-table page
            response.sendRedirect(request.getContextPath() + "/assign-table");

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("lockMessage", "❌ Error: " + e.getMessage());
            session.setAttribute("lockSuccess", false);
            response.sendRedirect(request.getContextPath() + "/assign-table");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Redirect GET requests to POST
        response.sendRedirect(request.getContextPath() + "/assign-table");
    }
}
