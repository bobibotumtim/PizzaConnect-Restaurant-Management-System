<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%
    Integer totalOrders = (Integer) request.getAttribute("totalOrders");
    Integer pendingOrders = (Integer) request.getAttribute("pendingOrders");
    Integer processingOrders = (Integer) request.getAttribute("processingOrders");
    Integer completedOrders = (Integer) request.getAttribute("completedOrders");
    Integer cancelledOrders = (Integer) request.getAttribute("cancelledOrders");
    Double totalRevenue = (Double) request.getAttribute("totalRevenue");
    Double totalPaid = (Double) request.getAttribute("totalPaid");
    Double totalUnpaid = (Double) request.getAttribute("totalUnpaid");
    List<Map.Entry<String, Integer>> top5Dishes = (List<Map.Entry<String, Integer>>) request.getAttribute("top5Dishes");
    double[] hourlyRevenue = (double[]) request.getAttribute("hourlyRevenue");
    String currentFilter = (String) request.getAttribute("currentFilter");
    
    // Default values if null
    if (totalOrders == null) totalOrders = 0;
    if (totalRevenue == null) totalRevenue = 0.0;
    if (totalPaid == null) totalPaid = 0.0;
    if (totalUnpaid == null) totalUnpaid = 0.0;
    if (pendingOrders == null) pendingOrders = 0;
    if (processingOrders == null) processingOrders = 0;
    if (completedOrders == null) completedOrders = 0;
    if (currentFilter == null) currentFilter = "today";
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Manager Dashboard</title>
        <!--Tailwind CSS CDN--> 
        <script src="https://cdn.tailwindcss.com"></script>
        <!-- Lucide Icons -->
        <script src="https://unpkg.com/lucide@latest"></script>
        <!-- Chart.js for charts (thay Recharts trong React) -->
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    </head>
    <body class="flex h-screen bg-gray-50">

        <!-- Sidebar -->
        <%
            String currentPath = request.getRequestURI();
        %>

        <div class="w-20 bg-gray-800 flex flex-col items-center py-6 space-y-8">

            <!-- Logo/Home -->
            <a href="${pageContext.request.contextPath}/home"
               class="nav-btn <%= currentPath.contains("/home") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
               title="Home">
                <i data-lucide="home" class="w-6 h-6"></i>
            </a>

            <!-- Navigation -->
            <div class="flex-1 flex flex-col space-y-6 mt-8">

                <!-- Dashboard -->
                <a href="${pageContext.request.contextPath}/dashboard"
                   class="nav-btn <%= currentPath.contains("/dashboard") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
                   title="Dashboard">
                    <i data-lucide="grid" class="w-6 h-6"></i>
                </a>

                <!-- Orders -->
                <a href="${pageContext.request.contextPath}/manage-orders"
                   class="nav-btn <%= currentPath.contains("/orders") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
                   title="Orders">
                    <i data-lucide="file-text" class="w-6 h-6"></i>
                </a>

                <!-- Menu -->
                <a href="${pageContext.request.contextPath}/menu"
                   class="nav-btn <%= currentPath.contains("/menu") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
                   title="Menu">
                    <i data-lucide="utensils" class="w-6 h-6"></i>
                </a>

                <!-- POS -->
                <a href="${pageContext.request.contextPath}/pos"
                   class="nav-btn <%= currentPath.contains("/pos") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
                   title="POS">
                    <i data-lucide="shopping-cart" class="w-6 h-6"></i>
                </a>

                <!-- Manage Products -->
                <a href="${pageContext.request.contextPath}/manageproduct"
                   class="nav-btn <%= currentPath.contains("/manageproduct") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
                   title="Manage Products">
                    <i data-lucide="package" class="w-6 h-6"></i>
                </a>

                <!-- Manage Users (Admin) -->
                <a href="${pageContext.request.contextPath}/admin"
                   class="nav-btn <%= currentPath.contains("/admin") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
                   title="Manage Users">
                    <i data-lucide="users" class="w-6 h-6"></i>
                </a>

                <!-- Discount -->
                <a href="${pageContext.request.contextPath}/discount"
                   class="nav-btn <%= currentPath.contains("/discount") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
                   title="Discount">
                    <i data-lucide="percent" class="w-6 h-6"></i>
                </a>

                <!-- Inventory -->
                <a href="${pageContext.request.contextPath}/inventory"
                   class="nav-btn <%= currentPath.contains("/inventory") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
                   title="Inventory">
                    <i data-lucide="box" class="w-6 h-6"></i>
                </a>

                <!-- Profile -->
                <a href="${pageContext.request.contextPath}/profile"
                   class="nav-btn <%= currentPath.contains("/profile") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
                   title="Profile">
                    <i data-lucide="user" class="w-6 h-6"></i>
                </a>

                <!-- Settings -->
                <a href="${pageContext.request.contextPath}/settings"
                   class="nav-btn <%= currentPath.contains("/settings") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
                   title="Settings">
                    <i data-lucide="settings" class="w-6 h-6"></i>
                </a>
            </div>

            <!-- Logout -->
            <a href="${pageContext.request.contextPath}/logout"
               class="nav-btn <%= currentPath.contains("/logout") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
               title="Logout">
                <i data-lucide="log-out" class="w-6 h-6"></i>
            </a>

        </div>


            <!-- Main Content -->
