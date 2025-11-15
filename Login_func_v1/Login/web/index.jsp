<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Redirect to HomeServlet to load data
    response.sendRedirect(request.getContextPath() + "/home");
%>
