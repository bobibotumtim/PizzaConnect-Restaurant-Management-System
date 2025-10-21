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
            max-width: 1400px;
            margin: 0 auto;
            background: white;
            border-radius: 15px;
            box-shadow: 0 15px 35px rgba(0,0,0,0.1);
            overflow: hidden;
        }
        
        .header {
            background: linear-gradient(135deg, #ff6b6b, #ee5a24);
            color: white;
            padding: 40px;
            text-align: center;
        }
        
        .header h1 {
            font-size: 3em;
            margin-bottom: 10px;
        }
        
        .header p {
            font-size: 1.2em;
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
            font-size: 1.1em;
        }
        
        .nav .logout {
            background: #e74c3c;
            color: white;
            padding: 10px 25px;
            text-decoration: none;
            border-radius: 5px;
            transition: background 0.3s;
            font-weight: 600;
        }
        
        .nav .logout:hover {
            background: #c0392b;
        }
        
        .content {
            padding: 40px;
        }
        
        .stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 25px;
            margin-bottom: 50px;
        }
        
        .stat-card {
            background: linear-gradient(135deg, #74b9ff, #0984e3);
            color: white;
            padding: 30px;
            border-radius: 15px;
            text-align: center;
            box-shadow: 0 8px 25px rgba(0,0,0,0.1);
            transition: transform 0.3s ease;
        }
        
        .stat-card:hover {
            transform: translateY(-5px);
        }
        
        .stat-card h3 {
            font-size: 2.5em;
            margin-bottom: 10px;
            font-weight: 700;
        }
        
        .stat-card p {
            font-size: 1.1em;
            opacity: 0.9;
            font-weight: 500;
        }
        
        .stat-card.users {
            background: linear-gradient(135deg, #a29bfe, #6c5ce7);
        }
        
        .stat-card.orders {
            background: linear-gradient(135deg, #fd79a8, #e84393);
        }
        
        .stat-card.revenue {
            background: linear-gradient(135deg, #00b894, #00a085);
        }
        
        .stat-card.products {
            background: linear-gradient(135deg, #fdcb6e, #e17055);
        }
        
        .dashboard-modules {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
            gap: 30px;
            margin-bottom: 40px;
        }
        
        .module-card {
            background: white;
            border-radius: 20px;
            padding: 40px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            transition: all 0.3s ease;
            border: 1px solid #e9ecef;
            text-align: center;
        }
        
        .module-card:hover {
            transform: translateY(-8px);
            box-shadow: 0 20px 40px rgba(0,0,0,0.15);
        }
        
        .module-icon {
            font-size: 4em;
            margin-bottom: 25px;
            display: block;
        }
        
        .module-card h3 {
            color: #2c3e50;
            font-size: 1.6em;
            margin-bottom: 15px;
            font-weight: 600;
        }
        
        .module-card p {
            color: #7f8c8d;
            margin-bottom: 30px;
            line-height: 1.6;
            font-size: 1.1em;
        }
        
        .module-actions {
            display: flex;
            gap: 15px;
            justify-content: center;
            flex-wrap: wrap;
        }
        
        .btn {
            padding: 15px 30px;
            border: none;
            border-radius: 10px;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            font-size: 1em;
            font-weight: 600;
            transition: all 0.3s ease;
            text-align: center;
        }
        
        .btn:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 20px rgba(0,0,0,0.2);
        }
        
        .btn-primary {
            background: linear-gradient(135deg, #3498db, #2980b9);
            color: white;
        }
        
        .btn-success {
            background: linear-gradient(135deg, #27ae60, #2ecc71);
            color: white;
        }
        
        .btn-info {
            background: linear-gradient(135deg, #17a2b8, #138496);
            color: white;
        }
        
        .btn-warning {
            background: linear-gradient(135deg, #f39c12, #e67e22);
            color: white;
        }
        
        .btn-danger {
            background: linear-gradient(135deg, #e74c3c, #c0392b);
            color: white;
        }
        
        .quick-actions {
            background: #f8f9fa;
            padding: 30px;
            border-radius: 15px;
            margin-top: 30px;
        }
        
        .quick-actions h3 {
            color: #2c3e50;
            margin-bottom: 20px;
            text-align: center;
            font-size: 1.5em;
        }
        
        .quick-actions-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
        }
        
        .quick-action-btn {
            background: white;
            border: 2px solid #e9ecef;
            padding: 15px;
            border-radius: 10px;
            text-decoration: none;
            color: #2c3e50;
            font-weight: 600;
            text-align: center;
            transition: all 0.3s ease;
        }
        
        .quick-action-btn:hover {
            border-color: #3498db;
            color: #3498db;
            transform: translateY(-2px);
        }
    </style>
</head>
<body>
    <%
        User currentUser = (User) request.getAttribute("currentUser");
        Integer totalOrders = (Integer) request.getAttribute("totalOrders");
        Integer totalUsers = (Integer) request.getAttribute("totalUsers");
        Integer adminCount = (Integer) request.getAttribute("adminCount");
        Integer employeeCount = (Integer) request.getAttribute("employeeCount");
        Integer customerCount = (Integer) request.getAttribute("customerCount");
        
        int orderCount = totalOrders != null ? totalOrders : 0;
        int userCount = totalUsers != null ? totalUsers : 0;
        int adminUserCount = adminCount != null ? adminCount : 0;
        int empUserCount = employeeCount != null ? employeeCount : 0;
        int custUserCount = customerCount != null ? customerCount : 0;
    %>
    
    <div class="container">
        <div class="header">
            <h1>🍕 Admin Dashboard</h1>
            <p>PizzaConnect Restaurant Management System</p>
        </div>
        
        <div class="nav">
            <div class="welcome">
                Welcome back, <strong><%= currentUser != null ? currentUser.getName() : "Admin" %></strong>! 👋
            </div>
            <a href="Login?action=logout" class="logout">Logout</a>
        </div>
        
        <div class="content">
            <div class="stats">
                <div class="stat-card users">
                    <h3><%= userCount %></h3>
                    <p>👥 Total Users</p>
                </div>
                <div class="stat-card orders">
                    <h3><%= orderCount %></h3>
                    <p>🍕 Total Orders</p>
                </div>
                <div class="stat-card revenue">
                    <h3><%= adminUserCount %></h3>
                    <p>👑 Admins</p>
                </div>
                <div class="stat-card products">
                    <h3><%= empUserCount %></h3>
                    <p>👨‍💼 Employees</p>
                </div>
            </div>
            
            <!-- Additional Stats Row -->
            <div class="stats" style="margin-top: 20px;">
                <div class="stat-card" style="background: linear-gradient(135deg, #a29bfe, #6c5ce7);">
                    <h3><%= custUserCount %></h3>
                    <p>👥 Customers</p>
                </div>
                <div class="stat-card" style="background: linear-gradient(135deg, #fd79a8, #e84393);">
                    <h3>$2,450</h3>
                    <p>💰 Today's Revenue</p>
                </div>
                <div class="stat-card" style="background: linear-gradient(135deg, #fdcb6e, #e17055);">
                    <h3>25</h3>
                    <p>🍕 Menu Items</p>
                </div>
                <div class="stat-card" style="background: linear-gradient(135deg, #00b894, #00a085);">
                    <h3>98%</h3>
                    <p>📊 System Health</p>
                </div>
            </div>
            
            <div class="dashboard-modules">
                <div class="module-card">
                    <div class="module-icon">👥</div>
                    <h3>User Management</h3>
                    <p>Manage users, roles, and permissions. Add new staff members, update user information, and control access levels.</p>
                    <div class="module-actions">
                        <a href="admin" class="btn btn-primary">Manage Users</a>
                        <a href="adduser" class="btn btn-success">Add User</a>
                    </div>
                </div>
                
                <div class="module-card">
                    <div class="module-icon">🍕</div>
                    <h3>Order Management</h3>
                    <p>View and manage pizza orders. Track order status, process payments, and handle customer requests efficiently.</p>
                    <div class="module-actions">
                        <a href="manage-orders" class="btn btn-success">Manage Orders</a>
                        <a href="add-order" class="btn btn-primary">New Order</a>
                    </div>
                </div>
                
                <div class="module-card">
                    <div class="module-icon">📊</div>
                    <h3>Reports & Analytics</h3>
                    <p>View detailed sales reports, revenue analytics, and business insights to make data-driven decisions.</p>
                    <div class="module-actions">
                        <a href="#reports" class="btn btn-info">View Reports</a>
                        <a href="#analytics" class="btn btn-warning">Analytics</a>
                    </div>
                </div>
                
                <div class="module-card">
                    <div class="module-icon">🍽️</div>
                    <h3>Menu Management</h3>
                    <p>Manage pizza menu, prices, and availability. Add new items, update descriptions, and control inventory.</p>
                    <div class="module-actions">
                        <a href="inventory?action=list" class="btn btn-warning">Manage Menu</a>
                        <a href="#add-item" class="btn btn-success">Add Item</a>
                    </div>
                </div>
                
                <div class="module-card">
                    <div class="module-icon">⚙️</div>
                    <h3>System Settings</h3>
                    <p>Configure system parameters, restaurant settings, and customize the application according to your needs.</p>
                    <div class="module-actions">
                        <a href="#settings" class="btn btn-warning">Settings</a>
                        <a href="#config" class="btn btn-info">Configure</a>
                    </div>
                </div>
                
                <div class="module-card">
                    <div class="module-icon">📞</div>
                    <h3>Customer Support</h3>
                    <p>Handle customer inquiries, manage feedback, and provide support to ensure customer satisfaction.</p>
                    <div class="module-actions">
                        <a href="#support" class="btn btn-info">Support Center</a>
                        <a href="#feedback" class="btn btn-primary">View Feedback</a>
                    </div>
                </div>
            </div>
            
            <div class="quick-actions">
                <h3>🚀 Quick Actions</h3>
                <div class="quick-actions-grid">
                    <a href="manage-orders" class="quick-action-btn">📋 View Orders</a>
                    <a href="admin" class="quick-action-btn">👥 Manage Users</a>
                    <a href="add-order" class="quick-action-btn">➕ New Order</a>
                    <a href="#reports" class="quick-action-btn">📊 View Reports</a>
                    <a href="#menu" class="quick-action-btn">🍕 Manage Menu</a>
                    <a href="#settings" class="quick-action-btn">⚙️ Settings</a>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
