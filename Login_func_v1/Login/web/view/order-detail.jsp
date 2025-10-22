<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.*,models.OrderDetail" %>
<html>
<head>
  <title>Chi tiết đơn hàng</title>
  <style>
    table { width:100%; border-collapse:collapse; background:white; }
    th,td { padding:10px; border-bottom:1px solid #eee; text-align:center; }
  </style>
</head>
<body>
<h2>Chi tiết đơn hàng</h2>
<table>
  <tr><th>ID</th><th>Product</th><th>Số lượng</th><th>Giá</th><th>Ghi chú</th></tr>
  <%
    List<OrderDetail> details = (List<OrderDetail>) request.getAttribute("details");
    for (OrderDetail d : details) {
  %>
  <tr>
    <td><%=d.getOrderDetailID()%></td>
    <td><%=d.getProductID()%></td>
    <td><%=d.getQuantity()%></td>
    <td><%=d.getTotalPrice()%></td>
    <td><%=d.getSpecialInstructions()%></td>
  </tr>
  <% } %>
</table>
</body>
</html>