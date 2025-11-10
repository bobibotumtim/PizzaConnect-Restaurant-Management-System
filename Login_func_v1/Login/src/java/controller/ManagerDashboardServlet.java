package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import models.User;
import models.Employee;
import java.io.IOException;

@WebServlet(name = "ManagerDashboardServlet", urlPatterns = {"/manager-dashboard"})
public class ManagerDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check if user is logged in
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/view/Login.jsp");
            return;
        }
        
        // Check if user is an Employee with Manager job role
        User currentUser = (User) session.getAttribute("user");
        Employee employee = (Employee) session.getAttribute("employee");
        
        // Must be role 2 (Employee) and have Manager job role
        if (currentUser.getRole() != 2 || employee == null || 
            !"Manager".equalsIgnoreCase(employee.getJobRole())) {
            // If not manager, redirect to appropriate dashboard
            if (currentUser.getRole() == 1) {
                response.sendRedirect(request.getContextPath() + "/dashboard");
            } else if (currentUser.getRole() == 2) {
                // Other employees go to waiter dashboard
                response.sendRedirect(request.getContextPath() + "/waiter-dashboard");
            } else {
                response.sendRedirect(request.getContextPath() + "/view/Home.jsp");
            }
            return;
        }
        
        // Forward to Manager Dashboard
        request.getRequestDispatcher("/view/ManagerDashboard.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
