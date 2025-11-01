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
    <h3 class="font-semibold mb-2">Ingredients</h3>
    <table class="w-full border border-gray-300 mb-4" id="ingredientTable_EditSize">
        <%-- (Y HỆT BẢNG CŨ) --%>
        <thead> ... </thead>
        <tbody>
            <c:forEach var="ing" items="${currentIngredients}">
                <tr>
                    <td>${ing.itemName}</td>
                    <td>
                        <input type="number" step="0.01" name="quantity[]" value="${ing.quantityNeeded}" ...>
                        <input type="hidden" name="inventoryId[]" value="${ing.inventoryId}">
                    </td>
                    <td>
                        <input type="text" name="unit[]" value="${ing.unit}" ... readonly>
                    </td>
                    <td>
                        <button type="button" class="removeBtn bg-red-500 ...">✕</button>
                    </td>
                </tr>
            </c:forEach>
        </tbody>
    </table>

    <%-- (Y HỆT PHẦN ADD MỚI CŨ) --%>
    <div class="flex gap-2 items-center mb-4">
        <select id="editNewIngredientSelect_EditSize" class="border p-2 rounded ...">
            <option value="">-- Select Ingredient --</option>
            <c:forEach var="inv" items="${ingredientList}">
                <option value="${inv.inventoryID}" data-unit="${inv.unit}">${inv.inventoryName}</option>
            </c:forEach>
        </select>
        <input type="number" id="editNewQuantity_EditSize" ...>
        <input type="text" id="editNewUnit_EditSize" ... readonly>
        <button type="button" id="editAddIngredientBtn_EditSize" class="bg-green-500 ...">Add</button>
    </div>

    <button type="submit" class="bg-blue-500 text-white px-4 py-2 rounded">Save All Changes</button>
</form>