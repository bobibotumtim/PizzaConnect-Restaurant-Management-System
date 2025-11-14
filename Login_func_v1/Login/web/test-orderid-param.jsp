<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Test OrderID Parameter</title>
</head>
<body>
    <h1>Test OrderID Parameter</h1>
    <%
        String orderIdParam = request.getParameter("orderId");
        out.println("<p>Raw Parameter: " + orderIdParam + "</p>");
        
        if (orderIdParam != null) {
            out.println("<p>Parameter is NOT null</p>");
            out.println("<p>Parameter length: " + orderIdParam.length() + "</p>");
            out.println("<p>Parameter trimmed: '" + orderIdParam.trim() + "'</p>");
            out.println("<p>Is empty: " + orderIdParam.trim().isEmpty() + "</p>");
            
            try {
                int orderId = Integer.parseInt(orderIdParam);
                out.println("<p style='color: green;'>✅ Successfully parsed: " + orderId + "</p>");
            } catch (NumberFormatException e) {
                out.println("<p style='color: red;'>❌ Parse error: " + e.getMessage() + "</p>");
            }
        } else {
            out.println("<p style='color: red;'>❌ Parameter is NULL</p>");
        }
    %>
    
    <hr>
    <h2>All Request Parameters:</h2>
    <%
        java.util.Enumeration<String> paramNames = request.getParameterNames();
        while (paramNames.hasMoreElements()) {
            String paramName = paramNames.nextElement();
            String paramValue = request.getParameter(paramName);
            out.println("<p><strong>" + paramName + ":</strong> " + paramValue + "</p>");
        }
    %>
    
    <hr>
    <h2>Request Info:</h2>
    <p><strong>Request URI:</strong> <%= request.getRequestURI() %></p>
    <p><strong>Query String:</strong> <%= request.getQueryString() %></p>
    <p><strong>Method:</strong> <%= request.getMethod() %></p>
</body>
</html>
