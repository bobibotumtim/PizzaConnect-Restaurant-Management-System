<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Apply Discount</title>
    <style>
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>
    <h2>Available Discounts</h2>
    <c:if test="${not empty message}">
        <p style="color: ${message.contains('success') ? 'green' : 'red'}">${message}</p>
    </c:if>
    <form action="applyDiscount" method="post">
        <table>
            <tr>
                <th>Description</th>
                <th>Type</th>
                <th>Value</th>
                <th>Action</th>
            </tr>
            <c:forEach var="discount" items="${discounts}">
                <tr>
                    <td>${discount.description}</td>
                    <td>${discount.discountType}</td>
                    <td>${discount.value}</td>
                    <td>
                        <input type="hidden" name="orderId" value="${param.orderId}">
                        <input type="hidden" name="discountId" value="${discount.discountId}">
                        <input type="hidden" name="totalPrice" value="${param.totalPrice}">
                        <c:if test="${discount.discountType == 'Loyalty'}">
                            <input type="number" name="pointsUsed" min="1" max="20" placeholder="Points to use" required>
                        </c:if>
                        <input type="submit" value="Apply">
                    </td>
                </tr>
            </c:forEach>
        </table>
    </form>
</body>
</html>