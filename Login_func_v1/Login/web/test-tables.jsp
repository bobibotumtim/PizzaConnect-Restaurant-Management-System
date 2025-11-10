<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="dao.TableDAO" %>
<%@ page import="models.Table" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html>
<head>
    <title>Test Tables</title>
</head>
<body>
    <h1>Test Table Data</h1>
    <%
        TableDAO tableDAO = new TableDAO();
        List<Table> tables = tableDAO.getActiveTablesWithStatus();
        
        out.println("<p><strong>Total tables:</strong> " + (tables != null ? tables.size() : "null") + "</p>");
        
        if (tables != null && !tables.isEmpty()) {
            out.println("<table border='1'>");
            out.println("<tr><th>ID</th><th>Number</th><th>Capacity</th><th>Status</th><th>IsActive</th></tr>");
            for (Table t : tables) {
                out.println("<tr>");
                out.println("<td>" + t.getTableID() + "</td>");
                out.println("<td>" + t.getTableNumber() + "</td>");
                out.println("<td>" + t.getCapacity() + "</td>");
                out.println("<td>" + t.getStatus() + "</td>");
                out.println("<td>" + t.isActive() + "</td>");
                out.println("</tr>");
            }
            out.println("</table>");
        } else {
            out.println("<p style='color: red;'>❌ No tables found!</p>");
            out.println("<p>Possible reasons:</p>");
            out.println("<ul>");
            out.println("<li>Database not initialized</li>");
            out.println("<li>Script not executed</li>");
            out.println("<li>Connection error</li>");
            out.println("</ul>");
        }
    %>
</body>
</html>
