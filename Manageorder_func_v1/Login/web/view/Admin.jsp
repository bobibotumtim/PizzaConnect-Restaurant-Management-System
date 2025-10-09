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
        
        /* Dashboard Modules */
        .dashboard-modules {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 25px;
            margin-bottom: 40px;
        }
        
        .module-card {
            background: white;
            border-radius: 15px;
            padding: 30px;
            box-shadow: 0 8px 25px rgba(0,0,0,0.1);
            transition: all 0.3s ease;
            border: 1px solid #e9ecef;
        }
        
        .module-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 15px 35px rgba(0,0,0,0.15);
        }
        
        .module-icon {
            font-size: 3em;
            text-align: center;
            margin-bottom: 20px;
        }
        
        .module-card h3 {
            color: #2c3e50;
            font-size: 1.4em;
            margin-bottom: 15px;
            text-align: center;
        }
        
        .module-card p {
            color: #7f8c8d;
            text-align: center;
            margin-bottom: 25px;
            line-height: 1.5;
        }
        
        .module-actions {
            text-align: center;
        }
        
        .module-actions .btn {
            padding: 12px 25px;
            font-size: 1em;
            font-weight: 600;
            border-radius: 8px;
            transition: all 0.3s ease;
            text-decoration: none;
            display: inline-block;
        }
        
        .module-actions .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(0,0,0,0.2);
        }
        
        .btn-success {
            background: linear-gradient(135deg, #27ae60, #2ecc71);
            color: white;
        }
        
        .btn-success:hover {
            background: linear-gradient(135deg, #229954, #27ae60);
        }
        
        .btn-info {
            background: linear-gradient(135deg, #3498db, #5dade2);
            color: white;
        }
        
        .btn-info:hover {
            background: linear-gradient(135deg, #2980b9, #3498db);
        }
        
        .btn-warning {
            background: linear-gradient(135deg, #f39c12, #f4d03f);
            color: white;
        }
        
        .btn-warning:hover {
            background: linear-gradient(135deg, #e67e22, #f39c12);
        }
    </style>
</head>
<body>
    <%
        User currentUser = (User) request.getAttribute("currentUser");
        List<User> users = (List<User>) request.getAttribute("users");
        String message = (String) request.getAttribute("message");
        String error = (String) request.getAttribute("error");
        Integer totalOrders = (Integer) request.getAttribute("totalOrders");
        
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
        int orderCount = totalOrders != null ? totalOrders : 0;
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
            <div>
                <a href="dashboard" class="btn btn-info" style="margin-right: 10px;">Dashboard</a>
                <a href="Login?action=logout" class="logout">Logout</a>
            </div>
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
                <div class="stat-card">
                    <h3><%= orderCount %></h3>
                    <p>Total Orders</p>
                </div>
            </div>
            
            <!-- Dashboard Modules -->
            <div class="dashboard-modules">
                <div class="module-card">
                    <div class="module-icon">👥</div>
                    <h3>User Management</h3>
                    <p>Manage users, roles and permissions</p>
                    <div class="module-actions">
                        <a href="#user-management" class="btn btn-primary">Manage Users</a>
                    </div>
                </div>
                
                <div class="module-card">
                    <div class="module-icon">🍕</div>
                    <h3>Order Management</h3>
                    <p>View and manage pizza orders</p>
                    <div class="module-actions">
                        <a href="manage-orders" class="btn btn-success">Manage Orders</a>
                    </div>
                </div>
                
                <div class="module-card">
                    <div class="module-icon">📊</div>
                    <h3>Reports & Analytics</h3>
                    <p>View sales reports and statistics</p>
                    <div class="module-actions">
                        <a href="#reports" class="btn btn-info">View Reports</a>
                    </div>
                </div>
                
                <div class="module-card">
                    <div class="module-icon">⚙️</div>
                    <h3>System Settings</h3>
                    <p>Configure system parameters</p>
                    <div class="module-actions">
                        <a href="#settings" class="btn btn-warning">Settings</a>
                    </div>
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