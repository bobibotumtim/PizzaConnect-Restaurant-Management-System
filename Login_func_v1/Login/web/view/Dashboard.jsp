<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Manager Dashboard</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <script src="https://unpkg.com/lucide@latest"></script>
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

                <!-- Dashboard (Admin) -->
                <a href="${pageContext.request.contextPath}/dashboard"
                   class="nav-btn <%= currentPath.contains("/dashboard") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
                   title="Dashboard">
                    <i data-lucide="grid" class="w-6 h-6"></i>
                </a>
                
                <!-- Orders -->
                <a href="${pageContext.request.contextPath}/orders"
                   class="nav-btn <%= currentPath.contains("/orders") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
                   title="Orders">
                    <i data-lucide="file-text" class="w-6 h-6"></i>
                </a>

                <!-- Menu -->
                <a href="${pageContext.request.contextPath}/manageproduct"
                   class="nav-btn <%= currentPath.contains("/menu") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
                   title="Menu">
                    <i data-lucide="utensils" class="w-6 h-6"></i>
                </a>

                <!-- Table -->
                <a href="${pageContext.request.contextPath}/table" 
                class="nav-btn <%= currentPath.contains("/table") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
                title="Table Booking">
                    <i data-lucide="rectangle-horizontal" class="w-6 h-6"></i>
                </a>

                <!-- Discount Programs (Admin) -->
                <a href="${pageContext.request.contextPath}/discount"
                   class="nav-btn <%= currentPath.contains("/discount") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
                   title="Discount Programs">
                    <i data-lucide="percent" class="w-6 h-6"></i>
                </a>

                <!-- Notifications -->
                <a href="${pageContext.request.contextPath}/notifications"
                   class="nav-btn <%= currentPath.contains("/notifications") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
                   title="Notifications">
                    <i data-lucide="bell" class="w-6 h-6"></i>
                </a>

                <!-- Manage Users (Admin) -->
                <a href="${pageContext.request.contextPath}/admin"
                   class="nav-btn <%= currentPath.contains("/admin") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
                   title="Manage Users">
                    <i data-lucide="users" class="w-6 h-6"></i>
                </a>
            </div>

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
                <h1 class="text-2xl font-bold text-gray-800">Manager Dashboard</h1>
                <div class="flex space-x-2">
                    <button class="tab-btn bg-orange-500 text-white">Today</button>
                    <button class="tab-btn bg-gray-100 text-gray-600 hover:bg-gray-200">This Week</button>
                    <button class="tab-btn bg-gray-100 text-gray-600 hover:bg-gray-200">This Month</button>
                    <button class="tab-btn bg-gray-100 text-gray-600 hover:bg-gray-200">This Year</button>
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
                                    <div class="w-2 h-2 rounded bg-orange-500"></div>
                                    <span>Foodies</span>
                                </div>
                                <div class="flex items-center space-x-1">
                                    <div class="w-2 h-2 rounded bg-gray-800"></div>
                                    <span>Cold Drink</span>
                                </div>
                                <div class="flex items-center space-x-1">
                                    <div class="w-2 h-2 rounded bg-gray-300"></div>
                                    <span>Others</span>
                                </div>
                            </div>
                        </div>

                        <!-- Total Balance -->
                        <div class="bg-white rounded-xl p-4 shadow-sm flex flex-col h-full">
                            <h2 class="text-base font-bold text-gray-800 mb-2 flex-shrink-0">Total Balance</h2>
                            <div class="text-2xl font-bold text-green-500 mb-3 flex-shrink-0">$30,000</div>
                            <div class="flex-1 min-h-0 flex flex-col justify-center space-y-2">
                                <div class="flex items-center justify-between p-2 bg-gray-50 rounded-lg">
                                    <div class="flex items-center space-x-2">
                                        <div class="w-8 h-8 bg-black rounded-full flex items-center justify-center flex-shrink-0">
                                            <i data-lucide="trending-up" class="w-4 h-4 text-white"></i>
                                        </div>
                                        <div>
                                            <div class="text-xs text-gray-500">Total Income</div>
                                            <div class="text-sm font-bold text-gray-800">$4,500</div>
                                        </div>
                                    </div>
                                    <div class="text-xs text-gray-400">(+20%)</div>
                                </div>

                                <div class="flex items-center justify-between p-2 bg-gray-50 rounded-lg">
                                    <div class="flex items-center space-x-2">
                                        <div class="w-8 h-8 bg-orange-500 rounded-full flex items-center justify-center flex-shrink-0">
                                            <i data-lucide="dollar-sign" class="w-4 h-4 text-white"></i>
                                        </div>
                                        <div>
                                            <div class="text-xs text-gray-500">Total Expense</div>
                                            <div class="text-sm font-bold text-gray-800">$2,500</div>
                                        </div>
                                    </div>
                                    <div class="text-xs text-gray-400">(+30%)</div>
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
                                        <span>Orders</span>
                                    </div>
                                    <div class="flex justify-between items-center border-b py-2 text-sm">
                                        <span>🥪 Grill Sandwich</span>
                                        <span class="font-bold text-gray-700">200</span>
                                    </div>
                                    <div class="flex justify-between items-center border-b py-2 text-sm">
                                        <span>🍗 Chicken Popeyes</span>
                                        <span class="font-bold text-gray-700">400</span>
                                    </div>
                                    <div class="flex justify-between items-center border-b py-2 text-sm">
                                        <span>🍔 Bison Burgers</span>
                                        <span class="font-bold text-gray-700">250</span>
                                    </div>
                                    <div class="flex justify-between items-center py-2 text-sm">
                                        <span>🥪 Grill Sandwich</span>
                                        <span class="font-bold text-gray-700">100</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- JS -->
            <script>
                lucide.createIcons();

                // Total Income Chart (Pie) - Fixed size
                const ctx1 = document.getElementById('incomeChart').getContext('2d');
                new Chart(ctx1, {
                    type: 'doughnut',
                    data: {
                        labels: ['Foodies', 'Cold Drink', 'Others'],
                        datasets: [{
                                data: [12000, 6000, 2000],
                                backgroundColor: ['#FF8C42', '#2D3142', '#E5E5E5']
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
                new Chart(ctx2, {
                    type: 'line',
                    data: {
                        labels: ['00:00', '04:00', '08:00', '12:00', '16:00', '20:00', '24:00'],
                        datasets: [{
                                label: 'Sales',
                                data: [14000, 13000, 15000, 16000, 14500, 15500, 14800],
                                borderColor: '#FF8C42',
                                backgroundColor: 'rgba(255, 140, 66, 0.2)',
                                fill: true,
                                tension: 0.4
                            }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {legend: {display: false}},
                        scales: {
                            y: {beginAtZero: false}
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
