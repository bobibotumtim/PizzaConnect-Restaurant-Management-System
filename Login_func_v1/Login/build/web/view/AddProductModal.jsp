<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<div id="addModal" class="modal">

    <div class="modal-content">
        <span class="close">&times;</span>
        <h2>Add New Product</h2>

        <form action="AddProductServlet" method="post" id="addProductForm">
            <div class="form-group">
                <label for="addProductName">Product Name:</label>
                <input type="text" name="productName" id="addProductName" required>
            </div>

            <div class="form-group">
                <label for="addDescription">Description:</label>
                <textarea name="description" id="addDescription" rows="3" required></textarea>
            </div>

            <div class="form-group">
                <label for="addPrice">Price ($):</label>
                <input type="number" name="price" id="addPrice" step="0.01" required>
            </div>

            <div class="form-group">
                <label for="addCategory">Category:</label>
                <input type="text" name="category" id="addCategory" required>
            </div>

            <div class="form-group">
                <label for="addImageUrl">Image URL:</label>
                <input type="text" name="imageUrl" id="addImageUrl" required>
            </div>

            <hr class="my-3">

            <h3 class="text-lg font-semibold text-gray-700 mb-2">Ingredients</h3>
            <div id="ingredientList">
            </div>
            <div id="ingredientTemplate" class="ingredient-row flex gap-2 mb-2 hidden">
                <select name="ingredientId[]" class="ingredientSelect flex-1 border p-2 rounded"
                        style="color:black; background:white; appearance:auto; min-width:150px;">
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


            <button type="button" id="addIngredientBtn" class="bg-blue-500 hover:bg-blue-600 text-white px-3 py-1 rounded mt-2">+ Add Ingredient</button>

            <button type="submit">Save Product</button>
        </form>
    </div>
</div>
