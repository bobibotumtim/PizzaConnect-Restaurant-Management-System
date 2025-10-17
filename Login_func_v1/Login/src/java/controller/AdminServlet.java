package controller;

import dao.UserDAO;
import dao.OrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;
import models.User;

public class AdminServlet extends HttpServlet {

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
        if (currentUser.getRole() != 1) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied. Admin role required.");
            return;
        }

        UserDAO userDAO = new UserDAO();
        List<User> allUsers = userDAO.getAllUsers();
        OrderDAO orderDAO = new OrderDAO();
        int totalOrders = orderDAO.countAllOrders();

        // Lấy số trang hiện tại (nếu không có thì mặc định = 1)
        int page = 1;
        String pageParam = request.getParameter("page");
        if (pageParam != null) {
            try {
                page = Integer.parseInt(pageParam);
            } catch (NumberFormatException ignored) {
            }
        }

        // Tính toán phân trang
        int totalUsers = allUsers.size();
        int totalPages = (int) Math.ceil((double) totalUsers / USERS_PER_PAGE);
        int start = (page - 1) * USERS_PER_PAGE;
        int end = Math.min(start + USERS_PER_PAGE, totalUsers);
        List<User> paginatedUsers = allUsers.subList(start, end);

        // Gửi dữ liệu sang JSP
        request.setAttribute("users", paginatedUsers);
        request.setAttribute("currentUser", currentUser);
        request.setAttribute("totalOrders", totalOrders);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);

        String message = (String) session.getAttribute("message");
        String error = (String) session.getAttribute("error");
        if (message != null) {
            session.removeAttribute("message");
        }
        if (error != null) {
            session.removeAttribute("error");
        }
        request.setAttribute("message", message);
        request.setAttribute("error", error);

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

        try {
            if ("delete".equals(action)) {
                String userIdStr = request.getParameter("userId");
                if (userIdStr != null) {
                    int userId = Integer.parseInt(userIdStr);
                    if (userId == user.getUserID()) {
                        session.setAttribute("error", "Cannot delete your own account!");
                    } else {
                        System.out.println("[AdminServlet] Attempting to delete userID: " + userId);
                        boolean success = userDAO.deleteUser(userId);
                        if (success) {
                            session.setAttribute("message", "✅ User deleted successfully!");
                        } else {
                            session.setAttribute("error", "❌ Failed to delete user! Check database constraints.");
                        }
                    }
                }
                 << << << < HEAD
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

        } catch (NumberFormatException e) {
            session.setAttribute("error", "Invalid user ID!");
        } catch (Exception e) {
            session.setAttribute("error", "Unexpected error: " + e.getMessage());
            e.printStackTrace();
             == == == =
        }
         >>> >>> > 73b2b6d9061dc304e377c544d92ff76bbbcb78d7
    }

    // Redirect để tránh submit lại form
    response.sendRedirect (

"admin");
    }
}
