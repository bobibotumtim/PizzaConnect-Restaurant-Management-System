<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="models.User" %>
<!DOCTYPE html>
<html lang="en">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>User Management - PizzaConnect</title>
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
        <% String currentPath=request.getRequestURI(); User currentUser=(User)
            request.getAttribute("currentUser"); List<User> users = (List<User>) request.getAttribute("users");
                String message = (String) request.getAttribute("message");
                String error = (String) request.getAttribute("error");
                Integer totalOrders = (Integer) request.getAttribute("totalOrders");
                String selectedRole = (String) request.getAttribute("selectedRole");
                if (selectedRole == null || selectedRole.trim().isEmpty()) {
                selectedRole = "all";
                }

                String roleParam = "";
                if (!"all".equalsIgnoreCase(selectedRole)) {
                roleParam = "&roleFilter=" + selectedRole;
                }

                // Calculate stats
                int totalUsers = users != null ? users.size() : 0;
                int adminCount = 0;
                int employeeCount = 0;
                int customerCount = 0;
                if (users != null) {
                for (User user : users) {
                if (user.getRole() == 1) adminCount++;
                else if (user.getRole() == 2) employeeCount++;
                else if (user.getRole() == 3) customerCount++;
                }
                }
                int orderCount = totalOrders != null ? totalOrders : 0;
        %>

        <!-- Sidebar Navigation -->
        <div class="w-20 bg-gray-800 flex flex-col items-center py-6 space-y-8">
            <a href="${pageContext.request.contextPath}/home" class="nav-btn <%= currentPath.contains("/home") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>" title="Home">
                <i data-lucide="home" class="w-6 h-6"></i>
            </a>
            <div class="flex-1 flex flex-col space-y-6 mt-8">
                <a href="${pageContext.request.contextPath}/dashboard" class="nav-btn <%= currentPath.contains("/dashboard") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>" title="Dashboard">
                    <i data-lucide="grid" class="w-6 h-6"></i>
                </a>

                <a href="${pageContext.request.contextPath}/orders" class="nav-btn <%= currentPath.contains("/orders") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>" title="Orders">
                    <i data-lucide="file-text" class="w-6 h-6"></i>
                </a>

                <a href="${pageContext.request.contextPath}/manageproduct" class="nav-btn <%= currentPath.contains("/menu") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>" title="Menu">
                    <i data-lucide="utensils" class="w-6 h-6"></i>
                </a>

                <a href="${pageContext.request.contextPath}/table" class="nav-btn <%= currentPath.contains("/table") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>" title="Table Booking">
                    <i data-lucide="rectangle-horizontal" class="w-6 h-6"></i>
                </a>

                <a href="${pageContext.request.contextPath}/discount" class="nav-btn <%= currentPath.contains("/discount") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>" title="Discount Programs">
                    <i data-lucide="percent" class="w-6 h-6"></i>
                </a>

                <a href="${pageContext.request.contextPath}/notifications" class="nav-btn <%= currentPath.contains("/notifications") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>" title="Notifications">
                    <i data-lucide="bell" class="w-6 h-6"></i>
                </a>

                <a href="${pageContext.request.contextPath}/admin" class="nav-btn <%= currentPath.contains("/admin") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>" title="Manage Users">
                    <i data-lucide="users" class="w-6 h-6"></i>
                </a>
            </div>
            <a href="${pageContext.request.contextPath}/profile" class="nav-btn <%= currentPath.contains("/profile") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>" title="Profile">
                <i data-lucide="user" class="w-6 h-6"></i>
            </a>
            <a href="${pageContext.request.contextPath}/settings" class="nav-btn <%= currentPath.contains("/settings") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>" title="Settings">
                <i data-lucide="settings" class="w-6 h-6"></i>
            </a>
            <a href="${pageContext.request.contextPath}/logout" class="nav-btn <%= currentPath.contains("/logout") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>" title="Logout">
                <i data-lucide="log-out" class="w-6 h-6"></i>
            </a>
        </div>

        <!-- Main Content -->
        <div class="flex-1 flex flex-col overflow-hidden">
            <!-- Header -->
            <div class="bg-white border-b px-6 py-4 flex justify-between items-center">
                <div>
                    <h1 class="text-2xl font-bold text-gray-800">User Management</h1>
                    <p class="text-sm text-gray-500">PizzaConnect Restaurant Management System</p>
                </div>
                <div class="text-gray-600">
                    Welcome, <strong>
                        <%= currentUser !=null ? currentUser.getName() : "Admin" %>
                    </strong>
                </div>
            </div>

            <!-- Content -->
            <div class="flex-1 p-6 overflow-auto">
                <!-- Alert Messages -->
                <% if (message !=null && !message.isEmpty()) { %>
                <div
                    class="mb-4 p-4 bg-green-100 border border-green-400 text-green-700 rounded-lg">
                    <div class="flex items-center">
                        <i data-lucide="check-circle" class="w-5 h-5 mr-2"></i>
                        <span>
                            <%= message %>
                        </span>
                    </div>
                </div>
                <% } %>

                <% if (error !=null && !error.isEmpty()) { %>
                <div
                    class="mb-4 p-4 bg-red-100 border border-red-400 text-red-700 rounded-lg">
                    <div class="flex items-center">
                        <i data-lucide="alert-circle" class="w-5 h-5 mr-2"></i>
                        <span>
                            <%= error %>
                        </span>
                    </div>
                </div>
                <% } %>

                <!-- Statistics Cards -->
                <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-6">
                    <div
                        class="bg-white rounded-xl p-6 shadow-sm border border-gray-200">
                        <div class="flex items-center justify-between">
                            <div>
                                <p class="text-sm font-medium text-gray-600">Total Users
                                </p>
                                <p class="text-2xl font-bold text-gray-800 mt-1">
                                    <%= totalUsers %>
                                </p>
                            </div>
                            <div class="p-3 bg-blue-100 rounded-lg">
                                <i data-lucide="users"
                                   class="w-6 h-6 text-blue-600"></i>
                            </div>
                        </div>
                    </div>

                    <div
                        class="bg-white rounded-xl p-6 shadow-sm border border-gray-200">
                        <div class="flex items-center justify-between">
                            <div>
                                <p class="text-sm font-medium text-gray-600">Admins</p>
                                <p class="text-2xl font-bold text-red-600 mt-1">
                                    <%= adminCount %>
                                </p>
                            </div>
                            <div class="p-3 bg-red-100 rounded-lg">
                                <i data-lucide="shield"
                                   class="w-6 h-6 text-red-600"></i>
                            </div>
                        </div>
                    </div>

                    <div
                        class="bg-white rounded-xl p-6 shadow-sm border border-gray-200">
                        <div class="flex items-center justify-between">
                            <div>
                                <p class="text-sm font-medium text-gray-600">Employees
                                </p>
                                <p class="text-2xl font-bold text-orange-600 mt-1">
                                    <%= employeeCount %>
                                </p>
                            </div>
                            <div class="p-3 bg-orange-100 rounded-lg">
                                <i data-lucide="briefcase"
                                   class="w-6 h-6 text-orange-600"></i>
                            </div>
                        </div>
                    </div>

                    <div
                        class="bg-white rounded-xl p-6 shadow-sm border border-gray-200">
                        <div class="flex items-center justify-between">
                            <div>
                                <p class="text-sm font-medium text-gray-600">Customers
                                </p>
                                <p class="text-2xl font-bold text-green-600 mt-1">
                                    <%= customerCount %>
                                </p>
                            </div>
                            <div class="p-3 bg-green-100 rounded-lg">
                                <i data-lucide="user-check"
                                   class="w-6 h-6 text-green-600"></i>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- User Management Table -->
                <div class="bg-white rounded-xl shadow-sm overflow-hidden">
                    <div
                        class="bg-gray-800 text-white px-6 py-4 flex justify-between items-center">
                        <div class="flex items-center">
                            <i data-lucide="users" class="w-5 h-5 mr-2"></i>
                            <span class="text-lg font-semibold">User Management</span>
                        </div>
                        <div class="flex items-center space-x-4">
                            <select id="roleFilter" onchange="filterUsersByRole()"
                                    class="border border-gray-300 rounded-lg px-3 py-2 text-gray-800 focus:outline-none focus:ring-2 focus:ring-orange-500">
                                <option value="all" <%="all"
                                                                    .equalsIgnoreCase(selectedRole) ? "selected" : "" %>
                                        >All Roles</option>
                                <option value="1" <%="1" .equals(selectedRole)
                                                                    ? "selected" : "" %>>Admin</option>
                                <option value="2" <%="2" .equals(selectedRole)
                                                                    ? "selected" : "" %>>Employee - All</option>
                                <option value="Manager" <%="Manager" .equals(selectedRole)
                                                                    ? "selected" : "" %>>├─ Manager</option>
                                <option value="Cashier" <%="Cashier" .equals(selectedRole)
                                                                    ? "selected" : "" %>>├─ Cashier</option>
                                <option value="Waiter" <%="Waiter" .equals(selectedRole)
                                                                    ? "selected" : "" %>>├─ Waiter</option>
                                <option value="Chef" <%="Chef" .equals(selectedRole)
                                                                    ? "selected" : "" %>>└─ Chef</option>
                                <option value="3" <%="3" .equals(selectedRole)
                                                                    ? "selected" : "" %>>Customer</option>
                            </select>
                            <a href="adduser"
                               class="bg-green-500 hover:bg-green-600 text-white px-4 py-2 rounded-lg flex items-center">
                                <i data-lucide="plus" class="w-4 h-4 mr-2"></i>
                                Add User
                            </a>
                        </div>
                    </div>

                    <% if (users==null || users.isEmpty()) { %>
                    <div class="text-center py-12">
                        <i data-lucide="users"
                           class="w-16 h-16 text-gray-400 mx-auto mb-4"></i>
                        <h3 class="text-lg font-medium text-gray-900 mb-2">No Users
                            Found</h3>
                        <p class="text-gray-500">There are no users in the system
                            yet.</p>
                    </div>
                    <% } else { %>
                    <div class="overflow-x-auto">
                        <table class="min-w-full">
                            <thead class="bg-gray-100">
                                <tr>
                                    <th
                                        class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                                        ID</th>
                                    <th
                                        class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                                        Name</th>
                                    <th
                                        class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                                        Email</th>
                                    <th
                                        class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                                        Phone</th>
                                    <th
                                        class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                                        Role</th>
                                    <th
                                        class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                                        Position</th>
                                    <th
                                        class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                                        Status</th>
                                    <th
                                        class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                                        Actions</th>
                                </tr>
                            </thead>
                            <tbody class="bg-white divide-y divide-gray-200">
                                <% 
                                dao.EmployeeDAO empDAO = new dao.EmployeeDAO();
                                for (User user : users) { 
                                    String employeeRole = "";
                                    if (user.getRole() == 2) {
                                        models.Employee emp = empDAO.getEmployeeByUserId(user.getUserID());
                                        if (emp != null) {
                                            employeeRole = emp.getRole();
                                        }
                                    }
                                %>
                                <tr class="hover:bg-gray-50"
                                    data-role="<%= user.getRole() %>">
                                    <td
                                        class="px-4 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                                        #<%= user.getUserID() %>
                                    </td>
                                    <td
                                        class="px-4 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                                        <%= user.getName() %>
                                    </td>
                                    <td
                                        class="px-4 py-4 whitespace-nowrap text-sm text-gray-500">
                                        <%= user.getEmail() %>
                                    </td>
                                    <td
                                        class="px-4 py-4 whitespace-nowrap text-sm text-gray-500">
                                        <%= user.getPhone() %>
                                    </td>
                                    <td class="px-4 py-4 whitespace-nowrap">
                                        <% if (user.getRole()==1) { %>
                                        <span
                                            class="px-3 py-1 inline-flex text-xs leading-5 font-semibold rounded-full bg-red-100 text-red-800">Admin</span>
                                        <% } else if (user.getRole()==2)
                                                                                            { %>
                                        <span
                                            class="px-3 py-1 inline-flex text-xs leading-5 font-semibold rounded-full bg-orange-100 text-orange-800">Employee</span>
                                        <% } else { %>
                                        <span
                                            class="px-3 py-1 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800">Customer</span>
                                        <% } %>
                                    </td>
                                    <td class="px-4 py-4 whitespace-nowrap">
                                        <% if (user.getRole() == 2 && !employeeRole.isEmpty()) { %>
                                            <% if ("Manager".equals(employeeRole)) { %>
                                            <span class="px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full bg-purple-100 text-purple-800">
                                                <i data-lucide="crown" class="w-3 h-3 mr-1"></i>
                                                Manager
                                            </span>
                                            <% } else if ("Cashier".equals(employeeRole)) { %>
                                            <span class="px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full bg-blue-100 text-blue-800">
                                                <i data-lucide="dollar-sign" class="w-3 h-3 mr-1"></i>
                                                Cashier
                                            </span>
                                            <% } else if ("Waiter".equals(employeeRole)) { %>
                                            <span class="px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full bg-teal-100 text-teal-800">
                                                <i data-lucide="user-round" class="w-3 h-3 mr-1"></i>
                                                Waiter
                                            </span>
                                            <% } else if ("Chef".equals(employeeRole)) { %>
                                            <span class="px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full bg-amber-100 text-amber-800">
                                                <i data-lucide="chef-hat" class="w-3 h-3 mr-1"></i>
                                                Chef
                                            </span>
                                            <% } %>
                                        <% } else { %>
                                        <span class="text-gray-400 text-xs">-</span>
                                        <% } %>
                                    </td>
                                    <td class="px-4 py-4 whitespace-nowrap">
                                        <% if (user.isActive()) { %>
                                        <span
                                            class="px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800">
                                            <i data-lucide="check-circle"
                                               class="w-3 h-3 mr-1"></i>
                                            Active
                                        </span>
                                        <% } else { %>
                                        <span
                                            class="px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full bg-red-100 text-red-800">
                                            <i data-lucide="x-circle"
                                               class="w-3 h-3 mr-1"></i>
                                            Inactive
                                        </span>
                                        <% } %>
                                    </td>
                                    <td
                                        class="px-4 py-4 whitespace-nowrap text-sm font-medium">
                                        <% if (currentUser !=null &&
                                            user.getUserID()
                                            !=currentUser.getUserID()) { %>
                                        <div class="flex space-x-2">
                                            <a href="edituser?id=<%= user.getUserID() %>"
                                               class="text-blue-600 hover:text-blue-800 bg-blue-50 hover:bg-blue-100 px-3 py-1 rounded text-xs">
                                                <i data-lucide="edit"
                                                   class="w-3 h-3 inline mr-1"></i>Edit
                                            </a>
                                            <% if (user.isActive()) { %>
                                            <button type="button"
                                                    class="text-yellow-600 hover:text-yellow-800 bg-yellow-50 hover:bg-yellow-100 px-3 py-1 rounded text-xs suspend-btn"
                                                    data-user-id="<%= user.getUserID() %>">
                                                <i data-lucide="pause"
                                                   class="w-3 h-3 inline mr-1"></i>Suspend
                                            </button>
                                            <% } else { %>
                                            <button
                                                type="button"
                                                class="text-green-600 hover:text-green-800 bg-green-50 hover:bg-green-100 px-3 py-1 rounded text-xs activate-btn"
                                                data-user-id="<%= user.getUserID() %>">
                                                <i data-lucide="play"
                                                   class="w-3 h-3 inline mr-1"></i>Activate
                                            </button>
                                            <% } %>
                                            <button
                                                type="button"
                                                class="text-red-600 hover:text-red-800 bg-red-50 hover:bg-red-100 px-3 py-1 rounded text-xs delete-btn"
                                                data-user-id="<%= user.getUserID() %>">
                                                <i data-lucide="trash-2"
                                                   class="w-3 h-3 inline mr-1"></i>Delete
                                            </button>
                                        </div>
                                        <% } else { %>
                                        <span
                                            class="text-gray-400 text-xs italic">Current
                                            User</span>
                                            <% } %>
                                    </td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                    <!-- Pagination -->
                    <% int currentPage=(int)
                        request.getAttribute("currentPage"); int
                        totalPages=(int) request.getAttribute("totalPages"); if
                        (totalPages> 1) {
                    %>
                    <div
                        class="flex justify-between items-center mt-6 px-6 py-4 bg-gray-50">
                        <div class="text-sm text-gray-500">
                            Showing page <%= currentPage %> of <%=
                                                                                totalPages %>
                        </div>
                        <div class="flex items-center space-x-2">
                            <a href="admin?page=1<%= roleParam %>" class="px-3 py-2 border border-gray-300 rounded <%= currentPage == 1 ? "bg-gray-100 text-gray-400 cursor-not-allowed" : "hover:bg-gray-100 text-gray-700" %>">
                                <i data-lucide="chevrons-left" class="w-4 h-4"></i>
                            </a>
                            <a href="admin?page=<%= (currentPage - 1) %><%= roleParam %>" class="px-3 py-2 border border-gray-300 rounded <%= currentPage == 1 ? "bg-gray-100 text-gray-400 cursor-not-allowed" : "hover:bg-gray-100 text-gray-700" %>">
                                <i data-lucide="chevron-left" class="w-4 h-4"></i>
                            </a>
                            
                            <% for (int i = Math.max(1, currentPage - 2); i <= Math.min(totalPages, currentPage + 2); i++) { %>
                            <a href="admin?page=<%= i %><%= roleParam %>" class="px-3 py-2 border border-gray-300 rounded <%= i == currentPage ? "bg-orange-500 text-white" : "hover:bg-gray-100 text-gray-700" %>">
                                <%= i %>
                            </a>
                            <% } %>
                            
                            <a href="admin?page=<%= (currentPage + 1) %><%= roleParam %>" class="px-3 py-2 border border-gray-300 rounded <%= currentPage == totalPages ? "bg-gray-100 text-gray-400 cursor-not-allowed" : "hover:bg-gray-100 text-gray-700" %>">
                                <i data-lucide="chevron-right" class="w-4 h-4"></i>
                            </a>
                            <a href="admin?page=<%= totalPages %><%= roleParam %>" class="px-3 py-2 border border-gray-300 rounded <%= currentPage == totalPages ? "bg-gray-100 text-gray-400 cursor-not-allowed" : "hover:bg-gray-100 text-gray-700" %>">
                                <i data-lucide="chevrons-right" class="w-4 h-4"></i>
                            </a>
                        </div>
                    </div>
                    <% } %>

                    <% } %>
                </div>
            </div>
        </div>

        <!-- Delete Confirmation Modal -->
        <div id="deleteModal"
             class="fixed inset-0 bg-gray-600 bg-opacity-50 flex items-center justify-center hidden z-50">
            <div class="bg-white rounded-lg p-6 w-full max-w-md mx-4">
                <div class="flex justify-between items-center mb-4">
                    <h2 class="text-lg font-bold text-gray-800 flex items-center">
                        <i data-lucide="alert-triangle" class="w-5 h-5 mr-2 text-red-500"></i>
                        Delete User
                    </h2>
                    <button onclick="closeModal('deleteModal')"
                            class="text-gray-400 hover:text-gray-600">
                        <i data-lucide="x" class="w-5 h-5"></i>
                    </button>
                </div>
                <p class="text-gray-600 mb-6">Are you sure you want to delete this user? This action
                    cannot be undone.</p>
                <div class="flex justify-end space-x-3">
                    <button onclick="closeModal('deleteModal')"
                            class="px-4 py-2 text-gray-600 bg-gray-100 hover:bg-gray-200 rounded-lg">Cancel</button>
                    <button onclick="confirmDelete()"
                            class="px-4 py-2 bg-red-500 text-white hover:bg-red-600 rounded-lg">Delete</button>
                </div>
            </div>
        </div>

        <!-- Suspend Confirmation Modal -->
        <div id="suspendModal"
             class="fixed inset-0 bg-gray-600 bg-opacity-50 flex items-center justify-center hidden z-50">
            <div class="bg-white rounded-lg p-6 w-full max-w-md mx-4">
                <div class="flex justify-between items-center mb-4">
                    <h2 class="text-lg font-bold text-gray-800 flex items-center">
                        <i data-lucide="pause-circle" class="w-5 h-5 mr-2 text-yellow-500"></i>
                        Suspend User
                    </h2>
                    <button onclick="closeModal('suspendModal')"
                            class="text-gray-400 hover:text-gray-600">
                        <i data-lucide="x" class="w-5 h-5"></i>
                    </button>
                </div>
                <p class="text-gray-600 mb-6">Are you sure you want to suspend this user? They will not
                    be able to access the system.</p>
                <div class="flex justify-end space-x-3">
                    <button onclick="closeModal('suspendModal')"
                            class="px-4 py-2 text-gray-600 bg-gray-100 hover:bg-gray-200 rounded-lg">Cancel</button>
                    <button onclick="confirmSuspend()"
                            class="px-4 py-2 bg-yellow-500 text-white hover:bg-yellow-600 rounded-lg">Suspend</button>
                </div>
            </div>
        </div>

        <!-- Activate Confirmation Modal -->
        <div id="activateModal"
             class="fixed inset-0 bg-gray-600 bg-opacity-50 flex items-center justify-center hidden z-50">
            <div class="bg-white rounded-lg p-6 w-full max-w-md mx-4">
                <div class="flex justify-between items-center mb-4">
                    <h2 class="text-lg font-bold text-gray-800 flex items-center">
                        <i data-lucide="play-circle" class="w-5 h-5 mr-2 text-green-500"></i>
                        Activate User
                    </h2>
                    <button onclick="closeModal('activateModal')"
                            class="text-gray-400 hover:text-gray-600">
                        <i data-lucide="x" class="w-5 h-5"></i>
                    </button>
                </div>
                <p class="text-gray-600 mb-6">Are you sure you want to activate this user? They will be
                    able to access the system again.</p>
                <div class="flex justify-end space-x-3">
                    <button onclick="closeModal('activateModal')"
                            class="px-4 py-2 text-gray-600 bg-gray-100 hover:bg-gray-200 rounded-lg">Cancel</button>
                    <button onclick="confirmActivate()"
                            class="px-4 py-2 bg-green-500 text-white hover:bg-green-600 rounded-lg">Activate</button>
                </div>
            </div>
        </div>

        <script>
            // Initialize Lucide icons
            lucide.createIcons();

            // Filter users by role
            function filterUsersByRole() {
                const selectedRole = document.getElementById('roleFilter').value;
                if (selectedRole === 'all') {
                    window.location.href = 'admin?page=1';
                } else {
                    window.location.href = 'admin?roleFilter=' + encodeURIComponent(selectedRole) + '&page=1';
                }
            }

            // Modal functions
            let currentUserId = null;

            function showDeleteModal(userId) {
                currentUserId = userId;
                document.getElementById('deleteModal').classList.remove('hidden');
            }

            function showSuspendModal(userId) {
                currentUserId = userId;
                document.getElementById('suspendModal').classList.remove('hidden');
            }

            function showActivateModal(userId) {
                currentUserId = userId;
                document.getElementById('activateModal').classList.remove('hidden');
            }

            function closeModal(modalId) {
                document.getElementById(modalId).classList.add('hidden');
                currentUserId = null;
            }

            function confirmDelete() {
                if (currentUserId) {
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

            // Initialize event listeners
            document.addEventListener('DOMContentLoaded', function () {
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

                // Close modal when clicking outside
                window.onclick = function (event) {
                    const modals = ['deleteModal', 'suspendModal', 'activateModal'];
                    modals.forEach(modalId => {
                        const modal = document.getElementById(modalId);
                        if (event.target === modal) {
                            modal.classList.add('hidden');
                            currentUserId = null;
                        }
                    });
                }
            });
        </script>

    </body>

</html>