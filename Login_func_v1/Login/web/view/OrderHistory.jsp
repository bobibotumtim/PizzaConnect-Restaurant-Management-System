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
        if (totalOrders == null) totalOrders = 0;
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
                            <% 
                                int completed = 0;
                                if (orders != null) {
                                    for (Order order : orders) {
                                        if (order.getStatus() == 3) completed++;
                                    }
                                }
                            %>
                            <%= completed %>
                        </div>
                    </div>
                    <div class="bg-white rounded-xl shadow-md p-6 border-l-4 border-red-500">
                        <div class="text-sm text-gray-600 mb-2">Total Spent</div>
                        <div class="text-3xl font-bold text-red-600">
                            <% 
                                double totalSpent = 0;
                                if (orders != null) {
                                    for (Order order : orders) {
                                        if (order.getStatus() == 3) { // Only completed orders (status = 3)
                                            totalSpent += order.getTotalPrice();
                                        }
                                    }
                                }
                            %>
                            <%= String.format("%,.0f", totalSpent) %>đ
                        </div>
                    </div>
                </div>

                <!-- Orders Table -->
                <div class="bg-white rounded-xl shadow-md overflow-hidden">
                    <div class="px-6 py-4 border-b border-gray-200">
                        <h2 class="text-xl font-bold text-gray-800">Your Orders</h2>
                    </div>

                    <% if (orders == null || orders.isEmpty()) { %>
                        <div class="p-12 text-center">
                            <div class="text-6xl mb-4">📦</div>
                            <h3 class="text-xl font-semibold text-gray-700 mb-2">No Orders Yet</h3>
                            <p class="text-gray-500 mb-6">You haven't placed any orders yet.</p>
                            <a href="${pageContext.request.contextPath}/customer-menu" 
                               class="inline-block bg-orange-500 text-white px-6 py-3 rounded-lg font-semibold hover:bg-orange-600 transition-all">
                                Browse Menu
                            </a>
                        </div>
                    <% } else { %>
                        <div class="overflow-x-auto">
                            <table class="w-full">
                                <thead class="bg-gray-50">
                                    <tr>
                                        <th class="px-6 py-4 text-left text-sm font-semibold text-gray-700">Order ID</th>
                                        <th class="px-6 py-4 text-left text-sm font-semibold text-gray-700">Date</th>
                                        <th class="px-6 py-4 text-left text-sm font-semibold text-gray-700">Table</th>
                                        <th class="px-6 py-4 text-left text-sm font-semibold text-gray-700">Total</th>
                                        <th class="px-6 py-4 text-left text-sm font-semibold text-gray-700">Status</th>
                                        <th class="px-6 py-4 text-left text-sm font-semibold text-gray-700">Payment</th>
                                        <th class="px-6 py-4 text-left text-sm font-semibold text-gray-700">Note</th>
                                    </tr>
                                </thead>
                                <tbody class="divide-y divide-gray-200">
                                    <% for (Order order : orders) { 
                                        Integer tableId = order.getTableID();
                                        String paymentStatus = order.getPaymentStatus();
                                    %>
                                        <tr class="hover:bg-gray-50 transition-colors">
                                            <td class="px-6 py-4">
                                                <span class="font-semibold text-gray-900">#<%= order.getOrderID() %></span>
                                            </td>
                                            <td class="px-6 py-4 text-gray-700 text-sm">
                                                <%= order.getOrderDate() != null ? order.getOrderDate().toString() : "N/A" %>
                                            </td>
                                            <td class="px-6 py-4 text-gray-700">
                                                <%= tableId != null && tableId != 0 ? "Table " + tableId : "N/A" %>
                                            </td>
                                            <td class="px-6 py-4">
                                                <span class="font-bold text-gray-900">
                                                    <%= String.format("%,.0f", order.getTotalPrice()) %>đ
                                                </span>
                                            </td>
                                            <td class="px-6 py-4">
                                                <% 
                                                    String statusClass = "";
                                                    switch(order.getStatus()) {
                                                        case 0: statusClass = "status-waiting"; break;   // Waiting
                                                        case 1: statusClass = "status-ready"; break;      // Ready
                                                        case 2: statusClass = "status-dining"; break;     // Dining
                                                        case 3: statusClass = "status-completed"; break;  // Completed
                                                        case 4: statusClass = "status-cancelled"; break;  // Cancelled
                                                    }
                                                %>
                                                <span class="status-badge <%= statusClass %>">
                                                    <%= order.getStatusText() %>
                                                </span>
                                            </td>
                                            <td class="px-6 py-4">
                                                <% 
                                                    String paymentClass = "payment-unpaid";
                                                    if ("Paid".equals(paymentStatus)) paymentClass = "payment-paid";
                                                %>
                                                <span class="px-3 py-1 rounded-full text-xs font-semibold <%= paymentClass %>">
                                                    <%= paymentStatus != null ? paymentStatus : "Unpaid" %>
                                                </span>
                                            </td>
                                            <td class="px-6 py-4 text-gray-700 text-sm">
                                                <% 
                                                    String noteText = (order.getNote() != null && !order.getNote().isEmpty()) 
                                                        ? order.getNote() : "None";
                                                %>
                                                <div class="truncate max-w-xs" title="<%= noteText %>">
                                                    <%= noteText %>
                                                </div>
                                            </td>
                                        </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    <% } %>
                </div>

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
