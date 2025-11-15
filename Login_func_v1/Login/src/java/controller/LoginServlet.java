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

        UserDAO dao = new UserDAO();
        User user = null;
        try {
            user = dao.checkLogin(phone, pass);   
        } catch (Exception e) {
            request.setAttribute("mess", "We are unable to process your login at the moment. Please try again later." + e.getMessage().toString());
            request.getRequestDispatcher("view/Login.jsp").forward(request, response);
            return;
        }

        if (user == null) {
            request.setAttribute("mess", "Tên đăng nhập hoặc mật khẩu không đúng!");
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
            // Waiter or other employees -> Redirect to Waiter Dashboard
            System.out.println("👔 Employee (non-chef) - Redirecting to Waiter Dashboard");
            response.sendRedirect("waiter-dashboard");
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
