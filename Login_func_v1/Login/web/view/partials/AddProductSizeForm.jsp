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

    <%-- ✅ LOGIC CÔNG THỨC: Giống như EditProductSizeForm --%>
    <h3 class="text-lg font-semibold text-gray-700 mb-2">Ingredients for this Size</h3>
    
    <table class="w-full border border-gray-300 mb-4" id="ingredientTable_AddSize">
        <thead class="bg-gray-200">
            <tr>
                <th class="p-2 text-left">Ingredient</th>
                <th class="p-2 text-left">Quantity</th>
                <th class="p-2 text-left">Unit</th>
                <th class="p-2 text-left">Action</th>
            </tr>
        </thead>
        <tbody id="ingredientList_AddSize">
            <%-- Nơi JS thêm các hàng ingredient --%>
        </tbody>
    </table>

    <%-- Form để add ingredient mới (giống EditProductSizeForm) --%>
    <div class="flex gap-1 items-center mb-1">
        <select id="newIngredientSelect_AddSize" class="border p-2 rounded min-w-[150px]">
            <option value="">-- Select Ingredient --</option>
            <c:forEach var="inv" items="${ingredientList}">
                <option value="${inv.inventoryID}" data-unit="${inv.unit}">${inv.inventoryName}</option>
            </c:forEach>
        </select>
        <input type="number" id="newQuantity_AddSize" placeholder="Quantity" step="0.01" class="border w-20 rounded">
        <input type="text" id="newUnit_AddSize" placeholder="Unit" class="border w-20 rounded" readonly>
        <button type="button" id="addIngredientBtn_AddSize" class="bg-green-500 text-white px-2 py-2 rounded">Add</button>
    </div>

    <button type="submit" class="mt-4 bg-green-600 text-white px-4 py-2 rounded">Save New Size</button>
</form>
