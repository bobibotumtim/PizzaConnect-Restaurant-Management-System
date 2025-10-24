<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="models.Order" %>
<html>
<head>
    <title>Thêm/Sửa Đơn Hàng</title>
    <style>
        body { font-family: sans-serif; background:#fff7f3; padding:30px; }
        form { background:white; padding:20px; border-radius:8px; width:400px; margin:auto; box-shadow:0 2px 6px #ccc; }
        input, textarea { width:100%; padding:8px; margin:6px 0; border:1px solid #ddd; border-radius:6px; }
        button { background:#ff5722; color:white; padding:10px 16px; border:none; border-radius:6px; cursor:pointer; width:100%; }
        a { text-decoration:none; display:block; text-align:center; margin-top:10px; color:#555; }
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
    <% } %>

    <label>Customer ID:</label>
    <input type="text" name="customerID" value="<%= editing ? o.getCustomerID() : "" %>" required/>

    <label>Employee ID:</label>
    <input type="text" name="employeeID" value="<%= editing ? o.getEmployeeID() : "" %>" required/>

    <label>Table ID:</label>
    <input type="text" name="tableID" value="<%= editing ? o.getTableID() : "" %>" required/>

    <label>Ghi chú:</label>
    <textarea name="note"><%= editing ? o.getNote() : "" %></textarea>

    <button type="submit">💾 Lưu</button>
</form>

<a href="OrderController?action=list">⬅️ Quay lại</a>
</body>
</html>
