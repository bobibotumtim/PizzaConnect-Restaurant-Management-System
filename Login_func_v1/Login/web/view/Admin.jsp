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

            /* Role Filter Styles */
            #roleFilter {
                padding: 8px 12px;
                border: 2px solid #e9ecef;
                border-radius: 5px;
                background: white;
                font-size: 0.9em;
                font-weight: 500;
                color: #2c3e50;
                cursor: pointer;
                transition: all 0.3s ease;
            }

            #roleFilter:focus {
                outline: none;
                border-color: #3498db;
                box-shadow: 0 0 0 3px rgba(52, 152, 219, 0.1);
            }

            #roleFilter:hover {
                border-color: #3498db;
            }

            .filter-container {
                display: flex;
                gap: 10px;
                align-items: center;
            }

            .filter-label {
                color: white;
                font-weight: 500;
                font-size: 0.9em;
            }

            /* Modal Styles */
            .modal {
                display: none;
                position: fixed;
                z-index: 1000;
                left: 0;
                top: 0;
                width: 100%;
                height: 100%;
                background-color: rgba(0,0,0,0.5);
                animation: fadeIn 0.3s ease;
            }

            .modal-content {
                background-color: white;
                margin: 15% auto;
                padding: 0;
                border-radius: 15px;
                width: 400px;
                box-shadow: 0 20px 40px rgba(0,0,0,0.3);
                animation: slideIn 0.3s ease;
                overflow: hidden;
            }

            .modal-header {
                background: linear-gradient(135deg, #e74c3c, #c0392b);
                color: white;
                padding: 20px;
                text-align: center;
                position: relative;
            }

            .modal-header .warning-icon {
                font-size: 3em;
                margin-bottom: 10px;
                display: block;
            }

            .modal-body {
                padding: 30px;
                text-align: center;
            }

            .modal-title {
                font-size: 1.5em;
                font-weight: 700;
                color: #2c3e50;
                margin-bottom: 15px;
            }

            .modal-message {
                color: #7f8c8d;
                font-size: 1.1em;
                line-height: 1.5;
                margin-bottom: 30px;
            }

            .modal-actions {
                display: flex;
                gap: 15px;
                justify-content: center;
            }

            .modal-btn {
                padding: 12px 30px;
                border: none;
                border-radius: 8px;
                font-size: 1em;
                font-weight: 600;
                cursor: pointer;
                transition: all 0.3s ease;
                min-width: 100px;
            }

            .modal-btn-yes {
                background: linear-gradient(135deg, #e74c3c, #c0392b);
                color: white;
            }

            .modal-btn-yes:hover {
                background: linear-gradient(135deg, #c0392b, #a93226);
                transform: translateY(-2px);
                box-shadow: 0 5px 15px rgba(231, 76, 60, 0.4);
            }

            .modal-btn-no {
                background: linear-gradient(135deg, #34495e, #2c3e50);
                color: white;
            }

            .modal-btn-no:hover {
                background: linear-gradient(135deg, #2c3e50, #1b2631);
                transform: translateY(-2px);
                box-shadow: 0 5px 15px rgba(52, 73, 94, 0.4);
            }

            .modal-btn-warning {
                background: linear-gradient(135deg, #f39c12, #e67e22);
                color: white;
            }

            .modal-btn-warning:hover {
                background: linear-gradient(135deg, #e67e22, #d35400);
                transform: translateY(-2px);
                box-shadow: 0 5px 15px rgba(243, 156, 18, 0.4);
            }

            @keyframes fadeIn {
                from {
                    opacity: 0;
                }
                to {
                    opacity: 1;
                }
            }

            @keyframes slideIn {
                from {
                    opacity: 0;
                    transform: translateY(-50px) scale(0.9);
                }
                to {
                    opacity: 1;
                    transform: translateY(0) scale(1);
                }
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
                    Welcome, <strong><%= currentUser != null ? currentUser.getName() : "Admin" %></strong> (Admin)
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
                            <a href="adduser" class="btn btn-success" style="margin-right: 10px;" title="Add New User">+ Add User</a>
                            <a href="#user-management" class="btn btn-primary" onclick="scrollToUserManagement()">Manage Users</a>
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
                    <div class="table-header" style="display: flex; justify-content: space-between; align-items: center;">
                        <span>👥 User Management</span>
                        <div class="filter-container">
                            <span class="filter-label">Filter by Role:</span>
                            <select id="roleFilter" onchange="filterUsersByRole()">
                                <option value="all">All Roles</option>
                                <option value="1">Admin</option>
                                <option value="2">Employee</option>
                                <option value="3">Customer</option>
                            </select>
                            <a href="adduser" class="btn btn-success" style="margin: 0;" title="Add New User">+ Add New User</a>
                        </div>
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
                                <th>Name</th>
                                <th>Email</th>
                                <th>Phone</th>
                                <th>Role</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (User user : users) { %>
                            <tr data-role="<%= user.getRole() %>">
                                <td><%= user.getUserID() %></td>
                                <td><strong><%= user.getName() %></strong></td>
                                <td><%= user.getEmail() %></td>
                                <td><%= user.getPhone() %></td>
                                <td>
                                    <% if (user.getRole() == 1) { %>
                                    <span class="role-badge role-admin">Admin</span>
                                    <% } else if (user.getRole() == 2) { %>
                                    <span class="role-badge role-user">Employee</span>
                                    <% } else { %>
                                    <span class="role-badge role-user">Customer</span>
                                    <% } %>
                                </td>
                                <td>
                                    <% if (user.isActive()) { %>
                                    <span style="color: #27ae60; font-weight: 600;">✓ Active</span>
                                    <% } else { %>
                                    <span style="color: #e74c3c; font-weight: 600;">✗ Inactive</span>
                                    <% } %>
                                </td>
                                <td>
                                    <% if (currentUser != null && user.getUserID() != currentUser.getUserID()) { %>
                                    <a href="edituser?id=<%= user.getUserID() %>" class="btn btn-edit">Edit</a>
                                    <% if (user.isActive()) { %>
                                    <button type="button" class="btn btn-warning suspend-btn" data-user-id="<%= user.getUserID() %>">Suspend</button>
                                    <% } else { %>
                                    <button type="button" class="btn btn-success activate-btn" data-user-id="<%= user.getUserID() %>">Activate</button>
                                    <% } %>
                                    <button type="button" class="btn btn-danger delete-btn" data-user-id="<%= user.getUserID() %>">Delete</button>
                                    <% } else { %>
                                    <span style="color: #7f8c8d; font-style: italic;">Current User</span>
                                    <% } %>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                    <!-- Pagination -->
                    <div class="pagination-container">
                        <ul class="pagination">
                            <% 
                                int currentPage = (int) request.getAttribute("currentPage");
                                int totalPages = (int) request.getAttribute("totalPages");

                                if (totalPages > 1) {
                            %>
                            <!-- Nút Previous -->
                            <li class="page-item <%= (currentPage == 1 ? "disabled" : "") %>">
                                <a class="page-link" href="admin?page=<%= (currentPage - 1) %>">Previous</a>
                            </li>

                            <!-- Danh sách các trang -->
                            <% for (int i = 1; i <= totalPages; i++) { %>
                            <li class="page-item <%= (i == currentPage ? "active" : "") %>">
                                <a class="page-link" href="admin?page=<%= i %>"><%= i %></a>
                            </li>
                            <% } %>

                            <!-- Nút Next -->
                            <li class="page-item <%= (currentPage == totalPages ? "disabled" : "") %>">
                                <a class="page-link" href="admin?page=<%= (currentPage + 1) %>">Next</a>
                            </li>
                            <% } %>
                        </ul>
                    </div>

                    <% } %>
                </div>
            </div>
        </div>

        <!-- Delete Confirmation Modal -->
        <div id="deleteModal" class="modal">
            <div class="modal-content">
                <div class="modal-header">
                    <span class="warning-icon">⚠️</span>
                </div>
                <div class="modal-body">
                    <div class="modal-title">Delete This User?</div>
                    <div class="modal-message">Are you sure you want to delete this user? This action cannot be undone.</div>
                    <div class="modal-actions">
                        <button class="modal-btn modal-btn-yes" onclick="confirmDelete()">Yes</button>
                        <button class="modal-btn modal-btn-no" onclick="closeModal('deleteModal')">No</button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Suspend Confirmation Modal -->
        <div id="suspendModal" class="modal">
            <div class="modal-content">
                <div class="modal-header" style="background: linear-gradient(135deg, #f39c12, #e67e22);">
                    <span class="warning-icon">⚠️</span>
                </div>
                <div class="modal-body">
                    <div class="modal-title">Suspend This User?</div>
                    <div class="modal-message">Are you sure you want to suspend this user? They will not be able to access the system.</div>
                    <div class="modal-actions">
                        <button class="modal-btn modal-btn-warning" onclick="confirmSuspend()">Yes</button>
                        <button class="modal-btn modal-btn-no" onclick="closeModal('suspendModal')">No</button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Activate Confirmation Modal -->
        <div id="activateModal" class="modal">
            <div class="modal-content">
                <div class="modal-header" style="background: linear-gradient(135deg, #27ae60, #2ecc71);">
                    <span class="warning-icon">✅</span>
                </div>
                <div class="modal-body">
                    <div class="modal-title">Activate This User?</div>
                    <div class="modal-message">Are you sure you want to activate this user? They will be able to access the system again.</div>
                    <div class="modal-actions">
                        <button class="modal-btn modal-btn-yes" style="background: linear-gradient(135deg, #27ae60, #2ecc71);" onclick="confirmActivate()">Yes</button>
                        <button class="modal-btn modal-btn-no" onclick="closeModal('activateModal')">No</button>
                    </div>
                </div>
            </div>
        </div>

        <script>
            // Function to scroll to user management section
            function scrollToUserManagement() {
                const userManagementSection = document.querySelector('.table-container');
                if (userManagementSection) {
                    userManagementSection.scrollIntoView({behavior: 'smooth'});
                }
            }

            // Function to filter users by role
            function filterUsersByRole() {
                const selectedRole = document.getElementById('roleFilter').value;
                const rows = document.querySelectorAll('tbody tr[data-role]');

                rows.forEach(function (row) {
                    if (selectedRole === 'all' || row.getAttribute('data-role') === selectedRole) {
                        row.style.display = '';
                    } else {
                        row.style.display = 'none';
                    }
                });

                // Update table message if no rows are visible
                updateTableMessage();
            }

            // Function to update table message based on visible rows
            function updateTableMessage() {
                const visibleRows = document.querySelectorAll('tbody tr[data-role]:not([style*="display: none"])');
                const selectedRole = document.getElementById('roleFilter').value;

                if (visibleRows.length === 0) {
                    // Show "No users found" message
                    let noUsersMessage = document.querySelector('.no-users-message');
                    if (!noUsersMessage) {
                        noUsersMessage = document.createElement('tr');
                        noUsersMessage.className = 'no-users-message';
                        noUsersMessage.innerHTML = '<td colspan="7" style="text-align: center; padding: 50px; color: #7f8c8d; font-style: italic;">No users found for selected role</td>';
                        document.querySelector('tbody').appendChild(noUsersMessage);
                    }
                    noUsersMessage.style.display = '';
                } else {
                    // Hide "No users found" message
                    const noUsersMessage = document.querySelector('.no-users-message');
                    if (noUsersMessage) {
                        noUsersMessage.style.display = 'none';
                    }
                }
            }

            // Initialize filter on page load
            document.addEventListener('DOMContentLoaded', function () {
                filterUsersByRole();

                // Add event listeners for action buttons
                document.querySelectorAll('.delete-btn').forEach(btn => {
                    btn.addEventListener('click', function () {
                        const userId = this.getAttribute('data-user-id');
                        showDeleteModal(userId);
                    });
                });

                document.querySelectorAll('.suspend-btn').forEach(btn => {
                    btn.addEventListener('click', function () {
                        const userId = this.getAttribute('data-user-id');
                        showSuspendModal(userId);
                    });
                });

                document.querySelectorAll('.activate-btn').forEach(btn => {
                    btn.addEventListener('click', function () {
                        const userId = this.getAttribute('data-user-id');
                        showActivateModal(userId);
                    });
                });
            });

            // Modal functions
            let currentUserId = null;

            function showDeleteModal(userId) {
                currentUserId = userId;
                document.getElementById('deleteModal').style.display = 'block';
            }

            function showSuspendModal(userId) {
                currentUserId = userId;
                document.getElementById('suspendModal').style.display = 'block';
            }

            function showActivateModal(userId) {
                currentUserId = userId;
                document.getElementById('activateModal').style.display = 'block';
            }

            function closeModal(modalId) {
                document.getElementById(modalId).style.display = 'none';
                currentUserId = null;
            }

            function confirmDelete() {
                if (currentUserId) {
                    // Create and submit form
                    const form = document.createElement('form');
                    form.method = 'POST';
                    form.action = 'admin';

                    const actionInput = document.createElement('input');
                    actionInput.type = 'hidden';
                    actionInput.name = 'action';
                    actionInput.value = 'delete';
                    form.appendChild(actionInput);

                    const userIdInput = document.createElement('input');
                    userIdInput.type = 'hidden';
                    userIdInput.name = 'userId';
                    userIdInput.value = currentUserId;
                    form.appendChild(userIdInput);

                    document.body.appendChild(form);
                    form.submit();
                }
            }

            function confirmSuspend() {
                if (currentUserId) {
                    // Create and submit form
                    const form = document.createElement('form');
                    form.method = 'POST';
                    form.action = 'admin';

                    const actionInput = document.createElement('input');
                    actionInput.type = 'hidden';
                    actionInput.name = 'action';
                    actionInput.value = 'suspend';
                    form.appendChild(actionInput);

                    const userIdInput = document.createElement('input');
                    userIdInput.type = 'hidden';
                    userIdInput.name = 'userId';
                    userIdInput.value = currentUserId;
                    form.appendChild(userIdInput);

                    document.body.appendChild(form);
                    form.submit();
                }
            }

            function confirmActivate() {
                if (currentUserId) {
                    // Create and submit form
                    const form = document.createElement('form');
                    form.method = 'POST';
                    form.action = 'admin';

                    const actionInput = document.createElement('input');
                    actionInput.type = 'hidden';
                    actionInput.name = 'action';
                    actionInput.value = 'activate';
                    form.appendChild(actionInput);

                    const userIdInput = document.createElement('input');
                    userIdInput.type = 'hidden';
                    userIdInput.name = 'userId';
                    userIdInput.value = currentUserId;
                    form.appendChild(userIdInput);

                    document.body.appendChild(form);
                    form.submit();
                }
            }

            // Close modal when clicking outside
            window.onclick = function (event) {
                const modals = document.querySelectorAll('.modal');
                modals.forEach(modal => {
                    if (event.target === modal) {
                        modal.style.display = 'none';
                        currentUserId = null;
                    }
                });
            }
        </script>
    </body>
</html>