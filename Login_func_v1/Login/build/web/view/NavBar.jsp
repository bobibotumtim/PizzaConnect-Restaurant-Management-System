<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="models.User" %>
<%
    HttpSession sessionObj = request.getSession(false);
    User user = (sessionObj != null) ? (User) sessionObj.getAttribute("user") : null;
%>

<div style="background-color:#343a40; color:white; padding:15px; display:flex; justify-content:space-between; align-items:center;">
    <div>
        <h2 style="margin:0;">🍕 Pizza Store</h2>
    </div>

    <div>
        <% if (user == null) { %>
            <!-- Nếu chưa đăng nhập -->
            <a href="view/Login.jsp"
               style="background-color:#28a745; color:white; padding:8px 15px; border-radius:5px; text-decoration:none;">
               Login
            </a>
        <% } else { %>
            <!-- Nếu đã đăng nhập -->
            <div style="display:flex; align-items:center; gap:15px;">
                <span>Welcome, <strong><%= user.getUsername() %></strong>!</span>
                <a href="detail"
                   style="background-color:#ffc107; color:black; padding:8px 15px; border-radius:5px; text-decoration:none;">
                   User Info
                </a>
                <a href="logout"
                   style="background-color:#dc3545; color:white; padding:8px 15px; border-radius:5px; text-decoration:none;">
                   Logout
                </a>
            </div>
        <% } %>
    </div>
</div>
