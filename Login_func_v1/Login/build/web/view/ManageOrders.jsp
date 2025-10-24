<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="models.Order" %>
<%@ page import="models.User" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Orders - PizzaConnect</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        
        .container {
            max-width: 1400px;
            margin: 0 auto;
            background: white;
            border-radius: 15px;
            box-shadow: 0 15px 35px rgba(0,0,0,0.1);
            overflow: hidden;
        }
        
        .header {
            background: linear-gradient(135deg, #ff6b6b, #ee5a24);
            color: white;
            padding: 30px;
            text-align: center;
        }
        
        .header h1 {
            font-size: 2.5em;
            margin-bottom: 10px;
        }
        
        .nav {
            background: #2c3e50;
            padding: 15px 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .nav .welcome {
            color: white;
            font-weight: 500;
        }
        
        .nav .logout {
            background: #e74c3c;
            color: white;
            padding: 8px 20px;
            text-decoration: none;
            border-radius: 5px;
            transition: background 0.3s;
        }
        
        .nav .logout:hover {
            background: #c0392b;
        }
        
        .content {
            padding: 30px;
        }
        
        .alert {
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 5px;
            font-weight: 500;
        }
        
        .alert.success {
            background: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        
        .alert.error {
            background: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        
        .filters {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 10px;
            margin-bottom: 30px;
            display: flex;
            gap: 15px;
            align-items: center;
            flex-wrap: wrap;
        }
        
        .filter-group {
            display: flex;
            flex-direction: column;
            gap: 5px;
        }
        
        .filter-group label {
            font-weight: 600;
            color: #2c3e50;
        }
        
        .filter-group select, .filter-group input {
            padding: 8px 12px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 14px;
        }
        
        .btn {
            padding: 8px 16px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            font-size: 14px;
            transition: all 0.3s;
            margin: 2px;
        }
        
        .btn-primary {
            background: #3498db;
            color: white;
        }
        
        .btn-primary:hover {
            background: #2980b9;
        }
        
        .btn-success {
            background: #27ae60;
            color: white;
        }
        
        .btn-success:hover {
            background: #229954;
        }
        
        .btn-warning {
            background: #f39c12;
            color: white;
        }
        
        .btn-warning:hover {
            background: #e67e22;
        }
        
        .btn-danger {
            background: #e74c3c;
            color: white;
        }
        
        .btn-danger:hover {
            background: #c0392b;
        }
        
        .btn-info {
            background: #17a2b8;
            color: white;
        }
        
        .btn-info:hover {
            background: #138496;
        }
        
        .table-container {
            background: white;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }
        
        .table-header {
            background: #34495e;
            color: white;
            padding: 20px;
            font-size: 1.2em;
            font-weight: 600;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
        }
        
        th, td {
            padding: 15px;
            text-align: left;
            border-bottom: 1px solid #ecf0f1;
        }
        
        th {
            background: #f8f9fa;
            font-weight: 600;
            color: #2c3e50;
        }
        
        tr:hover {
            background: #f8f9fa;
        }
        
        .status-badge {
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 0.85em;
            font-weight: 600;
            text-transform: uppercase;
        }
        
        .status-pending {
            background: #f39c12;
            color: white;
        }
        
        .status-processing {
            background: #3498db;
            color: white;
        }
        
        .status-completed {
            background: #27ae60;
            color: white;
        }
        
        .status-cancelled {
            background: #e74c3c;
            color: white;
        }
        
        .payment-badge {
            padding: 3px 8px;
            border-radius: 15px;
            font-size: 0.8em;
            font-weight: 600;
        }
        
        .payment-paid {
            background: #d4edda;
            color: #155724;
        }
        
        .payment-unpaid {
            background: #f8d7da;
            color: #721c24;
        }
        
        .empty-state {
            text-align: center;
            padding: 50px;
            color: #7f8c8d;
        }
        
        .empty-state i {
            font-size: 4em;
            margin-bottom: 20px;
            display: block;
        }
        
        .actions {
            display: flex;
            gap: 5px;
            flex-wrap: wrap;
        }
    </style>
</head>
<body>
    <%
        User currentUser = (User) request.getAttribute("currentUser");
        List<Order> orders = (List<Order>) request.getAttribute("orders");
        String message = (String) request.getAttribute("message");
        String error = (String) request.getAttribute("error");
        Integer selectedStatus = (Integer) request.getAttribute("selectedStatus");
    %>
    
    <div class="container">
        <div class="header">
            <h1>🍕 Manage Orders</h1>
            <p>PizzaConnect Restaurant Management System</p>
        </div>
        
        <div class="nav">
            <div class="welcome">
                Welcome, <strong><%= currentUser != null ? currentUser.getName() : "User" %></strong>
                (<%= currentUser != null && currentUser.getRole() == 1 ? "Admin" : "Employee" %>)
            </div>
            <a href="Login?action=logout" class="logout">Logout</a>
        </div>
        
        <div class="content">
            <% if (message != null && !message.isEmpty()) { %>
                <div class="alert success"><%= message %></div>
            <% } %>
            
            <% if (error != null && !error.isEmpty()) { %>
                <div class="alert error"><%= error %></div>
            <% } %>
            
            <div class="filters">
                <div class="filter-group">
                    <label>Filter by Status:</label>
                    <select onchange="filterByStatus(this.value)">
                        <option value="">All Orders</option>
                        <option value="0" <%= selectedStatus != null && selectedStatus == 0 ? "selected" : "" %>>Pending</option>
                        <option value="1" <%= selectedStatus != null && selectedStatus == 1 ? "selected" : "" %>>Processing</option>
                        <option value="2" <%= selectedStatus != null && selectedStatus == 2 ? "selected" : "" %>>Completed</option>
                        <option value="3" <%= selectedStatus != null && selectedStatus == 3 ? "selected" : "" %>>Cancelled</option>
                    </select>
                </div>
                
                <div class="filter-group">
                    <label>Quick Actions:</label>
                    <a href="manage-orders" class="btn btn-primary">Refresh</a>
                    <a href="add-order" class="btn btn-success">New Order</a>
                    <a href="dashboard" class="btn btn-info">Dashboard</a>
                </div>
            </div>
            
            <div class="table-container">
                <div class="table-header">
                    📋 Order Management
                </div>
                
                <% if (orders == null || orders.isEmpty()) { %>
                    <div class="empty-state">
                        <i>📦</i>
                        <h3>No Orders Found</h3>
                        <p>There are no orders in the system yet.</p>
                    </div>
                <% } else { %>
                    <table>
                        <thead>
                            <tr>
                                <th>Order ID</th>
                                <th>Table</th>
                                <th>Customer</th>
                                <th>Date</th>
                                <th>Total</th>
                                <th>Status</th>
                                <th>Payment</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Order order : orders) { %>
                                <tr>
                                    <td><strong>#<%= order.getOrderId() %></strong></td>
                                    <td><%= order.getTableNumber() != null ? order.getTableNumber() : "N/A" %></td>
                                    <td>
                                        <div><strong><%= order.getCustomerName() != null ? order.getCustomerName() : "Walk-in" %></strong></div>
                                        <% if (order.getCustomerPhone() != null) { %>
                                            <div style="font-size: 0.9em; color: #666;"><%= order.getCustomerPhone() %></div>
                                        <% } %>
                                    </td>
                                    <td><%= order.getOrderDate() != null ? new java.text.SimpleDateFormat("MMM dd, yyyy HH:mm").format(order.getOrderDate()) : "N/A" %></td>
                                    <td><strong>$<%= String.format("%.2f", order.getTotalMoney()) %></strong></td>
                                    <td>
                                        <% 
                                            String statusClass = "";
                                            switch(order.getStatus()) {
                                                case 0: statusClass = "status-pending"; break;
                                                case 1: statusClass = "status-processing"; break;
                                                case 2: statusClass = "status-completed"; break;
                                                case 3: statusClass = "status-cancelled"; break;
                                            }
                                        %>
                                        <span class="status-badge <%= statusClass %>"><%= order.getStatusText() %></span>
                                    </td>
                                    <td>
                                        <% 
                                            String paymentClass = order.getPaymentStatus() != null && order.getPaymentStatus().equals("Paid") ? "payment-paid" : "payment-unpaid";
                                        %>
                                        <span class="payment-badge <%= paymentClass %>">
                                            <%= order.getPaymentStatus() != null ? order.getPaymentStatus() : "Unpaid" %>
                                        </span>
                                    </td>
                                    <td>
                                        <div class="actions">
                                            <a href="manage-orders?action=view&orderId=<%= order.getOrderId() %>" class="btn btn-info">View</a>
                                            
                                            <% if (order.getStatus() == 0) { %>
                                                <form style="display: inline;" method="post" onsubmit="return confirm('Mark this order as Processing?')">
                                                    <input type="hidden" name="action" value="updateStatus">
                                                    <input type="hidden" name="orderId" value="<%= order.getOrderId() %>">
                                                    <input type="hidden" name="status" value="1">
                                                    <button type="submit" class="btn btn-warning">Process</button>
                                                </form>
                                            <% } %>
                                            
                                            <% if (order.getStatus() == 1) { %>
                                                <form style="display: inline;" method="post" onsubmit="return confirm('Mark this order as Completed?')">
                                                    <input type="hidden" name="action" value="updateStatus">
                                                    <input type="hidden" name="orderId" value="<%= order.getOrderId() %>">
                                                    <input type="hidden" name="status" value="2">
                                                    <button type="submit" class="btn btn-success">Complete</button>
                                                </form>
                                            <% } %>
                                            
                                            <% if (order.getPaymentStatus() == null || !order.getPaymentStatus().equals("Paid")) { %>
                                                <form style="display: inline;" method="post" onsubmit="return confirm('Mark this order as Paid?')">
                                                    <input type="hidden" name="action" value="updatePayment">
                                                    <input type="hidden" name="orderId" value="<%= order.getOrderId() %>">
                                                    <input type="hidden" name="paymentStatus" value="Paid">
                                                    <button type="submit" class="btn btn-success">Mark Paid</button>
                                                </form>
                                            <% } %>
                                            
                                            <% if (order.getStatus() != 2 && order.getStatus() != 3) { %>
                                                <form style="display: inline;" method="post" onsubmit="return confirm('Cancel this order?')">
                                                    <input type="hidden" name="action" value="updateStatus">
                                                    <input type="hidden" name="orderId" value="<%= order.getOrderId() %>">
                                                    <input type="hidden" name="status" value="3">
                                                    <button type="submit" class="btn btn-danger">Cancel</button>
                                                </form>
                                            <% } %>
                                            
                                            <% if (order.getStatus() == 0 || order.getStatus() == 3) { %>
                                                <form style="display: inline;" method="post" onsubmit="return confirm('Delete this order permanently?')">
                                                    <input type="hidden" name="action" value="delete">
                                                    <input type="hidden" name="orderId" value="<%= order.getOrderId() %>">
                                                    <button type="submit" class="btn btn-danger">Delete</button>
                                                </form>
                                            <% } %>
                                        </div>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                <% } %>
            </div>
        </div>
    </div>
    
    <script>
        function filterByStatus(status) {
            if (status === '') {
                window.location.href = 'manage-orders';
            } else {
                window.location.href = 'manage-orders?action=filter&status=' + status;
            }
        }
    </script>
</body>
</html>
