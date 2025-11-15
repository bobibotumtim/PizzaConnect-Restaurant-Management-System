<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="models.User" %>
<%@ page import="models.Employee" %>
<%@ page import="models.InventoryMonitorItem" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%
    User currentUser = (User) session.getAttribute("user");
    Employee employee = (Employee) session.getAttribute("employee");
    
    // Check if user is logged in and is a Manager
    if (currentUser == null || currentUser.getRole() != 2 || employee == null || 
        !"Manager".equalsIgnoreCase(employee.getJobRole())) {
        response.sendRedirect(request.getContextPath() + "/view/Login.jsp");
        return;
    }
    
    String userName = currentUser.getName();
    List<InventoryMonitorItem> items = (List<InventoryMonitorItem>) request.getAttribute("items");
    Map<String, Integer> counts = (Map<String, Integer>) request.getAttribute("counts");
    String currentLevel = (String) request.getAttribute("currentLevel");
    String searchTerm = (String) request.getAttribute("searchTerm");
    
    // Handle null values
    if (items == null) items = new java.util.ArrayList<>();
    if (counts == null) {
        counts = new java.util.HashMap<>();
        counts.put("CRITICAL", 0);
        counts.put("LOW", 0);
        counts.put("OK", 0);
        counts.put("INACTIVE", 0);
    }
    if (currentLevel == null) currentLevel = "ALL";
    if (searchTerm == null) searchTerm = "";
%>
        <!DOCTYPE html>
        <html lang="en">
          <head>
            <meta charset="UTF-8" />
            <meta
              name="viewport"
              content="width=device-width, initial-scale=1.0"
            />
            <title>Inventory Monitor - PizzaConnect</title>
            <script src="https://cdn.tailwindcss.com"></script>
            <script src="https://unpkg.com/lucide@latest"></script>
          </head></html></String,></String,></InventoryMonitorItem
></InventoryMonitorItem>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #fed7aa 0%, #ffffff 50%, #fee2e2 100%);
            min-height: 100vh;
        }
        .sidebar {
            width: 5rem;
            transition: width 0.3s ease;
        }
        .sidebar:hover {
            width: 16rem;
        }
        .sidebar-text {
            opacity: 0;
            white-space: nowrap;
            transition: opacity 0.3s ease;
        }
        .sidebar:hover .sidebar-text {
            opacity: 1;
        }
        .stat-card {
            transition: all 0.3s ease;
            cursor: pointer;
        }
        .stat-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 12px 24px rgba(0, 0, 0, 0.15);
        }
        .item-card {
            transition: all 0.2s ease;
        }
        .item-card:hover {
            transform: translateX(4px);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
        }
    </style>
