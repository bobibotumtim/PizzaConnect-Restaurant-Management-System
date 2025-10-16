package controller;

import dao.UserDAO;
import dao.OrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;
import models.User;

public class AdminServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Kiem tra session va quyen admin
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("Login");
            return;
        }
        
        User user = (User) session.getAttribute("user");
        if (user.getRole() != 1) { // 1 = admin role
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied. Admin role required.");
            return;
        }
        
        // Lay danh sach tat ca users
        UserDAO userDAO = new UserDAO();
        List<User> allUsers = userDAO.getAllUsers();
        
        // Lay thong ke don hang
        OrderDAO orderDAO = new OrderDAO();
        int totalOrders = orderDAO.countAllOrders();
        
        request.setAttribute("users", allUsers);
        request.setAttribute("currentUser", user);
        request.setAttribute("totalOrders", totalOrders);
        request.getRequestDispatcher("view/Admin.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Kiem tra session va quyen admin
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
        UserDAO userDAO = new UserDAO();
        
        if ("delete".equals(action)) {
            String userIdStr = request.getParameter("userId");
            if (userIdStr != null) {
                try {
                    int userId = Integer.parseInt(userIdStr);
                    if (userId != user.getUserID()) { // Khong cho phep xoa chinh minh
                        userDAO.deleteUser(userId);
                        request.setAttribute("message", "User deleted successfully!");
                    } else {
                        request.setAttribute("error", "Cannot delete your own account!");
                    }
                } catch (NumberFormatException e) {
                    request.setAttribute("error", "Invalid user ID!");
                }
            }
        } else if ("suspend".equals(action)) {
            String userIdStr = request.getParameter("userId");
            if (userIdStr != null) {
                try {
                    int userId = Integer.parseInt(userIdStr);
                    if (userId != user.getUserID()) { // Khong cho phep suspend chinh minh
                        User targetUser = userDAO.getUserById(userId);
                        if (targetUser != null) {
                            targetUser.setActive(false);
                            userDAO.updateUser(targetUser);
                            request.setAttribute("message", "User suspended successfully!");
                        } else {
                            request.setAttribute("error", "User not found!");
                        }
                    } else {
                        request.setAttribute("error", "Cannot suspend your own account!");
                    }
                } catch (NumberFormatException e) {
                    request.setAttribute("error", "Invalid user ID!");
                }
            }
        } else if ("activate".equals(action)) {
            String userIdStr = request.getParameter("userId");
            if (userIdStr != null) {
                try {
                    int userId = Integer.parseInt(userIdStr);
                    User targetUser = userDAO.getUserById(userId);
                    if (targetUser != null) {
                        targetUser.setActive(true);
                        userDAO.updateUser(targetUser);
                        request.setAttribute("message", "User activated successfully!");
                    } else {
                        request.setAttribute("error", "User not found!");
                    }
                } catch (NumberFormatException e) {
                    request.setAttribute("error", "Invalid user ID!");
                }
            }
        }
        
        // Redirect de tranh resubmit
        response.sendRedirect("admin");
    }
}
