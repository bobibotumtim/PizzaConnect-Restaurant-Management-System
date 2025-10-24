<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="models.Order" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Orders - PizzaConnect</title>
    <style>
        body {
            font-family: 'Segoe UI', sans-serif;
            background: linear-gradient(135deg, #74ebd5 0%, #9face6 100%);
            min-height: 100vh;
            margin: 0;
            padding: 30px;
        }

        .container {
            max-width: 1100px;
            margin: 0 auto;
            background: white;
            border-radius: 15px;
            box-shadow: 0 10px 25px rgba(0,0,0,0.1);
            overflow: hidden;
        }

        .header {
            background: linear-gradient(135deg, #ff6b6b, #ee5a24);
            color: white;
            padding: 25px;
            text-align: center;
        }

        h1 {
            margin: 0;
        }

        table {
            width: 100%;
            border-collapse: collapse;
        }

        th, td {
            padding: 15px;
            border-bottom: 1px solid #eee;
            text-align: center;
        }

        th {
            background: #f8f9fa;
            font-weight: 600;
            color: #2c3e50;
        }

        tr:hover {
            background: #f8f9fa;
        }

        .btn {
            background: #3498db;
            color: white;
            text-decoration: none;
            padding: 6px 14px;
            border-radius: 6px;
            transition: background 0.3s;
        }

        .btn:hover {
            background: #2980b9;
        }

        .empty {
            text-align: center;
            padding: 50px;
            color: #7f8c8d;
        }
    </style>
</head>
<body>
<div class="container">
    <div class="header">
        <h1>🍕 Orders Management</h1>
    </div>

    <%
        List<Order> orders = (List<Order>) request.getAttribute("orders");
        if (orders == null || orders.isEmpty()) {
    %>
        <div class="empty">
            <h3>No orders found</h3>
            <p>There are currently no orders in the system.</p>
        </div>
    <%
        } else {
    %>
        <table>
            <tr>
                <th>ID</th>
                <th>Customer</th>
                <th>Table</th>
                <th>Status</th>
                <th>Total</th>
                <th>Order Date</th>
                <th>Actions</th>
            </tr>
            <%
                for (Order o : orders) {
                    String statusText = o.getStatusText() != null ? o.getStatusText() : "N/A";
                    String customerName = o.getCustomerName() != null ? o.getCustomerName() : "Walk-in";
            %>
            <tr>
                <td>#<%= o.getOrderId() %></td>
                <td><%= customerName %></td>
                <td><%= o.getTableNumber() != null ? o.getTableNumber() : "N/A" %></td>
                <td><%= statusText %></td>
                <td>$<%= String.format("%.2f", o.getTotalMoney()) %></td>
                <td><%= o.getOrderDate() %></td>
                <td>
                    <a class="btn" href="OrderController?action=detail&id=<%= o.getOrderId() %>">View Details</a>
                </td>
            </tr>
            <% } %>
        </table>
    <% } %>
</div>
</body>
</html>
