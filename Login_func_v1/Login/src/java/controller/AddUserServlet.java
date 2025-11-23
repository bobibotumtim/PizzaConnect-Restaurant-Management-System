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

@WebServlet(name = "AddUserServlet", urlPatterns = { "/adduser" })
public class AddUserServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Kiểm tra session và quyền admin
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

        request.setAttribute("currentUser", user);
        request.getRequestDispatcher("/view/AddUser.jsp").forward(request, response);
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
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String roleStr = request.getParameter("role");
        String employeeRole = request.getParameter("employeeRole");
        String dateOfBirthStr = request.getParameter("dateOfBirth");
        String gender = request.getParameter("gender");

        // Validation
        if (name == null || name.trim().isEmpty()) {
            request.setAttribute("error", "Name is required!");
            request.setAttribute("currentUser", currentUser);
            request.getRequestDispatcher("/view/AddUser.jsp").forward(request, response);
            return;
        }

        if (email == null || email.trim().isEmpty()) {
            request.setAttribute("error", "Email is required!");
            request.setAttribute("currentUser", currentUser);
            request.getRequestDispatcher("/view/AddUser.jsp").forward(request, response);
            return;
        }

        // Validate email format
        if (!email.matches("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$")) {
            request.setAttribute("error", "Invalid email format!");
            request.setAttribute("currentUser", currentUser);
            request.getRequestDispatcher("/view/AddUser.jsp").forward(request, response);
            return;
        }

        if (phone == null || phone.trim().isEmpty()) {
            request.setAttribute("error", "Phone number is required!");
            request.setAttribute("currentUser", currentUser);
            request.getRequestDispatcher("/view/AddUser.jsp").forward(request, response);
            return;
        }

        // Validate phone format: 0[1-9] followed by 8 digits
        if (!phone.matches("^0[1-9]\\d{8}$")) {
            request.setAttribute("error", "Invalid phone format! Must be 10 digits starting with 0[1-9]");
            request.setAttribute("currentUser", currentUser);
            request.getRequestDispatcher("/view/AddUser.jsp").forward(request, response);
            return;
        }

        // Validate password: >=8 chars, 1 uppercase, 1 lowercase, 1 digit
        if (password == null || !password.matches("^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).{8,}$")) {
            request.setAttribute("error", "Password must be at least 8 characters with 1 uppercase, 1 lowercase, and 1 digit!");
            request.setAttribute("currentUser", currentUser);
            request.getRequestDispatcher("/view/AddUser.jsp").forward(request, response);
            return;
        }

        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Passwords do not match!");
            request.setAttribute("currentUser", currentUser);
            request.getRequestDispatcher("/view/AddUser.jsp").forward(request, response);
            return;
        }

        if (roleStr == null || roleStr.trim().isEmpty()) {
            request.setAttribute("error", "User role is required!");
            request.setAttribute("currentUser", currentUser);
            request.getRequestDispatcher("/view/AddUser.jsp").forward(request, response);
            return;
        }

        try {
            int role = Integer.parseInt(roleStr);
            if (role < 1 || role > 3) {
                request.setAttribute("error", "Invalid role selected!");
                request.setAttribute("currentUser", currentUser);
                request.getRequestDispatcher("/view/AddUser.jsp").forward(request, response);
                return;
            }

            // Kiểm tra email đã tồn tại chưa
            UserDAO userDAO = new UserDAO();
            if (userDAO.isUserExists(email)) {
                request.setAttribute("error", "Email already exists! Please use a different email.");
                request.setAttribute("currentUser", currentUser);
                request.getRequestDispatcher("/view/AddUser.jsp").forward(request, response);
                return;
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
                    request.getRequestDispatcher("/view/AddUser.jsp").forward(request, response);
                    return;
                }
            }

            // Tạo user mới
            User newUser = new User();
            newUser.setName(name.trim());
            newUser.setEmail(email.trim());
            newUser.setPhone(phone.trim());
            newUser.setPassword(password);
            newUser.setRole(role);
            newUser.setDateOfBirth(dateOfBirth);
            newUser.setGender(gender != null && !gender.trim().isEmpty() ? gender.trim() : null);
            newUser.setActive(true);

            // Thêm user vào database
            int userId = userDAO.insertUser(newUser);

            if (userId > 0) {
                // Nếu là Employee hoặc Customer, thêm vào bảng tương ứng
                if (role == 2) { // Employee
                    if (employeeRole == null || employeeRole.trim().isEmpty()) {
                        request.setAttribute("error", "Employee role is required for Employee users!");
                        request.setAttribute("currentUser", currentUser);
                        request.getRequestDispatcher("/view/AddUser.jsp").forward(request, response);
                        return;
                    }

                    // Validate employee role
                    if (!employeeRole.equals("Manager") &&
                            !employeeRole.equals("Waiter") && !employeeRole.equals("Chef")) {
                        request.setAttribute("error", "Invalid employee role selected!");
                        request.setAttribute("currentUser", currentUser);
                        request.getRequestDispatcher("/view/AddUser.jsp").forward(request, response);
                        return;
                    }

                    EmployeeDAO employeeDAO = new EmployeeDAO();
                    Employee employee = new Employee();
                    employee.setUserID(userId);
                    employee.setEmployeeRole(employeeRole);

                    int employeeId = employeeDAO.insertEmployee(employee);
                    if (employeeId <= 0) {
                        request.setAttribute("error", "User created but failed to create employee record.");
                        request.setAttribute("currentUser", currentUser);
                        request.getRequestDispatcher("/view/AddUser.jsp").forward(request, response);
                        return;
                    }
                } else if (role == 3) { // Customer
                    CustomerDAO customerDAO = new CustomerDAO();
                    Customer customer = new Customer();
                    customer.setUserID(userId);
                    customer.setLoyaltyPoint(0);

                    int customerId = customerDAO.insertCustomerReturnId(customer);
                    if (customerId <= 0) {
                        request.setAttribute("error", "User created but failed to create customer record.");
                        request.setAttribute("currentUser", currentUser);
                        request.getRequestDispatcher("/view/AddUser.jsp").forward(request, response);
                        return;
                    }
                }

                request.setAttribute("message", "User created successfully! User ID: " + userId);
                request.setAttribute("currentUser", currentUser);
                request.getRequestDispatcher("/view/AddUser.jsp").forward(request, response);
            } else {
                request.setAttribute("error", "Failed to create user. Please try again.");
                request.setAttribute("currentUser", currentUser);
                request.getRequestDispatcher("/view/AddUser.jsp").forward(request, response);
            }

        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid role format!");
            request.setAttribute("currentUser", currentUser);
            request.getRequestDispatcher("/view/AddUser.jsp").forward(request, response);
        }
    }
}