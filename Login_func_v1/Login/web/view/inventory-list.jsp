<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Manage Inventory</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">

<div class="container py-4">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="fw-bold text-primary">Manage Inventory</h2>
        <a href="manageinventory?action=add" class="btn btn-success">
            <i class="bi bi-plus-circle"></i> Add New Inventory
        </a>
    </div>

    <div class="card shadow-sm">
        <div class="card-body">
            <table class="table table-bordered align-middle text-center">
                <thead class="table-primary">
                <tr>
                    <th>ID</th>
                    <th>Item Name</th>
                    <th>Quantity</th>
                    <th>Unit</th>
                    <th>Last Updated</th>
                    <th>Status</th>
                    <th>Action</th>
                </tr>
                </thead>
                <tbody>
                <c:forEach var="inv" items="${inventoryList}">
                    <tr>
                        <td>${inv.inventoryID}</td>
                        <td>${inv.itemName}</td>
                        <td>${inv.quantity}</td>
                        <td>${inv.unit}</td>
                        <td>${inv.lastUpdated}</td>
                        <td>
                            <c:choose>
                                <c:when test="${inv.status eq 'Active'}">
                                    <span class="badge bg-success">Active</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge bg-secondary">Inactive</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td>
                            <a href="manageinventory?action=edit&id=${inv.inventoryID}" class="btn btn-sm btn-warning me-1">
                                Edit
                            </a>
                            <a href="manageinventory?action=toggle&id=${inv.inventoryID}" 
                               class="btn btn-sm ${inv.status eq 'Active' ? 'btn-danger' : 'btn-success'}"
                               onclick="return confirm('Are you sure to change status of this item?')">
                                ${inv.status eq 'Active' ? 'Deactivate' : 'Activate'}
                            </a>
                        </td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- Bootstrap Icons -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

