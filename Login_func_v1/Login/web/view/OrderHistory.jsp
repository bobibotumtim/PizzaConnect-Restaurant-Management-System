<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="models.Order" %>
<%@ page import="models.User" %>
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PizzaConnect - Order History</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        .status-badge {
            padding: 6px 14px;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 600;
            text-transform: uppercase;
        }

        .status-waiting {
            background: #f59e0b;  /* Orange - Chờ chef làm */
            color: white;
        }

        .status-ready {
            background: #3b82f6;  /* Blue - Chef làm xong */
            color: white;
        }

        .status-dining {
            background: #8b5cf6;  /* Purple - Khách đang ăn */
            color: white;
        }

        .status-completed {
            background: #10b981;  /* Green - Đã thanh toán */
            color: white;
        }

        .status-cancelled {
            background: #ef4444;  /* Red - Đã hủy */
            color: white;
        }

        .payment-paid {
            background: #d1fae5;
            color: #065f46;
        }

        .payment-unpaid {
            background: #fee2e2;
            color: #991b1b;
        }
    </style>
</head>

<body class="min-h-screen bg-gradient-to-br from-purple-50 to-blue-50">
    <% 
        User currentUser = (User) request.getAttribute("currentUser");
        User sessionUser = (User) session.getAttribute("user");
        User user = currentUser != null ? currentUser : sessionUser;
        List<Order> orders = (List<Order>) request.getAttribute("orders");
        Integer totalOrders = (Integer) request.getAttribute("totalOrders");
        Integer completedOrders = (Integer) request.getAttribute("completedOrders");
        Double totalSpent = (Double) request.getAttribute("totalSpent");
        Integer currentPage = (Integer) request.getAttribute("currentPage");
        Integer totalPages = (Integer) request.getAttribute("totalPages");
        Integer pageSize = (Integer) request.getAttribute("pageSize");
        
        if (totalOrders == null) totalOrders = 0;
        if (completedOrders == null) completedOrders = 0;
        if (totalSpent == null) totalSpent = 0.0;
        if (currentPage == null) currentPage = 1;
        if (totalPages == null) totalPages = 1;
        if (pageSize == null) pageSize = 5;
    %>

    <%@ include file="Sidebar.jsp" %>
    <%@ include file="NavBar.jsp" %>

    <!-- Main Content -->
    <div class="content-wrapper">
        <div class="flex-1 flex flex-col overflow-hidden">
            <!-- Header -->
            <div class="bg-gradient-to-r from-red-500 to-orange-500 text-white shadow-lg">
                <div class="max-w-7xl mx-auto px-6 py-6">
                    <div class="flex items-center justify-between">
                        <div class="flex items-center gap-4">
                            <div class="w-16 h-16 bg-white rounded-full flex items-center justify-center text-4xl shadow-lg">
                                🍕
                            </div>
                            <div>
                                <h1 class="text-3xl font-bold">Order History</h1>
                                <p class="text-red-100">View your past orders</p>
                            </div>
                        </div>
                        <div class="flex items-center gap-4">
                            <div class="text-right">
                                <div class="font-semibold"><%= user != null ? user.getName() : "User" %></div>
                                <div class="text-sm text-red-100">Customer</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="max-w-7xl mx-auto px-6 py-8 w-full">
                <!-- Statistics -->
                <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
                    <div class="bg-white rounded-xl shadow-md p-6 border-l-4 border-blue-500">
                        <div class="text-sm text-gray-600 mb-2">Total Orders</div>
                        <div class="text-3xl font-bold text-blue-600"><%= totalOrders %></div>
                    </div>
                    <div class="bg-white rounded-xl shadow-md p-6 border-l-4 border-green-500">
                        <div class="text-sm text-gray-600 mb-2">Completed</div>
                        <div class="text-3xl font-bold text-green-600">
                            <%= completedOrders %>
                        </div>
                    </div>
                    <div class="bg-white rounded-xl shadow-md p-6 border-l-4 border-red-500">
                        <div class="text-sm text-gray-600 mb-2">Total Spent</div>
                        <div class="text-3xl font-bold text-red-600">
                            <%= String.format("%,.0f", totalSpent) %>đ
                        </div>
                    </div>
                </div>

                <!-- Orders List -->
                <div class="space-y-6">
                    <% if (orders == null || orders.isEmpty()) { %>
                        <div class="bg-white rounded-xl shadow-md p-12 text-center">
                            <div class="text-6xl mb-4">📦</div>
                            <h3 class="text-xl font-semibold text-gray-700 mb-2">No Orders Yet</h3>
                            <p class="text-gray-500 mb-6">You haven't placed any orders yet.</p>
                            <a href="${pageContext.request.contextPath}/customer-menu" 
                               class="inline-block bg-orange-500 text-white px-6 py-3 rounded-lg font-semibold hover:bg-orange-600 transition-all">
                                Browse Menu
                            </a>
                        </div>
                    <% } else { 
                        for (Order order : orders) { 
                            Integer tableId = order.getTableID();
                            String paymentStatus = order.getPaymentStatus();
                            
                            String statusClass = "";
                            String statusIcon = "";
                            switch(order.getStatus()) {
                                case 0: 
                                    statusClass = "status-waiting"; 
                                    statusIcon = "⏳";
                                    break;
                                case 1: 
                                    statusClass = "status-ready"; 
                                    statusIcon = "✅";
                                    break;
                                case 2: 
                                    statusClass = "status-dining"; 
                                    statusIcon = "🍽️";
                                    break;
                                case 3: 
                                    statusClass = "status-completed"; 
                                    statusIcon = "✔️";
                                    break;
                                case 4: 
                                    statusClass = "status-cancelled"; 
                                    statusIcon = "❌";
                                    break;
                            }
                            
                            String paymentClass = "payment-unpaid";
                            if ("Paid".equals(paymentStatus)) paymentClass = "payment-paid";
                    %>
                        <!-- Order Card -->
                        <div class="bg-white rounded-xl shadow-md overflow-hidden hover:shadow-lg transition-shadow">
                            <!-- Order Header -->
                            <div class="bg-gradient-to-r from-orange-50 to-red-50 px-6 py-4 border-b border-orange-100">
                                <div class="flex items-center justify-between">
                                    <div class="flex items-center gap-4">
                                        <div class="text-3xl"><%= statusIcon %></div>
                                        <div>
                                            <div class="flex items-center gap-3">
                                                <span class="text-lg font-bold text-gray-900">Order #<%= order.getOrderID() %></span>
                                                <span class="status-badge <%= statusClass %>">
                                                    <%= order.getStatusText() %>
                                                </span>
                                                <span class="px-3 py-1 rounded-full text-xs font-semibold <%= paymentClass %>">
                                                    <%= paymentStatus != null ? paymentStatus : "Unpaid" %>
                                                </span>
                                            </div>
                                            <div class="text-sm text-gray-600 mt-1">
                                                <%= order.getOrderDate() != null ? new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(order.getOrderDate()) : "N/A" %>
                                                <% if (tableId != null && tableId != 0) { %>
                                                    • Table <%= tableId %>
                                                <% } %>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="text-right">
                                        <div class="text-2xl font-bold text-orange-600">
                                            <%= String.format("%,.0f", order.getTotalPrice()) %>đ
                                        </div>
                                        <div class="text-xs text-gray-500">Total Amount</div>
                                    </div>
                                </div>
                            </div>

                            <!-- Order Items -->
                            <div class="px-6 py-4">
                                <% if (order.getDetails() != null && !order.getDetails().isEmpty()) { %>
                                    <div class="space-y-3">
                                        <div class="text-sm font-semibold text-gray-700 mb-3">Order Items:</div>
                                        <% for (models.OrderDetail detail : order.getDetails()) { %>
                                            <div class="flex items-center justify-between py-2 border-b border-gray-100 last:border-0">
                                                <div class="flex items-center gap-3">
                                                    <div class="w-10 h-10 bg-orange-100 rounded-lg flex items-center justify-center text-orange-600 font-bold">
                                                        <%= detail.getQuantity() %>x
                                                    </div>
                                                    <div>
                                                        <div class="font-medium text-gray-900">
                                                            <%= detail.getProductName() != null ? detail.getProductName() : "Product #" + detail.getProductSizeID() %>
                                                        </div>
                                                        <% if (detail.getSpecialInstructions() != null && !detail.getSpecialInstructions().isEmpty()) { %>
                                                            <div class="text-xs text-gray-500 italic">
                                                                Note: <%= detail.getSpecialInstructions() %>
                                                            </div>
                                                        <% } %>
                                                    </div>
                                                </div>
                                                <div class="font-semibold text-gray-900">
                                                    <%= String.format("%,.0f", detail.getTotalPrice()) %>đ
                                                </div>
                                            </div>
                                        <% } %>
                                    </div>
                                <% } else { %>
                                    <div class="text-sm text-gray-500 italic">No items found</div>
                                <% } %>

                                <% if (order.getNote() != null && !order.getNote().isEmpty()) { %>
                                    <div class="mt-4 pt-4 border-t border-gray-200">
                                        <div class="text-xs font-semibold text-gray-600 mb-1">Order Note:</div>
                                        <div class="text-sm text-gray-700 bg-gray-50 rounded-lg p-3">
                                            <%= order.getNote() %>
                                        </div>
                                    </div>
                                <% } %>
                            </div>
                        </div>
                    <% } %>
                    <% } %>
                </div>

                <!-- Pagination -->
                <% if (totalPages > 1) { %>
                <div class="mt-8 flex items-center justify-center gap-2">
                    <!-- Previous Button -->
                    <% if (currentPage > 1) { %>
                        <a href="?page=<%= currentPage - 1 %>" 
                           class="px-4 py-2 bg-white border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition-colors">
                            ← Previous
                        </a>
                    <% } else { %>
                        <span class="px-4 py-2 bg-gray-100 border border-gray-200 rounded-lg text-gray-400 cursor-not-allowed">
                            ← Previous
                        </span>
                    <% } %>

                    <!-- Page Numbers -->
                    <div class="flex gap-2">
                        <% 
                            int startPage = Math.max(1, currentPage - 2);
                            int endPage = Math.min(totalPages, currentPage + 2);
                            
                            if (startPage > 1) { %>
                                <a href="?page=1" class="px-4 py-2 bg-white border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50">1</a>
                                <% if (startPage > 2) { %>
                                    <span class="px-4 py-2 text-gray-400">...</span>
                                <% } %>
                            <% }
                            
                            for (int i = startPage; i <= endPage; i++) { 
                                if (i == currentPage) { %>
                                    <span class="px-4 py-2 bg-orange-500 text-white rounded-lg font-semibold"><%= i %></span>
                                <% } else { %>
                                    <a href="?page=<%= i %>" class="px-4 py-2 bg-white border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50"><%= i %></a>
                                <% } %>
                            <% }
                            
                            if (endPage < totalPages) { 
                                if (endPage < totalPages - 1) { %>
                                    <span class="px-4 py-2 text-gray-400">...</span>
                                <% } %>
                                <a href="?page=<%= totalPages %>" class="px-4 py-2 bg-white border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50"><%= totalPages %></a>
                            <% } %>
                    </div>

                    <!-- Next Button -->
                    <% if (currentPage < totalPages) { %>
                        <a href="?page=<%= currentPage + 1 %>" 
                           class="px-4 py-2 bg-white border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition-colors">
                            Next →
                        </a>
                    <% } else { %>
                        <span class="px-4 py-2 bg-gray-100 border border-gray-200 rounded-lg text-gray-400 cursor-not-allowed">
                            Next →
                        </span>
                    <% } %>
                </div>

                <!-- Page Info -->
                <div class="mt-4 text-center text-sm text-gray-600">
                    Showing <%= Math.min((currentPage - 1) * pageSize + 1, totalOrders) %> 
                    to <%= Math.min(currentPage * pageSize, totalOrders) %> 
                    of <%= totalOrders %> orders
                </div>
                <% } %>

                <!-- Back to Menu Button -->
                <div class="mt-8 text-center">
                    <a href="${pageContext.request.contextPath}/customer-menu" 
                       class="inline-flex items-center gap-2 bg-orange-500 text-white px-6 py-3 rounded-lg font-semibold hover:bg-orange-600 transition-all shadow-md">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 11-4 0 2 2 0 014 0z" />
                        </svg>
                        Order More Food
                    </a>
                </div>
            </div>
        </div>
    </div>

    <!-- Initialize Lucide Icons -->
    <script src="https://unpkg.com/lucide@latest"></script>
    <script>
        lucide.createIcons();
    </script>
</body>
</html>
