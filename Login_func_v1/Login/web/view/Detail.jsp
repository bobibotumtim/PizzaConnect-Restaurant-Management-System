<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="models.User" %>
<html>
<head>
    <title>User Detail</title>
    <style>
        table {
            border-collapse: collapse;
            width: 50%;
            margin: 30px auto;
        }
        th, td {
            border: 1px solid #333;
            padding: 10px;
            text-align: left;
        }
        th {
            background-color: #f2f2f2;
            width: 30%;
        }
        h2 {
            text-align: center;
        }
    </style>
</head>
<body>
<h2>Thong tin User</h2>
<%
    User u = (User) request.getAttribute("user");
    if (u != null) {
%>
    <table>
        <tr>
            <th>UserID</th>
            <td><%= u.getUserID() %></td>
        </tr>
        <tr>
            <th>Username</th>
            <td><%= u.getUsername() %></td>
        </tr>
        <tr>
            <th>Email</th>
            <td><%= u.getEmail() %></td>
        </tr>
        <tr>
            <th>Password</th>
            <td><%= u.getPassword() %></td>
        </tr>
        <tr>
            <th>Phone</th>
            <td><%= u.getPhone() %></td>
        </tr>
        <tr>
            <th>Role</th>
            <td><%= u.getRole() %></td>
        </tr>
    </table>
    <a href="editUser?userID=<%= u.getUserID() %>">Edit</a>
<%
    } else {
%>
    <p style="text-align: center; color: red;">Không tìm thấy thông tin user.</p>
<%
    }
%>
</body>
</html>
