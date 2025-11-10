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
                System.out.println("✅ Employee set to session: " + employee.getName() + " - Specialization: " + employee.getSpecialization());
                
                // Check if employee is a Chef (has specialization)
                String specialization = employee.getSpecialization();
                if (specialization != null && !specialization.trim().isEmpty() && !specialization.equalsIgnoreCase("None")) {
                    // Chef -> Redirect to ChefMonitor
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
            {
                Customer acc = cdao.getCustomerByUserID(user.getUserID());
                if (acc == null) { 
                    request.setAttribute("error",
                            "No profile information found. Please contact support or complete your profile.");
                    request.getRequestDispatcher("view/Detail.jsp").forward(request, response);
                    return;
                }
                request.setAttribute("customer", acc);
                request.setAttribute("user", user);
                request.getRequestDispatcher("view/Home.jsp").forward(request, response);
            }
        }
    }

}
