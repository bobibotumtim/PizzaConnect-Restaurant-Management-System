<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<jsp:include page="/view/header.jsp"/>
<jsp:include page="/view/sidebar.jsp"/>

<div class="p-6 sm:ml-64 bg-gray-100 min-h-screen">
    <div class="p-6 bg-white rounded-2xl shadow-md">
        <h2 class="text-2xl font-bold mb-4">Chi tiết đơn hàng #${order.orderID}</h2>

        <div class="mb-6">
            <p><strong>Khách hàng:</strong> ${order.customerID}</p>
            <p><strong>Nhân viên:</strong> ${order.employeeID}</p>
            <p><strong>Bàn:</strong> ${order.tableID}</p>
            <p><strong>Ngày đặt:</strong> ${order.orderDate}</p>
            <p><strong>Trạng thái:</strong> ${order.status}</p>
            <p><strong>Thanh toán:</strong> ${order.paymentStatus}</p>
            <p><strong>Tổng tiền:</strong> ${order.totalPrice}</p>
            <p><strong>Ghi chú:</strong> ${order.note}</p>
        </div>

        <h3 class="text-xl font-semibold mb-3">Danh sách món</h3>
        <table class="min-w-full border border-gray-300 text-sm text-left">
            <thead class="bg-gray-200">
                <tr>
                    <th class="p-3">OrderDetailID</th>
                    <th class="p-3">ProductID</th>
                    <th class="p-3">Quantity</th>
                    <th class="p-3">TotalPrice</th>
                    <th class="p-3">Ghi chú món</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="d" items="${details}">
                    <tr class="border-b hover:bg-gray-50">
                        <td class="p-3">${d.orderDetailID}</td>
                        <td class="p-3">${d.productID}</td>
                        <td class="p-3">${d.quantity}</td>
                        <td class="p-3">${d.totalPrice}</td>
                        <td class="p-3">${d.specialInstructions}</td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>

        <div class="mt-4">
            <a href="OrderListServlet" class="text-blue-600 hover:underline">← Quay lại danh sách</a>
        </div>
    </div>
</div>
