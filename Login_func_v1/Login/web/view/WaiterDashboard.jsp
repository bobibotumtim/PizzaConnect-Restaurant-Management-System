<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="models.User" %>
<%@ page import="models.Employee" %>
<%
    HttpSession userSession = request.getSession(false);
    User user = (userSession != null) ? (User) userSession.getAttribute("user") : null;
    Employee employee = (userSession != null) ? (Employee) userSession.getAttribute("employee") : null;
    
    if (user == null || user.getRole() != 2) {
        response.sendRedirect("view/Login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Waiter Dashboard - PizzaConnect</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://unpkg.com/lucide@latest"></script>
    <style>
        .menu-card {
            transition: transform 0.3s, box-shadow 0.3s;
        }
        
        .menu-card:hover {
            transform: translateY(-8px);
            box-shadow: 0 20px 25px -5px rgba(0,0,0,0.1);
        }
    </style>
</head>
<body class="bg-gray-50">
    <!-- Top Navigation Bar -->
    <div class="bg-white shadow-md border-b px-6 py-3 flex items-center justify-between">
        <div class="flex items-center gap-4">
            <div class="text-2xl font-bold text-orange-600">🍕 PizzaConnect</div>
        </div>
        <div class="flex items-center gap-3">
            <div class="text-right">
                <div class="font-semibold text-gray-800"><%= employee != null ? employee.getName() : user.getName() %></div>
                <div class="text-xs text-gray-500"><%= user.getRole() == 1 ? "Admin" : "Waiter" %></div>
            </div>
            <a href="Login?action=logout" class="bg-red-500 text-white px-4 py-2 rounded-lg hover:bg-red-600 shadow-sm hover:shadow-md transition-all duration-200">
                Logout
            </a>
        </div>
    </div>
    
    <div class="content-wrapper">
        <div class="max-w-7xl mx-auto px-6 py-8">
            
            <!-- Welcome Section -->
            <div class="mb-8 bg-white rounded-xl shadow-md p-8 text-center">
                <div class="inline-flex items-center justify-center w-20 h-20 bg-gradient-to-br from-orange-400 to-orange-600 rounded-full mb-4">
                    <i data-lucide="user" class="w-10 h-10 text-white"></i>
                </div>
                <h1 class="text-4xl font-bold text-gray-800 mb-2">Welcome, <%= employee != null ? employee.getName() : user.getName() %>!</h1>
                <p class="text-gray-600">Welcome to Pizza Store Restaurant Management System</p>
            </div>
            
            <!-- Menu Grid -->
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                <!-- POS -->
                <a href="pos" class="menu-card bg-white rounded-xl shadow-md overflow-hidden block">
                    <div class="h-32 bg-gradient-to-br from-orange-400 to-orange-600 flex items-center justify-center">
                        <i data-lucide="shopping-cart" class="w-16 h-16 text-white"></i>
                    </div>
                    <div class="p-6">
                        <div class="text-sm text-orange-600 font-semibold mb-2">Sales</div>
                        <h3 class="text-xl font-bold text-gray-800 mb-2">Point of Sale (POS)</h3>
                        <p class="text-gray-600 text-sm">
                            Create new orders, add items, and process payments for customers
                        </p>
                    </div>
                </a>
                
                <!-- Assign Tables -->
                <a href="assign-table" class="menu-card bg-white rounded-xl shadow-md overflow-hidden block">
                    <div class="h-32 bg-gradient-to-br from-orange-400 to-orange-600 flex items-center justify-center">
                        <i data-lucide="layout-grid" class="w-16 h-16 text-white"></i>
                    </div>
                    <div class="p-6">
                        <div class="text-sm text-orange-600 font-semibold mb-2">Tables</div>
                        <h3 class="text-xl font-bold text-gray-800 mb-2">Table Management</h3>
                        <p class="text-gray-600 text-sm">
                            View table status, check orders and manage assigned tables
                        </p>
                    </div>
                </a>
                
                <!-- Waiter Monitor -->
                <a href="WaiterMonitor" class="menu-card bg-white rounded-xl shadow-md overflow-hidden block">
                    <div class="h-32 bg-gradient-to-br from-orange-400 to-orange-600 flex items-center justify-center">
                        <i data-lucide="bell" class="w-16 h-16 text-white"></i>
                    </div>
                    <div class="p-6">
                        <div class="text-sm text-orange-600 font-semibold mb-2">Kitchen</div>
                        <h3 class="text-xl font-bold text-gray-800 mb-2">Dish Monitor</h3>
                        <p class="text-gray-600 text-sm">
                            Track ready dishes from kitchen and mark dishes as served
                        </p>
                    </div>
                </a>
                
                <!-- Manage Orders -->
                <a href="manage-orders" class="menu-card bg-white rounded-xl shadow-md overflow-hidden block">
                    <div class="h-32 bg-gradient-to-br from-orange-400 to-orange-600 flex items-center justify-center">
                        <i data-lucide="file-text" class="w-16 h-16 text-white"></i>
                    </div>
                    <div class="p-6">
                        <div class="text-sm text-orange-600 font-semibold mb-2">Orders</div>
                        <h3 class="text-xl font-bold text-gray-800 mb-2">Order Management</h3>
                        <p class="text-gray-600 text-sm">
                            View order details, update status and handle customer requests
                        </p>
                    </div>
                </a>
                
                <!-- Profile -->
                <a href="profile" class="menu-card bg-white rounded-xl shadow-md overflow-hidden block">
                    <div class="h-32 bg-gradient-to-br from-orange-400 to-orange-600 flex items-center justify-center">
                        <i data-lucide="user-circle" class="w-16 h-16 text-white"></i>
                    </div>
                    <div class="p-6">
                        <div class="text-sm text-orange-600 font-semibold mb-2">Account</div>
                        <h3 class="text-xl font-bold text-gray-800 mb-2">Personal Profile</h3>
                        <p class="text-gray-600 text-sm">
                            View and update personal information, change password
                        </p>
                    </div>
                </a>
            </div>
        </div>
    </div>
    
    <script>
        // Initialize Lucide icons
        document.addEventListener('DOMContentLoaded', function() {
            if (typeof lucide !== 'undefined') {
                lucide.createIcons();
            }
        });
    </script>
</body>
</html>
