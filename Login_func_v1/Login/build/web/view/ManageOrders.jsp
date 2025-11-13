<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="models.Order" %>
<%@ page import="models.User" %>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PizzaConnect - Order Management</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        .modal {
            display: none;
            position: fixed;
            z-index: 50;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.5);
        }

        .modal.show {
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .fade-in {
            animation: fadeIn 0.3s;
        }

        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: translateY(-20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .status-badge {
            padding: 6px 14px;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 600;
            text-transform: uppercase;
        }

                        /* Order Status Colors - New Workflow */
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
        String message = (String) request.getAttribute("message");
        String error = (String) request.getAttribute("error");
        Integer selectedStatus = (Integer) request.getAttribute("selectedStatus");
    %>

                            <!-- Header -->
                            <div class="bg-gradient-to-r from-red-500 to-orange-500 text-white shadow-lg">
                                <div class="max-w-7xl mx-auto px-6 py-6">
                                    <div class="flex items-center justify-between">
                                        <div class="flex items-center gap-4">
                                            <div
                                                class="w-16 h-16 bg-white rounded-full flex items-center justify-center text-4xl shadow-lg">
                                                🍕
                                            </div>
                                            <div>
                                                <h1 class="text-3xl font-bold">PizzaConnect</h1>
                                                <p class="text-red-100">Restaurant Order Management System</p>
                                            </div>
                                        </div>
                                        <div class="flex items-center gap-4">
                                            <div class="text-right">
                                                <div class="font-semibold">
                                                    <%= user !=null ? user.getName() : "User" %>
                                                </div>
                                                <div class="text-sm text-red-100">
                                                    <% if (user != null) {
                                                        if (user.getRole() == 1) { %>
                                                            Admin
                                                        <% } else if (user.getRole() == 3) { %>
                                                            Customer
                                                        <% } else { %>
                                                            Employee
                                                        <% }
                                                    } %>
                                                </div>
                                            </div>
                                            <a href="Login?action=logout"
                                                class="bg-white text-red-500 px-4 py-2 rounded-lg font-semibold hover:bg-red-50 transition-all">
                                                Logout
                                            </a>
                                        </div>
                                    </div>
                                </div>
                            </div>

    <div class="max-w-7xl mx-auto px-6 py-8">
        <!-- Alert Messages -->
        <% 
            // Get messages from session
            String sessionMessage = (String) session.getAttribute("message");
            String sessionError = (String) session.getAttribute("error");
            
            // Clear messages from session after reading
            if (sessionMessage != null) {
                session.removeAttribute("message");
                message = sessionMessage;
            }
            if (sessionError != null) {
                session.removeAttribute("error");
                error = sessionError;
            }
        %>
        
        <% if (message != null && !message.isEmpty()) { %>
            <div class="bg-green-100 border-l-4 border-green-500 text-green-700 p-4 mb-6 rounded-lg">
                <div class="flex items-center">
                    <svg class="w-5 h-5 mr-2" fill="currentColor" viewBox="0 0 20 20">
                        <path fill-rule="evenodd"
                            d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
                            clip-rule="evenodd" />
                    </svg>
                    <%= message %>
                </div>
            </div>
        <% } %>

        <% if (error != null && !error.isEmpty()) { %>
            <div class="bg-red-100 border-l-4 border-red-500 text-red-700 p-4 mb-6 rounded-lg">
                <div class="flex items-center">
                    <svg class="w-5 h-5 mr-2" fill="currentColor" viewBox="0 0 20 20">
                        <path fill-rule="evenodd"
                            d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z"
                            clip-rule="evenodd" />
                    </svg>
                    <%= error %>
                </div>
            </div>
        <% } %>

                                                <!-- Statistics -->
                                                <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
                                                    <div
                                                        class="bg-white rounded-xl shadow-md p-6 border-l-4 border-blue-500">
                                                        <div class="text-sm text-gray-600 mb-2">Total Orders</div>
                                                        <div class="text-3xl font-bold text-blue-600">
                                                            <%= orders !=null ? orders.size() : 0 %>
                                                        </div>
                                                    </div>
                                                    <div
                                                        class="bg-white rounded-xl shadow-md p-6 border-l-4 border-green-500">
                                                        <div class="text-sm text-gray-600 mb-2">Completed</div>
                                                        <div class="text-3xl font-bold text-green-600">
                                                            <% int completed=0; if (orders !=null) { for (Order order :
                                                                orders) { if (order.getStatus()==3) completed++; } } %>
                                                                <%= completed %>
                                                        </div>
                                                    </div>
                                                    <div
                                                        class="bg-white rounded-xl shadow-md p-6 border-l-4 border-red-500">
                                                        <div class="text-sm text-gray-600 mb-2">Total Revenue</div>
                                                        <div class="text-3xl font-bold text-red-600">
                                                            <% double totalRevenue=0; 
                                                               if (orders !=null) { 
                                                                   for (Order order : orders) { 
                                                                       // Only count Completed orders (status = 3)
                                                                       if (order.getStatus() == 3) {
                                                                           totalRevenue += order.getTotalPrice();
                                                                       }
                                                                   } 
                                                               } 
                                                            %>
                                                            <%= String.format("%,.0f", totalRevenue) %>đ
                                                        </div>
                                                    </div>
                                                </div>

                                                <!-- Filters & Actions -->
                                                <div class="bg-white rounded-xl shadow-md p-6 mb-8">
                                                    <div class="flex flex-wrap gap-4 items-center justify-between">
                                                        <div class="flex flex-wrap gap-4 items-center flex-1">
                                                            <div class="flex-1 min-w-[250px]">
                                                                <label for="statusFilter"
                                                                    class="block text-sm font-semibold text-gray-700 mb-2">
                                                                    Filter by Status
                                                                </label>
                                                                <select id="statusFilter" name="statusFilter"
                                                                    onchange="filterByStatus(this.value)"
                                                                    class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none">
                                                                    <option value="">All Orders</option>
                                                                    <option value="0" <%=selectedStatus !=null &&
                                                                        selectedStatus==0 ? "selected" : "" %>>Waiting
                                                                    </option>
                                                                    <option value="1" <%=selectedStatus !=null &&
                                                                        selectedStatus==1 ? "selected" : "" %>
                                                                        >Ready</option>
                                                                    <option value="2" <%=selectedStatus !=null &&
                                                                        selectedStatus==2 ? "selected" : "" %>>Dining
                                                                    </option>
                                                                    <option value="3" <%=selectedStatus !=null &&
                                                                        selectedStatus==3 ? "selected" : "" %>>Completed
                                                                    </option>
                                                                    <option value="4" <%=selectedStatus !=null &&
                                                                        selectedStatus==4 ? "selected" : "" %>>Cancelled
                                                                    </option>
                                                                </select>

                                                            </div>
                                                        </div>
                                                        <div class="flex gap-2">
                                                            <a href="${pageContext.request.contextPath}/WaiterMonitor"
                                                                class="bg-orange-500 text-white px-6 py-2 rounded-lg font-semibold flex items-center gap-2 hover:bg-orange-600 transition-all shadow-md">
                                                                <svg class="w-5 h-5" fill="none" stroke="currentColor"
                                                                    viewBox="0 0 24 24">
                                                                    <path stroke-linecap="round" stroke-linejoin="round"
                                                                        stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
                                                                </svg>
                                                                Waiter Monitor
                                                            </a>
                                                            <a href="${pageContext.request.contextPath}/pos"
                                                                class="bg-green-500 text-white px-6 py-2 rounded-lg font-semibold flex items-center gap-2 hover:bg-green-600 transition-all shadow-md">
                                                                <svg class="w-5 h-5" fill="none" stroke="currentColor"
                                                                    viewBox="0 0 24 24">
                                                                    <path stroke-linecap="round" stroke-linejoin="round"
                                                                        stroke-width="2" d="M12 4v16m8-8H4" />
                                                                </svg>
                                                                New Order
                                                            </a>
                                                            <a href="${pageContext.request.contextPath}/manage-orders"
                                                                class="bg-blue-500 text-white px-6 py-2 rounded-lg font-semibold flex items-center gap-2 hover:bg-blue-600 transition-all">
                                                                <svg class="w-5 h-5" fill="none" stroke="currentColor"
                                                                    viewBox="0 0 24 24">
                                                                    <path stroke-linecap="round" stroke-linejoin="round"
                                                                        stroke-width="2"
                                                                        d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
                                                                </svg>
                                                                Refresh
                                                            </a>
                                                        </div>
                                                    </div>
                                                </div>

                                                <!-- Table -->
                                                <div class="bg-white rounded-xl shadow-md overflow-hidden">
                                                    <% if (orders==null || orders.isEmpty()) { %>
                                                        <div class="text-center py-16">
                                                            <div class="text-6xl mb-4">📦</div>
                                                            <h3 class="text-xl font-semibold text-gray-700 mb-2">No
                                                                Orders Found</h3>
                                                            <p class="text-gray-500">There are no orders in the system
                                                                yet.</p>
                                                        </div>
                                                        <% } else { %>
                                                            <div class="overflow-visible">
                                                                <table class="w-full table-fixed">
                                                                    <thead
                                                                        class="bg-gray-50 border-b-2 border-gray-200">
                                                                        <tr>
                                                                            <th
                                                                                class="px-4 py-4 text-left text-sm font-semibold text-gray-700" style="width: 8%;">
                                                                                Order ID</th>
                                                                            <th
                                                                                class="px-4 py-4 text-left text-sm font-semibold text-gray-700" style="width: 6%;">
                                                                                Table</th>
                                                                            <th
                                                                                class="px-4 py-4 text-left text-sm font-semibold text-gray-700" style="width: 8%;">
                                                                                Customer</th>
                                                                            <th
                                                                                class="px-4 py-4 text-left text-sm font-semibold text-gray-700" style="width: 12%;">
                                                                                Date</th>
                                                                            <th
                                                                                class="px-4 py-4 text-left text-sm font-semibold text-gray-700" style="width: 10%;">
                                                                                Total</th>
                                                                            <th
                                                                                class="px-4 py-4 text-left text-sm font-semibold text-gray-700" style="width: 10%;">
                                                                                Status</th>
                                                                            <th
                                                                                class="px-4 py-4 text-left text-sm font-semibold text-gray-700" style="width: 8%;">
                                                                                Payment</th>
                                                                            <th
                                                                                class="px-4 py-4 text-left text-sm font-semibold text-gray-700" style="width: 15%;">
                                                                                Note</th>
                                                                            <th
                                                                                class="px-4 py-4 text-center text-sm font-semibold text-gray-700" style="width: 23%;">
                                                                                Actions</th>
                                                                        </tr>
                                                                    </thead>
                                                                    <tbody class="divide-y divide-gray-200">
                                                                        <% for (Order order : orders) { Integer
                                                                            tableId=order.getTableID(); Integer
                                                                            customerId=order.getCustomerID(); %>
                                                                            <tr
                                                                                class="hover:bg-gray-50 transition-colors">
                                                                                <td class="px-4 py-4">
                                                                                    <span
                                                                                        class="font-semibold text-gray-900 text-sm">#
                                                                                        <%= order.getOrderID() %>
                                                                                    </span>
                                                                                </td>
                                                                                <td class="px-4 py-4 text-gray-700 text-sm">
                                                                                    <%= tableId !=null && tableId !=0 ?
                                                                                        tableId : "N/A" %>
                                                                                </td>
                                                                                <td class="px-4 py-4">
                                                                                    <div
                                                                                        class="font-medium text-gray-900 text-sm">
                                                                                        <%= customerId !=null &&
                                                                                            customerId !=0 ? customerId
                                                                                            : "N/A" %>
                                                                                    </div>
                                                                                </td>
                                                                                <td
                                                                                    class="px-4 py-4 text-gray-700 text-xs">
                                                                                    <%= order.getOrderDate() !=null ?
                                                                                        order.getOrderDate().toString()
                                                                                        : "N/A" %>
                                                                                </td>

                                                                                <td class="px-4 py-4">
                                                                                    <span
                                                                                        class="font-bold text-gray-900 text-sm">
                                                                                        <%= String.format("%,.0f",
                                                                                            order.getTotalPrice()) %>đ
                                                                                    </span>
                                                                                </td>
                                                                                <td class="px-4 py-4">
                                                                                    <% String statusClass="" ;
                                                                                        switch(order.getStatus()) { 
                                                                                        case 0: statusClass="status-waiting" ; break;   // Waiting
                                                                                        case 1: statusClass="status-ready" ; break;      // Ready
                                                                                        case 2: statusClass="status-dining" ; break;     // Dining
                                                                                        case 3: statusClass="status-completed" ; break;  // Completed
                                                                                        case 4: statusClass="status-cancelled" ; break;  // Cancelled
                                                                                        } %>
                                                                                        <span
                                                                                            class="status-badge <%= statusClass %>" style="font-size: 0.65rem; padding: 4px 10px;">
                                                                                            <%= order.getStatusText() %>
                                                                                        </span>
                                                                                </td>
                                                                                <td class="px-4 py-4">
                                                                                    <% String
                                                                                        paymentClass="payment-unpaid" ;
                                                                                        String
                                                                                        paymentStatus=order.getPaymentStatus();
                                                                                        if
                                                                                        ("Paid".equals(paymentStatus))
                                                                                        paymentClass="payment-paid" ; %>
                                                                                        <span
                                                                                            class="px-2 py-1 rounded-full text-xs font-semibold <%= paymentClass %>">
                                                                                            <%= paymentStatus !=null ?
                                                                                                paymentStatus : "Unpaid"
                                                                                                %>
                                                                                        </span>
                                                                                </td>
                                                                                <td
                                                                                    class="px-4 py-4 text-gray-700 text-xs">
                                                                                    <% String noteText=(order.getNote()
                                                                                        !=null &&
                                                                                        !order.getNote().isEmpty()) ?
                                                                                        order.getNote() : "None" ; %>
                                                                                        <div class="truncate"
                                                                                            title="<%= noteText %>">
                                                                                            <%= noteText %>
                                                                                        </div>
                                                                                </td>
                                                                                    <td class="px-2 py-4">
                                                                                        <div class="flex items-center justify-center gap-1 flex-wrap">
                                                                                            <%
                                                                                            // Get order status and payment status
                                                                                            int status = order.getStatus();
                                                                                            boolean isPaid = "Paid".equals(paymentStatus);
                                                                                            
                                                                                            // 1. VIEW BUTTON - Show for all orders
                                                                                            %>
                                                                                                <button
                                                                                                    onclick="openViewOrderModal(<%= order.getOrderID() %>)"
                                                                                                    class="px-2 py-1 text-white bg-gray-600 hover:bg-gray-700 rounded text-xs font-medium whitespace-nowrap"
                                                                                                    title="View Details">
                                                                                                    <svg class="w-4 h-4 inline" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                                                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                                                                                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                                                                                                    </svg>
                                                                                                    View
                                                                                                </button>
                                                                                                
                                                                                                <!-- PRINT BILL BUTTON - Show for all orders except cancelled (4) -->
                                                                                                <% if (status != 4) { %>
                                                                                                    <a href="${pageContext.request.contextPath}/bill?orderId=<%= order.getOrderID() %>"
                                                                                                    target="_blank"
                                                                                                    class="px-2 py-1 text-white bg-purple-600 hover:bg-purple-700 rounded text-xs font-medium whitespace-nowrap inline-flex items-center gap-1"
                                                                                                    title="Print Bill">
                                                                                                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                                                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z"/>
                                                                                                        </svg>
                                                                                                        Bill
                                                                                                    </a>
                                                                                                <% } %>
                                                                                                
                                                                                                <!-- ADD BUTTON - Show for Waiting, Ready, Dining (not Completed or Cancelled) -->
                                                                                                <% if (status >= 0 && status <= 2) { %>
                                                                                                <a href="${pageContext.request.contextPath}/pos?orderId=<%= order.getOrderID() %>"
                                                                                                    class="px-2 py-1 text-white bg-green-600 hover:bg-green-700 rounded text-xs font-medium whitespace-nowrap inline-flex items-center gap-1"
                                                                                                    title="Add More Items">
                                                                                                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                                                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
                                                                                                    </svg>
                                                                                                    Add
                                                                                                </a>
                                                                                                <% } %>
        <!-- Table -->
        <div class="bg-white rounded-xl shadow-md overflow-hidden">
            <% if (orders == null || orders.isEmpty()) { %>
                <div class="text-center py-16">
                    <div class="text-6xl mb-4">📦</div>
                    <h3 class="text-xl font-semibold text-gray-700 mb-2">No Orders Found</h3>
                    <p class="text-gray-500">There are no orders in the system yet.</p>
                </div>
            <% } else { %>
                <div class="overflow-visible">
                    <table class="w-full table-fixed">
                        <thead class="bg-gray-50 border-b-2 border-gray-200">
                            <tr>
                                <th class="px-4 py-4 text-left text-sm font-semibold text-gray-700" style="width: 8%;">Order ID</th>
                                <th class="px-4 py-4 text-left text-sm font-semibold text-gray-700" style="width: 6%;">Table</th>
                                <th class="px-4 py-4 text-left text-sm font-semibold text-gray-700" style="width: 8%;">Customer</th>
                                <th class="px-4 py-4 text-left text-sm font-semibold text-gray-700" style="width: 12%;">Date</th>
                                <th class="px-4 py-4 text-left text-sm font-semibold text-gray-700" style="width: 10%;">Total</th>
                                <th class="px-4 py-4 text-left text-sm font-semibold text-gray-700" style="width: 10%;">Status</th>
                                <th class="px-4 py-4 text-left text-sm font-semibold text-gray-700" style="width: 8%;">Payment</th>
                                <th class="px-4 py-4 text-left text-sm font-semibold text-gray-700" style="width: 15%;">Note</th>
                                <th class="px-4 py-4 text-center text-sm font-semibold text-gray-700" style="width: 23%;">Actions</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-200">
                            <% for (Order order : orders) { 
                                Integer tableId = order.getTableID(); 
                                Integer customerId = order.getCustomerID(); 
                            %>
                                <tr class="hover:bg-gray-50 transition-colors">
                                    <td class="px-4 py-4">
                                        <span class="font-semibold text-gray-900 text-sm">#<%= order.getOrderID() %></span>
                                    </td>
                                    <td class="px-4 py-4 text-gray-700 text-sm">
                                        <%= tableId != null && tableId != 0 ? tableId : "N/A" %>
                                    </td>
                                    <td class="px-4 py-4">
                                        <div class="font-medium text-gray-900 text-sm">
                                            <%= customerId != null && customerId != 0 ? customerId : "N/A" %>
                                        </div>
                                    </td>
                                    <td class="px-4 py-4 text-gray-700 text-xs">
                                        <%= order.getOrderDate() != null ? order.getOrderDate().toString() : "N/A" %>
                                    </td>
                                    <td class="px-4 py-4">
                                        <span class="font-bold text-gray-900 text-sm">
                                            <%= String.format("%,.0f", order.getTotalPrice()) %>đ
                                        </span>
                                    </td>
                                    <td class="px-4 py-4">
                                        <% 
                                            String statusClass = "";
                                            switch(order.getStatus()) { 
                                                case 0: statusClass = "status-waiting"; break;
                                                case 1: statusClass = "status-ready"; break;
                                                case 2: statusClass = "status-dining"; break;
                                                case 3: statusClass = "status-completed"; break;
                                                case 4: statusClass = "status-cancelled"; break;
                                            } 
                                        %>
                                        <span class="status-badge <%= statusClass %>" style="font-size: 0.65rem; padding: 4px 10px;">
                                            <%= order.getStatusText() %>
                                        </span>
                                    </td>
                                    <td class="px-4 py-4">
                                        <% 
                                            String paymentClass = "payment-unpaid";
                                            String paymentStatus = order.getPaymentStatus();
                                            if ("Paid".equals(paymentStatus)) paymentClass = "payment-paid";
                                        %>
                                        <span class="px-2 py-1 rounded-full text-xs font-semibold <%= paymentClass %>">
                                            <%= paymentStatus != null ? paymentStatus : "Unpaid" %>
                                        </span>
                                    </td>
                                    <td class="px-4 py-4 text-gray-700 text-xs">
                                        <% 
                                            String noteText = (order.getNote() != null && !order.getNote().isEmpty()) ? order.getNote() : "None";
                                        %>
                                        <div class="truncate" title="<%= noteText %>">
                                            <%= noteText %>
                                        </div>
                                    </td>
                                    <td class="px-2 py-4">
                                        <div class="flex items-center justify-center gap-1 flex-wrap">
                                            <%
                                                // Get order status and payment status
                                                int status = order.getStatus();
                                                boolean isPaid = "Paid".equals(paymentStatus);
                                            %>
                                            <button onclick="openViewOrderModal(<%= order.getOrderID() %>)"
                                                class="px-2 py-1 text-white bg-gray-600 hover:bg-gray-700 rounded text-xs font-medium whitespace-nowrap"
                                                title="View Details">
                                                <svg class="w-4 h-4 inline" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                                                </svg>
                                                View
                                            </button>
                                            
                                            <!-- BILL BUTTON - Show for all orders except cancelled -->
                                            <% if (status != 4) { %>
                                                <button onclick="openBillModal(<%= order.getOrderID() %>)"
                                                    class="px-2 py-1 text-white bg-purple-600 hover:bg-purple-700 rounded text-xs font-medium whitespace-nowrap inline-flex items-center gap-1"
                                                    title="View Bill">
                                                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z"/>
                                                    </svg>
                                                    Bill
                                                </button>
                                            <% } %>
                                            
                                            <% if (status == 0 || status == 1) { %>
                                            <a href="${pageContext.request.contextPath}/pos?orderId=<%= order.getOrderID() %>"
                                                class="px-2 py-1 text-white bg-green-600 hover:bg-green-700 rounded text-xs font-medium whitespace-nowrap inline-flex items-center gap-1"
                                                title="Add More Items">
                                                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
                                                </svg>
                                                Add
                                            </a>
                                            <% } %>

                                                                                                <%
                                                                                                // SERVE BUTTON - Show only for Ready status (1)
                                                                                                if (status == 1) {
                                                                                                %>
                                                                                                    <form
                                                                                                        style="display: inline;"
                                                                                                        method="post"
                                                                                                        onsubmit="return confirm('Đã đưa món cho khách?')">
                                                                                                        <input
                                                                                                            type="hidden"
                                                                                                            name="action"
                                                                                                            value="updateStatus">
                                                                                                        <input
                                                                                                            type="hidden"
                                                                                                            name="orderId"
                                                                                                            value="<%= order.getOrderID() %>">
                                                                                                        <input
                                                                                                            type="hidden"
                                                                                                            name="status"
                                                                                                            value="2">
                                                                                                        <button
                                                                                                            type="submit"
                                                                                                            class="px-2 py-1 bg-blue-500 text-white text-xs rounded hover:bg-blue-600 whitespace-nowrap">
                                                                                                            Serve
                                                                                                        </button>
                                                                                                    </form>
                                                                                                <% } %>

                                                                                                <%
                                                                                                // 4. PAID BUTTON - Show for Unpaid orders except Cancelled (4)
                                                                                                if (!isPaid && status != 4) {
                                                                                                %>
                                                                                                    <form
                                                                                                        style="display: inline;"
                                                                                                        method="post"
                                                                                                        onsubmit="return confirm('Mark this order as Paid?')">
                                                                                                        <input
                                                                                                            type="hidden"
                                                                                                            name="action"
                                                                                                            value="updatePayment"
                                                                                                            aria-label="Action">
                                                                                                        <input
                                                                                                            type="hidden"
                                                                                                            name="orderId"
                                                                                                            value="<%= order.getOrderID() %>"
                                                                                                            aria-label="Order ID">
                                                                                                        <input
                                                                                                            type="hidden"
                                                                                                            name="paymentStatus"
                                                                                                            value="Paid"
                                                                                                            aria-label="Payment Status">
                                                                                                        <button
                                                                                                            type="submit"
                                                                                                            class="px-2 py-1 bg-emerald-500 text-white text-xs rounded hover:bg-emerald-600 whitespace-nowrap">
                                                                                                            Paid
                                                                                                        </button>
                                                                                                    </form>
                                                                                                <% } %>

                                                                                                <%
                                                                                                // 5. CANCEL BUTTON - Show for Waiting, Ready, Dining only
                                                                                                if (status == 0) {
                                                                                                    // Waiting: Cancel without confirm
                                                                                                %>
                                                                                                    <form style="display: inline;" method="post">
                                                                                                        <input type="hidden" name="action" value="updateStatus">
                                                                                                        <input type="hidden" name="orderId" value="<%= order.getOrderID() %>">
                                                                                                        <input type="hidden" name="status" value="4">
                                                                                                        <button type="submit" class="px-2 py-1 bg-red-600 text-white text-xs rounded hover:bg-red-700 whitespace-nowrap">
                                                                                                            Cancel
                                                                                                        </button>
                                                                                                    </form>
                                                                                                <% } else if (status == 1 || status == 2) {
                                                                                                    // Ready or Dining: Cancel WITH confirm
                                                                                                %>
                                                                                                    <form style="display: inline;" method="post" 
                                                                                                        onsubmit="return confirm('⚠️ Bạn chắc chắn muốn hủy đơn hàng này?')">
                                                                                                        <input type="hidden" name="action" value="updateStatus">
                                                                                                        <input type="hidden" name="orderId" value="<%= order.getOrderID() %>">
                                                                                                        <input type="hidden" name="status" value="4">
                                                                                                        <button type="submit" class="px-2 py-1 bg-red-600 text-white text-xs rounded hover:bg-red-700 whitespace-nowrap">
                                                                                                            Cancel
                                                                                                        </button>
                                                                                                    </form>
                                                                                                <% }
                                                                                                // Completed (3) and Cancelled (4): NO Cancel button
                                                                                                %>
                                                                                        </div>
                                                                                    </td>
                                                                                </td>
                                                                            </tr>
                                                                            <% } %>
                                                                    </tbody>
                                                                </table>
                                                            </div>
                                                            <% } %>
                                                </div>
                                            <%
                                            // CANCEL BUTTON - Pending: no confirm, Processing: need confirm
                                            if (status == 0) {
                                                // Pending: Cancel without confirm
                                            %>
                                                <form style="display: inline;" method="post">
                                                    <input type="hidden" name="action" value="updateStatus">
                                                    <input type="hidden" name="orderId" value="<%= order.getOrderID() %>">
                                                    <input type="hidden" name="status" value="4">
                                                    <button type="submit" class="px-2 py-1 bg-red-600 text-white text-xs rounded hover:bg-red-700 whitespace-nowrap">
                                                        Cancel
                                                    </button>
                                                </form>
                                            <% } else if (status == 1) {
                                                // Processing: Cancel WITH confirm
                                            %>
                                                <form style="display: inline;" method="post" 
                                                    onsubmit="return confirm('⚠️ Order is being prepared! Are you sure you want to cancel?')">
                                                    <input type="hidden" name="action" value="updateStatus">
                                                    <input type="hidden" name="orderId" value="<%= order.getOrderID() %>">
                                                    <input type="hidden" name="status" value="4">
                                                    <button type="submit" class="px-2 py-1 bg-red-600 text-white text-xs rounded hover:bg-red-700 whitespace-nowrap">
                                                        Cancel
                                                    </button>
                                                </form>
                                            <% }
                                            // Completed (3) and Cancelled (4): NO Cancel button
                                            %>
                                        </div>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            <% } %>
        </div>

        <!-- Pagination -->
        <% 
            Integer currentPage = (Integer) request.getAttribute("currentPage");
            Integer totalPages = (Integer) request.getAttribute("totalPages");
            Integer totalOrders = (Integer) request.getAttribute("totalOrders");
            
            if (currentPage == null) currentPage = 1;
            if (totalPages == null) totalPages = 1;
            if (totalOrders == null) totalOrders = 0;
            
            if (totalPages > 1) {
        %>
        <div class="bg-white rounded-xl shadow-md p-6 mt-6">
            <div class="flex items-center justify-between">
                <div class="text-sm text-gray-600">
                    Showing page <%= currentPage %> / <%= totalPages %> (Total <%= totalOrders %> orders)
                </div>
                <div class="flex gap-2">
                    <% 
                        String baseUrl = request.getContextPath() + "/manage-orders";
                        String statusParam = "";
                        if (selectedStatus != null) {
                            statusParam = "&status=" + selectedStatus;
                            baseUrl += "?action=filter";
                        } else {
                            baseUrl += "?action=list";
                        }
                        
                        // Previous button
                        if (currentPage > 1) {
                    %>
                        <a href="<%= baseUrl %><%= statusParam %>&page=<%= currentPage - 1 %>" 
                           class="px-4 py-2 bg-gray-200 text-gray-700 rounded-lg hover:bg-gray-300 transition-all">
                            ← Previous
                        </a>
                    <% } else { %>
                        <span class="px-4 py-2 bg-gray-100 text-gray-400 rounded-lg cursor-not-allowed">
                            ← Previous
                        </span>
                    <% } %>
                    
                    <% 
                        // Page numbers
                        int startPage = Math.max(1, currentPage - 2);
                        int endPage = Math.min(totalPages, currentPage + 2);
                        
                        // Show first page
                        if (startPage > 1) {
                    %>
                        <a href="<%= baseUrl %><%= statusParam %>&page=1" 
                           class="px-4 py-2 bg-gray-200 text-gray-700 rounded-lg hover:bg-gray-300 transition-all">
                            1
                        </a>
                        <% if (startPage > 2) { %>
                            <span class="px-4 py-2 text-gray-500">...</span>
                        <% } %>
                    <% } %>
                    
                    <% 
                        // Show page numbers
                        for (int i = startPage; i <= endPage; i++) {
                            if (i == currentPage) {
                    %>
                        <span class="px-4 py-2 bg-blue-500 text-white rounded-lg font-semibold">
                            <%= i %>
                        </span>
                    <% } else { %>
                        <a href="<%= baseUrl %><%= statusParam %>&page=<%= i %>" 
                           class="px-4 py-2 bg-gray-200 text-gray-700 rounded-lg hover:bg-gray-300 transition-all">
                            <%= i %>
                        </a>
                    <% 
                            }
                        }
                    %>
                    
                    <% 
                        // Show last page
                        if (endPage < totalPages) {
                            if (endPage < totalPages - 1) {
                    %>
                            <span class="px-4 py-2 text-gray-500">...</span>
                    <%  } %>
                        <a href="<%= baseUrl %><%= statusParam %>&page=<%= totalPages %>" 
                           class="px-4 py-2 bg-gray-200 text-gray-700 rounded-lg hover:bg-gray-300 transition-all">
                            <%= totalPages %>
                        </a>
                    <% } %>
                    
                    <% 
                        // Next button
                        if (currentPage < totalPages) {
                    %>
                        <a href="<%= baseUrl %><%= statusParam %>&page=<%= currentPage + 1 %>" 
                           class="px-4 py-2 bg-gray-200 text-gray-700 rounded-lg hover:bg-gray-300 transition-all">
                            Next →
                        </a>
                    <% } else { %>
                        <span class="px-4 py-2 bg-gray-100 text-gray-400 rounded-lg cursor-not-allowed">
                            Next →
                        </span>
                    <% } %>
                </div>
            </div>
        </div>
        <% } %>
    </div>

    <!-- View Order Modal -->
    <div id="editOrderModal" class="modal">
        <div class="bg-white rounded-xl shadow-2xl max-w-lg w-full m-4 fade-in">
            <div class="bg-gradient-to-r from-gray-600 to-gray-700 text-white px-6 py-4 flex items-center justify-between rounded-t-xl">
                <h3 class="text-xl font-bold" id="editModalTitle">Order Details</h3>
                <button onclick="closeEditOrderModal()" class="hover:bg-gray-800 rounded-full p-1">
                    <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                    </svg>
                </button>
            </div>
            <div class="p-6">
                <div class="space-y-4">
                    <div class="grid grid-cols-2 gap-4">
                        <div>
                            <label class="block text-sm font-semibold text-gray-700 mb-1">Order ID</label>
                            <div id="viewOrderID" class="px-4 py-2 bg-gray-100 rounded-lg text-gray-800 font-mono"></div>
                        </div>
                        <div>
                            <label class="block text-sm font-semibold text-gray-700 mb-1">Table</label>
                            <div id="viewTable" class="px-4 py-2 bg-gray-100 rounded-lg text-gray-800"></div>
                        </div>
                    </div>

                    <div class="grid grid-cols-2 gap-4">
                        <div>
                            <label class="block text-sm font-semibold text-gray-700 mb-1">Status</label>
                            <div id="viewStatus" class="px-4 py-2 bg-gray-100 rounded-lg"></div>
                        </div>
                        <div>
                            <label class="block text-sm font-semibold text-gray-700 mb-1">Payment</label>
                            <div id="viewPayment" class="px-4 py-2 bg-gray-100 rounded-lg"></div>
                        </div>
                    </div>

                    <div>
                        <label class="block text-sm font-semibold text-gray-700 mb-1">Total Price</label>
                        <div id="viewTotal" class="px-4 py-2 bg-gray-100 rounded-lg text-green-600 font-bold text-lg"></div>
                    </div>

                    <div>
                        <label class="block text-sm font-semibold text-gray-700 mb-1">Order Items</label>
                        <div id="viewItems" class="px-4 py-3 bg-gray-50 rounded-lg border border-gray-200 max-h-48 overflow-y-auto"></div>
                    </div>

                    <div>
                        <label class="block text-sm font-semibold text-gray-700 mb-1">Note</label>
                        <div id="viewNote" class="px-4 py-2 bg-gray-100 rounded-lg text-gray-600 italic min-h-[60px]"></div>
                    </div>
                </div>

                <div class="flex justify-end gap-3 mt-6">
                    <button type="button" onclick="closeEditOrderModal()"
                        class="px-6 py-2 bg-gray-600 text-white rounded-lg hover:bg-gray-700">
                        Close
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- Bill Modal -->
    <div id="billModal" class="modal">
        <div class="bg-white rounded-xl shadow-2xl max-w-4xl w-full max-h-[90vh] overflow-hidden m-4 fade-in">
            <div class="bg-gradient-to-r from-purple-500 to-purple-600 text-white px-6 py-4 flex items-center justify-between rounded-t-xl">
                <h3 class="text-xl font-bold">Payment Bill - Order <span id="billOrderNumber"></span></h3>
                <button onclick="closeBillModal()" class="hover:bg-purple-700 rounded-full p-1">
                    <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                    </svg>
                </button>
            </div>
            
            <!-- Payment Status Display -->
            <div class="bg-gray-50 px-6 py-4 border-b">
                <div class="flex items-center justify-between">
                    <div class="flex items-center gap-4">
                        <label class="text-sm font-semibold text-gray-700">Payment Method:</label>
                        <span class="px-3 py-1 bg-blue-100 text-blue-800 rounded-full text-sm font-semibold">
                            QR Code
                        </span>
                        
                        <!-- Payment Status Display -->
                        <div id="paymentStatusDisplay" class="flex items-center gap-2">
                            <span id="paymentStatusBadge" class="px-3 py-1 rounded-full text-xs font-semibold"></span>
                        </div>
                    </div>
                    
                    <!-- Action Buttons -->
                    <div class="flex gap-2">
                        <button id="processPaymentBtn" class="px-4 py-2 bg-green-500 text-white rounded hover:bg-green-600 flex items-center gap-2">
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
                            </svg>
                            Confirm Payment
                        </button>
                        <button onclick="printBill()" class="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600 flex items-center gap-2">
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z"/>
                            </svg>
                            Print Bill
                        </button>
                    </div>
                </div>
            </div>
            
            <!-- Bill Content -->
            <div id="billContent" class="p-0 overflow-auto" style="max-height: 500px;">
                <!-- Bill content will be loaded here -->
            </div>
            
            <!-- Footer -->
            <div class="bg-gray-50 px-6 py-4 border-t flex justify-end">
                <button onclick="closeBillModal()" class="px-6 py-2 bg-gray-500 text-white rounded hover:bg-gray-600">
                    Close
                </button>
            </div>
        </div>
    </div>

<script>
    // Sửa lỗi context path - đảm bảo lấy đúng context path
    const ctx = '${pageContext.request.contextPath}';
    console.log('Context Path:', ctx);

    function filterByStatus(status) {
        const baseUrl = ctx + '/manage-orders';
        if (status === '') {
            window.location.href = baseUrl + '?page=1';
        } else {
            window.location.href = baseUrl + '?action=filter&status=' + status + '&page=1';
        }
    }

    // View Order Modal Functions
    function openViewOrderModal(orderId) {
        const modal = document.getElementById("editOrderModal");
        
        const url = ctx + '/manage-orders?action=getOrder&id=' + orderId;
        
        fetch(url)
            .then(res => res.json())
            .then(data => {
                if (!data.success) {
                    alert("Could not load order data.");
                    return;
                }

                const o = data.order;
                const statusText = ['Waiting', 'Ready', 'Dining', 'Completed', 'Cancelled'][o.status];
                const statusColor = ['yellow', 'blue', 'orange', 'green', 'red'][o.status];
                
                document.getElementById("viewOrderID").textContent = '#' + o.orderID;
                document.getElementById("viewTable").textContent = 'Table ' + (o.tableID || 'N/A');
                document.getElementById("viewStatus").innerHTML = '<span class="px-3 py-1 rounded-full text-white bg-' + statusColor + '-500">' + statusText + '</span>';
                document.getElementById("viewPayment").innerHTML = '<span class="px-3 py-1 rounded-full text-white bg-' + (o.paymentStatus === 'Paid' ? 'green' : 'orange') + '-500">' + (o.paymentStatus || 'Unpaid') + '</span>';
                document.getElementById("viewTotal").textContent = (o.totalPrice || 0).toLocaleString('vi-VN') + ' VND';
                document.getElementById("viewNote").textContent = o.note || 'No notes';
                
                // Load order items
                if (data.details && data.details.length > 0) {
                    let itemsHTML = '<div class="space-y-2">';
                    data.details.forEach(item => {
                        itemsHTML += '<div class="flex justify-between py-2 border-b">';
                        itemsHTML += '<div><span class="font-semibold">' + item.productName + '</span> x' + item.quantity + '</div>';
                        itemsHTML += '<div class="text-gray-600">' + (item.totalPrice || 0).toLocaleString('vi-VN') + ' VND</div>';
                        itemsHTML += '</div>';
                    });
                    itemsHTML += '</div>';
                    document.getElementById("viewItems").innerHTML = itemsHTML;
                } else {
                    document.getElementById("viewItems").innerHTML = '<p class="text-gray-500">No items</p>';
                }

                modal.classList.add("show");
            })
            .catch(err => {
                console.error("Error:", err);
                alert("Error loading order details");
            });
    }

    function closeEditOrderModal() {
        document.getElementById("editOrderModal").classList.remove("show");
    }

    // Bill Modal Functions
    let currentBillOrderId = null;
    let currentPaymentStatus = null;

    function openBillModal(orderId) {
        console.log('Opening bill modal for order:', orderId);
        currentBillOrderId = orderId;
        const modal = document.getElementById('billModal');
        const billContent = document.getElementById('billContent');
        const billOrderNumber = document.getElementById('billOrderNumber');
        
        // Update order number in modal title
        billOrderNumber.textContent = '#' + orderId;
        
        // Show loading
        billContent.innerHTML = `
            <div class="flex justify-center items-center py-12">
                <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-purple-500"></div>
                <span class="ml-3 text-gray-600">Loading bill...</span>
            </div>
        `;
        
        modal.classList.add('show');
        
        // Load bill content using iframe
        loadBillWithIframe(orderId);
    }

    function loadBillWithIframe(orderId) {
        const billContent = document.getElementById('billContent');
        
        const billUrl = ctx + '/bill?orderId=' + orderId + '&embedded=true';
        
        // Create iframe to load the bill
        const iframe = document.createElement('iframe');
        iframe.src = billUrl;
        iframe.style.width = '100%';
        iframe.style.height = '500px';
        iframe.style.border = 'none';
        iframe.onload = function() {
            console.log('Bill iframe loaded successfully');
            console.log('Loaded URL:', billUrl);
            
            // Load payment status after bill is loaded
            loadPaymentStatus(orderId);
        };
        iframe.onerror = function() {
            console.error('Failed to load bill iframe');
            console.error('Failed URL:', billUrl);
            
            billContent.innerHTML = `
                <div class="text-center py-8 text-red-600">
                    <p>Failed to load bill. Please try again.</p>
                    <button onclick="openBillModal(${orderId})" class="mt-4 px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600">
                        Retry
                    </button>
                </div>
            `;
        };
        
        billContent.innerHTML = '';
        billContent.appendChild(iframe);
    }

    function loadPaymentStatus(orderId) {
        // Fetch current payment status
        fetch(ctx + '/manage-orders?action=getOrder&id=' + orderId)
            .then(res => res.json())
            .then(data => {
                if (data.success) {
                    const order = data.order;
                    currentPaymentStatus = order.paymentStatus;
                    
                    // Update payment status display
                    updatePaymentStatusDisplay(order.paymentStatus);
                    
                    // Update process payment button state
                    updateProcessPaymentButton(order.paymentStatus);
                }
            })
            .catch(err => {
                console.error('Error loading payment status:', err);
            });
    }

    function updatePaymentStatusDisplay(paymentStatus) {
        const paymentStatusBadge = document.getElementById('paymentStatusBadge');
        const paymentStatusDisplay = document.getElementById('paymentStatusDisplay');
        
        if (paymentStatus === 'Paid') {
            paymentStatusBadge.textContent = 'Paid';
            paymentStatusBadge.className = 'px-3 py-1 rounded-full text-xs font-semibold bg-green-100 text-green-800';
            paymentStatusDisplay.innerHTML = `
                <span id="paymentStatusBadge" class="px-3 py-1 rounded-full text-xs font-semibold bg-green-100 text-green-800">Paid</span>
                <span class="text-green-600 text-sm">✅ Payment Completed</span>
            `;
        } else {
            paymentStatusBadge.textContent = 'Unpaid';
            paymentStatusBadge.className = 'px-3 py-1 rounded-full text-xs font-semibold bg-red-100 text-red-800';
            paymentStatusDisplay.innerHTML = `
                <span id="paymentStatusBadge" class="px-3 py-1 rounded-full text-xs font-semibold bg-red-100 text-red-800">Unpaid</span>
            `;
        }
    }

    function updateProcessPaymentButton(paymentStatus) {
        const processPaymentBtn = document.getElementById('processPaymentBtn');
        if (paymentStatus === 'Paid') {
            processPaymentBtn.disabled = true;
            processPaymentBtn.innerHTML = `
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
                </svg>
                Payment Completed
            `;
            processPaymentBtn.className = 'px-4 py-2 bg-gray-400 text-white rounded cursor-not-allowed flex items-center gap-2';
        } else {
            processPaymentBtn.disabled = false;
            processPaymentBtn.innerHTML = `
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
                </svg>
                Confirm Payment
            `;
            processPaymentBtn.className = 'px-4 py-2 bg-green-500 text-white rounded hover:bg-green-600 flex items-center gap-2';
        }
    }

    function closeBillModal() {
        document.getElementById('billModal').classList.remove('show');
        currentBillOrderId = null;
        currentPaymentStatus = null;
    }

    function printBill() {
        if (currentBillOrderId) {
            // Get the iframe content
            const iframe = document.querySelector('#billContent iframe');
            if (iframe && iframe.contentWindow) {
                // Trigger print on the iframe
                iframe.contentWindow.print();
            } else {
                // Fallback: open in new window
                const printUrl = ctx + '/bill?orderId=' + currentBillOrderId;
                const printWindow = window.open(printUrl, '_blank');
                if (printWindow) {
                    printWindow.onload = function() {
                        printWindow.print();
                    };
                }
            }
        }
    }

    // Process Payment - FIXED VERSION
    document.addEventListener('click', function(e) {
        if (e.target && e.target.id === 'processPaymentBtn') {
            processPayment();
        }
    });

    async function processPayment() {
        if (!currentBillOrderId) return;
        
        if (!confirm('Are you sure you want to confirm payment for this order?')) {
            return;
        }
        
        try {
            console.log('Processing payment for order:', currentBillOrderId);
            
            const formData = new URLSearchParams();
            formData.append('action', 'processPayment');
            formData.append('orderId', currentBillOrderId);
            formData.append('embedded', 'true'); // Thêm embedded parameter
            
            const response = await fetch(ctx + '/bill', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: formData
            });
            
            const result = await response.text();
            console.log('Payment response:', result);
            
            if (response.ok) {
                if (result.startsWith('success:')) {
                    const message = result.substring(8); // Remove "success:" prefix
                    alert('✅ ' + message);
                    // Update UI immediately
                    updatePaymentStatusDisplay('Paid');
                    updateProcessPaymentButton('Paid');
                    // Close modal after short delay
                    setTimeout(() => {
                        closeBillModal();
                        // Refresh page to update order list
                        window.location.reload();
                    }, 1500);
                } else if (result.startsWith('error:')) {
                    const error = result.substring(6); // Remove "error:" prefix
                    alert('❌ ' + error);
                } else {
                    // Nếu response không đúng format, hiển thị toàn bộ response để debug
                    console.error('Unexpected response format:', result);
                    alert('❌ Unexpected response from server. Check console for details.');
                }
            } else {
                alert('❌ HTTP Error: ' + response.status + ' - ' + result);
            }
        } catch (error) {
            console.error('Error processing payment:', error);
            alert('❌ Error processing payment: ' + error.message);
        }
    }

    // Close modal when clicking outside
    window.onclick = function (event) {
        const editModal = document.getElementById('editOrderModal');
        const billModal = document.getElementById('billModal');
        if (event.target === editModal) {
            closeEditOrderModal();
        }
        if (event.target === billModal) {
            closeBillModal();
        }
    }

    // Debug: Kiểm tra context path khi trang load
    document.addEventListener('DOMContentLoaded', function() {
        console.log('Page loaded - Context Path:', ctx);
        console.log('Full bill URL example:', ctx + '/bill?orderId=1');
    });
</script>
</body>
</html>