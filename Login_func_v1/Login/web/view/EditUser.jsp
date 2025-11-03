<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="models.User" %>
<%@ page import="java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit User - PizzaConnect</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://unpkg.com/lucide@latest"></script>
    <style>
        .nav-btn {
            width: 3rem;
            height: 3rem;
            border-radius: 0.75rem;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.2s;
        }
        .nav-btn:hover {
            transform: translateY(-2px);
        }
    </style>
</head>
<body class="flex h-screen bg-gray-50">

    <%
        String currentPath = request.getRequestURI();
        User currentUser = (User) request.getAttribute("currentUser");
        User editUser = (User) request.getAttribute("editUser");
        String message = (String) request.getAttribute("message");
        String error = (String) request.getAttribute("error");
        
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        String dobString = "";
        if (editUser != null && editUser.getDateOfBirth() != null) {
            dobString = sdf.format(editUser.getDateOfBirth());
        }
    %>
    
    <!-- Sidebar Navigation -->
    <div class="w-20 bg-gray-800 flex flex-col items-center py-6 space-y-8">
        <a href="${pageContext.request.contextPath}/home"
           class="nav-btn <%= currentPath.contains("/home") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
           title="Home">
            <i data-lucide="home" class="w-6 h-6"></i>
        </a>
        <div class="flex-1 flex flex-col space-y-6 mt-8">
            <a href="${pageContext.request.contextPath}/dashboard"
                class="nav-btn <%= currentPath.contains("/dashboard") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
                title="Dashboard">
                <i data-lucide="grid" class="w-6 h-6"></i>
            </a>
            
            <a href="${pageContext.request.contextPath}/orders"
                class="nav-btn <%= currentPath.contains("/orders") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
                title="Orders">
                <i data-lucide="file-text" class="w-6 h-6"></i>
            </a>

            <a href="${pageContext.request.contextPath}/manageproduct"
                class="nav-btn <%= currentPath.contains("/menu") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
                title="Menu">
                <i data-lucide="utensils" class="w-6 h-6"></i>
            </a>

            <a href="${pageContext.request.contextPath}/table" 
            class="nav-btn <%= currentPath.contains("/table") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
            title="Table Booking">
                <i data-lucide="rectangle-horizontal" class="w-6 h-6"></i>
            </a>

            <a href="${pageContext.request.contextPath}/discount"
                class="nav-btn <%= currentPath.contains("/discount") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
                title="Discount Programs">
                <i data-lucide="percent" class="w-6 h-6"></i>
            </a>

            <a href="${pageContext.request.contextPath}/notifications"
                class="nav-btn <%= currentPath.contains("/notifications") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
                title="Notifications">
                <i data-lucide="bell" class="w-6 h-6"></i>
            </a>

            <a href="${pageContext.request.contextPath}/admin"
                class="nav-btn <%= currentPath.contains("/admin") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
                title="Manage Users">
                <i data-lucide="users" class="w-6 h-6"></i>
            </a>
        </div>
        <a href="${pageContext.request.contextPath}/profile"
            class="nav-btn <%= currentPath.contains("/profile") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
            title="Profile">
            <i data-lucide="user" class="w-6 h-6"></i>
        </a>
        <a href="${pageContext.request.contextPath}/settings"
            class="nav-btn <%= currentPath.contains("/settings") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
            title="Settings">
            <i data-lucide="settings" class="w-6 h-6"></i>
        </a>
        <a href="${pageContext.request.contextPath}/logout"
           class="nav-btn <%= currentPath.contains("/logout") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
           title="Logout">
            <i data-lucide="log-out" class="w-6 h-6"></i>
        </a>
    </div>

    <!-- Main Content -->
    <div class="flex-1 flex flex-col overflow-hidden">
        <!-- Header -->
        <div class="bg-white border-b px-6 py-4 flex justify-between items-center">
            <div>
                <h1 class="text-2xl font-bold text-gray-800">Edit User</h1>
                <p class="text-sm text-gray-500">PizzaConnect Restaurant Management System</p>
            </div>
            <div class="text-gray-600">
                Welcome, <strong><%= currentUser != null ? currentUser.getName() : "Admin" %></strong>
            </div>
        </div>

        <!-- Content -->
        <div class="flex-1 p-6 overflow-auto">
            <!-- Navigation Breadcrumb -->
            <div class="bg-gray-50 p-4 rounded-xl mb-6 flex items-center space-x-2">
                <a href="admin" class="bg-gray-500 hover:bg-gray-600 text-white px-4 py-2 rounded-lg flex items-center">
                    <i data-lucide="arrow-left" class="w-4 h-4 mr-2"></i>
                    Back to Users
                </a>
                <a href="dashboard" class="bg-orange-500 hover:bg-orange-600 text-white px-4 py-2 rounded-lg">Dashboard</a>
            </div>

            <!-- Alert Messages -->
            <% if (message != null && !message.isEmpty()) { %>
            <div class="mb-4 p-4 bg-green-100 border border-green-400 text-green-700 rounded-lg">
                <div class="flex items-center">
                    <i data-lucide="check-circle" class="w-5 h-5 mr-2"></i>
                    <span><%= message %></span>
                </div>
            </div>
            <% } %>
            
            <% if (error != null && !error.isEmpty()) { %>
            <div class="mb-4 p-4 bg-red-100 border border-red-400 text-red-700 rounded-lg">
                <div class="flex items-center">
                    <i data-lucide="alert-circle" class="w-5 h-5 mr-2"></i>
                    <span><%= error %></span>
                </div>
            </div>
            <% } %>
            
            <% if (editUser != null) { %>
            <!-- User Information Card -->
            <div class="bg-blue-50 border border-blue-200 rounded-lg p-4 mb-6">
                <h4 class="text-lg font-semibold text-blue-800 mb-3 flex items-center">
                    <i data-lucide="user" class="w-5 h-5 mr-2"></i>
                    User Information
                </h4>
                <div class="grid grid-cols-1 md:grid-cols-3 gap-4 text-blue-700">
                    <div>
                        <strong>User ID:</strong> #<%= editUser.getUserID() %>
                    </div>
                    <div>
                        <strong>Current Status:</strong>
                        <span class="px-2 py-1 rounded-full text-xs <%= editUser.isActive() ? "bg-green-100 text-green-800" : "bg-red-100 text-red-800" %>">
                            <%= editUser.isActive() ? "Active" : "Inactive" %>
                        </span>
                    </div>
                    <div>
                        <strong>Role:</strong>
                        <% if (editUser.getRole() == 1) { %>
                            <span class="px-2 py-1 rounded-full text-xs bg-red-100 text-red-800">Admin</span>
                        <% } else if (editUser.getRole() == 2) { %>
                            <span class="px-2 py-1 rounded-full text-xs bg-orange-100 text-orange-800">Employee</span>
                        <% } else { %>
                            <span class="px-2 py-1 rounded-full text-xs bg-green-100 text-green-800">Customer</span>
                        <% } %>
                    </div>
                </div>
            </div>
            
            <!-- Edit User Form -->
            <div class="bg-white rounded-xl shadow-sm overflow-hidden">
                <div class="bg-gray-800 text-white px-6 py-4">
                    <h2 class="text-lg font-semibold flex items-center">
                        <i data-lucide="edit" class="w-5 h-5 mr-2"></i>
                        Edit User Account
                    </h2>
                </div>
                
                <form method="post" action="edituser" class="p-6">
                    <input type="hidden" name="userId" value="<%= editUser.getUserID() %>">
                    
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                        <div>
                            <label for="name" class="block text-sm font-medium text-gray-700 mb-2">Full Name *</label>
                            <input type="text" id="name" name="name" required 
                                   value="<%= editUser.getName() != null ? editUser.getName() : "" %>"
                                   class="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500"
                                   placeholder="Enter full name">
                        </div>
                        <div>
                            <label for="email" class="block text-sm font-medium text-gray-700 mb-2">Email Address *</label>
                            <input type="email" id="email" name="email" required 
                                   value="<%= editUser.getEmail() != null ? editUser.getEmail() : "" %>"
                                   class="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500"
                                   placeholder="Enter email address">
                        </div>
                        <div>
                            <label for="phone" class="block text-sm font-medium text-gray-700 mb-2">Phone Number *</label>
                            <input type="tel" id="phone" name="phone" required 
                                   value="<%= editUser.getPhone() != null ? editUser.getPhone() : "" %>"
                                   class="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500"
                                   placeholder="Enter phone number">
                        </div>
                        <div>
                            <label for="role" class="block text-sm font-medium text-gray-700 mb-2">User Role *</label>
                            <select id="role" name="role" required onchange="toggleEmployeeRole()"
                                    class="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500">
                                <option value="1" <%= editUser.getRole() == 1 ? "selected" : "" %>>Admin</option>
                                <option value="2" <%= editUser.getRole() == 2 ? "selected" : "" %>>Employee</option>
                                <option value="3" <%= editUser.getRole() == 3 ? "selected" : "" %>>Customer</option>
                            </select>
                        </div>
                        <%
                            String currentEmployeeRole = "";
                            if (editUser.getRole() == 2) {
                                // Get employee role from database
                                dao.EmployeeDAO empDAO = new dao.EmployeeDAO();
                                models.Employee emp = empDAO.getEmployeeByUserId(editUser.getUserID());
                                if (emp != null) {
                                    currentEmployeeRole = emp.getRole();
                                }
                            }
                        %>
                        <div id="employeeRoleDiv" style="display: <%= editUser.getRole() == 2 ? "block" : "none" %>;">
                            <label for="employeeRole" class="block text-sm font-medium text-gray-700 mb-2">Employee Role *</label>
                            <select id="employeeRole" name="employeeRole"
                                    class="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500">
                                <option value="">Select Employee Role</option>
                                <option value="Manager" <%= "Manager".equals(currentEmployeeRole) ? "selected" : "" %>>Manager</option>
                                <option value="Cashier" <%= "Cashier".equals(currentEmployeeRole) ? "selected" : "" %>>Cashier</option>
                                <option value="Waiter" <%= "Waiter".equals(currentEmployeeRole) ? "selected" : "" %>>Waiter</option>
                                <option value="Chef" <%= "Chef".equals(currentEmployeeRole) ? "selected" : "" %>>Chef</option>
                            </select>
                        </div>
                        <div>
                            <label for="password" class="block text-sm font-medium text-gray-700 mb-2">New Password (Leave blank to keep current)</label>
                            <input type="password" id="password" name="password" minlength="6"
                                   class="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500"
                                   placeholder="Enter new password">
                        </div>
                        <div>
                            <label for="confirmPassword" class="block text-sm font-medium text-gray-700 mb-2">Confirm New Password</label>
                            <input type="password" id="confirmPassword" name="confirmPassword" 
                                   class="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500"
                                   placeholder="Confirm new password">
                        </div>
                        <div>
                            <label for="dateOfBirth" class="block text-sm font-medium text-gray-700 mb-2">Date of Birth</label>
                            <input type="date" id="dateOfBirth" name="dateOfBirth" value="<%= dobString %>"
                                   class="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500">
                        </div>
                        <div>
                            <label for="gender" class="block text-sm font-medium text-gray-700 mb-2">Gender</label>
                            <select id="gender" name="gender" 
                                    class="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500">
                                <option value="">Select Gender</option>
                                <option value="Male" <%= "Male".equals(editUser.getGender()) ? "selected" : "" %>>Male</option>
                                <option value="Female" <%= "Female".equals(editUser.getGender()) ? "selected" : "" %>>Female</option>
                                <option value="Other" <%= "Other".equals(editUser.getGender()) ? "selected" : "" %>>Other</option>
                            </select>
                        </div>
                        <div>
                            <label for="isActive" class="block text-sm font-medium text-gray-700 mb-2">Account Status</label>
                            <select id="isActive" name="isActive" 
                                    class="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500">
                                <option value="true" <%= editUser.isActive() ? "selected" : "" %>>Active</option>
                                <option value="false" <%= !editUser.isActive() ? "selected" : "" %>>Inactive</option>
                            </select>
                        </div>
                    </div>
                    
                    <div class="flex justify-center space-x-4 mt-8">
                        <button type="submit" class="bg-blue-500 hover:bg-blue-600 text-white px-6 py-3 rounded-lg flex items-center">
                            <i data-lucide="save" class="w-4 h-4 mr-2"></i>
                            Save Changes
                        </button>
                        <a href="admin" class="bg-gray-500 hover:bg-gray-600 text-white px-6 py-3 rounded-lg flex items-center">
                            <i data-lucide="x" class="w-4 h-4 mr-2"></i>
                            Cancel
                        </a>
                    </div>
                </form>
            </div>
            <% } else { %>
            <div class="text-center py-12">
                <i data-lucide="user-x" class="w-16 h-16 text-gray-400 mx-auto mb-4"></i>
                <h3 class="text-lg font-medium text-gray-900 mb-2">User Not Found</h3>
                <p class="text-gray-500 mb-4">The user you're trying to edit could not be found.</p>
                <a href="admin" class="bg-gray-500 hover:bg-gray-600 text-white px-4 py-2 rounded-lg">Back to Users</a>
            </div>
            <% } %>
        </div>
    </div>
    
    <script>
        // Initialize Lucide icons
        lucide.createIcons();
        
        // Toggle employee role dropdown
        function toggleEmployeeRole() {
            const roleSelect = document.getElementById('role');
            const employeeRoleDiv = document.getElementById('employeeRoleDiv');
            const employeeRoleSelect = document.getElementById('employeeRole');
            
            if (roleSelect.value === '2') { // Employee role
                employeeRoleDiv.style.display = 'block';
                employeeRoleSelect.required = true;
            } else {
                employeeRoleDiv.style.display = 'none';
                employeeRoleSelect.required = false;
                employeeRoleSelect.value = '';
            }
        }
        
        // Password confirmation validation
        document.getElementById('confirmPassword').addEventListener('input', function() {
            const password = document.getElementById('password').value;
            const confirmPassword = this.value;
            
            if (password && confirmPassword && password !== confirmPassword) {
                this.setCustomValidity('Passwords do not match');
            } else {
                this.setCustomValidity('');
            }
        });
        
        // Form validation
        document.querySelector('form').addEventListener('submit', function(e) {
            const password = document.getElementById('password').value;
            const confirmPassword = document.getElementById('confirmPassword').value;
            const role = document.getElementById('role').value;
            const employeeRole = document.getElementById('employeeRole').value;
            
            if (password && confirmPassword && password !== confirmPassword) {
                e.preventDefault();
                alert('Passwords do not match!');
                return false;
            }
            
            if (password && password.length < 6) {
                e.preventDefault();
                alert('Password must be at least 6 characters long!');
                return false;
            }
            
            if (role === '2' && !employeeRole) {
                e.preventDefault();
                alert('Please select an Employee Role!');
                return false;
            }
        });
    </script>
</body>
</html>

