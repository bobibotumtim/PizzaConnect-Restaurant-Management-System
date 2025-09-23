<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="models.User" %>
<html>
<head>
    <title>Edit User</title>
</head>
<body>
<%
    User u = (User) request.getAttribute("user"); 
    if (u == null) {
%>
    <p>Không tìm thấy thông tin User.</p>
<%
    } else {
%>
    <h2>Sửa thông tin User</h2>
    <form action="updateUser" method="post">
        <!-- cần UserID để biết user nào -->
        <input type="hidden" name="userID" value="<%= u.getUserID() %>"/>

        <label>Username:</label>
        <input type="text" name="username" value="<%= u.getUsername() %>" readonly/><br/><br/>

        <label>Email:</label>
        <input type="text" name="email" value="<%= u.getEmail() %>"/><br/><br/>

        <label>Password:</label>
        <input type="password" name="password" value="<%= u.getPassword() %>"/><br/><br/>

        <label>Phone:</label>
        <input type="text" name="phone" value="<%= u.getPhone() %>"/><br/><br/>

        <label>Role:</label>
        <input type="number" name="role" value="<%= u.getRole() %>"/><br/><br/>

        <input type="submit" value="Cập nhật"/>
    </form>
<%
    }
%>
</body>
</html>
