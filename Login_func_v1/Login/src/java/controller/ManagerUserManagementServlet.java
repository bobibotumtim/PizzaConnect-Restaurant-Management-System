package controller;

import dao.UserDAO;
import dao.OrderDAO;
import dao.EmployeeDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;
import java.util.ArrayList;
import java.util.stream.Collectors;
import models.User;
import models.Employee;

@WebServlet(name = "ManagerUserManagementServlet", urlPatterns = {"/manager-users"})
public class ManagerUserManagementServlet extends HttpServlet {

    private static final int USERS_PER_PAGE = 10;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("Login");
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        Employee employee = (Employee) session.getAttribute("employee");
        
        // Check if user is Admin or Manager
        boolean isAuthorized = false;
        if (currentUser.getRole() == 1) {
            isAuthorized = true;
        } else if (currentUser.getRole() == 2 && employee != null) {
            String jobRole = employee.getJobRole();
            System.out.println("[ManagerUserManagement] JobRole from employee: '" + jobRole + "'");
            if (jobRole != null && jobRole.trim().equalsIgnoreCase("Manager")) {
                isAuthorized = true;
            }
        }
        
        if (!isAuthorized) {
            session.setAttribute("error", "Access denied. Manager role required.");
            response.sendRedirect(request.getContextPath() + "/manager-dashboard");
            return;
        }

        UserDAO userDAO = new UserDAO();
        EmployeeDAO employeeDAO = new EmployeeDAO();
        OrderDAO orderDAO = new OrderDAO();

        String roleFilter = request.getParameter("roleFilter");
        if (roleFilter == null || roleFilter.trim().isEmpty()) {
            roleFilter = request.getParameter("role");
        }
        if (roleFilter == null || roleFilter.trim().isEmpty()) {
            roleFilter = "all";
        }

        List<User> allUsers = userDAO.getAllUsers();
        List<User> filteredUsers;

        if ("all".equalsIgnoreCase(roleFilter)) {
            filteredUsers = allUsers;
        } else if ("Manager".equals(roleFilter) || "Cashier".equals(roleFilter) || 
                   "Waiter".equals(roleFilter) || "Chef".equals(roleFilter)) {
            filteredUsers = new ArrayList<>();
            for (User user : allUsers) {
                if (user.getRole() == 2) {
                    Employee emp = employeeDAO.getEmployeeByUserId(user.getUserID());
                    if (emp != null && roleFilter.equals(emp.getEmployeeRole())) {
                        filteredUsers.add(user);
                    }
                }
            }
        } else {
            Integer roleInt = null;
            try {
                roleInt = Integer.parseInt(roleFilter);
            } catch (NumberFormatException ex) {
                String rf = roleFilter.trim().toLowerCase();
                if (rf.startsWith("admin")) {
                    roleInt = 1;
                } else if (rf.startsWith("staff") || rf.startsWith("employee")) {
                    roleInt = 2;
                } else if (rf.startsWith("customer") || rf.startsWith("user")) {
                    roleInt = 3;
                }
            }
            if (roleInt != null) {
                final Integer finalRoleInt = roleInt;
                filteredUsers = allUsers.stream()
                        .filter(u -> u.getRole() == finalRoleInt)
                        .collect(Collectors.toList());
            } else {
                filteredUsers = allUsers;
            }
        }

        int totalOrders = orderDAO.countAllOrders();
        int page = 1;
        String pageParam = request.getParameter("page");
        if (pageParam != null) {
            try {
                page = Integer.parseInt(pageParam);
            } catch (NumberFormatException ignored) {
            }
        }

        int totalUsers = filteredUsers.size();
        int totalPages = Math.max(1, (int) Math.ceil((double) totalUsers / USERS_PER_PAGE));
        if (page < 1) page = 1;
        if (page > totalPages) page = totalPages;

        int start = (page - 1) * USERS_PER_PAGE;
        int end = Math.min(start + USERS_PER_PAGE, totalUsers);
        List<User> paginatedUsers = filteredUsers.subList(start, end);

        request.setAttribute("users", paginatedUsers);
        request.setAttribute("currentUser", currentUser);
        request.setAttribute("totalOrders", totalOrders);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("selectedRole", roleFilter);

        String message = (String) session.getAttribute("message");
        String error = (String) session.getAttribute("error");
        if (message != null) session.removeAttribute("message");
        if (error != null) session.removeAttribute("error");

        request.setAttribute("message", message);
        request.setAttribute("error", error);

        request.getRequestDispatcher("view/Admin.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("Login");
            return;
        }

        User user = (User) session.getAttribute("user");
        Employee employee = (Employee) session.getAttribute("employee");
        
        boolean isAuthorized = false;
        if (user.getRole() == 1) {
            isAuthorized = true;
        } else if (user.getRole() == 2 && employee != null) {
            String jobRole = employee.getJobRole();
            if (jobRole != null && jobRole.trim().equalsIgnoreCase("Manager")) {
                isAuthorized = true;
            }
        }
        
        if (!isAuthorized) {
            session.setAttribute("error", "Access denied. Manager role required.");
            response.sendRedirect(request.getContextPath() + "/manager-dashboard");
            return;
        }

        String action = request.getParameter("action");
        UserDAO userDAO = new UserDAO();

        try {
            if ("delete".equals(action)) {
                String userIdStr = request.getParameter("userId");
                if (userIdStr != null) {
                    int userId = Integer.parseInt(userIdStr);
                    if (userId == user.getUserID()) {
                        session.setAttribute("error", "Cannot delete your own account!");
                    } else {
                        boolean success = userDAO.deleteUser(userId);
                        if (success) {
                            session.setAttribute("message", "✅ User deleted successfully!");
                        } else {
                            session.setAttribute("error", "❌ Failed to delete user!");
                        }
                    }
                }
            } else if ("suspend".equals(action)) {
                String userIdStr = request.getParameter("userId");
                if (userIdStr != null) {
                    int userId = Integer.parseInt(userIdStr);
                    if (userId == user.getUserID()) {
                        session.setAttribute("error", "Cannot suspend your own account!");
                    } else {
                        User targetUser = userDAO.getUserById(userId);
                        if (targetUser != null) {
                            targetUser.setActive(false);
                            boolean success = userDAO.updateUser(targetUser);
                            if (success) {
                                session.setAttribute("message", "User suspended successfully!");
                            } else {
                                session.setAttribute("error", "Failed to suspend user!");
                            }
                        } else {
                            session.setAttribute("error", "User not found!");
                        }
                    }
                }
            } else if ("activate".equals(action)) {
                String userIdStr = request.getParameter("userId");
                if (userIdStr != null) {
                    int userId = Integer.parseInt(userIdStr);
                    User targetUser = userDAO.getUserById(userId);
                    if (targetUser != null) {
                        targetUser.setActive(true);
                        boolean success = userDAO.updateUser(targetUser);
                        if (success) {
                            session.setAttribute("message", "User activated successfully!");
                        } else {
                            session.setAttribute("error", "Failed to activate user!");
                        }
                    } else {
                        session.setAttribute("error", "User not found!");
                    }
                }
            }
        } catch (Exception e) {
            session.setAttribute("error", "Error: " + e.getMessage());
        }

        response.sendRedirect("manager-users");
    }
}
