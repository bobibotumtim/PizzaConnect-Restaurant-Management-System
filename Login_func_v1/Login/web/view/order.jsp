<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.*, models.Order" %>
<!DOCTYPE html>
<html>
<head>
    <title>Order List</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/tailwind.css">
</head>
<body class="flex bg-gray-100">
    <%@ include file="/view/sidebar.jsp" %>

    <div class="flex-1 p-8">
        <%@ include file="/view/header.jsp" %>

        <h1 class="text-2xl font-bold mb-4">Order List</h1>

        <div class="bg-white shadow-md rounded-2xl p-4">
            <table class="min-w-full text-center border-collapse">
                <thead>
                    <tr class="bg-gray-200">
                        <th class="py-2 px-4">Order ID</th>
                        <th class="py-2 px-4">Customer ID</th>
                        <th class="py-2 px-4">Employee ID</th>
                        <th class="py-2 px-4">Table ID</th>
                        <th class="py-2 px-4">Order Date</th>
                        <th class="py-2 px-4">Status</th>
                        <th class="py-2 px-4">Payment Status</th>
                        <th class="py-2 px-4">Total Price</th>
                        <th class="py-2 px-4">Note</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        List<Order> orderList = (List<Order>) request.getAttribute("orderList");
                        if (orderList != null && !orderList.isEmpty()) {
                            for (Order order : orderList) {
                    %>
                        <tr class="border-t">
                            <td class="py-2 px-4"><%= order.getOrderID() %></td>
                            <td class="py-2 px-4"><%= order.getCustomerID() %></td>
                            <td class="py-2 px-4"><%= order.getEmployeeID() %></td>
                            <td class="py-2 px-4"><%= order.getTableID() %></td>
                            <td class="py-2 px-4"><%= order.getOrderDate() %></td>
                            <td class="py-2 px-4"><%= order.getStatus() %></td>
                            <td class="py-2 px-4"><%= order.getPaymentStatus() %></td>
                            <td class="py-2 px-4"><%= order.getTotalPrice() %></td>
                            <td class="py-2 px-4"><%= order.getNote() %></td>
                        </tr>
                    <%
                            }
                        } else {
                    %>
                        <tr><td colspan="9" class="py-4 text-gray-500">No orders found.</td></tr>
                    <%
                        }
                    %>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>
