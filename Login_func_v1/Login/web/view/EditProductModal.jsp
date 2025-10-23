<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%-- EDIT POP-UP --%>
<div id="editModal" class="modal">
    <div class="modal-content">
        <span class="close">&times;</span>
        <h2>Edit Product</h2>

        <form action="EditProductServlet" method="post">
            <input type="hidden" name="action" value="update">
            <input type="hidden" name="productId" id="editProductId">

            <div class="form-group">
                <label for="editProductName">Product Name:</label>
                <input type="text" name="productName" id="editProductName" required>
            </div>

            <div class="form-group">
                <label for="editDescription">Description:</label>
                <textarea name="description" id="editDescription" rows="3"></textarea>
            </div>

            <div class="form-group">
                <label for="editPrice">Price ($):</label>
                <input type="number" name="price" id="editPrice" step="0.01" required>
            </div>

            <div class="form-group">
                <label for="editCategory">Category:</label>
                <input type="text" name="category" id="editCategory">
            </div>

            <div class="form-group">
                <label for="editImageUrl">Image URL:</label>
                <input type="text" name="imageUrl" id="editImageUrl">
            </div>

            <button type="submit">Save Changes</button>
        </form>
    </div>
</div>
