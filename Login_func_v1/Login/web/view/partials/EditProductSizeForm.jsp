<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%-- Lấy data từ LoadEditSizeFormServlet --%>
<c:set var="size" value="${requestScope.size}" />
<c:set var="currentIngredients" value="${requestScope.currentIngredients}" />
<c:set var="ingredientList" value="${requestScope.ingredientList}" />

<h2>Edit Size: ${size.sizeCode}</h2>

<%-- ✅ Form action trỏ đến Servlet mới --%>
<form action="${pageContext.request.contextPath}/EditProductSizeServlet" method="post" id="editSizeForm">
    
    <%-- ✅ Input ẩn cho ProductSizeID --%>
    <input type="hidden" name="productSizeId" value="${size.productSizeId}">

    <div class="grid grid-cols-2 gap-4 mb-4">
        <div>
            <label>Size Code</label>
            <input type="text" name="sizeCode" value="${size.sizeCode}" class="border p-2 rounded w-full" required>
        </div>
        <div>
            <label>Price</label>
            <input type="number" step="0.01" name="price" value="${size.price}" class="border p-2 rounded w-full" required>
        </div>
    </div>

    <hr class="my-2">

    <%-- ✅ LOGIC CÔNG THỨC: Giữ nguyên 100% từ file EditProductFullContent.jsp cũ --%>
    <table class="w-full border border-gray-300 mb-4" id="ingredientTable_EditSize">
        <thead class="bg-gray-200">
            <tr>
                <th class="p-2 text-left">Ingredient</th>
                <th class="p-2 text-left">Quantity</th>
                <th class="p-2 text-left">Unit</th>
                <th class="p-2 text-left">Action</th>
            </tr>
        </thead>
        <tbody>
    <c:forEach var="ing" items="${currentIngredients}">
        <tr class="border-b">
            <td class="px-2 py-1">${ing.itemName}</td>
            <td class="px-2 py-1">
                <input type="number" step="0.01" name="quantity[]" value="${ing.quantityNeeded}" 
                       class="border p-1 w-24">
                <input type="hidden" name="inventoryId[]" value="${ing.inventoryId}">
            </td>
            <td class="px-2 py-1">
                <input type="text" name="unit[]" value="${ing.unit}" 
                       class="border p-1 w-20" readonly>
            </td>
            <td class="px-2 py-1 text-center">
                <button type="button" 
                        class="removeBtn bg-red-500 text-white px-2 py-1 rounded inline-flex justify-center items-center">
                    ✕
                </button>
            </td>
        </tr>
    </c:forEach>
</tbody>

    </table>

    <%-- (Y HỆT PHẦN ADD MỚI CŨ) --%>
    <div class="flex gap-1 items-center mb-1">
        <select id="editNewIngredientSelect_EditSize" class="border p-2 rounded min-w-[150px]">
            <option value="">-- Select Ingredient --</option>
            <c:forEach var="inv" items="${ingredientList}">
                <option value="${inv.inventoryID}" data-unit="${inv.unit}">${inv.inventoryName}</option>
            </c:forEach>
        </select>
        <input type="number" id="editNewQuantity_EditSize" placeholder="Quantity" class="border w-20 rounded">
        <input type="text" id="editNewUnit_EditSize" placeholder="Unit" class="border w-20 rounded" readonly>
        <button type="button" id="editAddIngredientBtn_EditSize" class="bg-green-500 text-white px-2 py-2 rounded">Add</button>
    </div>


    <button type="submit" class="bg-blue-500 text-white px-4 py-2 rounded">Save All Changes</button>
</form>