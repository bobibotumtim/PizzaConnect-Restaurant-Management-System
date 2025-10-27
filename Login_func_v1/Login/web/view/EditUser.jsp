<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="models.User" %>
<%@ page import="java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit User - PizzaConnect</title>
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
            max-width: 800px;
            margin: 0 auto;
            background: white;
            border-radius: 15px;
            box-shadow: 0 15px 35px rgba(0,0,0,0.1);
            overflow: hidden;
        }
        
        .header {
            background: linear-gradient(135deg, #f39c12, #e67e22);
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
            padding: 40px;
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
        
        .form-container {
            background: #f8f9fa;
            padding: 30px;
            border-radius: 10px;
            margin-bottom: 30px;
        }
        
        .form-group {
            margin-bottom: 25px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: #2c3e50;
        }
        
        .form-group input,
        .form-group select {
            width: 100%;
            padding: 12px;
            border: 2px solid #e9ecef;
            border-radius: 8px;
            font-size: 1em;
            transition: border-color 0.3s;
        }
        
        .form-group input:focus,
        .form-group select:focus {
            outline: none;
            border-color: #3498db;
            box-shadow: 0 0 0 3px rgba(52, 152, 219, 0.1);
        }
        
        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
        }
        
        .btn {
            padding: 12px 25px;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            font-size: 1em;
            font-weight: 600;
            transition: all 0.3s;
            text-align: center;
        }
        
        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(0,0,0,0.2);
        }
        
        .btn-primary {
            background: linear-gradient(135deg, #3498db, #2980b9);
            color: white;
        }
        
        .btn-success {
            background: linear-gradient(135deg, #27ae60, #2ecc71);
            color: white;
        }
        
        .btn-secondary {
            background: linear-gradient(135deg, #95a5a6, #7f8c8d);
            color: white;
        }
        
        .btn-danger {
            background: linear-gradient(135deg, #e74c3c, #c0392b);
            color: white;
        }
        
        .form-actions {
            display: flex;
            gap: 15px;
            justify-content: center;
            margin-top: 30px;
        }
        
        .user-info {
            background: #e8f4fd;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 20px;
            border-left: 4px solid #3498db;
        }
        
        .user-info h4 {
            color: #2c3e50;
            margin-bottom: 10px;
        }
        
        .user-info p {
            color: #555;
            margin-bottom: 5px;
        }
        
        .status-badge {
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 0.85em;
            font-weight: 600;
            text-transform: uppercase;
        }
        
        .status-active {
            background: #27ae60;
            color: white;
        }
        
        .status-inactive {
            background: #e74c3c;
            color: white;
        }
        
        .password-section {
            background: #fff3cd;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
            border-left: 4px solid #ffc107;
        }
        
        .password-section h5 {
            color: #856404;
            margin-bottom: 10px;
        }
        
        .password-section p {
            color: #856404;
            font-size: 0.9em;
        }
    </style>
</head>
<body>
    <%
        User currentUser = (User) request.getAttribute("currentUser");
        User editUser = (User) request.getAttribute("editUser");
        String message = (String) request.getAttribute("message");
        String error = (String) request.getAttribute("error");
        
        if (editUser == null) {
            response.sendRedirect("admin");
            return;
        }
        
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        String dateOfBirthStr = "";
        if (editUser.getDateOfBirth() != null) {
            dateOfBirthStr = sdf.format(editUser.getDateOfBirth());
        }
    %>
    
    <div class="container">
        <div class="header">
            <h1>✏️ Edit User</h1>
            <p>PizzaConnect Restaurant Management System</p>
        </div>
        
        <div class="nav">
            <div class="welcome">
                Welcome, <strong><%= currentUser != null ? currentUser.getName() : "Admin" %></strong> (Admin)
            </div>
            <div>
                <a href="admin" class="btn btn-secondary" style="margin-right: 10px;">← Back to Users</a>
                <a href="dashboard" class="btn btn-primary" style="margin-right: 10px;">Dashboard</a>
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
            
            <div class="user-info">
                <h4>👤 User Information</h4>
                <p><strong>User ID:</strong> <%= editUser.getUserID() %></p>
                <p><strong>Current Status:</strong> 
                    <span class="status-badge <%= editUser.isActive() ? "status-active" : "status-inactive" %>">
                        <%= editUser.isActive() ? "Active" : "Inactive" %>
                    </span>
                </p>
                <p><strong>Role:</strong> 
                    <% if (editUser.getRole() == 1) { %>
                        Admin
                    <% } else if (editUser.getRole() == 2) { %>
                        Employee
                    <% } else { %>
                        Customer
                    <% } %>
                </p>
            </div>
            
            <div class="form-container">
                <form method="post" action="edituser">
                    <input type="hidden" name="userId" value="<%= editUser.getUserID() %>">
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label for="name">Full Name *</label>
                            <input type="text" id="name" name="name" required 
                                   value="<%= editUser.getName() %>" placeholder="Enter full name">
                        </div>
                        <div class="form-group">
                            <label for="email">Email Address *</label>
                            <input type="email" id="email" name="email" required 
                                   value="<%= editUser.getEmail() %>" placeholder="Enter email address">
                        </div>
                    </div>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label for="phone">Phone Number *</label>
                            <input type="tel" id="phone" name="phone" required 
                                   value="<%= editUser.getPhone() %>" placeholder="Enter phone number">
                        </div>
                        <div class="form-group">
                            <label for="role">User Role *</label>
                            <select id="role" name="role" required>
                                <option value="">Select Role</option>
                                <option value="1" <%= editUser.getRole() == 1 ? "selected" : "" %>>Admin</option>
                                <option value="2" <%= editUser.getRole() == 2 ? "selected" : "" %>>Employee</option>
                                <option value="3" <%= editUser.getRole() == 3 ? "selected" : "" %>>Customer</option>
                            </select>
                        </div>
                    </div>
                    
                    <div class="password-section">
                        <h5>🔒 Password Management</h5>
                        <p>Leave password fields empty to keep current password unchanged.</p>
                    </div>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label for="password">New Password</label>
                            <input type="password" id="password" name="password" 
                                   placeholder="Enter new password (leave empty to keep current)">
                        </div>
                        <div class="form-group">
                            <label for="confirmPassword">Confirm New Password</label>
                            <input type="password" id="confirmPassword" name="confirmPassword" 
                                   placeholder="Confirm new password">
                        </div>
                    </div>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label for="dateOfBirth">Date of Birth</label>
                            <input type="date" id="dateOfBirth" name="dateOfBirth" 
                                   value="<%= dateOfBirthStr %>">
                        </div>
                        <div class="form-group">
                            <label for="gender">Gender</label>
                            <select id="gender" name="gender">
                                <option value="">Select Gender</option>
                                <option value="Male" <%= "Male".equals(editUser.getGender()) ? "selected" : "" %>>Male</option>
                                <option value="Female" <%= "Female".equals(editUser.getGender()) ? "selected" : "" %>>Female</option>
                                <option value="Other" <%= "Other".equals(editUser.getGender()) ? "selected" : "" %>>Other</option>
                            </select>
                        </div>
                    </div>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label for="isActive">Account Status</label>
                            <select id="isActive" name="isActive">
                                <option value="true" <%= editUser.isActive() ? "selected" : "" %>>Active</option>
                                <option value="false" <%= !editUser.isActive() ? "selected" : "" %>>Inactive</option>
                            </select>
                        </div>
                    </div>
                    
                    <div class="form-actions">
                        <button type="submit" class="btn btn-success">Update User</button>
                        <a href="admin" class="btn btn-secondary">Cancel</a>
                    </div>
                </form>
            </div>
        </div>
    </div>
    
    <script>
        // Password confirmation validation
        document.getElementById('confirmPassword').addEventListener('input', function() {
            const password = document.getElementById('password').value;
            const confirmPassword = this.value;
            
            if (password !== confirmPassword && password !== '') {
                this.setCustomValidity('Passwords do not match');
            } else {
                this.setCustomValidity('');
            }
        });
        
        // Form validation
        document.querySelector('form').addEventListener('submit', function(e) {
            const password = document.getElementById('password').value;
            const confirmPassword = document.getElementById('confirmPassword').value;
            
            if (password !== '' && password !== confirmPassword) {
                e.preventDefault();
                alert('Passwords do not match!');
                return false;
            }
            
            if (password !== '' && password.length < 6) {
                e.preventDefault();
                alert('Password must be at least 6 characters long!');
                return false;
            }
        });
    </script>
</body>
</html>
