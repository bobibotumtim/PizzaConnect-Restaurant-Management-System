package controller;

import dao.UserDAO;
import dao.EmployeeDAO;
import dao.CustomerDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import models.User;
import models.Employee;
import models.Customer;

@WebServlet(name = "EditUserServlet", urlPatterns = { "/edituser" })
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
        String employeeRole = request.getParameter("employeeRole");
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
                // Xử lý Employee/Customer records
                EmployeeDAO employeeDAO = new EmployeeDAO();
                CustomerDAO customerDAO = new CustomerDAO();

                // Nếu role thay đổi, cần xóa record cũ và tạo mới
                int oldRole = userDAO.getUserById(userId).getRole();

                if (role == 2) { // Employee
                    if (employeeRole == null || employeeRole.trim().isEmpty()) {
                        request.setAttribute("error", "Employee role is required for Employee users!");
                        request.setAttribute("currentUser", currentUser);
                        request.setAttribute("editUser", existingUser);
                        request.getRequestDispatcher("/view/EditUser.jsp").forward(request, response);
                        return;
                    }

                    // Validate employee role
                    if (!employeeRole.equals("Manager") && !employeeRole.equals("Cashier") &&
                            !employeeRole.equals("Waiter") && !employeeRole.equals("Chef")) {
                        request.setAttribute("error", "Invalid employee role selected!");
                        request.setAttribute("currentUser", currentUser);
                        request.setAttribute("editUser", existingUser);
                        request.getRequestDispatcher("/view/EditUser.jsp").forward(request, response);
                        return;
                    }

                    // Nếu role cũ là Customer, xóa customer record
                    if (oldRole == 3) {
                        customerDAO.deleteCustomerByUserId(userId);
                    }

                    // Kiểm tra xem employee record đã tồn tại chưa
                    Employee existingEmployee = employeeDAO.getEmployeeByUserId(userId);
                    if (existingEmployee != null) {
                        // Update existing employee role
                        employeeDAO.updateEmployeeRole(userId, employeeRole);
                    } else {
                        // Create new employee record
                        Employee employee = new Employee();
                        employee.setUserID(userId);
                        employee.setEmployeeRole(employeeRole);
                        employeeDAO.insertEmployee(employee);
                    }
                } else if (role == 3) { // Customer
                    // Nếu role cũ là Employee, xóa employee record
                    if (oldRole == 2) {
                        employeeDAO.deleteEmployee(userId);
                    }

                    // Kiểm tra xem customer record đã tồn tại chưa
                    Customer existingCustomer = customerDAO.getCustomerByUserID(userId);
                    if (existingCustomer == null) {
                        // Create new customer record
                        Customer customer = new Customer();
                        customer.setUserID(userId);
                        customer.setLoyaltyPoint(0);
                        customerDAO.insertCustomer(customer);
                    }
                } else if (role == 1) { // Admin
                    // Xóa employee hoặc customer record nếu có
                    if (oldRole == 2) {
                        employeeDAO.deleteEmployee(userId);
                    } else if (oldRole == 3) {
                        customerDAO.deleteCustomerByUserId(userId);
                    }
                }

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