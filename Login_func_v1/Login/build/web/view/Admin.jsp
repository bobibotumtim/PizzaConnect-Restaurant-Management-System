<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="models.User" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - PizzaConnect</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 15px;
            box-shadow: 0 15px 35px rgba(0,0,0,0.1);
            overflow: hidden;
        }
        
        .header {
            background: linear-gradient(135deg, #ff6b6b, #ee5a24);
            color: white;
            padding: 30px;
            text-align: center;
        }
        
        .header h1 {
            font-size: 2.5em;
            margin-bottom: 10px;
        }
        
        .header p {
            font-size: 1.1em;
            opacity: 0.9;
        }
        
        .nav {
            background: #2c3e50;
            padding: 15px 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .nav .welcome {
            color: white;
            font-weight: 500;
        }
        
        .nav .logout {
            background: #e74c3c;
            color: white;
            padding: 8px 20px;
            text-decoration: none;
            border-radius: 5px;
            transition: background 0.3s;
        }
        
        .nav .logout:hover {
            background: #c0392b;
        }
        
        .content {
            padding: 30px;
        }
        
        .alert {
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 5px;
            font-weight: 500;
        }
        
        .alert.success {
            background: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        
        .alert.error {
            background: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        
        .stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            background: linear-gradient(135deg, #74b9ff, #0984e3);
            color: white;
            padding: 25px;
            border-radius: 10px;
            text-align: center;
        }
        
        .stat-card h3 {
            font-size: 2em;
            margin-bottom: 10px;
        }
        
        .stat-card p {
            font-size: 1.1em;
            opacity: 0.9;
        }
        
        .table-container {
            background: white;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }
        
        .table-header {
            background: #34495e;
            color: white;
            padding: 20px;
            font-size: 1.2em;
            font-weight: 600;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
        }
        
        th, td {
            padding: 15px;
            text-align: left;
            border-bottom: 1px solid #ecf0f1;
        }
        
        th {
            background: #f8f9fa;
            font-weight: 600;
            color: #2c3e50;
        }
        
        tr:hover {
            background: #f8f9fa;
        }
        
        .role-badge {
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 0.85em;
            font-weight: 600;
            text-transform: uppercase;
        }
        
        .role-admin {
            background: #e74c3c;
            color: white;
        }
        
        .role-user {
            background: #3498db;
            color: white;
        }
        
        .btn {
            padding: 8px 16px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            font-size: 0.9em;
            transition: all 0.3s;
        }
        
        .btn-danger {
            background: #e74c3c;
            color: white;
        }
        
        .btn-danger:hover {
            background: #c0392b;
            transform: translateY(-1px);
        }
        
        .btn-edit {
            background: #f39c12;
            color: white;
            margin-right: 5px;
        }
        
        .btn-edit:hover {
            background: #e67e22;
            transform: translateY(-1px);
        }
        
        .empty-state {
            text-align: center;
            padding: 50px;
            color: #7f8c8d;
        }
        
        .empty-state i {
            font-size: 4em;
            margin-bottom: 20px;
            display: block;
        }
    </style>
</head>
<body>
    <%
        User currentUser = (User) request.getAttribute("currentUser");
        List<User> users = (List<User>) request.getAttribute("users");
        String message = (String) request.getAttribute("message");
        String error = (String) request.getAttribute("error");
        
        // Calculate stats
        int totalUsers = users != null ? users.size() : 0;
        int adminCount = 0;
        if (users != null) {
            for (User user : users) {
                if (user.getRole() == 1) {
                    adminCount++;
                }
            }
        }
        int regularUsers = totalUsers - adminCount;
    %>
    
    <div class="container">
        <div class="header">
            <h1>🍕 PizzaConnect Admin</h1>
            <p>Restaurant Management System</p>
        </div>
        
        <div class="nav">
            <div class="welcome">
                Welcome, <strong><%= currentUser != null ? currentUser.getUsername() : "Admin" %></strong> (Admin)
            </div>
            <a href="Login?action=logout" class="logout">Logout</a>
        </div>
        
        <div class="content">
            <% if (message != null && !message.isEmpty()) { %>
                <div class="alert success"><%= message %></div>
            <% } %>
            
            <% if (error != null && !error.isEmpty()) { %>
                <div class="alert error"><%= error %></div>
            <% } %>
            
            <div class="stats">
                <div class="stat-card">
                    <h3><%= totalUsers %></h3>
                    <p>Total Users</p>
                </div>
                <div class="stat-card">
                    <h3><%= adminCount %></h3>
                    <p>Admins</p>
                </div>
                <div class="stat-card">
                    <h3><%= regularUsers %></h3>
                    <p>Regular Users</p>
                </div>
            </div>
            
            <div class="table-container">
                <div class="table-header">
                    👥 User Management
                </div>
                
                <% if (users == null || users.isEmpty()) { %>
                    <div class="empty-state">
                        <i>👤</i>
                        <h3>No Users Found</h3>
                        <p>There are no users in the system yet.</p>
                    </div>
                <% } else { %>
                    <table>
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Username</th>
                                <th>Email</th>
                                <th>Phone</th>
                                <th>Role</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (User user : users) { %>
                                <tr>
                                    <td><%= user.getUserID() %></td>
                                    <td><strong><%= user.getUsername() %></strong></td>
                                    <td><%= user.getEmail() %></td>
                                    <td><%= user.getPhone() %></td>
                                    <td>
                                        <% if (user.getRole() == 1) { %>
                                            <span class="role-badge role-admin">Admin</span>
                                        <% } else { %>
                                            <span class="role-badge role-user">User</span>
                                        <% } %>
                                    </td>
                                    <td>
                                        <% if (currentUser != null && user.getUserID() != currentUser.getUserID()) { %>
                                            <a href="edituser?id=<%= user.getUserID() %>" class="btn btn-edit">Edit</a>
                                            <form style="display: inline;" method="post" 
                                                  onsubmit="return confirm('Are you sure you want to delete this user?')">
                                                <input type="hidden" name="action" value="delete">
                                                <input type="hidden" name="userId" value="<%= user.getUserID() %>">
                                                <button type="submit" class="btn btn-danger">Delete</button>
                                            </form>
                                        <% } else { %>
                                            <span style="color: #7f8c8d; font-style: italic;">Current User</span>
                                        <% } %>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                <% } %>
            </div>
        </div>
    </div>
</body>
</html>