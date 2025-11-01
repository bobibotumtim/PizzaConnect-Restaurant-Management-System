<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%-- Lấy 2 attribute đã set từ ViewProductSizesServlet --%>
<c:set var="product" value="${requestScope.product}" />
<c:set var="availabilityMap" value="${requestScope.availabilityMap}" />

<h2 class="text-xl font-bold mb-4">Sizes for: ${product.productName}</h2>

<button type="button" class="addSizeBtn bg-green-500 text-white px-4 py-2 rounded mb-4"
        data-product-id="${product.productId}">
    + Add New Size
</button>

<table class="min-w-full border">
    <thead class="bg-gray-100">
        <tr>
            <th class="px-4 py-2 text-left">Size Code</th>
            <th class="px-4 py-2 text-left">Price</th>
            <th class="px-4 py-2 text-left">Available to Make</th>
            <th class="px-4 py-2 text-left">Actions</th>
        </tr>
    </thead>
    <tbody class="divide-y">
        <c:forEach var="size" items="${product.sizes}">
            <tr class="hover:bg-gray-50">
                <td class="px-4 py-2 font-medium">${size.sizeCode}</td>
                <td class="px-4 py-2">
                    <fmt:formatNumber value="${size.price}" type="currency" currencySymbol="$" />
                </td>
                <td class="px-4 py-2">
                    <%-- Lấy số lượng từ Map --%>
                    <c:set var="qty" value="${availabilityMap[size.productSizeId]}" />
                    <fmt:formatNumber value="${empty qty ? 0 : qty}" type="number" maxFractionDigits="0" /> 
                    units
                </td>
                <td class="px-4 py-2">
                    <button class="editSizeBtn bg-sky-500 text-white px-3 py-1 rounded text-xs"
                            data-size-id="${size.productSizeId}">
                        Edit
                    </button>
                    <a href="${pageContext.request.contextPath}/DeleteProductSizeServlet?sizeId=${size.productSizeId}"
                       onclick="return confirm('Delete this size?');"
                       class="bg-red-500 text-white px-3 py-1 rounded text-xs">
                        Delete
                    </a>
                </td>
            </tr>
        </c:forEach>
        <c:if test="${empty product.sizes}">
            <tr>
                <td colspan="4" class="p-4 text-center text-gray-500">
                    This product currently has no sizes defined.
                </td>
            </tr>
        </c:if>
    </tbody>
</table>