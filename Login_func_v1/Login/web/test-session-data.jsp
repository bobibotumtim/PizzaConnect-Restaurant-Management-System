<%@page contentType="text/html" pageEncoding="UTF-8"%> <%@ page
import="models.User" %> <%@ page import="models.Employee" %>
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8" />
    <title>Session Data Test</title>
    <style>
      body {
        font-family: monospace;
        padding: 20px;
        background: #f5f5f5;
      }
      .section {
        margin: 20px 0;
        padding: 15px;
        border: 1px solid #ccc;
        background: white;
      }
      .label {
        font-weight: bold;
        color: #333;
      }
      .value {
        color: #0066cc;
      }
      .error {
        color: red;
        font-weight: bold;
      }
      .success {
        color: green;
        font-weight: bold;
      }
    </style>
  </head>
  <body>
    <h1>Session Data Test</h1>

    <% User currentUser = (User) session.getAttribute("user"); Employee employee
    = (Employee) session.getAttribute("employee"); %>

    <div class="section">
      <h2>Session Information</h2>
      <p>
        <span class="label">Session ID:</span>
        <span class="value"><%= session.getId() %></span>
      </p>
      <p>
        <span class="label">Session Created:</span>
        <span class="value"
          ><%= new java.util.Date(session.getCreationTime()) %></span
        >
      </p>
    </div>

    <div class="section">
      <h2>User Object</h2>
      <% if (currentUser != null) { %>
      <p class="success">✓ User object exists in session</p>
      <p>
        <span class="label">User ID:</span>
        <span class="value"><%= currentUser.getUserID() %></span>
      </p>
      <p>
        <span class="label">Name:</span>
        <span class="value"><%= currentUser.getName() %></span>
      </p>
      <p>
        <span class="label">Email:</span>
        <span class="value"><%= currentUser.getEmail() %></span>
      </p>
      <p>
        <span class="label">Role:</span>
        <span class="value"><%= currentUser.getRole() %></span>
      </p>
      <% } else { %>
      <p class="error">✗ No user object in session</p>
      <% } %>
    </div>

    <div class="section">
      <h2>Employee Object</h2>
      <% if (employee != null) { %>
      <p class="success">✓ Employee object exists in session</p>
      <p>
        <span class="label">Employee ID:</span>
        <span class="value"><%= employee.getEmployeeID() %></span>
      </p>
    </div>
  </body>
</html>
            <p><span class="label">User ID:</span> <span class="value"><%= employee.getUserID() %></span></p>
            <p><span class="label">Job Role:</span> <span class="value"><%= employee.getJobRole() %></span></p>
            <p><span class="label">Specialization:</span> <span class="value"><%= employee.getSpecialization() %></span></p>
        <% } else { %>
            <p class="error">✗ No employee object in session</p>
        <% } %>
    </div>
    
    <div class="section">
        <h2>Access Check for Inventory Monitor</h2>
        <% if (currentUser != null && employee != null) {
            boolean hasAccess = currentUser.getRole() == 2 && "Manager".equalsIgnoreCase(employee.getJobRole());
            if (hasAccess) { %>
                <p class="success">✓ User HAS access to Inventory Monitor</p>
                <p>Role is 2: <span class="success">✓</span></p>
                <p>JobRole is Manager: <span class="success">✓</span></p>
        <%  } else { %>
                <p class="error">✗ User DOES NOT have access to Inventory Monitor</p>
                <p>Role is 2: <% if (currentUser.getRole() == 2) { %><span class="success">✓</span><% } else { %><span class="error">✗ (Role is <%= currentUser.getRole() %>)</span><% } %></p>
                <p>JobRole is Manager: <% if ("Manager".equalsIgnoreCase(employee.getJobRole())) { %><span class="success">✓</span><% } else { %><span class="error">✗ (JobRole is <%= employee.getJobRole() %>)</span><% } %></p>
        <%  }
        } else { %>
            <p class="error">✗ Cannot check access - missing user or employee data</p>
        <% } %>
    </div>
    
    <div class="section">
        <h2>Actions</h2>
        <p><a href="<%= request.getContextPath() %>/manager-dashboard">Go to Manager Dashboard</a></p>
        <p><a href="<%= request.getContextPath() %>/inventory-monitor">Go to Inventory Monitor</a></p>
        <p><a href="<%= request.getContextPath() %>/logout">Logout</a></p>
    </div>
</body>
</html>
