<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head><title>Inventory Form</title></head>
<body>
    <h2>${inventory != null ? "Edit Inventory Item" : "Add Inventory Item"}</h2>
    <form action="inventory" method="post">
        <input type="hidden" name="id" value="${inventory.inventoryID}">
        Name: <input type="text" name="name" value="${inventory.itemName}" required><br>
        Quantity: <input type="number" step="0.01" name="quantity" value="${inventory.quantity}" required><br>
        Unit: <input type="text" name="unit" value="${inventory.unit}" required><br>
        <input type="submit" value="Save">
    </form>
    <a href="inventory">Back to list</a>
</body>
</html>

