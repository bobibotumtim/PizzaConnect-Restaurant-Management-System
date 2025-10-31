package controller;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import models.User;

@WebServlet(name = "EditUserServlet", urlPatterns = {"/edituser"})
public class EditUserServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Kiểm tra session và quyền admin
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("Login");
            return;
        }
        
        User currentUser = (User) session.getAttribute("user");
        if (currentUser.getRole() != 1) { // 1 = admin role
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied. Admin role required.");
            return;
        }
        
        // Lấy userId từ parameter
        String userIdStr = request.getParameter("id");
        if (userIdStr == null || userIdStr.trim().isEmpty()) {
            response.sendRedirect("admin");
            return;
        }

        try {
            int userId = Integer.parseInt(userIdStr);
            UserDAO userDAO = new UserDAO();
            User editUser = userDAO.getUserById(userId);
            
            if (editUser == null) {
                request.setAttribute("error", "User not found!");
                response.sendRedirect("admin");
                return;
            }
            
            request.setAttribute("currentUser", currentUser);
            request.setAttribute("editUser", editUser);
            request.getRequestDispatcher("/view/EditUser.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            response.sendRedirect("admin");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Kiểm tra session và quyền admin
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
        
        // Lấy thông tin từ form
        String userIdStr = request.getParameter("userId");
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String roleStr = request.getParameter("role");
        String dateOfBirthStr = request.getParameter("dateOfBirth");
        String gender = request.getParameter("gender");
        String isActiveStr = request.getParameter("isActive");
        
        // Validation
        if (userIdStr == null || userIdStr.trim().isEmpty()) {
            response.sendRedirect("admin");
            return;
        }
        
        if (name == null || name.trim().isEmpty()) {
            request.setAttribute("error", "Name is required!");
            request.setAttribute("currentUser", currentUser);
            // Reload user data
            try {
                int userId = Integer.parseInt(userIdStr);
                UserDAO userDAO = new UserDAO();
                User editUser = userDAO.getUserById(userId);
                request.setAttribute("editUser", editUser);
            } catch (NumberFormatException e) {
                response.sendRedirect("admin");
                return;
            }
            request.getRequestDispatcher("/view/EditUser.jsp").forward(request, response);
            return;
        }
        
        if (email == null || email.trim().isEmpty()) {
            request.setAttribute("error", "Email is required!");
            request.setAttribute("currentUser", currentUser);
            // Reload user data
            try {
                int userId = Integer.parseInt(userIdStr);
                UserDAO userDAO = new UserDAO();
                User editUser = userDAO.getUserById(userId);
                request.setAttribute("editUser", editUser);
            } catch (NumberFormatException e) {
                response.sendRedirect("admin");
                return;
            }
            request.getRequestDispatcher("/view/EditUser.jsp").forward(request, response);
            return;
        }
        
        if (phone == null || phone.trim().isEmpty()) {
            request.setAttribute("error", "Phone number is required!");
            request.setAttribute("currentUser", currentUser);
            // Reload user data
            try {
                int userId = Integer.parseInt(userIdStr);
                UserDAO userDAO = new UserDAO();
                User editUser = userDAO.getUserById(userId);
                request.setAttribute("editUser", editUser);
            } catch (NumberFormatException e) {
                response.sendRedirect("admin");
                return;
            }
            request.getRequestDispatcher("/view/EditUser.jsp").forward(request, response);
            return;
        }
        
        if (roleStr == null || roleStr.trim().isEmpty()) {
            request.setAttribute("error", "User role is required!");
            request.setAttribute("currentUser", currentUser);
            // Reload user data
            try {
                int userId = Integer.parseInt(userIdStr);
                UserDAO userDAO = new UserDAO();
                User editUser = userDAO.getUserById(userId);
                request.setAttribute("editUser", editUser);
            } catch (NumberFormatException e) {
                response.sendRedirect("admin");
                return;
            }
            request.getRequestDispatcher("/view/EditUser.jsp").forward(request, response);
            return;
        }
        
        // Password validation (only if password is provided)
        if (password != null && !password.trim().isEmpty()) {
            if (password.length() < 6) {
                request.setAttribute("error", "Password must be at least 6 characters long!");
                request.setAttribute("currentUser", currentUser);
                // Reload user data
                try {
                    int userId = Integer.parseInt(userIdStr);
                    UserDAO userDAO = new UserDAO();
                    User editUser = userDAO.getUserById(userId);
                    request.setAttribute("editUser", editUser);
                } catch (NumberFormatException e) {
                    response.sendRedirect("admin");
                    return;
                }
                request.getRequestDispatcher("/view/EditUser.jsp").forward(request, response);
                return;
            }
            
            if (!password.equals(confirmPassword)) {
                request.setAttribute("error", "Passwords do not match!");
                request.setAttribute("currentUser", currentUser);
                // Reload user data
                try {
                    int userId = Integer.parseInt(userIdStr);
                    UserDAO userDAO = new UserDAO();
                    User editUser = userDAO.getUserById(userId);
                    request.setAttribute("editUser", editUser);
                } catch (NumberFormatException e) {
                    response.sendRedirect("admin");
                    return;
                }
                request.getRequestDispatcher("/view/EditUser.jsp").forward(request, response);
                return;
            }
        }
        
        try {
            int userId = Integer.parseInt(userIdStr);
            int role = Integer.parseInt(roleStr);
            boolean isActive = "true".equals(isActiveStr);
            
            if (role < 1 || role > 3) {
                request.setAttribute("error", "Invalid role selected!");
                request.setAttribute("currentUser", currentUser);
                // Reload user data
                UserDAO userDAO = new UserDAO();
                User editUser = userDAO.getUserById(userId);
                request.setAttribute("editUser", editUser);
                request.getRequestDispatcher("/view/EditUser.jsp").forward(request, response);
                return;
            }
            
            // Kiểm tra email đã tồn tại chưa (trừ user hiện tại)
            UserDAO userDAO = new UserDAO();
            User existingUser = userDAO.getUserById(userId);
            if (existingUser == null) {
                response.sendRedirect("admin");
                return;
            }
            
            // Kiểm tra email có bị trùng với user khác không
            if (!existingUser.getEmail().equals(email.trim())) {
                if (userDAO.isUserExists(email.trim())) {
                    request.setAttribute("error", "Email already exists! Please use a different email.");
                    request.setAttribute("currentUser", currentUser);
                    request.setAttribute("editUser", existingUser);
                    request.getRequestDispatcher("/view/EditUser.jsp").forward(request, response);
                    return;
                }
            }
            
            // Parse date of birth
            Date dateOfBirth = null;
            if (dateOfBirthStr != null && !dateOfBirthStr.trim().isEmpty()) {
                try {
                    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                    dateOfBirth = sdf.parse(dateOfBirthStr);
                } catch (ParseException e) {
                    request.setAttribute("error", "Invalid date format!");
                    request.setAttribute("currentUser", currentUser);
                    request.setAttribute("editUser", existingUser);
                    request.getRequestDispatcher("/view/EditUser.jsp").forward(request, response);
                    return;
                }
            }
            
            // Cập nhật thông tin user
            existingUser.setName(name.trim());
            existingUser.setEmail(email.trim());
            existingUser.setPhone(phone.trim());
            existingUser.setRole(role);
            existingUser.setDateOfBirth(dateOfBirth);
            existingUser.setGender(gender != null && !gender.trim().isEmpty() ? gender.trim() : null);
            existingUser.setActive(isActive);
            
            // Cập nhật password nếu có
            if (password != null && !password.trim().isEmpty()) {
                existingUser.setPassword(password);
            }
            
            // Cập nhật user trong database
            boolean success = userDAO.updateUser(existingUser);
            
            if (success) {
                request.setAttribute("message", "User updated successfully!");
                request.setAttribute("currentUser", currentUser);
                request.setAttribute("editUser", existingUser);
                request.getRequestDispatcher("/view/EditUser.jsp").forward(request, response);
            } else {
                request.setAttribute("error", "Failed to update user. Please try again.");
                request.setAttribute("currentUser", currentUser);
                request.setAttribute("editUser", existingUser);
                request.getRequestDispatcher("/view/EditUser.jsp").forward(request, response);
            }
            
        } catch (NumberFormatException e) {
            response.sendRedirect("admin");
        }
    }
}