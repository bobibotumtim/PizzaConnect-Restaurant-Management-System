<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Home - Test</title>
</head>
<body>
    <h1>Home Page Test</h1>
    <p>If you see this, the servlet is working!</p>
    
    <%
        Object productsObj = request.getAttribute("productsWithSizes");
        if (productsObj != null) {
            out.println("<p>Products loaded: " + productsObj.getClass().getName() + "</p>");
        } else {
            out.println("<p>No products loaded</p>");
        }
    %>
</body>
</html>
