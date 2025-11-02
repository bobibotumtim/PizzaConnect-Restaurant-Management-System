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

                                                                                                <%
                                                                                                // 2. PROCESS BUTTON - Only for Pending
                                                                                                if (status == 0) {
                                                                                                %>
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

                                                                                                <%
                                                                                                // 3. COMPLETE BUTTON - Only for Processing
                                                                                                if (status == 1) {
                                                                                                %>
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

                                                                                                                <%
                                                                                                                // 4. PAID BUTTON - Show for Unpaid orders except Cancelled
                                                                                                                if (!isPaid && status != 3) {
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
                                                                                                                // 5. CANCEL BUTTON - Show for Pending and Processing only
                                                                                                                if (status != 2 && status != 3) {
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

                                                                                                                                <%
                                                                                                                                // 6. DELETE BUTTON - Show for Cancelled OR (Pending + Unpaid)
                                                                                                                                if (status == 3 || (status == 0 && !isPaid)) {
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

                            <!-- View Order Modal -->
                            <div id="editOrderModal" class="modal">
                                <div class="bg-white rounded-xl shadow-2xl max-w-lg w-full m-4 fade-in">
                                    <div
                                        class="bg-gradient-to-r from-gray-600 to-gray-700 text-white px-6 py-4 flex items-center justify-between rounded-t-xl">
                                        <h3 class="text-xl font-bold" id="editModalTitle">Order Details</h3>
                                        <button onclick="closeEditOrderModal()"
                                            class="hover:bg-gray-800 rounded-full p-1">
                                            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                                    d="M6 18L18 6M6 6l12 12" />
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

                                // View Order Modal Functions
                                function openViewOrderModal(orderId) {
                                    const modal = document.getElementById("editOrderModal");
                                    
                                    fetch(ctx + '/manage-orders?action=getOrder&id=' + orderId)
                                        .then(res => res.json())
                                        .then(data => {
                                            if (!data.success) {
                                                alert("Could not load order data.");
                                                return;
                                            }

                                            const o = data.order;
                                            const statusText = ['Pending', 'Processing', 'Completed', 'Cancelled'][o.status];
                                            const statusColor = ['orange', 'blue', 'green', 'red'][o.status];
                                            
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

                                // Price validation function
                                function validatePrice(input) {
                                    const value = parseFloat(input.value);
                                    const min = 10000;
                                    const max = 99000000;
                                    
                                    if (isNaN(value) || value < min || value > max) {
                                        input.setCustomValidity(`Giá phải từ ${min.toLocaleString('vi-VN')}đ đến ${max.toLocaleString('vi-VN')}đ`);
                                        input.reportValidity();
                                        return false;
                                    } else {
                                        input.setCustomValidity('');
                                        return true;
                                    }
                                }

                                // Add validation to all price inputs
                                document.addEventListener('DOMContentLoaded', function() {
                                    const priceInputs = document.querySelectorAll('input[name="totalPrice"], input[type="number"][placeholder*="price"], input[type="number"][placeholder*="Price"]');
                                    priceInputs.forEach(input => {
                                        input.setAttribute('min', '10000');
                                        input.setAttribute('max', '99000000');
                                        input.setAttribute('step', '1000');
                                        input.addEventListener('blur', function() {
                                            validatePrice(this);
                                        });
                                        input.addEventListener('input', function() {
                                            this.setCustomValidity('');
                                        });
                                    });
                                });

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