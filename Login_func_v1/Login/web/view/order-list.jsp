<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.*, models.Order" %>
<html>
<head>
    <title>Pizza Order Manager</title>
    <style>
        body { font-family: sans-serif; background: #fff7f3; }
        .header { display:flex; justify-content:space-between; align-items:center; padding:20px; }
        .btn { background:#ff5722; color:white; padding:8px 16px; text-decoration:none; border-radius:6px; }
        table { width:100%; border-collapse:collapse; background:white; border-radius:8px; overflow:hidden; }
        th, td { padding:12px; text-align:center; border-bottom:1px solid #f1f1f1; }
    </style>
</head>
<body>
    <div class="header">
        <h2>🍕 Pizza Order Manager</h2>
        <a href="OrderController?action=new" class="btn">+ Thêm đơn hàng</a>
    </div>

    <table>
        <tr>
            <th>ID</th><th>Khách hàng</th><th>Loại pizza</th><th>Số lượng</th>
            <th>Giá (VND)</th><th>Tổng tiền</th><th>Trạng thái</th><th>Thao tác</th>
        </tr>
        <%
            List<Order> list = (List<Order>) request.getAttribute("orders");
            if (list == null || list.isEmpty()) {
        %>
            <tr><td colspan="8">Chưa có đơn hàng nào</td></tr>
        <% } else {
            for (Order o : list) {
        %>
            <tr>
                <td><%= o.getId() %></td>
                <td><%= o.getCustomerName() %></td>
                <td><%= o.getPizzaType() %></td>
                <td><%= o.getQuantity() %></td>
                <td><%= o.getPrice() %></td>
                <td><%= o.getQuantity() * o.getPrice() %></td>
                <td><%= o.getStatus() %></td>
                <td>
                    <a href="OrderController?action=edit&id=<%= o.getId() %>">Sửa</a> |
                    <a href="OrderController?action=delete&id=<%= o.getId() %>"
                       onclick="return confirm('Xoá đơn hàng này?')">Xoá</a>
                </td>
            </tr>
        <% } } %>
    </table>
</body>
</html>
