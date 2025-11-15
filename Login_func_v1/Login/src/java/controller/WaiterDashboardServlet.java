package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import models.User;
import models.Employee;

@WebServlet(name = "WaiterDashboardServlet", urlPatterns = {"/waiter-dashboard"})
public class WaiterDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Kiểm tra session
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        Employee employee = (session != null) ? (Employee) session.getAttribute("employee") : null;
        
        if (user == null || user.getRole() != 2) {
            response.sendRedirect("view/Login.jsp");
            return;
        }
        
        // Chặn Manager - redirect về Manager Dashboard
        if (employee != null && "Manager".equalsIgnoreCase(employee.getJobRole())) {
            response.sendRedirect("manager-dashboard");
            return;
        }
        
        // Kiểm tra nếu là Chef thì redirect về ChefMonitor
        if (employee != null && employee.isChef()) {
            response.sendRedirect("ChefMonitor");
            return;
        }
        
        // Forward to Waiter Dashboard
        request.getRequestDispatcher("view/WaiterDashboard.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
