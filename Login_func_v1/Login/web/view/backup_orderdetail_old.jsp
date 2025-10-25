<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="models.Order" %>
<%@ page import="models.OrderDetail" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Order Details - PizzaConnect</title>
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
            max-width: 1000px;
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
        
        .nav .back {
            background: #3498db;
            color: white;
            padding: 8px 20px;
            text-decoration: none;
            border-radius: 5px;
            transition: background 0.3s;
        }
        
        .nav .back:hover {
            background: #2980b9;
        }
        
        .content {
            padding: 30px;
        }
        
        .order-info {
            background: #f8f9fa;
            padding: 25px;
            border-radius: 10px;
            margin-bottom: 30px;
        }
        
        .order-info h2 {
            color: #2c3e50;
            margin-bottom: 20px;
            font-size: 1.5em;
        }
        
        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
        }
        
        .info-item {
            display: flex;
            flex-direction: column;
        }
        
        .info-label {
            font-weight: 600;
            color: #7f8c8d;
            font-size: 0.9em;
            margin-bottom: 5px;
        }
        
        .info-value {
            font-size: 1.1em;
            color: #2c3e50;
        }
        
        .status-badge {
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 0.9em;
            font-weight: 600;
            text-transform: uppercase;
            display: inline-block;
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
            padding: 6px 12px;
            border-radius: 15px;
            font-size: 0.85em;
            font-weight: 600;
            display: inline-block;
        }
        
        .payment-paid {
            background: #d4edda;
            color: #155724;
        }
        
        .payment-unpaid {
            background: #f8d7da;
            color: #721c24;
        }
        
        .order-details {
            background: white;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }
        
        .details-header {
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
        
        .total-row {
            background: #e8f5e8;
            font-weight: 600;
            font-size: 1.1em;
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
        
        .notes {
            background: #fff3cd;
            border: 1px solid #ffeaa7;
            padding: 15px;
            border-radius: 5px;
            margin-top: 20px;
        }
        
        .notes h4 {
            color: #856404;
            margin-bottom: 10px;
        }
        
        .notes p {
            color: #856404;
            margin: 0;
        }
    </style>
</head>
<body>
    <%
        Order order = (Order) request.getAttribute("order");
        List<Orderdetail> orderDetails = (List<Orderdetail>) request.getAttribute("orderDetails");
    %>
    
    <div class="container">
        <div class="header">
            <h1>🍕 Order Details</h1>
            <p>Order #<%= order != null ? order.getOrderId() : "N/A" %></p>
        </div>
        
        <div class="nav">
            <a href="manage-orders" class="back">← Back to Orders</a>
        </div>
        
        <div class="content">
            <% if (order != null) { %>
                <div class="order-info">
                    <h2>Order Information</h2>
                    <div class="info-grid">
                        <div class="info-item">
                            <span class="info-label">Order ID</span>
                            <span class="info-value">#<%= order.getOrderId() %></span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">Table Number</span>
                            <span class="info-value"><%= order.getTableNumber() != null ? order.getTableNumber() : "N/A" %></span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">Customer Name</span>
                            <span class="info-value"><%= order.getCustomerName() != null ? order.getCustomerName() : "Walk-in Customer" %></span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">Customer Phone</span>
                            <span class="info-value"><%= order.getCustomerPhone() != null ? order.getCustomerPhone() : "N/A" %></span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">Order Date</span>
                            <span class="info-value">
                                <%= order.getOrderDate() != null ? new java.text.SimpleDateFormat("MMM dd, yyyy 'at' HH:mm").format(order.getOrderDate()) : "N/A" %>
                            </span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">Status</span>
                            <span class="info-value">
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
                            </span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">Payment Status</span>
                            <span class="info-value">
                                <% 
                                    String paymentClass = order.getPaymentStatus() != null && order.getPaymentStatus().equals("Paid") ? "payment-paid" : "payment-unpaid";
                                %>
                                <span class="payment-badge <%= paymentClass %>">
                                    <%= order.getPaymentStatus() != null ? order.getPaymentStatus() : "Unpaid" %>
                                </span>
                            </span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">Total Amount</span>
                            <span class="info-value" style="font-size: 1.3em; font-weight: 600; color: #27ae60;">
                                $<%= String.format("%.2f", order.getTotalMoney()) %>
                            </span>
                        </div>
                    </div>
                    
                    <% if (order.getNotes() != null && !order.getNotes().trim().isEmpty()) { %>
                        <div class="notes">
                            <h4>📝 Special Notes</h4>
                            <p><%= order.getNotes() %></p>
                        </div>
                    <% } %>
                </div>
                
                <div class="order-details">
                    <div class="details-header">
                        🍕 Order Items
                    </div>
                    
                    <% if (orderDetails == null || orderDetails.isEmpty()) { %>
                        <div class="empty-state">
                            <i>🍕</i>
                            <h3>No Items Found</h3>
                            <p>This order has no items.</p>
                        </div>
                    <% } else { %>
                        <table>
                            <thead>
                                <tr>
                                    <th>Product ID</th>
                                    <th>Quantity</th>
                                    <th>Unit Price</th>
                                    <th>Total Price</th>
                                    <th>Special Instructions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% 
                                    double grandTotal = 0;
                                    for (Orderdetail detail : orderDetails) {
                                        grandTotal += detail.getTotalPrice();
                                %>
                                    <tr>
                                        <td><strong>#<%= detail.getProductId() %></strong></td>
                                        <td><%= detail.getQuantity() %></td>
                                        <td>$<%= String.format("%.2f", detail.getUnitPrice()) %></td>
                                        <td><strong>$<%= String.format("%.2f", detail.getTotalPrice()) %></strong></td>
                                        <td>
                                            <% if (detail.getSpecialInstructions() != null && !detail.getSpecialInstructions().trim().isEmpty()) { %>
                                                <em style="color: #7f8c8d;"><%= detail.getSpecialInstructions() %></em>
                                            <% } else { %>
                                                <span style="color: #bdc3c7;">No special instructions</span>
                                            <% } %>
                                        </td>
                                    </tr>
                                <% } %>
                                <tr class="total-row">
                                    <td colspan="3"><strong>Grand Total:</strong></td>
                                    <td colspan="2"><strong>$<%= String.format("%.2f", grandTotal) %></strong></td>
                                </tr>
                            </tbody>
                        </table>
                    <% } %>
                </div>
            <% } else { %>
                <div class="empty-state">
                    <i>❌</i>
                    <h3>Order Not Found</h3>
                    <p>The requested order could not be found.</p>
                </div>
            <% } %>
        </div>
    </div>
</body>
</html>

