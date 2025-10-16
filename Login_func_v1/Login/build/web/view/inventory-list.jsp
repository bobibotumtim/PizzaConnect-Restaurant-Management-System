<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<html>
<head><title>Inventory Management</title></head>
<body>
    <h2>Inventory List</h2>
    <a href="inventory?action=new">➕ Add New Item</a>
    <table border="1" cellpadding="8">
        <tr>
            <th>ID</th><th>Item Name</th><th>Quantity</th><th>Unit</th><th>Last Updated</th><th>Action</th>
        </tr>
        <c:forEach var="i" items="${list}">
            <tr>
                <td>${i.inventoryID}</td>
                <td>${i.itemName}</td>
                <td>${i.quantity}</td>
                <td>${i.unit}</td>
                <td>${i.lastUpdated}</td>
                <td>
                    <a href="inventory?action=edit&id=${i.inventoryID}">Edit</a> |
                    <a href="inventory?action=delete&id=${i.inventoryID}" onclick="return confirm('Delete this item?');">Delete</a>
                </td>
            </tr>
        </c:forEach>
    </table>
</body>
</html>
