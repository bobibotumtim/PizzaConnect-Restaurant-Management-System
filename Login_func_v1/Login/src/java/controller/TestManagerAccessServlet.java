package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import models.User;
import models.Employee;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet(name = "TestManagerAccessServlet", urlPatterns = {"/test-manager-access"})
public class TestManagerAccessServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        HttpSession session = request.getSession(false);
        
        out.println("<!DOCTYPE html>");
        out.println("<html><head><title>Test Manager Access</title>");
        out.println("<style>");
        out.println("body { font-family: Arial; padding: 20px; }");
        out.println(".success { background: #c8e6c9; padding: 15px; margin: 10px 0; border-radius: 5px; }");
        out.println(".error { background: #ffcdd2; padding: 15px; margin: 10px 0; border-radius: 5px; }");
        out.println(".info { background: #e3f2fd; padding: 15px; margin: 10px 0; border-radius: 5px; }");
        out.println("</style></head><body>");
        
        out.println("<h1>🔍 Manager Access Debug</h1>");
        
        if (session == null) {
            out.println("<div class='error'><h2>❌ No Session</h2><p>Please login first.</p></div>");
            out.println("</body></html>");
            return;
        }
        
        User currentUser = (User) session.getAttribute("user");
        Employee employee = (Employee) session.getAttribute("employee");
        
        out.println("<div class='info'>");
        out.println("<h2>Session Info:</h2>");
        out.println("<p><strong>Session ID:</strong> " + session.getId() + "</p>");
        out.println("<p><strong>User in session:</strong> " + (currentUser != null ? "Yes ✅" : "No ❌") + "</p>");
        out.println("<p><strong>Employee in session:</strong> " + (employee != null ? "Yes ✅" : "No ❌") + "</p>");
        out.println("</div>");
        
        if (currentUser != null) {
            out.println("<div class='success'>");
            out.println("<h2>✅ User Details:</h2>");
            out.println("<p><strong>User ID:</strong> " + currentUser.getUserID() + "</p>");
            out.println("<p><strong>Name:</strong> " + currentUser.getName() + "</p>");
            out.println("<p><strong>Email:</strong> " + currentUser.getEmail() + "</p>");
            out.println("<p><strong>Role:</strong> " + currentUser.getRole());
            if (currentUser.getRole() == 1) out.println(" (Admin)");
            else if (currentUser.getRole() == 2) out.println(" (Employee)");
            else if (currentUser.getRole() == 3) out.println(" (Customer)");
            out.println("</p></div>");
        } else {
            out.println("<div class='error'><h2>❌ No User</h2></div>");
        }
        
        if (employee != null) {
            out.println("<div class='success'>");
            out.println("<h2>✅ Employee Details:</h2>");
            out.println("<p><strong>Employee ID:</strong> " + employee.getEmployeeID() + "</p>");
            out.println("<p><strong>Job Role:</strong> " + employee.getJobRole() + "</p>");
            out.println("<p><strong>Specialization:</strong> " + (employee.getSpecialization() != null ? employee.getSpecialization() : "None") + "</p>");
            out.println("</div>");
            
            // Check authorization
            boolean isAuthorized = false;
            if (currentUser != null) {
                if (currentUser.getRole() == 1) {
                    isAuthorized = true;
                } else if (currentUser.getRole() == 2 && "Manager".equalsIgnoreCase(employee.getJobRole())) {
                    isAuthorized = true;
                }
            }
            
            out.println("<div class='" + (isAuthorized ? "success" : "error") + "'>");
            out.println("<h2>🔐 Authorization Check:</h2>");
            out.println("<p><strong>Can access Admin page?</strong> " + (isAuthorized ? "Yes ✅" : "No ❌") + "</p>");
            
            if (isAuthorized) {
                out.println("<h3>✅ You should be able to access:</h3>");
                out.println("<ul>");
                out.println("<li><a href='" + request.getContextPath() + "/manager-dashboard'>Manager Dashboard</a></li>");
                out.println("<li><a href='" + request.getContextPath() + "/sales-reports'>Sales Reports</a></li>");
                out.println("<li><a href='" + request.getContextPath() + "/admin'>User Management</a></li>");
                out.println("</ul>");
            } else {
                out.println("<p><strong>Problem:</strong> Role=" + currentUser.getRole() + ", JobRole=" + employee.getJobRole() + "</p>");
                out.println("<p><strong>Required:</strong> Role=2 AND JobRole='Manager'</p>");
            }
            out.println("</div>");
            
        } else if (currentUser != null && currentUser.getRole() == 2) {
            out.println("<div class='error'>");
            out.println("<h2>❌ Problem Found!</h2>");
            out.println("<p>User has role=2 (Employee) but no Employee object in session.</p>");
            out.println("<p><strong>Solution:</strong> Logout and login again to refresh session.</p>");
            out.println("</div>");
        }
        
        out.println("<hr>");
        out.println("<p><a href='" + request.getContextPath() + "/logout'>Logout</a> | ");
        out.println("<a href='" + request.getContextPath() + "/manager-dashboard'>Manager Dashboard</a></p>");
        out.println("</body></html>");
    }
}