</head>
<body>

    <!-- Expandable Sidebar -->
    <div class="sidebar fixed left-0 top-0 h-full bg-gray-900 flex flex-col py-6 z-50 overflow-hidden">
        <!-- Logo -->
        <div class="flex items-center px-4 mb-8">
            <div class="text-3xl min-w-[3rem] flex justify-center">
                🍕
            </div>
            <span class="sidebar-text ml-3 text-white text-xl font-bold">PizzaConnect</span>
        </div>

        <!-- Navigation -->
        <nav class="flex-1 flex flex-col space-y-2 px-3">
            <a href="${pageContext.request.contextPath}/manager-dashboard"
               class="flex items-center px-3 py-3 rounded-lg text-gray-400 hover:bg-gray-800 hover:text-white transition">
                <div class="min-w-[2.5rem] flex justify-center">
                    <i data-lucide="home" class="w-6 h-6"></i>
                </div>
                <span class="sidebar-text ml-3">Dashboard</span>
            </a>

            <a href="${pageContext.request.contextPath}/inventorymonitor"
               class="flex items-center px-3 py-3 rounded-lg bg-orange-500 text-white">
                <div class="min-w-[2.5rem] flex justify-center">
                    <i data-lucide="package" class="w-6 h-6"></i>
                </div>
                <span class="sidebar-text ml-3">Inventory Monitor</span>
            </a>

            <a href="${pageContext.request.contextPath}/sales-reports"
               class="flex items-center px-3 py-3 rounded-lg text-gray-400 hover:bg-gray-800 hover:text-white transition">
                <div class="min-w-[2.5rem] flex justify-center">
                    <i data-lucide="file-text" class="w-6 h-6"></i>
                </div>
                <span class="sidebar-text ml-3">Sales Reports</span>
            </a>

            <a href="${pageContext.request.contextPath}/profile"
               class="flex items-center px-3 py-3 rounded-lg text-gray-400 hover:bg-gray-800 hover:text-white transition">
                <div class="min-w-[2.5rem] flex justify-center">
                    <i data-lucide="user-circle" class="w-6 h-6"></i>
                </div>
                <span class="sidebar-text ml-3">Edit Profile</span>
            </a>

            <a href="${pageContext.request.contextPath}/customer-feedback"
               class="flex items-center px-3 py-3 rounded-lg text-gray-400 hover:bg-gray-800 hover:text-white transition">
                <div class="min-w-[2.5rem] flex justify-center">
                    <i data-lucide="message-circle" class="w-6 h-6"></i>
                </div>
                <span class="sidebar-text ml-3">Customer Feedback</span>
            </a>
        </nav>
    </div>

    <!-- Top Navigation Bar -->
    <div class="fixed top-0 left-20 right-0 bg-white shadow-md border-b px-6 py-3 flex items-center justify-between z-40">
        <div class="text-2xl font-bold text-orange-600">🍕 PizzaConnect</div>
        <div class="flex items-center gap-3">
            <div class="text-right">
                <div class="font-semibold text-gray-800"><%= userName %></div>
                <div class="text-xs text-gray-500">Manager</div>
            </div>
            <a href="${pageContext.request.contextPath}/logout" class="bg-red-500 text-white px-4 py-2 rounded-lg hover:bg-red-600 shadow-sm hover:shadow-md transition-all duration-200 flex items-center gap-2">
                <i data-lucide="log-out" class="w-4 h-4"></i>
                Logout
            </a>
        </div>
    </div>

    <!-- Main Content -->
    <div class="ml-20 mt-16 min-h-screen p-8">
        <div class="max-w-7xl mx-auto">

            <!-- Statistics Cards -->
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
                <!-- CRITICAL Card -->
                <div class="stat-card bg-white rounded-xl shadow-lg p-6 border-l-4 <%= counts.get("CRITICAL") > 0 ? "border-red-600 ring-2 ring-red-200" : "border-red-600" %>"
                     onclick="filterByLevel('CRITICAL')">
                    <div class="flex items-center justify-between mb-4">
                        <div class="p-3 bg-red-100 rounded-lg">
                            <i data-lucide="alert-triangle" class="w-8 h-8 text-red-600"></i>
                        </div>
                        <span class="text-3xl font-bold text-red-600"><%= counts.get("CRITICAL") %></span>
                    </div>
                    <h3 class="text-gray-600 font-semibold">CRITICAL</h3>
                    <p class="text-sm text-gray-500 mt-1">Needs immediate attention</p>
                </div>

                <!-- LOW Card -->
                <div class="stat-card bg-white rounded-xl shadow-lg p-6 border-l-4 border-amber-500"
                     onclick="filterByLevel('LOW')">
                    <div class="flex items-center justify-between mb-4">
                        <div class="p-3 bg-amber-100 rounded-lg">
                            <i data-lucide="alert-circle" class="w-8 h-8 text-amber-600"></i>
                        </div>
                        <span class="text-3xl font-bold text-amber-600"><%= counts.get("LOW") %></span>
                    </div>
                    <h3 class="text-gray-600 font-semibold">LOW</h3>
                    <p class="text-sm text-gray-500 mt-1">Running low on stock</p>
                </div>

                <!-- OK Card -->
                <div class="stat-card bg-white rounded-xl shadow-lg p-6 border-l-4 border-green-600"
                     onclick="filterByLevel('OK')">
                    <div class="flex items-center justify-between mb-4">
                        <div class="p-3 bg-green-100 rounded-lg">
                            <i data-lucide="check-circle" class="w-8 h-8 text-green-600"></i>
                        </div>
                        <span class="text-3xl font-bold text-green-600"><%= counts.get("OK") %></span>
                    </div>
                    <h3 class="text-gray-600 font-semibold">OK</h3>
                    <p class="text-sm text-gray-500 mt-1">Stock levels good</p>
                </div>

                <!-- INACTIVE Card -->
                <div class="stat-card bg-white rounded-xl shadow-lg p-6 border-l-4 border-gray-400"
                     onclick="filterByLevel('INACTIVE')">
                    <div class="flex items-center justify-between mb-4">
                        <div class="p-3 bg-gray-100 rounded-lg">
                            <i data-lucide="archive" class="w-8 h-8 text-gray-600"></i>
                        </div>
                        <span class="text-3xl font-bold text-gray-600"><%= counts.get("INACTIVE") %></span>
                    </div>
                    <h3 class="text-gray-600 font-semibold">INACTIVE</h3>
                    <p class="text-sm text-gray-500 mt-1">Not in use</p>
                </div>
            </div>


            <!-- Controls Section -->
            <div class="bg-white rounded-xl shadow-lg p-6 mb-8">
                <div class="flex flex-col lg:flex-row gap-4 items-center justify-between">
                    <!-- Filter Buttons -->
                    <div class="flex flex-wrap gap-2">
                        <button onclick="filterByLevel('ALL')"
                                class="px-4 py-2 rounded-lg font-medium transition <%= "ALL".equals(currentLevel) ? "bg-orange-500 text-white" : "bg-gray-100 text-gray-700 hover:bg-gray-200" %>">
                            All Items
                        </button>
                        <button onclick="filterByLevel('CRITICAL')"
                                class="px-4 py-2 rounded-lg font-medium transition <%= "CRITICAL".equals(currentLevel) ? "bg-red-600 text-white" : "bg-gray-100 text-gray-700 hover:bg-gray-200" %>">
                            Critical
                        </button>
                        <button onclick="filterByLevel('LOW')"
                                class="px-4 py-2 rounded-lg font-medium transition <%= "LOW".equals(currentLevel) ? "bg-amber-500 text-white" : "bg-gray-100 text-gray-700 hover:bg-gray-200" %>">
                            Low
                        </button>
                        <button onclick="filterByLevel('OK')"
                                class="px-4 py-2 rounded-lg font-medium transition <%= "OK".equals(currentLevel) ? "bg-green-600 text-white" : "bg-gray-100 text-gray-700 hover:bg-gray-200" %>">
                            OK
                        </button>
                        <button onclick="filterByLevel('INACTIVE')"
                                class="px-4 py-2 rounded-lg font-medium transition <%= "INACTIVE".equals(currentLevel) ? "bg-gray-600 text-white" : "bg-gray-100 text-gray-700 hover:bg-gray-200" %>">
                            Inactive
                        </button>
                    </div>

                    <!-- Search and Actions -->
                    <div class="flex gap-2 w-full lg:w-auto">
                        <div class="relative flex-1 lg:w-64">
                            <i data-lucide="search" class="w-5 h-5 text-gray-400 absolute left-3 top-1/2 transform -translate-y-1/2"></i>
                            <input type="text" id="searchInput" value="<%= searchTerm %>"
                                   placeholder="Search items..."
                                   class="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-transparent">
                        </div>
                        <button onclick="refreshData()"
                                class="px-4 py-2 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 transition flex items-center gap-2">
                            <i data-lucide="refresh-cw" class="w-5 h-5"></i>
                            <span class="hidden sm:inline">Refresh</span>
                        </button>
                        <button onclick="exportCSV()"
                                class="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition flex items-center gap-2">
                            <i data-lucide="download" class="w-5 h-5"></i>
                            <span class="hidden sm:inline">Export</span>
                        </button>
                    </div>
                </div>
            </div>


            <!-- Items List -->
            <div class="bg-white rounded-xl shadow-lg overflow-hidden">
                <% if (items != null && !items.isEmpty()) { %>
                    <!-- Desktop Table View -->
                    <div class="hidden md:block overflow-x-auto">
                        <table class="w-full">
                            <thead class="bg-gray-50 border-b border-gray-200">
                                <tr>
                                    <th class="px-6 py-4 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Item</th>
                                    <th class="px-6 py-4 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Quantity</th>
                                    <th class="px-6 py-4 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Status</th>
                                    <th class="px-6 py-4 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Warning Level</th>
                                    <th class="px-6 py-4 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Last Updated</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-gray-200">
                                <% for (InventoryMonitorItem item : items) { %>
                                <tr class="hover:bg-gray-50 transition">
                                    <td class="px-6 py-4">
                                        <div class="flex items-center gap-3">
                                            <div class="p-2 rounded-lg" style="background-color: <%= item.getWarningLevelColor() %>20;">
                                                <i data-lucide="<%= item.getWarningLevelIcon() %>" class="w-5 h-5" style="color: <%= item.getWarningLevelColor() %>;"></i>
                                            </div>
                                            <div>
                                                <div class="font-semibold text-gray-800"><%= item.getItemName() %></div>
                                                <div class="text-sm text-gray-500"><%= item.getUnit() %></div>
                                            </div>
                                        </div>
                                    </td>
                                    <td class="px-6 py-4">
                                        <div class="font-semibold text-gray-800"><%= item.getQuantity() %></div>
                                        <div class="text-xs text-gray-500">
                                            Critical: <%= item.getCriticalThreshold() %> | Low: <%= item.getLowThreshold() %>
                                        </div>
                                    </td>
                                    <td class="px-6 py-4">
                                        <span class="px-3 py-1 rounded-full text-xs font-semibold <%= "Active".equals(item.getStatus()) ? "bg-green-100 text-green-800" : "bg-gray-100 text-gray-800" %>">
                                            <%= item.getStatus() %>
                                        </span>
                                    </td>
                                    <td class="px-6 py-4">
                                        <span class="px-3 py-1 rounded-full text-xs font-semibold" 
                                              style="background-color: <%= item.getWarningLevelColor() %>20; color: <%= item.getWarningLevelColor() %>;">
                                            <%= item.getStockLevel() %>
                                        </span>
                                    </td>
                                    <td class="px-6 py-4 text-sm text-gray-600">
                                        <%= item.getLastUpdated() %>
                                    </td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>

                    <!-- Mobile Card View -->
                    <div class="md:hidden divide-y divide-gray-200">
                        <% for (InventoryMonitorItem item : items) { %>
                        <div class="item-card p-4">
                            <div class="flex items-start gap-3 mb-3">
                                <div class="p-2 rounded-lg" style="background-color: <%= item.getWarningLevelColor() %>20;">
                                    <i data-lucide="<%= item.getWarningLevelIcon() %>" class="w-6 h-6" style="color: <%= item.getWarningLevelColor() %>;"></i>
                                </div>
                                <div class="flex-1">
                                    <h3 class="font-semibold text-gray-800 mb-1"><%= item.getItemName() %></h3>
                                    <div class="flex flex-wrap gap-2 mb-2">
                                        <span class="px-2 py-1 rounded-full text-xs font-semibold" 
                                              style="background-color: <%= item.getWarningLevelColor() %>20; color: <%= item.getWarningLevelColor() %>;">
                                            <%= item.getStockLevel() %>
                                        </span>
                                        <span class="px-2 py-1 rounded-full text-xs font-semibold <%= "Active".equals(item.getStatus()) ? "bg-green-100 text-green-800" : "bg-gray-100 text-gray-800" %>">
                                            <%= item.getStatus() %>
                                        </span>
                                    </div>
                                    <div class="text-sm text-gray-600">
                                        <div><strong>Quantity:</strong> <%= item.getQuantity() %> <%= item.getUnit() %></div>
                                        <div><strong>Thresholds:</strong> Critical: <%= item.getCriticalThreshold() %>, Low: <%= item.getLowThreshold() %></div>
                                        <div class="text-xs text-gray-500 mt-1"><%= item.getLastUpdated() %></div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <% } %>
                    </div>
                <% } else { %>
                    <!-- Empty State -->
                    <div class="p-12 text-center">
                        <div class="inline-flex items-center justify-center w-16 h-16 bg-gray-100 rounded-full mb-4">
                            <i data-lucide="inbox" class="w-8 h-8 text-gray-400"></i>
                        </div>
                        <h3 class="text-lg font-semibold text-gray-800 mb-2">No items found</h3>
                        <p class="text-gray-600">Try adjusting your filters or search term</p>
                    </div>
                <% } %>
            </div>
        </div>
    </div>


    <!-- JavaScript -->
    <script>
        // Initialize Lucide icons
        lucide.createIcons();

        // Filter by warning level
        function filterByLevel(level) {
            const searchTerm = document.getElementById('searchInput').value;
            const url = new URL(window.location.href);
            url.searchParams.set('level', level);
            if (searchTerm) {
                url.searchParams.set('search', searchTerm);
            } else {
                url.searchParams.delete('search');
            }
            window.location.href = url.toString();
        }

        // Search with debounce
        let searchTimeout;
        document.getElementById('searchInput').addEventListener('input', function(e) {
            clearTimeout(searchTimeout);
            searchTimeout = setTimeout(() => {
                const searchTerm = e.target.value;
                const url = new URL(window.location.href);
                if (searchTerm) {
                    url.searchParams.set('search', searchTerm);
                } else {
                    url.searchParams.delete('search');
                }
                window.location.href = url.toString();
            }, 500);
        });

        // Refresh data
        function refreshData() {
            window.location.reload();
        }

        // Export to CSV
        function exportCSV() {
            const url = new URL(window.location.href);
            url.searchParams.set('action', 'export');
            window.location.href = url.toString();
            
            // Show success message
            setTimeout(() => {
                showToast('Export completed successfully!', 'success');
            }, 500);
        }

        // Show toast notification
        function showToast(message, type) {
            type = type || 'success';
            const toast = document.createElement('div');
            const bgColor = type == 'success' ? 'bg-green-600' : 'bg-red-600';
            toast.className = 'fixed top-4 right-4 px-6 py-3 rounded-lg shadow-lg text-white z-50 ' + bgColor;
            toast.textContent = message;
            document.body.appendChild(toast);
            
            setTimeout(function() {
                toast.remove();
            }, 3000);
        }
    </script>
</body>
</html>
