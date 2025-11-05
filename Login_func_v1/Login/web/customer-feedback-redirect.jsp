<%@ page contentType="text/html;charset=UTF-8" language="java" %> <%@ page
import="models.User" %> <% // Check authentication - only admin and employees
can access User currentUser = (User) session.getAttribute("user"); if
(currentUser == null || (currentUser.getRole() != 1 && currentUser.getRole() !=
2)) { response.sendRedirect(request.getContextPath() + "/view/Home.jsp");
return; } // Redirect to debug page for now
response.sendRedirect(request.getContextPath() + "/debug-feedback.jsp"); %>
