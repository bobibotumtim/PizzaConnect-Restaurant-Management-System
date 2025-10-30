<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ page import="java.util.List" %>
        <%@ page import="models.Order" %>
            <%@ page import="models.User" %>
                <!DOCTYPE html>
                <html lang="vi">

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

                        .status-pending {
                            background: #f59e0b;
                            color: white;
                        }

                        .status-processing {
                            background: #3b82f6;
                            color: white;
                        }

                        .status-completed {
                            background: #10b981;
                            color: white;
                        }

                        .status-cancelled {
                            background: #ef4444;
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
                    <% User currentUser=(User) request.getAttribute("currentUser"); User sessionUser=(User)
                        session.getAttribute("user"); User user=currentUser !=null ? currentUser : sessionUser;
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
                                                    <%= user !=null && user.getRole()==1 ? "Admin" : "Employee" %>
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
                                <% if (message !=null && !message.isEmpty()) { %>
                                    <div
                                        class="bg-green-100 border-l-4 border-green-500 text-green-700 p-4 mb-6 rounded-lg">
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

                                        <% if (error !=null && !error.isEmpty()) { %>
                                            <div
                                                class="bg-red-100 border-l-4 border-red-500 text-red-700 p-4 mb-6 rounded-lg">
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
                                                                orders) { if (order.getStatus()==2) completed++; } } %>
                                                                <%= completed %>
                                                        </div>
                                                    </div>
                                                    <div
                                                        class="bg-white rounded-xl shadow-md p-6 border-l-4 border-red-500">
                                                        <div class="text-sm text-gray-600 mb-2">Total Revenue</div>
                                                        <div class="text-3xl font-bold text-red-600">
                                                            <% double totalRevenue=0; if (orders !=null) { for (Order
                                                                order : orders) { totalRevenue +=order.getTotalPrice();
                                                                } } %>
                                                                $<%= String.format("%.2f", totalRevenue) %>
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
                                                                        selectedStatus==0 ? "selected" : "" %>>Pending
                                                                    </option>
                                                                    <option value="1" <%=selectedStatus !=null &&
                                                                        selectedStatus==1 ? "selected" : "" %>
                                                                        >Processing</option>
                                                                    <option value="2" <%=selectedStatus !=null &&
                                                                        selectedStatus==2 ? "selected" : "" %>>Completed
                                                                    </option>
                                                                    <option value="3" <%=selectedStatus !=null &&
                                                                        selectedStatus==3 ? "selected" : "" %>>Cancelled
                                                                    </option>
                                                                </select>

                                                            </div>
                                                        </div>
                                                        <div class="flex gap-2">
                                                            <button onclick="openAddOrderModal()"
                                                                class="bg-green-500 text-white px-6 py-2 rounded-lg font-semibold flex items-center gap-2 hover:bg-green-600 transition-all shadow-md">
                                                                <svg class="w-5 h-5" fill="none" stroke="currentColor"
                                                                    viewBox="0 0 24 24">
                                                                    <path stroke-linecap="round" stroke-linejoin="round"
                                                                        stroke-width="2" d="M12 4v16m8-8H4" />
                                                                </svg>
                                                                New Order
                                                            </button>
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
                                                            <a href="${pageContext.request.contextPath}/dashboard"
                                                                class="bg-indigo-500 text-white px-6 py-2 rounded-lg font-semibold flex items-center gap-2 hover:bg-indigo-600 transition-all">
                                                                <svg class="w-5 h-5" fill="none" stroke="currentColor"
                                                                    viewBox="0 0 24 24">
                                                                    <path stroke-linecap="round" stroke-linejoin="round"
                                                                        stroke-width="2"
                                                                        d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
                                                                </svg>
                                                                Dashboard
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
                                                            <div class="overflow-x-auto">
                                                                <table class="w-full">
                                                                    <thead
                                                                        class="bg-gray-50 border-b-2 border-gray-200">
                                                                        <tr>
                                                                            <th
                                                                                class="px-6 py-4 text-left text-sm font-semibold text-gray-700">
                                                                                Order ID</th>
                                                                            <th
                                                                                class="px-6 py-4 text-left text-sm font-semibold text-gray-700">
                                                                                Table</th>
                                                                            <th
                                                                                class="px-6 py-4 text-left text-sm font-semibold text-gray-700">
                                                                                Customer</th>
                                                                            <th
                                                                                class="px-6 py-4 text-left text-sm font-semibold text-gray-700">
                                                                                Date</th>
                                                                            <th
                                                                                class="px-6 py-4 text-left text-sm font-semibold text-gray-700">
                                                                                Total</th>
                                                                            <th
                                                                                class="px-6 py-4 text-left text-sm font-semibold text-gray-700">
                                                                                Status</th>
                                                                            <th
                                                                                class="px-6 py-4 text-left text-sm font-semibold text-gray-700">
                                                                                Payment</th>
                                                                            <th
                                                                                class="px-6 py-4 text-left text-sm font-semibold text-gray-700">
                                                                                Note</th>
                                                                            <th
                                                                                class="px-6 py-4 text-center text-sm font-semibold text-gray-700">
                                                                                Actions</th>
                                                                        </tr>
                                                                    </thead>
                                                                    <tbody class="divide-y divide-gray-200">
                                                                        <% for (Order order : orders) { Integer
                                                                            tableId=order.getTableID(); Integer
                                                                            customerId=order.getCustomerID(); %>
                                                                            <tr
                                                                                class="hover:bg-gray-50 transition-colors">
                                                                                <td class="px-6 py-4">
                                                                                    <span
                                                                                        class="font-semibold text-gray-900">#
                                                                                        <%= order.getOrderID() %>
                                                                                    </span>
                                                                                </td>
                                                                                <td class="px-6 py-4 text-gray-700">
                                                                                    <%= tableId !=null && tableId !=0 ?
                                                                                        tableId : "N/A" %>
                                                                                </td>
                                                                                <td class="px-6 py-4">
                                                                                    <div
                                                                                        class="font-medium text-gray-900">
                                                                                        <%= customerId !=null &&
                                                                                            customerId !=0 ? customerId
                                                                                            : "N/A" %>
                                                                                    </div>
                                                                                </td>
                                                                                <td
                                                                                    class="px-6 py-4 text-gray-700 text-sm">
                                                                                    <%= order.getOrderDate() !=null ?
                                                                                        order.getOrderDate().toString()
                                                                                        : "N/A" %>
                                                                                </td>

                                                                                <td class="px-6 py-4">
                                                                                    <span
                                                                                        class="font-bold text-gray-900">$
                                                                                        <%= String.format("%.2f",
                                                                                            order.getTotalPrice()) %>
                                                                                    </span>
                                                                                </td>
                                                                                <td class="px-6 py-4">
                                                                                    <% String statusClass="" ;
                                                                                        switch(order.getStatus()) { case
                                                                                        0: statusClass="status-pending"
                                                                                        ; break; case 1:
                                                                                        statusClass="status-processing"
                                                                                        ; break; case 2:
                                                                                        statusClass="status-completed" ;
                                                                                        break; case 3:
                                                                                        statusClass="status-cancelled" ;
                                                                                        break; } %>
                                                                                        <span
                                                                                            class="status-badge <%= statusClass %>">
                                                                                            <%= order.getStatusText() %>
                                                                                        </span>
                                                                                </td>
                                                                                <td class="px-6 py-4">
                                                                                    <% String
                                                                                        paymentClass="payment-unpaid" ;
                                                                                        String
                                                                                        paymentStatus=order.getPaymentStatus();
                                                                                        if
                                                                                        ("Paid".equals(paymentStatus))
                                                                                        paymentClass="payment-paid" ; %>
                                                                                        <span
                                                                                            class="px-3 py-1 rounded-full text-xs font-semibold <%= paymentClass %>">
                                                                                            <%= paymentStatus !=null ?
                                                                                                paymentStatus : "Unpaid"
                                                                                                %>
                                                                                        </span>
                                                                                </td>
                                                                                <td
                                                                                    class="px-6 py-4 text-gray-700 text-sm max-w-xs">
                                                                                    <% String noteText=(order.getNote()
                                                                                        !=null &&
                                                                                        !order.getNote().isEmpty()) ?
                                                                                        order.getNote() : "None" ; %>
                                                                                        <div class="truncate"
                                                                                            title="<%= noteText %>">
                                                                                            <%= noteText %>
                                                                                        </div>
                                                                                </td>
                                                                                <td class="px-6 py-4">
                                                                                    <div class="flex items-center justify-center gap-1 overflow-x-auto"
                                                                                        style="min-width: 300px;">
                                                                                        <% if (order.getStatus() !=3) {
                                                                                            %>
                                                                                            <button
                                                                                                onclick="openEditOrderModal(<%= order.getOrderID() %>)"
                                                                                                class="p-1 text-blue-600 hover:bg-blue-50 rounded transition-colors"
                                                                                                title="Edit">
                                                                                                <svg class="w-5 h-5"
                                                                                                    fill="none"
                                                                                                    stroke="currentColor"
                                                                                                    viewBox="0 0 24 24">
                                                                                                    <path
                                                                                                        stroke-linecap="round"
                                                                                                        stroke-linejoin="round"
                                                                                                        stroke-width="2"
                                                                                                        d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                                                                                                </svg>
                                                                                            </button>
                                                                                            <% } %>

                                                                                                <% if
                                                                                                    (order.getStatus()==0)
                                                                                                    { %>
                                                                                                    <form
                                                                                                        style="display: inline;"
                                                                                                        method="post"
                                                                                                        onsubmit="return confirm('Mark this order as Processing?')">
                                                                                                        <input
                                                                                                            type="hidden"
                                                                                                            name="action"
                                                                                                            value="updateStatus"
                                                                                                            aria-label="Action">
                                                                                                        <input
                                                                                                            type="hidden"
                                                                                                            name="orderId"
                                                                                                            value="<%= order.getOrderID() %>"
                                                                                                            aria-label="Order ID">
                                                                                                        <input
                                                                                                            type="hidden"
                                                                                                            name="status"
                                                                                                            value="1"
                                                                                                            aria-label="Status">
                                                                                                        <button
                                                                                                            type="submit"
                                                                                                            class="px-2 py-1 bg-yellow-500 text-white text-xs rounded hover:bg-yellow-600 whitespace-nowrap">
                                                                                                            Process
                                                                                                        </button>
                                                                                                    </form>
                                                                                                    <% } %>

                                                                                                        <% if
                                                                                                            (order.getStatus()==1)
                                                                                                            { %>
                                                                                                            <form
                                                                                                                style="display: inline;"
                                                                                                                method="post"
                                                                                                                onsubmit="return confirm('Mark this order as Completed?')">
                                                                                                                <input
                                                                                                                    type="hidden"
                                                                                                                    name="action"
                                                                                                                    value="updateStatus"
                                                                                                                    aria-label="Action">
                                                                                                                <input
                                                                                                                    type="hidden"
                                                                                                                    name="orderId"
                                                                                                                    value="<%= order.getOrderID() %>"
                                                                                                                    aria-label="Order ID">
                                                                                                                <input
                                                                                                                    type="hidden"
                                                                                                                    name="status"
                                                                                                                    value="2"
                                                                                                                    aria-label="Status">
                                                                                                                <button
                                                                                                                    type="submit"
                                                                                                                    class="px-2 py-1 bg-green-500 text-white text-xs rounded hover:bg-green-600 whitespace-nowrap">
                                                                                                                    Complete
                                                                                                                </button>
                                                                                                            </form>
                                                                                                            <% } %>

                                                                                                                <% if
                                                                                                                    ((paymentStatus==null
                                                                                                                    ||
                                                                                                                    !"Paid".equals(paymentStatus))
                                                                                                                    &&
                                                                                                                    order.getStatus()
                                                                                                                    !=3)
                                                                                                                    { %>
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
                                                                                                                    <% }
                                                                                                                        %>

                                                                                                                        <% if
                                                                                                                            (order.getStatus()
                                                                                                                            !=2
                                                                                                                            &&
                                                                                                                            order.getStatus()
                                                                                                                            !=3)
                                                                                                                            {
                                                                                                                            %>
                                                                                                                            <form
                                                                                                                                style="display: inline;"
                                                                                                                                method="post"
                                                                                                                                onsubmit="return confirm('Cancel this order?')">
                                                                                                                                <input
                                                                                                                                    type="hidden"
                                                                                                                                    name="action"
                                                                                                                                    value="updateStatus"
                                                                                                                                    aria-label="Action">
                                                                                                                                <input
                                                                                                                                    type="hidden"
                                                                                                                                    name="orderId"
                                                                                                                                    value="<%= order.getOrderID() %>"
                                                                                                                                    aria-label="Order ID">
                                                                                                                                <input
                                                                                                                                    type="hidden"
                                                                                                                                    name="status"
                                                                                                                                    value="3"
                                                                                                                                    aria-label="Status">
                                                                                                                                <button
                                                                                                                                    type="submit"
                                                                                                                                    class="px-2 py-1 bg-orange-500 text-white text-xs rounded hover:bg-orange-600 whitespace-nowrap">
                                                                                                                                    Cancel
                                                                                                                                </button>
                                                                                                                            </form>
                                                                                                                            <% }
                                                                                                                                %>

                                                                                                                                <% if
                                                                                                                                    ((order.getStatus()==0
                                                                                                                                    ||
                                                                                                                                    order.getStatus()==3)
                                                                                                                                    &&
                                                                                                                                    !"Paid".equals(paymentStatus))
                                                                                                                                    {
                                                                                                                                    %>
                                                                                                                                    <form
                                                                                                                                        style="display: inline;"
                                                                                                                                        method="post"
                                                                                                                                        onsubmit="return confirm('Delete this order permanently?')">
                                                                                                                                        <input
                                                                                                                                            type="hidden"
                                                                                                                                            name="action"
                                                                                                                                            value="delete"
                                                                                                                                            aria-label="Action">
                                                                                                                                        <input
                                                                                                                                            type="hidden"
                                                                                                                                            name="orderId"
                                                                                                                                            value="<%= order.getOrderID() %>"
                                                                                                                                            aria-label="Order ID">
                                                                                                                                        <button
                                                                                                                                            type="submit"
                                                                                                                                            class="p-1 text-red-600 hover:bg-red-50 rounded transition-colors"
                                                                                                                                            title="Delete">
                                                                                                                                            <svg class="w-5 h-5"
                                                                                                                                                fill="none"
                                                                                                                                                stroke="currentColor"
                                                                                                                                                viewBox="0 0 24 24">
                                                                                                                                                <path
                                                                                                                                                    stroke-linecap="round"
                                                                                                                                                    stroke-linejoin="round"
                                                                                                                                                    stroke-width="2"
                                                                                                                                                    d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                                                                                                                                            </svg>
                                                                                                                                        </button>
                                                                                                                                    </form>
                                                                                                                                    <% }
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
                            </div>

                            <!-- Add Order Modal -->
                            <div id="addOrderModal" class="modal">
                                <div
                                    class="bg-white rounded-xl shadow-2xl max-w-2xl w-full max-h-[90vh] overflow-auto m-4 fade-in">
                                    <div
                                        class="bg-gradient-to-r from-green-500 to-green-600 text-white px-6 py-4 flex items-center justify-between rounded-t-xl">
                                        <h3 class="text-xl font-bold">Add New Order</h3>
                                        <button onclick="closeAddOrderModal()"
                                            class="hover:bg-green-700 rounded-full p-1">
                                            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                                    d="M6 18L18 6M6 6l12 12" />
                                            </svg>
                                        </button>
                                    </div>
                                    <form id="addOrderForm" onsubmit="submitAddOrderForm(event)" class="p-6">
                                        <div class="space-y-4">
                                            <div>
                                                <label for="orderItems"
                                                    class="block text-sm font-semibold text-gray-700 mb-2">Order
                                                    Items</label>
                                                <div id="orderItems" class="space-y-3"></div>
                                                <button type="button" onclick="addOrderItemRow()"
                                                    class="mt-3 w-full bg-blue-500 text-white px-4 py-2 rounded-lg hover:bg-blue-600 flex items-center justify-center gap-2">
                                                    <svg class="w-5 h-5" fill="none" stroke="currentColor"
                                                        viewBox="0 0 24 24">
                                                        <path stroke-linecap="round" stroke-linejoin="round"
                                                            stroke-width="2" d="M12 4v16m8-8H4" />
                                                    </svg>
                                                    Add Pizza
                                                </button>
                                            </div>

                                            <div>
                                                <label for="add-order-status"
                                                    class="block text-sm font-semibold text-gray-700 mb-2">Status</label>
                                                <select id="add-order-status" name="status"
                                                    class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500">
                                                    <option value="0">Pending</option>
                                                    <option value="1">Processing</option>
                                                    <option value="2">Completed</option>
                                                    <option value="3">Cancelled</option>
                                                </select>
                                            </div>
                                        </div>

                                        <div id="addOrderError"
                                            class="hidden mt-4 p-3 bg-red-100 text-red-700 rounded-lg"></div>

                                        <div class="flex justify-end gap-3 mt-6">
                                            <button type="button" onclick="closeAddOrderModal()"
                                                class="px-6 py-2 bg-gray-300 text-gray-700 rounded-lg hover:bg-gray-400">
                                                Cancel
                                            </button>
                                            <button type="submit"
                                                class="px-6 py-2 bg-green-500 text-white rounded-lg hover:bg-green-600">
                                                Create Order
                                            </button>
                                        </div>
                                    </form>
                                </div>
                            </div>

                            <!-- Edit Order Modal -->
                            <div id="editOrderModal" class="modal">
                                <div class="bg-white rounded-xl shadow-2xl max-w-md w-full m-4 fade-in">
                                    <div
                                        class="bg-gradient-to-r from-blue-500 to-blue-600 text-white px-6 py-4 flex items-center justify-between rounded-t-xl">
                                        <h3 class="text-xl font-bold" id="editModalTitle">Edit Order</h3>
                                        <button onclick="closeEditOrderModal()"
                                            class="hover:bg-blue-700 rounded-full p-1">
                                            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                                    d="M6 18L18 6M6 6l12 12" />
                                            </svg>
                                        </button>
                                    </div>
                                    <form id="editOrderForm" onsubmit="submitEditOrderForm(event)" class="p-6">
                                        <input type="hidden" id="editOrderID" name="orderID" aria-label="Order ID">

                                        <div class="space-y-4">
                                            <div>
                                                <label for="editStatus"
                                                    class="block text-sm font-semibold text-gray-700 mb-2">
                                                    Status
                                                </label>
                                                <select id="editStatus" name="status" required
                                                    class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500">
                                                    <option value="0">Pending</option>
                                                    <option value="1">Processing</option>
                                                    <option value="2">Completed</option>
                                                    <option value="3">Cancelled</option>
                                                </select>
                                            </div>


                                            <div>
                                                <label for="editPaymentStatus"
                                                    class="block text-sm font-semibold text-gray-700 mb-2">Payment
                                                    Status</label>
                                                <select id="editPaymentStatus" name="paymentStatus" required
                                                    class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500">
                                                    <option value="Unpaid">Unpaid</option>
                                                    <option value="Paid">Paid</option>
                                                </select>
                                            </div>

                                            <div>
                                                <label for="editNote"
                                                    class="block text-sm font-semibold text-gray-700 mb-2">
                                                    Note
                                                </label>
                                                <textarea id="editNote" name="note" rows="3"
                                                    class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                                                    placeholder="Add special instructions or notes..."></textarea>
                                            </div>
                                        </div>

                                        <div id="editOrderError"
                                            class="hidden mt-4 p-3 bg-red-100 text-red-700 rounded-lg"></div>

                                        <div class="flex justify-end gap-3 mt-6">
                                            <button type="button" onclick="closeEditOrderModal()"
                                                class="px-6 py-2 bg-gray-300 text-gray-700 rounded-lg hover:bg-gray-400">
                                                Cancel
                                            </button>
                                            <button type="submit"
                                                class="px-6 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600">
                                                Save Changes
                                            </button>
                                        </div>
                                    </form>
                                </div>
                            </div>

                            <script>
                                const ctx = '${pageContext.request.contextPath}';

                                function filterByStatus(status) {
                                    if (status === '') {
                                        window.location.href = ctx + '/manage-orders';
                                    } else {
                                        window.location.href = ctx + '/manage-orders?action=filter&status=' + status;
                                    }
                                }

                                // Add Order Modal Functions
                                function openAddOrderModal() {
                                    document.getElementById('addOrderModal').classList.add('show');
                                    document.getElementById('addOrderError').classList.add('hidden');
                                    if (document.getElementById('orderItems').children.length === 0) {
                                        addOrderItemRow();
                                    }
                                }

                                function closeAddOrderModal() {
                                    document.getElementById('addOrderModal').classList.remove('show');
                                    document.getElementById('addOrderForm').reset();
                                    document.getElementById('orderItems').innerHTML = '';
                                }

                                function orderItemRowTemplate() {
                                    return `
                <div class="order-item-row grid grid-cols-5 gap-3 p-3 bg-gray-50 rounded-lg">
                    <div class="col-span-2">
                        <label for="pizza-type-select" class="block text-xs font-semibold text-gray-700 mb-1">Pizza Type</label>
                        <select id="pizza-type-select" name="pizzaType" onchange="updatePrice(this)" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500">
                            <option value="Pepperoni" data-price="25.00">Pepperoni ($25.00)</option>
                            <option value="Hawaiian" data-price="28.00">Hawaiian ($28.00)</option>
                            <option value="Margherita" data-price="22.00">Margherita ($22.00)</option>
                            <option value="BBQ Chicken" data-price="30.00">BBQ Chicken ($30.00)</option>
                            <option value="Veggie" data-price="24.00">Veggie ($24.00)</option>
                        </select>
                    </div>
                    <div>
                        <label for="quantity-input" class="block text-xs font-semibold text-gray-700 mb-1">Quantity</label>
                        <input id="quantity-input" name="quantity" type="number" min="1" max="100" value="1" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500" required />
                    </div>
                    <div>
                        <label for="price-input" class="block text-xs font-semibold text-gray-700 mb-1">
                            Price
                            <span class="text-xs font-normal text-gray-500">($5-$9000)</span>
                        </label>
                        <input id="price-input" name="price" type="number" step="0.01" min="5" max="9000" value="25.00" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500" required />
                    </div>
                    <div class="flex items-end">
                        <button type="button" onclick="this.closest('.order-item-row').remove()" class="w-full px-3 py-2 bg-red-500 text-white rounded-lg hover:bg-red-600">
                            Remove
                        </button>
                    </div>
                </div>`;
                                }

                                function updatePrice(selectElement) {
                                    const selectedOption = selectElement.options[selectElement.selectedIndex];
                                    const price = selectedOption.getAttribute('data-price');
                                    const priceInput = selectElement.closest('.order-item-row').querySelector('input[name="price"]');
                                    priceInput.value = price;
                                }

                                function addOrderItemRow() {
                                    document.getElementById('orderItems').insertAdjacentHTML('beforeend', orderItemRowTemplate());
                                }

                                async function submitAddOrderForm(event) {
                                    event.preventDefault();
                                    const form = document.getElementById('addOrderForm');
                                    const errorBox = document.getElementById('addOrderError');

                                    const formData = new URLSearchParams();
                                    formData.append('action', 'add');
                                    formData.append('status', form.status.value);

                                    const rows = document.querySelectorAll('#orderItems .order-item-row');
                                    if (rows.length === 0) {
                                        errorBox.classList.remove('hidden');
                                        errorBox.textContent = 'Please add at least 1 pizza';
                                        return;
                                    }

                                    let totalPrice = 0;
                                    for (const row of rows) {
                                        const pizzaType = row.querySelector('select[name="pizzaType"]').value;
                                        const quantityInput = row.querySelector('input[name="quantity"]');
                                        const quantity = parseInt(quantityInput.value);
                                        const priceInput = row.querySelector('input[name="price"]');
                                        const price = parseFloat(priceInput.value);

                                        // Validate quantity
                                        if (!quantity || quantity < 1 || quantity > 100) {
                                            errorBox.classList.remove('hidden');
                                            errorBox.textContent = 'Quantity must be between 1 and 100';
                                            quantityInput.focus();
                                            return;
                                        }

                                        // Validate price
                                        if (!price || price < 5 || price > 9000) {
                                            errorBox.classList.remove('hidden');
                                            errorBox.textContent = 'Price must be between $5 and $9000';
                                            priceInput.focus();
                                            return;
                                        }

                                        totalPrice += price * quantity;
                                        formData.append('pizzaType', pizzaType);
                                        formData.append('quantity', quantity);
                                        formData.append('price', price);
                                    }

                                    // Validate total price
                                    if (totalPrice < 5 || totalPrice > 9000) {
                                        errorBox.classList.remove('hidden');
                                        errorBox.textContent = 'Total order must be between $5 and $9000';
                                        return;
                                    }

                                    try {
                                        const res = await fetch(ctx + '/manage-orders', {
                                            method: 'POST',
                                            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                                            body: formData.toString()
                                        });

                                        const text = await res.text();
                                        if (!res.ok) {
                                            errorBox.classList.remove('hidden');
                                            errorBox.textContent = text || 'Unable to create order.';
                                            return;
                                        }

                                        closeAddOrderModal();
                                        window.location.href = ctx + '/manage-orders';
                                    } catch (e) {
                                        errorBox.classList.remove('hidden');
                                        errorBox.textContent = 'Connection error: ' + (e && e.message ? e.message : e);
                                    }
                                }

                                // Edit Order Modal Functions
                                function openEditOrderModal(orderId) {
                                    console.log("Opening edit modal for order:", orderId);
                                    const modal = document.getElementById("editOrderModal");
                                    const errorBox = document.getElementById("editOrderError");
                                    errorBox.classList.add("hidden");

                                    console.log("Fetching order data...");
                                    fetch(ctx + '/manage-orders?action=getOrder&id=' + orderId)
                                        .then(res => {
                                            console.log("Response status:", res.status);
                                            return res.json();
                                        })
                                        .then(data => {
                                            console.log("Order data received:", data);
                                            if (!data.success) {
                                                errorBox.classList.remove("hidden");
                                                errorBox.textContent = data.message || "Could not load order data.";
                                                return;
                                            }

                                            const o = data.order;
                                            document.getElementById("editOrderID").value = o.orderID;
                                            document.getElementById("editStatus").value = o.status;
                                            document.getElementById("editPaymentStatus").value = o.paymentStatus || "Unpaid";
                                            document.getElementById("editNote").value = o.note || "";
                                            document.getElementById("editModalTitle").textContent = 'Edit Order #' + o.orderID;

                                            console.log("Opening modal...");
                                            modal.classList.add("show");
                                            console.log("Modal classes:", modal.className);
                                        })
                                        .catch(err => {
                                            console.error("Error fetching order:", err);
                                            errorBox.classList.remove("hidden");
                                            errorBox.textContent = "Error: " + err.message;
                                        });
                                }

                                function closeEditOrderModal() {
                                    document.getElementById("editOrderModal").classList.remove("show");
                                }

                                async function submitEditOrderForm(event) {
                                    event.preventDefault();
                                    const errorBox = document.getElementById("editOrderError");
                                    errorBox.classList.add("hidden");

                                    const form = document.getElementById("editOrderForm");
                                    const formData = new URLSearchParams();
                                    formData.append("action", "update");
                                    formData.append("orderID", form.orderID.value);
                                    formData.append("status", form.status.value);
                                    formData.append("paymentStatus", form.paymentStatus.value);
                                    formData.append("note", form.note.value);

                                    try {
                                        const res = await fetch(ctx + '/manage-orders', {
                                            method: "POST",
                                            headers: { "Content-Type": "application/x-www-form-urlencoded" },
                                            body: formData.toString()
                                        });
                                        const result = await res.json();

                                        if (result.success) {
                                            closeEditOrderModal();
                                            alert("✅ Order updated successfully!");
                                            window.location.reload();
                                        } else {
                                            errorBox.classList.remove("hidden");
                                            errorBox.textContent = result.message || "Failed to update order.";
                                        }
                                    } catch (err) {
                                        errorBox.classList.remove("hidden");
                                        errorBox.textContent = "Network error: " + err.message;
                                    }
                                }

                                // Close modal when clicking outside
                                window.onclick = function (event) {
                                    const addModal = document.getElementById('addOrderModal');
                                    const editModal = document.getElementById('editOrderModal');
                                    if (event.target === addModal) {
                                        closeAddOrderModal();
                                    }
                                    if (event.target === editModal) {
                                        closeEditOrderModal();
                                    }
                                }
                            </script>
                </body>

                </html>