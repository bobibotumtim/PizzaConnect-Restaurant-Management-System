<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="models.User" %>
<%@ page import="models.Employee" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Debug Session</title>
    <style>
        body { font-family: Arial; padding: 20px; background: #f5f5f5; }
        .box { background: white; padding: 20px; margin: 10px 0; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .success { background: #c8e6c9; }
        .error { background: #ffcdd2; }
        .info { background: #e3f2fd; }
        h2 { margin-top: 0; }
        pre { background: #f5f5f5; padding: 10px; border-radius: 4px; overflow-x: auto; }
    </style>
</head>
<body>
    <h1>🔍 Session Debug Information</h1>
    
    <%
        User currentUser = (User) session.getAttribute("user");
        Employee employee = (Employee) session.getAttribute("employee");
    %>
    
    <div class="box info">
        <h2>Session Info</h2>
        <p><strong>Session ID:</strong> <%= session.getId() %></p>
        <p><strong>Session Created:</strong> <%= new java.util.Date(session.getCreationTime()) %></p>
        <p><strong>Last Accessed:</strong> <%= new java.util.Date(session.getLastAccessedTime()) %></p>
    </div>
    
    <% if (currentUser != null) { %>
        <div class="box success">
            <h2>✅ User Object Found</h2>
            <pre>User ID: <%= currentUser.getUserID() %>
Name: <%= currentUser.getName() %>
Email: <%= currentUser.getEmail() %>
Phone: <%= currentUser.getPhone() %>
Role: <%= currentUser.getRole() %> <%= currentUser.getRole() == 1 ? "(Admin)" : currentUser.getRole() == 2 ? "(Employee)" : "(Customer)" %>
Active: <%= currentUser.isActive() %></pre>
        </div>
    <% } else { %>
        <div class="box error">
            <h2>❌ No User in Session</h2>
            <p>Please login first</p>
        </div>
    <% } %>
    
    <% if (employee != null) { %>
        <div class="box success">
            <h2>✅ Employee Object Found</h2>
            <pre>Employee ID: <%= employee.getEmployeeID() %>
Job Role: <%= employee.getJobRole() %>
Specialization: <%= employee.getSpecialization() != null ? employee.getSpecialization() : "None" %></pre>
        </div>
    <% } else { %>
        <div class="box error">
            <h2>❌ No Employee in Session</h2>
            <p>Employee object not found in session</p>
        </div>
    <% } %>
    
    <% 
        if (currentUser != null && employee != null) {
            boolean isAdmin = currentUser.getRole() == 1;
            boolean isManager = currentUser.getRole() == 2 && "Manager".equalsIgnoreCase(employee.getJobRole());
            boolean canAccessAdmin = isAdmin || isManager;
    %>
        <div class="box <%= canAccessAdmin ? "success" : "error" %>">
            <h2>🔐 Authorization Check</h2>
            <p><strong>Is Admin:</strong> <%= isAdmin ? "Yes ✅" : "No ❌" %></p>
            <p><strong>Is Manager:</strong> <%= isManager ? "Yes ✅" : "No ❌" %></p>
            <p><strong>Can Access Admin Page:</strong> <%= canAccessAdmin ? "Yes ✅" : "No ❌" %></p>
            
            <% if (canAccessAdmin) { %>
                <hr>
                <h3>Available Links:</h3>
                <ul>
                    <li><a href="<%= request.getContextPath() %>/manager-dashboard">Manager Dashboard</a></li>
                    <li><a href="<%= request.getContextPath() %>/admin">User Management (Admin Page)</a></li>
                    <li><a href="<%= request.getContextPath() %>/sales-reports">Sales Reports</a></li>
                </ul>
            <% } else { %>
                <hr>
                <p><strong>Problem:</strong></p>
                <ul>
                    <li>User Role: <%= currentUser.getRole() %></li>
                    <li>Employee Job Role: <%= employee.getJobRole() %></li>
                    <li>Expected: Role=2 AND JobRole='Manager' (case insensitive)</li>
                </ul>
            <% } %>
        </div>
    <% } %>
    
    <div class="box info">
        <h3>Quick Actions:</h3>
        <p>
            <a href="<%= request.getContextPath() %>/view/Login.jsp">Go to Login</a> | 
            <a href="<%= request.getContextPath() %>/logout">Logout</a> | 
            <a href="<%= request.getContextPath() %>/dashboard">Dashboard</a>
        </p>
    </div>
</body>
</html>