<div class="flex-1 flex flex-col overflow-hidden">
    <!-- Header -->
    <div class="bg-white border-b px-6 py-4 flex justify-between items-center flex-shrink-0">
        <div>
            <h1 class="text-2xl font-bold text-gray-800">Admin Dashboard</h1>
            <p class="text-sm text-gray-500 mt-1">
                <% 
                String filterLabel = "Today";
                if ("week".equals(currentFilter)) filterLabel = "This Week";
                else if ("month".equals(currentFilter)) filterLabel = "This Month";
                else if ("year".equals(currentFilter)) filterLabel = "This Year";
                %>
                Showing <%= totalOrders %> orders from <%= filterLabel %>
            </p>
        </div>
        <div class="flex space-x-2">
            <button onclick="filterDashboard('today')" class="tab-btn <%= "today".equals(currentFilter) ? "bg-orange-500 text-white" : "bg-gray-100 text-gray-600 hover:bg-gray-200" %>">Today</button>
            <button onclick="filterDashboard('week')" class="tab-btn <%= "week".equals(currentFilter) ? "bg-orange-500 text-white" : "bg-gray-100 text-gray-600 hover:bg-gray-200" %>">This Week</button>
            <button onclick="filterDashboard('month')" class="tab-btn <%= "month".equals(currentFilter) ? "bg-orange-500 text-white" : "bg-gray-100 text-gray-600 hover:bg-gray-200" %>">This Month</button>
            <button onclick="filterDashboard('year')" class="tab-btn <%= "year".equals(currentFilter) ? "bg-orange-500 text-white" : "bg-gray-100 text-gray-600 hover:bg-gray-200" %>">This Year</button>
        </div>
    </div>

    <!-- Dashboard Content - FIT TO SCREEN -->
