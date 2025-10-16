<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Manager Dashboard</title>
        <!-- Tailwind CSS CDN -->
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

            <!-- Home -->
            <a href="${pageContext.request.contextPath}/home"
               class="nav-btn <%= currentPath.contains("/home") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
               title="Home">
                <i data-lucide="pizza" class="w-6 h-6"></i>
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
                <a href="${pageContext.request.contextPath}/orders"
                   class="nav-btn <%= currentPath.contains("/orders") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
                   title="Orders">
                    <i data-lucide="file-text" class="w-6 h-6"></i>
                </a>

                <!-- Menu -->
                <a href="${pageContext.request.contextPath}/menu"
                   class="nav-btn <%= currentPath.contains("/menu") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
                   title="Menu">
                    <i data-lucide="pizza" class="w-6 h-6"></i>
                </a>

                <!-- Notifications -->
                <a href="${pageContext.request.contextPath}/notifications"
                   class="nav-btn <%= currentPath.contains("/notifications") ? "bg-orange-500 text-white" : "text-gray-400 hover:bg-gray-700" %>"
                   title="Notifications">
                    <i data-lucide="bell" class="w-6 h-6"></i>
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
               class="w-12 h-12 rounded-xl flex items-center justify-center
               <%= currentPath.contains("/logout") ? "bg-orange-500 text-white" : "bg-gray-700 text-gray-400 hover:bg-gray-600" %>"
               title="Logout">
                <i data-lucide="arrow-right" class="w-6 h-6"></i>
            </a>

        </div>


        <!-- Main Content -->
        <div class="flex-1 overflow-auto">
            <!-- Header -->
            <div class="bg-white border-b px-8 py-6 flex justify-between items-center">
                <h1 class="text-3xl font-bold text-gray-800">Manager Dashboard</h1>
                <div class="flex space-x-2">
                    <button class="tab-btn bg-orange-500 text-white">Today</button>
                    <button class="tab-btn bg-gray-100 text-gray-600 hover:bg-gray-200">This Week</button>
                    <button class="tab-btn bg-gray-100 text-gray-600 hover:bg-gray-200">This Month</button>
                    <button class="tab-btn bg-gray-100 text-gray-600 hover:bg-gray-200">This Year</button>
                </div>
            </div>

            <!-- Dashboard Content -->
            <div class="p-8">
                <!-- Top Row -->
                <div class="grid grid-cols-2 gap-6 mb-6">
                    <!-- Total Income -->
                    <div class="bg-white rounded-2xl p-8 shadow-sm text-center">
                        <h2 class="text-2xl font-bold text-gray-800 mb-6">Total Income</h2>
                        <canvas id="incomeChart" height="100"></canvas>
                        <div class="flex justify-center space-x-8 mt-4">
                            <div class="flex items-center space-x-2"><div class="w-4 h-4 rounded bg-orange-500"></div><span>Foodies</span></div>
                            <div class="flex items-center space-x-2"><div class="w-4 h-4 rounded bg-gray-800"></div><span>Cold Drink</span></div>
                            <div class="flex items-center space-x-2"><div class="w-4 h-4 rounded bg-gray-300"></div><span>Others</span></div>
                        </div>
                    </div>

                    <!-- Total Balance -->
                    <div class="bg-white rounded-2xl p-8 shadow-sm">
                        <h2 class="text-2xl font-bold text-gray-800 mb-6">Total Balance</h2>
                        <div class="text-5xl font-bold text-green-500 mb-8">$30,000</div>
                        <div class="space-y-4">
                            <div class="flex items-center justify-between p-4 bg-gray-50 rounded-xl">
                                <div class="flex items-center space-x-3">
                                    <div class="w-12 h-12 bg-black rounded-full flex items-center justify-center">
                                        <i data-lucide="trending-up" class="w-6 h-6 text-white"></i>
                                    </div>
                                    <div>
                                        <div class="text-sm text-gray-500">Total Income</div>
                                        <div class="text-lg font-bold text-gray-800">$4,500</div>
                                    </div>
                                </div>
                                <div class="text-sm text-gray-400">(+ 20% Increase)</div>
                            </div>

                            <div class="flex items-center justify-between p-4 bg-gray-50 rounded-xl">
                                <div class="flex items-center space-x-3">
                                    <div class="w-12 h-12 bg-orange-500 rounded-full flex items-center justify-center">
                                        <i data-lucide="dollar-sign" class="w-6 h-6 text-white"></i>
                                    </div>
                                    <div>
                                        <div class="text-sm text-gray-500">Total Expense</div>
                                        <div class="text-lg font-bold text-gray-800">$2,500</div>
                                    </div>
                                </div>
                                <div class="text-sm text-gray-400">(+ 30% Increase)</div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Bottom Row -->
                <div class="grid grid-cols-3 gap-6">
                    <!-- Daily Selling -->
                    <div class="col-span-2 bg-white rounded-2xl p-8 shadow-sm">
                        <h2 class="text-2xl font-bold text-gray-800 mb-6">Daily Selling</h2>
                        <canvas id="dailyChart" height="120"></canvas>
                    </div>

                    <!-- Best Dishes -->
                    <div class="bg-white rounded-2xl p-8 shadow-sm">
                        <h2 class="text-2xl font-bold text-gray-800 mb-6">Best Dishes</h2>
                        <div class="space-y-4">
                            <div class="flex justify-between text-sm text-gray-500 mb-4"><span>Dishes</span><span>Orders</span></div>
                            <div class="flex justify-between items-center border-b py-2"><span>🥪 Grill Sandwich</span><span class="font-bold text-gray-700">200</span></div>
                            <div class="flex justify-between items-center border-b py-2"><span>🍗 Chicken Popeyes</span><span class="font-bold text-gray-700">400</span></div>
                            <div class="flex justify-between items-center border-b py-2"><span>🍔 Bison Burgers</span><span class="font-bold text-gray-700">250</span></div>
                            <div class="flex justify-between items-center py-2"><span>🥪 Grill Sandwich</span><span class="font-bold text-gray-700">100</span></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- JS -->
        <script>
            lucide.createIcons();

            // Total Income Chart (Pie)
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
                    plugins: {
                        legend: {display: false}
                    },
                    cutout: '70%'
                }
            });

            // Daily Selling Chart (Area)
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
                    plugins: {legend: {display: false}},
                    scales: {y: {beginAtZero: false}}
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
                padding: 0.5rem 1.5rem;
                border-radius: 0.5rem;
                font-weight: 500;
                transition: all 0.2s;
            }
        </style>

    </body>
</html>
