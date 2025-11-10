<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="models.User" %>
<%@ page import="models.Employee" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Test Manager Access</title>
    <style>
        body { font-family: Arial; padding: 20px; }
        .info { background: #e3f2fd; padding: 15px; margin: 10px 0; border-radius: 5px; }
        .success { background: #c8e6c9; padding: 15px; margin: 10px 0; border-radius: 5px; }
        .error { background: #ffcdd2; padding: 15px; margin: 10px 0; border-radius: 5px; }
        .code { background: #f5f5f5; padding: 10px; font-family: monospace; }
    </style>
</head>
<body>
    <h1>🔍 Test Manager Access Debug</h1>
    
    <%
        User currentUser = (User) session.getAttribute("user");
        Employee employee = (Employee) session.getAttribute("employee");
    %>
    
    <div class="info">
        <h2>Session Information:</h2>
        <div class="code">
            <strong>Session ID:</strong> <%= session.getId() %><br>
            <strong>User in session:</strong> <%= (currentUser != null) ? "Yes" : "No" %><br>
            <strong>Employee in session:</strong> <%= (employee != null) ? "Yes" : "No" %>
        </div>
    </div>
    
    <% if (currentUser != null) { %>
        <div class="success">
            <h2>✅ User Details:</h2>
            <div class="code">
                <strong>User ID:</strong> <%= currentUser.getUserID() %><br>
                <strong>Name:</strong> <%= currentUser.getName() %><br>
                <strong>Email:</strong> <%= currentUser.getEmail() %><br>
                <strong>Phone:</strong> <%= currentUser.getPhone() %><br>
                <strong>Role (User):</strong> <%= currentUser.getRole() %>
                <% if (currentUser.getRole() == 1) { %>
                    (Admin)
                <% } else if (currentUser.getRole() == 2) { %>
                    (Employee)
                <% } else if (currentUser.getRole() == 3) { %>
                    (Customer)
                <% } %>
            </div>
        </div>
    <% } else { %>
        <div class="error">
            <h2>❌ No User in Session</h2>
            <p>Please <a href="<%= request.getContextPath() %>/view/Login.jsp">login</a> first.</p>
        </div>
    <% } %>
    
    <% if (employee != null) { %>
        <div class="success">
            <h2>✅ Employee Details:</h2>
            <div class="code">
                <strong>Employee ID:</strong> <%= employee.getEmployeeID() %><br>
                <strong>Job Role:</strong> <%= employee.getJobRole() %><br>
                <strong>Specialization:</strong> <%= (employee.getSpecialization() != null) ? employee.getSpecialization() : "None" %>
            </div>
        </div>
    <% } else { %>
        <div class="error">
            <h2>❌ No Employee in Session</h2>
            <% if (currentUser != null && currentUser.getRole() == 2) { %>
                <p><strong>Warning:</strong> User has role=2 (Employee) but no Employee object in session!</p>
                <p>This might be the problem. Try logout and login again.</p>
            <% } %>
        </div>
    <% } %>
    
    <% if (currentUser != null && employee != null) { %>
        <div class="<%= ("Manager".equalsIgnoreCase(employee.getJobRole())) ? "success" : "error" %>">
            <h2>🔐 Access Check:</h2>
            <div class="code">
                <strong>Is Admin?</strong> <%= (currentUser.getRole() == 1) ? "Yes ✅" : "No ❌" %><br>
                <strong>Is Employee?</strong> <%= (currentUser.getRole() == 2) ? "Yes ✅" : "No ❌" %><br>
                <strong>Is Manager?</strong> <%= ("Manager".equalsIgnoreCase(employee.getJobRole())) ? "Yes ✅" : "No ❌" %><br>
                <strong>Can access Admin page?</strong> 
                <% 
                    boolean canAccess = (currentUser.getRole() == 1) || 
                                       (currentUser.getRole() == 2 && "Manager".equalsIgnoreCase(employee.getJobRole()));
                %>
                <%= canAccess ? "Yes ✅" : "No ❌" %>
            </div>
        </div>
        
        <% if (canAccess) { %>
            <div class="success">
                <h2>✅ You should be able to access:</h2>
                <ul>
                    <li><a href="<%= request.getContextPath() %>/manager-dashboard">Manager Dashboard</a></li>
                    <li><a href="<%= request.getContextPath() %>/sales-reports">Sales Reports</a></li>
                    <li><a href="<%= request.getContextPath() %>/admin">User Management (Admin)</a></li>
                </ul>
            </div>
        <% } else { %>
            <div class="error">
                <h2>❌ Access Denied</h2>
                <p>You don't have permission to access Manager features.</p>
                <p><strong>Required:</strong> Role=2 (Employee) AND JobRole='Manager'</p>
                <p><strong>Your status:</strong> Role=<%= currentUser.getRole() %>, JobRole=<%= employee.getJobRole() %></p>
            </div>
        <% } %>
    <% } %>
    
    <hr>
    <p><a href="<%= request.getContextPath() %>/view/Home.jsp">← Back to Home</a></p>
</body>
</html>
