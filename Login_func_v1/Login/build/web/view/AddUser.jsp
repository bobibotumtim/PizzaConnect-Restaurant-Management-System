<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="models.User" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add New User - PizzaConnect</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://unpkg.com/lucide@latest"></script>
</head>
<body class="bg-gray-50 min-h-screen ml-20">
    <%-- Include Sidebar and NavBar --%>
    <%@ include file="Sidebar.jsp" %>
    <%@ include file="NavBar.jsp" %>

    <%
        User currentUser = (User) request.getAttribute("currentUser");
        String message = (String) request.getAttribute("message");
        String error = (String) request.getAttribute("error");
    %>

    <!-- Main Content -->
    <div class="content-wrapper">
        <div class="p-6">
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
            
            <!-- Role Information -->
            <div class="bg-blue-50 border border-blue-200 rounded-lg p-4 mb-6">
                <h4 class="text-lg font-semibold text-blue-800 mb-3 flex items-center">
                    <i data-lucide="info" class="w-5 h-5 mr-2"></i>
                    User Role Information
                </h4>
                <ul class="space-y-2 text-blue-700">
                    <li class="flex items-center">
                        <i data-lucide="shield" class="w-4 h-4 mr-2 text-red-500"></i>
                        <strong>Admin (1):</strong> Full system access, can manage all users and orders
                    </li>
                    <li class="flex items-center">
                        <i data-lucide="briefcase" class="w-4 h-4 mr-2 text-orange-500"></i>
                        <strong>Employee (2):</strong> Can manage orders and view customer information
                    </li>
                    <li class="flex items-center">
                        <i data-lucide="user-check" class="w-4 h-4 mr-2 text-green-500"></i>
                        <strong>Customer (3):</strong> Can place orders and view their own information
                    </li>
                </ul>
            </div>
            
            <!-- Add User Form -->
            <div class="bg-white rounded-xl shadow-sm overflow-hidden">
                <div class="bg-gray-800 text-white px-6 py-4">
                    <h2 class="text-lg font-semibold flex items-center">
                        <i data-lucide="user-plus" class="w-5 h-5 mr-2"></i>
                        Create New User Account
                    </h2>
                </div>
                
                <form method="post" action="adduser" class="p-6">
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                        <div>
                            <label for="name" class="block text-sm font-medium text-gray-700 mb-2">Full Name *</label>
                            <input type="text" id="name" name="name" required 
                                   class="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500"
                                   placeholder="Enter full name">
                        </div>
                        <div>
                            <label for="email" class="block text-sm font-medium text-gray-700 mb-2">Email Address *</label>
                            <input type="email" id="email" name="email" required 
                                   pattern="^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
                                   class="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500"
                                   placeholder="example@domain.com"
                                   title="Enter a valid email address">
                            <p class="text-xs text-gray-500 mt-1">Example: user@example.com</p>
                        </div>
                        <div>
                            <label for="phone" class="block text-sm font-medium text-gray-700 mb-2">Phone Number *</label>
                            <input type="tel" id="phone" name="phone" required 
                                   pattern="^0[1-9]\d{8}$"
                                   maxlength="10"
                                   class="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500"
                                   placeholder="0912345678"
                                   title="Phone must be 10 digits starting with 0[1-9]">
                            <p class="text-xs text-gray-500 mt-1">10 digits starting with 0[1-9] (e.g., 0912345678)</p>
                        </div>
                        <div>
                            <label for="role" class="block text-sm font-medium text-gray-700 mb-2">User Role *</label>
                            <select id="role" name="role" required onchange="toggleEmployeeRole()"
                                    class="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500">
                                <option value="">Select Role</option>
                                <option value="1">Admin</option>
                                <option value="2">Employee</option>
                                <option value="3">Customer</option>
                            </select>
                        </div>
                        <div id="employeeRoleDiv" style="display: none;">
                            <label for="employeeRole" class="block text-sm font-medium text-gray-700 mb-2">Employee Role *</label>
                            <select id="employeeRole" name="employeeRole"
                                    class="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500">
                                <option value="">Select Employee Role</option>
                                <option value="Manager">Manager</option>
                                <option value="Waiter">Waiter</option>
                                <option value="Chef">Chef</option>
                            </select>
                        </div>
                        <div>
                            <label for="password" class="block text-sm font-medium text-gray-700 mb-2">Password *</label>
                            <input type="password" id="password" name="password" required minlength="8"
                                   pattern="^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$"
                                   class="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500"
                                   placeholder="Min 8 chars, 1 uppercase, 1 lowercase, 1 digit"
                                   title="Password must be at least 8 characters with 1 uppercase, 1 lowercase, and 1 digit">
                            <p class="text-xs text-gray-500 mt-1">Must contain: 1 uppercase, 1 lowercase, 1 digit, min 8 characters</p>
                        </div>
                        <div>
                            <label for="confirmPassword" class="block text-sm font-medium text-gray-700 mb-2">Confirm Password *</label>
                            <input type="password" id="confirmPassword" name="confirmPassword" required 
                                   class="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500"
                                   placeholder="Confirm password">
                        </div>
                        <div>
                            <label for="dateOfBirth" class="block text-sm font-medium text-gray-700 mb-2">Date of Birth</label>
                            <input type="date" id="dateOfBirth" name="dateOfBirth"
                                   class="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500">
                        </div>
                        <div>
                            <label for="gender" class="block text-sm font-medium text-gray-700 mb-2">Gender</label>
                            <select id="gender" name="gender" 
                                    class="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-orange-500">
                                <option value="">Select Gender</option>
                                <option value="Male">Male</option>
                                <option value="Female">Female</option>
                                <option value="Other">Other</option>
                            </select>
                        </div>
                    </div>
                    
                    <div class="flex justify-center space-x-4 mt-8">
                        <button type="submit" class="bg-green-500 hover:bg-green-600 text-white px-6 py-3 rounded-lg flex items-center">
                            <i data-lucide="user-plus" class="w-4 h-4 mr-2"></i>
                            Create User
                        </button>
                        <a href="admin" class="bg-gray-500 hover:bg-gray-600 text-white px-6 py-3 rounded-lg flex items-center">
                            <i data-lucide="x" class="w-4 h-4 mr-2"></i>
                            Cancel
                        </a>
                    </div>
                </form>
            </div>
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
            
            if (password !== confirmPassword) {
                this.setCustomValidity('Passwords do not match');
            } else {
                this.setCustomValidity('');
            }
        });
        
        // Form validation
        document.querySelector('form').addEventListener('submit', function(e) {
            const email = document.getElementById('email').value;
            const phone = document.getElementById('phone').value;
            const password = document.getElementById('password').value;
            const confirmPassword = document.getElementById('confirmPassword').value;
            const role = document.getElementById('role').value;
            const employeeRole = document.getElementById('employeeRole').value;
            
            // Validate email
            const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
            if (!emailRegex.test(email)) {
                e.preventDefault();
                alert('Invalid email format!');
                return false;
            }
            
            // Validate phone: 0[1-9] followed by 8 digits
            const phoneRegex = /^0[1-9]\d{8}$/;
            if (!phoneRegex.test(phone)) {
                e.preventDefault();
                alert('Invalid phone format! Must be 10 digits starting with 0[1-9]');
                return false;
            }
            
            if (password !== confirmPassword) {
                e.preventDefault();
                alert('Passwords do not match!');
                return false;
            }
            
            // Validate password: >=8 chars, 1 uppercase, 1 lowercase, 1 digit
            const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$/;
            if (!passwordRegex.test(password)) {
                e.preventDefault();
                alert('Password must be at least 8 characters with 1 uppercase, 1 lowercase, and 1 digit!');
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
