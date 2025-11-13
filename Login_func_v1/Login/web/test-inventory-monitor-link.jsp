<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
  <head>
    <title>Test Inventory Monitor Link</title>
  </head>
  <body>
    <h1>Test Inventory Monitor Links</h1>

    <h2>Try these links:</h2>
    <ul>
      <li>
        <a href="<%= request.getContextPath() %>/inventory-monitor"
          >Inventory Monitor (Servlet)</a
        >
      </li>
      <li>
        <a href="<%= request.getContextPath() %>/view/InventoryMonitor.jsp"
          >Inventory Monitor (Direct JSP)</a
        >
      </li>
      <li>
        <a href="<%= request.getContextPath() %>/manager-dashboard"
          >Manager Dashboard (Working)</a
        >
      </li>
      <li>
        <a href="<%= request.getContextPath() %>/test-inventory-monitor"
          >Test Servlet (Working)</a
        >
      </li>
    </ul>

    <h2>Debug Info:</h2>
    <p>Context Path: <%= request.getContextPath() %></p>
    <p>
      Full URL to Inventory Monitor: <%= request.getContextPath()
      %>/inventory-monitor
    </p>

    <h2>Session Info:</h2>
    <p>User: <%= session.getAttribute("user") %></p>
    <p>Employee: <%= session.getAttribute("employee") %></p>
  </body>
</html>
