package controller;

import dao.CustomerDAO;
import dao.EmployeeDAO;
import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import models.*;

public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher("view/Login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String phone = request.getParameter("phone");
        String pass = request.getParameter("pass");

        // Server-side validation
        if (phone == null || phone.trim().isEmpty()) {
            request.setAttribute("mess", "Phone number is required!");
            request.getRequestDispatcher("view/Login.jsp").forward(request, response);
            return;
        }
        
        if (pass == null || pass.isEmpty()) {
            request.setAttribute("mess", "Password is required!");
            request.getRequestDispatcher("view/Login.jsp").forward(request, response);
            return;
        }
        
        // Trim phone and validate format
        phone = phone.trim();
        if (!phone.matches("^[0-9]{10}$")) {
            request.setAttribute("mess", "Phone number must be 10 digits!");
            request.getRequestDispatcher("view/Login.jsp").forward(request, response);
            return;
        }
        
        // For login, we don't enforce strong password validation
        // This allows users with old passwords to still login
        // Strong password is only enforced during signup and password change

        UserDAO dao = new UserDAO();
        User user = null;
        try {
            user = dao.checkLogin(phone, pass);   
        } catch (Exception e) {
            request.setAttribute("mess", "System is under maintenance. Please try again later!");
            request.getRequestDispatcher("view/Login.jsp").forward(request, response);
            return;
        }

        if (user == null) {
            request.setAttribute("mess", "Phone number or password is incorrect!");
            request.getRequestDispatcher("view/Login.jsp").forward(request, response);
            return;
        }

        HttpSession session = request.getSession();
        session.setAttribute("user", user); 

        // Redirect based on role
        if (user.getRole() == 1) {
            // Admin -> Dashboard
            response.sendRedirect("dashboard"); 
        } else if (user.getRole() == 2) {
            // Employee -> Get Employee info and set to session
            EmployeeDAO empDAO = new EmployeeDAO();
            Employee employee = empDAO.getEmployeeByUserID(user.getUserID());
            if (employee != null) {
                session.setAttribute("employee", employee);
                String jobRole = employee.getJobRole();
                
                System.out.println("========== EMPLOYEE LOGIN DEBUG ==========");
                System.out.println("Employee Name: " + employee.getName());
                System.out.println("Employee ID: " + employee.getEmployeeID());
                System.out.println("Job Role: [" + jobRole + "]");
                System.out.println("Job Role is null: " + (jobRole == null));
                System.out.println("Job Role length: " + (jobRole != null ? jobRole.length() : "N/A"));
                System.out.println("Job Role trim: [" + (jobRole != null ? jobRole.trim() : "null") + "]");
                System.out.println("==========================================");
                
                // Check if employee is a Manager
                if (jobRole != null && jobRole.trim().equalsIgnoreCase("Manager")) {
                    System.out.println("👔 Manager detected - Redirecting to Manager Dashboard");
                    response.sendRedirect("manager-dashboard");
                    return;
                }
                
                // Check if employee is a Chef
                if (jobRole != null && jobRole.trim().equalsIgnoreCase("Chef")) {
                    System.out.println("🍳 Chef detected - Redirecting to ChefMonitor");
                    response.sendRedirect("ChefMonitor");
                    return;
                }
            }
            // Waiter or other employees -> Redirect to POS
            System.out.println("👔 Employee (Waiter) - Redirecting to POS");
            response.sendRedirect("pos");
        } else {
            // Customer -> Home
            CustomerDAO cdao = new CustomerDAO();
            Customer acc = cdao.getCustomerByUserID(user.getUserID());
            if (acc == null) { 
                request.setAttribute("error",
                        "No profile information found. Please contact support or complete your profile.");
                request.getRequestDispatcher("view/Detail.jsp").forward(request, response);
                return;
            }
            session.setAttribute("customer", acc);
            // Redirect to home servlet to load products
            response.sendRedirect("home");
        }
    }

}
