<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%-- Lấy productId và ingredientList từ LoadAddSizeFormServlet --%>
<c:set var="productId" value="${requestScope.productId}" />
<c:set var="ingredientList" value="${requestScope.ingredientList}" />

<h2>Add New Size</h2>

<%-- ✅ Form action trỏ đến Servlet mới --%>
<form action="${pageContext.request.contextPath}/AddProductSizeServlet" method="post" id="addSizeForm">
    
    <%-- ✅ Input ẩn cho ProductID --%>
    <input type="hidden" name="productId" value="${productId}">

    <%-- ✅ Dropdown chọn Size Code --%>
    <div class="form-group">
        <label for="addSizeCode">Size Code:</label>
        <select name="sizeCode" id="addSizeCode" class="border p-2 rounded" required>
            <option value="">-- Select Size --</option>
            <option value="F">F</option>
            <option value="L">L</option>
            <option value="M">M</option>
            <option value="S">S</option>
        </select>
    </div>
    
    <div class="form-group mt-2">
        <label for="addPrice">Price ($):</label>
        <input type="number" name="price" id="addPrice" step="0.01" class="border p-2 rounded" required>
    </div>

    <hr class="my-3">

    <%-- ✅ LOGIC CÔNG THỨC: Giữ nguyên 100% từ file AddProductModal.jsp cũ của bạn --%>
    <h3 class="text-lg font-semibold text-gray-700 mb-2">Ingredients for this Size</h3>
    <div id="ingredientList_AddSize">
        <%-- Nơi JS thêm các hàng --%>
    </div>
    
    <%-- Template để JS clone --%>
    <div id="ingredientTemplate_AddSize" class="ingredient-row flex gap-2 mb-2 hidden">
        <select name="ingredientId[]" class="ingredientSelect flex-1 border p-2 rounded">
            <option value="">-- Select Ingredient --</option>
            <c:forEach var="ing" items="${ingredientList}">
                <option value="${ing.inventoryID}" data-unit="${ing.unit}">
                    ${ing.inventoryName}
                </option>
            </c:forEach>
        </select>
        <input type="number" name="ingredientQty[]" placeholder="Quantity" step="0.01" class="w-24 border p-2 rounded">
        <input type="text" name="ingredientUnit[]" placeholder="Unit" class="unitField w-24 border p-2 rounded" readonly>
        <button type="button" class="removeIng bg-red-500 text-white px-2 rounded">✕</button>
    </div>

    <button type="button" id="addIngredientBtn_AddSize" class="bg-blue-500 text-white px-3 py-1 rounded mt-2">
        + Add Ingredient
    </button>

    <button type="submit" class="mt-4 bg-green-600 text-white px-4 py-2 rounded">Save New Size</button>
</form>
