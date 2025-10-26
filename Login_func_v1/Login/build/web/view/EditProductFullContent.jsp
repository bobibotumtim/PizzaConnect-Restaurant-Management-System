<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="java.util.*, models.ProductIngredient" %>

<%
    models.Product product = (models.Product) request.getAttribute("product");
    List<ProductIngredient> currentIngredients = (List<ProductIngredient>) request.getAttribute("currentIngredients");
    List<Map<String,Object>> ingredientList = (List<Map<String,Object>>) request.getAttribute("ingredientList");
%>


        <h2 class="text-lg font-bold mb-4">Edit Product: ${product.productName}</h2>

        <form action="${pageContext.request.contextPath}/EditProductFullServlet" method="post">
            <input type="hidden" name="productId" value="${product.productId}">

            <!-- Product info -->
            <div class="grid grid-cols-2 gap-4 mb-4">
                <div>
                    <label>Product Name</label>
                    <input type="text" name="productName" value="${product.productName}" class="border p-2 rounded w-full" required>
                </div>
                <div>
                    <label>Category</label>
                    <input type="text" name="category" value="${product.category}" class="border p-2 rounded w-full" required>
                </div>
                <div class="col-span-2">
                    <label>Description</label>
                    <textarea name="description" class="border p-2 rounded w-full" rows="3">${product.description}</textarea>
                </div>
                <div>
                    <label>Price</label>
                    <input type="number" step="0.01" name="price" value="${product.price}" class="border p-2 rounded w-full" required>
                </div>
                <div>
                    <label>Image URL</label>
                    <input type="text" name="imageUrl" value="${product.imageUrl}" class="border p-2 rounded w-full">
                </div>
            </div>

            <hr class="my-2">

            <!-- Ingredient list table -->
            <h3 class="font-semibold mb-2">Ingredients</h3>
            <table class="w-full border border-gray-300 mb-4" id="ingredientTable">
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
                        <tr>
                            <td>${ing.itemName}</td>
                            <td>
                                <input type="number" step="0.01" name="quantity[]" value="${ing.quantityNeeded}" class="border p-1 w-24">
                                <input type="hidden" name="inventoryId[]" value="${ing.inventoryId}">
                            </td>
                            <td>
                                <input type="text" name="unit[]" value="${ing.unit}" class="border p-1 w-20" readonly>
                            </td>
                            <td>
                                <button type="button" class="removeBtn bg-red-500 text-white px-2 py-1 rounded">✕</button>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>

            <!-- Add new ingredient -->
            <div class="flex gap-2 items-center mb-4">
                <select id="editNewIngredientSelect" class="border p-2 rounded min-w-[150px]">
                    <option value="">-- Select Ingredient --</option>
                    <c:forEach var="inv" items="${ingredientList}">
                        <option value="${inv.inventoryID}" data-unit="${inv.unit}">${inv.inventoryName}</option>
                    </c:forEach>
                </select>
                <input type="number" id="editNewQuantity" placeholder="Quantity" class="border p-2 w-24 rounded">
                <input type="text" id="editNewUnit" placeholder="Unit" class="border p-2 w-24 rounded" readonly>
                <button type="button" id="editAddIngredientBtn" class="bg-green-500 text-white px-3 py-2 rounded">Add</button>
            </div>

            <button type="submit" class="bg-blue-500 text-white px-4 py-2 rounded">Save All Changes</button>
        </form>



