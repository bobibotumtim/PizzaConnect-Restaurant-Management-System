<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="models.Order" %>
<html>
<head>
    <title>Thêm/Sửa Đơn Hàng</title>
    <style>
        body { font-family: sans-serif; background:#fff7f3; padding:30px; }
        form { background:white; padding:20px; border-radius:8px; width:450px; margin:auto; box-shadow:0 2px 6px #ccc; }
        input, textarea, select { width:100%; padding:8px; margin:6px 0; border:1px solid #ddd; border-radius:6px; box-sizing:border-box; }
        label { font-weight:bold; color:#333; display:block; margin-top:10px; }
        button { background:#ff5722; color:white; padding:12px 16px; border:none; border-radius:6px; cursor:pointer; width:100%; margin-top:15px; font-size:16px; }
        button:hover { background:#e64a19; }
        a { text-decoration:none; display:block; text-align:center; margin-top:15px; color:#555; padding:8px; }
        a:hover { color:#ff5722; }
        .form-group { margin-bottom:15px; }
    </style>
</head>
<body>
<%
    Order o = (Order) request.getAttribute("order");
    boolean editing = (o != null);
%>
<h2 style="text-align:center;"><%= editing ? "✏️ Sửa đơn hàng" : "➕ Thêm đơn hàng" %></h2>

<form method="post" action="OrderController">
    <% if (editing) { %>
        <input type="hidden" name="orderID" value="<%= o.getOrderID() %>"/>
        <input type="hidden" name="action" value="updateFromModal"/>
    <% } else { %>
        <input type="hidden" name="action" value="addFromModal"/>
    <% } %>

    <label>Customer ID:</label>
    <input type="number" name="customerID" value="<%= editing ? o.getCustomerID() : "" %>" required/>

    <label>Employee ID:</label>
    <input type="number" name="employeeID" value="<%= editing ? o.getEmployeeID() : "" %>" required/>

    <label>Table ID:</label>
    <input type="number" name="tableID" value="<%= editing ? o.getTableID() : "" %>" required/>

    <% if (editing) { %>
        <label>Order Date:</label>
        <input type="datetime-local" name="orderDate" value="<%= o.getOrderDate() != null ? o.getOrderDate().toString().substring(0, 16) : "" %>"/>

        <label>Status:</label>
        <select name="status">
            <option value="0" <%= o.getStatus() == 0 ? "selected" : "" %>>Pending</option>
            <option value="1" <%= o.getStatus() == 1 ? "selected" : "" %>>Processing</option>
            <option value="2" <%= o.getStatus() == 2 ? "selected" : "" %>>Completed</option>
            <option value="3" <%= o.getStatus() == 3 ? "selected" : "" %>>Cancelled</option>
        </select>

        <label>Payment Status:</label>
        <select name="paymentStatus">
            <option value="Unpaid" <%= "Unpaid".equals(o.getPaymentStatus()) ? "selected" : "" %>>Unpaid</option>
            <option value="Paid" <%= "Paid".equals(o.getPaymentStatus()) ? "selected" : "" %>>Paid</option>
            <option value="Refunded" <%= "Refunded".equals(o.getPaymentStatus()) ? "selected" : "" %>>Refunded</option>
        </select>

        <label>Total Price:</label>
        <input type="number" step="0.01" name="totalPrice" value="<%= o.getTotalPrice() %>"/>
    <% } %>

    <label>Ghi chú:</label>
    <textarea name="note"><%= editing && o.getNote() != null ? o.getNote() : "" %></textarea>

    <button type="submit">💾 <%= editing ? "Cập nhật" : "Thêm mới" %></button>
</form>

<a href="OrderController?action=list">⬅️ Quay lại</a>
</body>
</html>