<div class="flex-1 p-4 overflow-hidden">
    <div class="h-full flex flex-col gap-4">
        <!-- Top Row - 48% chiều cao -->
        <div class="grid grid-cols-2 gap-4" style="height: 48%;">
            <!-- Total Income -->
            <div class="bg-white rounded-xl p-4 shadow-sm flex flex-col h-full">
                <h2 class="text-base font-bold text-gray-800 mb-2 flex-shrink-0">Total Income</h2>
                <div class="flex-1 min-h-0 flex items-center justify-center">
                    <div style="width: 200px; height: 200px;">
                        <canvas id="incomeChart"></canvas>
                    </div>
                </div>
                <div class="flex justify-center space-x-3 mt-2 text-xs flex-shrink-0">
                    <div class="flex items-center space-x-1">
                        <div class="w-2 h-2 rounded bg-green-500"></div>
                        <span>Completed</span>
                    </div>
                    <div class="flex items-center space-x-1">
                        <div class="w-2 h-2 rounded bg-blue-500"></div>
                        <span>Processing</span>
                    </div>
                    <div class="flex items-center space-x-1">
                        <div class="w-2 h-2 rounded bg-orange-500"></div>
                        <span>Pending</span>
                    </div>
                    <div class="flex items-center space-x-1">
                        <div class="w-2 h-2 rounded bg-red-500"></div>
                        <span>Cancelled</span>
                    </div>
                </div>
            </div>

            <!-- Total Balance -->
            <div class="bg-white rounded-xl p-4 shadow-sm flex flex-col h-full">
                <h2 class="text-base font-bold text-gray-800 mb-2 flex-shrink-0">Total Revenue</h2>
                <div class="text-2xl font-bold text-green-500 mb-3 flex-shrink-0"><%= String.format("%,.0f", totalRevenue) %> VND</div>
                <div class="flex-1 min-h-0 flex flex-col justify-center space-y-2">
                    <div class="flex items-center justify-between p-2 bg-gray-50 rounded-lg">
                        <div class="flex items-center space-x-2">
                            <div class="w-8 h-8 bg-green-500 rounded-full flex items-center justify-center flex-shrink-0">
                                <i data-lucide="check-circle" class="w-4 h-4 text-white"></i>
                            </div>
                            <div>
                                <div class="text-xs text-gray-500">Paid Orders</div>
                                <div class="text-sm font-bold text-gray-800"><%= String.format("%,.0f", totalPaid) %> VND</div>
                            </div>
                        </div>
                    </div>

                    <div class="flex items-center justify-between p-2 bg-gray-50 rounded-lg">
                        <div class="flex items-center space-x-2">
                            <div class="w-8 h-8 bg-orange-500 rounded-full flex items-center justify-center flex-shrink-0">
                                <i data-lucide="clock" class="w-4 h-4 text-white"></i>
                            </div>
                            <div>
                                <div class="text-xs text-gray-500">Unpaid Orders</div>
                                <div class="text-sm font-bold text-gray-800"><%= String.format("%,.0f", totalUnpaid) %> VND</div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="flex items-center justify-between p-2 bg-gray-50 rounded-lg">
                        <div class="flex items-center space-x-2">
                            <div class="w-8 h-8 bg-blue-500 rounded-full flex items-center justify-center flex-shrink-0">
                                <i data-lucide="shopping-cart" class="w-4 h-4 text-white"></i>
                            </div>
                            <div>
                                <div class="text-xs text-gray-500">Total Orders</div>
                                <div class="text-sm font-bold text-gray-800"><%= totalOrders %></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Bottom Row - 48% chiều cao -->
        <div class="grid grid-cols-3 gap-4" style="height: 48%;">
            <!-- Daily Selling -->
            <div class="col-span-2 bg-white rounded-xl p-4 shadow-sm flex flex-col h-full">
                <h2 class="text-base font-bold text-gray-800 mb-2 flex-shrink-0">Daily Selling</h2>
                <div class="flex-1 min-h-0">
                    <canvas id="dailyChart"></canvas>
                </div>
            </div>

            <!-- Best Dishes -->
            <div class="bg-white rounded-xl p-4 shadow-sm flex flex-col h-full">
                <h2 class="text-base font-bold text-gray-800 mb-2 flex-shrink-0">Best Dishes</h2>
                <div class="flex-1 min-h-0 overflow-auto">
                    <div class="space-y-2">
                        <div class="flex justify-between text-xs text-gray-500 mb-2">
                            <span>Dishes</span>
                            <span>Quantity</span>
                        </div>
                        <% 
                        if (top5Dishes != null && !top5Dishes.isEmpty()) {
                            int rank = 1;
                            for (Map.Entry<String, Integer> dish : top5Dishes) {
                        %>
                        <div class="flex justify-between items-center border-b py-2 text-sm hover:bg-gray-50">
                            <div class="flex items-center space-x-2">
                                <span class="text-xs font-semibold text-gray-400 w-6">#<%= rank %></span>
                                <span class="text-gray-700"><%= dish.getKey() %></span>
                            </div>
                            <span class="font-bold text-orange-600"><%= dish.getValue() %></span>
                        </div>
                        <% 
                                rank++;
                            }
                        } else {
                        %>
                        <div class="text-center text-gray-400 text-sm py-8">
                            <p>No data available</p>
                        </div>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

        <!-- JS -->
        <script>
    const ctx = '${pageContext.request.contextPath}';
    
    function filterDashboard(period) {
        window.location.href = ctx + '/dashboard?filter=' + period;
    }
    
    lucide.createIcons();

    // Total Income Chart (Pie) - Fixed size
    const ctx1 = document.getElementById('incomeChart').getContext('2d');
    new Chart(ctx1, {
        type: 'doughnut',
        data: {
            labels: ['Completed', 'Processing', 'Pending', 'Cancelled'],
            datasets: [{
                data: [<%= completedOrders %>, <%= processingOrders %>, <%= pendingOrders %>, <%= cancelledOrders %>],
                backgroundColor: ['#10b981', '#3b82f6', '#f59e0b', '#ef4444']
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: true,
            plugins: {
                legend: {display: false}
            },
            cutout: '70%'
        }
    });

    // Daily Selling Chart (Area) - Fill container
    const ctx2 = document.getElementById('dailyChart').getContext('2d');
    <% 
    StringBuilder hourlyData = new StringBuilder();
    if (hourlyRevenue != null) {
        for (int i = 0; i < hourlyRevenue.length; i++) {
            if (i > 0) hourlyData.append(", ");
            hourlyData.append(String.format("%.2f", hourlyRevenue[i]));
        }
    }
    %>
    new Chart(ctx2, {
        type: 'line',
        data: {
            labels: ['00:00', '01:00', '02:00', '03:00', '04:00', '05:00', '06:00', '07:00', 
                     '08:00', '09:00', '10:00', '11:00', '12:00', '13:00', '14:00', '15:00',
                     '16:00', '17:00', '18:00', '19:00', '20:00', '21:00', '22:00', '23:00'],
            datasets: [{
                label: 'Revenue (VND)',
                data: [<%= hourlyData.toString() %>],
                borderColor: '#FF8C42',
                backgroundColor: 'rgba(255, 140, 66, 0.2)',
                fill: true,
                tension: 0.4
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {display: true},
                tooltip: {
                    callbacks: {
                        label: function(context) {
                            return 'Revenue: ' + context.parsed.y.toLocaleString('vi-VN') + ' VND';
                        }
                    }
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    ticks: {
                        callback: function(value) {
                            return value.toLocaleString('vi-VN');
                        }
                    }
                }
            }
        }
    });
</script>

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
    .tab-btn {
        padding: 0.375rem 1rem;
        border-radius: 0.5rem;
        font-weight: 500;
        font-size: 0.875rem;
        transition: all 0.2s;
    }
    .nav-btn:hover {
        transform: translateY(-2px);
    }
</style>

    </body>
</html>
